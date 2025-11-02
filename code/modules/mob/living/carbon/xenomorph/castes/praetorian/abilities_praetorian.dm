// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/ability/activable/xeno/spray_acid/cone
	name = "Spray Acid Cone"
	desc = "Spray a cone of dangerous acid at your target."
	ability_cost = 300
	cooldown_duration = 40 SECONDS
	/// How will far can the acid go? Tile underneath starts at 1.
	var/range = 5

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
	start_acid_spray_cone(target, range)
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

	var/obj/effect/xenomorph/spray/spray = xenomorph_spray(T, xeno_owner.xeno_caste.acid_spray_duration, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner)
	var/turf/next_normal_turf = get_step(T, facing)
	for (var/atom/movable/A AS in T)
		// There would of been a snowflake check for carbons to paralyze them for the sake of making their density to FALSE and allowing it to continue,
		// however, we want the spray to work on them and do things like statistics and damage. So, we tell it to skip the cooldown.
		A.acid_spray_act(owner, TRUE)
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

/datum/action/ability/activable/xeno/spray_acid/cone/circle
	name = "Spray Acid Circle"
	desc = "Spray a cone of dangerous acid around you."

/datum/action/ability/activable/xeno/spray_acid/cone/circle/start_acid_spray_cone(turf/T, range)
	for(var/direction in GLOB.alldirs)
		if(direction in GLOB.cardinals)
			do_acid_cone_spray(xeno_owner.loc, range, direction, CONE_PART_MIDDLE, xeno_owner, TRUE)
		else
			do_acid_cone_spray(xeno_owner.loc, range, direction, CONE_PART_MIDDLE_DIAG, xeno_owner, TRUE)

#undef CONE_PART_MIDDLE
#undef CONE_PART_LEFT
#undef CONE_PART_RIGHT
#undef CONE_PART_DIAG_LEFT
#undef CONE_PART_DIAG_RIGHT
#undef CONE_PART_MIDDLE_DIAG

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
	var/nade_type = /obj/item/explosive/grenade/sticky/xeno/acid

/datum/action/ability/xeno_action/sticky_grenade/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(owner.l_hand || owner.r_hand)
		if(!silent)
			owner.balloon_alert(owner, "Cannot create grenade, need empty hands")
		return FALSE

/datum/action/ability/xeno_action/sticky_grenade/action_activate()
	var/obj/item/explosive/grenade/sticky/xeno/acid/nade = new(owner.loc)
	owner.put_in_hands(nade)
	to_chat(owner, span_xenonotice("We vomit up a sticky lump.")) // Ewww...
	add_cooldown()
	succeed_activate()
	nade.activate(owner)

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
	paralyze_duration = 0 // Although we don't do anything related to paralyze, it is nice to have this zeroed out.
	charge_range = PRAE_CHARGEDISTANCE
	///Can we use the ability again
	var/recast_available = FALSE
	///Is this the recast
	var/recast = FALSE
	/// If we should do acid_spray_act on those we pass over.
	var/do_acid_spray_act = TRUE
	///List of pass_flags given by this action
	var/charge_pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE

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

	xeno_owner.add_pass_flags(charge_pass_flags, type)
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
	xeno_owner.remove_pass_flags(charge_pass_flags, type)
	recast_available = FALSE

///Drops an acid puddle on the current owner's tile, will do 0 damage if the owner has no acid_spray_damage
/datum/action/ability/activable/xeno/charge/acid_dash/proc/acid_steps(atom/A, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	xenomorph_spray(get_turf(xeno_owner), 5 SECONDS, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner, FALSE, do_acid_spray_act)



// ***************************************
// *********** Dodge
// ***************************************
/datum/action/ability/xeno_action/dodge
	name = "Dodge"
	action_icon_state = "dodge"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Flood your body with adrenaline, gaining a speed boost upon activation and the ability to pass through mobs. Enemies automatically receive bump attacks when passed."
	ability_cost = 100
	cooldown_duration = 18 SECONDS
	use_state_flags = ABILITY_USE_BUSY
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DODGE,
	)
	/// The increase of speed when ability is active.
	var/speed_buff = -0.3
	/// How long the ability will last?
	var/duration = 8 SECONDS
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///List of pass_flags given by this action
	var/dodge_pass_flags = PASS_MOB|PASS_XENO

/datum/action/ability/xeno_action/dodge/action_activate(atom/A)
	owner.balloon_alert(owner, "Dodge ready!")
	toggle_particles(TRUE)

	owner.add_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_DODGE_SPEED, TRUE, 0, NONE, TRUE, speed_buff)
	owner.allow_pass_flags |= (PASS_MOB|PASS_XENO)
	xeno_owner.add_pass_flags(dodge_pass_flags, type)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	addtimer(CALLBACK(src, PROC_REF(remove_effects)), duration)

	succeed_activate()
	add_cooldown()

/// Automatically bumps living non-xenos if bump attacks are on.
/datum/action/ability/xeno_action/dodge/proc/on_move(datum/source)
	if(owner.stat == DEAD)
		return FALSE
	if(!xeno_owner.client?.prefs?.toggle_bump_attacking)
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_BUMP_ATTACK) || owner.next_move > world.time)
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
	toggle_particles(FALSE)

	owner.remove_movespeed_modifier(MOVESPEED_ID_PRAETORIAN_DANCER_DODGE_SPEED)
	owner.allow_pass_flags &= ~(PASS_MOB|PASS_XENO)
	xeno_owner.remove_pass_flags(dodge_pass_flags, type)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/// Toggles particles on or off, adjusting their positioning to fit the buff's owner.
/datum/action/ability/xeno_action/dodge/proc/toggle_particles(toggle)
	var/particle_x = abs(xeno_owner.pixel_x)
	if(!toggle)
		QDEL_NULL(particle_holder)
		return
	particle_holder = new(xeno_owner, /particles/baton_pass)
	particle_holder.pixel_x = particle_x
	particle_holder.pixel_y = -3

// ***************************************
// *********** Impale
// ***************************************
/datum/action/ability/activable/xeno/impale
	name = "Impale"
	action_icon_state = "impale"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Skewer an object next to you with your tail. The more debuffs on a living target, the greater the damage done. Penetrates the armor of marked targets."
	ability_cost = 150
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_IMPALE,
	)

/datum/action/ability/activable/xeno/impale/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(A) && !ishitbox(A) && !isvehicle(A) && !ismachinery(A))
		if(!silent)
			A.balloon_alert(owner, "cannot impale")
		return FALSE
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/xenomorph_target = A
		if(owner.issamexenohive(xenomorph_target))
			A.balloon_alert(owner, "cannot impale ally")
			return FALSE
	if(!A.Adjacent(owner))
		A.balloon_alert(owner, "too far")
		return FALSE
	if(isliving(A))
		var/mob/living/living_target = A
		if(living_target.stat == DEAD)
			living_target.balloon_alert(owner, "already dead")
			return FALSE

/datum/action/ability/activable/xeno/impale/use_ability(atom/target_atom)
	. = ..()

	xeno_owner.face_atom(target_atom)
	xeno_owner.do_attack_animation(target_atom, ATTACK_EFFECT_REDSTAB)
	playsound(xeno_owner, get_sfx(SFX_ALIEN_TAIL_ATTACK), 30, TRUE)
	xeno_owner.visible_message(span_danger("\The [xeno_owner] violently spears \the [target_atom] with their tail!"))
	if(!ishuman(target_atom))
		target_atom.attack_alien(xeno_owner, xeno_owner.xeno_caste.melee_damage * DANCER_NONHUMAN_IMPALE_MULT)

	else
		var/mob/living/carbon/human/human_victim = target_atom
		var/marked = human_victim.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
		var/buff_multiplier = min(DANCER_MAX_IMPALE_MULT, determine_buff_mult(human_victim))
		var/adj_damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * buff_multiplier)
		human_victim.apply_damage(adj_damage, BRUTE, blocked = MELEE, penetration = (marked ? DANCER_IMPALE_PENETRATION : 0), attacker = owner)
		human_victim.Shake(duration = 0.5 SECONDS)
		//you got shishkebabbed really bad
		if(buff_multiplier > 1.70)
			xeno_owner.emote("roar")
			human_victim.knockback(xeno_owner, 1, 1)
			human_victim.emote("scream")
	succeed_activate()
	add_cooldown()

/// Determines the total damage multiplier of impale based on the presence of several debuffs.
/datum/action/ability/activable/xeno/impale/proc/determine_buff_mult(mob/living/carbon/human/living_target)
	var/adjusted_mult = 1.20
	//tier 1 debuffs
	if(living_target.IsStaggered())
		adjusted_mult += 0.15
	if(living_target.IsSlowed())
		adjusted_mult += 0.15
	if(living_target.IsConfused())
		adjusted_mult += 0.15
	if(living_target.IsImmobilized())
		adjusted_mult += 0.15
	if(living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		adjusted_mult += 0.15
	if(living_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		adjusted_mult += 0.15
	if(living_target.has_status_effect(STATUS_EFFECT_SHATTER))
		adjusted_mult += 0.15
	if(living_target.has_status_effect(STATUS_EFFECT_MELTING))
		adjusted_mult += 0.15
	if(living_target.has_status_effect(STATUS_EFFECT_LIFEDRAIN))
		adjusted_mult += 0.15
	//big bonus if target has a "helpless" debuff
	if(living_target.IsParalyzed() || living_target.IsStun() || living_target.IsKnockdown())
		adjusted_mult += 0.5
	return adjusted_mult


// ***************************************
// *********** Tail Trip
// ***************************************
/datum/action/ability/activable/xeno/tail_trip
	name = "Tail Trip"
	action_icon_state = "tail_trip"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Twirl your tail around low to the ground, knocking over and disorienting any adjacent marines. Marked enemies receive stronger debuffs and are briefly stunned."
	ability_cost = 75
	cooldown_duration = 8 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_TRIP,
	)
	/// If the owner is on fire, should they be extinguished while spreading it to the affected as melting fire?
	var/spreads_fire = FALSE

/datum/action/ability/activable/xeno/tail_trip/use_ability(atom/target_atom)
	. = ..()

	xeno_owner.add_filter("dancer_tail_trip", 2, gauss_blur_filter(1)) //Add cool SFX
	var/obj/effect/temp_visual/tail_swing/swing = new
	xeno_owner.vis_contents += swing

	xeno_owner.spin(0.6 SECONDS, 1)
	xeno_owner.emote("tail")
	xeno_owner.enable_throw_parry(0.6 SECONDS)
	playsound(xeno_owner,pick('sound/effects/alien/tail_swipe1.ogg','sound/effects/alien/tail_swipe2.ogg','sound/effects/alien/tail_swipe3.ogg'), 25, 1) //Sound effects
	xeno_owner.visible_message(span_danger("\The [xeno_owner] sweeps its tail in a low circle!"))

	var/damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier))
	var/list/inrange = orange(1, xeno_owner)
	var/melting_fire_stacks
	if(spreads_fire && xeno_owner.is_on_fire())
		melting_fire_stacks += xeno_owner.fire_stacks
		var/datum/status_effect/stacking/melting_fire/melting_fire = xeno_owner.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
		if(melting_fire)
			melting_fire_stacks += melting_fire.stacks
		xeno_owner.ExtinguishMob()

	for (var/mob/living/carbon/human/living_target in inrange)
		if(living_target.stat == DEAD)
			continue
		to_chat(living_target, span_xenowarning("Our legs are struck by \the [xeno_owner]'s tail!"))
		var/buffed = living_target.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
		if(buffed)
			living_target.ParalyzeNoChain(1.5 SECONDS)
			shake_camera(living_target, 2, 1)
		living_target.AdjustKnockdown(buffed ? 1 SECONDS : 0.5 SECONDS)
		living_target.adjust_stagger(buffed ? 3 SECONDS : 1.5 SECONDS)
		living_target.apply_damage(damage, STAMINA, updating_health = TRUE, attacker = owner)
		if(melting_fire_stacks)
			var/datum/status_effect/stacking/melting_fire/melting_fire = xeno_owner.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
			if(melting_fire)
				melting_fire.add_stacks(melting_fire_stacks)
			else
				living_target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, melting_fire_stacks)

	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/datum, remove_filter), "dancer_tail_trip"), 0.6 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(remove_swing), swing), 3 SECONDS)
	succeed_activate()
	add_cooldown()

///Garbage collects the swing attack vis_overlay created during use_ability
/datum/action/ability/activable/xeno/tail_trip/proc/remove_swing(swing_visual)
	xeno_owner.vis_contents -= swing_visual
	QDEL_NULL(swing_visual)

/obj/effect/temp_visual/tail_swing
	icon = 'icons/effects/96x96.dmi'
	icon_state = "tail_swing"
	pixel_x = -18
	pixel_y = -32
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART

// ***************************************
// *********** Tail Hook
// ***************************************
/datum/action/ability/activable/xeno/tail_hook
	name = "Tail Hook"
	action_icon_state = "tail_hook"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Swing your tail high, sending the hooked edge gouging into any targets within 2 tiles. Hooked marines have their movement slowed and are dragged, spinning, towards you. Marked marines are slowed for longer and briefly knocked over."
	cooldown_duration = 12 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	ability_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAILHOOK,
	)
	/// If the owner is on fire, should they be extinguished while spreading it to the affected as melting fire?
	var/spreads_fire = FALSE
	/// How far will the affected be pulled towards the owner? If negative, will push them away instead.
	var/pull_distance = 1
	/// How much additional damage should the affected take? This is a flat increase of damage.
	var/bonus_damage = 0

/datum/action/ability/activable/xeno/tail_hook/use_ability(atom/target_atom)
	. = ..()

	var/obj/effect/temp_visual/tail_hook/hook = new
	xeno_owner.vis_contents += hook
	xeno_owner.spin(0.8 SECONDS, 1)
	xeno_owner.enable_throw_parry(0.6 SECONDS)

	playsound(xeno_owner,pick('sound/effects/alien/tail_swipe1.ogg','sound/effects/alien/tail_swipe2.ogg','sound/effects/alien/tail_swipe3.ogg'), 25, 1) //Sound effects
	xeno_owner.visible_message(span_danger("\The [xeno_owner] swings the hook on its tail through the air!"))

	var/damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) / 2) + bonus_damage
	var/list/inrange = orange(2, xeno_owner)
	var/melting_fire_stacks
	if(spreads_fire && xeno_owner.is_on_fire())
		melting_fire_stacks += xeno_owner.fire_stacks
		var/datum/status_effect/stacking/melting_fire/melting_fire = xeno_owner.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
		if(melting_fire)
			melting_fire_stacks += melting_fire.stacks
		xeno_owner.ExtinguishMob()

	for (var/mob/living/carbon/human/living_target in inrange)
		var/start_turf = get_step(xeno_owner, get_cardinal_dir(xeno_owner, living_target))
		//no hooking through solid obstacles
		if(check_path(xeno_owner, start_turf, PASS_THROW) != start_turf)
			continue
		if(living_target.stat == DEAD)
			continue
		to_chat(living_target, span_xenowarning("\The [xeno_owner] hooks into your flesh and yanks you towards it!"))
		var/buffed = living_target.has_status_effect(STATUS_EFFECT_DANCER_TAGGED)
		living_target.apply_damage(damage, BRUTE, blocked = MELEE, updating_health = TRUE, attacker = owner)
		living_target.Shake(duration = 0.1 SECONDS)
		living_target.spin(2 SECONDS, 1)

		if(pull_distance > 0) // Inward (positive)
			living_target.throw_at(xeno_owner, pull_distance, 3, xeno_owner)
		else if(pull_distance < 0) // Outward (negative)
			living_target.knockback(xeno_owner, -pull_distance, 1)
		living_target.adjust_slowdown(buffed? 0.9 : 0.3)
		if(buffed)
			living_target.AdjustKnockdown(0.1 SECONDS)
		if(melting_fire_stacks)
			var/datum/status_effect/stacking/melting_fire/melting_fire = xeno_owner.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
			if(melting_fire)
				melting_fire.add_stacks(melting_fire_stacks)
			else
				living_target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, melting_fire_stacks)

	addtimer(CALLBACK(src, PROC_REF(remove_swing), hook), 3 SECONDS) //Remove cool SFX
	succeed_activate()
	add_cooldown()

///Garbage collects the swing attack vis_overlay created during use_ability
/datum/action/ability/activable/xeno/tail_hook/proc/remove_swing(swing_visual)
	xeno_owner.vis_contents -= swing_visual
	QDEL_NULL(swing_visual)

/obj/effect/temp_visual/tail_hook
	icon = 'icons/effects/128x128.dmi'
	icon_state = "tail_hook"
	pixel_x = -32
	pixel_y = -46
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART

// ***************************************
// *********** Baton Pass
// ***************************************
/datum/action/ability/activable/xeno/baton_pass
	name = "Baton Pass"
	action_icon_state = "baton_pass"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Dose adjacent xenomorphs with your adrenaline, increasing their movement speed for 6 seconds. Less effect on quick xenos."
	cooldown_duration = 35 SECONDS
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BATONPASS,
	)
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
\
/datum/action/ability/activable/xeno/baton_pass/use_ability(atom/target)

	var/obj/effect/temp_visual/baton_pass/baton = new
	xeno_owner.vis_contents += baton
	xeno_owner.spin(0.8 SECONDS, 1)

	playsound(xeno_owner,pick('sound/effects/alien/tail_swipe1.ogg','sound/effects/alien/tail_swipe2.ogg','sound/effects/alien/tail_swipe3.ogg'), 25, 1) //Sound effects
	xeno_owner.visible_message(span_danger("\The [xeno_owner] empowers nearby xenos with increased speed!"))

	for (var/mob/living/carbon/xenomorph/xeno_target in orange(1, xeno_owner))
		if(xeno_target.stat == DEAD)
			continue
		if(xeno_target.hivenumber != xeno_owner.hivenumber)
			continue
		xeno_target.apply_status_effect(STATUS_EFFECT_XENO_BATONPASS)

	addtimer(CALLBACK(src, PROC_REF(remove_baton), baton), 3 SECONDS)
	succeed_activate()
	add_cooldown()

///Garbage collects the baton vis_overlay created during use_ability
/datum/action/ability/activable/xeno/baton_pass/proc/remove_baton(baton_visual)
	xeno_owner.vis_contents -= baton_visual
	QDEL_NULL(baton_visual)

/obj/effect/temp_visual/baton_pass
	icon = 'icons/effects/96x96.dmi'
	icon_state = "baton_pass"
	pixel_x = -18
	pixel_y = -14
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART

// ***************************************
// *********** Abduct
// ***************************************

/datum/action/ability/activable/xeno/oppressor
	// If the affected hit a wall while being thrown, what percentage of the owner's melee damage should be dealt to them?
	var/wallbang_multiplier = 0

/// Called when the throw has ended.
/datum/action/ability/activable/xeno/oppressor/proc/on_post_throw(datum/source)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE) // Because we don't want to forget to unregister the signal.
	UnregisterSignal(source, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT))

/// Called when the source has hit something.
/datum/action/ability/activable/xeno/oppressor/proc/on_throw_impact(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!isliving(source))
		return
	var/mob/living/living_source = source
	new /obj/effect/temp_visual/warrior/impact(living_source.loc, get_dir(living_source, xeno_owner))
	if(!wallbang_multiplier || !isclosedturf(hit_atom))
		return
	INVOKE_ASYNC(living_source, TYPE_PROC_REF(/mob, emote), "scream")
	living_source.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * wallbang_multiplier, BRUTE, blocked = MELEE, updating_health = TRUE, attacker = owner)

/datum/action/ability/activable/xeno/oppressor/abduct
	name = "Abduct"
	action_icon_state = "abduct"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Throw your tail out and hook in any humans caught in it. Ends prematurely if blocked or hits anything dense."
	ability_cost = 50
	cooldown_duration = 12 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ABDUCT,
	)
	/// A list of turfs that will be used to get mobs who will get affected by the ability.
	var/list/turf/turf_line
	/// The created effects that need to be deleted later.
	var/list/obj/effect/xeno/abduct_warning/telegraphed_atoms
	/// A timer for when to conclude the ability.
	var/ability_timer
	/// Multiplies various effects by this number. Changes whenever one or more human mobs are caught.
	var/last_known_multiplier = 1

/datum/action/ability/activable/xeno/oppressor/abduct/Destroy()
	cleanup_variables()
	return ..()

/datum/action/ability/activable/xeno/oppressor/abduct/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(ability_timer)
		if(!silent)
			A.balloon_alert(xeno_owner, "already abducting")
		return FALSE
	var/distance_to_target = get_dist(xeno_owner, A)
	if(!distance_to_target)
		if(!silent)
			A.balloon_alert(xeno_owner, "too short")
		return FALSE
	var/start_turf = get_step(xeno_owner, get_cardinal_dir(xeno_owner, A))
	if(check_path(xeno_owner, start_turf, PASS_THROW) != start_turf)
		if(!silent)
			A.balloon_alert(xeno_owner, "path blocked")
		return FALSE

/datum/action/ability/activable/xeno/oppressor/abduct/use_ability(atom/A)
	var/turf/targetted_turf = get_turf(A)
	while(get_dist(xeno_owner, targetted_turf) > 7) // Allows targetting beyond maximum range to automatically do maximum range.
		targetted_turf = get_step(targetted_turf, REVERSE_DIR(get_dir(xeno_owner, targetted_turf)))

	xeno_owner.face_atom(targetted_turf)
	if(!do_after(owner, 0.1 SECONDS, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER) || !can_use_ability(targetted_turf, TRUE, ABILITY_IGNORE_SELECTED_ABILITY))
		add_cooldown(1 SECONDS)
		return
	xeno_owner.face_atom(targetted_turf)
	turf_line = get_traversal_line(get_step(xeno_owner, get_cardinal_dir(xeno_owner, targetted_turf)), check_path(xeno_owner, targetted_turf, PASS_THROW))
	LAZYINITLIST(telegraphed_atoms)
	for(var/turf/turf_from_line AS in turf_line)
		telegraphed_atoms += new /obj/effect/xeno/abduct_warning(turf_from_line)
	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, XENO_TRAIT)
	ability_timer = addtimer(CALLBACK(src, PROC_REF(pull_them_in)), 0.7 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(failed_pull))
	RegisterSignal(xeno_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(failed_pull))

/datum/action/ability/activable/xeno/oppressor/abduct/on_post_throw(datum/source)
	. = ..()
	var/mob/living/carbon/human/human_source = source
	human_source.Paralyze(0.2 SECONDS * last_known_multiplier)
	human_source.add_slowdown(0.6 * last_known_multiplier)
	human_source.adjust_stagger(3 SECONDS * last_known_multiplier)
	REMOVE_TRAIT(human_source, TRAIT_IMMOBILE, THROW_TRAIT)
	human_source.allow_pass_flags &= ~(PASS_MOB|PASS_XENO)

/// Ends the ability by throwing all humans in the affected turfs to the initial turf.
/datum/action/ability/activable/xeno/oppressor/abduct/proc/pull_them_in()
	SIGNAL_HANDLER
	var/list/mob/living/carbon/human/human_mobs = list()
	for(var/turf/turf_from_line AS in turf_line)
		for(var/atom/movable/target AS in turf_from_line.contents)
			if(!ishuman(target))
				continue
			var/mob/living/carbon/human/human_mob = target
			if(human_mob.stat == DEAD)
				continue
			if(human_mob.move_resist >= MOVE_FORCE_OVERPOWERING)
				continue
			human_mobs += human_mob
			human_mob.allow_pass_flags |= (PASS_MOB|PASS_XENO) // Without this, groups of affected humans will bump into each other while being thrown.

	last_known_multiplier = human_mobs.len
	if(last_known_multiplier)
		for(var/mob/living/carbon/human/human_mob in human_mobs)
			RegisterSignal(human_mob, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_post_throw))
			ADD_TRAIT(human_mob, TRAIT_IMMOBILE, THROW_TRAIT) // Given that this throw will be slow compared to other abilities, we do not want humans to move DURING it.
			human_mob.throw_at(turf_line[1], 6, 2, xeno_owner, TRUE)
			INVOKE_ASYNC(human_mob, TYPE_PROC_REF(/mob/living/carbon/human, apply_damage), xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, STAMINA, null, 0, FALSE, FALSE, TRUE, 0, owner)
		xeno_owner.add_slowdown(0.3 * last_known_multiplier)
		playsound(human_mobs[human_mobs.len], 'sound/voice/alien/pounce.ogg', 25, TRUE)
	succeed_activate()
	add_cooldown()
	cleanup_variables()

/// Ends the ability by punishing the owner.
/datum/action/ability/activable/xeno/oppressor/abduct/proc/failed_pull()
	SIGNAL_HANDLER
	xeno_owner.Knockdown(1 SECONDS)
	xeno_owner.add_slowdown(0.9)
	succeed_activate()
	add_cooldown()
	cleanup_variables()

/// Cleans up any unneeded variables, signals, and undoes any traits that the ability gave.
/datum/action/ability/activable/xeno/oppressor/abduct/proc/cleanup_variables()
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, XENO_TRAIT)
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(xeno_owner, COMSIG_LIVING_STATUS_STAGGER)
	QDEL_LIST(telegraphed_atoms)
	deltimer(ability_timer)
	ability_timer = null
	telegraphed_atoms = null
	turf_line = null

/obj/effect/xeno/abduct_warning
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "abduct_hook"

/obj/effect/xeno/abduct_warning/Initialize(mapload)
	. = ..()
	notify_ai_hazard()

// ***************************************
// *********** Dislocate
// ***************************************
/datum/action/ability/activable/xeno/oppressor/dislocate
	name = "Dislocate"
	action_icon_state = "punch"
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	desc = "Shrike a human with enough force that they are thrown backwards."
	ability_cost = 50
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DISLOCATE,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/oppressor/dislocate/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target)) // No balloon as it can get really spammy.
		return FALSE
	if(isxeno(target))
		var/mob/living/carbon/xenomorph/xenomorph_target = target
		if(xeno_owner.issamexenohive(xenomorph_target))
			if(!silent)
				target.balloon_alert(xeno_owner, "cannot dislocate ally")
			return FALSE
	var/mob/living/carbon/carbon_target = target
	if(!xeno_owner.Adjacent(carbon_target))
		carbon_target.balloon_alert(xeno_owner, "too far")
		return FALSE
	if(carbon_target.stat == DEAD)
		carbon_target.balloon_alert(xeno_owner, "already dead")
		return FALSE

/datum/action/ability/activable/xeno/oppressor/dislocate/use_ability(atom/target)
	var/mob/living/carbon/carbon_target = target
	var/datum/limb/target_limb = carbon_target.get_limb(xeno_owner.zone_selected)
	if(!target_limb || (target_limb.limb_status & LIMB_DESTROYED))
		target_limb = carbon_target.get_limb(BODY_ZONE_CHEST)

	xeno_owner.face_atom(target)

	carbon_target.Shake(duration = 0.1 SECONDS)
	xeno_owner.do_attack_animation(carbon_target)
	new /obj/effect/temp_visual/warrior/punch/weak(get_turf(carbon_target))
	playsound(target, 'sound/weapons/punch1.ogg', 25, TRUE)

	RegisterSignal(carbon_target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(carbon_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_post_throw))
	carbon_target.throw_at(get_step(carbon_target, get_dir(xeno_owner, carbon_target)), 2, 2, xeno_owner, TRUE)
	carbon_target.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, BRUTE, target_limb ? target_limb : 0, MELEE, attacker = owner)

	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/oppressor/dislocate/on_post_throw(datum/source)
	. = ..()
	var/mob/living/carbon/carbon_source = source
	carbon_source.Paralyze(0.8 SECONDS)
	carbon_source.adjust_stagger(2.4 SECONDS)

// ***************************************
// *********** Item Throw
// ***************************************
/datum/action/ability/activable/xeno/item_throw
	name = "Item Throw"
	action_icon_state = "item_throw"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Pick up a nearby item momentarily and throw it in a chosen direction. The item's size determines elements such as how fast or hard it hits."
	ability_cost = 50
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ITEM_THROW,
	)
	use_state_flags = ABILITY_USE_STAGGERED
	/// If they have moved at least a single tile since picking up an item.
	var/has_moved_already = FALSE
	/// If we are holding an item.
	var/obj/item/held_item
	/// Mutable appearance of the held item.
	var/mutable_appearance/held_appearance

/datum/action/ability/activable/xeno/item_throw/Destroy()
	drop_item()
	return ..()

/datum/action/ability/activable/xeno/item_throw/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(held_item)
		return TRUE
	if(!isitem(A) || isgrabitem(A))
		if(!silent)
			A.balloon_alert(owner, "not an item")
		return FALSE
	var/obj/item/item_atom = A
	if(!owner.Adjacent(item_atom))
		if(!silent)
			item_atom.balloon_alert(owner, "too far")
		return FALSE
	if(item_atom.anchored)
		if(!silent)
			item_atom.balloon_alert(owner, "item is anchored")
		return FALSE

/datum/action/ability/activable/xeno/item_throw/use_ability(atom/A)
	if(!held_item)
		playsound(owner, 'sound/voice/alien/pounce2.ogg', 30)
		var/obj/item/interacted_item = A
		interacted_item.forceMove(owner)
		held_item = interacted_item
		held_appearance = mutable_appearance(interacted_item.icon, interacted_item.icon_state)
		held_appearance.layer = ABOVE_OBJ_LAYER
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_owner_turn))
		RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(drop_item))
		RegisterSignal(owner, COMSIG_MOB_STAT_CHANGED, PROC_REF(drop_item)) // No need to check for the specifics regarding stat as anything that isn't CONSCIOUS should cause it to drop.
		RegisterSignal(held_item, COMSIG_QDELETING, PROC_REF(on_item_qdel))

		owner.add_movespeed_modifier(MOVESPEED_ID_OPPRESSOR_ITEM_GRAB, TRUE, 0, NONE, TRUE, 2)
		on_owner_turn(null, null, owner.dir)
		succeed_activate()
		ability_cost = 0 // Throwing will cost nothing to prevent the ability from failing to recast if they happen to have not enough plasma.
		has_moved_already = FALSE
		return
	owner.remove_movespeed_modifier(MOVESPEED_ID_OPPRESSOR_ITEM_GRAB)
	held_item.throwforce += min(held_item.w_class * 15, 90) // Upper limit to prevent any weird weight classes (e.g. above WEIGHT_CLASS_GIGANTIC)
	RegisterSignal(held_item, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_throw_end))
	held_item.forceMove(get_turf(owner))
	// A speed of 5 is required to inflict maximum damage to mobs.
	held_item.throw_at(A, max(2, 11 - (held_item.w_class * 2)), 5)
	held_item = null
	owner.overlays -= held_appearance
	playsound(xeno_owner, 'sound/effects/throw.ogg', 30, 1)
	succeed_activate()
	ability_cost = initial(ability_cost)
	add_cooldown()
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOB_DEATH, COMSIG_MOB_STAT_CHANGED))

/// Reduces throwforce by what it was increased by.
/datum/action/ability/activable/xeno/item_throw/proc/on_throw_end(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_POST_THROW, COMSIG_QDELETING))
	var/obj/item/item_source = source
	item_source.throwforce -= min(item_source.w_class * 15, 90)

/// On move, drop the item if they moved once already. Otherwise, set it so that they'll drop the item if they move again.
/datum/action/ability/activable/xeno/item_throw/proc/on_move()
	SIGNAL_HANDLER
	if(!has_moved_already)
		has_moved_already = TRUE
		return
	drop_item()

/// Drops the item on the floor, thus ending the ability.
/datum/action/ability/activable/xeno/item_throw/proc/drop_item()
	if(!held_item)
		return
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOB_DEATH, COMSIG_MOB_STAT_CHANGED))
	UnregisterSignal(held_item, COMSIG_QDELETING)
	held_item.forceMove(get_turf(owner))
	held_item = null
	owner.remove_movespeed_modifier(MOVESPEED_ID_OPPRESSOR_ITEM_GRAB)
	owner.overlays -= held_appearance
	held_appearance = null
	playsound(owner, 'sound/voice/alien/pounce2.ogg', 30, frequency = -1)
	add_cooldown()

/// Handles the unexpected qdel of the held item.
/datum/action/ability/activable/xeno/item_throw/proc/on_item_qdel()
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOB_DEATH, COMSIG_MOB_STAT_CHANGED))
	held_item = null
	owner.remove_movespeed_modifier(MOVESPEED_ID_OPPRESSOR_ITEM_GRAB)
	owner.overlays -= held_appearance
	held_appearance = null
	add_cooldown()

/// Turns the held_appearance accordingly whenever the owner turns.
/datum/action/ability/activable/xeno/item_throw/proc/on_owner_turn(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!new_dir || new_dir == old_dir)
		return
	owner.overlays -= held_appearance
	var/matrix/new_transform = held_appearance.transform
	switch(old_dir)
		if(NORTH)
			new_transform.Translate(-15, -12)
		if(SOUTH)
			new_transform.Translate(-15, 12)
		if(EAST)
			new_transform.Translate(-35, 0)
		if(WEST)
			new_transform.Translate(5, 0)
	switch(new_dir)
		if(NORTH)
			new_transform.Translate(15, 12)
		if(SOUTH)
			new_transform.Translate(15, -12)
		if(EAST)
			new_transform.Translate(35, 0)
		if(WEST)
			new_transform.Translate(-5, 0)
	held_appearance.transform = new_transform
	owner.overlays += held_appearance

// ***************************************
// *********** Tail Lash
// ***************************************
/datum/action/ability/activable/xeno/oppressor/tail_lash
	name = "Tail Lash"
	action_icon_state = "tail_lash"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Knock back humans that are in front of you."
	ability_cost = 50
	cooldown_duration = 11 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY | ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_LASH,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TAIL_LASH_SELECT,
	)

/datum/action/ability/activable/xeno/oppressor/tail_lash/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y + 2, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 1, xeno_owner.z)

	for(var/turf/affected_tile AS in block(lower_left, upper_right))
		affected_tile.Shake(duration = 0.1 SECONDS)
		for(var/atom/movable/affected AS in affected_tile)
			if(!ishuman(affected) || affected.move_resist >= MOVE_FORCE_OVERPOWERING)
				continue
			var/mob/living/carbon/human/affected_human = affected
			if(affected_human.stat == DEAD)
				continue
			RegisterSignal(affected_human, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
			RegisterSignal(affected_human, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_post_throw))
			affected_human.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, STAMINA, updating_health = TRUE, attacker = owner)
			var/throwlocation = affected_human.loc
			for(var/x in 1 to 2)
				throwlocation = get_step(throwlocation, owner.dir)
			affected_human.throw_at(throwlocation, 2, 1, owner, TRUE)

	xeno_owner.spin(4, 1)
	xeno_owner.emote("tail")
	playsound(xeno_owner, 'sound/weapons/alien_claw_block.ogg', 50, 1)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/oppressor/tail_lash/on_post_throw(datum/source)
	. = ..()
	var/mob/living/carbon/human/human_source = source
	human_source.Paralyze(0.8 SECONDS)
	human_source.adjust_stagger(2.4 SECONDS)

// ***************************************
// *********** Advance (Oppressor)
// ***************************************
/datum/action/ability/activable/xeno/oppressor/advance
	name = "Advance"
	action_icon_state = "advance"
	action_icon = 'icons/Xeno/actions/praetorian.dmi'
	desc = "Launch yourself with tremendous speed toward a location. If you hit a marine, they are launched incredibly far."
	ability_cost = 50
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ADVANCE_OPPRESSOR,
	)
	/// How long does it take to complete the do_after?
	var/cast_time = 0.8 SECONDS
	/// How far will humans that are hit be thrown? This is rounded down to the nearest whole number.
	var/throw_range = 5
	/// How long should humans that are hit be paralyzed?
	var/paralyze_duration = 1.5 SECONDS
	/// Should the owner gain a movement speed modifier for 6 seconds after using Advance? If so, what amount should be it?
	var/movement_speed_modifier = 0
	/// The id of the timer that will remove the movement speed modifier.
	var/timer_id

/datum/action/ability/activable/xeno/oppressor/advance/remove_action(mob/living/L)
	revoke_movespeed_modifier()
	return ..()

/datum/action/ability/activable/xeno/oppressor/advance/use_ability(atom/target)
	xeno_owner.face_atom(target)
	if(!do_after(xeno_owner, cast_time, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER))
		return
	xeno_owner.face_atom(target)

	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	xeno_owner.xeno_flags |= XENO_LEAPING

	if(movement_speed_modifier)
		xeno_owner.add_movespeed_modifier(MOVESPEED_ID_OPPRESSOR_ADVANCE, TRUE, 0, NONE, TRUE, movement_speed_modifier)
		timer_id = addtimer(CALLBACK(src, PROC_REF(revoke_movespeed_modifier)), 6 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
	xeno_owner.throw_at(target, 5, 5, xeno_owner)
	xeno_owner.emote("roar")
	succeed_activate()
	add_cooldown()

/// Called when the throw has ended for the impacted human.
/datum/action/ability/activable/xeno/oppressor/advance/on_post_throw(datum/source)
	. = ..()
	var/mob/living/living_source = source
	living_source.Paralyze(paralyze_duration)

/// Shake the turf under for cool points.
/datum/action/ability/activable/xeno/oppressor/advance/proc/on_move(datum/source)
	SIGNAL_HANDLER
	var/turf/current_turf = get_turf(source)
	current_turf.Shake(duration = 0.2 SECONDS)

/// Ends the charge when hitting an object.
/datum/action/ability/activable/xeno/oppressor/advance/proc/obj_hit(datum/source, obj/obj_hit, speed)
	SIGNAL_HANDLER
	obj_hit.hitby(xeno_owner, speed)

/// Ends the charge when hitting a human. Knocks them back pretty far.
/datum/action/ability/activable/xeno/oppressor/advance/proc/mob_hit(datum/source, mob/living/living_hit)
	SIGNAL_HANDLER
	if(!ishuman(living_hit) || living_hit.move_resist >= MOVE_FORCE_OVERPOWERING)
		return

	RegisterSignal(living_hit, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	RegisterSignal(living_hit, COMSIG_MOVABLE_POST_THROW, PROC_REF(on_post_throw))
	living_hit.throw_at(get_step_rand(get_ranged_target_turf(living_hit, get_dir(xeno_owner, living_hit), 5)), FLOOR(throw_range, 1), 5, xeno_owner, TRUE)
	INVOKE_ASYNC(living_hit, TYPE_PROC_REF(/mob/living/carbon/human, apply_damage), xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, BRUTE, xeno_owner.zone_selected, MELEE, FALSE, FALSE, TRUE, 0, owner)

/// Cleans up after charge is finished.
/datum/action/ability/activable/xeno/oppressor/advance/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENOMORPH_LEAP_BUMP))
	xeno_owner.xeno_flags &= ~XENO_LEAPING

/// Removes the movement speed modifier, if any.
/datum/action/ability/activable/xeno/oppressor/advance/proc/revoke_movespeed_modifier()
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_OPPRESSOR_ADVANCE)
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
