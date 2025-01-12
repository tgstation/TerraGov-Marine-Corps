// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/cone
	name = "Spray Acid Cone"
	desc = "Spray a cone of dangerous acid at your target."
	ability_cost = 300
	cooldown_duration = 40 SECONDS

/datum/action/ability/activable/xeno/spray_acid/cone/use_ability(atom/A)
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(!do_after(xeno_owner, 5, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	GLOB.round_statistics.praetorian_acid_sprays++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "praetorian_acid_sprays")

	succeed_activate()

	playsound(xeno_owner.loc, 'sound/effects/refill.ogg', 25, 1)
	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] spews forth a wide cone of acid!"), \
	span_xenowarning("We spew forth a cone of acid!"), null, 5)

	xeno_owner.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, 1)
	start_acid_spray_cone(target, xeno_owner.xeno_caste.acid_spray_range)
	add_cooldown()
	addtimer(CALLBACK(src, PROC_REF(reset_speed)), rand(2 SECONDS, 3 SECONDS))

/datum/action/ability/activable/xeno/spray_acid/cone/proc/reset_speed()
	if(QDELETED(xeno_owner))
		return
	xeno_owner.remove_movespeed_modifier(type)

/datum/action/ability/activable/xeno/spray_acid/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/spray_acid/ai_should_use(atom/target)
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

GLOBAL_LIST_INIT(acid_spray_hit, typecacheof(list(/obj/structure/barricade, /obj/hitbox, /obj/structure/razorwire)))

#define CONE_PART_MIDDLE (1<<0)
#define CONE_PART_LEFT (1<<1)
#define CONE_PART_RIGHT (1<<2)
#define CONE_PART_DIAG_LEFT (1<<3)
#define CONE_PART_DIAG_RIGHT (1<<4)
#define CONE_PART_MIDDLE_DIAG (1<<5)

///Start the acid cone spray in the correct direction
/datum/action/ability/activable/xeno/spray_acid/cone/proc/start_acid_spray_cone(turf/T, range)
	var/facing = angle_to_dir(Get_Angle(owner, T))
	owner.setDir(facing)
	switch(facing)
		if(NORTH, SOUTH, EAST, WEST)
			do_acid_cone_spray(owner.loc, range, facing, CONE_PART_MIDDLE|CONE_PART_LEFT|CONE_PART_RIGHT, owner, TRUE)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			do_acid_cone_spray(owner.loc, range, facing, CONE_PART_MIDDLE_DIAG, owner, TRUE)
			do_acid_cone_spray(owner.loc, range + 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, owner, TRUE)

///Check if it's possible to create a spray, and if yes, check if the spray must continue
/datum/action/ability/activable/xeno/spray_acid/cone/proc/do_acid_cone_spray(turf/T, distance_left, facing, direction_flag, source_spray, skip_timer = FALSE)
	if(distance_left <= 0)
		return
	if(T.density)
		return
	var/is_blocked = FALSE
	for (var/obj/O in T)
		if(!O.CanPass(source_spray, get_turf(source_spray)))
			is_blocked = TRUE
			O.acid_spray_act(owner)
			break
	if(is_blocked)
		return

	var/obj/effect/xenomorph/spray/spray = new(T, xeno_owner.xeno_caste.acid_spray_duration, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner)
	var/turf/next_normal_turf = get_step(T, facing)
	for (var/atom/movable/A AS in T)
		A.acid_spray_act(owner)
		if(((A.density && !(A.allow_pass_flags & PASS_PROJECTILE) && !(A.atom_flags & ON_BORDER)) || !A.Exit(source_spray, facing)) && !isxeno(A))
			is_blocked = TRUE
	if(!is_blocked)
		if(!skip_timer)
			addtimer(CALLBACK(src, PROC_REF(continue_acid_cone_spray), T, next_normal_turf, distance_left, facing, direction_flag, spray), 3)
			return
		continue_acid_cone_spray(T, next_normal_turf, distance_left, facing, direction_flag, spray)


///Call the next steps of the cone spray,
/datum/action/ability/activable/xeno/spray_acid/cone/proc/continue_acid_cone_spray(turf/current_turf, turf/next_normal_turf, distance_left, facing, direction_flag, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE))
		do_acid_cone_spray(next_normal_turf, distance_left - 1 , facing, CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_RIGHT))
		do_acid_cone_spray(get_step(next_normal_turf, turn(facing, 90)), distance_left - 1, facing, CONE_PART_RIGHT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_LEFT))
		do_acid_cone_spray(get_step(next_normal_turf, turn(facing, -90)), distance_left - 1, facing, CONE_PART_LEFT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_LEFT))
		do_acid_cone_spray(get_step(current_turf, turn(facing, 45)), distance_left - 1, turn(facing, 45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_RIGHT))
		do_acid_cone_spray(get_step(current_turf, turn(facing, -45)), distance_left - 1, turn(facing, -45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE_DIAG))
		do_acid_cone_spray(next_normal_turf, distance_left - 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, spray)
		do_acid_cone_spray(next_normal_turf, distance_left - 2, facing, (distance_left < 5) ? CONE_PART_MIDDLE : CONE_PART_MIDDLE_DIAG, spray)


// ***************************************
// *********** Slime Grenade
// ***************************************
/datum/action/ability/xeno_action/sticky_grenade
	name = "Slime grenade"
	action_icon_state = "gas mine"
	action_icon = 'icons/Xeno/actions/sentinel.dmi'
	desc = "Throws a lump of compressed acid to stick to a target, which will leave a trail of acid behind them."
	ability_cost = 75
	cooldown_duration = 45 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOXIC_GRENADE,
	)
	///Type of nade to be thrown
	var/nade_type = /obj/item/explosive/grenade/sticky/xeno

/datum/action/ability/xeno_action/sticky_grenade/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(owner.l_hand || owner.r_hand)
		if(!silent)
			owner.balloon_alert(owner, "Cannot create grenade, need empty hands")
		return FALSE

/datum/action/ability/xeno_action/sticky_grenade/action_activate()
	var/obj/item/explosive/grenade/sticky/xeno/nade = new(owner.loc)
	owner.put_in_hands(nade)
	to_chat(owner, span_xenonotice("We vomit up a sticky lump.")) // Ewww...
	add_cooldown()
	succeed_activate()
	nade.activate(owner)

/obj/item/explosive/grenade/sticky/xeno/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")

/obj/item/explosive/grenade/sticky/xeno
	name = "\improper slime grenade"
	desc = "A fleshy mass oozing acid. It appears to be rapidly decomposing."
	greyscale_colors = "#42A500"
	greyscale_config = /datum/greyscale_config/xenogrenade
	self_sticky = TRUE
	arm_sound = 'sound/voice/alien/yell_alt.ogg'
	worn_icon_state = null
	worn_icon_list = null
	var/acid_spray_damage = 15

/obj/item/explosive/grenade/sticky/xeno/prime()
	for(var/turf/acid_tile AS in RANGE_TURFS(1, loc))
		new /obj/effect/temp_visual/acid_splatter(acid_tile) //SFX
		new /obj/effect/xenomorph/spray(acid_tile, 5 SECONDS, acid_spray_damage)
	playsound(loc, SFX_ACID_BOUNCE, 35)
	if(stuck_to)
		clean_refs()
	qdel(src)

/obj/item/explosive/grenade/sticky/xeno/stuck_to(atom/hit_atom)
	. = ..()
	RegisterSignal(stuck_to, COMSIG_MOVABLE_MOVED, PROC_REF(drop_acid))
	new /obj/effect/xenomorph/spray(get_turf(src), 5 SECONDS, acid_spray_damage)

///causes acid tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/xeno/proc/drop_acid(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	new /obj/effect/xenomorph/spray(get_turf(src), 5 SECONDS, acid_spray_damage)

/obj/item/explosive/grenade/sticky/xeno/clean_refs()
	stuck_to.cut_overlay(saved_overlay)
	UnregisterSignal(stuck_to, COMSIG_MOVABLE_MOVED)
	return ..()

//Deals with picking up and using the grenade
/obj/item/explosive/grenade/sticky/xeno/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE
	attack_hand(xeno_attacker)


// ***************************************
// *********** Acid dash
// ***************************************
/datum/action/ability/activable/xeno/charge/acid_dash
	name = "Acid Dash"
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	desc = "Instantly dash, tackling the first marine in your path. If you manage to tackle someone, gain another weaker cast of the ability."
	ability_cost = 250
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_DASH,
	)
	charge_range = PRAE_CHARGEDISTANCE
	///Can we use the ability again
	var/recast_available = FALSE
	///Is this the recast
	var/recast = FALSE
	///The last tile we dashed through, used when swapping with a human
	var/turf/last_turf

/datum/action/ability/activable/xeno/charge/acid_dash/use_ability(atom/A)
	if(!A)
		return
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(acid_steps)) //We drop acid on every tile we pass through

	xeno_owner.visible_message(span_danger("[xeno_owner] slides towards \the [A]!"), \
	span_danger("We dash towards \the [A], spraying acid down our path!") )
	xeno_owner.emote("roar")
	xeno_owner.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	last_turf = get_turf(owner)
	owner.pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	owner.throw_at(A, charge_range, 2, owner)

/datum/action/ability/activable/xeno/charge/acid_dash/mob_hit(datum/source, mob/living/living_target)
	. = TRUE
	if(living_target.stat || isxeno(living_target) || !(iscarbon(living_target))) //we leap past xenos
		return
	recast_available = TRUE
	var/mob/living/carbon/carbon_victim = living_target
	carbon_victim.ParalyzeNoChain(0.5 SECONDS)

	to_chat(carbon_victim, span_userdanger("The [owner] tackles us, sending us behind them!"))
	owner.visible_message(span_xenodanger("\The [owner] tackles [carbon_victim], swapping location with them!"), \
		span_xenodanger("We push [carbon_victim] in our acid trail!"), visible_message_flags = COMBAT_MESSAGE)

/datum/action/ability/activable/xeno/charge/acid_dash/charge_complete()
	. = ..()
	if(recast_available)
		addtimer(CALLBACK(src, PROC_REF(charge_complete)), 2 SECONDS) //Delayed recursive call, this time you won't gain a recast so it will go on cooldown in 2 SECONDS.
		recast = TRUE
	else
		recast = FALSE
		add_cooldown()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	xeno_owner.pass_flags = initial(xeno_owner.pass_flags)
	recast_available = FALSE

///Drops an acid puddle on the current owner's tile, will do 0 damage if the owner has no acid_spray_damage
/datum/action/ability/activable/xeno/charge/acid_dash/proc/acid_steps(atom/A, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	last_turf = OldLoc
	new /obj/effect/xenomorph/spray(get_turf(xeno_owner), 5 SECONDS, xeno_owner.xeno_caste.acid_spray_damage) //Add a modifier here to buff the damage if needed
	for(var/obj/O in get_turf(xeno_owner))
		O.acid_spray_act(xeno_owner)



// ***************************************
// *********** Dodge
// ***************************************
/datum/action/ability/xeno_action/dodge
	name = "Dodge"
	action_icon_state = "dodge"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Gain a speed boost upon activation and the ability to pass through mobs. Enemies automatically receive bump attacks when passed."
	ability_cost = 100
	cooldown_duration = 12 SECONDS
	use_state_flags = ABILITY_USE_BUSY
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DODGE,
	)
	/// The increase of speed when ability is active.
	var/speed_buff = -0.4
	/// How long the ability will last?
	var/duration = 6 SECONDS

/datum/action/ability/xeno_action/dodge/action_activate(atom/A)
	owner.balloon_alert(owner, "Dodge ready!")

	owner.add_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_DODGE_SPEED, TRUE, 0, NONE, TRUE, speed_buff)
	owner.allow_pass_flags |= (PASS_MOB|PASS_XENO)
	owner.pass_flags |= (PASS_MOB|PASS_XENO)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	addtimer(CALLBACK(src, PROC_REF(remove_effects)), duration)

	succeed_activate()
	add_cooldown()

/// Automatically bumps living non-xenos if bump attacks are on.
/datum/action/ability/xeno_action/dodge/proc/on_move(datum/source)
	if(owner.stat == DEAD)
		return FALSE
	var/datum/action/bump_attack_toggle/bump_attack_action = owner.actions_by_path[/datum/action/bump_attack_toggle]
	if(bump_attack_action == null || bump_attack_action.attacking) // Bump attacks are off if attacking is true, apparently.
		return FALSE
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BUMP_ATTACK) || owner.next_move > world.time)
		return FALSE

	var/turf/current_turf = get_turf(owner)
	for(var/mob/living/living_mob in current_turf)
		if(living_mob.stat == DEAD)
			continue
		if(isxeno(living_mob))
			var/mob/living/carbon/xenomorph/xenomorph_mob = living_mob
			if(owner.issamexenohive(xenomorph_mob))
				continue
		owner.Bump(living_mob)
		return

/// Removes the movespeed modifier and various pass_flags that was given by the dodge ability.
/datum/action/ability/xeno_action/dodge/proc/remove_effects()
	owner.balloon_alert(owner, "Dodge inactive!")

	owner.remove_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_DODGE_SPEED)
	owner.allow_pass_flags &= ~(PASS_MOB|PASS_XENO)
	owner.pass_flags &= ~(PASS_MOB|PASS_XENO)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

// ***************************************
// *********** Impale
// ***************************************
/datum/action/ability/activable/xeno/impale
	name = "Impale"
	action_icon_state = "impale"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Impale a marine next to you with your tail for moderate damage. Marked enemies are impaled twice."
	ability_cost = 100
	cooldown_duration = 8 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_IMPALE,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/impale/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "cannot impale")
		return FALSE
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/xenomorph_target = A
		if(owner.issamexenohive(xenomorph_target))
			A.balloon_alert(owner, "cannot impale ally")
			return FALSE
	var/mob/living/carbon/carbon_target = A
	if(!owner.Adjacent(carbon_target))
		carbon_target.balloon_alert(owner, "too far")
		return FALSE
	if(carbon_target.stat == DEAD)
		carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/xeno/impale/use_ability(atom/target_atom)
	. = ..()

	if(!iscarbon(target_atom))
		return
	var/mob/living/carbon/living_target = target_atom
	var/buffed = living_target.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
	xeno_owner.visible_message(span_danger("\The [xeno_owner] violently slices [living_target] with its tail [buffed ? "twice" : ""]!"), \
		span_danger("We slice [living_target] with our tail[buffed ? " twice" : ""]!"))

	try_impale(living_target)
	if(buffed)
		xeno_owner.emote("roar")
		addtimer(CALLBACK(src, PROC_REF(try_impale), living_target), 0.1 SECONDS) // A short delay for animation coolness (and also if they're dead).

	succeed_activate()
	add_cooldown()

/// Performs the main effect of impale ability like animating and attacking.
/datum/action/ability/activable/xeno/impale/proc/try_impale(mob/living/carbon/living_target)
	var/damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier)
	xeno_owner.face_atom(living_target)
	xeno_owner.do_attack_animation(living_target, ATTACK_EFFECT_REDSLASH)
	xeno_owner.spin(4, 1)
	playsound(living_target, get_sfx(SFX_ALIEN_TAIL_ATTACK), 30, TRUE)
	if(living_target.stat != DEAD) // If they drop dead from the first impale, keep the effects but do no damage.
		living_target.apply_damage(damage, BRUTE, blocked = MELEE)

// ***************************************
// *********** Tail Trip
// ***************************************
/datum/action/ability/activable/xeno/tail_trip
	name = "Tail Trip"
	action_icon_state = "tail_trip"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Target a marine within two tiles of you to disorient and slows them. Marked enemies receive stronger debuffs and are stunned for a second."
	ability_cost = 50
	cooldown_duration = 8 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_TRIP,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/tail_trip/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "cannot tail trip")
		return FALSE
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/xenomorph_target = A
		if(owner.issamexenohive(xenomorph_target))
			A.balloon_alert(owner, "cannot tail trip ally")
			return FALSE
	var/mob/living/carbon/carbon_target = A
	if(get_dist(owner, carbon_target) > 2)
		if(!silent)
			carbon_target.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, carbon_target, 2))
		if(!silent)
			carbon_target.balloon_alert(owner, "need line of sight")
		return FALSE
	if(carbon_target.stat == DEAD)
		carbon_target.balloon_alert(owner, "already dead")
		return FALSE
	if(carbon_target.stat == UNCONSCIOUS)
		carbon_target.balloon_alert(owner, "not standing")
		return FALSE

/datum/action/ability/activable/xeno/tail_trip/use_ability(atom/target_atom)
	. = ..()
	if(!iscarbon(target_atom))
		return

	var/mob/living/carbon/living_target = target_atom

	var/damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier)
	var/buffed = living_target.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)

	xeno_owner.visible_message(span_danger("\The [xeno_owner] sweeps [living_target]'s legs with its tail!"), \
		span_danger("We trip [living_target] with our tail!"))
	shake_camera(living_target, 2, 1)
	xeno_owner.face_atom(living_target)
	xeno_owner.spin(4, 1)
	xeno_owner.emote("tail")
	playsound(living_target,'sound/weapons/alien_claw_block.ogg', 50, 1)

	living_target.Paralyze(buffed ? 1 SECONDS : 0.1 SECONDS)
	living_target.adjust_stagger(buffed ? 5 SECONDS : 4 SECONDS)
	living_target.adjust_slowdown(buffed ? 1.2 : 0.9)
	living_target.apply_damage(damage, STAMINA, updating_health = TRUE)

	succeed_activate()
	add_cooldown()
