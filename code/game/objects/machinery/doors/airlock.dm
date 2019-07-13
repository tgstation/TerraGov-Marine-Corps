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
	var/no_panel = 0 //the airlock has no panel that can be screwdrivered open
	damage_cap = 3000
	var/emergency = FALSE

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


/obj/machinery/door/airlock/proc/isElectrified()
	if(secondsElectrified != MACHINE_NOT_ELECTRIFIED)
		return TRUE
	return FALSE


/obj/machinery/door/airlock/proc/canAIControl(mob/user)
	return ((aiControlDisabled != 1) && !isAllPowerCut())


/obj/machinery/door/airlock/proc/canAIHack()
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerCut()));


/obj/machinery/door/airlock/hasPower()
	return ((!secondsMainPowerLost || !secondsBackupPowerLost) && !(machine_stat & NOPOWER))


/obj/machinery/door/airlock/requiresID()
	return !(wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner)


/obj/machinery/door/airlock/proc/isAllPowerCut()
	if((wires.is_cut(WIRE_POWER1) || wires.is_cut(WIRE_POWER2)) && (wires.is_cut(WIRE_BACKUP1) || wires.is_cut(WIRE_BACKUP2)))
		return TRUE


/obj/machinery/door/airlock/proc/regainMainPower()
	if(secondsMainPowerLost > 0)
		secondsMainPowerLost = 0
	update_icon()


/obj/machinery/door/airlock/proc/handlePowerRestore()
	var/cont = TRUE
	while(cont)
		sleep(10)
		if(QDELETED(src))
			return
		cont = FALSE
		if(secondsMainPowerLost > 0)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				secondsMainPowerLost -= 1
				updateDialog()
			cont = TRUE
		if(secondsBackupPowerLost > 0)
			if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
				secondsBackupPowerLost -= 1
				updateDialog()
			cont = TRUE
	spawnPowerRestoreRunning = FALSE
	updateDialog()
	update_icon()


/obj/machinery/door/airlock/proc/loseMainPower()
	if(secondsMainPowerLost <= 0)
		secondsMainPowerLost = 60
		if(secondsBackupPowerLost < 10)
			secondsBackupPowerLost = 10
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, .proc/handlePowerRestore)
	update_icon()


/obj/machinery/door/airlock/proc/loseBackupPower()
	if(secondsBackupPowerLost < 60)
		secondsBackupPowerLost = 60
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, .proc/handlePowerRestore)
	update_icon()


/obj/machinery/door/airlock/proc/regainBackupPower()
	if(secondsBackupPowerLost > 0)
		secondsBackupPowerLost = 0
	update_icon()

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/shock(mob/user, prb)
	if(!hasPower())
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
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) || welded)
			overlays = list()
			if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
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
			if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
				spawn(2) // The only work around that works. Downside is that the door will be gone for a millisecond.
					flick("o_door_opening", src)  //can not use flick due to BYOND bug updating overlays right before flicking
			else
				flick("door_opening", src)
		if("closing")
			if(overlays) overlays.Cut()
			if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
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


/obj/machinery/door/airlock/attack_ai(mob/user)
	if(CHECK_BITFIELD(obj_flags, EMAGGED))
		to_chat(user, "<span class='warning'>Unable to interface: Airlock is unresponsive.</span>")
		return

	ui_interact(user)


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
/obj/machinery/door/airlock/attack_alien(mob/living/carbon/xenomorph/M)
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

	if(do_after(M, 40, FALSE, src, BUSY_ICON_HOSTILE) && !M.lying)
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

/obj/machinery/door/airlock/attack_larva(mob/living/carbon/xenomorph/larva/M)
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

/obj/machinery/door/airlock/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!issilicon(user) && isElectrified())
		shock(user, 100)

/obj/machinery/door/airlock/Topic(href, href_list, nowindow = 0)
	. = ..()
	if(.)
		return
	if(usr.stat || usr.restrained()|| usr.mob_size == MOB_SIZE_SMALL)
		return
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.interactee==src)
			usr.unset_interaction()
			return

	if((in_range(src, usr) && istype(src.loc, /turf)) && CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		usr.set_interaction(src)
		if(ishuman(usr) && usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			usr.visible_message("<span class='notice'>[usr] fumbles around figuring out [src]'s wiring.</span>",
			"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
			var/fumbling_time = 100 - 20 * usr.mind.cm_skills.engineer
			if(!do_after(usr, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return FALSE

	if(issilicon(usr))
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					//disable idscan
					if(wires.is_cut(WIRE_IDSCAN))
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
					if(wires.is_cut(WIRE_BOLTS))
						to_chat(usr, "The door bolt control wire has been cut - The door bolts are already dropped.")
					else if(src.locked)
						to_chat(usr, "The door bolts are already dropped.")
					else
						src.lock()
						to_chat(usr, "The door bolts have been dropped.")
				if(5)
					//un-electrify door
					if(wires.is_cut(WIRE_SHOCK))
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
					if (wires.is_cut(WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (src.safe)
						safe = 0
					else
						to_chat(usr, text("Firmware reports safeties already overridden."))
				if(9)
					// Door speed control
					if(wires.is_cut(WIRE_TIMING))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (src.normalspeed)
						normalspeed = 0
					else
						to_chat(usr, text("Door timing circuity already accelerated."))
				if(10)
					// Bolt lights
					if(wires.is_cut(WIRE_LIGHT))
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
					if(wires.is_cut(WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - The IdScan feature cannot be enabled.")
					else if(src.aiDisabledIdScanner)
						to_chat(usr, "The IdScan feature has been enabled.")
						src.aiDisabledIdScanner = 0
					else
						to_chat(usr, "The IdScan feature is already enabled.")
				if(4)
					//raise door bolts
					if(wires.is_cut(WIRE_BOLTS))
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
					if(wires.is_cut(WIRE_SHOCK))
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
					if(wires.is_cut(WIRE_SHOCK))
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
					if (wires.is_cut(WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (!src.safe)
						safe = 1
					else
						to_chat(usr, text("Firmware reports safeties already in place."))
				if(9)
					// Door speed control
					if(wires.is_cut(WIRE_TIMING))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (!src.normalspeed)
						normalspeed = 1
					else
						to_chat(usr, text("Door timing circuity currently operating normally."))
				if(10)
					// Bolt lights
					if(wires.is_cut(WIRE_LIGHT))
						to_chat(usr, "The bolt lights wire has been cut - The door bolt lights cannot be enabled.")
					else if (!src.lights)
						lights = 1
						to_chat(usr, "The door bolt lights have been enabled")
					else
						to_chat(usr, "The door bolt lights are already enabled!")

	update_icon()
	if(!nowindow)
		updateUsrDialog()
	return

/obj/machinery/door/airlock/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/clothing/mask/cigarette) && isElectrified())
		var/obj/item/clothing/mask/cigarette/L = I
		L.light("<span class='notice'>[user] lights their [L] on an electrical arc from the [src]")

	else if(!issilicon(user) && isElectrified())
		shock(user, 75)

	if(iswelder(I) && !operating && density)
		var/obj/item/tool/weldingtool/W = I

		if(not_weldable)
			to_chat(user, "<span class='warning'>\The [src] would require something a lot stronger than [W] to weld!</span>")
			return

		if(user.a_intent != INTENT_HELP)
			if(!W.tool_start_check(user, amount = 0))
				return

			user.visible_message("<span class='notice'>[user] is [welded ? "unwelding":"welding"] the airlock.</span>", \
							"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
							"<span class='italics'>You hear welding.</span>")

			if(!W.use_tool(src, user, 40, volume = 50, extra_checks = CALLBACK(src, .proc/weld_checks)))
				return

			welded = !welded
			user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
								"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
			update_icon()
		else
			if(obj_integrity >= max_integrity)
				to_chat(user, "<span class='notice'>The airlock doesn't need repairing.</span>")
				return

			if(!W.tool_start_check(user, amount=0))
				return

			user.visible_message("<span class='notice'>[user] is welding the airlock.</span>", \
							"<span class='notice'>You begin repairing the airlock...</span>", \
							"<span class='italics'>You hear welding.</span>")

			if(!W.use_tool(src, user, 40, volume = 50, extra_checks = CALLBACK(src, .proc/weld_checks)))
				return

			obj_integrity = max_integrity
			DISABLE_BITFIELD(machine_stat, BROKEN)
			user.visible_message("<span class='notice'>[user.name] has repaired [src].</span>", \
								"<span class='notice'>You finish repairing the airlock.</span>")
			update_icon()
				

	else if(isscrewdriver(I))
		if(no_panel)
			to_chat(user, "<span class='warning'>\The [src] has no panel to open!</span>")
			return

		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		to_chat(user, "<span class='notice'>You [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "close"] [src]'s panel.</span>")
		update_icon()
		
	else if(iswirecutter(I))
		return attack_hand(user)

	else if(ismultitool(I))
		return attack_hand(user)

	else if(istype(I, /obj/item/assembly/signaler))
		return attack_hand(user)

	else if(!I.pry_capable)
		return TRUE

	else if(I.pry_capable == IS_PRY_CAPABLE_CROWBAR && CHECK_BITFIELD(machine_stat, PANEL_OPEN) && (operating == -1 || (density && welded && operating != 1 && !hasPower() && !locked)))
		if(user.mind?.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to deconstruct [src].</span>",
			"<span class='notice'>You fumble around figuring out how to deconstruct [src].</span>")

			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return

		if(width > 1)
			to_chat(user, "<span class='warning'>Large doors seem impossible to disassemble.</span>")
			return

		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		user.visible_message("[user] starts removing the electronics from the airlock assembly.", "You start removing electronics from the airlock assembly.")
		
		if(!do_after(user,40, TRUE, src, BUSY_ICON_BUILD))
			return

		to_chat(user, "<span class='notice'>You removed the airlock electronics!</span>")

		var/obj/structure/door_assembly/DA = new assembly_type(loc)
		if(istype(DA, /obj/structure/door_assembly/multi_tile))
			DA.setDir(dir)
			DA.anchored = TRUE

		if(mineral)
			DA.glass = mineral

		else if(glass && !DA.glass)
			DA.glass = TRUE

		DA.state = 1
		DA.created_name = name
		DA.update_state()

		var/obj/item/circuitboard/airlock/AE
		if(!electronics)
			AE = new(loc)
			if(!req_access)
				check_access()
			if(length(req_access))
				AE.conf_access = req_access
			else if(length(req_one_access))
				AE.conf_access = req_one_access
				AE.one_access = TRUE
		else
			AE = electronics
			if(electronics.is_general_board)
				AE.set_general()
			AE.forceMove(loc)
			electronics = null

		if(operating == -1)
			AE.icon_state = "door_electronics_smoked"
			operating = FALSE
		qdel(src)

	else if(hasPower() && I.pry_capable != IS_PRY_CAPABLE_FORCE)
		to_chat(user, "<span class='warning'>The airlock's motors resist your efforts to force it.</span>")

	else if(locked)
		to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced.</span>")

	else if(welded)
		to_chat(user, "<span class='warning'>The airlock is welded shut.</span>")

	else if(I.pry_capable == IS_PRY_CAPABLE_FORCE)
		return FALSE //handled by the item's afterattack

	else if(!operating)
		if(density)
			open(1)
		else
			close(1)

	return TRUE


///obj/machinery/door/airlock/phoron/attackby(C as obj, mob/user as mob)
//	if(C)
//		ignite(is_hot(C))
//	..()

/obj/machinery/door/airlock/open(forced=0)
	if( operating || welded || locked || !loc)
		return 0
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_OPEN))
			return 0
	use_power(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(istype(src, /obj/machinery/door/airlock/glass))
		playsound(src.loc, 'sound/machines/windowdoor.ogg', 25, 1)
	else
		playsound(src.loc, 'sound/machines/airlock.ogg', 25, 0)
	if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
		src.closeOther.close()
	return ..()

/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked || !loc)
		return
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
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
			M.apply_damage(DOOR_CRUSH_DAMAGE, BRUTE)
			M.set_stunned(5)
			M.set_knocked_down(5)
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

/obj/machinery/door/airlock/proc/lock(forced=0)
	if (operating || src.locked) return

	src.locked = 1
	for(var/mob/M in range(1,src))
		M.show_message("You hear a click from the bottom of the door.", 2)
	update_icon()

/obj/machinery/door/airlock/proc/unlock(forced=0)
	if (operating || !src.locked) return

	if(forced || hasPower()) //only can raise bolts if power's on
		src.locked = 0
		for(var/mob/M in range(1,src))
			M.show_message("You hear a click from the bottom of the door.", 2)
		update_icon()
		return 1
	return 0

/obj/machinery/door/airlock/Initialize(mapload, ...)
	. = ..()

	wires = new /datum/wires/airlock(src)

	if(closeOtherId != null)
		for (var/obj/machinery/door/airlock/A in GLOB.machines)
			if(A.closeOtherId == src.closeOtherId && A != src)
				src.closeOther = A
				break

	// fix smoothing
	relativewall_neighbours()


/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(wires)
	return ..()


/obj/machinery/door/airlock/proc/prison_open()
	src.unlock()
	src.open()
	src.lock()
	return


/obj/machinery/door/airlock/proc/update_nearby_icons()
	relativewall_neighbours()


/obj/machinery/door/airlock/proc/set_electrified(seconds, mob/user)
	secondsElectrified = seconds
	if(secondsElectrified > MACHINE_NOT_ELECTRIFIED)
		INVOKE_ASYNC(src, .proc/electrified_loop)

	if(user)
		var/message
		switch(secondsElectrified)
			if(MACHINE_ELECTRIFIED_PERMANENT)
				message = "permanently shocked"
			if(MACHINE_NOT_ELECTRIFIED)
				message = "unshocked"
			else
				message = "temp shocked for [secondsElectrified] seconds"
		LAZYADD(shockedby, text("\[[time_stamp()]\] [key_name(user)] - ([uppertext(message)])"))
		log_combat(user, src, message)


/obj/machinery/door/airlock/proc/electrified_loop()
	while(secondsElectrified > MACHINE_NOT_ELECTRIFIED)
		sleep(10)
		if(QDELETED(src))
			return

		secondsElectrified--
		updateDialog()
	// This is to protect against changing to permanent, mid loop.
	if(secondsElectrified == MACHINE_NOT_ELECTRIFIED)
		set_electrified(MACHINE_NOT_ELECTRIFIED)
	else
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT)
	updateDialog()


/obj/machinery/door/airlock/proc/user_toggle_open(mob/user)
	if(!canAIControl(user))
		return

	if(welded)
		to_chat(user, "<span class='warning'>The airlock has been welded shut.</span>")
		return

	if(locked)
		to_chat(user, "<span class='warning'>The door bolts are down.</span>")
		return

	if(!density)
		close()
	else
		open()


/obj/machinery/door/airlock/proc/shock_restore(mob/user)
	if(!canAIControl(user))
		return

	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "<span class='warning'>The electrification wire is cut.</span>")
		return

	if(isElectrified())
		set_electrified(MACHINE_NOT_ELECTRIFIED, user)


/obj/machinery/door/airlock/proc/shock_temp(mob/user)
	if(!canAIControl(user))
		return

	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "<span class='warning'>The electrification wire is cut.</span>")
		return

	set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, user)


/obj/machinery/door/airlock/proc/shock_perm(mob/user)
	if(!canAIControl(user))
		return

	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "<span class='warning'>The electrification wire is cut.</span>")
		return

	set_electrified(MACHINE_ELECTRIFIED_PERMANENT, user)


/obj/machinery/door/airlock/proc/emergency_on(mob/user)
	if(!canAIControl(user))
		return

	if(emergency)
		to_chat(user, "<span class='warning'>Emergency access is already enabled.</span>")		
		return

	emergency = TRUE
	update_icon()



/obj/machinery/door/airlock/proc/emergency_off(mob/user)
	if(!canAIControl(user))
		return

	if(!emergency)
		to_chat(user, "<span class='warning'>Emergency access is already disabled.</span>")
		return

	emergency = FALSE
	update_icon()


/obj/machinery/door/airlock/proc/bolt_raise(mob/user)
	if(!canAIControl(user))
		return

	if(wires.is_cut(WIRE_BOLTS))
		to_chat(user, "<span class='warning'>The door bolt wire is cut.</span>")
		return

	if(!locked)
		to_chat(user, "<span class='warning'>The door bolts are already up.</span>")
		return

	if(!hasPower())
		to_chat(user, "<span class='warning'>Cannot raise door bolts due to power failure.</span>")
		return

	unbolt()
		


/obj/machinery/door/airlock/proc/bolt_drop(mob/user)
	if(!canAIControl(user))
		return

	if(wires.is_cut(WIRE_BOLTS))
		to_chat(user, "<span class='warning'>The door bolt wire is cut.</span>")
		return

	bolt()


/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return

	locked = TRUE
	playsound(src, 'sound/machines/boltsdown.ogg', 30, 0, 3)
	audible_message("<span class='notice'>You hear a click from the bottom of the door.</span>", null,  1)
	update_icon()


/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return

	locked = FALSE
	playsound(src, 'sound/machines/boltsup.ogg', 30, 0, 3)
	audible_message("<span class='notice'>You hear a click from the bottom of the door.</span>", null,  1)
	update_icon()


/obj/machinery/door/airlock/proc/weld_checks()
	return !operating && density