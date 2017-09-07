
/obj/machinery/computer/dropship_weapons
	name = "abstract dropship weapons controls"
	desc = "A computer to manage equipments and weapons installed on the dropship."
	density = 1
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "consoleright"
	circuit = null
	unacidable = TRUE
	exproof = TRUE
	var/shuttle_tag  // Used to know which shuttle we're linked to.
	var/obj/structure/dropship_equipment/selected_equipment //the currently selected equipment installed on the shuttle this console controls.
	var/list/shuttle_equipments = list() //list of the equipments on the shuttle this console controls



/obj/machinery/computer/dropship_weapons/attack_hand(mob/user)
	if(..())
		return
	if(!allowed(user))
		user << "<span class='warning'>Access denied.</span>"
		return 1

	user.set_interaction(src)
	ui_interact(user)


/obj/machinery/computer/dropship_weapons/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)
	var/data[0]
	var/datum/shuttle/ferry/marine/FM = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(FM))
		return

	var/shuttle_state
	switch(FM.moving_status)
		if(SHUTTLE_IDLE) shuttle_state = "idle"
		if(SHUTTLE_WARMUP) shuttle_state = "warmup"
		if(SHUTTLE_INTRANSIT) shuttle_state = "in_transit"
		if(SHUTTLE_CRASHED) shuttle_state = "crashed"


	var/list/equipment_data = list()
	var/list/targets_data = list()
	for(var/X in active_laser_targets)
		var/obj/effect/overlay/temp/laser_target/LT = X
		if(!istype(LT))
			continue
		var/area/laser_area = get_area(LT)
		targets_data += list(list("target_name" = "[LT.name] ([laser_area.name])", "target_tag" = LT.target_id))
	shuttle_equipments = FM.equipments
	var/element_nbr = 1
	for(var/X in FM.equipments)
		var/obj/structure/dropship_equipment/E = X
		equipment_data += list(list("name"= sanitize(copytext(E.name,1,MAX_MESSAGE_LEN)), "eqp_tag" = element_nbr, "is_weapon" = E.is_weapon, "is_interactable" = E.is_interactable))
		element_nbr++


	var/selected_eqp_name = ""
	var/selected_eqp_ammo_name = ""
	var/selected_eqp_ammo_amt = 0
	var/selected_eqp_max_ammo_amt = 0
	var/screen_mode = 0
	if(selected_equipment)
		selected_eqp_name = sanitize(copytext(selected_equipment.name,1,MAX_MESSAGE_LEN))
		if(selected_equipment.ammo_equipped)
			selected_eqp_ammo_name = sanitize(copytext(selected_equipment.ammo_equipped.name,1,MAX_MESSAGE_LEN))
			selected_eqp_ammo_amt = selected_equipment.ammo_equipped.ammo_count
			selected_eqp_max_ammo_amt = selected_equipment.ammo_equipped.max_ammo_count
		screen_mode = selected_equipment.screen_mode


	data = list(
		"shuttle_state" = shuttle_state,
		"fire_mission_enabled" = FM.transit_gun_mission,
		"equipment_data" = equipment_data,
		"targets_data" = targets_data,
		"selected_eqp" = selected_eqp_name,
		"selected_eqp_ammo_name" = selected_eqp_ammo_name,
		"selected_eqp_ammo_amt" = selected_eqp_ammo_amt,
		"selected_eqp_max_ammo_amt" = selected_eqp_max_ammo_amt,
		"screen_mode" = screen_mode,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "dropship_weapons_console.tmpl", "Weapons Control", 500, 400)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/dropship_weapons/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	var/datum/shuttle/ferry/marine/shuttle = shuttle_controller.shuttles[shuttle_tag]
	if (!istype(shuttle))
		return

	if(href_list["equip_interact"])
		var/base_tag = text2num(href_list["equip_interact"])
		var/obj/structure/dropship_equipment/E = shuttle_equipments[base_tag]
		E.linked_console = src
		E.equipment_interact(usr)

	if(href_list["open_fire"])
		var/targ_id = text2num(href_list["open_fire"])
		var/mob/M = usr
		if(M.mind.assigned_role != "Pilot Officer") //only pilots can fire dropship weapons.
			usr << "<span class='warning'>A screen with graphics and walls of physics and engineering values open, you immediately force it closed.</span>"
			return
		for(var/X in active_laser_targets)
			var/obj/effect/overlay/temp/laser_target/LT = X
			if(LT.target_id == targ_id)
				if(shuttle.moving_status != SHUTTLE_INTRANSIT)
					usr << "<span class='warning'>Dropship can only fire while in flight.</span>"
					return
				if(shuttle.queen_locked) return

				if(!selected_equipment || !selected_equipment.is_weapon)
					usr << "<span class='warning'>No weapon selected.</span>"
					return
				var/obj/structure/dropship_equipment/weapon/DEW = selected_equipment
				if(!shuttle.transit_gun_mission && DEW.fire_mission_only)
					usr << "<span class='warning'>[DEW] requires a fire mission flight type to be fired.</span>"
					return

				if(!DEW.ammo_equipped || DEW.ammo_equipped.ammo_count <= 0)
					usr << "<span class='warning'>[DEW] has no ammo.</span>"
					return
				if(DEW.last_fired > world.time - DEW.firing_delay)
					usr << "<span class='warning'>[DEW] just fired, wait for it to cool down.</span>"
					return
				if(!LT.loc) return
				DEW.open_fire(LT)
				break

	if(href_list["deselect"])
		selected_equipment = null

	ui_interact(usr)

/obj/machinery/computer/dropship_weapons/dropship1
	name = "\improper 'Alamo' weapons controls"
	New()
		..()
		shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"

/obj/machinery/computer/dropship_weapons/dropship2
	name = "\improper 'Normandy' weapons controls"

	New()
		..()
		shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"