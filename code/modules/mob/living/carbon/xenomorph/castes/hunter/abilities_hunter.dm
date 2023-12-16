// ***************************************
// *********** Stealth
// ***************************************
/datum/action/ability/xeno_action/stealth
	name = "Toggle Stealth"
	action_icon_state = "hunter_invisibility"
	desc = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	ability_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_STEALTH,
	)
	cooldown_duration = HUNTER_STEALTH_COOLDOWN
	var/last_stealth = null
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	var/stealth_alpha_multiplier = 1

/datum/action/ability/xeno_action/stealth/remove_action(mob/living/L)
	if(stealth)
		cancel_stealth()
	return ..()

/datum/action/ability/xeno_action/stealth/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/stealthy_beno = owner
	if(stealthy_beno.on_fire)
		to_chat(stealthy_beno, "<span class='warning'>We're too busy being on fire to enter Stealth!</span>")
		return FALSE
	return TRUE

/datum/action/ability/xeno_action/stealth/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'><b>We're ready to use Stealth again.</b></span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
	return ..()

/datum/action/ability/xeno_action/stealth/action_activate()
	if(stealth)
		cancel_stealth()
		return TRUE
	if(HAS_TRAIT_FROM(owner, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT))   // stops stealth and disguise from stacking
		owner.balloon_alert(owner, "already in a form of stealth!")
		return
	succeed_activate()
	to_chat(owner, "<span class='xenodanger'>We vanish into the shadows...</span>")
	last_stealth = world.time
	stealth = TRUE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(handle_stealth))
	RegisterSignal(owner, COMSIG_XENOMORPH_POUNCE_END, PROC_REF(sneak_attack_pounce))
	RegisterSignal(owner, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(sneak_attack_slash))
	RegisterSignal(owner, COMSIG_XENOMORPH_DISARM_HUMAN, PROC_REF(sneak_attack_slash))
	RegisterSignal(owner, COMSIG_XENOMORPH_ZONE_SELECT, PROC_REF(sneak_attack_zone))
	RegisterSignal(owner, COMSIG_XENOMORPH_PLASMA_REGEN, PROC_REF(plasma_regen))

	// TODO: attack_alien() overrides are a mess and need a lot of work to make them require parentcalling
	RegisterSignals(owner, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_LIVING_IGNITED,
		COMSIG_LIVING_ADD_VENTCRAWL), PROC_REF(cancel_stealth))

	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_OBJ, PROC_REF(on_obj_attack))

	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_ADDTRAIT(TRAIT_FLOORED)), PROC_REF(cancel_stealth))

	RegisterSignal(owner, COMSIG_XENOMORPH_TAKING_DAMAGE, PROC_REF(damage_taken))

	ADD_TRAIT(owner, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT)

	handle_stealth()
	addtimer(CALLBACK(src, PROC_REF(sneak_attack_cooldown)), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.
	START_PROCESSING(SSprocessing, src)

/datum/action/ability/xeno_action/stealth/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	SIGNAL_HANDLER
	add_cooldown()
	to_chat(owner, "<span class='xenodanger'>We emerge from the shadows.</span>")

	UnregisterSignal(owner, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_XENOMORPH_POUNCE_END,
		COMSIG_XENO_LIVING_THROW_HIT,
		COMSIG_XENOMORPH_ATTACK_LIVING,
		COMSIG_XENOMORPH_DISARM_HUMAN,
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_ATTACK_OBJ,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_LIVING_IGNITED,
		COMSIG_LIVING_ADD_VENTCRAWL,
		SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
		SIGNAL_ADDTRAIT(TRAIT_FLOORED),
		COMSIG_XENOMORPH_ZONE_SELECT,
		COMSIG_XENOMORPH_PLASMA_REGEN,
		COMSIG_XENOMORPH_TAKING_DAMAGE,))

	stealth = FALSE
	can_sneak_attack = FALSE
	REMOVE_TRAIT(owner, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT)
	owner.alpha = 255 //no transparency/translucency

///Signal wrapper to verify that an object is damageable before breaking stealth
/datum/action/ability/xeno_action/stealth/proc/on_obj_attack(datum/source, obj/attacked)
	SIGNAL_HANDLER
	if(attacked.resistance_flags & XENO_DAMAGEABLE)
		cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/sneak_attack_cooldown()
	if(!stealth || can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(owner, span_xenodanger("We're ready to use Sneak Attack while stealthed."))
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)

/datum/action/ability/xeno_action/stealth/process()
	if(!stealth)
		return PROCESS_KILL
	handle_stealth()

/datum/action/ability/xeno_action/stealth/proc/handle_stealth()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xenoowner = owner
	//Initial stealth
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY) //We don't start out at max invisibility
		owner.alpha = HUNTER_STEALTH_RUN_ALPHA * stealth_alpha_multiplier
		return
	//Stationary stealth
	else if(owner.last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY) //If we're standing still for 4 seconds we become almost completely invisible
		owner.alpha = HUNTER_STEALTH_STILL_ALPHA * stealth_alpha_multiplier
	//Walking stealth
	else if(owner.m_intent == MOVE_INTENT_WALK)
		xenoowner.use_plasma(HUNTER_STEALTH_WALK_PLASMADRAIN)
		owner.alpha = HUNTER_STEALTH_WALK_ALPHA * stealth_alpha_multiplier
	//Running stealth
	else
		xenoowner.use_plasma(HUNTER_STEALTH_RUN_PLASMADRAIN)
		owner.alpha = HUNTER_STEALTH_RUN_ALPHA * stealth_alpha_multiplier
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!xenoowner.plasma_stored)
		to_chat(xenoowner, span_xenodanger("We lack sufficient plasma to remain camouflaged."))
		cancel_stealth()

/// Callback listening for a xeno using the pounce ability
/datum/action/ability/xeno_action/stealth/proc/sneak_attack_pounce()
	SIGNAL_HANDLER
	if(owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent(MOVE_INTENT_RUN)
		if(owner.hud_used?.move_intent)
			owner.hud_used.move_intent.icon_state = "running"
		owner.update_icons()

	cancel_stealth()

/// Callback for when a mob gets hit as part of a pounce
/datum/action/ability/xeno_action/stealth/proc/mob_hit(datum/source, mob/living/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	if(can_sneak_attack)
		M.adjust_stagger(3 SECONDS)
		M.add_slowdown(1)
		to_chat(owner, span_xenodanger("Pouncing from the shadows, we stagger our victim."))

/datum/action/ability/xeno_action/stealth/proc/sneak_attack_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	if(!can_sneak_attack)
		return

	var/staggerslow_stacks = 2
	var/flavour
	if(owner.m_intent == MOVE_INTENT_RUN && ( owner.last_move_intent > (world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY) ) ) //Allows us to slash while running... but only if we've been stationary for awhile
		flavour = "vicious"
	else
		armor_mod += HUNTER_SNEAK_SLASH_ARMOR_PEN
		staggerslow_stacks *= 2
		flavour = "deadly"

	owner.visible_message(span_danger("\The [owner] strikes [target] with [flavour] precision!"), \
	span_danger("We strike [target] with [flavour] precision!"))
	target.adjust_stagger(staggerslow_stacks SECONDS)
	target.add_slowdown(staggerslow_stacks)
	target.ParalyzeNoChain(1 SECONDS)

	cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xenoowner = owner
	if(damage_taken > xenoowner.xeno_caste.stealth_break_threshold)
		cancel_stealth()

/datum/action/ability/xeno_action/stealth/proc/plasma_regen(datum/source, list/plasma_mod)
	SIGNAL_HANDLER
	if(owner.last_move_intent < world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		plasma_mod[1] *= 0.5
	else
		plasma_mod[1] = 0

/datum/action/ability/xeno_action/stealth/proc/sneak_attack_zone()
	SIGNAL_HANDLER
	if(!can_sneak_attack)
		return
	return COMSIG_ACCURATE_ZONE

/datum/action/ability/xeno_action/stealth/disguise
	name = "Disguise"
	action_icon_state = "xenohide"
	desc = "Disguise yourself as the enemy. Uses plasma to move. Select your disguise with Hunter's Mark."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_DISGUISE,
	)
	///the regular appearance of the hunter
	var/old_appearance

/datum/action/ability/xeno_action/stealth/disguise/action_activate()
	if(stealth)
		cancel_stealth()
		return TRUE
	var/mob/living/carbon/xenomorph/xenoowner = owner
	var/datum/action/ability/activable/xeno/hunter_mark/mark = xenoowner.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]
	if(HAS_TRAIT_FROM(owner, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT))   // stops stealth and disguise from stacking
		owner.balloon_alert(owner, "already in a form of stealth!")
		return
	if(!mark.marked_target)
		to_chat(owner, span_warning("We have no target to disguise into!"))
		return
	if(ishuman(mark.marked_target))
		to_chat(owner, "You cannot turn into a human!")
		return
	old_appearance = xenoowner.appearance
	ADD_TRAIT(xenoowner, TRAIT_MOB_ICON_UPDATE_BLOCKED, STEALTH_TRAIT)
	xenoowner.update_wounds()
	return ..()

/datum/action/ability/xeno_action/stealth/disguise/cancel_stealth()
	. = ..()
	owner.appearance = old_appearance
	REMOVE_TRAIT(owner, TRAIT_MOB_ICON_UPDATE_BLOCKED, STEALTH_TRAIT)
	var/mob/living/carbon/xenomorph/xenoowner = owner
	xenoowner.update_wounds()

/datum/action/ability/xeno_action/stealth/disguise/handle_stealth()
	var/mob/living/carbon/xenomorph/xenoowner = owner
	var/datum/action/ability/activable/xeno/hunter_mark/mark = xenoowner.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]
	var/old_layer = xenoowner.layer
	xenoowner.appearance = mark.marked_target.appearance
	//Retaining old rendering layer to prevent rendering under objects.
	xenoowner.layer = old_layer
	xenoowner.underlays.Cut()
	if(owner.last_move_intent >= world.time - HUNTER_STEALTH_STEALTH_DELAY)
		xenoowner.use_plasma(owner.m_intent == MOVE_INTENT_WALK ? HUNTER_STEALTH_WALK_PLASMADRAIN : HUNTER_STEALTH_RUN_PLASMADRAIN)
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!xenoowner.plasma_stored)
		to_chat(xenoowner, span_xenodanger("We lack sufficient plasma to remain disguised."))
		cancel_stealth()


// ***************************************
// *********** Hunter's Pounce
// ***************************************
#define HUNTER_POUNCE_RANGE 7 // in tiles
#define XENO_POUNCE_SPEED 2
#define XENO_POUNCE_STUN_DURATION 2 SECONDS
#define XENO_POUNCE_STANDBY_DURATION 0.5 SECONDS
#define XENO_POUNCE_SHIELD_STUN_DURATION 6 SECONDS

/datum/action/ability/activable/xeno/pounce
	name = "Pounce"
	desc = "Leap at your target, tackling and disarming them."
	action_icon_state = "pounce"
	ability_cost = 20
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_POUNCE,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	/// The range of this ability.
	var/pounce_range = HUNTER_POUNCE_RANGE

/datum/action/ability/activable/xeno/pounce/on_cooldown_finish()
	owner.balloon_alert(owner, "Pounce ready")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.usedPounce = FALSE
	return ..()

/datum/action/ability/activable/xeno/pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/ability/activable/xeno/pounce/use_ability(atom/A)
	if(owner.layer != MOB_LAYER)
		owner.layer = MOB_LAYER
		var/datum/action/ability/xeno_action/xenohide/hide_action = owner.actions_by_path[/datum/action/ability/xeno_action/xenohide]
		hide_action?.button?.cut_overlay(mutable_appearance('icons/Xeno/actions.dmi', "selected_purple_frame", ACTION_LAYER_ACTION_ICON_STATE, FLOAT_PLANE)) // Removes Hide action icon border
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(movement_fx))
	RegisterSignal(owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(object_hit))
	RegisterSignal(owner, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(pounce_complete))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.usedPounce = TRUE
	xeno_owner.pass_flags |= PASS_LOW_STRUCTURE|PASS_FIRE|PASS_XENO
	xeno_owner.throw_at(A, pounce_range, XENO_POUNCE_SPEED, xeno_owner)
	addtimer(CALLBACK(src, PROC_REF(reset_pass_flags)), 0.6 SECONDS)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/pounce/proc/movement_fx()
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/xenomorph/afterimage(get_turf(owner), owner) //Create the after image.

/datum/action/ability/activable/xeno/pounce/proc/object_hit(datum/source, obj/object_target, speed)
	SIGNAL_HANDLER
	object_target.hitby(owner, speed)
	pounce_complete()

/datum/action/ability/activable/xeno/pounce/proc/mob_hit(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	if(living_target.stat)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(ishuman(living_target) && (living_target.dir in reverse_nearby_direction(living_target.dir)))
		var/mob/living/carbon/human/human_target = living_target
		if(!human_target.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			xeno_owner.Paralyze(XENO_POUNCE_SHIELD_STUN_DURATION)
			xeno_owner.set_throwing(FALSE)
			return COMPONENT_KEEP_THROWING
	playsound(living_target.loc, 'sound/voice/alien_pounce.ogg', 25, TRUE)
	xeno_owner.Immobilize(XENO_POUNCE_STANDBY_DURATION)
	xeno_owner.forceMove(get_turf(living_target))
	living_target.Knockdown(XENO_POUNCE_STUN_DURATION)
	pounce_complete()

/datum/action/ability/activable/xeno/pounce/proc/pounce_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT, COMSIG_MOVABLE_POST_THROW))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE_END)

/datum/action/ability/activable/xeno/pounce/proc/reset_pass_flags()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.pass_flags = initial(xeno_owner.pass_flags)

/datum/action/ability/activable/xeno/pounce/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/pounce/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, pounce_range))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


// ***************************************
// *********** Hunter's Mark
// ***************************************
/datum/action/ability/activable/xeno/hunter_mark
	name = "Hunter's Mark"
	action_icon_state = "hunter_mark"
	desc = "Psychically mark a creature you have line of sight to, allowing you to sense its direction, distance and location with Psychic Trace."
	ability_cost = 25
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_MARK,
	)
	cooldown_duration = 60 SECONDS
	///the target marked
	var/atom/movable/marked_target

/datum/action/ability/activable/xeno/hunter_mark/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/X = owner

	if(!isliving(A) && (X.xeno_caste.upgrade != XENO_UPGRADE_PRIMO) || !ismovable(A))
		if(!silent)
			to_chat(X, span_xenowarning("We cannot psychically mark this target!"))
		return FALSE

	if(A == marked_target)
		if(!silent)
			to_chat(X, span_xenowarning("This is already our target!"))
		return FALSE

	if(A == X)
		if(!silent)
			to_chat(X, span_xenowarning("Why would we target ourselves?"))
		return FALSE

	if(!line_of_sight(X, A)) //Need line of sight.
		if(!silent)
			to_chat(X, span_xenowarning("We require line of sight to mark them!"))
		return FALSE

	return TRUE


/datum/action/ability/activable/xeno/hunter_mark/on_cooldown_finish()
	to_chat(owner, span_xenowarning("<b>We are able to impose our psychic mark again.</b>"))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()


/datum/action/ability/activable/xeno/hunter_mark/use_ability(atom/A)

	var/mob/living/carbon/xenomorph/X = owner

	X.face_atom(A) //Face towards the target so we don't look silly

	if(!line_of_sight(X, A)) //Need line of sight.
		to_chat(X, span_xenowarning("We lost line of sight to the target!"))
		return fail_activate()

	if(marked_target)
		UnregisterSignal(marked_target, COMSIG_QDELETING)

	marked_target = A

	RegisterSignal(marked_target, COMSIG_QDELETING, PROC_REF(unset_target)) //For var clean up

	to_chat(X, span_xenodanger("We psychically mark [A] as our quarry."))
	X.playsound_local(X, 'sound/effects/ghost.ogg', 25, 0, 1)

	succeed_activate()

	GLOB.round_statistics.hunter_marks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hunter_marks")
	add_cooldown()

///Nulls the target of our hunter's mark
/datum/action/ability/activable/xeno/hunter_mark/proc/unset_target()
	SIGNAL_HANDLER
	UnregisterSignal(marked_target, COMSIG_QDELETING)
	marked_target = null //Nullify hunter's mark target and clear the var

// ***************************************
// *********** Psychic Trace
// ***************************************
/datum/action/ability/xeno_action/psychic_trace
	name = "Psychic Trace"
	action_icon_state = "toggle_queen_zoom"
	desc = "Psychically ping the creature you marked, letting you know its direction, distance and location, and general condition."
	ability_cost = 1 //Token amount
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_TRACE,
	)
	cooldown_duration = HUNTER_PSYCHIC_TRACE_COOLDOWN

/datum/action/ability/xeno_action/psychic_trace/can_use_action(silent = FALSE, override_flags)
	. = ..()

	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/ability/activable/xeno/hunter_mark/mark = X.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]

	if(!mark.marked_target)
		if(!silent)
			to_chat(owner, span_xenowarning("We have no target we can trace!"))
		return FALSE

	if(mark.marked_target.z != owner.z)
		if(!silent)
			to_chat(owner, span_xenowarning("Our target is too far away, and is beyond our senses!"))
		return FALSE


/datum/action/ability/xeno_action/psychic_trace/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/ability/activable/xeno/hunter_mark/mark = X.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]
	to_chat(X, span_xenodanger("We sense our quarry <b>[mark.marked_target]</b> is currently located in <b>[AREACOORD_NO_Z(mark.marked_target)]</b> and is <b>[get_dist(X, mark.marked_target)]</b> tiles away. It is <b>[calculate_mark_health(mark.marked_target)]</b> and <b>[mark.marked_target.status_flags & XENO_HOST ? "impregnated" : "barren"]</b>."))
	X.playsound_local(X, 'sound/effects/ghost2.ogg', 10, 0, 1)

	var/atom/movable/screen/arrow/hunter_mark_arrow/arrow_hud = new
	//Prepare the tracker object and set its parameters
	arrow_hud.add_hud(X, mark.marked_target) //set the tracker parameters
	arrow_hud.process() //Update immediately

	add_cooldown()

	return succeed_activate()

///Where we calculate the approximate health of our trace target
/datum/action/ability/xeno_action/psychic_trace/proc/calculate_mark_health(mob/living/target)
	if(!isliving(target))
		return "not living"

	if(target.stat == DEAD)
		return "deceased"

	var/percentage = round(target.health * 100 / target.maxHealth)
	switch(percentage)
		if(100 to INFINITY)
			return "in perfect health"
		if(76 to 99)
			return "slightly injured"
		if(51 to 75)
			return "moderately injured"
		if(26 to 50)
			return "badly injured"
		if(1 to 25)
			return "severely injured"
		if(-51 to 0)
			return "critically injured"
		if(-99 to -50)
			return "on the verge of death"
		else
			return "deceased"

/datum/action/ability/xeno_action/mirage
	name = "Mirage"
	action_icon_state = "mirror_image"
	desc = "Create mirror images of ourselves. Reactivate to swap with an illusion."
	ability_cost = 50
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_MIRAGE,
	)
	cooldown_duration = 30 SECONDS
	///How long will the illusions live
	var/illusion_life_time = 10 SECONDS
	///How many illusions are created
	var/illusion_count = 3
	/// List of illusions
	var/list/mob/illusion/illusions = list()
	/// If swap has been used during the current set of illusions
	var/swap_used = FALSE

/datum/action/ability/xeno_action/mirage/remove_action()
	clean_illusions()
	return ..()

/datum/action/ability/xeno_action/mirage/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(swap_used)
		if(!silent)
			to_chat(owner, span_xenowarning("We already swapped with an illusion!"))
		return FALSE

/datum/action/ability/xeno_action/mirage/action_activate()
	succeed_activate()
	if (!length(illusions))
		spawn_illusions()
	else
		swap()

/// Spawns a set of illusions around the hunter
/datum/action/ability/xeno_action/mirage/proc/spawn_illusions()
	var/mob/illusion/xeno/center_illusion = new (owner.loc, owner, owner, illusion_life_time)
	for(var/i in 1 to (illusion_count - 1))
		illusions += new /mob/illusion/xeno(owner.loc, owner, center_illusion, illusion_life_time)
	illusions += center_illusion
	addtimer(CALLBACK(src, PROC_REF(clean_illusions)), illusion_life_time)

/// Clean up the illusions list
/datum/action/ability/xeno_action/mirage/proc/clean_illusions()
	illusions = list()
	add_cooldown()
	swap_used = FALSE

/// Swap places of hunter and an illusion
/datum/action/ability/xeno_action/mirage/proc/swap()
	swap_used = TRUE
	var/mob/living/carbon/xenomorph/X = owner

	if(!length(illusions))
		to_chat(X, span_xenowarning("We have no illusions to swap with!"))
		return

	X.playsound_local(X, 'sound/effects/swap.ogg', 10, 0, 1)
	var/turf/current_turf = get_turf(X)

	var/mob/selected_illusion = illusions[1]
	X.forceMove(get_turf(selected_illusion.loc))
	selected_illusion.forceMove(current_turf)

// ***************************************
// *********** Silence
// ***************************************
/datum/action/ability/activable/xeno/silence
	name = "Silence"
	action_icon_state = "silence"
	desc = "Impairs the ability of hostile living creatures we can see in a 5x5 area. Targets will be unable to speak and hear for 10 seconds, or 15 seconds if they're your Hunter Mark target."
	ability_cost = 50
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SILENCE,
	)
	cooldown_duration = HUNTER_SILENCE_COOLDOWN

/datum/action/ability/activable/xeno/silence/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/impairer = owner //Type cast this for on_fire

	var/distance = get_dist(impairer, A)
	if(distance > HUNTER_SILENCE_RANGE)
		if(!silent)
			to_chat(impairer, span_xenodanger("The target location is too far! We must be [distance - HUNTER_SILENCE_RANGE] tiles closer!"))
		return FALSE

	if(!line_of_sight(impairer, A)) //Need line of sight.
		if(!silent)
			to_chat(impairer, span_xenowarning("We require line of sight to the target location!") )
		return FALSE

	return TRUE


/datum/action/ability/activable/xeno/silence/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	X.face_atom(A)

	var/victim_count
	for(var/mob/living/target AS in cheap_get_humans_near(A, HUNTER_SILENCE_AOE))
		if(!isliving(target)) //Filter out non-living
			continue
		if(target.stat == DEAD) //Ignore the dead
			continue
		if(!line_of_sight(X, target)) //Need line of sight
			continue
		if(isxeno(target)) //Ignore friendlies
			var/mob/living/carbon/xenomorph/xeno_victim = target
			if(X.issamexenohive(xeno_victim))
				continue

		var/silence_multiplier = 1
		var/datum/action/ability/activable/xeno/hunter_mark/mark_action = X.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark]
		if(mark_action?.marked_target == target) //Double debuff stacks for the marked target
			silence_multiplier = HUNTER_SILENCE_MULTIPLIER
		to_chat(target, span_danger("Your mind convulses at the touch of something ominous as the world seems to blur, your voice dies in your throat, and everything falls silent!") ) //Notify privately
		target.playsound_local(target, 'sound/effects/ghost.ogg', 25, 0, 1)
		target.adjust_stagger(HUNTER_SILENCE_STAGGER_STACKS * silence_multiplier)
		target.adjust_blurriness(HUNTER_SILENCE_SENSORY_STACKS * silence_multiplier)
		target.adjust_ear_damage(HUNTER_SILENCE_SENSORY_STACKS * silence_multiplier, HUNTER_SILENCE_SENSORY_STACKS * silence_multiplier)
		target.apply_status_effect(/datum/status_effect/mute, HUNTER_SILENCE_MUTE_DURATION * silence_multiplier)
		victim_count++

	if(!victim_count)
		to_chat(X, span_xenodanger("We were unable to violate the minds of any victims."))
		add_cooldown(HUNTER_SILENCE_WHIFF_COOLDOWN) //We cooldown to prevent spam, but only for a short duration
		return fail_activate()

	X.playsound_local(X, 'sound/effects/ghost.ogg', 25, 0, 1)
	to_chat(X, span_xenodanger("We invade the mind of [victim_count] [victim_count > 1 ? "victims" : "victim"], silencing and muting them...") )
	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.hunter_silence_targets += victim_count //Increment by victim count
	SSblackbox.record_feedback("tally", "round_statistics", victim_count, "hunter_silence_targets") //Statistics

/datum/action/ability/activable/xeno/silence/on_cooldown_finish()
	to_chat(owner, span_xenowarning("<b>We refocus our psionic energies, allowing us to impose silence again.</b>") )
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	cooldown_duration = initial(cooldown_duration) //Reset the cooldown timer to its initial state in the event of a whiffed Silence.
	return ..()
