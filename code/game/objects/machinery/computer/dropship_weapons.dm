
/obj/machinery/computer/dropship_weapons
	name = "abstract dropship weapons controls"
	desc = "A computer to manage equipments and weapons installed on the dropship."
	density = TRUE
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "consoleright"
	circuit = null
	resistance_flags = RESIST_ALL
	interaction_flags = INTERACT_MACHINE_NANO
	var/shuttle_tag  // Used to know which shuttle we're linked to.
	var/obj/structure/dropship_equipment/selected_equipment //the currently selected equipment installed on the shuttle this console controls.
	var/list/shuttle_equipments = list() //list of the equipments on the shuttle this console controls


/obj/machinery/computer/dropship_weapons/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttle_tag)
	if(!shuttle)
		WARNING("[src] could not find shuttle [shuttle_tag] from SSshuttle")
		return 

	var/list/data = list()
	var/list/equipment_data = list()	
	var/list/targets_data = list()	
	for(var/X in GLOB.active_laser_targets)	
		var/obj/effect/overlay/temp/laser_target/LT = X	
		var/area/laser_area = get_area(LT)	
		targets_data += list(list("target_name" = "[LT.name] ([laser_area.name])", "target_tag" = LT.target_id))	
	shuttle_equipments = shuttle.equipments	
	var/element_nbr = 1	
	for(var/X in shuttle.equipments)	
		var/obj/structure/dropship_equipment/E = X	
		equipment_data += list(list("name"= sanitize(copytext(E.name,1,MAX_MESSAGE_LEN)), "eqp_tag" = element_nbr, "is_weapon" = E.is_weapon, "is_interactable" = E.is_interactable))	
		element_nbr++	

	var/selected_eqp_name = ""	
	var/selected_eqp_ammo_name = ""	
	var/selected_eqp_ammo_amt = 0	
	var/selected_eqp_max_ammo_amt = 0	
	var/screen_mode = 0	
	var/ammo_status = ""
	if(selected_equipment)	
		selected_eqp_name = sanitize(copytext(selected_equipment.name,1,MAX_MESSAGE_LEN))	
		if(selected_equipment.ammo_equipped)	
			selected_eqp_ammo_name = sanitize(copytext(selected_equipment.ammo_equipped.name,1,MAX_MESSAGE_LEN))	
			selected_eqp_ammo_amt = selected_equipment.ammo_equipped.ammo_count	
			selected_eqp_max_ammo_amt = selected_equipment.ammo_equipped.max_ammo_count	

			switch((selected_eqp_ammo_amt / selected_eqp_max_ammo_amt) * 100)
				if(50 to INFINITY)
					ammo_status = "good"
				if(0 to 50)
					ammo_status = "average"
				if(-INFINITY to 0)
					ammo_status = "bad"
		screen_mode = selected_equipment.screen_mode	

	data = list(	
		"shuttle_mode" = shuttle.mode,	
		"equipment_data" = equipment_data,	
		"targets_data" = targets_data,	
		"selected_eqp" = selected_eqp_name,	
		"selected_eqp_ammo_name" = selected_eqp_ammo_name,	
		"selected_eqp_ammo_amt" = selected_eqp_ammo_amt,	
		"selected_eqp_max_ammo_amt" = selected_eqp_max_ammo_amt,	
		"selected_eqp_ammo_status" = ammo_status,
		"screen_mode" = screen_mode,	
	)	
	
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)	
	if (!ui)	
		ui = new(user, src, ui_key, "dropship_weapons_console.tmpl", "Weapons Control", 500, 400)	
		ui.set_initial_data(data)	
		ui.open()	
		ui.set_auto_update(1)

/obj/machinery/computer/dropship_weapons/Topic(href, href_list)	
	. = ..()
	if(.)	
		return	

	var/obj/docking_port/mobile/marine_dropship/shuttle = SSshuttle.getShuttle(shuttle_tag)
	if(!shuttle)
		stack_trace("Invalid shuttle_tag [shuttle_tag]")
		return

	if(href_list["equip_interact"])	
		var/base_tag = text2num(href_list["equip_interact"])	
		var/obj/structure/dropship_equipment/E = shuttle_equipments[base_tag]	
		E.linked_console = src	
		E.equipment_interact(usr)	

	if(href_list["open_fire"])	
		var/targ_id = text2num(href_list["open_fire"])	
		var/mob/living/L = usr	
		if(!istype(L))
			return
		if(!istype(SSjob.GetJob(L.mind.assigned_role), /datum/job/command/pilot)) //everyone can fire dropship weapons while fumbling.	
			L.visible_message("<span class='notice'>[L] fumbles around figuring out how to use the automated targeting system.</span>",	
			"<span class='notice'>You fumble around figuring out how to use the automated targeting system.</span>")	
			var/fumbling_time = 100 - 20 * L.mind.cm_skills.pilot	
			if(!do_after(L, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))	
				return FALSE	
		for(var/X in GLOB.active_laser_targets)	
			var/obj/effect/overlay/temp/laser_target/LT = X	
			if(LT.target_id == targ_id)	
				if(shuttle.mode != SHUTTLE_CALL)	
					to_chat(L, "<span class='warning'>Dropship can only fire while in flight.</span>")	
					return	
				if(shuttle.mode == SHUTTLE_HIJACK_LOCK) 
					return	

				if(!selected_equipment?.is_weapon)	
					to_chat(L, "<span class='warning'>No weapon selected.</span>")	
					return	
				var/obj/structure/dropship_equipment/weapon/DEW = selected_equipment	
				if(!DEW.ammo_equipped || DEW.ammo_equipped.ammo_count <= 0)	
					to_chat(L, "<span class='warning'>[DEW] has no ammo.</span>")	
					return	
				if(DEW.last_fired > world.time - DEW.firing_delay)	
					to_chat(L, "<span class='warning'>[DEW] just fired, wait for it to cool down.</span>")	
					return	
				if(QDELETED(LT)) // Quick final check on the Laser target
					return	
				DEW.open_fire(LT)	
				break	

	if(href_list["deselect"])	
		selected_equipment = null	

	ui_interact(usr)


/obj/machinery/computer/dropship_weapons/dropship1
	name = "\improper 'Alamo' weapons controls"
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/computer/dropship_weapons/dropship1/Initialize()
	. = ..()
	shuttle_tag = "alamo"

/obj/machinery/computer/dropship_weapons/dropship2
	name = "\improper 'Normandy' weapons controls"
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/computer/dropship_weapons/dropship2/Initialize()
	. = ..()
	shuttle_tag = "normandy"
