/particles/mecha_smoke
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 200
	count = 1000
	spawning = 3
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	velocity = list(0, 0.3, 0)
	position = list(5, 32, 0)
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, 0.95)
	grow = 0.05


/obj/vehicle/sealed/mecha/combat/greyscale
	name = "Should not be visible"
	icon_state = "greyscale"
	layer = ABOVE_ALL_MOB_LAYER
	mech_type = EXOSUIT_MODULE_GREYSCALE
	pixel_x = -16
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	move_delay = 3
	max_equip_by_category = MECH_GREYSCALE_MAX_EQUIP
	internal_damage_threshold = 15
	internal_damage_probability = 5
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_SHORT_CIRCUIT
	mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_HEADLIGHTS | MECHA_SKILL_LOCKED
	/// keyed list. values are types at init, otherwise instances of mecha limbs, order is layer order as well
	var/list/datum/mech_limb/limbs = list(
		MECH_GREY_TORSO = null,
		MECH_GREY_HEAD = null,
		MECH_GREY_LEGS = null,
		MECH_GREY_R_ARM = null,
		MECH_GREY_L_ARM = null,
	)
	///left particle smoke holder
	var/obj/effect/abstract/particle_holder/holder_left
	///right particle smoke holder
	var/obj/effect/abstract/particle_holder/holder_right

/obj/vehicle/sealed/mecha/combat/greyscale/Initialize(mapload)
	holder_left = new(src, /particles/mecha_smoke)
	holder_left.layer = layer+0.001
	holder_right = new(src, /particles/mecha_smoke)
	holder_right.layer = layer+0.001
	. = ..()

	for(var/key in limbs)
		if(!limbs[key])
			continue
		var/new_limb_type = limbs[key]
		limbs[key] = null
		var/datum/mech_limb/limb = new new_limb_type
		limb.attach(src, key)

/obj/vehicle/sealed/mecha/combat/greyscale/Destroy()
	var/obj/effect/temp_visual/explosion/explosion = new /obj/effect/temp_visual/explosion(loc, 4, LIGHT_COLOR_LAVA, FALSE, TRUE)
	explosion.pixel_x = 16
	for(var/key in limbs)
		var/datum/mech_limb/limb = limbs[key]
		limb?.detach(src)
	return ..()


/obj/vehicle/sealed/mecha/combat/greyscale/mob_try_enter(mob/M)
	if((mecha_flags & MECHA_SKILL_LOCKED) && M.skills.getRating(SKILL_LARGE_VEHICLE) < SKILL_LARGE_VEHICLE_TRAINED)
		balloon_alert(M, "You don't know how to pilot this")
		return FALSE
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/update_icon()
	. = ..()
	if(QDELING(src))
		return
	var/broken_percent = obj_integrity/max_integrity
	var/inverted_percent = 1-broken_percent
	holder_left.particles.spawning = 3 * inverted_percent
	switch(broken_percent)
		if(-INFINITY to 0.25)
			holder_left.particles.icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
		if(0.25 to 0.5)
			holder_left.particles.icon_state = list("smoke_1" = inverted_percent, "smoke_2" = inverted_percent, "smoke_3" = inverted_percent, "steam_1" = broken_percent, "steam_2" = broken_percent, "steam_3" = broken_percent)
		if(0.5 to 0.75)
			holder_left.particles.icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
		else
			holder_left.particles.spawning = 0
	holder_right.particles.icon_state = holder_left.particles.icon_state
	holder_right.particles.spawning = holder_left.particles.spawning
	//end of shared code
	if(dir & WEST)
		holder_left.particles.position = list(30, 32, 0)
		holder_right.particles.position = list(30, 37, 0)
		holder_left.layer = layer+0.002
	else if(dir & EAST)
		holder_left.particles.position = list(5, 32, 0)
		holder_right.particles.position = list(5, 37, 0)
		holder_left.layer = layer+0.001
	else
		holder_left.particles.position = list(5, 32, 0)
		holder_right.particles.position = list(30, 32, 0)
		holder_left.layer = layer+0.001

/obj/vehicle/sealed/mecha/combat/greyscale/update_overlays()
	. = ..()
	var/list/render_order
	//spriter bs requires this code
	switch(dir)
		if(EAST)
			render_order = list(MECH_GREY_TORSO, MECH_GREY_HEAD, MECH_GREY_LEGS, MECH_GREY_L_ARM, MECHA_L_ARM, MECH_GREY_R_ARM, MECHA_R_ARM)
		if(WEST)
			render_order = list(MECH_GREY_TORSO, MECH_GREY_HEAD, MECH_GREY_LEGS, MECH_GREY_R_ARM, MECHA_R_ARM, MECH_GREY_L_ARM, MECHA_L_ARM)
		else
			render_order = list(MECH_GREY_TORSO, MECH_GREY_HEAD, MECH_GREY_LEGS, MECH_GREY_R_ARM, MECH_GREY_L_ARM, MECHA_L_ARM, MECHA_R_ARM)

	for(var/key in render_order)
		if(key == MECHA_R_ARM)
			var/obj/item/mecha_parts/mecha_equipment/right_gun = equip_by_category[MECHA_R_ARM]
			if(right_gun)
				. += image('icons/mecha/mech_gun_overlays.dmi', right_gun.icon_state + "_right", pixel_x=-32)
			continue
		if(key == MECHA_L_ARM)
			var/obj/item/mecha_parts/mecha_equipment/left_gun = equip_by_category[MECHA_L_ARM]
			if(left_gun)
				. += image('icons/mecha/mech_gun_overlays.dmi', left_gun.icon_state + "_left", pixel_x=-32)
			continue

		if(!istype(limbs[key], /datum/mech_limb))
			continue
		var/datum/mech_limb/limb = limbs[key]
		. += limb.get_overlays()

/obj/vehicle/sealed/mecha/combat/greyscale/setDir(newdir)
	. = ..()
	update_icon() //when available pass UPDATE_OVERLAYS since this is just for layering order

/obj/vehicle/sealed/mecha/combat/greyscale/recon
	name = "Recon Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/recon,
		MECH_GREY_HEAD = /datum/mech_limb/head/recon,
		MECH_GREY_LEGS = /datum/mech_limb/legs/recon,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/recon,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/recon,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill
	mecha_flags = ADDING_ACCESS_POSSIBLE|CANSTRAFE|IS_ENCLOSED|HAS_HEADLIGHTS

/obj/vehicle/sealed/mecha/combat/greyscale/assault
	name = "Assault Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/assault,
		MECH_GREY_HEAD = /datum/mech_limb/head/assault,
		MECH_GREY_LEGS = /datum/mech_limb/legs/assault,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/assault,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/assault,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/assault/noskill
	mecha_flags = ADDING_ACCESS_POSSIBLE|CANSTRAFE|IS_ENCLOSED|HAS_HEADLIGHTS

/obj/vehicle/sealed/mecha/combat/greyscale/vanguard
	name = "Vanguard Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/vanguard,
		MECH_GREY_HEAD = /datum/mech_limb/head/vanguard,
		MECH_GREY_LEGS = /datum/mech_limb/legs/vanguard,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/vanguard,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/vanguard,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill
	mecha_flags = ADDING_ACCESS_POSSIBLE|CANSTRAFE|IS_ENCLOSED|HAS_HEADLIGHTS
