#define MECH_VANGUARD "Vanguard"
#define MECH_RECON "Recon"
#define MECH_ASSAULT "Assault"

#define MECH_GREY_R_ARM "R_ARM"
#define MECH_GREY_L_ARM "L_ARM"
#define MECH_GREY_LEGS "LEG"
#define MECH_GREY_TORSO "CHEST"
#define MECH_GREY_HEAD "HEAD"

#define MECH_GREY_PRIMARY_DEFAULT ARMOR_PALETTE_DRAB
#define MECH_GREY_SECONDARY_DEFAULT ARMOR_PALETTE_BLACK
#define MECH_GREY_VISOR_DEFAULT VISOR_PALETTE_GOLD


GLOBAL_LIST_INIT(mech_bodytypes, list(MECH_RECON, MECH_ASSAULT, MECH_VANGUARD))

/**
 *
 * TODODODODOD
 * tgui
 * * show data
 * * centerpiece
 * selecting type of limb
 * ask kuro about center piece part
 */




/datum/mech_limb
	///category that this limb will be displayed in
	var/category = "NONE" // tivi todo del
	///when attached the mechs health is modified by this amount
	var/health_mod = 0
	///when attached the mechs armor is modified by this amount
	var/list/soft_armor_mod = list(MELEE = 20, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 0, FIRE = 100, ACID = 100)
	///when attached the mechs slowdown is modified by this amount
	var/slowdown_mod = 0
	///typepath for greyscale icon generation
	var/greyscale_type = /datum/greyscale_config
	/// 2 or 3 entry list of primary, secondary, visor color to use
	var/list/colors = list(MECH_GREY_PRIMARY_DEFAULT, MECH_GREY_SECONDARY_DEFAULT, MECH_GREY_VISOR_DEFAULT)
	///overlay icon to generate
	var/icon/overlay_icon

/datum/mech_limb/New()
	..()
	update_colors(arglist(colors)) // tivi todo


/datum/mech_limb/proc/update_colors(color_one, color_two, ...)
	if(!color_one && !color_two)
		CRASH("update_colors did not recieve any colors")
	var/list/colors_to_set = list()
	if(color_one && !color_two)
		colors_to_set += color_one
		colors_to_set += colors[2]
	else if(!color_one && color_two)
		colors_to_set += colors[1]
		colors_to_set += color_two
	else
		colors_to_set = list(color_one, color_two)
	colors = colors_to_set
	var/list/splitcolors = list()
	for(var/color in colors_to_set)
		splitcolors += color
	overlay_icon = SSgreyscale.GetColoredIconByType(greyscale_type, splitcolors)

/**
 * proc to call to add this limb to the mech object
 * Args:
 * * attached: mech we are attaching to
 * * slot: slot we are being attached to mostly relevant for r/l arm
 */
/datum/mech_limb/proc/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	SHOULD_CALL_PARENT(TRUE)
	if(!slot)
		CRASH("attaching with no slot")
	if(istype(attached.limbs[slot], /datum/mech_limb)) // tivi todo exact type
		attached.limbs[slot].detach(attached)
	attached.limbs[slot] = src
	attached.max_integrity += health_mod
	attached.obj_integrity += health_mod
	attached.move_delay += slowdown_mod

	attached.soft_armor = attached.soft_armor.modifyRating(arglist(soft_armor_mod))
	attached.update_icon()

/**
 * proc to call to remove this limb to the mech object
 * Args:
 * * attached: mech we are attaching to
 */
/datum/mech_limb/proc/detach(obj/vehicle/sealed/mecha/combat/greyscale/detached)
	SHOULD_CALL_PARENT(TRUE)
	for(var/slot in detached.limbs)
		if(detached.limbs[slot] != src)
			continue
		detached.limbs[slot] = null
	detached.max_integrity -= health_mod
	detached.obj_integrity -= health_mod
	detached.move_delay -= slowdown_mod

	var/list/removed_armor = soft_armor_mod.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type]
	detached.soft_armor = detached.soft_armor.modifyRating(arglist(removed_armor))
	detached.update_icon()

/// Returns an overlay or list of overlays to use on the mech
/datum/mech_limb/proc/get_overlays()
	return icon2appearance(overlay_icon)

/datum/mech_limb/arm
	health_mod = 200
	var/scatter_mod = 0
	var/arm_slot

/datum/mech_limb/arm/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	arm_slot = slot
	return ..()

/datum/mech_limb/arm/detach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	arm_slot = null
	return ..()

/datum/mech_limb/arm/get_overlays()
	if(arm_slot == MECH_GREY_R_ARM)
		return image(overlay_icon, icon_state = "right")
	return image(overlay_icon, icon_state = "left")

/datum/mech_limb/arm/recon
	greyscale_type = /datum/greyscale_config/mech_recon/arms

/datum/mech_limb/arm/assault
	greyscale_type = /datum/greyscale_config/mech_assault/arms

/datum/mech_limb/arm/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/arms

/datum/mech_limb/legs
	health_mod = 300

/datum/mech_limb/legs/recon
	greyscale_type = /datum/greyscale_config/mech_recon/legs

/datum/mech_limb/legs/assault
	greyscale_type = /datum/greyscale_config/mech_assault/legs

/datum/mech_limb/legs/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/legs

/datum/mech_limb/head
	health_mod = 200
	var/visor_config
	var/icon/visor_icon
	var/light_range = 5

/datum/mech_limb/head/attach(obj/vehicle/sealed/mecha/combat/greyscale/attached, slot)
	. = ..()
	attached.light_range = light_range

/datum/mech_limb/head/detach(obj/vehicle/sealed/mecha/combat/greyscale/detached)
	. = ..()
	detached.light_range = initial(detached.light_range)

/datum/mech_limb/head/update_colors(color_one, color_two, visor_color)
	. = ..()
	visor_icon = SSgreyscale.GetColoredIconByType(visor_config, visor_color)

/datum/mech_limb/head/get_overlays()
	return list(icon2appearance(overlay_icon), icon2appearance(visor_icon), emissive_appearance(visor_icon))

/datum/mech_limb/head/recon
	greyscale_type = /datum/greyscale_config/mech_recon/head
	visor_config = /datum/greyscale_config/mech_recon/visor

/datum/mech_limb/head/assault
	greyscale_type = /datum/greyscale_config/mech_assault/head
	visor_config = /datum/greyscale_config/mech_assault/visor

/datum/mech_limb/head/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/head
	visor_config = /datum/greyscale_config/mech_vanguard/visor

/datum/mech_limb/torso
	health_mod = 600

/datum/mech_limb/torso/recon
	greyscale_type = /datum/greyscale_config/mech_recon/torso

/datum/mech_limb/torso/assault
	greyscale_type = /datum/greyscale_config/mech_assault/torso

/datum/mech_limb/torso/vanguard
	greyscale_type = /datum/greyscale_config/mech_vanguard/torso

/obj/machinery/computer/mech_builder
	name = "mech computer"
	interaction_flags = INTERACT_MACHINE_TGUI
	var/static/list/available_colors = list(
		"Default" = list(
			"Drab" = ARMOR_PALETTE_DRAB,
			"Brown" = ARMOR_PALETTE_BROWN,
			"Snow" = ARMOR_PALETTE_SNOW,
			"Desert" = ARMOR_PALETTE_DESERT,
			"Black" = ARMOR_PALETTE_BLACK,
			"Grey" = ARMOR_PALETTE_GREY,
			"Gun Metal" = ARMOR_PALETTE_GUN_METAL,
			"Night Slate" = ARMOR_PALETTE_NIGHT_SLATE,
			"Fall" = ARMOR_PALETTE_FALL,
		),
		"Red" = list(
			"Dark Red" = ARMOR_PALETTE_RED,
			"Bronze Red" = ARMOR_PALETTE_BRONZE_RED,
			"Red" = ARMOR_PALETTE_LIGHT_RED,
			"Blood Red" = ARMOR_PALETTE_BLOOD_RED,
		),
		"Green" = list(
			"Green" = ARMOR_PALETTE_GREEN,
			"Emerald" = ARMOR_PALETTE_EMERALD,
			"Lime" = ARMOR_PALETTE_LIME,
			"Mint" = ARMOR_PALETTE_MINT,
			"Jade" = ARMOR_PALETTE_JADE,
			"Leaf" = ARMOR_PALETTE_LEAF,
			"Forest" = ARMOR_PALETTE_FOREST,
			"Smoked Green" = ARMOR_PALETTE_SMOKED_GREEN,
		),
		"Purple" = list(
			"Purple" = ARMOR_PALETTE_PURPLE,
			"Lavander" = ARMOR_PALETTE_LAVANDER,
			"Lilac" = ARMOR_PALETTE_LILAC,
			"Iris Purple" = ARMOR_PALETTE_IRIS_PURPLE,
			"Orchid" = ARMOR_PALETTE_ORCHID,
			"Grape" = ARMOR_PALETTE_GRAPE,
		),
		"Blue" = list(
			"Dark Blue" = ARMOR_PALETTE_BLUE,
			"Blue" = ARMOR_PALETTE_LIGHT_BLUE,
			"Cottonwood" = ARMOR_PALETTE_COTTONWOOD,
			"Aqua" = ARMOR_PALETTE_AQUA,
			"Cerulean" = ARMOR_PALETTE_CERULEAN,
			"Sea Blue" = ARMOR_PALETTE_SEA_BLUE,
			"Cloud" = ARMOR_PALETTE_CLOUD,
		),
		"Yellow" = list(
			"Gold" = ARMOR_PALETTE_YELLOW,
			"Yellow" = ARMOR_PALETTE_LIGHT_YELLOW,
			"Angelic Gold" = ARMOR_PALETTE_ANGELIC,
			"Honey" = ARMOR_PALETTE_HONEY,
		),
		"Orange" = list(
			"Orange" = ARMOR_PALETTE_ORANGE,
			"Beige" = ARMOR_PALETTE_BEIGE,
			"Earth" = ARMOR_PALETTE_EARTH,
		),
		"Pink" = list(
			"Salmon" = ARMOR_PALETTE_SALMON_PINK,
			"Magenta" = ARMOR_PALETTE_MAGENTA_PINK,
			"Sakura" = ARMOR_PALETTE_SAKURA,
		),
	)
	var/static/list/available_visor_colors = list(
		"Default" = list(
			"Gold" = VISOR_PALETTE_GOLD,
			"Silver" = VISOR_PALETTE_SILVER,
			"Black" = VISOR_PALETTE_BLACK,
		),
		"Red" = list(
			"Red" = VISOR_PALETTE_RED,
		),
		"Green" = list(
			"Green" = VISOR_PALETTE_GREEN,
		),
		"Purple" = list(
			"Purple" = VISOR_PALETTE_PURPLE,
			"Magenta" = VISOR_PALETTE_MAGENTA,
		),
		"Blue" = list(
			"Blue" = VISOR_PALETTE_BLUE,
			"Ice Blue" = VISOR_PALETTE_ICE,
			"Sky Blue" = VISOR_PALETTE_SKY_BLUE,
		),
		"Yellow" = list(
			"Honey" = VISOR_PALETTE_HONEY,
			"Metallic Bronze" = VISOR_PALETTE_METALLIC_BRONZE,
		),
		"Orange" = list(
			"Orange" = VISOR_PALETTE_ORANGE,
		),
		"Pink" = list(
			"Salmon" = VISOR_PALETTE_SALMON,
			"Pearl Pink" = VISOR_PALETTE_PEARL_PINK,
		),
	)

	// string names of string not acctual color
	var/list/selected_primary = list(
		MECH_GREY_TORSO = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_HEAD = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_LEGS = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_R_ARM = MECH_GREY_PRIMARY_DEFAULT,
		MECH_GREY_L_ARM = MECH_GREY_PRIMARY_DEFAULT,
	)
	var/list/selected_secondary = list(
		MECH_GREY_TORSO = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_HEAD = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_LEGS = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_R_ARM = MECH_GREY_SECONDARY_DEFAULT,
		MECH_GREY_L_ARM = MECH_GREY_SECONDARY_DEFAULT,
	)
	var/selected_visor = MECH_GREY_VISOR_DEFAULT
	var/selected_variants = list(
		MECH_GREY_TORSO = MECH_ASSAULT,
		MECH_GREY_HEAD = MECH_ASSAULT,
		MECH_GREY_LEGS = MECH_ASSAULT,
		MECH_GREY_R_ARM = MECH_ASSAULT,
		MECH_GREY_L_ARM = MECH_ASSAULT,
	)
	var/selected_name = "DEFAULT" // tivi todo implement?
	var/obj/screen/mech_builder_view/mech_view // tivi todo copypaste from mech
	var/obj/screen/mech_builder_view/mech_view_east
	var/obj/screen/mech_builder_view/mech_view_west
	var/currently_assembling = FALSE

/obj/screen/mech_builder_view
	name = "mech_preview"
	del_on_map_removal = FALSE
	layer = OBJ_LAYER
	plane = GAME_PLANE
	///list of plane masters to apply to owners
	var/list/plane_masters = list()

/obj/screen/mech_builder_view/Initialize(mapload)
	. = ..()
	assigned_map = "mech_preview_[REF(src)]"
	set_position(1, 1)
	for(var/plane_master_type in subtypesof(/obj/screen/plane_master) - /obj/screen/plane_master/blackness)
		var/obj/screen/plane_master/plane_master = new plane_master_type()
		plane_master.screen_loc = "[assigned_map]:CENTER"
		plane_masters += plane_master

/obj/screen/mech_builder_view/Destroy()
	QDEL_LIST(plane_masters)
	return ..()

/obj/machinery/computer/mech_builder/Initialize()
	. = ..()
	mech_view = new
	mech_view_east = new
	mech_view_east.setDir(EAST)
	mech_view_west = new
	mech_view_west.setDir(WEST)
	update_ui_view()

/obj/machinery/computer/mech_builder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "MechVendor", name, 1600, 630)
	ui.open()
	user.client?.screen |= mech_view.plane_masters
	user.client?.register_map_obj(mech_view)
	user.client?.screen |= mech_view_east.plane_masters
	user.client?.register_map_obj(mech_view_east)
	user.client?.screen |= mech_view_west.plane_masters
	user.client?.register_map_obj(mech_view_west)

/obj/machinery/computer/mech_builder/ui_close(mob/user)
	. = ..()
	user.client?.screen -= mech_view.plane_masters
	user.client?.clear_map(mech_view.assigned_map)
	user.client?.screen -= mech_view_east.plane_masters
	user.client?.clear_map(mech_view_east.assigned_map)
	user.client?.screen -= mech_view_west.plane_masters
	user.client?.clear_map(mech_view_west.assigned_map)

/obj/machinery/computer/mech_builder/ui_static_data(mob/user)
	var/list/data = list()
	data["mech_view"] = mech_view.assigned_map
	data["mech_view_east"] = mech_view_east.assigned_map
	data["mech_view_west"] = mech_view_west.assigned_map
	data["colors"] = available_colors
	data["visor_colors"] = available_visor_colors
	data["bodypart_names"] = GLOB.mech_bodytypes
	return data

/obj/machinery/computer/mech_builder/ui_data(mob/user)
	var/list/data = list()
	data["selected_primary"] = selected_primary
	data["selected_secondary"] = selected_secondary
	data["selected_visor"] = selected_visor
	data["selected_variants"] = selected_variants
	data["selected_name"] = selected_name
	return data

/obj/machinery/computer/mech_builder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state) // tivi todo weapons
	. = ..()
	if(.)
		return

	if(currently_assembling)
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
				return TRUE
			return FALSE

		if("set_secondary")
			var/new_color_name = params["new_color"]
			for(var/key in available_colors)
				if(!(new_color_name in available_colors[key]))
					continue
				selected_secondary[selected_part] = available_colors[key][new_color_name]
				return TRUE
			return FALSE

		if("set_visor")
			var/new_color_name = params["new_color"]
			for(var/key in available_visor_colors)
				if(!(new_color_name in available_visor_colors[key]))
					continue
				selected_visor = available_visor_colors[key][new_color_name]
				return TRUE
			return FALSE

		if("set_bodypart")
			var/new_bodytype = params["new_bodytype"]
			if(!(new_bodytype in GLOB.mech_bodytypes))
				return FALSE
			selected_variants[selected_part] = new_bodytype
			update_ui_view()
			return TRUE

		if("assemble")
			for(var/key in selected_primary)
				if(isnull(selected_primary[key]))
					return FALSE
			for(var/key in selected_primary)
				if(isnull(selected_primary[key]))
					return FALSE
			if(isnull(selected_visor))
				return FALSE
			currently_assembling = TRUE
			addtimer(CALLBACK(src, .proc/deploy_mech), 3 SECONDS) // tivi todo special effects
			ui.close()
			return FALSE

/obj/machinery/computer/mech_builder/proc/deploy_mech()
	var/obj/vehicle/sealed/mecha/combat/greyscale/mech = new(get_turf(src))
	for(var/slot in selected_primary)
		var/limb_type = get_mech_limb(slot, selected_variants[slot])
		var/datum/mech_limb/limb = new limb_type()
		limb.update_colors(selected_primary[slot], selected_secondary[slot], selected_visor) // tivi todo visor colors
		limb.attach(mech, slot)
	currently_assembling = FALSE

/obj/machinery/computer/mech_builder/proc/update_ui_view()
	var/default_colors = MECH_GREY_PRIMARY_DEFAULT + MECH_GREY_SECONDARY_DEFAULT
	var/default_visor = MECH_GREY_VISOR_DEFAULT
	var/new_overlays = list()
	for(var/slot in selected_variants)
		var/datum/mech_limb/head/typepath = get_mech_limb(slot, selected_variants[slot])
		if(slot == MECH_GREY_L_ARM || slot == MECH_GREY_R_ARM)
			var/iconstate = "left"
			if(slot == MECH_GREY_R_ARM)
				iconstate = "right"
			new_overlays += image(SSgreyscale.GetColoredIconByType(initial(typepath.greyscale_type), default_colors), icon_state=iconstate)
		else
			new_overlays += icon2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.greyscale_type), default_colors))
		if(slot == SLOT_HEAD)
			new_overlays += SSgreyscale.GetColoredIconByType(initial(typepath.visor_config), default_visor)
	mech_view.overlays = new_overlays
	mech_view_east.appearance = mech_view.appearance
	mech_view_west.appearance = mech_view.appearance

/proc/get_mech_limb(slot, mech_type)
	switch(slot)
		if(MECH_GREY_HEAD)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/head/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/head/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/head/vanguard
		if(MECH_GREY_L_ARM, MECH_GREY_R_ARM)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/arm/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/arm/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/arm/vanguard
		if(MECH_GREY_TORSO)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/torso/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/torso/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/torso/vanguard
		if(MECH_GREY_LEGS)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/legs/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/legs/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/legs/vanguard
	CRASH("Error getting mech type: [slot], [mech_type]")
