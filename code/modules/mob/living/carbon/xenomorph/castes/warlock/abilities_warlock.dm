// ***************************************
// *********** Psychic shield
// ***************************************
/datum/action/xeno_action/activable/psychic_shield
	name = "Psychic Shield"
	action_icon_state = "fling"
	mechanics_text = "Creates a protective field of psychic energy in front of you."
	cooldown_timer = 12 SECONDS
	plasma_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_SHIELD,
	)
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	var/obj/effect/xeno/shield/active_shield


/datum/action/xeno_action/activable/psychic_shield/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to create a psychic shield again."))
	return ..()

/datum/action/xeno_action/activable/psychic_shield/use_ability(atom/A)
	. = ..()
	//GLOB.round_statistics.psychic_flings++
	//SSblackbox.record_feedback("tally", "round_statistics", 1, "psychic_flings")
	//var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner.visible_message("A strange and violent psychic aura is suddenly emitted from \the [owner]!")
	playsound(owner,'sound/effects/magic.ogg', 75, 1)

	//var/turf/facing = get_step(owner, owner.dir)
	active_shield = new(get_step(owner, owner.dir), owner)

	//maybe add some thing to light fling mobs caught in the deploying shield
	add_cooldown()

/obj/effect/xeno/shield
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "alienegg_fire"
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER
	var/mob/living/carbon/xenomorph/owner

/obj/effect/xeno/shield/Initialize(loc, creator)
	. = ..()
	owner = creator
	dir = owner.dir
	if(dir == EAST || dir == WEST)
		bound_height = 96
		bound_y = -32
	else
		bound_width = 96
		bound_x = -32

/obj/effect/xeno/shield/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(!(cardinal_move & REVERSE_DIR(dir)))
		if(!uncrossing)
			proj.uncross_scheduled += src
		return FALSE
	if (uncrossing)
		return FALSE
	reflect_projectile(proj)
	return FALSE

/obj/effect/xeno/shield/proc/reflect_projectile(obj/projectile/proj)
	playsound(loc, 'sound/effects/portal.ogg', 20)
	var/new_range = proj.proj_max_range - proj.distance_travelled

	if(new_range <= 0)
		proj.ammo.do_at_max_range(proj)
		qdel(proj)
		return
	var/perpendicular_angle = Get_Angle(src, get_step(src, dir)) //the angle src is facing
	var/new_angle = (perpendicular_angle + (perpendicular_angle - proj.dir_angle - 180))
	if(new_angle < 0)
		new_angle += 360
	else if(new_angle > 360)
		new_angle -= 360
	proj.firer = src
	proj.fire_at(shooter = src, source = src, range = new_range, angle = new_angle, recursivity = TRUE) //loc_override = loc //note investigate hitscan issue


// ***************************************
// *********** psychic crush
// ***************************************
/datum/action/xeno_action/activable/psy_crush
	name = "psychic crush"
	action_icon_state = "centrifugal_force"
	mechanics_text = "Channel our psychic force to crush everything in an area of effect." //placeholder
	ability_name = "psychic crush"
	plasma_cost = 20
	cooldown_timer = 5 SECONDS //placeholder
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_CRUSH,
	)
	///The number of times we can expand our effect radius. Effectively a max radius
	var/max_interations = 5 //maybe tie this to maturity
	///How many times we have expanded our effect radius
	var/current_iterations = 0
	///timer hash for the timer we use when charging up
	var/channel_loop_timer
	///List of turfs in the effect radius
	var/list/target_turfs = list()
	///list of effects used to visualise area of effect
	var/list/effect_list = list()
	/// A list of all things that had a fliter applied
	var/list/filters_applied = list()
	///max range at which we can cast out ability
	var/ability_range = 9

/datum/action/xeno_action/activable/psy_crush/use_ability(atom/target)
	//note: can probs just make alt action activate a new proc, and call it here if timer is active.
	if(channel_loop_timer) //you're already channeling
		early_trigger()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.selected_ability != src)
		action_activate()
		return
	if(owner.do_actions || !target)
		return FALSE
	if(!can_use_action(TRUE)) //stunned or whatever
		return fail_activate()
	if(!check_distance(target))
		return FALSE
	if(!do_after(owner, 0.5 SECONDS, TRUE, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_use_action, FALSE, XACT_USE_BUSY))) //windup
		return fail_activate()
	owner.visible_message(span_xenowarning("\The [owner] starts channeling their psychic might!"), \
		span_xenowarning("We start channeling our psychic might!"))
	var/turf/target_turf = get_turf(target)
	target_turfs += target_turf
	effect_list += new /obj/effect/xeno/crush_warning(turf_to_check)
	do_channel(target_turf) //start channeling
	RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_ADDTRAIT(TRAIT_IMMOBILE)), .proc/stop_crush)

///activates crush early
/datum/action/xeno_action/activable/psy_crush/proc/early_trigger()
	if(!can_use_action() || !length(target_turfs))
		owner.visible_message(span_xenowarning("\The [owner] is unable to unleash their power!"), \
			span_xenowarning("We fail to unleash our power!"))
		return
	crush(target_turfs[1])
	//addtimer(CALLBACK(src, .proc/crush, target_turfs[1]), 1)

/datum/action/xeno_action/activable/psy_crush/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > ability_range)
		to_chat(owner, span_warning("Too far for our reach... We need to be [dist - ability_range] steps closer!"))
		return FALSE
	else if(!line_of_sight(owner, target, 9))
		to_chat(owner, span_warning("We can't focus properly without a clear line of sight!"))
		return FALSE
	return TRUE

///Increases the area of effect, or triggers the crush if we've reached max iterations
/datum/action/xeno_action/activable/psy_crush/proc/do_channel(turf/target)
	channel_loop_timer = null
	var/mob/living/carbon/xenomorph/X = owner
	if(!check_distance(target) || isnull(X) || X.stat == DEAD)
		stop_crush(target)
		return
	if(current_iterations >= max_interations)
		crush(target)
		return
	playsound(target, 'sound/effects/woosh_swoosh.ogg', 30 + (current_iterations * 10)) //Sound effects

	succeed_activate()

	var/list/turfs_to_add = list()
	for(var/turf/current_turf AS in target_turfs)
		var/list/turfs_to_check = get_adjacent_open_turfs(current_turf)
		for(var/turf/turf_to_check AS in turfs_to_check)
			if((turf_to_check in target_turfs) || (turf_to_check in turfs_to_add))
				continue
			turfs_to_add += turf_to_check
			effect_list += new /obj/effect/xeno/crush_warning(turf_to_check)
	target_turfs += turfs_to_add
	current_iterations ++
	if(can_use_action(X, XACT_IGNORE_COOLDOWN))
		channel_loop_timer = addtimer(CALLBACK(src, .proc/do_channel, target), 10, TIMER_STOPPABLE)
		return
	stop_crush(target)

///crushes all turfs in the AOE
/datum/action/xeno_action/activable/psy_crush/proc/crush(turf/target)
	//note: do we need a check to see if we have sufficient plasma, due to the override?
	if(!check_distance(target))
		stop_crush(target)
		return
	succeed_activate(plasma_cost * current_iterations)
	to_chat(owner, span_warning("We unleash our psychic might!"))
	playsound(target, 'sound/effects/EMPulse.ogg', 70)
	apply_filters(target_turfs)
	addtimer(CALLBACK(src, .proc/remove_all_filters), 2 SECONDS, TIMER_STOPPABLE)
	for(var/turf/effected_turf AS in target_turfs)
		for(var/i AS in effected_turf)
			if(iscarbon(i))
				var/mob/living/carbon/carbon_victim = i
				if(isxeno(carbon_victim) || carbon_victim.stat == DEAD)
					continue
				var/block = carbon_victim.get_soft_armor(BOMB)
				carbon_victim.apply_damage(35, BRUTE, blocked = block)
				carbon_victim.apply_damage(50, STAMINA, blocked = block)
				carbon_victim.adjust_stagger(6)
				carbon_victim.add_slowdown(8)
			else if(ismecha(i))
				var/obj/vehicle/sealed/mecha/mecha_victim = i
				mecha_victim.ex_act(EXPLODE_HEAVY)
			else if(isobj(i))
				var/obj/obj_victim = i
				if(istype(obj_victim, /obj/alien))
					continue
				obj_victim.ex_act(EXPLODE_LIGHT)
	stop_crush(target)

/// stops channeling and unregisters all listeners, resetting the ability
/datum/action/xeno_action/activable/psy_crush/proc/stop_crush(turf/target)
	SIGNAL_HANDLER
	to_chat(owner, span_warning("We stop.")) //debug only
	if(channel_loop_timer)
		deltimer(channel_loop_timer)
		channel_loop_timer = null
	for(var/obj/effect/xeno/crush_warning/current_effect AS in effect_list)
		qdel(current_effect)
	current_iterations = 0
	target_turfs = list()
	effect_list = list()
	add_cooldown()
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_ADDTRAIT(TRAIT_IMMOBILE)))

///Apply a filter on all items in the list of turfs
/datum/action/xeno_action/activable/psy_crush/proc/apply_filters(list/turfs)
	for(var/turf/targeted AS in turfs)
		targeted.add_filter("crushblur", 1, radial_blur_filter(0.3))
		filters_applied += targeted
		for(var/atom/movable/item AS in targeted.contents)
			item.add_filter("crushblur", 1, radial_blur_filter(0.3))
			filters_applied += item

///Remove all filters of items in filters_applied
/datum/action/xeno_action/activable/psy_crush/proc/remove_all_filters()
	for(var/atom/thing AS in filters_applied)
		if(QDELETED(thing))
			continue
		thing.remove_filter("crushblur")
	filters_applied.Cut()

/obj/effect/xeno/crush_warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "crush_warning"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = FLY_LAYER


// ***************************************
// *********** Psyblast
// ***************************************
/datum/action/xeno_action/activable/psy_blast
	name = "Psychic blast"
	action_icon_state = "bombard"
	mechanics_text = "Launch a blast of psychic energy. Must remain stationary for a few seconds to use."
	ability_name = "bombard"
	cooldown_timer = 5 SECONDS //placeholder
	plasma_cost = 60 //placeholder
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_BLAST,
	)
	target_flags = XABB_MOB_TARGET //todo:what does this actually do?

/datum/action/xeno_action/activable/psy_blast/on_cooldown_finish()
	to_chat(owner, span_notice("We feel our strength return. We are ready to unleash a psychic blast again."))
	return ..()

/datum/action/xeno_action/activable/psy_blast/on_activation()
	var/mob/living/carbon/xenomorph/X = owner
	X.visible_message(span_notice("\The [X] prepares to fire!"), \
		span_notice("We prepare to fire."), null, 5) //placeholder

/datum/action/xeno_action/activable/psy_blast/on_deactivation()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.selected_ability == src)
		to_chat(X, span_notice("We relax our stance."))

/datum/action/xeno_action/activable/psy_blast/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(!X.check_state())
		return FALSE
	//if(X.ammo?.spit_cost > X.plasma_stored)
	//	if(!silent)
	//		to_chat(X, span_warning("We need [X.ammo?.spit_cost - X.plasma_stored] more plasma!"))
	//	return FALSE

/datum/action/xeno_action/activable/psy_blast/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/turf/target = get_turf(A)

	if(!istype(target))
		return

	to_chat(X, span_xenonotice("We channel our psychic power."))

	if(!do_after(X, 1 SECONDS, FALSE, target, BUSY_ICON_DANGER))
		to_chat(X, span_warning("We decide not to launch."))
		return fail_activate()

	if(!can_use_ability(target, FALSE))
		return fail_activate()

	X.visible_message(span_xenowarning("\The [X] launches a blast of psychic energy!"), \
	span_xenowarning("We launch a huge blast of psychic energy!"), null, 5)

	var/obj/projectile/hitscan/P = new /obj/projectile/hitscan(X.loc)
	var/datum/ammo/ammo_type = /datum/ammo/energy/psy_blast
	P.effect_icon = initial(ammo_type.hitscan_effect_icon)
	//P.generate_bullet(X.ammo) //readd this when we make the beno
	P.generate_bullet(ammo_type)
	P.fire_at(target, X, null, P.ammo.max_range, P.ammo.shell_speed)
	playsound(X, 'sound/weapons/guns/fire/volkite_4.ogg', 50)
	//if(istype(X.ammo, /datum/ammo/xeno/shrike_gas/corrosive))
	//	GLOB.round_statistics.shrike_acid_smokes++
	//	SSblackbox.record_feedback("tally", "round_statistics", 1, "shrike_acid_smokes")
	//	X.corrosive_ammo--
	//else
	//	GLOB.round_statistics.shrike_neuro_smokes++
	//	SSblackbox.record_feedback("tally", "round_statistics", 1, "shrike_neuro_smokes")
	//	X.neuro_ammo--

	succeed_activate()
	add_cooldown()
