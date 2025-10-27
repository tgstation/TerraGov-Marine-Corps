// ***************************************
// *********** Empower
// ***************************************
#define WARRIOR_EMPOWER_COMBO_THRESHOLD 2 // After how many abilities should a Warrior get an empowered cast (2 means the 3rd one is empowered).
#define WARRIOR_EMPOWER_COMBO_FADE_TIME 10 SECONDS // The duration of a combo, after which it will disappear by itself.

/datum/action/ability/xeno_action/empower
	name = "Empower"
	/// Holds the fade-out timer.
	var/fade_timer
	/// The amount of abilities we've chained together.
	var/combo_count = 0
	/// List of abilities that can be empowered.
	var/list/empowerable_actions = list(
		/datum/action/ability/activable/xeno/warrior/fling,
		/datum/action/ability/activable/xeno/warrior/grapple_toss,
		/datum/action/ability/activable/xeno/warrior/punch,
		/datum/action/ability/activable/xeno/warrior/punch/flurry,
	)
	hidden = TRUE

/// Checks if Empower is capped and gives bonuses if so, otherwise increases combo count.
/datum/action/ability/xeno_action/empower/proc/check_empower(atom/target)
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD || living_target.issamexenohive(owner))
			return FALSE
	if(combo_count >= WARRIOR_EMPOWER_COMBO_THRESHOLD)
		xeno_owner.emote("roar")
		clear_empower()
		return TRUE
	activate_empower()
	return FALSE

/// Handles empowering, and gives visual feedback if applicable.
/datum/action/ability/xeno_action/empower/proc/activate_empower()
	combo_count++
	if(combo_count >= WARRIOR_EMPOWER_COMBO_THRESHOLD)
		for(var/datum/action/ability/activable/xeno/warrior/warrior_action AS in xeno_owner.actions)
			if(warrior_action.type in empowerable_actions)
				warrior_action.add_empowered_frame()
				warrior_action.update_button_icon()
	fade_timer = addtimer(CALLBACK(src, PROC_REF(empower_fade)), WARRIOR_EMPOWER_COMBO_FADE_TIME, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_STOPPABLE)

/// Clears empowering, as well as visual feedback and combo count.
/datum/action/ability/xeno_action/empower/proc/clear_empower()
	for(var/datum/action/ability/activable/xeno/warrior/warrior_action AS in xeno_owner.actions)
		if(warrior_action.type in empowerable_actions)
			warrior_action.remove_empowered_frame()
			warrior_action.update_button_icon()
	combo_count = initial(combo_count)
	deltimer(fade_timer)

/// Happens when Empower fades.
/datum/action/ability/xeno_action/empower/proc/empower_fade()
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 25, 0, 1)
	clear_empower()


// ***************************************
// *********** Agility
// ***************************************
#define WARRIOR_AGILITY_SPEED_MODIFIER -0.6
#define WARRIOR_AGILITY_ARMOR_MODIFIER -30

/datum/action/ability/xeno_action/toggle_agility
	name = "Agility"
	action_icon_state = "agility_on"
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	cooldown_duration = 0.4 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_AGILITY,
	)
	action_type = ACTION_TOGGLE
	/// The speed modifier to be applied.
	var/speed_modifier = WARRIOR_AGILITY_SPEED_MODIFIER
	/// The armor modifier to be applied.
	var/armor_modifier = WARRIOR_AGILITY_ARMOR_MODIFIER
	/// The attached armor to eventually remove.
	var/datum/armor/attached_armor

/datum/action/ability/xeno_action/toggle_agility/New(Target)
	. = ..()
	desc = "Move on all fours and loosen our scales. Increases movement speed by [abs(speed_modifier)], but reduces all soft armor by [armor_modifier]. Automatically disabled after using an ability."

/datum/action/ability/xeno_action/toggle_agility/action_activate()
	GLOB.round_statistics.warrior_agility_toggles++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_agility_toggles")
	toggled = !toggled
	set_toggle(toggled)
	xeno_owner.update_icons()
	add_cooldown()
	if(!toggled)
		xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY)
		xeno_owner.soft_armor = xeno_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null
		return
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY, TRUE, 0, NONE, TRUE, speed_modifier)
	attached_armor = new(armor_modifier, armor_modifier, armor_modifier, armor_modifier, armor_modifier, armor_modifier, armor_modifier, armor_modifier)
	xeno_owner.soft_armor = xeno_owner.soft_armor.attachArmor(attached_armor)
	xeno_owner.toggle_move_intent(MOVE_INTENT_RUN)

// ***************************************
// *********** Parent Ability
// ***************************************
#define WARRIOR_IMPACT_DAMAGE_MULTIPLIER 1.0
#define WARRIOR_DISPLACE_KNOCKDOWN 0.4 SECONDS

/datum/action/ability/activable/xeno/warrior/use_ability(atom/A)
	var/datum/action/ability/xeno_action/toggle_agility/agility_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/toggle_agility]
	if(agility_action?.toggled)
		agility_action.action_activate()

/// Adds an outline around the ability button to represent Empower.
/datum/action/ability/activable/xeno/warrior/proc/add_empowered_frame()
	button.add_overlay(visual_references[VREF_MUTABLE_EMPOWERED_FRAME])

/// Removes the Empower outline.
/datum/action/ability/activable/xeno/warrior/proc/remove_empowered_frame()
	button.cut_overlay(visual_references[VREF_MUTABLE_EMPOWERED_FRAME])

/// Handles anything that would happen when a target is thrown into an atom using an ability.
/datum/action/ability/activable/xeno/warrior/proc/thrown_into(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/mob/living/living_target = source
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")
	living_target.Knockdown(WARRIOR_DISPLACE_KNOCKDOWN)
	new /obj/effect/temp_visual/warrior/impact(get_turf(living_target), get_dir(living_target, xeno_owner))
	// mob/living/turf_collision() does speed * 5 damage on impact with a turf, and we don't want to go overboard, so we deduce that here.
	var/thrown_damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * WARRIOR_IMPACT_DAMAGE_MULTIPLIER
	living_target.apply_damage(thrown_damage, BRUTE, blocked = MELEE, attacker = owner)
	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		if(hit_living.issamexenohive(xeno_owner))
			return
		INVOKE_ASYNC(hit_living, TYPE_PROC_REF(/mob, emote), "scream")
		hit_living.apply_damage(thrown_damage, BRUTE, blocked = MELEE, attacker = owner)
		hit_living.Knockdown(WARRIOR_DISPLACE_KNOCKDOWN)
		step_away(hit_living, living_target, 1, 1)
	if(isobj(hit_atom))
		var/obj/hit_object = hit_atom
		if(istype(hit_object, /obj/structure/xeno))
			return
		hit_object.take_damage(thrown_damage, BRUTE, MELEE)
	if(iswallturf(hit_atom))
		var/turf/closed/wall/hit_wall = hit_atom
		if(!(hit_wall.resistance_flags & INDESTRUCTIBLE))
			hit_wall.take_damage(thrown_damage, BRUTE, MELEE)

/// Ends the target's throw.
/datum/action/ability/activable/xeno/warrior/proc/throw_ended(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT))
	var/mob/living/living_target = source
	living_target.Knockdown(0.5 SECONDS)
	living_target.remove_pass_flags(PASS_XENO, THROW_TRAIT)

/obj/effect/temp_visual/warrior/impact
	icon = 'icons/effects/96x96.dmi'
	icon_state = "throw_impact"
	duration = 3.5
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/warrior/impact/Initialize(mapload, direction)
	. = ..()
	animate(src, alpha = 0, time = duration - 1.5)
	// directions refuse to work naturally so i improvised, suck it byond
	direction = closest_cardinal_dir(direction)
	switch(direction)
		if(NORTH)
			icon_state = "[initial(icon_state)]_n"
			pixel_y -= 20
		if(SOUTH)
			icon_state = "[initial(icon_state)]_s"
			pixel_y += 20
		if(WEST)
			icon_state = "[initial(icon_state)]_w"
			pixel_x += 20
		if(EAST)
			icon_state = "[initial(icon_state)]_e"
			pixel_x -= 20


// ***************************************
// *********** Lunge
// ***************************************
#define WARRIOR_LUNGE_RANGE 4.5

/datum/action/ability/activable/xeno/warrior/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	ability_cost = 30
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LUNGE,
	)
	target_flags = ABILITY_MOB_TARGET
	/// The starting amount of distance that Fling can go. Compared against euclidean distance. Rounded down for lunge throw.
	var/starting_lunge_distance = WARRIOR_LUNGE_RANGE
	/// The target of our lunge, we keep it to check if we are adjacent every time we move.
	var/atom/lunge_target

/datum/action/ability/activable/xeno/warrior/lunge/New(Target)
	. = ..()
	desc = "Lunge towards a target within [starting_lunge_distance] tiles, putting them in our grasp. Usable on allies."

/datum/action/ability/activable/xeno/warrior/lunge/on_cooldown_finish()
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/warrior/lunge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(A))
		if(!silent)
			owner.balloon_alert(owner, "Invalid target")
		return FALSE
	var/mob/living/living_target = A
	if(living_target.stat == DEAD && !living_target.issamexenohive(owner))
		if(!silent)
			owner.balloon_alert(owner, "Dead")
		return FALSE
	if(get_dist_euclidean(living_target, owner) > starting_lunge_distance)
		if(!silent)
			owner.balloon_alert(owner, "Too far")
		return FALSE

/datum/action/ability/activable/xeno/warrior/lunge/use_ability(atom/A)
	. = ..()
	GLOB.round_statistics.warrior_lunges++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_lunges")
	xeno_owner.add_filter("warrior_lunge", 2, gauss_blur_filter(3))
	lunge_target = A
	succeed_activate()
	add_cooldown()
	if(lunge_target.Adjacent(xeno_owner)) // They're already in range, neck grab without lunging.
		lunge_grab(lunge_target)
		return
	RegisterSignal(lunge_target, COMSIG_QDELETING, PROC_REF(clean_lunge_target))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_if_lunge_possible))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(clean_lunge_target))
	xeno_owner.throw_at(get_step_towards(A, xeno_owner), FLOOR(starting_lunge_distance, 1), 2, xeno_owner)

/// Check if we are close enough to grab.
/datum/action/ability/activable/xeno/warrior/lunge/proc/check_if_lunge_possible(datum/source)
	SIGNAL_HANDLER
	if(lunge_target.Adjacent(source))
		INVOKE_ASYNC(src, PROC_REF(lunge_grab), lunge_target)

/// Null lunge target and reset related vars.
/datum/action/ability/activable/xeno/warrior/lunge/proc/clean_lunge_target()
	SIGNAL_HANDLER
	UnregisterSignal(lunge_target, COMSIG_QDELETING)
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_POST_THROW))
	lunge_target = null
	owner.set_throwing(FALSE)
	owner.remove_filter("warrior_lunge")

/// Do the grab on the target, and clean all previous vars
/datum/action/ability/activable/xeno/warrior/lunge/proc/lunge_grab(atom/A)
	clean_lunge_target()
	xeno_owner.swap_hand()
	if(xeno_owner.start_pulling(A) && isliving(A) && !xeno_owner.issamexenohive(A))
		var/mob/living/living_target = A
		GLOB.round_statistics.warrior_grabs++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_grabs")
		xeno_owner.setGrabState(GRAB_NECK)
		living_target.resistance_flags |= RESTRAINED_NECKGRAB
		living_target.drop_all_held_items()
		living_target.Paralyze(0.1 SECONDS)
		living_target.balloon_alert(xeno_owner, "Grabbed [living_target]")

	xeno_owner.swap_hand()
	var/datum/action/ability/xeno_action/empower/empower_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/empower]
	if(empower_action?.combo_count < WARRIOR_EMPOWER_COMBO_THRESHOLD)
		empower_action?.activate_empower()

////////////////////////
/datum/action/ability/activable/xeno/warrior/lunge/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/warrior/lunge/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 2))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


// ***************************************
// *********** Fling
// ***************************************
#define WARRIOR_FLING_TOSS_COOLDOWN 20 SECONDS
#define WARRIOR_FLING_DISTANCE 4 // in tiles
#define WARRIOR_FLING_EMPOWER_MULTIPLIER 2

/datum/action/ability/activable/xeno/warrior/fling
	name = "Fling"
	action_icon_state = "fling"
	action_icon = 'icons/Xeno/actions/shrike.dmi'
	ability_cost = 20
	cooldown_duration = WARRIOR_FLING_TOSS_COOLDOWN
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FLING,
	)
	target_flags = ABILITY_MOB_TARGET
	/// The starting amount of distance that Fling can go.
	var/starting_fling_distance = WARRIOR_FLING_DISTANCE
	/// The multiplier used for the cooldown duration if the ability was used on an allied xenomorph.
	var/ally_cooldown_multiplier = 1

/datum/action/ability/activable/xeno/warrior/fling/New(Target)
	. = ..()
	desc = "Send a target flying up to [starting_fling_distance] tiles away. Distance reduced for bigger targets. Usable on allies."

/datum/action/ability/activable/xeno/warrior/fling/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE
	if(!isliving(A))
		if(!silent)
			owner.balloon_alert(owner, "Invalid target")
		return FALSE
	var/mob/living/living_target = A
	if(living_target.stat == DEAD && !living_target.issamexenohive(owner))
		if(!silent)
			owner.balloon_alert(owner, "Dead")
		return FALSE
	if(!living_target.Adjacent(owner))
		if(!silent)
			owner.balloon_alert(owner, "Not adjacent")
		return FALSE

/datum/action/ability/activable/xeno/warrior/fling/use_ability(atom/A)
	. = ..()
	GLOB.round_statistics.warrior_flings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_flings")
	var/mob/living/living_target = A
	xeno_owner.face_atom(living_target)
	playsound(living_target, 'sound/weapons/alien_claw_block.ogg', 75, 1)
	shake_camera(living_target, 1, 1)
	xeno_owner.do_attack_animation(living_target, ATTACK_EFFECT_DISARM2)
	var/fling_distance = starting_fling_distance
	if(living_target.mob_size >= MOB_SIZE_BIG) // Penalize fling distance for big creatures.
		fling_distance--
	var/datum/action/ability/xeno_action/empower/empower_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/empower]
	if(empower_action?.check_empower(living_target))
		fling_distance *= WARRIOR_FLING_EMPOWER_MULTIPLIER
	var/cooldown_to_set = cooldown_duration
	if(!living_target.issamexenohive(xeno_owner))
		RegisterSignal(living_target, COMSIG_MOVABLE_IMPACT, PROC_REF(thrown_into))
		RegisterSignal(living_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_ended))
	else
		cooldown_to_set *= ally_cooldown_multiplier
	living_target.add_pass_flags(PASS_XENO, THROW_TRAIT)
	var/fling_direction = get_dir(xeno_owner, living_target)
	living_target.throw_at(get_ranged_target_turf(xeno_owner, fling_direction ? fling_direction : xeno_owner.dir, fling_distance), fling_distance, 1, xeno_owner, TRUE)
	succeed_activate()
	add_cooldown(cooldown_to_set)
	var/datum/action/ability/activable/xeno/warrior/grapple_toss/toss_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/grapple_toss]
	toss_action?.add_cooldown(cooldown_to_set)

/datum/action/ability/activable/xeno/warrior/fling/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/warrior/fling/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


// ***************************************
// *********** Grapple Toss
// ***************************************
#define WARRIOR_GRAPPLE_TOSS_DISTANCE 4 // in tiles
#define WARRIOR_GRAPPLE_TOSS_STAGGER 3 SECONDS
#define WARRIOR_GRAPPLE_TOSS_SLOWDOWN 3
#define WARRIOR_GRAPPLE_TOSS_EMPOWER_MULTIPLIER 2
#define WARRIOR_GRAPPLE_TOSS_THROW_PARALYZE 0.5 SECONDS

/datum/action/ability/activable/xeno/warrior/grapple_toss
	name = "Grapple Toss"
	action_icon_state = "grapple_toss"
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	ability_cost = 20
	cooldown_duration = WARRIOR_FLING_TOSS_COOLDOWN
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GRAPPLE_TOSS,
	)
	target_flags = ABILITY_TURF_TARGET
	/// The starting amount of distance that Toss can go.
	var/starting_toss_distance = WARRIOR_GRAPPLE_TOSS_DISTANCE
	/// The multiplier used for the cooldown duration if the ability was used on an allied xenomorph.
	var/ally_cooldown_multiplier = 1

/datum/action/ability/activable/xeno/warrior/grapple_toss/New(Target)
	. = ..()
	desc = "Throw a creature under our grasp up to [starting_toss_distance] tiles away. Distance reduced on larger targets. Usable on allies."

/datum/action/ability/activable/xeno/warrior/grapple_toss/on_cooldown_finish()
	var/datum/action/ability/activable/xeno/warrior/fling/fling_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	xeno_owner.balloon_alert(xeno_owner, "[fling_action ? "[initial(fling_action.name)] / " : ""][initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/warrior/grapple_toss/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!owner.pulling)
		if(!silent)
			owner.balloon_alert(owner, "Nothing to toss")
		return FALSE
	if(!owner.Adjacent(owner.pulling))
		if(!silent)
			owner.balloon_alert(owner, "Target not adjacent")
		return FALSE

/datum/action/ability/activable/xeno/warrior/grapple_toss/use_ability(atom/A)
	. = ..()
	var/atom/movable/atom_target = xeno_owner.pulling
	var/fling_distance = starting_toss_distance
	var/datum/action/ability/xeno_action/empower/empower_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/empower]
	if(empower_action?.check_empower(atom_target))
		fling_distance *= WARRIOR_GRAPPLE_TOSS_EMPOWER_MULTIPLIER
	var/cooldown_to_set = cooldown_duration
	if(isliving(atom_target))
		var/mob/living/living_target = atom_target
		if(living_target.mob_size >= MOB_SIZE_BIG)
			fling_distance--
		if(!living_target.issamexenohive(xeno_owner))
			living_target.add_pass_flags(PASS_XENO, THROW_TRAIT)
			shake_camera(living_target, 1, 1)
			living_target.adjust_stagger(WARRIOR_GRAPPLE_TOSS_STAGGER)
			living_target.add_slowdown(WARRIOR_GRAPPLE_TOSS_SLOWDOWN)
			living_target.adjust_blurriness(WARRIOR_GRAPPLE_TOSS_SLOWDOWN)
			living_target.Paralyze(WARRIOR_GRAPPLE_TOSS_THROW_PARALYZE) // very important otherwise the guy can move right as you throw them
			RegisterSignal(living_target, COMSIG_MOVABLE_IMPACT, PROC_REF(thrown_into))
			RegisterSignal(living_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_ended))
		else
			cooldown_to_set *= ally_cooldown_multiplier
	xeno_owner.face_atom(atom_target)
	atom_target.forceMove(get_turf(xeno_owner))
	xeno_owner.do_attack_animation(atom_target, ATTACK_EFFECT_DISARM2)
	playsound(atom_target, 'sound/weapons/alien_claw_block.ogg', 75, 1)
	atom_target.throw_at(get_turf(A), fling_distance, 1, xeno_owner, TRUE)
	succeed_activate()
	add_cooldown(cooldown_to_set)
	var/datum/action/ability/activable/xeno/warrior/fling/fling_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/warrior/fling]
	fling_action?.add_cooldown(cooldown_to_set)


// ***************************************
// *********** Punch
// ***************************************
#define WARRIOR_PUNCH_SLOWDOWN 3
#define WARRIOR_PUNCH_STAGGER 3 SECONDS
#define WARRIOR_PUNCH_DAMAGE_MULTIPLIER 1.2
#define WARRIOR_PUNCH_EMPOWER_MULTIPLIER 1.5
#define WARRIOR_PUNCH_GRAPPLED_DAMAGE_MULTIPLIER 1.5
#define WARRIOR_PUNCH_GRAPPLED_DEBUFF_MULTIPLIER 1.5
#define WARRIOR_PUNCH_GRAPPLED_PARALYZE 0.5 SECONDS
#define WARRIOR_PUNCH_KNOCKBACK_DISTANCE 1 // in tiles
#define WARRIOR_PUNCH_KNOCKBACK_SPEED 1

/datum/action/ability/activable/xeno/warrior/punch
	name = "Punch"
	action_icon_state = "punch"
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	desc = "Strike a target, inflicting stamina damage, stagger and slowdown. Deals double damage, stagger and slowdown to grappled targets. Deals quadruple damage to structures and machinery."
	ability_cost = 15
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PUNCH,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/warrior/punch/on_cooldown_finish()
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/warrior/punch/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isliving(A) && !isstructure(A) && !ismachinery(A) && !isvehicle(A))
		if(!silent)
			owner.balloon_alert(owner, "Cannot punch")
		return FALSE
	if(A.resistance_flags & (INDESTRUCTIBLE|CRUSHER_IMMUNE))
		if(!silent)
			owner.balloon_alert(owner, "Cannot damage")
		return FALSE
	if(isliving(A))
		var/mob/living/living_target = A
		if(living_target.issamexenohive(owner))
			if(!silent)
				owner.balloon_alert(owner, "Cannot punch")
			return FALSE
		if(living_target.stat == DEAD)
			if(!silent)
				owner.balloon_alert(owner, "Dead")
			return FALSE
	if(!A.Adjacent(owner))
		if(!silent)
			owner.balloon_alert(owner, "Not adjacent")
		return FALSE

/datum/action/ability/activable/xeno/warrior/punch/use_ability(atom/A)
	. = ..()
	GLOB.round_statistics.warrior_punches++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_punches")
	do_ability(A)

/// Does the ability. Exists because Punch is the parent of another ability, so this lets us separate functionality and avoid repeating a few lines of code.
/datum/action/ability/activable/xeno/warrior/punch/proc/do_ability(atom/A)
	var/punch_damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * WARRIOR_PUNCH_DAMAGE_MULTIPLIER
	var/datum/action/ability/xeno_action/empower/empower_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/empower]
	if(empower_action?.check_empower(A))
		punch_damage *= WARRIOR_PUNCH_EMPOWER_MULTIPLIER
	if(!A.punch_act(xeno_owner, punch_damage))
		return fail_activate()
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/warrior/punch/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/warrior/punch/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

/// Handles anything that should happen when the Warrior's punch hits any atom.
/atom/proc/punch_act(mob/living/carbon/xenomorph/xeno, punch_damage, push = TRUE)
	return TRUE

/obj/machinery/punch_act(mob/living/carbon/xenomorph/xeno, punch_damage, ...)
	xeno.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	xeno.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	if(!(resistance_flags & UNACIDABLE) || resistance_flags & XENO_DAMAGEABLE) // If it's acidable or we can't acid it but it has the xeno damagable flag, we can damage it
		attack_generic(xeno, punch_damage * 4, BRUTE, effects = FALSE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)
	if(!(machine_stat & PANEL_OPEN))
		machine_stat |= PANEL_OPEN
	if(wires)
		var/allcut = wires.is_all_cut()
		if(!allcut)
			wires.cut_all()
	update_appearance()
	return TRUE

/obj/machinery/computer/punch_act(...)
	set_disabled() // Currently only computers use this; falcon punch away its density.
	return ..()

/obj/machinery/light/punch_act(mob/living/carbon/xenomorph/xeno, ...)
	. = ..()
	attack_alien(xeno)

/obj/machinery/camera/punch_act(...)
	. = ..()
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)
	sparks.start()
	deactivate()

/obj/machinery/power/apc/punch_act(...)
	. = ..()
	beenhit += 4 // Break it open instantly.
	update_appearance()

/obj/machinery/vending/punch_act(...)
	. = ..()
	if(tipped_level < 2)
		tip_over()

/obj/structure/punch_act(mob/living/carbon/xenomorph/xeno, punch_damage, ...)
	. = ..()
	xeno.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	xeno.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	attack_alien(xeno, punch_damage * 4, BRUTE, effects = FALSE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)

/obj/vehicle/punch_act(mob/living/carbon/xenomorph/xeno, punch_damage, ...)
	. = ..()
	xeno.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	xeno.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	attack_generic(xeno, punch_damage * 4, BRUTE, effects = FALSE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)
	return TRUE

/obj/vehicle/sealed/mecha/combat/greyscale/punch_act(mob/living/carbon/xenomorph/xeno, punch_damage, ...)
	. = ..()
	xeno.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	xeno.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	attack_generic(xeno, punch_damage * 3, BRUTE, effects = FALSE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)
	return TRUE

/mob/living/punch_act(mob/living/carbon/xenomorph/warrior/xeno, punch_damage, push = TRUE)
	. = ..()
	var/slowdown_stacks = WARRIOR_PUNCH_SLOWDOWN
	var/stagger_stacks = WARRIOR_PUNCH_STAGGER
	var/visual_effect = /obj/effect/temp_visual/warrior/punch/weak
	var/sound_effect = 'sound/weapons/punch1.ogg'
	if(pulledby == xeno)
		xeno.stop_pulling()
		punch_damage *= WARRIOR_PUNCH_GRAPPLED_DAMAGE_MULTIPLIER
		slowdown_stacks *= WARRIOR_PUNCH_GRAPPLED_DEBUFF_MULTIPLIER
		stagger_stacks *= WARRIOR_PUNCH_GRAPPLED_DEBUFF_MULTIPLIER
		visual_effect = /obj/effect/temp_visual/warrior/punch/strong
		sound_effect = 'sound/weapons/punch2.ogg'
		Paralyze(WARRIOR_PUNCH_GRAPPLED_PARALYZE)
		Shake(duration = 0.5 SECONDS)
	var/datum/limb/target_limb
	if(!iscarbon(src))
		var/mob/living/carbon/carbon_target = src
		target_limb = carbon_target.get_limb(xeno.zone_selected)
		if(!target_limb || (target_limb.limb_status & LIMB_DESTROYED))
			target_limb = carbon_target.get_limb(BODY_ZONE_CHEST)
	xeno.face_atom(src)
	xeno.do_attack_animation(src)
	new visual_effect(get_turf(src))
	playsound(src, sound_effect, 50, 1)
	shake_camera(src, 1, 1)
	add_slowdown(slowdown_stacks)
	adjust_stagger(stagger_stacks)
	adjust_blurriness(slowdown_stacks)
	apply_damage(punch_damage, BRUTE, target_limb ? target_limb : 0, MELEE, attacker = xeno)
	apply_damage(punch_damage, STAMINA, updating_health = TRUE, attacker = xeno)
	var/turf_behind = get_step(src, REVERSE_DIR(get_dir(src, xeno)))
	if(!push)
		return
	if(LinkBlocked(get_turf(src), turf_behind))
		do_attack_animation(turf_behind)
		return
	knockback(xeno, WARRIOR_PUNCH_KNOCKBACK_DISTANCE, WARRIOR_PUNCH_KNOCKBACK_SPEED)

/obj/effect/temp_visual/warrior/punch
	icon = 'icons/effects/effects.dmi'
	icon_state = "weak_punch"
	duration = 2.5
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/warrior/punch/weak/Initialize(mapload)
	. = ..()
	animate(src, time = duration + 1, alpha = 0)

/obj/effect/temp_visual/warrior/punch/strong
	icon = 'icons/effects/64x64.dmi'
	icon_state = "strong_punch"
	duration = 3
	pixel_x = -16
	pixel_y = -16


// ***************************************
// *********** Flurry
// ***************************************
#define WARRIOR_JAB_DAMAGE_MULTIPLIER 0.25
#define WARRIOR_JAB_BLIND 3
#define WARRIOR_JAB_BLUR 6
#define WARRIOR_JAB_CONFUSION_DURATION 3 SECONDS

/datum/action/ability/activable/xeno/warrior/punch/flurry
	name = "Flurry"
	action_icon_state = "flurry"
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	desc = "Strike at your target with blinding speed."
	ability_cost = 10
	cooldown_duration = 7 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_JAB,
	)
	/// The amount of charges we currently have. Initial value is assumed to be the maximum.
	var/current_charges = 3

/datum/action/ability/activable/xeno/warrior/punch/flurry/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[current_charges]/[initial(current_charges)]")
	visual_references[VREF_MUTABLE_JAB] = counter_maptext

/datum/action/ability/activable/xeno/warrior/punch/flurry/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_JAB])
	visual_references[VREF_MUTABLE_JAB] = null

/datum/action/ability/activable/xeno/warrior/punch/flurry/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_JAB])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_JAB]
	number?.maptext = MAPTEXT("[current_charges]/[initial(current_charges)]")
	visual_references[VREF_MUTABLE_JAB] = number
	button.add_overlay(visual_references[VREF_MUTABLE_JAB])
	return ..()

/datum/action/ability/activable/xeno/warrior/punch/flurry/on_cooldown_finish()
	current_charges = clamp(current_charges+1, 0, initial(current_charges))
	owner.balloon_alert(owner, "[initial(name)] ready[current_charges > 1 ? " ([current_charges]/[initial(current_charges)])" : ""]")
	update_button_icon()
	if(current_charges < initial(current_charges))
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(on_cooldown_finish)), cooldown_duration, TIMER_STOPPABLE)
		return
	return ..()

/datum/action/ability/activable/xeno/warrior/punch/flurry/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(cooldown_timer && current_charges > 0)
		return TRUE

/datum/action/ability/activable/xeno/warrior/punch/flurry/do_ability(atom/A)
	var/jab_damage = round((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * WARRIOR_JAB_DAMAGE_MULTIPLIER)
	if(!A.punch_act(xeno_owner, jab_damage, FALSE))
		return fail_activate()
	current_charges--
	succeed_activate()
	add_cooldown()
	if(!isliving(A))
		return
	var/datum/action/ability/xeno_action/empower/empower_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/empower]
	if(!empower_action?.check_empower(A))
		return
	var/mob/living/living_target = A
	living_target.adjust_blindness(WARRIOR_JAB_BLIND)
	living_target.adjust_blurriness(WARRIOR_JAB_BLUR)
	living_target.apply_status_effect(STATUS_EFFECT_CONFUSED, WARRIOR_JAB_CONFUSION_DURATION)
