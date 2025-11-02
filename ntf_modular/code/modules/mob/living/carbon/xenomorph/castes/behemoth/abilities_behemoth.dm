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
	can_hit_turf = TRUE

/turf/tail_stab_act(mob/living/carbon/xenomorph/xeno, damage, target_zone, penetration, structure_damage_multiplier,  stab_description = "devastating tail-ram!", disorientamount) //Smash structures
	. = ..()
	xeno.face_atom(src) //Face the target if adjacent so you dont look dumb.
	xeno.do_attack_animation(src, ATTACK_EFFECT_SMASH)
	xeno.visible_message(span_xenodanger("\The [xeno] slam [src] with a [stab_description]"), \
		span_xenodanger("We slam [src] with a [stab_description]"), visible_message_flags = COMBAT_MESSAGE)
	playsound(src, "alien_tail_swipe", 50, TRUE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 25, 1)
	var/list/turf/affected_turfs = filled_turfs(src, 1, include_edge = FALSE, pass_flags_checked = PASS_GLASS|PASS_PROJECTILE)
	for(var/turf/affected_tiles in affected_turfs)
		affected_tiles.Shake(duration = 0.5 SECONDS) //SFX
	behemoth_area_attack(xeno, affected_turfs, damage_multiplier = 1)

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

/obj/structure/earth_pillar/siege/tail_stab_act(mob/living/carbon/xenomorph/xeno, damage, target_zone, penetration, structure_damage_multiplier, stab_description, disorientamount)
	. = ..()
	if(xeno.blunt_stab)
		stab_description = "strong tail-whip"
		var/the_direction = xeno.dir
		var/the_range = 7
		if(!in_range(src, xeno)) //the tail stab turns xeno around to reach that far, so reverse also less power
			the_direction = reverse_ndir(xeno_owner.dir)
			the_range = 5
		throw_pillar(get_ranged_target_turf(xeno_owner, the_direction, the_range, TRUE), TRUE)

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
/datum/ammo/xeno/earth_pillar/siege/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	if(istype(target_turf, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = target_turf
		wall_victim.take_damage(150, BRUTE) //bonus damage
	return on_hit_anything(target_turf, proj)

/datum/ammo/xeno/earth_pillar/siege/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	target_obj.take_damage(100) //bonus damage
	if(istype(target_obj, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/hit_tank = target_obj
		hit_tank.explode()
	return on_hit_anything(get_turf(target_obj), proj)

// ***************************************
// *********** Gallop
// ***************************************

/datum/action/ability/xeno_action/ready_charge/sieger
	name = "Gallop"
	desc = "Toggles Galloping on or off. This can be used to crush and displace talls, has a less charge time than rolling and can deal damage, and can ram through structures but tires us quickly. We will be disoriented when we ram into something."
	speed_per_step = 0.35
	steps_for_charge = 4
	max_steps_buildup = 4
	crush_living_damage = 15
	plasma_use_multiplier = 3

/datum/action/ability/xeno_action/ready_charge/sieger/do_crush(datum/source, atom/crushed)
	. = ..()
	var/mob/living/carbon/xenomorph/charger = owner
	if(isturf(crushed))
		charger.Knockdown(0.7 SECONDS)
		playsound(charger, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 25, 1)
		charger.add_slowdown(4)
		charger.adjust_stagger(4)
		charger.do_jitter_animation(1500, 2 SECONDS)
	else if(isliving(crushed)) //not as effective as crusher againt people
		speed_down(2)
		charger.add_slowdown(2)

// ***************************************
// *********** Shard Burst
// ***************************************

/datum/action/ability/activable/xeno/shard_burst
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SPRAY_SHARD,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	action_icon_state = "fortify"
	action_icon = 'icons/Xeno/actions/defender.dmi'

/datum/action/ability/activable/xeno/shard_burst/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

	var/turf/T = get_turf(owner)
	var/turf/T2 = get_turf(A)
	if(T == T2)
		if(!silent)
			to_chat(owner, span_warning("That's far too close!"))
		return FALSE


/datum/action/ability/activable/xeno/shard_burst/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien/drool1.ogg', 50, 1)
	to_chat(owner, span_xenodanger("We feel our carapace covered with enough pieces of rock. We can burst shards again."))
	return ..()


/datum/action/ability/activable/xeno/shard_burst/cone
	name = "Shard Burst"
	desc = "Shoot a cone of stone shards at your target from your armor, sundering your armor each time."
	ability_cost = 100
	cooldown_duration = 30 SECONDS
	/// How will far can the shards go? Tile underneath starts at 1.
	var/range = 7

/datum/action/ability/activable/xeno/shard_burst/cone/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return fail_activate()

	xeno_owner.emote("roar")
	if(!do_after(xeno_owner, 5, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	succeed_activate()

	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] shoots forth a wide cone of stone shards!"), \
	span_xenowarning("We shoot forth a cone of stone shards!"), null, 5)

	xeno_owner.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, 1)
	start_shard_burst_cone(target, range)
	add_cooldown()
	xeno_owner.adjust_sunder(30) //you shoot your armor
	addtimer(CALLBACK(src, PROC_REF(reset_speed)), rand(2 SECONDS, 3 SECONDS))

/datum/action/ability/activable/xeno/shard_burst/cone/proc/reset_speed()
	if(QDELETED(xeno_owner))
		return
	xeno_owner.remove_movespeed_modifier(type)

/datum/action/ability/activable/xeno/shard_burst/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/shard_burst/ai_should_use(atom/target)
	if(owner.do_actions) //Chances are we're already spraying, don't override it
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

///Start the acid cone spray in the correct direction
/datum/action/ability/activable/xeno/shard_burst/cone/proc/start_shard_burst_cone(turf/T, range)
	var/facing = angle_to_dir(Get_Angle(owner, T))
	owner.setDir(facing)
	switch(facing)
		if(NORTH, SOUTH, EAST, WEST)
			do_shard_cone_spray(T, range, owner)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			do_shard_cone_spray(T, range + 1, owner)

/datum/action/ability/activable/xeno/shard_burst/cone/proc/do_shard_cone_spray(turf/T, range)
	playsound(owner.loc, 'sound/weapons/guns/fire/gunshot.ogg', 25, 1)
	xenomorph_spray_shard(T, xeno_owner, range)

//rock shrapnel, could probably hurt friendlies too.
/datum/ammo/bullet/sieger_shard
	name = "rock shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_variation = 5
	damage = 25
	penetration = 20
	sundering = 3
	damage_falloff = 3
	max_range = 7
	shell_speed = 1.5
	bonus_projectiles_type = /datum/ammo/bullet/sieger_shard/scatter
	bonus_projectiles_amount = 14
	bonus_projectiles_scatter = 6

/datum/ammo/bullet/sieger_shard/scatter
	bonus_projectiles_type = null
	bonus_projectiles_amount = 0

/proc/xenomorph_spray_shard(turf/spraying_turf, mob/living/carbon/xenomorph/xenomorph_creator, range = 5)
	var/datum/ammo/ammo = /datum/ammo/bullet/sieger_shard
	var/turf/current_turf = get_turf(xenomorph_creator)
	var/atom/movable/projectile/newspit = new /atom/movable/projectile(current_turf)
	newspit.generate_bullet(ammo)
	newspit.def_zone = ran_zone()
	newspit.fire_at(spraying_turf, xenomorph_creator, xenomorph_creator, range)

/datum/action/ability/activable/xeno/shard_burst/cone/circle
	name = "Shard Explosion"
	desc = "Shoot shards of stone all around you."

/datum/action/ability/activable/xeno/shard_burst/cone/circle/start_shard_burst_cone(turf/T, range)
	do_shard_cone_spray(get_ranged_target_turf(xeno_owner, NORTH, 1), range)
	do_shard_cone_spray(get_ranged_target_turf(xeno_owner, WEST, 1),  range)
	do_shard_cone_spray(get_ranged_target_turf(xeno_owner, SOUTH, 1), range)
	do_shard_cone_spray(get_ranged_target_turf(xeno_owner, EAST, 1), range)

