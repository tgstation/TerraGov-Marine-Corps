GLOBAL_LIST_INIT(greyscale_weapons_data, generate_greyscale_weapons_data())

///generates the static list data containig all printable mech equipment modules for greyscale
/proc/generate_greyscale_weapons_data()
	. = list("weapons" = list(), "ammo" = list(), "armor" = list(), "utility" = list(), "power" = list())
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/type AS in subtypesof(/obj/item/mecha_parts/mecha_equipment))
		if(!(initial(type.mech_flags) & EXOSUIT_MODULE_GREYSCALE))
			continue
		if(initial(type.mech_flags) == ALL)
			continue
		switch(initial(type.equipment_slot))
			if(MECHA_WEAPON)
				var/list/weapon_representation = list(
					"type" = type,
					"name" = initial(type.name),
					"desc" = initial(type.desc),
					"icon_state" = initial(type.icon_state),
					"health" = initial(type.max_integrity),
					"firerate" = initial(type.projectile_delay),
					"burst_count" = initial(type.burst_amount),
					"scatter" = initial(type.variance),
					"slowdown" = initial(type.slowdown),
					"burst_amount" = initial(type.burst_amount)
				)
				var/datum/ammo/ammotype = initial(type.ammotype)
				if(ispath(ammotype, /datum/ammo))
					weapon_representation["damage"] = initial(ammotype.damage)
					weapon_representation["armor_pierce"] = initial(ammotype.penetration)
				if(ispath(type, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic))
					var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/ballistic_type = type
					weapon_representation["projectiles"] = initial(ballistic_type.projectiles)
					weapon_representation["cache_max"] = initial(ballistic_type.projectiles_cache_max)
					weapon_representation["ammo_type"] = initial(ballistic_type.ammo_type)
				.["weapons"] += list(weapon_representation)
			if(MECHA_ARMOR)
				.["armor"] += list(list(
					"type" = type,
					"name" = initial(type.name),
					"desc" = initial(type.desc),
					"slowdown" = initial(type.slowdown),
				))
			if(MECHA_UTILITY)
				.["utility"] += list(list(
					"type" = type,
					"name" = initial(type.name),
					"desc" = initial(type.desc),
					"energy_drain" = initial(type.energy_drain),
				))
			if(MECHA_POWER)
				.["power"] += list(list(
					"type" = type,
					"name" = initial(type.name),
					"desc" = initial(type.desc),
				))
			else
				stack_trace("equipment_slot not set for [type]")
	for(var/obj/item/mecha_ammo/vendable/ammo AS in subtypesof(/obj/item/mecha_ammo/vendable))
		.["ammo"] += list(list(
			"type" = ammo,
			"name" = initial(ammo.name),
			"icon_state" = initial(ammo.icon_state),
			"ammo_count" = initial(ammo.rounds),
			"ammo_type" = initial(ammo.ammo_type),
		))

/atom/movable/screen/mech_builder_view
	name = "Mech preview"
	del_on_map_removal = FALSE
	layer = OBJ_LAYER
	plane = GAME_PLANE
	///list of plane masters to apply to owners
	var/list/plane_masters = list()

/atom/movable/screen/mech_builder_view/Initialize(mapload)
	. = ..()
	assigned_map = "mech_preview_[REF(src)]"
	set_position(1, 1)
	for(var/plane_master_type in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type()
		plane_master.screen_loc = "[assigned_map]:CENTER"
		plane_masters += plane_master

/atom/movable/screen/mech_builder_view/Destroy()
	QDEL_LIST(plane_masters)
	return ..()

/obj/machinery/computer/mech_builder
	name = "mech computer"
	screen_overlay = "mech_computer"
	dir = EAST // determines where the mech will pop out, NOT where the computer faces
	interaction_flags = INTERACT_OBJ_UI

	///current selected name for the mech
	var/selected_name = "TGMC Combat Mech"
	///STRING-STRING list of mech_slot-primary_color_palette
	var/list/selected_primary = list(
		MECH_GREY_TORSO = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_HEAD = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_LEGS = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_R_ARM = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_L_ARM = MECH_GREY_PRIMARY_DEFAULT,
	)
	///STRING-STRING list of mech_slot-secondary_color_palette
	var/list/selected_secondary = list(
		MECH_GREY_TORSO = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_HEAD = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_LEGS = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_R_ARM = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_L_ARM = MECH_GREY_SECONDARY_DEFAULT,
	)
	///string of the visor palette
	var/selected_visor = MECH_GREY_VISOR_DEFAULT
	///STRING-STRING list of mech_slot-part_type
	var/selected_variants = list(
		MECH_GREY_TORSO = MECH_ASSAULT,
		MECH_GREY_HEAD = MECH_ASSAULT,
		MECH_GREY_LEGS = MECH_ASSAULT,
		MECH_GREY_R_ARM = MECH_ASSAULT,
		MECH_GREY_L_ARM = MECH_ASSAULT,
	)
	/// Currently selected equipment, maxes are determined by equipment_max
	var/selected_equipment = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	///List of max equipment that we're allowed to attach while using this console
	var/equipment_max = MECH_GREYSCALE_MAX_EQUIP
	///reference to the mech screen object
	var/atom/movable/screen/mech_builder_view/mech_view
	///list of stat data that will be sent to the UI
	var/list/current_stats

	/// list(STRING-list(STRING-STRING)) of primary and secondary palettes. first string is category, second is name
	var/static/list/available_colors = ARMOR_PALETTES_LIST
	/// list(STRING-list(STRING-STRING)) of visor palettes. first string is category, second is name
	var/static/list/available_visor_colors = VISOR_PALETTES_LIST

/obj/machinery/computer/mech_builder/Initialize(mapload)
	. = ..()
	mech_view = new
	update_ui_view()
	current_stats = list()
	var/list/datum/mech_limb/limbs = list()
	for(var/slot in selected_variants)
		var/path = get_mech_limb(slot, selected_variants[slot])
		limbs[slot] = new path(TRUE)
	var/datum/mech_limb/head/head_limb = limbs[MECH_GREY_HEAD]
	current_stats["accuracy"] = head_limb.accuracy_mod
	current_stats["light_mod"]= head_limb.light_range
	var/datum/mech_limb/arm/arm_limb = limbs[MECH_GREY_L_ARM]
	current_stats["left_scatter"] = arm_limb.scatter_mod
	arm_limb = limbs[MECH_GREY_R_ARM]
	current_stats["right_scatter"] = arm_limb.scatter_mod
	var/datum/mech_limb/torso/torso_limb = limbs[MECH_GREY_TORSO]
	var/obj/item/cell/cell_type = torso_limb.cell_type
	current_stats["power_max"] = initial(cell_type.maxcharge)

	var/health = 0
	var/slowdown = 0
	var/list/armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	for(var/key in limbs)
		var/datum/mech_limb/limb = limbs[key]
		health += limb.health_mod
		slowdown += limb.slowdown_mod
		for(var/armor_type in limb.soft_armor_mod)
			armor[armor_type] += limb.soft_armor_mod[armor_type]
	current_stats["health"] = health
	current_stats["slowdown"] = slowdown
	current_stats["armor"] = armor

/obj/machinery/computer/mech_builder/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < SKILL_LARGE_VEHICLE_TRAINED)
		return FALSE

/obj/machinery/computer/mech_builder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "MechVendor", name)
	ui.open()
	user.client?.screen |= mech_view.plane_masters
	user.client?.register_map_obj(mech_view)

/obj/machinery/computer/mech_builder/ui_close(mob/user)
	. = ..()
	user.client?.screen -= mech_view.plane_masters
	user.client?.clear_map(mech_view.assigned_map)

/obj/machinery/computer/mech_builder/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet/mech_builder)
	. += get_asset_datum(/datum/asset/spritesheet/mech_ammo)

/obj/machinery/computer/mech_builder/ui_static_data(mob/user)
	var/list/data = list()
	data["mech_view"] = mech_view.assigned_map
	data["colors"] = available_colors
	data["visor_colors"] = available_visor_colors
	data["all_equipment"] = GLOB.greyscale_weapons_data
	data["equip_max"] = equipment_max
	return data

/obj/machinery/computer/mech_builder/ui_data(mob/user)
	var/list/data = list()
	data["selected_primary"] = selected_primary
	data["selected_secondary"] = selected_secondary
	data["selected_visor"] = selected_visor
	data["selected_variants"] = selected_variants
	data["selected_name"] = selected_name
	data["selected_equipment"] = selected_equipment
	data["current_stats"] = current_stats
	data["cooldown_left"] = S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_MECHA)
	return data

/obj/machinery/computer/mech_builder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_MECHA))
		return FALSE
	var/selected_part = params["bodypart"]
	if(selected_part && !(selected_part in selected_primary))
		return FALSE // non valid body parts

	switch(action)
		if("set_primary")
			var/new_color_name = params["new_color"]
			for(var/key in available_colors)
				if(!(new_color_name in available_colors[key]))
					continue
				selected_primary[selected_part] = available_colors[key][new_color_name]
				update_ui_view()
				return TRUE
			return FALSE

		if("set_secondary")
			var/new_color_name = params["new_color"]
			for(var/key in available_colors)
				if(!(new_color_name in available_colors[key]))
					continue
				selected_secondary[selected_part] = available_colors[key][new_color_name]
				update_ui_view()
				return TRUE
			return FALSE

		if("set_visor")
			var/new_color_name = params["new_color"]
			for(var/key in available_visor_colors)
				if(!(new_color_name in available_visor_colors[key]))
					continue
				selected_visor = available_visor_colors[key][new_color_name]
				update_ui_view()
				return TRUE
			return FALSE

		if("set_bodypart")
			var/new_bodytype = params["new_bodytype"]
			if(!(new_bodytype in GLOB.mech_bodytypes))
				return FALSE
			var/old_bodytype = selected_variants[selected_part]
			selected_variants[selected_part] = new_bodytype
			update_ui_view()
			update_stats(selected_part, old_bodytype, new_bodytype)
			return TRUE

		if("set_name")
			var/new_name = params["new_name"]
			if(!new_name)
				return FALSE
			if(is_ic_filtered(new_name) || NON_ASCII_CHECK(new_name))
				tgui_alert(usr, "You cannot set a name that contains a word prohibited in IC chat!")
				return
			selected_name = new_name

		if("assemble")
			for(var/key in selected_primary)
				if(isnull(selected_primary[key]))
					return FALSE
			for(var/key in selected_primary)
				if(isnull(selected_primary[key]))
					return FALSE
			if(isnull(selected_visor))
				return FALSE
			addtimer(CALLBACK(src, PROC_REF(deploy_mech)), 1 SECONDS)
			playsound(get_step(src, dir), 'sound/machines/elevator_move.ogg', 50, 0)
			S_TIMER_COOLDOWN_START(src, COOLDOWN_MECHA, 5 MINUTES)
			return TRUE

		if("add_weapon")
			var/obj/item/mecha_parts/mecha_equipment/weapon/new_type = text2path(params["type"])
			if(!ispath(new_type, /obj/item/mecha_parts/mecha_equipment))
				return FALSE
			if(initial(new_type.equipment_slot) != MECHA_WEAPON)
				return FALSE
			if(!(initial(new_type.mech_flags) & EXOSUIT_MODULE_GREYSCALE))
				return FALSE
			if(params["is_right_weapon"])
				selected_equipment[MECHA_R_ARM] = new_type
				return TRUE
			selected_equipment[MECHA_L_ARM] = new_type
			return TRUE

		if("add_power")
			var/obj/item/mecha_parts/mecha_equipment/new_type = text2path(params["type"])
			if(!ispath(new_type, /obj/item/mecha_parts/mecha_equipment))
				return FALSE
			if(!(initial(new_type.mech_flags) & EXOSUIT_MODULE_GREYSCALE))
				return FALSE
			if(length(selected_equipment[MECHA_POWER]) >= equipment_max[MECHA_POWER])
				return FALSE
			selected_equipment[MECHA_POWER] += new_type
			return TRUE

		if("add_armor")
			var/obj/item/mecha_parts/mecha_equipment/new_type = text2path(params["type"])
			if(!ispath(new_type, /obj/item/mecha_parts/mecha_equipment))
				return FALSE
			if(!(initial(new_type.mech_flags) & EXOSUIT_MODULE_GREYSCALE))
				return FALSE
			if(length(selected_equipment[MECHA_ARMOR]) >= equipment_max[MECHA_ARMOR])
				return FALSE
			selected_equipment[MECHA_ARMOR] += new_type
			return TRUE

		if("add_utility")
			var/obj/item/mecha_parts/mecha_equipment/new_type = text2path(params["type"])
			if(!ispath(new_type, /obj/item/mecha_parts/mecha_equipment))
				return FALSE
			if(!(initial(new_type.mech_flags) & EXOSUIT_MODULE_GREYSCALE))
				return FALSE
			if(length(selected_equipment[MECHA_UTILITY]) >= equipment_max[MECHA_UTILITY])
				return FALSE
			selected_equipment[MECHA_UTILITY] += new_type
			return TRUE

		if("remove_weapon")
			if(params["is_right_weapon"])
				selected_equipment[MECHA_R_ARM] = null
				return TRUE
			selected_equipment[MECHA_L_ARM] = null
			return TRUE

		if("remove_power")
			var/obj/item/mecha_parts/mecha_equipment/removed_type = text2path(params["type"])
			selected_equipment[MECHA_POWER] -= removed_type
			return TRUE

		if("remove_armor")
			var/obj/item/mecha_parts/mecha_equipment/removed_type = text2path(params["type"])
			selected_equipment[MECHA_ARMOR] -= removed_type
			return TRUE

		if("remove_utility")
			var/obj/item/mecha_parts/mecha_equipment/removed_type = text2path(params["type"])
			selected_equipment[MECHA_UTILITY] -= removed_type
			return TRUE

		if("vend_ammo")
			var/new_ammo = text2path(params["type"])
			if(!ispath(new_ammo, /obj/item/mecha_ammo/vendable))
				return FALSE
			new new_ammo(get_turf(src))

///Actually deploys mech after a short delay to let people spot it coming down
/obj/machinery/computer/mech_builder/proc/deploy_mech()
	var/turf/assemble_turf = get_step(src, dir)
	var/obj/vehicle/sealed/mecha/combat/greyscale/mech = new(assemble_turf)
	mech.name = selected_name
	for(var/slot in selected_primary)
		var/limb_type = get_mech_limb(slot, selected_variants[slot])
		var/datum/mech_limb/limb = new limb_type()
		limb.update_colors(selected_primary[slot], selected_secondary[slot], selected_visor)
		limb.attach(mech, slot)
	if(selected_equipment[MECHA_L_ARM])
		var/new_type = selected_equipment[MECHA_L_ARM]
		var/obj/item/mecha_parts/mecha_equipment/weapon/new_gun = new new_type
		new_gun.attach(mech)
	if(selected_equipment[MECHA_R_ARM])
		var/new_type = selected_equipment[MECHA_R_ARM]
		var/obj/item/mecha_parts/mecha_equipment/weapon/new_gun = new new_type
		new_gun.attach(mech, TRUE)
	for(var/equipment in (selected_equipment[MECHA_POWER]|selected_equipment[MECHA_ARMOR]|selected_equipment[MECHA_UTILITY]))
		var/obj/item/mecha_parts/mecha_equipment/new_equip = new equipment
		new_equip.attach(mech)

	mech.pixel_y = 240
	animate(mech, time=4 SECONDS, pixel_y=initial(mech.pixel_y), easing=SINE_EASING|EASE_OUT)

	balloon_alert_to_viewers("Beep. Mecha ready for use.")
	playsound(src, 'sound/machines/chime.ogg', 30, 1)

///updates the current_stats data for the UI
/obj/machinery/computer/mech_builder/proc/update_stats(selected_part, old_bodytype, new_bodytype)
	var/old_type = get_mech_limb(selected_part, old_bodytype)
	var/new_type = get_mech_limb(selected_part, new_bodytype)
	var/datum/mech_limb/old_limb = new old_type(TRUE)
	var/datum/mech_limb/new_limb = new new_type(TRUE)
	switch(selected_part)
		if(MECH_GREY_HEAD)
			var/datum/mech_limb/head/head_limb = new_limb
			current_stats["accuracy"] = head_limb.accuracy_mod
			current_stats["light_mod"]= head_limb.light_range
		if(MECH_GREY_L_ARM)
			var/datum/mech_limb/arm/arm_limb = new_limb
			current_stats["left_scatter"] = arm_limb.scatter_mod
		if(MECH_GREY_R_ARM)
			var/datum/mech_limb/arm/arm_limb = new_limb
			current_stats["right_scatter"] = arm_limb.scatter_mod
		if(MECH_GREY_TORSO)
			var/datum/mech_limb/torso/torso_limb = new_limb
			var/obj/item/cell/cell_type = torso_limb.cell_type
			current_stats["power_max"] = initial(cell_type.maxcharge)

	current_stats["health"] = current_stats["health"] - old_limb.health_mod + new_limb.health_mod
	current_stats["slowdown"] = current_stats["slowdown"] - old_limb.slowdown_mod + new_limb.slowdown_mod
	for(var/armor_type in old_limb.soft_armor_mod)
		current_stats["armor"][armor_type] -= old_limb.soft_armor_mod[armor_type]
	for(var/armor_type in new_limb.soft_armor_mod)
		current_stats["armor"][armor_type] += new_limb.soft_armor_mod[armor_type]

///Updates the displayed mech preview dummy in the UI
/obj/machinery/computer/mech_builder/proc/update_ui_view()
	var/new_overlays = list()
	for(var/slot in selected_variants)
		var/datum/mech_limb/head/typepath = get_mech_limb(slot, selected_variants[slot])
		if(slot == MECH_GREY_L_ARM || slot == MECH_GREY_R_ARM)
			var/iconstate = "left"
			if(slot == MECH_GREY_R_ARM)
				iconstate = "right"
			new_overlays += iconstate2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.greyscale_type), selected_primary[slot] + selected_secondary[slot]), iconstate)
			continue
		new_overlays += icon2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.greyscale_type), selected_primary[slot] + selected_secondary[slot]))
		if(slot == MECH_GREY_HEAD)
			new_overlays += icon2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.visor_config), selected_visor))
	mech_view.overlays = new_overlays
