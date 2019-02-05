#define APC_WIRE_IDSCAN      (1<<0)
#define APC_WIRE_MAIN_POWER1 (1<<1)
#define APC_WIRE_MAIN_POWER2 (1<<2)
#define APC_WIRE_AI_CONTROL  (1<<3)

#define APC_RESET_EMP 5

//update_state
#define UPSTATE_OPENED1 (1<<0)
#define UPSTATE_OPENED2 (1<<1)
#define UPSTATE_MAINT (1<<2)
#define UPSTATE_BROKE (1<<3)
#define UPSTATE_WIREEXP (1<<4)
#define UPSTATE_ALLGOOD (1<<5)

//update_overlay
#define APC_UPOVERLAY_CHARGEING0 (1<<0)
#define APC_UPOVERLAY_CHARGEING1 (1<<1)
#define APC_UPOVERLAY_CHARGEING2 (1<<2)
#define APC_UPOVERLAY_EQUIPMENT0 (1<<3)
#define APC_UPOVERLAY_EQUIPMENT1 (1<<4)
#define APC_UPOVERLAY_EQUIPMENT2 (1<<5)
#define APC_UPOVERLAY_LIGHTING0 (1<<6)
#define APC_UPOVERLAY_LIGHTING1 (1<<7)
#define APC_UPOVERLAY_LIGHTING2 (1<<8)
#define APC_UPOVERLAY_ENVIRON0 (1<<9)
#define APC_UPOVERLAY_ENVIRON1 (1<<10)
#define APC_UPOVERLAY_ENVIRON2 (1<<11)
#define APC_UPOVERLAY_LOCKED (1<<12)
#define APC_UPOVERLAY_OPERATING (1<<13)
#define APC_UPOVERLAY_CELL_IN (1<<14)
#define APC_UPOVERLAY_BLUESCREEN (1<<15)

#define APC_ELECTRONICS_MISSING   0
#define APC_ELECTRONICS_INSTALLED 1
#define APC_ELECTRONICS_SECURED   2

#define APC_COVER_CLOSED  0
#define APC_COVER_OPENED  1
#define APC_COVER_REMOVED 2

#define APC_NOT_CHARGING  0
#define APC_CHARGING      1
#define APC_FULLY_CHARGED 2

//The Area Power Controller (APC), formerly Power Distribution Unit (PDU)
//One per area, needs wire conection to power network

//Controls power to devices in that area
//May be opened to change power cell
//Three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "apc0"
	anchored = TRUE
	use_power = NO_POWER_USE
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	unacidable = TRUE
	var/area/area
	var/areastring = null
	var/obj/item/cell/cell
	var/start_charge = 90 //Initial cell charge %
	var/cell_type = /obj/item/cell/apc //0 = no cell, 1 = regular, 2 = high-cap (x5) <- old, now it's just 0 = no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/opened = APC_COVER_CLOSED
	var/shorted = FALSE
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = TRUE
	var/charging = APC_NOT_CHARGING
	var/chargemode = 1
	var/chargecount = 0
	var/locked = TRUE
	var/coverlocked = TRUE
	var/aidisabled = FALSE
	var/obj/machinery/power/terminal/terminal = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/apcwires = 15
	powernet = 0 //Set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/debug = 0
	var/autoflag = 0 // 0 = off, 1 = eqp and lights off, 2 = eqp off, 3 = all on.
	var/has_electronics = APC_ELECTRONICS_MISSING
	var/overload = 1 //Used for the Blackout malf module
	var/beenhit = 0 //Used for counting how many times it has been hit, used for Aliens at the moment
	var/list/apcwirelist = list(
		"Orange" = 1,
		"Dark red" = 2,
		"White" = 3,
		"Yellow" = 4,
	)
	var/longtermpower = 10
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = 0
	var/updating_icon = 0
	var/crash_break_probability = 85 //Probability of APC being broken by a shuttle crash on the same z-level
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ
	var/obj/item/circuitboard/apc/electronics = null

/proc/RandomAPCWires()
	//To make this not randomize the wires, just set index to 1 and increment it in the flag for loop (after doing everything else).
	var/list/apcwires = list(0, 0, 0, 0)
	APCIndexToFlag = list(0, 0, 0, 0)
	APCIndexToWireColor = list(0, 0, 0, 0)
	APCWireColorToIndex = list(0, 0, 0, 0)
	var/flagIndex = 1
	for(var/flag = 1, flag < 16, flag += flag)
		var/valid = 0
		while(!valid)
			var/colorIndex = rand(1, 4)
			if(apcwires[colorIndex] == 0)
				valid = 1
				apcwires[colorIndex] = flag
				APCIndexToFlag[flagIndex] = flag
				APCIndexToWireColor[flagIndex] = colorIndex
				APCWireColorToIndex[colorIndex] = flagIndex
		flagIndex += 1
	return apcwires

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/updateDialog()
	if(stat & (BROKEN|MAINT))
		return
	..()

/obj/machinery/power/apc/New(turf/loc, var/ndir, var/building=FALSE)
	. = ..()
	GLOB.apcs_list += src

	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir

	switch(dir)
		if(NORTH)
			pixel_y = 32
		if(SOUTH)
			pixel_y = -32
		if(EAST)
			pixel_x = 32
		if(WEST)
			pixel_x = -32

	if(building)
		var/area/A = get_area(src)
		area = A.master
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [area.name] APC"
		stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

	start_processing()

/obj/machinery/power/apc/Initialize(mapload)
	. = ..()

	if(mapload)
		has_electronics = APC_ELECTRONICS_SECURED

		//Is starting with a power cell installed, create it and set its charge level
		if(cell_type)
			cell = new cell_type(src)
			cell.charge = start_charge * cell.maxcharge / 100.0 //Convert percentage to actual value

		var/area/A = get_area(src)

		//If area isn't specified use current
		if(isarea(A) && areastring == null)
			area = A
			name = "\improper [area.name] APC"
		else
			area = get_area_name(areastring)
			name = "\improper [area.name] APC"

		update_icon()
		make_terminal()

		update() //areas should be lit on startup

		//Break few ACPs on the colony
		if(!start_charge && z == 1 && prob(10))
			addtimer(CALLBACK(src, .proc/set_broken), 5)


// the very fact that i have to override this screams to me that apcs shouldnt be under machinery - spookydonut
/obj/machinery/power/apc/power_change()
	return

/obj/machinery/power/apc/proc/make_terminal()
	//Create a terminal object at the same position as original turf loc
	//Wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.dir = dir
	terminal.master = src

/obj/machinery/power/apc/examine(mob/user)
	to_chat(user, desc)
	if(stat & BROKEN)
		to_chat(user, "<span class='info'>It appears to be completely broken. It's hard to see what else is wrong with it.</span>")
		return

	if(opened)
		if(has_electronics && terminal)
			to_chat(user, "<span class='info'>The cover is [opened == APC_COVER_REMOVED ? "removed":"open"] and the power cell is [cell ? "installed":"missing"].</span>")
		else
			to_chat(user, "<span class='info'>It's [ !terminal ? "not" : "" ] wired up.</span>")
			to_chat(user, "<span class='info'>The electronics are[!has_electronics?"n't":""] installed.</span>")
	else
		if(stat & MAINT)
			to_chat(user, "<span class='info'>The cover is closed. Something is wrong with it, it doesn't work.</span>")
		else
			to_chat(user, "<span class='info'>The cover is closed.</span>")

	if(panel_open)
		to_chat(user, "<span class='info'>The wiring is exposed.</span>")

//Update the APC icon to show the three base states
//Also add overlays for indicator lights
/obj/machinery/power/apc/update_icon()
	var/update = check_updates()	//Returns 0 if no need to update icons.
									//1 if we need to update the icon_state
									//2 if we need to update the overlays
	if(!update)
		return

	overlays.Cut()

	if(update & 1)
		var/broken = update_state & UPSTATE_BROKE ? "-b" : ""
		var/status = update_state & UPSTATE_WIREEXP ? "-wires" : broken
		icon_state = "apc[opened][status]"

	if(update & 2)
		if(update_overlay & APC_UPOVERLAY_CELL_IN)
			overlays += "apco_cell"
		else if(update_overlay & APC_UPOVERLAY_BLUESCREEN)
			overlays += image(icon, "apco_emag")
		else
			overlays += image(icon, "apcox-[locked]")
			overlays += image(icon, "apco3-[charging]")
			if(update_overlay & APC_UPOVERLAY_OPERATING)
				overlays += image(icon, "apco0-[equipment]")
				overlays += image(icon, "apco1-[lighting]")
				overlays += image(icon, "apco2-[environ]")

/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0


	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened == APC_COVER_OPENED)
			update_state |= UPSTATE_OPENED1
		if(opened == APC_COVER_REMOVED)
			update_state |= UPSTATE_OPENED2
	if(panel_open)
		update_state |= UPSTATE_WIREEXP
	if(!update_state)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(emagged)
			update_overlay |= APC_UPOVERLAY_BLUESCREEN
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == APC_CHARGING)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == APC_FULLY_CHARGED)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ == 1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ == 2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2
	else if(opened && !(stat & (UPSTATE_MAINT)) && cell)
		if((opened == APC_COVER_OPENED && !(stat & BROKEN)) || opened == APC_COVER_REMOVED)
			update_overlay |= APC_UPOVERLAY_CELL_IN

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay && update_overlay)
		results += 2
	return results

/obj/machinery/power/apc/proc/queue_icon_update()
	updating_icon = TRUE

/obj/machinery/power/apc/attack_alien(mob/living/carbon/Xenomorph/M)
	M.animation_attack_on(src)
	M.visible_message("<span class='danger'>[M] slashes \the [src]!</span>", \
	"<span class='danger'>You slash \the [src]!</span>", null, 5)
	playsound(loc, "alien_claw_metal", 25, 1)
	var/allcut = TRUE
	for(var/wire in apcwirelist)
		if(!isWireCut(apcwirelist[wire]))
			allcut = FALSE
			break

	if(beenhit >= pick(3, 4) && !panel_open)
		panel_open = TRUE
		update_icon()
		visible_message("<span class='danger'>\The [src]'s cover swings open, exposing the wires!</span>", null, null, 5)

	else if(panel_open && !allcut)
		for(var/wire in apcwirelist)
			cut(apcwirelist[wire])
		update_icon()
		visible_message("<span class='danger'>\The [src]'s wires snap apart in a rain of sparks!", null, null, 5)
	else
		beenhit += 1

//Attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/attackby(obj/item/W, mob/user)

	if(issilicon(user) && get_dist(src, user) > 1)
		return attack_hand(user)
	add_fingerprint(user)
	if(iscrowbar(W) && opened)
		if(has_electronics == APC_ELECTRONICS_INSTALLED)
			if(user.action_busy) return
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to deconstruct [src].</span>",
				"<span class='notice'>You fumble around figuring out how to deconstruct [src].</span>")
				var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
			if(terminal)
				to_chat(user, "<span class='warning'>Disconnect the terminal first.</span>")
				return
			playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts removing [src]'s power control board.</span>",
			"<span class='notice'>You start removing [src]'s power control board.</span>")
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD) && has_electronics == APC_ELECTRONICS_INSTALLED)
				has_electronics = APC_ELECTRONICS_MISSING
				if((stat & BROKEN))
					user.visible_message("<span class='notice'>[user] breaks [src]'s charred power control board and removes the remains.</span>",
					"<span class='notice'>You break [src]'s charred power control board and remove the remains.</span>")
				else
					user.visible_message("<span class='notice'>[user] removes [src]'s power control board.</span>",
					"<span class='notice'>You remove [src]'s power control board.</span>")
					var/obj/item/circuitboard/apc/circuit
					if(!electronics)
						circuit = new/obj/item/circuitboard/apc( src.loc )
					else
						circuit = new electronics( src.loc )
						if(electronics.is_general_board)
							circuit.set_general()
				electronics = null
		else if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			update_icon()
	else if(iscrowbar(W) && !((stat & BROKEN)))
		if(coverlocked && !(stat & MAINT))
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened.</span>")
			return
		else
			opened = APC_COVER_OPENED
			update_icon()
	else if(istype(W, /obj/item/cell) && opened) //Trying to put a cell inside
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out how to fit [W] into [src].</span>",
			"<span class='notice'>You fumble around figuring out how to fit [W] into [src].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		if(cell)
			to_chat(user, "<span class='warning'>There is a power cell already installed.</span>")
			return
		else
			if(stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell.</span>")
				return
			if(user.transferItemToLoc(W, src))
				cell = W
				user.visible_message("<span class='notice'>[user] inserts [W] into [src]!",
				"<span class='notice'>You insert [W] into [src]!")
				chargecount = 0
				update_icon()
	else if(isscrewdriver(W)) //Haxing
		if(opened)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s confusing wiring.</span>",
				"<span class='notice'>You fumble around figuring out [src]'s confusing wiring.</span>")
				var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
			if(cell)
				to_chat(user, "<span class='warning'>Close the APC first.</span>")
				return
			else
				if(has_electronics == APC_ELECTRONICS_INSTALLED && terminal)
					has_electronics = APC_ELECTRONICS_SECURED
					stat &= ~MAINT
					playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] screws [src]'s circuit electronics into place.</span>",
					"<span class='notice'>You screw [src]'s circuit electronics into place.</span>")
				else if(has_electronics == APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					stat |= MAINT
					playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] unfastens [src]'s circuit electronics.</span>",
					"<span class='notice'>You unfasten [src]'s circuit electronics.</span>")
				else
					to_chat(user, "<span class='warning'>There is nothing to secure.</span>")
					return
				update_icon()
		else if(emagged)
			to_chat(user, "<span class='warning'>The interface is broken.</span>")
		else
			panel_open = !panel_open
			user.visible_message("<span class='notice'>[user] [panel_open ? "exposes" : "unexposes"] [src]'s wiring.</span>",
			"<span class='notice'>You [panel_open ? "expose" : "unexpose"] [src]'s wiring.</span>")
			update_icon()

	else if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda)) //Trying to unlock the interface with an ID card
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out where to swipe [W] on [src].</span>",
			"<span class='notice'>You fumble around figuring out where to swipe [W] on [src].</span>")
			var/fumbling_time = 30 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		if(emagged)
			to_chat(user, "<span class='warning'>The interface is broken.</span>")
		else if(opened)
			to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card.</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>You must close the panel.</span>")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "<span class='warning'>Nothing happens.</span>")
		else
			if(allowed(usr))
				locked = !locked
				user.visible_message("<span class='notice'>[user] [locked ? "locks" : "unlocks"] [src]'s interface.</span>",
				"<span class='notice'>You [locked ? "lock" : "unlock"] [src]'s interface.</span>")
				update_icon()
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else if(istype(W, /obj/item/card/emag) && !(emagged)) // trying to unlock with an emag card
		if(opened)
			to_chat(user, "<span class='warning'>You must close the cover to swipe an ID card.</span>")
		else if(panel_open)
			to_chat(user, "<span class='warning'>You must close the panel first</span>")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "<span class='warning'>Nothing happens.</span>")
		else
			flick("apc-spark", src)
			if(do_after(user, 6, TRUE, 5, BUSY_ICON_HOSTILE))
				if(prob(50))
					emagged = TRUE
					locked = FALSE
					to_chat(user, "<span class='warning'>You emag [src]'s interface.</span>")
					update_icon()
				else
					to_chat(user, "<span class='warning'>You fail to [ locked ? "unlock" : "lock"] [src]'s interface.</span>")
	else if(iscablecoil(W) && !terminal && opened && has_electronics != APC_ELECTRONICS_SECURED)
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [src].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [src].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		if(loc:intact_tile)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first.</span>")
			return
		var/obj/item/stack/cable_coil/C = W
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts wiring [src]'s frame.</span>",
		"<span class='notice'>You start wiring [src]'s frame.</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
		if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD) && !terminal && opened && has_electronics != APC_ELECTRONICS_SECURED)
			var/turf/T = get_turf(src)
			var/obj/structure/cable/N = T.get_cable_node()
			if(prob(50) && electrocute_mob(usr, N, N))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			if(C.use(10))
				user.visible_message("<span class='notice'>[user] wires [src]'s frame.</span>",
				"<span class='notice'>You wire [src]'s frame.</span>")
				make_terminal()
				terminal.connect_to_network()
	else if(iswirecutter(W) && terminal && opened && has_electronics != APC_ELECTRONICS_SECURED)
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [W].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [W].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		if(loc:intact_tile)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts removing [src]'s wiring and terminal.</span>",
		"<span class='notice'>You start removing [src]'s wiring and terminal.</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
		if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
			if (prob(50) && electrocute_mob(user, terminal.powernet, terminal))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return
			new /obj/item/stack/cable_coil(loc,10)
			user.visible_message("<span class='notice'>[user] removes [src]'s wiring and terminal.</span>",
			"<span class='notice'>You remove [src]'s wiring and terminal.</span>")
			qdel(terminal)
			terminal = null
	else if(istype(W, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && !(stat & BROKEN))
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [W].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [W].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		user.visible_message("<span class='notice'>[user] starts inserting the power control board into [src].</span>",
		"<span class='notice'>You start inserting the power control board into [src].</span>")
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)
		if(do_after(user, 15, TRUE, 5, BUSY_ICON_BUILD))
			has_electronics = APC_ELECTRONICS_INSTALLED
			user.visible_message("<span class='notice'>[user] inserts the power control board into [src].</span>",
			"<span class='notice'>You insert the power control board into [src].</span>")
			electronics = W
			qdel(W)
	else if(istype(W, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && (stat & BROKEN))
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [W].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [W].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged.</span>")
		return
	else if(iswelder(W) && opened && has_electronics == APC_ELECTRONICS_MISSING && !terminal)
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [W].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [W].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		var/obj/item/tool/weldingtool/WT = W
		if(WT.get_fuel() < 3)
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts unwelding [src]'s frame.</span>",
		"<span class='notice'>You start unwelding [src]'s frame.</span>")
		playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
		if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
			if(!src || !WT.remove_fuel(3, user)) return
			if(emagged || (stat & BROKEN) || opened == APC_COVER_REMOVED)
				new /obj/item/stack/sheet/metal(loc)
				user.visible_message("<span class='notice'>[user] unwelds [src]'s frame apart.</span>",
				"<span class='notice'>You unweld [src]'s frame apart.</span>")
			else
				new /obj/item/frame/apc(loc)
				user.visible_message("<span class='notice'>[user] unwelds [src]'s frame off the wall.</span>",
				"<span class='notice'>You unweld [src]'s frame off the wall.</span>")
			qdel(src)
			return
	else if(istype(W, /obj/item/frame/apc) && opened && emagged)
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [W].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [W].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		emagged = FALSE
		if(opened == APC_COVER_REMOVED)
			opened = APC_COVER_OPENED
		user.visible_message("<span class='notice'>[user] replaces [src]'s damaged frontal panel with a new one.</span>",
		"<span class='notice'>You replace [src]'s damaged frontal panel with a new one.</span>")
		qdel(W)
		update_icon()
	else if(istype(W, /obj/item/frame/apc) && opened && (stat & BROKEN))
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
			user.visible_message("<span class='notice'>[user] fumbles around figuring out what to do with [W].</span>",
			"<span class='notice'>You fumble around figuring out what to do with [W].</span>")
			var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
		if(has_electronics)
			to_chat(user, "<span class='warning'>You cannot repair this APC until you remove the electronics still inside.</span>")
			return
		user.visible_message("<span class='notice'>[user] begins replacing [src]'s damaged frontal panel with a new one.</span>",
		"<span class='notice'>You begin replacing [src]'s damaged frontal panel with a new one.</span>")
		if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] replaces [src]'s damaged frontal panel with a new one.</span>",
			"<span class='notice'>You replace [src]'s damaged frontal panel with a new one.</span>")
			qdel(W)
			stat &= ~BROKEN
			if(opened == APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_icon()
	else
		if(((stat & BROKEN)) && !opened && W.force >= 5)
			opened = APC_COVER_REMOVED
			user.visible_message("<span class='warning'>[user] knocks down [src]'s cover with [W]!</span>", \
				"<span class='warning'>You knock down [src]'s cover with [W]!</span>")
			update_icon()
		else
			if(issilicon(user))
				return attack_hand(user)
			if(!opened && panel_open && (ismultitool(W) || iswirecutter(W)))
				return attack_hand(user)
			user.visible_message("<span class='danger'>[user] hits [src] with [W]!</span>", \
			"<span class='danger'>You hit [src] with [W]!</span>")

//Attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/user)

	if(!user)
		return

	add_fingerprint(user)

	//Human mob special interaction goes here.
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(H.species.flags & IS_SYNTHETIC && H.a_intent == INTENT_GRAB)
			if(emagged || stat & BROKEN)
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(3, 1, src)
				s.start()
				to_chat(H, "<span class='danger'>The APC's power currents surge eratically, damaging your chassis!</span>")
				H.adjustFireLoss(10,0)
			else if(cell && cell.charge > 0)
				if(H.nutrition < 450)
					if(cell.charge >= 500)
						H.nutrition += 50
						cell.charge -= 500
					else
						H.nutrition += cell.charge/10
						cell.charge = 0

					to_chat(user, "<span class='notice'>You slot your fingers into the APC interface and siphon off some of the stored charge for your own use.</span>")
					if(cell.charge < 0) cell.charge = 0
					if(H.nutrition > 500) H.nutrition = 500
					charging = APC_CHARGING

				else
					to_chat(user, "<span class='warning'>You are already fully charged.</span>")
			else
				to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")
			return
		else if(H.species.can_shred(H))
			user.visible_message("<span class='warning'>[user.name] slashes [src]!</span>",
			"<span class='warning'>You slash [src]!</span>")
			playsound(src.loc, 'sound/weapons/slash.ogg', 25, 1)
			var/allcut = 1
			for(var/wire in apcwirelist)
				if(!isWireCut(apcwirelist[wire]))
					allcut = 0
					break
			if(beenhit >= pick(3, 4) && !panel_open)
				panel_open = TRUE
				update_icon()
				visible_message("<span class='warning'>[src]'s cover flies open, exposing the wires!</span>")

			else if(panel_open && allcut == 0)
				for(var/wire in apcwirelist)
					cut(apcwirelist[wire])
				update_icon()
				visible_message("<span class='warning'>[src]'s wires are shredded!</span>")
			else
				beenhit += 1
			return


	if(usr == user && opened && (!issilicon(user)))
		if(cell)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out how to remove the power cell from [src].</span>",
				"<span class='notice'>You fumble around figuring out how to remove the power cell from [src].</span>")
				var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - user.mind.cm_skills.engineer )
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()

			src.cell = null
			user.visible_message("<span class='notice'>[user] removes the power cell from [src]!</span>",
			"<span class='notice'>You remove the power cell from [src].</span>")
			charging = APC_NOT_CHARGING
			update_icon()
		return
	if(stat & (BROKEN|MAINT))
		return

	interact(user)

/obj/machinery/power/apc/interact(mob/user)
	if(!user)
		return
	user.set_interaction(src)
	if(panel_open /*&& !issiicon(user)*/) //Commented out the typecheck to allow engiborgs to repair damaged apcs.
		var/t1 = text("<html><head><title>[area.name] APC wires</title></head><body><B>Access Panel</B><br>\n")

		for(var/wiredesc in apcwirelist)
			var/is_uncut = src.apcwires & APCWireColorToFlag[apcwirelist[wiredesc]]
			t1 += "[wiredesc] wire: "
			if(!is_uncut)
				t1 += "<a href='?src=\ref[src];apcwires=[apcwirelist[wiredesc]]'>Mend</a>"
			else
				t1 += "<a href='?src=\ref[src];apcwires=[apcwirelist[wiredesc]]'>Cut</a> "
				t1 += "<a href='?src=\ref[src];pulse=[apcwirelist[wiredesc]]'>Pulse</a> "
			t1 += "<br>"
		t1 += text("<br>\n[(src.locked ? "The APC is locked." : "The APC is unlocked.")]<br>\n[(shorted ? "The APC's power has been shorted." : "The APC is working properly!")]<br>\n[(src.aidisabled ? "The 'AI control allowed' light is off." : "The 'AI control allowed' light is on.")]")
		t1 += text("<p><a href='?src=\ref[src];close2=1'>Close</a></p></body></html>")
		user << browse(t1, "window=apcwires")
		onclose(user, "apcwires")

	//Open the APC NanoUI
	ui_interact(user)
	return

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)
	if(!user)
		return

	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = round(lastused_equip + lastused_light + lastused_environ),
		"coverLocked" = coverlocked,
		"siliconUser" = issilicon(user),

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = round(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = round(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = round(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)

	//Update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		//The ui does not exist, so we'll create a new() one
        //For a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "apc.tmpl", "[area.name] - APC", 520, data["siliconUser"] ? 465 : 440)
		//When the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		//Open the new ui window
		ui.open()
		//Auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
	area.power_change()

/obj/machinery/power/apc/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	apcwires &= ~wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			shock(usr, 50)
			shorted = TRUE
			updateDialog()
		if(APC_WIRE_MAIN_POWER2)
			shock(usr, 50)
			shorted = TRUE
			updateDialog()
		if(APC_WIRE_AI_CONTROL)
			if(!aidisabled)
				aidisabled = TRUE
			updateDialog()
	if(isxeno(usr)) //So aliens don't see this when they cut all of the wires.
		return
	interact(usr)
	updateUsrDialog()

/obj/machinery/power/apc/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //Not used in this function
	apcwires |= wireFlag
	switch(wireIndex)
		if(APC_WIRE_MAIN_POWER1)
			if((!isWireCut(APC_WIRE_MAIN_POWER1)) && (!isWireCut(APC_WIRE_MAIN_POWER2)))
				shorted = FALSE
				shock(usr, 50)
				updateDialog()
		if(APC_WIRE_MAIN_POWER2)
			if((!isWireCut(APC_WIRE_MAIN_POWER1)) && (!isWireCut(APC_WIRE_MAIN_POWER2)))
				shorted = FALSE
				shock(usr, 50)
				updateDialog()
		if(APC_WIRE_AI_CONTROL)
			//One wire for AI control. Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
			//aidisabledDisabled: If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
			if(aidisabled)
				aidisabled = FALSE
			updateUsrDialog()
	updateUsrDialog()
	interact(usr)

/obj/machinery/power/apc/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(APC_WIRE_IDSCAN) //Unlocks the APC for 30 seconds, if you have a better way to hack an APC I'm all ears
			locked = FALSE
			addtimer(CALLBACK(src, .proc/reset, wireIndex), 300)
		if(APC_WIRE_MAIN_POWER1)
			shorted = TRUE
			addtimer(CALLBACK(src, .proc/reset, wireIndex), 1200)
		if(APC_WIRE_MAIN_POWER2)
			shorted = TRUE
			addtimer(CALLBACK(src, .proc/reset, wireIndex), 1200)
		if(APC_WIRE_AI_CONTROL)
			aidisabled = TRUE
			updateDialog()
			addtimer(CALLBACK(src, .proc/reset, wireIndex), 10)

/obj/machinery/power/apc/proc/reset(var/wire)
	switch(wire)
		if(APC_WIRE_IDSCAN)
			locked = TRUE
		if(APC_WIRE_MAIN_POWER1)
			shorted = FALSE
		if(APC_WIRE_MAIN_POWER2)
			shorted = FALSE
		if(APC_WIRE_AI_CONTROL)
			aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = 3
			environ = 3
	updateDialog()

/obj/machinery/power/apc/proc/can_use(mob/user as mob, var/loud = 0) //used by attack_hand() and Topic()
	if(user.stat)
		to_chat(user, "<span class='warning'>You must be conscious to use [src]!</span>")
		return 0
	if(!user.client)
		return 0
	if(!(ishuman(user) || issilicon(user) || ismonkey(user)))
		to_chat(user, "<span class='warning'>You don't have the dexterity to use [src]!</span>")
		nanomanager.close_user_uis(user, src)
		return 0
	if(user.is_mob_restrained())
		to_chat(user, "<span class='warning'>You must have free hands to use [src].</span>")
		return 0
	if(user.lying)
		to_chat(user, "<span class='warning'>You can't reach [src]!</span>")
		return 0
	autoflag = 5
	if(issilicon(user))
		if(aidisabled)
			if(!loud)
				to_chat(user, "<span class='warning'>[src] has AI control disabled!</span>")
				nanomanager.close_user_uis(user, src)
			return 0
	else
		if((!in_range(src, user) || !istype(src.loc, /turf)))
			nanomanager.close_user_uis(user, src)
			return 0

	var/mob/living/carbon/human/H = user
	if(istype(H))
		if(H.getBrainLoss() >= 60)
			for(var/mob/M in viewers(src, null))
				H.visible_message("<span class='warning'>[H] stares cluelessly at [src] and drools.</span>",
				"<span class='warning'>You stare cluelessly at [src] and drool.</span>")
			return 0
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return 0
	return 1

/obj/machinery/power/apc/Topic(href, href_list, var/usingUI = 1)
	if(!(iscyborg(usr) && (href_list["apcwires"] || href_list["pulse"])))
		if(!can_use(usr, 1))
			return 0
	add_fingerprint(usr)
	if(ishuman(usr) && usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
		usr.visible_message("<span class='notice'>[usr] fumbles around figuring out how to use [src]'s interface.</span>",
		"<span class='notice'>You fumble around figuring out how to use [src]'s interface.</span>")
		var/fumbling_time = 50 * ( SKILL_ENGINEER_ENGI - usr.mind.cm_skills.engineer )
		if(!do_after(usr, fumbling_time, TRUE, 5, BUSY_ICON_BUILD)) return

	if(href_list["apcwires"])
		var/t1 = text2num(href_list["apcwires"])
		if(!iswirecutter(usr.get_active_held_item()))
			to_chat(usr, "<span class='warning'>You need wirecutters!</span>")
			return 0
		if(isWireColorCut(t1))
			mend(t1)
		else
			cut(t1)
	else if(href_list["pulse"])
		var/t1 = text2num(href_list["pulse"])
		if(!ismultitool(usr.get_active_held_item()))
			to_chat(usr, "<span class='warning'>You need a multitool!</span>")
			return 0
		if(isWireColorCut(t1))
			to_chat(usr, "<span class='warning'>You can't pulse a cut wire.</span>")
			return 0
		else
			pulse(t1)
	else if(href_list["lock"])
		coverlocked = !coverlocked

	else if(href_list["breaker"])
		operating = !operating
		update()
		update_icon()

	else if(href_list["cmode"])
		chargemode = !chargemode
		if(!chargemode)
			charging = APC_NOT_CHARGING
			update_icon()

	else if(href_list["eqp"])
		var/val = text2num(href_list["eqp"])
		equipment = (val == 1) ? 0 : val
		update_icon()
		update()

	else if (href_list["lgt"])
		var/val = text2num(href_list["lgt"])
		lighting = (val == 1) ? 0 : val
		update_icon()
		update()

	else if (href_list["env"])
		var/val = text2num(href_list["env"])
		environ = (val == 1) ? 0 :val
		update_icon()
		update()

	else if( href_list["close"] )
		nanomanager.close_user_uis(usr, src)
		return 0

	else if (href_list["close2"])
		usr << browse(null, "window=apcwires")
		return 0

	else if(href_list["overload"])
		if(issilicon(usr) && !aidisabled)
			overload_lighting()

	if(usingUI)
		updateDialog()

	return 1

/obj/machinery/power/apc/proc/ion_act()
	//intended to be a bit like an emag
	if(!emagged)
		if(prob(3))
			locked = FALSE
			if(cell.charge > 0)
				cell.charge = 0
				cell.corrupt()
				emagged = TRUE
				update_icon()
				var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread()
				smoke.set_up(1, 0, loc)
				smoke.attach(src)
				smoke.start()
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(1, 1, src)
				s.start()
				visible_message("<span class='warning'>[src] suddenly lets out a blast of smoke and some sparks!")

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/proc/last_surplus()
	if(terminal && terminal.powernet)
		return terminal.powernet.last_surplus()
	else
		return 0

//Returns 1 if the APC should attempt to charge
/obj/machinery/power/apc/proc/attempt_charging()
	return (chargemode && charging == APC_CHARGING && operating)

/obj/machinery/power/apc/add_load(var/amount)
	if(terminal && terminal.powernet)
		return terminal.powernet.draw_power(amount)
	return 0

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(updating_icon)
		update_icon()
	if(stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return

	lastused_light = area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()
	var/power_excess = 0

	var/perapc = 0
	if(terminal && terminal.powernet)
		perapc = terminal.powernet.perapc

	if(debug)
		log_runtime( "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light]")

		if(area.powerupdate)
			log_runtime("power update in [area.name] / [name]")

	if(cell && !shorted)
		var/cell_maxcharge = cell.maxcharge

		//Calculate how much power the APC will try to get from the grid.
		var/target_draw = lastused_total
		if(attempt_charging())
			target_draw += min((cell_maxcharge - cell.charge), (cell_maxcharge * CHARGELEVEL))/CELLRATE
		target_draw = min(target_draw, perapc) //Limit power draw by perapc

		//Try to draw power from the grid
		var/power_drawn = 0
		if(avail())
			power_drawn = add_load(target_draw) //Get some power from the powernet

		//Figure out how much power is left over after meeting demand
		power_excess = power_drawn - lastused_total

		if(power_excess < 0) //Couldn't get enough power from the grid, we will need to take from the power cell.

			charging = APC_NOT_CHARGING

			var/required_power = -power_excess
			if(cell.charge >= required_power * CELLRATE) //Can we draw enough from cell to cover what's left over?
				cell.use(required_power * CELLRATE)

			else if (autoflag != 0)	//Not enough power available to run the last tick!
				chargecount = 0
				//This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				autoflag = 0

		//Set external power status
		if(!power_drawn)
			main_status = 0
		else if(power_excess < 0)
			main_status = 1
		else
			main_status = 2

		//Set channels depending on how much charge we have left
		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2


		if(cell.charge >= 1250 || longtermpower > 0) //Put most likely at the top so we don't check it last, effeciency 101
			if(autoflag != 3)
				equipment = autoset(equipment, 1)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				autoflag = 3
				area.poweralert(1, src)
				if(cell.charge >= 4000)
					area.poweralert(1, src)
		else if(cell.charge < 1250 && cell.charge > 750 && longtermpower < 0) //<30%, turn off equipment
			if(autoflag != 2)
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 1)
				environ = autoset(environ, 1)
				area.poweralert(0, src)
				autoflag = 2
		else if(cell.charge < 750 && cell.charge > 10) //<15%, turn off lighting & equipment
			if((autoflag > 1 && longtermpower < 0) || (autoflag > 1 && longtermpower >= 0))
				equipment = autoset(equipment, 2)
				lighting = autoset(lighting, 2)
				environ = autoset(environ, 1)
				area.poweralert(0, src)
				autoflag = 1
		else if(cell.charge <= 0) //Zero charge, turn all off
			if(autoflag != 0)
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)
				area.poweralert(0, src)
				autoflag = 0

		//Now trickle-charge the cell
		if(attempt_charging())
			if(power_excess > 0) //Check to make sure we have enough to charge
				cell.give(power_excess * CELLRATE) //Actually recharge the cell
			else
				charging = APC_NOT_CHARGING //Stop charging
				chargecount = 0

		//Show cell as fully charged if so
		if(cell.charge >= cell_maxcharge)
			charging = APC_FULLY_CHARGED

		//If we have excess power for long enough, think about re-enable charging.
		if(chargemode)
			if(!charging)
				//last_surplus() overestimates the amount of power available for charging, but it's equivalent to what APCs were doing before.
				if(last_surplus() * CELLRATE >= cell_maxcharge * CHARGELEVEL)
					chargecount++
				else
					chargecount = 0
					charging = APC_NOT_CHARGING

				if(chargecount >= 10)
					chargecount = 0
					charging = APC_CHARGING

		else //Chargemode off
			charging = APC_NOT_CHARGING
			chargecount = 0

	else //No cell, switch everything off
		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)
		autoflag = 0

	//Update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()
	updateDialog()

//val 0 = off, 1 = off(auto) 2 = on, 3 = on(auto)
//on 0 = off, 1 = auto-on, 2 = auto-off

/proc/autoset(var/val, var/on)

	if(on == 0) //Turn things off
		if(val == 2) //If on, return off
			return 0
		else if(val == 3) //If auto-on, return auto-off
			return 1

	else if(on == 1) //Turn things auto-on
		if(val == 1) //If auto-off, return auto-on
			return 3

	else if(on == 2) //Turn things auto-off
		if(val == 3) //If auto-on, return auto-off
			return 1
	return val

//Damage and destruction acts
/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	addtimer(CALLBACK(src, .proc/reset, APC_RESET_EMP), 60 SECONDS)
	..()

/obj/machinery/power/apc/ex_act(severity)

	switch(severity)
		if(1)
			if(cell)
				cell.ex_act(1) //More lags woohoo
			qdel(src)
			return
		if(2)
			if(prob(50))
				set_broken()
				if(cell && prob(50))
					cell.ex_act(2)
		if(3.0)
			if(prob(25))
				set_broken()
				if(cell && prob(25))
					cell.ex_act(3)

/obj/machinery/power/apc/proc/set_broken()

	//Aesthetically much better!
	visible_message("<span class='warning'>[src]'s screen flickers with warnings briefly!</span>")
	addtimer(CALLBACK(src, .proc/do_break), rand(2, 5))

/obj/machinery/power/apc/proc/do_break()
	visible_message("<span class='danger'>[src]'s screen suddenly explodes in rain of sparks and small debris!</span>")
	stat |= BROKEN
	operating = FALSE
	update_icon()
	update()

//Overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting()
	if(!operating || shorted)
		return
	if(cell && cell.charge >= 20)
		cell.use(20)
		INVOKE_ASYNC(src, .proc/break_lights)

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/L in area.related)
		L.on = TRUE
		L.broken()
		L.on = FALSE
		stoplag()

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()

	if(cell)
		qdel(cell)
	if(terminal)
		disconnect_terminal()

	. = ..()

/obj/machinery/power/apc/proc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

//------Various APCs ------//


/obj/machinery/power/apc/north
	dir = NORTH

/obj/machinery/power/apc/east
	dir = EAST

/obj/machinery/power/apc/west
	dir = WEST

/obj/machinery/power/apc/lowcharge
	start_charge = 25

/obj/machinery/power/apc/lowcharge/north
	dir = NORTH

/obj/machinery/power/apc/lowcharge/east
	dir = EAST

/obj/machinery/power/apc/lowcharge/west
	dir = WEST

/obj/machinery/power/apc/nocharge
	start_charge = 0

/obj/machinery/power/apc/nocharge/north
	dir = NORTH

/obj/machinery/power/apc/nocharge/east
	dir = EAST

/obj/machinery/power/apc/nocharge/west
	dir = WEST

/obj/machinery/power/apc/potato
	cell_type = /obj/item/cell/potato

/obj/machinery/power/apc/potato/north
	dir = NORTH

/obj/machinery/power/apc/potato/east
	dir = EAST

/obj/machinery/power/apc/potato/west
	dir = WEST

/obj/machinery/power/apc/weak
	cell_type = /obj/item/cell

/obj/machinery/power/apc/weak/north
	dir = NORTH

/obj/machinery/power/apc/weak/east
	dir = EAST

/obj/machinery/power/apc/weak/west
	dir = WEST

/obj/machinery/power/apc/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/high/north
	dir = NORTH

/obj/machinery/power/apc/high/east
	dir = EAST

/obj/machinery/power/apc/high/west
	dir = WEST

/obj/machinery/power/apc/super
	cell_type = /obj/item/cell/super

/obj/machinery/power/apc/super/north
	dir = NORTH

/obj/machinery/power/apc/super/east
	dir = EAST

/obj/machinery/power/apc/super/west
	dir = WEST

/obj/machinery/power/apc/hyper
	cell_type = /obj/item/cell/hyper

/obj/machinery/power/apc/hyper/north
	dir = NORTH

/obj/machinery/power/apc/hyper/east
	dir = EAST

/obj/machinery/power/apc/hyper/west
	dir = WEST

//------Theseus APCs ------//

/obj/machinery/power/apc/almayer
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/almayer/north
	dir = NORTH

/obj/machinery/power/apc/almayer/east
	dir = EAST

/obj/machinery/power/apc/almayer/west
	dir = WEST

/obj/machinery/power/apc/almayer/hardened
	name = "hardened area power controller"
	desc = "A control terminal for the area electrical systems. This one is hardened against sudden power fluctuations caused by electrical grid damage."
	crash_break_probability = 0

/obj/machinery/power/apc/almayer/hardened/north
	dir = NORTH

/obj/machinery/power/apc/almayer/hardened/east
	dir = EAST

/obj/machinery/power/apc/almayer/hardened/west
	dir = WEST

#undef APC_WIRE_IDSCAN
#undef APC_WIRE_MAIN_POWER1
#undef APC_WIRE_MAIN_POWER2
#undef APC_WIRE_AI_CONTROL

#undef APC_RESET_EMP

#undef APC_UPDATE_ICON_COOLDOWN
#undef UPSTATE_OPENED1
#undef UPSTATE_OPENED2
#undef UPSTATE_MAINT
#undef UPSTATE_BROKE
#undef UPSTATE_WIREEXP
#undef UPSTATE_ALLGOOD

#undef APC_UPOVERLAY_CHARGEING0
#undef APC_UPOVERLAY_CHARGEING1
#undef APC_UPOVERLAY_CHARGEING2
#undef APC_UPOVERLAY_EQUIPMENT0
#undef APC_UPOVERLAY_EQUIPMENT1
#undef APC_UPOVERLAY_EQUIPMENT2
#undef APC_UPOVERLAY_LIGHTING0
#undef APC_UPOVERLAY_LIGHTING1
#undef APC_UPOVERLAY_LIGHTING2
#undef APC_UPOVERLAY_ENVIRON0
#undef APC_UPOVERLAY_ENVIRON1
#undef APC_UPOVERLAY_ENVIRON2
#undef APC_UPOVERLAY_LOCKED
#undef APC_UPOVERLAY_OPERATING
#undef APC_UPOVERLAY_CELL_IN
#undef APC_UPOVERLAY_BLUESCREEN

#undef APC_ELECTRONICS_MISSING
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED
