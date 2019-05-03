#define APC_RESET_EMP 5

#define APC_ELECTRONICS_MISSING   0
#define APC_ELECTRONICS_INSTALLED 1
#define APC_ELECTRONICS_SECURED   2

#define APC_COVER_CLOSED  0
#define APC_COVER_OPENED  1
#define APC_COVER_REMOVED 2

#define APC_NOT_CHARGING  0
#define APC_CHARGING      1
#define APC_FULLY_CHARGED 2

#define APC_EXTERNAL_POWER_NONE 0
#define APC_EXTERNAL_POWER_LOW  1
#define APC_EXTERNAL_POWER_GOOD 2

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
	pixel_x = -16
	pixel_y = -16
	anchored = TRUE
	use_power = NO_POWER_USE
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	resistance_flags = UNACIDABLE
	var/area/area
	var/areastring = null
	var/obj/item/cell/cell
	var/start_charge = 90 //Initial cell charge %
	var/cell_type = /obj/item/cell/apc
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
	var/main_status = APC_EXTERNAL_POWER_NONE
	var/apcwires = 15
	var/debug = 0
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
		var/valid = FALSE
		while(!valid)
			var/colorIndex = rand(1, 4)
			if(apcwires[colorIndex] == 0)
				valid = TRUE
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
	if(machine_stat & (BROKEN|MAINT))
		return
	..()

/obj/machinery/power/apc/New()
	. = ..()
	GLOB.apcs_list += src

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()

	QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()

	. = ..()

/obj/machinery/power/apc/Initialize(mapload, ndir, building = FALSE)
	// offset 32 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (ndir)
		setDir(ndir)

	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32

	if(building)
		var/area/A = get_area(src)
		area = A.master
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [area.name] APC"
		machine_stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, .proc/update), 5)

	start_processing()

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
		if(!start_charge && is_ground_level(z) && prob(10))
			addtimer(CALLBACK(src, .proc/set_broken), 5)

/obj/machinery/power/apc/proc/make_terminal()
	//Create a terminal object at the same position as original turf loc
	//Wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.setDir(dir)
	terminal.master = src

/obj/machinery/power/apc/examine(mob/user)
	. = ..()

	if(machine_stat & BROKEN)
		to_chat(user, "<span class='info'>It appears to be completely broken. It's hard to see what else is wrong with it.</span>")
		return

	if(opened)
		if(has_electronics && terminal)
			to_chat(user, "<span class='info'>The cover is [opened == APC_COVER_REMOVED ? "removed":"open"] and the power cell is [cell ? "installed":"missing"].</span>")
		else
			to_chat(user, "<span class='info'>It's [ !terminal ? "not" : "" ] wired up.</span>")
			to_chat(user, "<span class='info'>The electronics are[!has_electronics?"n't":""] installed.</span>")
	else
		if(machine_stat & MAINT)
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
		var/broken = CHECK_BITFIELD(update_state, UPSTATE_BROKE) ? "-b" : ""
		var/status = (CHECK_BITFIELD(update_state, UPSTATE_WIREEXP) && !CHECK_BITFIELD(update_state, UPSTATE_OPENED1)) ? "-wires" : broken
		icon_state = "apc[opened][status]"

	if(update & 2)
		if(CHECK_BITFIELD(update_overlay, APC_UPOVERLAY_CELL_IN))
			overlays += "apco-cell"
		else if(CHECK_BITFIELD(update_state, UPSTATE_ALLGOOD))
			if(CHECK_BITFIELD(update_overlay, APC_UPOVERLAY_BLUESCREEN))
				overlays += image(icon, "apco-emag")
			else
				overlays += image(icon, "apcox-[locked]")
				overlays += image(icon, "apco3-[charging]")
				var/operating = CHECK_BITFIELD(update_overlay, APC_UPOVERLAY_OPERATING)
				overlays += image(icon, "apco0-[operating ? equipment : 0]")
				overlays += image(icon, "apco1-[operating ? lighting : 0]")
				overlays += image(icon, "apco2-[operating ? environ : 0]")

/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(machine_stat & BROKEN)
		ENABLE_BITFIELD(update_state, UPSTATE_BROKE)
	if(machine_stat & MAINT)
		ENABLE_BITFIELD(update_state, UPSTATE_MAINT)
	if(opened)
		if(opened == APC_COVER_OPENED)
			ENABLE_BITFIELD(update_state, UPSTATE_OPENED1)
		if(opened == APC_COVER_REMOVED)
			ENABLE_BITFIELD(update_state, UPSTATE_OPENED2)
	if(panel_open)
		ENABLE_BITFIELD(update_state, UPSTATE_WIREEXP)
	if(!update_state)
		ENABLE_BITFIELD(update_state, UPSTATE_ALLGOOD)
		if(emagged)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_BLUESCREEN)
		if(locked)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LOCKED)
		if(operating)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_OPERATING)
		if(!charging)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CHARGEING0)
		else if(charging == APC_CHARGING)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CHARGEING1)
		else if(charging == APC_FULLY_CHARGED)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CHARGEING2)

		if (!equipment)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_EQUIPMENT0)
		else if(equipment == 1)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_EQUIPMENT1)
		else if(equipment == 2)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_EQUIPMENT2)

		if(!lighting)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LIGHTING0)
		else if(lighting == 1)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LIGHTING1)
		else if(lighting == 2)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LIGHTING2)

		if(!environ)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_ENVIRON0)
		else if(environ == 1)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_ENVIRON1)
		else if(environ == 2)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_ENVIRON2)
	if(opened && cell && !CHECK_BITFIELD(update_state, UPSTATE_MAINT) && ((CHECK_BITFIELD(update_state, UPSTATE_OPENED1) && !CHECK_BITFIELD(update_state, UPSTATE_BROKE)) || CHECK_BITFIELD(update_state, UPSTATE_OPENED2)))
		ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CELL_IN)

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay)
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
				if((machine_stat & BROKEN))
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
	else if(iscrowbar(W) && !((machine_stat & BROKEN)))
		if(coverlocked && !(machine_stat & MAINT))
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
			if(machine_stat & MAINT)
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
					machine_stat &= ~MAINT
					playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
					user.visible_message("<span class='notice'>[user] screws [src]'s circuit electronics into place.</span>",
					"<span class='notice'>You screw [src]'s circuit electronics into place.</span>")
				else if(has_electronics == APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					machine_stat |= MAINT
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

	else if(istype(W, /obj/item/card/id)) //Trying to unlock the interface with an ID card
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
		else if(machine_stat & (BROKEN|MAINT))
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
		else if(machine_stat & (BROKEN|MAINT))
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
		var/turf/T = get_turf(src)
		if(T.intact_tile)
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
			if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
				return
		terminal.dismantle(user)
	else if(istype(W, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && !(machine_stat & BROKEN))
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
	else if(istype(W, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && (machine_stat & BROKEN))
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
			if(emagged || (machine_stat & BROKEN) || opened == APC_COVER_REMOVED)
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
	else if(istype(W, /obj/item/frame/apc) && opened && (machine_stat & BROKEN))
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
			machine_stat &= ~BROKEN
			if(opened == APC_COVER_REMOVED)
				opened = APC_COVER_OPENED
			update_icon()
	else
		if(((machine_stat & BROKEN)) && !opened && W.force >= 5)
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
		var/datum/species/S = H.species

		if(S.species_flags & IS_SYNTHETIC && H.a_intent == INTENT_GRAB)
			if(emagged || machine_stat & BROKEN)
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
	if(machine_stat & (BROKEN|MAINT))
		return

	interact(user)

/obj/machinery/power/apc/interact(mob/user)
	if(!user)
		return
	user.set_interaction(src)
	if(panel_open /*&& !issiicon(user)*/) //Commented out the typecheck to allow engiborgs to repair damaged apcs.
		var/t1 = text("<B>Access Panel</B><br>\n")

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

		var/datum/browser/popup = new(user, "apcwires", "<div align='center'>[area.name] APC wires</div>")
		popup.set_content(t1)
		popup.open(FALSE)
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
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
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
	return ((apcwires & wireFlag) == 0)

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((apcwires & wireFlag) == 0)

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
		SSnano.close_user_uis(user, src)
		return 0
	if(user.restrained())
		to_chat(user, "<span class='warning'>You must have free hands to use [src].</span>")
		return 0
	if(user.lying)
		to_chat(user, "<span class='warning'>You can't reach [src]!</span>")
		return 0
	if(issilicon(user))
		if(aidisabled)
			if(!loud)
				to_chat(user, "<span class='warning'>[src] has AI control disabled!</span>")
				SSnano.close_user_uis(user, src)
			return 0
	else
		if((!in_range(src, user) || !istype(src.loc, /turf)))
			SSnano.close_user_uis(user, src)
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
			return FALSE
	add_fingerprint(usr)

	if(href_list["apcwires"])
		var/t1 = text2num(href_list["apcwires"])
		if(!iswirecutter(usr.get_active_held_item()))
			to_chat(usr, "<span class='warning'>You need wirecutters!</span>")
			return FALSE
		if(!skillcheck(usr))
			return FALSE
		if(isWireColorCut(t1))
			mend(t1)
		else
			cut(t1)

	else if(href_list["pulse"])
		var/t1 = text2num(href_list["pulse"])
		if(!ismultitool(usr.get_active_held_item()))
			to_chat(usr, "<span class='warning'>You need a multitool!</span>")
			return FALSE
		if(isWireColorCut(t1))
			to_chat(usr, "<span class='warning'>You can't pulse a cut wire.</span>")
			return FALSE
		if(!skillcheck(usr))
			return FALSE
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
		equipment = (val == TRUE) ? FALSE : val
		update_icon()
		update()

	else if(href_list["lgt"])
		var/val = text2num(href_list["lgt"])
		lighting = (val == TRUE) ? FALSE : val
		update_icon()
		update()

	else if(href_list["env"])
		var/val = text2num(href_list["env"])
		environ = (val == TRUE) ? FALSE :val
		update_icon()
		update()

	else if(href_list["close"])
		SSnano.close_user_uis(usr, src)
		return FALSE

	else if(href_list["close2"])
		usr << browse(null, "window=apcwires")
		return FALSE

	else if(href_list["overload"])
		if(issilicon(usr) && !aidisabled)
			overload_lighting()

	if(usingUI)
		updateDialog()

	return TRUE


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
				var/datum/effect_system/smoke_spread/smoke = new(src)
				smoke.set_up(1, loc)
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

//Returns 1 if the APC should attempt to charge
/obj/machinery/power/apc/proc/attempt_charging()
	return (chargemode && charging == APC_CHARGING && operating)

/obj/machinery/power/apc/add_load(var/amount)
	if(terminal && terminal.powernet)
		return terminal.add_load(amount)
	return 0

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()
	if(updating_icon)
		update_icon()
	if(machine_stat & (BROKEN|MAINT))
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

	if(!avail())
		main_status = APC_EXTERNAL_POWER_NONE
	else if(excess < 0)
		main_status = APC_EXTERNAL_POWER_LOW
	else
		main_status = APC_EXTERNAL_POWER_GOOD

	if(GLOB.Debug2)
		log_runtime( "Status: [main_status] - Excess: [excess] - Last Equip: [lastused_equip] - Last Light: [lastused_light]")

		if(area.powerupdate)
			log_runtime("power update in [area.name] / [name]")

	if(cell && !shorted)
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)
			cell.give(cellused)
			add_load(cellused/GLOB.CELLRATE)
		else		// not enough excess, and not enough per-apc
			if((cell.charge/GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				//This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)

		//Set channels depending on how much charge we have left
		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 30 && longtermpower < 0)			// <30%, turn off equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		//Now trickle-charge the cell
		if(attempt_charging())
			if(excess  > 0) //Check to make sure we have enough to charge
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell
			else
				charging = APC_NOT_CHARGING //Stop charging
				chargecount = 0

		//Show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		//If we have excess power for long enough, think about re-enable charging.
		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge*GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0
					charging = APC_NOT_CHARGING

				if(chargecount == 10)
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

	//Update icon & area power if anything changed

	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

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
	update_icon()
	update()
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
	machine_stat |= BROKEN
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
	for(var/a in area.related)
		var/area/A = a
		for(var/obj/machinery/light/L in A)
			L.broken()
			L.on = FALSE
			stoplag()

/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/apc/can_terminal_dismantle()
	. = opened ? TRUE : FALSE

/obj/machinery/power/apc/proc/skillcheck(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!H.mind)
		return FALSE
	if(H.mind.cm_skills?.engineer < SKILL_ENGINEER_ENGI)
		H.visible_message("<span class='notice'>[H] fumbles around figuring out how to operate [src]'s interface.</span>",
		"<span class='notice'>You fumble around figuring out how to operate [src]'s interface.</span>")
		var/fumbling_time = 50 * (SKILL_ENGINEER_ENGI - H.mind.cm_skills.engineer)
		if(!do_after(H, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
			return FALSE
	return TRUE

//------Various APCs ------//

// mapping helpers
/obj/machinery/power/apc/drained
	start_charge = 0

/obj/machinery/power/apc/lowcharge
	start_charge = 25

/obj/machinery/power/apc/potato
	cell_type = /obj/item/cell/potato

/obj/machinery/power/apc/weak
	cell_type = /obj/item/cell

/obj/machinery/power/apc/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/super
	cell_type = /obj/item/cell/super

/obj/machinery/power/apc/hyper
	cell_type = /obj/item/cell/hyper

//------Theseus APCs ------//

/obj/machinery/power/apc/almayer
	req_access = list(ACCESS_MARINE_ENGINEERING)
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/almayer/hardened
	name = "hardened area power controller"
	desc = "A control terminal for the area electrical systems. This one is hardened against sudden power fluctuations caused by electrical grid damage."
	crash_break_probability = 0

#undef APC_RESET_EMP

#undef APC_ELECTRONICS_MISSING
#undef APC_ELECTRONICS_INSTALLED
#undef APC_ELECTRONICS_SECURED

#undef APC_COVER_CLOSED
#undef APC_COVER_OPENED
#undef APC_COVER_REMOVED

#undef APC_NOT_CHARGING
#undef APC_CHARGING
#undef APC_FULLY_CHARGED

#undef APC_EXTERNAL_POWER_NONE
#undef APC_EXTERNAL_POWER_LOW
#undef APC_EXTERNAL_POWER_GOOD
