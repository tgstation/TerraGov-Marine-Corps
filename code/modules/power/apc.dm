#define APC_RESET_EMP 5

#define APC_ELECTRONICS_MISSING 0
#define APC_ELECTRONICS_INSTALLED 1
#define APC_ELECTRONICS_SECURED 2

#define APC_COVER_CLOSED 0
#define APC_COVER_OPENED 1
#define APC_COVER_REMOVED 2

#define APC_NOT_CHARGING 0
#define APC_CHARGING 1
#define APC_FULLY_CHARGED 2

#define APC_EXTERNAL_POWER_NONE 0
#define APC_EXTERNAL_POWER_LOW 1
#define APC_EXTERNAL_POWER_GOOD 2

//The Area Power Controller (APC), formerly Power Distribution Unit (PDU)
//One per area, needs wire conection to power network

//Controls power to devices in that area
//May be opened to change power cell
//Three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon = 'icons/obj/machines/apc.dmi'
	icon_state = "apc0"
	//pixel_x = -16
	//pixel_y = -16
	anchored = TRUE
	use_power = NO_POWER_USE
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	resistance_flags = UNACIDABLE
	interaction_flags = INTERACT_MACHINE_TGUI
	light_range = 1
	light_power = 0.5
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
	var/debug = 0
	var/has_electronics = APC_ELECTRONICS_MISSING
	var/overload = 1 //Used for the Blackout malf module
	var/beenhit = 0 //Used for counting how many times it has been hit, used for Aliens at the moment
	var/longtermpower = 10
	var/update_state = NONE
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

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/updateUsrDialog()
	if(machine_stat & (BROKEN|MAINT))
		return
	..()

/obj/machinery/power/apc/Initialize(mapload, ndir, building)
	GLOB.apcs_list += src
	wires = new /datum/wires/apc(src)

	// offset 32 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (ndir)
		setDir(ndir)

	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

	if(building)
		var/area/A = get_area(src)
		area = A
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [area.name] APC"
		machine_stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(update)), 5)

	start_processing()

	. = ..()

	var/area/A = get_area(src)

	//If area isn't specified use current
	if(isarea(A) && areastring == null)
		area = A
		name = "\improper [area.name] APC"
	else
		area = get_area_name(areastring)
		name = "\improper [area.name] APC"

	update_icon()
	update() //areas should be lit on startup

	if(mapload)
		has_electronics = APC_ELECTRONICS_SECURED

		//Is starting with a power cell installed, create it and set its charge level
		if(cell_type)
			set_cell(new cell_type(src))
			cell.charge = start_charge * cell.maxcharge / 100.0 //Convert percentage to actual value
			cell.update_icon()


		make_terminal()

		update() //areas should be lit on startup

		//Break few ACPs on the colony
		if(!start_charge && is_ground_level(z) && prob(10))
			addtimer(CALLBACK(src, PROC_REF(set_broken)), 5)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()

	QDEL_NULL(cell)
	QDEL_NULL(wires)
	if(terminal)
		disconnect_terminal()

	return ..()

///Wrapper to guarantee powercells are properly nulled and avoid hard deletes.
/obj/machinery/power/apc/proc/set_cell(obj/item/cell/new_cell)
	if(cell)
		UnregisterSignal(cell, COMSIG_QDELETING)
	cell = new_cell
	if(cell)
		RegisterSignal(cell, COMSIG_QDELETING, PROC_REF(on_cell_deletion))


///Called by the deletion of the referenced powercell.
/obj/machinery/power/apc/proc/on_cell_deletion(obj/item/cell/source, force)
	SIGNAL_HANDLER
	set_cell(null)


/obj/machinery/power/apc/proc/make_terminal()
	//Create a terminal object at the same position as original turf loc
	//Wires will attach to this
	terminal = new(loc)
	terminal.setDir(REVERSE_DIR(dir))
	terminal.master = src

/obj/machinery/power/apc/examine(mob/user)
	. = ..()

	if(machine_stat & BROKEN)
		. += span_info("It appears to be completely broken. It's hard to see what else is wrong with it.")
		return

	if(opened)
		if(has_electronics && terminal)
			. += span_info("The cover is [opened == APC_COVER_REMOVED ? "removed":"open"] and the power cell is [cell ? "installed":"missing"].")
		else
			. += span_info("It's [ !terminal ? "not" : "" ] wired up.")
			. += span_info("The electronics are[!has_electronics?"n't":""] installed.")
	else
		if(machine_stat & MAINT)
			. += span_info("The cover is closed. Something is wrong with it, it doesn't work.")
		else
			. += span_info("The cover is closed.")

	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		. += span_info("The wiring is exposed.")

//Update the APC icon to show the three base states
//Also add overlays for indicator lights
/obj/machinery/power/apc/update_icon() //TODO JESUS CHRIST THIS IS SHIT
	var/update = check_updates()	//Returns 0 if no need to update icons.
									//1 if we need to update the icon_state
									//2 if we need to update the overlays
	if(!update)
		return

	set_light(0)
	overlays.Cut()

	if(update & 1)
		var/broken = CHECK_BITFIELD(update_state, UPSTATE_BROKE) ? "-b" : ""
		var/status = (CHECK_BITFIELD(update_state, UPSTATE_WIREEXP) && !CHECK_BITFIELD(update_state, UPSTATE_OPENED1)) ? "-wires" : broken
		icon_state = "apc[opened][status]"

	if(update & 2)
		if(CHECK_BITFIELD(update_overlay, APC_UPOVERLAY_CELL_IN))
			overlays += "apco-cell"
		else if(CHECK_BITFIELD(update_state, UPSTATE_ALLGOOD))
			overlays += emissive_appearance(icon, "apcox-[locked]")
			overlays += mutable_appearance(icon, "apcox-[locked]")
			overlays += emissive_appearance(icon, "apco3-[charging]")
			overlays += mutable_appearance(icon, "apco3-[charging]")
			var/operating = CHECK_BITFIELD(update_overlay, APC_UPOVERLAY_OPERATING)
			overlays += emissive_appearance(icon, "apco0-[operating ? equipment : 0]")
			overlays += mutable_appearance(icon, "apco0-[operating ? equipment : 0]")
			overlays += emissive_appearance(icon, "apco1-[operating ? lighting : 0]")
			overlays += mutable_appearance(icon, "apco1-[operating ? lighting : 0]")
			overlays += emissive_appearance(icon, "apco2-[operating ? environ : 0]")
			overlays += mutable_appearance(icon, "apco2-[operating ? environ : 0]")

			switch(charging)
				if(APC_NOT_CHARGING)
					set_light_color(LIGHT_COLOR_RED)
				if(APC_CHARGING)
					set_light_color(LIGHT_COLOR_BLUE)
				if(APC_FULLY_CHARGED)
					set_light_color(LIGHT_COLOR_GREEN)
			set_light(initial(light_range))

/obj/machinery/power/apc/proc/check_updates()

	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = NONE
	update_overlay = 0

	if(machine_stat & BROKEN)
		ENABLE_BITFIELD(update_state, UPSTATE_BROKE)
	if(machine_stat & MAINT)
		ENABLE_BITFIELD(update_state, UPSTATE_MAINT)
	switch(opened)
		if(APC_COVER_OPENED)
			ENABLE_BITFIELD(update_state, UPSTATE_OPENED1)
		if(APC_COVER_REMOVED)
			ENABLE_BITFIELD(update_state, UPSTATE_OPENED2)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(update_state, UPSTATE_WIREEXP)
	if(!update_state)
		ENABLE_BITFIELD(update_state, UPSTATE_ALLGOOD)
		if(locked)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LOCKED)
		if(operating)
			ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_OPERATING)

		switch(charging)
			if(APC_NOT_CHARGING)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CHARGEING0)
			if(APC_CHARGING)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CHARGEING1)
			if(APC_FULLY_CHARGED)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_CHARGEING2)

		switch(equipment)
			if(0)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_EQUIPMENT0)
			if(1)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_EQUIPMENT1)
			if(2)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_EQUIPMENT2)

		switch(lighting)
			if(0)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LIGHTING0)
			if(1)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LIGHTING1)
			if(2)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_LIGHTING2)

		switch(environ)
			if(0)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_ENVIRON0)
			if(1)
				ENABLE_BITFIELD(update_overlay, APC_UPOVERLAY_ENVIRON1)
			if(2)
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

/obj/machinery/power/apc/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(effects)
		X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
		X.visible_message(span_danger("[X] slashes \the [src]!"), \
		span_danger("We slash \the [src]!"), null, 5)
		playsound(loc, "alien_claw_metal", 25, 1)

	var/allcut = wires.is_all_cut()

	if(beenhit >= pick(3, 4) && !CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(machine_stat, PANEL_OPEN)
		update_icon()
		visible_message(span_danger("\The [src]'s cover swings open, exposing the wires!"), null, null, 5)

	else if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) && !allcut)
		wires.cut_all()
		update_icon()
		visible_message(span_danger("\The [src]'s wires snap apart in a rain of sparks!"), null, null, 5)
		if(X.client)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[X.ckey]
			personal_statistics.apcs_slashed++
	else
		beenhit += 1

//Attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/cell) && opened) //Trying to put a cell inside
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out how to fit [I] into [src]."),
			span_notice("You fumble around figuring out how to fit [I] into [src]."))
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(cell)
			balloon_alert(user, "Already installed")
			return

		if(machine_stat & MAINT)
			balloon_alert(user, "No connector")
			return

		if(!user.transferItemToLoc(I, src))
			return

		set_cell(I)
		user.visible_message("<span class='notice'>[user] inserts [I] into [src]!",
		"<span class='notice'>You insert [I] into [src]!")
		chargecount = 0
		update_icon()

	else if(istype(I, /obj/item/card/id)) //Trying to unlock the interface with an ID card
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out where to swipe [I] on [src]."),
			span_notice("You fumble around figuring out where to swipe [I] on [src]."))
			var/fumbling_time = 3 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(opened)
			balloon_alert(user, "Close the cover first")
			return

		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			balloon_alert(user, "Close the panel first")
			return

		if(machine_stat & (BROKEN|MAINT))
			balloon_alert(user, "Nothing happens")
			return

		if(!allowed(user))
			balloon_alert(user, "Access denied")
			return

		locked = !locked
		balloon_alert_to_viewers("[locked ? "locked" : "unlocked"]")
		update_icon()

	else if(iscablecoil(I) && !terminal && opened && has_electronics != APC_ELECTRONICS_SECURED)
		var/obj/item/stack/cable_coil/C = I

		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		var/turf/T = get_turf(src)
		if(T.intact_tile)
			balloon_alert(user, "Remove the floor plating")
			return

		if(C.get_amount() < 10)
			balloon_alert(user, "Not enough wires")
			return

		balloon_alert_to_viewers("starts wiring [src]")
		playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD) || terminal || !opened || has_electronics == APC_ELECTRONICS_SECURED)
			return

		var/obj/structure/cable/N = T.get_cable_node()
		if(prob(50) && electrocute_mob(user, N, N))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			return

		if(!C.use(10))
			return

		balloon_alert_to_viewers("Wired]")
		make_terminal()
		terminal.connect_to_network()

	else if(istype(I, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && !(machine_stat & BROKEN))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		balloon_alert_to_viewers("Tries to insert APC board into [src]")
		playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)

		if(!do_after(user, 15, NONE, src, BUSY_ICON_BUILD))
			return

		has_electronics = APC_ELECTRONICS_INSTALLED
		balloon_alert_to_viewers("Inserts APC board into [src]")
		electronics = I
		qdel(I)

	else if(istype(I, /obj/item/circuitboard/apc) && opened && has_electronics == APC_ELECTRONICS_MISSING && (machine_stat & BROKEN))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		balloon_alert(user, "Cannot, frame damaged")

	else if(istype(I, /obj/item/frame/apc) && opened && (machine_stat & BROKEN))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(has_electronics)
			balloon_alert(user, "Cannot, electronics still inside")
			return

		balloon_alert_to_viewers("Begins replacing front panel")

		if(!do_after(user, 50, NONE, src, BUSY_ICON_BUILD))
			return

		balloon_alert_to_viewers("Replaces front panel")
		qdel(I)
		DISABLE_BITFIELD(machine_stat, BROKEN)
		if(opened == APC_COVER_REMOVED)
			opened = APC_COVER_OPENED
		update_icon()

	else if(istype(I, /obj/item/frame/apc) && opened)
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return

		if(opened == APC_COVER_REMOVED)
			opened = APC_COVER_OPENED
		balloon_alert_to_viewers("Replaces [src]'s front panel")
		qdel(I)
		update_icon()

	else
		if(((machine_stat & BROKEN)) && !opened && I.force >= 5)
			opened = APC_COVER_REMOVED
			balloon_alert_to_viewers("Knocks down [src]'s panel")
			update_icon()
		else
			if(issilicon(user))
				return attack_hand(user)

			if(!opened && CHECK_BITFIELD(machine_stat, PANEL_OPEN) && (ismultitool(I) || iswirecutter(I)))
				return attack_hand(user)
			balloon_alert_to_viewers("Hits [src] with [I]")


/obj/machinery/power/apc/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(opened)
		if(has_electronics == APC_ELECTRONICS_INSTALLED)
			if(terminal)
				balloon_alert(user, "Disconnect the wires")
				return
			if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
				balloon_alert_to_viewers("Fumbles around removing cell from [src]")
				var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			I.play_tool_sound(src)
			balloon_alert(user, "Removing APC board")
			if(I.use_tool(src, user, 50))
				if(has_electronics == APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_MISSING
					if(machine_stat & BROKEN)
						balloon_alert_to_viewers("Removes the charred control board")
						return
					else
						balloon_alert_to_viewers("Removes the control board")
						new /obj/item/circuitboard/apc(loc)
						return
		else if(opened != APC_COVER_REMOVED)
			opened = APC_COVER_CLOSED
			coverlocked = TRUE //closing cover relocks it
			update_icon()
			return
	else if(!(machine_stat & BROKEN))
		if(coverlocked && !(machine_stat & MAINT)) // locked...
			balloon_alert(user, "Locked")
			return
		else if(machine_stat & PANEL_OPEN)
			balloon_alert(user, "Can't, wires in way")
			return
		else
			opened = APC_COVER_OPENED
			update_icon()
			return


/obj/machinery/power/apc/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	. = TRUE
	if(opened)
		if(cell)
			if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
				balloon_alert_to_viewers("fumbles")
				var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("Removes cell")
			var/turf/T = get_turf(user)
			cell.forceMove(T)
			cell.update_icon()
			set_cell(null)
			charging = APC_NOT_CHARGING
			update_icon()
			return
		else
			switch(has_electronics)
				if(APC_ELECTRONICS_INSTALLED)
					has_electronics = APC_ELECTRONICS_SECURED
					machine_stat &= ~MAINT
					I.play_tool_sound(src)
					balloon_alert(user, "Screws circuit board in")
				if(APC_ELECTRONICS_SECURED)
					has_electronics = APC_ELECTRONICS_INSTALLED
					machine_stat |= MAINT
					I.play_tool_sound(src)
					balloon_alert(user, "Unfastens electronics")
				else
					balloon_alert(user, "Nothing securable")
					return
			update_icon()
	else
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		balloon_alert(user, "wires [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "exposed" : "unexposed"]")
		update_icon()


/obj/machinery/power/apc/wirecutter_act(mob/living/user, obj/item/I)
	if(terminal && opened)
		terminal.deconstruct(user)
		return TRUE


/obj/machinery/power/apc/welder_act(mob/living/user, obj/item/I)
	if(!opened || has_electronics || terminal)
		return

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		balloon_alert_to_viewers("fumbles")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return

	if(!I.tool_start_check(user, amount = 3))
		return
	balloon_alert_to_viewers("welds [src]")

	if(!I.use_tool(src, user, 50, volume = 50, amount = 3))
		return

	if((machine_stat & BROKEN) || opened == APC_COVER_REMOVED)
		new /obj/item/stack/sheet/metal(loc)
		balloon_alert_to_viewers("cuts apart [src]")
	else
		new /obj/item/frame/apc(loc)
		balloon_alert_to_viewers("cuts [src] from the wall")
	qdel(src)
	return TRUE


//Attack with hand - remove cell (if cover open) or interact with the APC
/obj/machinery/power/apc/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(opened && cell && !issilicon(user))
		if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
			balloon_alert_to_viewers("fumbles")
			var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_ENGI - user.skills.getRating(SKILL_ENGINEER) )
			if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
				return
		balloon_alert_to_viewers("removes [src] from [src]")
		user.put_in_hands(cell)
		cell.update_icon()
		set_cell(null)
		charging = APC_NOT_CHARGING
		update_icon()
		return

	if(machine_stat & (BROKEN|MAINT))
		return

	interact(user)



/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Apc", name)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = DisplayPower(lastused_total),
		"coverLocked" = coverlocked,
		"siliconUser" = issilicon(user),

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = DisplayPower(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on" = list("eqp" = 2),
					"off" = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = DisplayPower(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on" = list("lgt" = 2),
					"off" = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = DisplayPower(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on" = list("env" = 2),
					"off" = list("env" = 1)
				)
			)
		)
	)
	return data


/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell?.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/can_use(mob/user, loud = FALSE) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(isAI(user) && aidisabled)
		if(!loud)
			balloon_alert(user, "eee is disabled")
		return FALSE
	return TRUE

/obj/machinery/power/apc/ui_act(action, list/params)
	. = ..()
	if(. || !can_use(usr, TRUE) || (locked && !usr.has_unlimited_silicon_privilege))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if((machine_stat & (BROKEN|MAINT)))
					balloon_alert(usr, "APC unresponsive")
				else
					locked = !locked
					update_icon()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_icon()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
			. = TRUE
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				overload_lighting()
				. = TRUE
	return TRUE

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


/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = 3
			environ = 3
			update_icon()
			update()

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0


/obj/machinery/power/apc/add_load(amount)
	if(terminal?.powernet)
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

	lastused_light = area.usage(STATIC_LIGHTS)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
	area.clear_usage()

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

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused / GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge / GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)


		// set channels depending on how much charge we have left

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

		// now trickle-charge the cell
		if(chargemode && charging == APC_CHARGING && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge * GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_CHARGING

		else // chargemode off
			charging = APC_NOT_CHARGING
			chargecount = 0

	else // no cell, switch everything off
		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	// update icon & area power if anything changed
	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if(last_ch != charging)
		queue_icon_update()

//val 0 = off, 1 = off(auto) 2 = on, 3 = on(auto)
//on 0 = off, 1 = auto-on, 2 = auto-off

/proc/autoset(val, on)

	switch(on)
		if(0) //Turn things off
			switch(val)
				if(2) //If on, return off
					return 0
				if(3) //If auto-on, return auto-off
					return 1

		if(1) //Turn things auto-on
			if(val == 1) //If auto-off, return auto-on
				return 3

		if(2) //Turn things auto-off
			if(val == 3) //If auto-on, return auto-off
				return 1
	return val


/obj/machinery/power/apc/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update_icon()
	update()
	addtimer(CALLBACK(src, PROC_REF(reset), APC_RESET_EMP), 60 SECONDS)
	return ..()


/obj/machinery/power/apc/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			cell?.ex_act(1) //More lags woohoo
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
			set_broken()
			if(!cell || prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
			set_broken()
			if(!cell || prob(75))
				return
		if(EXPLODE_WEAK)
			if(prob(80))
				return
			set_broken()
			if(!cell || prob(85))
				return

	cell.ex_act(severity)


/obj/machinery/power/apc/proc/set_broken()
	//Aesthetically much better!
	visible_message(span_warning("[src]'s screen flickers with warnings briefly!"))
	addtimer(CALLBACK(src, PROC_REF(do_break)), rand(2, 5))


/obj/machinery/power/apc/proc/do_break()
	visible_message(span_danger("[src]'s screen suddenly explodes in rain of sparks and small debris!"))
	machine_stat |= BROKEN
	operating = FALSE
	update_icon()
	update()


//Overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting()
	if(!operating || shorted)
		return
	if(cell?.charge >= 20)
		cell.use(20)
		INVOKE_ASYNC(src, PROC_REF(break_lights))


/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/L in get_area(src))
		L.broken()
		stoplag()


/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null


/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(machine_stat & (NOPOWER|BROKEN|MAINT))
		return

	operating = !operating
	log_combat(user, src, "turned [operating ? "on" : "off"]")
	update()
	update_icon()


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

//------Marine ship APCs ------//

/obj/machinery/power/apc/mainship
	req_access = list(ACCESS_MARINE_ENGINEERING)
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/mainship/hardened
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
