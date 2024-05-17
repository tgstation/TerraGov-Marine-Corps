/// A preview of the mech for the UI
/atom/movable/screen/mech_view
	name = "mechview"
	del_on_map_removal = FALSE
	layer = OBJ_LAYER
	plane = GAME_PLANE

	/// The body that is displayed
	var/obj/vehicle/sealed/mecha/owner
	///list of plane masters to apply to owners
	var/list/plane_masters = list()

/atom/movable/screen/mech_view/Initialize(mapload, datum/hud/hud_owner, obj/vehicle/sealed/mecha/newowner)
	. = ..()
	owner = newowner
	assigned_map = "mech_view_[REF(owner)]"
	set_position(1, 1)
	for(var/plane_master_type in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		var/atom/movable/screen/plane_master/plane_master = new plane_master_type()
		plane_master.screen_loc = "[assigned_map]:CENTER"
		plane_masters += plane_master

/atom/movable/screen/mech_view/Destroy()
	QDEL_LIST(plane_masters)
	owner = null
	return ..()

/obj/vehicle/sealed/mecha/ui_close(mob/user)
	. = ..()
	user.client?.screen -= ui_view.plane_masters
	user.client?.clear_map(ui_view.assigned_map)

/obj/vehicle/sealed/mecha/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name, ui_x, ui_y)
		ui.open()
		user.client?.screen |= ui_view.plane_masters
		user.client?.register_map_obj(ui_view)

/obj/vehicle/sealed/mecha/ui_status(mob/user)
	if(contains(user))
		return UI_INTERACTIVE
	return min(
		ui_status_user_is_abled(user, src),
		ui_status_user_has_free_hands(user, src),
		ui_status_user_is_advanced_tool_user(user),
		ui_status_only_living(user),
		max(
			ui_status_user_is_adjacent(user, src),
		)
	)

/obj/vehicle/sealed/mecha/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/mechaarmor))

/obj/vehicle/sealed/mecha/ui_static_data(mob/user)
	var/list/data = list()
	data["cabin_dangerous_highpressure"] = WARNING_HIGH_PRESSURE
	data["mineral_material_amount"] = MINERAL_MATERIAL_AMOUNT
	//map of relevant flags to check tgui side, not every flag needs to be here
	data["mechflag_keys"] = list(
		"LIGHTS_ON" = LIGHTS_ON,
		"HAS_HEADLIGHTS" = HAS_HEADLIGHTS,
	)
	data["internal_damage_keys"] = list(
		"MECHA_INT_FIRE" = MECHA_INT_FIRE,
		"MECHA_INT_CONTROL_LOST" = MECHA_INT_CONTROL_LOST,
	)
	data["mech_electronics"] = list(
		"minfreq" = MIN_FREE_FREQ,
		"maxfreq" = MAX_FREE_FREQ,
	)
	return data

/obj/vehicle/sealed/mecha/ui_data(mob/user)
	var/list/data = list()
	var/isoperator = (user in occupants) //maintenance mode outside of mech
	data["isoperator"] = isoperator
	if(!isoperator)
		data["name"] = name
		data["mecha_flags"] = mecha_flags
		data["cell"] = cell?.name
		for(var/code in operation_req_access)
			data["operation_req_access"] += list(list("name" = get_access_desc(code), "number" = code))
		if(!isliving(user))
			return data
		var/mob/living/living_user = user
		var/obj/item/card/id/card = living_user.get_idcard(TRUE)
		if(!card)
			return data
		for(var/idcode in card.access)
			if(idcode in operation_req_access)
				continue
			var/accessname = get_access_desc(idcode)
			if(!accessname)
				continue //there's some strange access without a name
			data["idcard_access"] += list(list("name" = accessname, "number" = idcode))
		return data
	ui_view.appearance = appearance
	data["name"] = name
	data["integrity"] = obj_integrity/max_integrity
	data["power_level"] = cell?.charge
	data["power_max"] = cell?.maxcharge
	data["mecha_flags"] = mecha_flags
	data["internal_damage"] = internal_damage
	data["dna_lock"] = dna_lock
	data["weapons_safety"] = weapons_safety
	data["mech_view"] = ui_view.assigned_map
	if(radio)
		data["mech_electronics"] = list(
			"microphone" = radio.broadcasting,
			"speaker" = radio.listening,
			"frequency" = radio.frequency,
		)
	if(equip_by_category[MECHA_L_ARM])
		var/obj/item/mecha_parts/mecha_equipment/l_gun = equip_by_category[MECHA_L_ARM]
		var/isballisticweapon = istype(l_gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic)
		data["left_arm_weapon"] = list(
			"name" = l_gun.name,
			"desc" = l_gun.desc,
			"ref" = REF(l_gun),
			"integrity" = (l_gun.obj_integrity/l_gun.max_integrity),
			"isballisticweapon" = isballisticweapon,
			"energy_per_use" = l_gun.energy_drain,
			"snowflake" = l_gun.get_snowflake_data(),
		)
		if(isballisticweapon)
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/weapon = l_gun
			data["left_arm_weapon"] += list(
				"projectiles" = weapon.projectiles,
				"max_magazine" = initial(weapon.projectiles),
				"projectiles_cache" = weapon.projectiles_cache,
				"projectiles_cache_max" = weapon.projectiles_cache_max,
				"disabledreload" = weapon.disabledreload,
				"ammo_type" = weapon.ammo_type,
			)
	if(equip_by_category[MECHA_R_ARM])
		var/obj/item/mecha_parts/mecha_equipment/r_gun = equip_by_category[MECHA_R_ARM]
		var/isballisticweapon = istype(r_gun, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic)
		data["right_arm_weapon"] = list(
			"name" = r_gun.name,
			"desc" = r_gun.desc,
			"ref" = REF(r_gun),
			"integrity" = (r_gun.obj_integrity/r_gun.max_integrity),
			"isballisticweapon" = isballisticweapon,
			"energy_per_use" = r_gun.energy_drain,
			"snowflake" = r_gun.get_snowflake_data(),
		)
		if(isballisticweapon)
			var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/weapon = r_gun
			data["right_arm_weapon"] += list(
				"projectiles" = weapon.projectiles,
				"max_magazine" = initial(weapon.projectiles),
				"projectiles_cache" = weapon.projectiles_cache,
				"projectiles_cache_max" = weapon.projectiles_cache_max,
				"disabledreload" = weapon.disabledreload,
				"ammo_type" = weapon.ammo_type,
			)
	data["mech_equipment"] = list("utility" = list(), "power" = list(), "armor" = list())
	for(var/obj/item/mecha_parts/mecha_equipment/utility AS in equip_by_category[MECHA_UTILITY])
		data["mech_equipment"]["utility"] += list(list(
			"name" = utility.name,
			"activated" = utility.activated,
			"snowflake" = utility.get_snowflake_data(),
			"ref" = REF(utility),
		))
	for(var/obj/item/mecha_parts/mecha_equipment/power AS in equip_by_category[MECHA_POWER])
		data["mech_equipment"]["power"] += list(list(
			"name" = power.name,
			"activated" = power.activated,
			"snowflake" = power.get_snowflake_data(),
			"ref" = REF(power),
		))
	for(var/obj/item/mecha_parts/mecha_equipment/armor/armor AS in equip_by_category[MECHA_ARMOR])
		data["mech_equipment"]["armor"] += list(list(
			"protect_name" = armor.protect_name,
			"iconstate_name" = armor.iconstate_name,
			"ref" = REF(armor),
		))
	return data

/obj/vehicle/sealed/mecha/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	//usr is in occupants
	switch(action)
		if("changename")
			var/userinput = tgui_input_text(usr, "Choose a new exosuit name", "Rename exosuit", max_length = MAX_NAME_LEN)
			if(!userinput)
				return
			if(is_ic_filtered(userinput) || NON_ASCII_CHECK(userinput))
				tgui_alert(usr, "You cannot set a name that contains a word prohibited in IC chat!")
				return
			name = userinput
		if("toggle_safety")
			set_safety(usr)
			return
		if("dna_lock")
			var/mob/living/carbon/user = usr
			if(!istype(user))
				to_chat(user, "[icon2html(src, occupants)][span_notice("You can't create a DNA lock with no DNA!.")]")
				return
			dna_lock = md5(REF(user))
			to_chat(user, "[icon2html(src, occupants)][span_notice("You feel a prick as the needle takes your DNA sample.")]")
		if("reset_dna")
			dna_lock = null
		if("view_dna")
			tgui_alert(usr, "Enzymes detected: " + dna_lock)
			return FALSE
		if("toggle_microphone")
			radio.broadcasting = !radio.broadcasting
		if("toggle_speaker")
			radio.listening = !radio.listening
		if("set_frequency")
			radio.set_frequency(sanitize_frequency(params["new_frequency"], radio.freerange))
		if("repair_int_damage")
			ui.close() //if doing this you're likely want to watch for bad people so close the UI
			try_repair_int_damage(usr, params["flag"])
			return FALSE
		if("equip_act")
			var/obj/item/mecha_parts/mecha_equipment/gear = locate(params["ref"]) in flat_equipment
			return gear?.ui_act(params["gear_action"], params, ui, state)
	return TRUE
