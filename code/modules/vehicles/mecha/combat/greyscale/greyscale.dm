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
	soft_armor = list(MELEE = 25, BULLET = 75, FIRE = 25, BOMB = 50, LASER = 40, ENERGY = 40, ACID = 30, BIO = 100)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 1, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1)
	step_energy_drain = 0
	move_delay = 3
	max_equip_by_category = MECH_GREYSCALE_MAX_EQUIP
	internal_damage_threshold = 15
	internal_damage_probability = 5
	possible_int_damage = MECHA_INT_FIRE|MECHA_INT_SHORT_CIRCUIT
	mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_HEADLIGHTS | MECHA_SKILL_LOCKED | MECHA_SPIN_WHEN_NO_ANGLE | OMNIDIRECTIONAL_ATTACKS | QUIET_TURNS
	explosion_block = 2
	pivot_step = TRUE
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
	/// Stores the time at which we last moved.
	var/last_mousedown_time
	/// Stores the direction of the last movement made.
	var/last_move_dir
	/// The timing for activating a dash by double tapping a movement key.
	var/double_tap_timing = 0.18 SECONDS
	/// total wight our limbs and equipment contribute. max determined by MECH_GREY_LEGS limb
	var/weight = 0

/obj/vehicle/sealed/mecha/combat/greyscale/Initialize(mapload)
	holder_left = new(src, /particles/mecha_smoke)
	holder_left.layer = layer+0.001
	holder_right = new(src, /particles/mecha_smoke)
	holder_right.layer = layer+0.001
	. = ..()

	set_jump_component()

	for(var/key in limbs)
		if(!limbs[key])
			continue
		var/new_limb_type = limbs[key]
		limbs[key] = null
		var/datum/mech_limb/limb = new new_limb_type
		limb.attach(src, key)

/obj/vehicle/sealed/mecha/combat/greyscale/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	playsound(get_turf(src), SFX_EXPLOSION_MED, 100, TRUE) //destroy sound is normally very quiet
	new /obj/effect/temp_visual/explosion(loc, 4, LIGHT_COLOR_LAVA, FALSE, TRUE)
	for(var/mob/living/nearby_mob AS in cheap_get_living_near(src, 5))
		shake_camera(nearby_mob, 4, 1)
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/Destroy()
	for(var/key in limbs)
		var/datum/mech_limb/limb = limbs[key]
		if(limb)
			limb.detach(src)
			qdel(limb)
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/examine(mob/user)
	. = ..()
	for(var/limb_key in limbs)
		if(limb_key == MECH_GREY_TORSO)
			continue
		var/datum/mech_limb/limb = limbs[limb_key]
		. += "It's " + limb.display_name + " has " + "[(limb.part_health / initial(limb.part_health))*100]" + "% integrity."

/obj/vehicle/sealed/mecha/combat/greyscale/fire_act(burn_level)
	. = ..()
	take_damage(burn_level / 2, BURN, FIRE)

/obj/vehicle/sealed/mecha/combat/greyscale/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_overload_mode)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/repairpack)

/obj/vehicle/sealed/mecha/combat/greyscale/mob_try_enter(mob/entering_mob, mob/user, loc_override = FALSE)
	if((mecha_flags & MECHA_SKILL_LOCKED) && entering_mob.skills.getRating(SKILL_MECH) < SKILL_MECH_TRAINED)
		balloon_alert(entering_mob, "You don't know how to pilot this")
		return FALSE
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/add_occupant(mob/M)
	. = ..()
	var/datum/mech_limb/holding = limbs[MECH_GREY_HEAD]
	if(!holding || holding.disabled)
		return
	ADD_TRAIT(M, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	M.update_sight()

/obj/vehicle/sealed/mecha/combat/greyscale/remove_occupant(mob/M)
	REMOVE_TRAIT(M, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	M.update_sight()
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/grant_controller_actions_by_flag(mob/M, flag)
	. = ..()
	if(. && (flag & VEHICLE_CONTROL_DRIVE))
		RegisterSignal(M, COMSIG_KB_MOVEMENT_EAST_DOWN, PROC_REF(dash_east))
		RegisterSignal(M, COMSIG_KB_MOVEMENT_NORTH_DOWN, PROC_REF(dash_north))
		RegisterSignal(M, COMSIG_KB_MOVEMENT_SOUTH_DOWN, PROC_REF(dash_south))
		RegisterSignal(M, COMSIG_KB_MOVEMENT_WEST_DOWN, PROC_REF(dash_west))

/obj/vehicle/sealed/mecha/combat/greyscale/remove_controller_actions_by_flag(mob/M, flag)
	. = ..()
	if(. && (flag & VEHICLE_CONTROL_DRIVE))
		UnregisterSignal(M, list(COMSIG_KB_MOVEMENT_EAST_DOWN, COMSIG_KB_MOVEMENT_NORTH_DOWN, COMSIG_KB_MOVEMENT_SOUTH_DOWN, COMSIG_KB_MOVEMENT_WEST_DOWN))

/// Checks if we can dash to the east.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/dash_east()
	SIGNAL_HANDLER
	check_dash(EAST)

/// Checks if we can dash to the north.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/dash_north()
	SIGNAL_HANDLER
	check_dash(NORTH)

/// Checks if we can dash to the south.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/dash_south()
	SIGNAL_HANDLER
	check_dash(SOUTH)

/// Checks if we can dash to the west.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/dash_west()
	SIGNAL_HANDLER
	check_dash(WEST)

/// Checks if we can dash in the specified direction, and activates the ability if so.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/check_dash(direction)
	if(last_move_dir == direction && last_mousedown_time + double_tap_timing > world.time)
		if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_DASH))
			for(var/mob/occupant AS in return_drivers())
				balloon_alert(occupant, "Dash cooldown ([(S_TIMER_COOLDOWN_TIMELEFT(src, COOLDOWN_MECHA_DASH) / 10)]s)")
			return
		if(!use_power(dash_power_consumption))
			for(var/mob/occupant AS in return_drivers())
				balloon_alert(occupant, "Not enough for dash")
			return
		S_TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_DASH, dash_cooldown)
		activate_dash(direction)
		return
	last_mousedown_time = world.time
	last_move_dir = direction

/// Does a dash in the specified direction.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/activate_dash(direction)
	var/turf/target_turf = get_step(src, direction)
	for(var/i in 1 to dash_range)
		target_turf = get_step(target_turf, direction)
	throw_at(target_turf, dash_range, 1, src, FALSE, TRUE, TRUE)

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
			var/datum/mech_limb/holding = limbs[MECH_GREY_R_ARM]
			if(!holding || holding?.disabled)
				continue
			var/obj/item/mecha_parts/mecha_equipment/right_gun = equip_by_category[MECHA_R_ARM]
			if(right_gun)
				var/mutable_appearance/r_gun = mutable_appearance('icons/mecha/mech_gun_overlays.dmi', right_gun.icon_state + "_right", appearance_flags = KEEP_APART)
				r_gun.pixel_x = -32
				. += r_gun
			continue
		if(key == MECHA_L_ARM)
			var/datum/mech_limb/holding = limbs[MECH_GREY_L_ARM]
			if(!holding || holding.disabled)
				continue
			var/obj/item/mecha_parts/mecha_equipment/left_gun = equip_by_category[MECHA_L_ARM]
			if(left_gun)
				var/mutable_appearance/l_gun = mutable_appearance('icons/mecha/mech_gun_overlays.dmi', left_gun.icon_state + "_left", appearance_flags = KEEP_APART)
				l_gun.pixel_x = -32
				. += l_gun
			continue

		if(!istype(limbs[key], /datum/mech_limb))
			continue
		var/datum/mech_limb/limb = limbs[key]
		. += limb.get_overlays()

	var/state = leg_overload_mode ? "booster_active" : "booster"
	. += image('icons/mecha/mecha_ability_overlays.dmi', icon_state = state, layer=layer+0.001)

/obj/vehicle/sealed/mecha/combat/greyscale/setDir(newdir)
	. = ..()
	update_icon() //when available pass UPDATE_OVERLAYS since this is just for layering order

/obj/vehicle/sealed/mecha/combat/greyscale/throw_bounce(atom/hit_atom, turf/old_throw_source)
	return //no bounce for us

/obj/vehicle/sealed/mecha/combat/greyscale/needs_welder_repair(mob/user)
	if(user.zone_selected == BODY_ZONE_CHEST || user.zone_selected == BODY_ZONE_PRECISE_GROIN)
		return obj_integrity < max_integrity
	for(var/key in limbs)
		var/datum/mech_limb/limb = limbs[key]
		if(!limb)
			continue
		if((user.zone_selected in limb.def_zones) && (limb.part_health < initial(limb?.part_health)))
			return TRUE

///Sets up the jump component for the mob. Proc args can be altered so different mobs have different 'default' jump settings
/obj/vehicle/sealed/mecha/combat/greyscale/proc/set_jump_component(duration = 0.5 SECONDS, cooldown = 1 SECONDS, cost = 8, height = 16, sound = null, flags = JUMP_SHADOW, jump_pass_flags = PASS_LOW_STRUCTURE|PASS_FIRE|PASS_TANK)
	var/list/arg_list = list(duration, cooldown, cost, height, sound, flags, jump_pass_flags)
	if(SEND_SIGNAL(src, COMSIG_LIVING_SET_JUMP_COMPONENT, arg_list))
		duration = arg_list[1]
		cooldown = arg_list[2]
		cost = arg_list[3]
		height = arg_list[4]
		sound = arg_list[5]
		flags = arg_list[6]
		jump_pass_flags = arg_list[7]

	var/gravity = get_gravity()
	if(gravity < 1) //low grav
		duration *= 2.5 - gravity
		cooldown *= 2 - gravity
		cost *= gravity * 0.5
		height *= 2 - gravity
		if(gravity <= 0.75)
			jump_pass_flags |= PASS_DEFENSIVE_STRUCTURE
	else if(gravity > 1) //high grav
		duration *= gravity * 0.5
		cooldown *= gravity
		cost *= gravity
		height *= gravity * 0.5

	AddComponent(/datum/component/jump, _jump_duration = duration, _jump_cooldown = cooldown, _stamina_cost = cost, _jump_height = height, _jump_sound = sound, _jump_flags = flags, _jumper_allow_pass_flags = jump_pass_flags)

/obj/vehicle/sealed/mecha/combat/greyscale/recon
	name = "Recon Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/recon,
		MECH_GREY_HEAD = /datum/mech_limb/head/recon,
		MECH_GREY_LEGS = /datum/mech_limb/legs/recon,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/recon,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/recon,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/recon/noskill // hvh type
	mecha_flags = ADDING_ACCESS_POSSIBLE|CANSTRAFE|IS_ENCLOSED|HAS_HEADLIGHTS
	pivot_step = FALSE
	max_integrity = 1020
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 75, FIRE = 100, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.5, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)

/obj/vehicle/sealed/mecha/combat/greyscale/assault
	name = "Assault Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/assault,
		MECH_GREY_HEAD = /datum/mech_limb/head/assault,
		MECH_GREY_LEGS = /datum/mech_limb/legs/assault,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/assault,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/assault,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/assault/noskill // hvh type
	mecha_flags = ADDING_ACCESS_POSSIBLE|CANSTRAFE|IS_ENCLOSED|HAS_HEADLIGHTS
	pivot_step = FALSE
	max_integrity = 1390
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 75, FIRE = 100, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.5, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)

/obj/vehicle/sealed/mecha/combat/greyscale/vanguard
	name = "Vanguard Mecha"
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/vanguard,
		MECH_GREY_HEAD = /datum/mech_limb/head/vanguard,
		MECH_GREY_LEGS = /datum/mech_limb/legs/vanguard,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/vanguard,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/vanguard,
	)

/obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill // hvh type
	mecha_flags = ADDING_ACCESS_POSSIBLE|CANSTRAFE|IS_ENCLOSED|HAS_HEADLIGHTS
	pivot_step = FALSE
	max_integrity = 1760
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 75, FIRE = 100, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.5, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)

/obj/item/repairpack
	name = "mech repairpack"
	desc = "A mecha repair pack, consisting of various auto-extinguisher systems, materials and repair nano-scarabs."
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "posibrain-occupied" // todo kuro needs to make/find an icon for this
