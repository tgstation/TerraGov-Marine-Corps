//nerd sieger strain

// ***************************************
// *********** Tail Ram
// ***************************************

/datum/action/ability/activable/xeno/tail_stab/battering_ram
	name = "Tail Ram"
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "tail_attack"
	desc = "Strike a target within two tiles with a ram-like tail for non AP blunt damage, large stagger and slowdown, double stagger and slowdown to grappled targets, FIVE times damage to structures and machinery."
	ability_cost = 30
	cooldown_duration = 20 SECONDS
	penetration = 0
	structure_damage_multiplier = 5
	disorientamount = 4

// ***************************************
// *********** Earth Riser (Siege)
// ***************************************

/datum/action/ability/activable/xeno/earth_riser/siege
	name = "Earth Riser (Siege)"
	action_icon_state = "earth_riser"
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	desc = "Raise a pillar of earth at the selected location. This solid structure can be used for defense, and it interacts with other abilities for offensive usage. The pillar can be launched by click-dragging it in a direction. Alternate use destroys active pillars, starting with the oldest one. These ones specialise in structure damage on direct hit."
	ability_cost = 20
	cooldown_duration = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EARTH_RISER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE,
	)
	/// The maximum amount of Earth Pillars that can be active at once.
	maximum_pillars = 2
	pillar_type = /obj/structure/earth_pillar/siege

#define SIEGE_PILLAR_SPREAD_RADIUS EARTH_PILLAR_SPREAD_RADIUS/2

/obj/structure/earth_pillar/siege
	name = "siege pillar"

//this is here to reduce the spread range
/datum/ammo/xeno/earth_pillar/siege/on_hit_anything(turf/hit_turf, atom/movable/projectile/proj)
	playsound(hit_turf, 'sound/effects/alien/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(hit_turf)
	var/list/turf/affected_turfs = filled_turfs(hit_turf, SIEGE_PILLAR_SPREAD_RADIUS, include_edge = FALSE, pass_flags_checked = PASS_GLASS|PASS_PROJECTILE)
	behemoth_area_attack(proj.firer, affected_turfs, damage_multiplier = EARTH_PILLAR_SPREAD_DAMAGE_MULTIPLIER)


/// Deletes the pillar and creates a projectile on the same tile, to be fired at the target atom.
/obj/structure/earth_pillar/siege/throw_pillar(atom/target_atom, landslide)
	if(!isxeno(usr) || !in_range(src, usr) || target_atom == src || warning_flashes < initial(warning_flashes))
		return
	SEND_SIGNAL(src, COMSIG_XENOABILITY_EARTH_PILLAR_THROW)
	var/source_turf = get_turf(src)
	playsound(source_turf, SFX_BEHEMOTH_EARTH_PILLAR_HIT, 40)
	new /obj/effect/temp_visual/behemoth/landslide/hit(source_turf)
	qdel(src)
	var/datum/ammo/xeno/earth_pillar/siege/projectile = landslide? GLOB.ammo_list[/datum/ammo/xeno/earth_pillar/siege/landslide] : GLOB.ammo_list[/datum/ammo/xeno/earth_pillar/siege]
	var/atom/movable/projectile/new_projectile = new /atom/movable/projectile(source_turf)
	new_projectile.generate_bullet(projectile)
	new_projectile.fire_at(get_turf(target_atom), usr, source_turf, new_projectile.ammo.max_range)


/datum/ammo/xeno/earth_pillar/siege
	name = "siege pillar"

/datum/ammo/xeno/earth_pillar/siege/landslide
	name = "siege pillar"

//since it loses landslide we let em boom on regular throws and stuff
/datum/ammo/xeno/earth_pillar/siege/landslide/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	if(istype(target_turf, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = target_turf
		wall_victim.take_damage(250) //bonus damage
	return on_hit_anything(target_turf, proj)

/datum/ammo/xeno/earth_pillar/siege/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	target_obj.take_damage(125) //bonus damage
	if(istype(target_obj, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/hit_tank = target_obj
		hit_tank.explode()
	return on_hit_anything(get_turf(target_obj), proj)

// ***************************************
// *********** Gallop
// ***************************************

/datum/action/ability/xeno_action/ready_charge/sieger
	name = "Gallop"
	desc = "Toggles Galloping on or off. This can be used to crush and displace talls, has a less charge time than rolling and can deal damage, and can ram through structures but tires us quickly."
	speed_per_step = 0.35
	steps_for_charge = 4
	max_steps_buildup = 4
	crush_living_damage = 20
	plasma_use_multiplier = 2

// ***************************************
// *********** Shard Burst
// ***************************************

/datum/action/ability/activable/xeno/shard_burst/cone
	name = "Shard Burst"
	desc = "Shoot a cone of stone shards at your target from your armor, sundering your armor each time."
	ability_cost = 300
	cooldown_duration = 30 SECONDS
	/// How will far can the shards go? Tile underneath starts at 1.
	var/range = 7

/datum/action/ability/activable/xeno/shard_burst/cone/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(!do_after(xeno_owner, 5, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	succeed_activate()

	playsound(xeno_owner.loc, 'sound/weapons/guns/fire/grenadelauncher.ogg', 25, 1)
	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] shoots forth a wide cone of stone shards!"), \
	span_xenowarning("We shoot forth a cone of stone shards!"), null, 5)

	xeno_owner.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, 1)
	start_shard_burst_cone(target, range)
	xeno_owner.adjust_sunder(30) //you shoot your armor
	add_cooldown()
	addtimer(CALLBACK(src, PROC_REF(reset_speed)), rand(2 SECONDS, 3 SECONDS))

/datum/action/ability/activable/xeno/shard_burst/cone/proc/reset_speed()
	if(QDELETED(xeno_owner))
		return
	xeno_owner.remove_movespeed_modifier(type)

/datum/action/ability/activable/xeno/shard_burst/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/shard_burst/ai_should_use(atom/target)
	if(owner.do_actions) //Chances are we're already spraying acid, don't override it
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 3))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

GLOBAL_LIST_INIT(shard_burst_hit, typecacheof(list(/obj/structure/barricade, /obj/hitbox, /obj/structure/razorwire)))

#define CONE_PART_MIDDLE (1<<0)
#define CONE_PART_LEFT (1<<1)
#define CONE_PART_RIGHT (1<<2)
#define CONE_PART_DIAG_LEFT (1<<3)
#define CONE_PART_DIAG_RIGHT (1<<4)
#define CONE_PART_MIDDLE_DIAG (1<<5)

///Start the acid cone spray in the correct direction
/datum/action/ability/activable/xeno/shard_burst/cone/proc/start_shard_burst_cone(turf/T, range)
	var/facing = angle_to_dir(Get_Angle(owner, T))
	owner.setDir(facing)
	switch(facing)
		if(NORTH, SOUTH, EAST, WEST)
			do_shard_cone_spray(owner.loc, range, facing, CONE_PART_MIDDLE|CONE_PART_LEFT|CONE_PART_RIGHT, owner, TRUE)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			do_shard_cone_spray(owner.loc, range, facing, CONE_PART_MIDDLE_DIAG, owner, TRUE)
			do_shard_cone_spray(owner.loc, range + 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, owner, TRUE)

///Check if it's possible to create a spray, and if yes, check if the spray must continue
/datum/action/ability/activable/xeno/shard_burst/cone/proc/do_shard_cone_spray(turf/T, distance_left, facing, direction_flag, source_spray, skip_timer = FALSE)
	if(distance_left <= 0)
		return

	xenomorph_spray_shard(T, xeno_owner, range)
	var/turf/next_normal_turf = get_step(T, facing)
	for (var/atom/movable/A AS in T)
		if(!skip_timer)
			addtimer(CALLBACK(src, PROC_REF(continue_shard_cone_spray), T, next_normal_turf, distance_left, facing, direction_flag), 3)
			return
		continue_shard_cone_spray(T, next_normal_turf, distance_left, facing, direction_flag)

/proc/xenomorph_spray_shard(turf/spraying_turf, mob/living/carbon/xenomorph/xenomorph_creator, range = 5)
	var/datum/ammo/ammo = /datum/ammo/bullet/micro_rail_spread
	for(var/atom/atom_in_turf AS in spraying_turf)
		var/turf/current_turf = get_turf(xenomorph_creator)
		var/atom/movable/projectile/newspit = new /atom/movable/projectile(current_turf)
		newspit.generate_bullet(ammo)
		newspit.def_zone = ran_zone()
		newspit.fire_at(spraying_turf, xenomorph_creator, xenomorph_creator, range)

///Call the next steps of the cone spray,
/datum/action/ability/activable/xeno/shard_burst/cone/proc/continue_shard_cone_spray(turf/current_turf, turf/next_normal_turf, distance_left, facing, direction_flag, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE))
		do_shard_cone_spray(next_normal_turf, distance_left - 1 , facing, CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_RIGHT))
		do_shard_cone_spray(get_step(next_normal_turf, turn(facing, 90)), distance_left - 1, facing, CONE_PART_RIGHT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_LEFT))
		do_shard_cone_spray(get_step(next_normal_turf, turn(facing, -90)), distance_left - 1, facing, CONE_PART_LEFT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_LEFT))
		do_shard_cone_spray(get_step(current_turf, turn(facing, 45)), distance_left - 1, turn(facing, 45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_RIGHT))
		do_shard_cone_spray(get_step(current_turf, turn(facing, -45)), distance_left - 1, turn(facing, -45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE_DIAG))
		do_shard_cone_spray(next_normal_turf, distance_left - 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, spray)
		do_shard_cone_spray(next_normal_turf, distance_left - 2, facing, (distance_left < 5) ? CONE_PART_MIDDLE : CONE_PART_MIDDLE_DIAG, spray)

/datum/action/ability/activable/xeno/shard_burst/cone/circle
	name = "Shard Explosion"
	desc = "Shoot shards of stone all around you."

/datum/action/ability/activable/xeno/shard_burst/cone/circle/start_shard_burst_cone(turf/T, range)
	for(var/direction in GLOB.alldirs)
		if(direction in GLOB.cardinals)
			do_shard_cone_spray(xeno_owner.loc, range, direction, CONE_PART_MIDDLE, xeno_owner, TRUE)
		else
			do_shard_cone_spray(xeno_owner.loc, range, direction, CONE_PART_MIDDLE_DIAG, xeno_owner, TRUE)

#undef CONE_PART_MIDDLE
#undef CONE_PART_LEFT
#undef CONE_PART_RIGHT
#undef CONE_PART_DIAG_LEFT
#undef CONE_PART_DIAG_RIGHT
#undef CONE_PART_MIDDLE_DIAG
