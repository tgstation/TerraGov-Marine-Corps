#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_SAFETY 10
#define AIRLOCK_WIRE_SPEED 11
#define AIRLOCK_WIRE_LIGHT 12

/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	isWireColorCut - returns 1 if that color wire is cut, or 0 if not
	isWireCut - returns 1 if that wire (e.g. AIRLOCK_WIRE_DOOR_BOLTS) is cut, or 0 if not
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	arePowerSystemsOn - 1 if the main or backup power are functioning, 0 if not. Does not check whether the power grid is charged or an APC has equipment on or anything like that. (Check (machine_stat & NOPOWER) for that)
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

//This generates the randomized airlock wire assignments for the game.
/proc/RandomAirlockWires()
	var/list/wire_assignments = CreateRandomAirlockWires()

	globalAirlockIndexToFlag = wire_assignments[2]
	globalAirlockIndexToWireColor = wire_assignments[3]
	globalAirlockWireColorToIndex = wire_assignments[4]
	return wire_assignments[1]

/proc/CreateRandomAirlockWires()
	//to make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/wires = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/airlockIndexToFlag = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/airlockIndexToWireColor = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/airlockWireColorToIndex = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	var/flagIndex = 1
	for (var/flag=1, flag<4096, flag+=flag)
		var/valid = 0
		var/list/colorList = list(AIRLOCK_WIRE_IDSCAN, AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2, AIRLOCK_WIRE_DOOR_BOLTS,
		AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2, AIRLOCK_WIRE_OPEN_DOOR, AIRLOCK_WIRE_AI_CONTROL, AIRLOCK_WIRE_ELECTRIFY,
		AIRLOCK_WIRE_SAFETY, AIRLOCK_WIRE_SPEED, AIRLOCK_WIRE_LIGHT)

		while (!valid)
			var/colorIndex = pick(colorList)
			if(wires[colorIndex]==0)
				valid = 1
				wires[colorIndex] = flag
				airlockIndexToFlag[flagIndex] = flag
				airlockIndexToWireColor[flagIndex] = colorIndex
				airlockWireColorToIndex[colorIndex] = flagIndex
				colorList -= colorIndex
		flagIndex+=1
	return list(wires, airlockIndexToFlag, airlockIndexToWireColor, airlockWireColorToIndex)

/* Example:
Airlock wires color -> flag are { 64, 128, 256, 2, 16, 4, 8, 32, 1 }.
Airlock wires color -> index are { 7, 8, 9, 2, 5, 3, 4, 6, 1 }.
Airlock index -> flag are { 1, 2, 4, 8, 16, 32, 64, 128, 256 }.
Airlock index -> wire color are { 9, 4, 6, 7, 5, 8, 1, 2, 3 }.
*/

/obj/machinery/door/airlock
	name = "\improper Airlock"
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door_closed"
	power_channel = ENVIRON

	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = 0
	var/lights = 1 // bolt lights show by default
	var/wires = 4095
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/list/signalers[12]
	var/lockdownbyai = 0
	autoclose = 1
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/circuitboard/airlock/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/secured_wires = 0	//for mapping use
	var/list/airlockIndexToFlag
	var/list/airlockWireColorToFlag
	var/list/airlockIndexToWireColor
	var/list/airlockWireColorToIndex
	var/no_panel = 0 //the airlock has no panel that can be screwdrivered open
	damage_cap = 3000

	tiles_with = list(
		/turf/closed/wall)

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(issilicon(user))
		return ..(user)
	if(iscarbon(user) && isElectrified())
		if(!justzap)
			if(shock(user, 100))
				justzap = TRUE
				spawn (openspeed)
					justzap = FALSE
				return
		else /*if(justzap)*/
			return
	else if(ishuman(user) && user.hallucination > 50 && prob(10) && !operating)
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			to_chat(H, "<span class='danger'>You feel a powerful shock course through your body!</span>")
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.siemens_coefficient)//not insulated
				H.halloss += 10
				H.stunned += 10
				return
	return ..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user as mob)
	..(user)



/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be \red open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/


/obj/machinery/door/airlock/proc/pulse(var/wireColor)
	//var/wireFlag = airlockWireColorToFlag[wireColor] //not used in this function
	var/wireIndex = airlockWireColorToIndex[wireColor]
	switch(wireIndex)
		if(AIRLOCK_WIRE_IDSCAN)
			//Sending a pulse through this flashes the red light on the door (if the door has power).
			if((src.arePowerSystemsOn()) && (!(machine_stat & NOPOWER)))
				do_animate("deny")
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter).
			src.loseMainPower()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//one wire for door bolts. Sending a pulse through this drops door bolts if they're not down (whether power's on or not),
			//raises them if they are down (only if power's on)
			if(!src.locked)
				src.lock()
			else
				src.unlock()
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter).
			src.loseBackupPower()
		if(AIRLOCK_WIRE_AI_CONTROL)
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if(src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateDialog()
			spawn(10)
				if(src.aiControlDisabled == 1)
					src.aiControlDisabled = 0
				else if(src.aiControlDisabled == 2)
					src.aiControlDisabled = -1
				src.updateDialog()
		if(AIRLOCK_WIRE_ELECTRIFY)
			//one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds.
			if(src.secondsElectrified==0)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				log_combat(usr, src, "electrified")
				src.secondsElectrified = 30
				spawn(10)
					//TODO: Move this into process() and make pulsing reset secondsElectrified to 30
					while (src.secondsElectrified>0)
						src.secondsElectrified-=1
						if(src.secondsElectrified<0)
							src.secondsElectrified = 0
//						src.updateUsrDialog()  //Commented this line out to keep the airlock from clusterfucking you with electricity. --NeoFite
						sleep(10)
		if(AIRLOCK_WIRE_OPEN_DOOR)
			//tries to open the door without ID
			//will succeed only if the ID wire is cut or the door requires no access
			if(!src.requiresID() || src.check_access(null))
				if(density)	open()
				else		close()
		if(AIRLOCK_WIRE_SAFETY)
			safe = !safe
			if(!src.density)
				close()
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			normalspeed = !normalspeed
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_LIGHT)
			lights = !lights
			src.updateUsrDialog()


/obj/machinery/door/airlock/proc/cut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor]
	wires &= ~wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			//Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be crowbarred open, but bolts-raising will not work. Cutting these wires may electocute the user.
			src.loseMainPower()
			src.shock(usr, 50)
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_DOOR_BOLTS)
			//Cutting this wire also drops the door bolts, and mending it does not raise them. (This is what happens now, except there are a lot more wires going to door bolts at present)
			src.lock()
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			//Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
			src.loseBackupPower()
			src.shock(usr, 50)
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if(src.aiControlDisabled == 0)
				src.aiControlDisabled = 1
			else if(src.aiControlDisabled == -1)
				src.aiControlDisabled = 2
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_ELECTRIFY)
			//Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted.
			if(src.secondsElectrified != -1)
				shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
				log_combat(usr, src, "electrified")
				src.secondsElectrified = -1
		if (AIRLOCK_WIRE_SAFETY)
			safe = 0
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			autoclose = 0
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_LIGHT)
			lights = 0
			src.updateUsrDialog()

/obj/machinery/door/airlock/proc/mend(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	var/wireIndex = airlockWireColorToIndex[wireColor] //not used in this function
	wires |= wireFlag
	switch(wireIndex)
		if(AIRLOCK_WIRE_MAIN_POWER1, AIRLOCK_WIRE_MAIN_POWER2)
			if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
				src.regainMainPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(AIRLOCK_WIRE_BACKUP_POWER1, AIRLOCK_WIRE_BACKUP_POWER2)
			if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
				src.regainBackupPower()
				src.shock(usr, 50)
				src.updateUsrDialog()
		if(AIRLOCK_WIRE_AI_CONTROL)
			//one wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aiControlDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if(src.aiControlDisabled == 1)
				src.aiControlDisabled = 0
			else if(src.aiControlDisabled == 2)
				src.aiControlDisabled = -1
			src.updateUsrDialog()
		if(AIRLOCK_WIRE_ELECTRIFY)
			if(src.secondsElectrified == -1)
				src.secondsElectrified = 0

		if (AIRLOCK_WIRE_SAFETY)
			safe = 1
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_SPEED)
			autoclose = 1
			if(!src.density)
				close()
			src.updateUsrDialog()

		if(AIRLOCK_WIRE_LIGHT)
			lights = 1
			src.updateUsrDialog()


/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireColorCut(var/wireColor)
	var/wireFlag = airlockWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/isWireCut(var/wireIndex)
	var/wireFlag = airlockIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((src.aiControlDisabled!=1) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((src.aiControlDisabled==1) && (!hackProof) && (!src.isAllPowerLoss()));

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	if(machine_stat & NOPOWER)
		return 0
	return (src.secondsMainPowerLost==0 || src.secondsBackupPowerLost==0)

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerLoss()
	if(machine_stat & NOPOWER)
		return 1
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
			return 1
	return 0

/obj/machinery/door/airlock/proc/regainMainPower()
	if(src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/loseMainPower()
	if(src.secondsMainPowerLost <= 0)
		src.secondsMainPowerLost = 60
		if(src.secondsBackupPowerLost < 10)
			src.secondsBackupPowerLost = 10
	if(!src.spawnPowerRestoreRunning)
		src.spawnPowerRestoreRunning = 1
		spawn(0)
			var/cont = 1
			while (cont)
				sleep(10)
				cont = 0
				if(src.secondsMainPowerLost>0)
					if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
						src.secondsMainPowerLost -= 1
						src.updateDialog()
					cont = 1

				if(src.secondsBackupPowerLost>0)
					if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
						src.secondsBackupPowerLost -= 1
						src.updateDialog()
					cont = 1
			src.spawnPowerRestoreRunning = 0
			src.updateDialog()

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/shock(mob/user, prb)
	if(!arePowerSystemsOn())
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	if(..())
		hasShocked = 1
		sleep(10)
		hasShocked = 0
		return 1
	else
		return 0


/obj/machinery/door/airlock/update_icon()
	if(overlays) overlays.Cut()
	if(density)
		if(locked && lights)
			icon_state = "door_locked"
		else
			icon_state = "door_closed"
		if(p_open || welded)
			overlays = list()
			if(p_open)
				overlays += image(icon, "panel_open")
			if(welded)
				overlays += image(icon, "welded")
	else
		icon_state = "door_open"

	return

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			if(overlays) overlays.Cut()
			if(p_open)
				spawn(2) // The only work around that works. Downside is that the door will be gone for a millisecond.
					flick("o_door_opening", src)  //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays.Cut()
			if(p_open)
				flick("o_door_closing", src)
			else
				flick("door_closing", src)
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density)
				flick("door_deny", src)
	return

/obj/machinery/door/airlock/attack_ai(mob/user as mob)
	if (!check_synth_access(user))
		return

	//Separate interface for the AI.
	user.set_interaction(src)
	var/t1
	if(src.secondsMainPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)))
			t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
		else
			t1 += text("Main power is offline indefinitely.<br>\n")
	else
		t1 += text("Main power is online.")

	if(src.secondsBackupPowerLost > 0)
		if((!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1)) && (!src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)))
			t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
		else
			t1 += text("Backup power is offline indefinitely.<br>\n")
	else if(src.secondsMainPowerLost > 0)
		t1 += text("Backup power is online.")
	else
		t1 += text("Backup power is offline, but will turn on if main power fails.")
	t1 += "<br>\n"

	if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
		t1 += text("IdScan wire is cut.<br>\n")
	else if(src.aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2))
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(src.secondsMainPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(src.secondsBackupPowerLost == 0)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
		t1 += text("Door bolt control wire is cut.<br>\n")
	else if(!src.locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
		if(src.arePowerSystemsOn())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
		t1 += text("Electrification wire is cut.<br>\n")
	if(src.secondsElectrified==-1)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
	else if(src.secondsElectrified>0)
		t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src.secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

	if(src.isWireCut(AIRLOCK_WIRE_SAFETY))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'> Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'> Restore?</a><br>\n",src)

	if(src.isWireCut(AIRLOCK_WIRE_SPEED))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'> Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'> Restore?</a><br>\n",src)




	if(src.welded)
		t1 += text("Door appears to have been welded shut.<br>\n")
	else if(!src.locked)
		if(src.density)
			t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
		else
			t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

	var/datum/browser/popup = new(user, "airlock", "<div align='center'>Airlock Control</div>")
	popup.set_content(t1)
	popup.open(FALSE)
	onclose(user, "airlock")


//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door


/obj/machinery/door/airlock/proc/hack(mob/user as mob)
	if(src.aiHacking==0)
		src.aiHacking=1
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(src.canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				src.aiHacking=0
				return
			else if(!src.canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				src.aiHacking=0
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
			src.aiControlDisabled = 2
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			src.aiHacking = 0
			if (user)
				src.attack_ai(user)


/obj/machinery/door/airlock/attack_paw(mob/user as mob)
	return src.attack_hand(user)

//Prying open doors
/obj/machinery/door/airlock/attack_alien(mob/living/carbon/Xenomorph/M)
	var/turf/cur_loc = M.loc
	if(isElectrified())
		if(shock(M, 70))
			return
	if(locked)
		to_chat(M, "<span class='warning'>\The [src] is bolted down tight.</span>")
		return FALSE
	if(welded)
		to_chat(M, "<span class='warning'>\The [src] is welded shut.</span>")
		return FALSE
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(!density)
		to_chat(M, "<span class='warning'>\The [src] is already open!</span>")
		return FALSE

	if(M.action_busy)
		return FALSE

	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	M.visible_message("<span class='warning'>\The [M] digs into \the [src] and begins to pry it open.</span>", \
	"<span class='warning'>You dig into \the [src] and begin to pry it open.</span>", null, 5)

	if(do_after(M, 40, FALSE, 5, BUSY_ICON_HOSTILE))
		if(M.loc != cur_loc)
			return FALSE //Make sure we're still there
		if(M.lying)
			return FALSE
		if(locked)
			to_chat(M, "<span class='warning'>\The [src] is bolted down tight.</span>")
			return FALSE
		if(welded)
			to_chat(M, "<span class='warning'>\The [src] is welded shut.</span>")
			return FALSE
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)
				M.visible_message("<span class='danger'>\The [M] pries \the [src] open.</span>", \
				"<span class='danger'>You pry \the [src] open.</span>", null, 5)

/obj/machinery/door/airlock/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	for(var/atom/movable/AM in get_turf(src))
		if(AM != src && AM.density && !AM.CanPass(M, M.loc))
			to_chat(M, "<span class='warning'>\The [AM] prevents you from squeezing under \the [src]!</span>")
			return
	if(locked || welded) //Can't pass through airlocks that have been bolted down or welded
		to_chat(M, "<span class='warning'>\The [src] is locked down tight. You can't squeeze underneath!</span>")
		return
	M.visible_message("<span class='warning'>\The [M] scuttles underneath \the [src]!</span>", \
	"<span class='warning'>You squeeze and scuttle underneath \the [src].</span>", null, 5)
	M.forceMove(loc)

/obj/machinery/door/airlock/attack_hand(mob/user as mob)
	if(!issilicon(usr))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return

	if(src.p_open)
		user.set_interaction(src)
		var/t1

		//t1 += text("[]: ", airlockFeatureNames[airlockWireColorToIndex[9]])
		var/list/wires = list(
			"Orange" = 1,
			"Dark red" = 2,
			"White" = 3,
			"Yellow" = 4,
			"Red" = 5,
			"Blue" = 6,
			"Green" = 7,
			"Grey" = 8,
			"Black" = 9,
			"Gold" = 10,
			"Aqua" = 11,
			"Pink" = 12
		)
		for(var/wiredesc in wires)
			var/is_uncut = src.wires & airlockWireColorToFlag[wires[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];wires=[wires[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[wires[wiredesc]]'>Pulse</a> "
				if(src.signalers[wires[wiredesc]])
					t1 += "<a href='?src=\ref[src];remove-signaler=[wires[wiredesc]]'>Detach signaler</a>"
				else
					t1 += "<a href='?src=\ref[src];signaler=[wires[wiredesc]]'>Attach signaler</a>"
			t1 += "<br>"

		t1 += text("<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]<br>\n[]", (src.locked ? "The door bolts have fallen!" : "The door bolts look up."), (src.lights ? "The door bolt lights are on." : "The door bolt lights are off!"), ((src.arePowerSystemsOn()) ? "The test light is on." : "The test light is off!"), (src.aiControlDisabled==0 ? "The 'AI control allowed' light is on." : "The 'AI control allowed' light is off."),  (src.safe==0 ? "The 'Check Wiring' light is on." : "The 'Check Wiring' light is off."), (src.normalspeed==0 ? "The 'Check Timing Mechanism' light is on." : "The 'Check Timing Mechanism' light is off."))

		t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)

		var/datum/browser/popup = new(user, "airlock", "<div align='center'>Access Panel</div>")
		popup.set_content(t1)
		popup.open(FALSE)
		onclose(user, "airlock")

	else
		..(user)


/obj/machinery/door/airlock/proc/check_synth_access(mob/user as mob)
	if(operating < 0) //emagged
		to_chat(user, "<span class='warning'>Unable to interface: Internal error.</span>")
		return 0
	if(!src.canAIControl())
		if(src.canAIHack(user))
			src.hack(user)
		else
			if (src.isAllPowerLoss()) //don't really like how this gets checked a second time, but not sure how else to do it.
				to_chat(user, "<span class='warning'>Unable to interface: Connection timed out.</span>")
			else
				to_chat(user, "<span class='warning'>Unable to interface: Connection refused.</span>")
		return 0
	return 1

/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	if(!nowindow)
		..()
	if(usr.stat || usr.restrained()|| usr.mob_size == MOB_SIZE_SMALL)
		return
	add_fingerprint(usr)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.interactee==src)
			usr.unset_interaction()
			return

	if((in_range(src, usr) && istype(src.loc, /turf)) && src.p_open)
		usr.set_interaction(src)
		if(ishuman(usr) && usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			usr.visible_message("<span class='notice'>[usr] fumbles around figuring out [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
			var/fumbling_time = 100 - 20 * usr.mind.cm_skills.engineer
			if(!do_after(usr, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(!iswirecutter(usr.get_active_held_item()))
				to_chat(usr, "You need wirecutters!")
				return
			if(src.isWireColorCut(t1))
				src.mend(t1)
			else
				src.cut(t1)
		else if(href_list["pulse"])
			var/t1 = text2num(href_list["pulse"])
			if(!ismultitool(usr.get_active_held_item()))
				to_chat(usr, "You need a multitool!")
				return
			if(src.isWireColorCut(t1))
				to_chat(usr, "You can't pulse a cut wire.")
				return
			else
				src.pulse(t1)
		else if(href_list["signaler"])
			var/wirenum = text2num(href_list["signaler"])
			if(!istype(usr.get_active_held_item(), /obj/item/assembly/signaler))
				to_chat(usr, "You need a signaller!")
				return
			if(src.isWireColorCut(wirenum))
				to_chat(usr, "You can't attach a signaller to a cut wire.")
				return
			var/obj/item/assembly/signaler/R = usr.get_active_held_item()
			if(R.secured)
				to_chat(usr, "This radio can't be attached!")
				return
			var/mob/M = usr
			if(M.drop_held_item())
				R.forceMove(src)
				R.airlock_wire = wirenum
				src.signalers[wirenum] = R
		else if(href_list["remove-signaler"])
			var/wirenum = text2num(href_list["remove-signaler"])
			if(!(src.signalers[wirenum]))
				to_chat(usr, "There's no signaller attached to that wire!")
				return
			var/obj/item/assembly/signaler/R = src.signalers[wirenum]
			R.loc = usr.loc
			R.airlock_wire = null
			src.signalers[wirenum] = null


	if(issilicon(usr))
		if (!check_synth_access(usr))
			return

		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					//disable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - The IdScan feature is already disabled.")
					else if(src.aiDisabledIdScanner)
						to_chat(usr, "The IdScan feature is already disabled.")
					else
						to_chat(usr, "The IdScan feature has been disabled.")
						src.aiDisabledIdScanner = 1
				if(2)
					//disrupt main power
					if(src.secondsMainPowerLost == 0)
						src.loseMainPower()
					else
						to_chat(usr, "Main power is already offline.")
				if(3)
					//disrupt backup power
					if(src.secondsBackupPowerLost == 0)
						src.loseBackupPower()
					else
						to_chat(usr, "Backup power is already offline.")
				if(4)
					//drop door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "The door bolt control wire has been cut - The door bolts are already dropped.")
					else if(src.locked)
						to_chat(usr, "The door bolts are already dropped.")
					else
						src.lock()
						to_chat(usr, "The door bolts have been dropped.")
				if(5)
					//un-electrify door
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, text("The electrification wire is cut - Cannot un-electrify the door."))
					else if(secondsElectrified != 0)
						to_chat(usr, "The door is now un-electrified.")
						src.secondsElectrified = 0
				if(7)
					//close door
					if(src.welded)
						to_chat(usr, text("The airlock has been welded shut!"))
					else if(src.locked)
						to_chat(usr, text("The door bolts are down!"))
					else if(!src.density)
						close()
					else
						open()
				if(8)
					// Safeties!  We don't need no stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (src.safe)
						safe = 0
					else
						to_chat(usr, text("Firmware reports safeties already overridden."))
				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (src.normalspeed)
						normalspeed = 0
					else
						to_chat(usr, text("Door timing circuity already accelerated."))
				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, "The bolt lights wire has been cut - The door bolt lights are already disabled.")
					else if (src.lights)
						lights = 0
						to_chat(usr, "The door bolt lights have been disabled.")
					else
						to_chat(usr, "The door bolt lights are already disabled!")

		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					//enable idscan
					if(src.isWireCut(AIRLOCK_WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - The IdScan feature cannot be enabled.")
					else if(src.aiDisabledIdScanner)
						to_chat(usr, "The IdScan feature has been enabled.")
						src.aiDisabledIdScanner = 0
					else
						to_chat(usr, "The IdScan feature is already enabled.")
				if(4)
					//raise door bolts
					if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
						to_chat(usr, "The door bolt control wire has been cut - The door bolts cannot be raised.")
					else if(!src.locked)
						to_chat(usr, "The door bolts are already raised.")
					else
						if(src.unlock())
							to_chat(usr, "The door bolts have been raised.")
						else
							to_chat(usr, "Unable to raise door bolts.")
				if(5)
					//electrify door for 30 seconds
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, text("The electrification wire has been cut.<br>\n"))
					else if(src.secondsElectrified==-1)
						to_chat(usr, text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n"))
					else if(src.secondsElectrified!=0)
						to_chat(usr, text("The door is already electrified. Cannot re-electrify it while it's already electrified.<br>\n"))
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						log_combat(usr, src, "electrified")
						to_chat(usr, "The door is now electrified for thirty seconds.")
						src.secondsElectrified = 30
						spawn(10)
							while (src.secondsElectrified>0)
								src.secondsElectrified-=1
								if(src.secondsElectrified<0)
									src.secondsElectrified = 0
								sleep(10)
				if(6)
					//electrify door indefinitely
					if(src.isWireCut(AIRLOCK_WIRE_ELECTRIFY))
						to_chat(usr, text("The electrification wire has been cut.<br>\n"))
					else if(src.secondsElectrified==-1)
						to_chat(usr, text("The door is already indefinitely electrified.<br>\n"))
					else if(src.secondsElectrified!=0)
						to_chat(usr, text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n"))
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						log_combat(usr, src, "electrified")
						to_chat(usr, "The door is now electrified.")
						src.secondsElectrified = -1
				if(7)
					//open door
					if(src.welded)
						to_chat(usr, text("The airlock has been welded shut!"))
					else if(src.locked)
						to_chat(usr, text("The door bolts are down!"))
					else if(src.density)
						open()
					else
						close()
				if (8)
					// Safeties!  Maybe we do need some stinking safeties!
					if (src.isWireCut(AIRLOCK_WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (!src.safe)
						safe = 1
					else
						to_chat(usr, text("Firmware reports safeties already in place."))
				if(9)
					// Door speed control
					if(src.isWireCut(AIRLOCK_WIRE_SPEED))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (!src.normalspeed)
						normalspeed = 1
					else
						to_chat(usr, text("Door timing circuity currently operating normally."))
				if(10)
					// Bolt lights
					if(src.isWireCut(AIRLOCK_WIRE_LIGHT))
						to_chat(usr, "The bolt lights wire has been cut - The door bolt lights cannot be enabled.")
					else if (!src.lights)
						lights = 1
						to_chat(usr, "The door bolt lights have been enabled")
					else
						to_chat(usr, "The door bolt lights are already enabled!")

	add_fingerprint(usr)
	update_icon()
	if(!nowindow)
		updateUsrDialog()
	return

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user)
	//to_chat(world, text("airlock attackby src [] obj [] mob []", src, C, user))
	if(istype(C, /obj/item/clothing/mask/cigarette))
		if(isElectrified())
			var/obj/item/clothing/mask/cigarette/L = C
			L.light("<span class='notice'>[user] lights their [L] on an electrical arc from the [src]")
			return
	if(!issilicon(user))
		if(isElectrified())
			if(shock(user, 75))
				return
	add_fingerprint(user)
	if(istype(C, /obj/item/weapon/zombie_claws) && (src.welded || src.locked))
		user.visible_message("<span class='notice'>[user] starts tearing into the door on the [src]!</span>", \
			"<span class='notice'>You start prying your hand into the gaps of the door with your fingers... This will take about 30 seconds.</span>", \
			"<span class='notice'>You hear tearing noises!</span>")
		if(do_after(user, 300, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='notice'>[user] slams the door open [src]!</span>", \
			"<span class='notice'>You slam the door open!</span>", \
			"<span class='notice'>You hear metal screeching!</span>")
			src.locked = 0
			src.welded = 0
			src.update_icon()
			src.open()
			src.locked = 1
			return
		return
	if((istype(C, /obj/item/tool/pickaxe/plasmacutter) && !operating && density && !user.action_busy))
		var/obj/item/tool/pickaxe/plasmacutter/P = C

		if(not_weldable)
			to_chat(user, "<span class='warning'>\The [src] would require something a lot stronger than [P] to cut!</span>")
			return

		if(!src.welded) //Cut apart the airlock if it isn't welded shut.
			if(!(P.start_cut(user, src.name, src)))
				return
			if(do_after(user, P.calc_delay(user), TRUE, 5, BUSY_ICON_HOSTILE) && P)
				P.cut_apart(user, src.name, src) //Airlocks cost as much as a wall to fully cut apart.
				P.debris(loc, 1, 1, 0, 3) //Metal sheet, some rods and wires.
				qdel(src)
			return

		if(!(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)))
			return
		if(do_after(user, P.calc_delay(user) * PLASMACUTTER_VLOW_MOD, TRUE, 5, BUSY_ICON_HOSTILE) && P)
			P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD) //Airlocks require much less power to unweld.
			src.welded = FALSE
			src.update_icon()
		return


	if(iswelder(C) && !operating && density)
		var/obj/item/tool/weldingtool/W = C

		if(not_weldable)
			to_chat(user, "<span class='warning'>\The [src] would require something a lot stronger than [W] to weld!</span>")
			return

		if(W.remove_fuel(0,user))
			user.visible_message("<span class='notice'>[user] starts working on \the [src] with [W].</span>", \
			"<span class='notice'>You start working on \the [src] with [W].</span>", \
			"<span class='notice'>You hear welding.</span>")
			playsound(src.loc, 'sound/items/weldingtool_weld.ogg', 25)
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD) && density)
				if(!src.welded)
					src.welded = 1
				else
					src.welded = null
				src.update_icon()
		return
	else if(isscrewdriver(C))
		if(no_panel)
			to_chat(user, "<span class='warning'>\The [src] has no panel to open!</span>")
			return

		p_open = !p_open
		to_chat(user, "<span class='notice'>You [p_open ? "open" : "close"] [src]'s panel.</span>")
		update_icon()
	else if(iswirecutter(C))
		return src.attack_hand(user)
	else if(ismultitool(C))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/assembly/signaler))
		return src.attack_hand(user)
	else if(C.pry_capable)
		if(C.pry_capable == IS_PRY_CAPABLE_CROWBAR && src.p_open && (operating == -1 || (density && welded && operating != 1 && !src.arePowerSystemsOn() && !src.locked)) )
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to deconstruct [src].</span>",
				"<span class='notice'>You fumble around figuring out how to deconstruct [src].</span>")
				var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
			if(width > 1)
				to_chat(user, "<span class='warning'>Large doors seem impossible to disassemble.</span>")
				return
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			user.visible_message("[user] starts removing the electronics from the airlock assembly.", "You start removing electronics from the airlock assembly.")
			if(do_after(user,40, TRUE, 5, BUSY_ICON_BUILD))
				to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")

				var/obj/structure/door_assembly/da = new assembly_type(src.loc)
				if (istype(da, /obj/structure/door_assembly/multi_tile))
					da.setDir(dir)

 				da.anchored = 1
				if(mineral)
					da.glass = mineral
				//else if(glass)
				else if(glass && !da.glass)
					da.glass = 1
				da.state = 1
				da.created_name = src.name
				da.update_state()

				var/obj/item/circuitboard/airlock/ae
				if(!electronics)
					ae = new/obj/item/circuitboard/airlock( src.loc )
					if(!src.req_access)
						src.check_access()
					if(src.req_access.len)
						ae.conf_access = src.req_access
					else if (src.req_one_access.len)
						ae.conf_access = src.req_one_access
						ae.one_access = 1
				else
					ae = electronics
					if(electronics.is_general_board)
						ae.set_general()
					electronics = null
					ae.loc = src.loc
				if(operating == -1)
					ae.icon_state = "door_electronics_smoked"
					operating = 0

				qdel(src)
				return

		else if(arePowerSystemsOn() && C.pry_capable != IS_PRY_CAPABLE_FORCE)
			to_chat(user, "<span class='warning'>The airlock's motors resist your efforts to force it.</span>")
		else if(locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced.</span>")
		else if(welded)
			to_chat(user, "<span class='warning'>The airlock is welded shut.</span>")
		else if(C.pry_capable == IS_PRY_CAPABLE_FORCE)
			return FALSE //handled by the item's afterattack
		else if(!operating )
			spawn(0)
				if(density)
					open(1)
				else
					close(1)
		return TRUE //no afterattack call
	else
		return ..()


///obj/machinery/door/airlock/phoron/attackby(C as obj, mob/user as mob)
//	if(C)
//		ignite(is_hot(C))
//	..()

/obj/machinery/door/airlock/open(var/forced=0)
	if( operating || welded || locked || !loc)
		return 0
	if(!forced)
		if( !arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR) )
			return 0
	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 25, 1)
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 25, 0)
	if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close()
	return ..()

/obj/machinery/door/airlock/close(var/forced=0)
	if(operating || welded || locked || !loc)
		return
	if(!forced)
		if( !arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS) )
			return
	if(safe)
		for(var/turf/turf in locs)
			if(locate(/mob/living) in turf)
			//	playsound(src.loc, 'sound/machines/buzz-two.ogg', 25, 0)	//THE BUZZING IT NEVER STOPS	-Pete
				spawn (60 + openspeed)
					close()
				return

	for(var/turf/turf in locs)
		for(var/mob/living/M in turf)
			if(iscyborg(M))
				M.apply_damage(DOOR_CRUSH_DAMAGE, BRUTE)
			else
				M.apply_damage(DOOR_CRUSH_DAMAGE, BRUTE)
				M.SetStunned(5)
				M.SetKnockeddown(5)
				if (iscarbon(M))
					var/mob/living/carbon/C = M
					var/datum/species/S = C.species
					if(S?.species_flags & NO_PAIN)
						M.emote("pain")
			var/turf/location = src.loc
			if(istype(location, /turf))
				location.add_mob_blood(M)

	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 25, 1)
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 25, 0)
	for(var/turf/turf in locs)
		var/obj/structure/window/killthis = (locate(/obj/structure/window) in turf)
		if(killthis)
			killthis.ex_act(2)//Smashin windows
	..()
	return

/obj/machinery/door/airlock/proc/lock(var/forced=0)
	if (operating || src.locked) return

	src.locked = 1
	for(var/mob/M in range(1,src))
		M.show_message("You hear a click from the bottom of the door.", 2)
	update_icon()

/obj/machinery/door/airlock/proc/unlock(var/forced=0)
	if (operating || !src.locked) return

	if (forced || (src.arePowerSystemsOn())) //only can raise bolts if power's on
		src.locked = 0
		for(var/mob/M in range(1,src))
			M.show_message("You hear a click from the bottom of the door.", 2)
		update_icon()
		return 1
	return 0

/obj/machinery/door/airlock/Initialize()
	. = ..()

	//wires
	if (!secured_wires)
		airlockWireColorToFlag = globalAirlockWireColorToFlag
		airlockIndexToFlag = globalAirlockIndexToFlag
		airlockIndexToWireColor = globalAirlockIndexToWireColor
		airlockWireColorToIndex = globalAirlockWireColorToIndex
	else
		randomize_wires()

	if(closeOtherId != null)
		for (var/obj/machinery/door/airlock/A in GLOB.machines)
			if(A.closeOtherId == src.closeOtherId && A != src)
				src.closeOther = A
				break

	// fix smoothing
	relativewall_neighbours()

/obj/machinery/door/airlock/proc/randomize_wires()
	var/wire_assignments = CreateRandomAirlockWires()
	airlockWireColorToFlag = wire_assignments[1]
	airlockIndexToFlag = wire_assignments[2]
	airlockIndexToWireColor = wire_assignments[3]
	airlockWireColorToIndex = wire_assignments[4]

/obj/machinery/door/airlock/proc/prison_open()
	src.unlock()
	src.open()
	src.lock()
	return


/obj/machinery/door/airlock/proc/update_nearby_icons()
	relativewall_neighbours()
