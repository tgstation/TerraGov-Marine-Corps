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

/particles/mech_footstep
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke3"
	width = 750
	height = 750
	count = 25
	spawning = 25
	lifespan = 5
	fade = 15
	gradient = list("#BA9F6D", "#808080", "#FFFFFF")
	color = generator(GEN_NUM, 0, 0.25)
	color_change = generator(GEN_NUM, 0.08, 0.07)
	velocity = generator(GEN_CIRCLE, 5, 6)
	rotation = generator(GEN_NUM, -45, 45)
	scale = 0.015
	grow = 0.03
	friction = 0.25

/particles/mech_footstep_water
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke4"
	width = 750
	height = 750
	count = 25
	spawning = 25
	lifespan = 5
	fade = 15
	velocity = generator(GEN_CIRCLE, 5, 6)
	rotation = generator(GEN_NUM, -45, 45)
	scale = 0.015
	grow = 0.03
	friction = 0.25

/particles/dash_sparks
	icon = 'icons/effects/64x64.dmi'
	icon_state = "flare"
	width = 750
	height = 750
	count = 40
	spawning = 0
	lifespan = 5
	fade = 2
	velocity = list(-12, 0)
	scale = 0.1
	grow = -0.01
	drift = generator(GEN_CIRCLE, 3, 3, NORMAL_RAND)
	gravity = list(0, 1)
///sprite stuff with layering requires we make a specific order for each dir
/proc/get_greyscale_render_order(dir)
	switch(dir)
		if(EAST)
			return list(MECH_GREY_L_ARM, MECHA_L_ARM, MECH_GREY_TORSO, MECHA_R_BACK, MECHA_L_BACK, MECH_GREY_HEAD, MECH_GREY_LEGS,MECH_GREY_R_ARM, MECHA_R_ARM)
		if(WEST)
			return list(MECH_GREY_R_ARM, MECHA_R_ARM, MECH_GREY_TORSO, MECHA_R_BACK, MECHA_L_BACK, MECH_GREY_HEAD, MECH_GREY_LEGS, MECH_GREY_L_ARM, MECHA_L_ARM)
		if(NORTH)
			return list(MECH_GREY_TORSO, MECHA_R_BACK, MECHA_L_BACK, MECH_GREY_HEAD, MECH_GREY_LEGS, MECH_GREY_R_ARM, MECH_GREY_L_ARM, MECHA_L_ARM, MECHA_R_ARM)
		else
			return list(MECHA_R_BACK, MECHA_L_BACK, MECH_GREY_LEGS, MECH_GREY_TORSO, MECH_GREY_HEAD, MECH_GREY_R_ARM, MECH_GREY_L_ARM, MECHA_L_ARM, MECHA_R_ARM)

/obj/vehicle/sealed/mecha/combat/greyscale
	name = "Should not be visible"
	icon = 'icons/blanks/32x32.dmi'
	base_icon_state = "nothing"
	layer = ABOVE_ALL_MOB_LAYER
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
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
	allow_diagonal_movement = TRUE
	/// used to lookup ability overlays for this mech
	var/ability_module_icon = 'icons/mecha/mecha_ability_overlays.dmi'
	///whether we have currently swapped the back and arm icons
	var/swapped_to_backweapons = FALSE
	/// whether we should be using the b_ prefix for guns if we're boosting
	var/use_gun_boost_prefix = FALSE
	///whetehr we use the damage particles
	var/use_damage_particles = TRUE
	///whether this is an unusable wreck
	var/is_wreck = FALSE
	/// keyed list. values are types at init, otherwise instances of mecha limbs, order is layer order as well
	var/list/datum/mech_limb/limbs = list(
		MECH_GREY_TORSO = null,
		MECH_GREY_HEAD = null,
		MECH_GREY_LEGS = null,
		MECH_GREY_R_ARM = null,
		MECH_GREY_L_ARM = null,
	)
	/// list of where the foots are for mechs visually, used for particles
	var/foot_offsets = list(
		"left_foot" = list("N" = list(22,-8), "S" = list(22,-8), "E" = list(44,-8), "W" = list(22,-4)),
		"right_foot" = list("N" = list(44,-8), "S" = list(44,-8), "E" = list(22,-8), "W" = list(44,-4)),
	)
	///left dash foot sparks holder
	var/obj/effect/abstract/particle_holder/dash_sparks_left
	///right dash foot sparks holder
	var/obj/effect/abstract/particle_holder/dash_sparks_right
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
	/// Determines which foot the footstep particles go
	var/next_footstep_left = FALSE

/obj/vehicle/sealed/mecha/combat/greyscale/Initialize(mapload)
	if(use_damage_particles)
		holder_left = new(src, /particles/mecha_smoke)
		holder_left.layer = layer+0.001
		holder_right = new(src, /particles/mecha_smoke)
		holder_right.layer = layer+0.001
	dash_sparks_left = new(src, /particles/dash_sparks)
	dash_sparks_left.layer = layer-0.001
	dash_sparks_right = new(src, /particles/dash_sparks)
	dash_sparks_right.layer = layer-0.001
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
	if(is_wreck)
		. += "It's a smoking ruin."
		return
	for(var/limb_key in limbs)
		if(limb_key == MECH_GREY_TORSO)
			continue
		var/datum/mech_limb/limb = limbs[limb_key]
		. += "It's " + limb.display_name + " has " + "[(limb.part_health / initial(limb.part_health))*100]" + "% integrity."

/obj/vehicle/sealed/mecha/combat/greyscale/fire_act(burn_level)
	. = ..()
	take_damage(burn_level / 2, BURN, FIRE)

/obj/vehicle/sealed/mecha/combat/greyscale/emp_act(severity)
	if(!emp_timer)
		move_delay += MECH_EMP_SLOWDOWN
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/emp_restore()
	. = ..()
	move_delay -= MECH_EMP_SLOWDOWN

/obj/vehicle/sealed/mecha/combat/greyscale/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_overload_mode)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/repairpack)

/obj/vehicle/sealed/mecha/combat/greyscale/mob_try_enter(mob/entering_mob, mob/user, loc_override = FALSE)
	if(is_wreck)
		balloon_alert(entering_mob, "Destroyed")
		return FALSE
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

/obj/vehicle/sealed/mecha/combat/greyscale/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!forced)
		if(HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
			return
		if(!no_footstep_particle)
			var/obj/effect/abstract/particle_holder/footstep_particles
			var/turf/current_turf = get_turf(src)
			if(iswater(current_turf))
				footstep_particles = new(current_turf, /particles/mech_footstep_water)
			else
				footstep_particles = new(current_turf, /particles/mech_footstep)
			var/current_foot
			if(next_footstep_left)
				current_foot = "left_foot"
				next_footstep_left = FALSE
			else
				current_foot = "right_foot"
				next_footstep_left = TRUE
			footstep_particles.particles.position = list(foot_offsets[current_foot][dir2text_short(dir)][1] - 30, foot_offsets[current_foot][dir2text_short(dir)][2]-4)
			footstep_particles.layer = layer - 0.01
			QDEL_IN(footstep_particles, 5)

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
		if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_MECHA_DASH))
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
	if(!no_footstep_particle)
		add_sparks(direction)
		addtimer(CALLBACK(src, PROC_REF(remove_sparks)), 0.4 SECONDS)
	playsound(get_turf(src), 'sound/mecha/weapons/laser_sword.ogg', 70)
	ASYNC
		for(var/i=1 to dash_range)
			step(src, direction)
			sleep(1)

///adds dashing sparks in the specified direction
/obj/vehicle/sealed/mecha/combat/greyscale/proc/add_sparks(direction)
	dash_sparks_left.particles.spawning = 5
	dash_sparks_right.particles.spawning = 5
	dash_sparks_left.particles.position = list(foot_offsets["left_foot"][dir2text_short(direction)][1], foot_offsets["left_foot"][dir2text_short(direction)][2])
	dash_sparks_right.particles.position = list(foot_offsets["right_foot"][dir2text_short(direction)][1], foot_offsets["right_foot"][dir2text_short(direction)][2])
	switch(direction)
		if(EAST)
			dash_sparks_left.particles.velocity = list(-12, 0)
			dash_sparks_right.particles.velocity = list(-12, 0)
			dash_sparks_right.particles.gravity = list(0, 1)
		if(WEST)
			dash_sparks_left.particles.velocity = list(12, 0)
			dash_sparks_right.particles.velocity = list(12, 0)
			dash_sparks_right.particles.gravity = list(0, 1)
		if(NORTH)
			dash_sparks_left.particles.velocity = list(0, -12)
			dash_sparks_right.particles.velocity = list(0, -12)
			dash_sparks_right.particles.gravity = list(0, 0)
		else
			dash_sparks_left.particles.velocity = list(0, 12)
			dash_sparks_right.particles.velocity = list(0, 12)
			dash_sparks_right.particles.gravity = list(0, 0)

/// Turns off dash sparks particles.
/obj/vehicle/sealed/mecha/combat/greyscale/proc/remove_sparks()
	dash_sparks_left.particles.spawning = 0
	dash_sparks_right.particles.spawning = 0

/obj/vehicle/sealed/mecha/combat/greyscale/update_icon()
	. = ..()
	if(QDELING(src) || !use_damage_particles)
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

/obj/vehicle/sealed/mecha/combat/greyscale/get_mecha_occupancy_state()
	return base_icon_state

/obj/vehicle/sealed/mecha/combat/greyscale/update_overlays()
	. = ..()
	var/list/render_order = get_greyscale_render_order(dir)
	var/uses_back_icons = (MECHA_L_BACK in equip_by_category)
	if(!uses_back_icons)
		render_order -= list(MECHA_R_BACK, MECHA_L_BACK)

	for(var/key in render_order)
		/// only used for weapons
		var/prefix = is_wreck ? "d_" : (leg_overload_mode && use_gun_boost_prefix ? "b_" : "")
		if(key == MECHA_R_ARM)
			var/datum/mech_limb/arm/holding = limbs[MECH_GREY_R_ARM]
			if(!holding || holding?.disabled)
				continue
			var/obj/item/mecha_parts/mecha_equipment/right_gun = equip_by_category[MECHA_R_ARM]
			if(!is_wreck && uses_back_icons)
				prefix += "fire"
			if(right_gun)
				var/mutable_appearance/r_gun = mutable_appearance(holding.gun_icon, prefix+right_gun.icon_state + "_right")
				r_gun.pixel_w = holding.pixel_x_offset
				. += r_gun
			continue
		if(key == MECHA_L_ARM)
			var/datum/mech_limb/arm/holding = limbs[MECH_GREY_L_ARM]
			if(!holding || holding.disabled)
				continue
			var/obj/item/mecha_parts/mecha_equipment/left_gun = equip_by_category[MECHA_L_ARM]
			if(!is_wreck && uses_back_icons)
				prefix += "fire"
			if(left_gun)
				var/mutable_appearance/l_gun = mutable_appearance(holding.gun_icon, prefix+left_gun.icon_state + "_left")
				l_gun.pixel_w = holding.pixel_x_offset
				. += l_gun
			continue

		if(key == MECHA_R_BACK)
			var/datum/mech_limb/arm/holding = limbs[MECH_GREY_R_ARM]
			if(!holding || holding?.disabled)
				continue
			var/obj/item/mecha_parts/mecha_equipment/right_gun = equip_by_category[MECHA_R_BACK]
			if(right_gun)
				var/mutable_appearance/r_gun = mutable_appearance(holding.gun_icon, prefix+right_gun.icon_state + "_right")
				. += r_gun
			continue
		if(key == MECHA_L_BACK)
			var/datum/mech_limb/arm/holding = limbs[MECH_GREY_L_ARM]
			if(!holding || holding.disabled)
				continue
			var/obj/item/mecha_parts/mecha_equipment/left_gun = equip_by_category[MECHA_L_BACK]
			if(left_gun)
				var/mutable_appearance/l_gun = mutable_appearance(holding.gun_icon, prefix+left_gun.icon_state + "_left")
				. += l_gun
			continue

		if(!istype(limbs[key], /datum/mech_limb))
			continue
		var/datum/mech_limb/limb = limbs[key]
		. += limb.get_overlays()

	for(var/obj/item/mecha_parts/mecha_equipment/ability/module in equip_by_category[MECHA_UTILITY])
		if(module.icon_state)
			var/prefix = is_wreck ? "d_" : (leg_overload_mode && use_gun_boost_prefix ? "b_" : "")
			var/image/new_overlay =image(ability_module_icon, icon_state = prefix+module.icon_state)
			. += new_overlay

	var/state = leg_overload_mode ? "booster_active" : "booster"
	. += image(ability_module_icon, icon_state = state, layer=layer+0.002)
	. += emissive_appearance(ability_module_icon, state, src)

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
	soft_armor = list(MELEE = 25, BULLET = 60, LASER = 50, ENERGY = 50, BOMB = 40, BIO = 75, FIRE = 100, ACID = 30)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.5, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/recon/hvh,
		MECH_GREY_HEAD = /datum/mech_limb/head/recon,
		MECH_GREY_LEGS = /datum/mech_limb/legs/recon,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/recon,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/recon,
	)

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
	soft_armor = list(MELEE = 35, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 60, BIO = 75, FIRE = 100, ACID = 30)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.5, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/assault/hvh,
		MECH_GREY_HEAD = /datum/mech_limb/head/assault,
		MECH_GREY_LEGS = /datum/mech_limb/legs/assault,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/assault,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/assault,
	)

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
	soft_armor = list(MELEE = 45, BULLET = 70, LASER = 60, ENERGY = 60, BOMB = 70, BIO = 75, FIRE = 100, ACID = 30)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.5, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)

/obj/item/repairpack
	name = "mech repairpack"
	desc = "A mecha repair pack, consisting of various auto-extinguisher systems, materials and repair nano-scarabs."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "armor_melee"
