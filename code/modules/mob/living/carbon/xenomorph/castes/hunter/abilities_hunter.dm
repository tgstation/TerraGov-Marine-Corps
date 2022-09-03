// ***************************************
// *********** Stealth
// ***************************************
/datum/action/xeno_action/stealth
	name = "Toggle Stealth"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, almost invisible if you stand still, and ready a sneak attack. Uses plasma to move."
	ability_name = "stealth"
	plasma_cost = 10
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_STEALTH
	cooldown_timer = HUNTER_STEALTH_COOLDOWN
	var/last_stealth = null
	var/stealth = FALSE
	var/can_sneak_attack = FALSE
	var/stealth_alpha_multiplier = 1

/datum/action/xeno_action/stealth/remove_action(mob/living/L)
	if(stealth)
		cancel_stealth()
	return ..()

/datum/action/xeno_action/stealth/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/stealthy_beno = owner
	if(stealthy_beno.on_fire)
		to_chat(stealthy_beno, "<span class='warning'>We're too busy being on fire to enter Stealth!</span>")
		return FALSE
	return TRUE

/datum/action/xeno_action/stealth/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'><b>We're ready to use Stealth again.</b></span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
	return ..()

/datum/action/xeno_action/stealth/action_activate()
	if(stealth)
		cancel_stealth()
		return TRUE

	succeed_activate()
	to_chat(owner, "<span class='xenodanger'>We vanish into the shadows...</span>")
	last_stealth = world.time
	stealth = TRUE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/handle_stealth)
	RegisterSignal(owner, COMSIG_XENOMORPH_POUNCE_END, .proc/sneak_attack_pounce)
	RegisterSignal(owner, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/sneak_attack_slash)
	RegisterSignal(owner, COMSIG_XENOMORPH_DISARM_HUMAN, .proc/sneak_attack_slash)
	RegisterSignal(owner, COMSIG_XENOMORPH_ZONE_SELECT, .proc/sneak_attack_zone)
	RegisterSignal(owner, COMSIG_XENOMORPH_PLASMA_REGEN, .proc/plasma_regen)

	// TODO: attack_alien() overrides are a mess and need a lot of work to make them require parentcalling
	RegisterSignal(owner, list(
		COMSIG_XENOMORPH_GRAB,
		COMSIG_XENOMORPH_ATTACK_BARRICADE,
		COMSIG_XENOMORPH_ATTACK_CLOSET,
		COMSIG_XENOMORPH_ATTACK_RAZORWIRE,
		COMSIG_XENOMORPH_ATTACK_BED,
		COMSIG_XENOMORPH_ATTACK_NEST,
		COMSIG_XENOMORPH_ATTACK_TABLE,
		COMSIG_XENOMORPH_ATTACK_RACK,
		COMSIG_XENOMORPH_ATTACK_SENTRY,
		COMSIG_XENOMORPH_ATTACK_M56_POST,
		COMSIG_XENOMORPH_ATTACK_M56,
		COMSIG_XENOMORPH_ATTACK_TANK,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_XENOMORPH_FIRE_BURNING,
		COMSIG_LIVING_ADD_VENTCRAWL), .proc/cancel_stealth)

	RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_ADDTRAIT(TRAIT_FLOORED)), .proc/cancel_stealth)

	RegisterSignal(owner, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/damage_taken)

	ADD_TRAIT(owner, TRAIT_TURRET_HIDDEN, STEALTH_TRAIT)

	handle_stealth()
	addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.
	START_PROCESSING(SSprocessing, src)

/datum/action/xeno_action/stealth/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
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
		COMSIG_XENOMORPH_ATTACK_BARRICADE,
		COMSIG_XENOMORPH_ATTACK_CLOSET,
		COMSIG_XENOMORPH_ATTACK_RAZORWIRE,
		COMSIG_XENOMORPH_ATTACK_BED,
		COMSIG_XENOMORPH_ATTACK_NEST,
		COMSIG_XENOMORPH_ATTACK_TABLE,
		COMSIG_XENOMORPH_ATTACK_RACK,
		COMSIG_XENOMORPH_ATTACK_SENTRY,
		COMSIG_XENOMORPH_ATTACK_M56_POST,
		COMSIG_XENOMORPH_ATTACK_M56,
		COMSIG_XENOMORPH_ATTACK_TANK,
		COMSIG_XENOMORPH_THROW_HIT,
		COMSIG_XENOMORPH_FIRE_BURNING,
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

/datum/action/xeno_action/stealth/proc/sneak_attack_cooldown()
	if(!stealth || can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(owner, span_xenodanger("We're ready to use Sneak Attack while stealthed."))
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)

/datum/action/xeno_action/stealth/process()
	if(!stealth)
		return PROCESS_KILL
	handle_stealth()

/datum/action/xeno_action/stealth/proc/handle_stealth()
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
/datum/action/xeno_action/stealth/proc/sneak_attack_pounce()
	SIGNAL_HANDLER
	if(owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent(MOVE_INTENT_RUN)
		if(owner.hud_used?.move_intent)
			owner.hud_used.move_intent.icon_state = "running"
		owner.update_icons()

	cancel_stealth()

/// Callback for when a mob gets hit as part of a pounce
/datum/action/xeno_action/stealth/proc/mob_hit(datum/source, mob/living/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	if(can_sneak_attack)
		M.adjust_stagger(3)
		M.add_slowdown(1)
		to_chat(owner, span_xenodanger("Pouncing from the shadows, we stagger our victim."))

/datum/action/xeno_action/stealth/proc/sneak_attack_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
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
	target.adjust_stagger(staggerslow_stacks)
	target.add_slowdown(staggerslow_stacks)
	target.ParalyzeNoChain(1 SECONDS)

	cancel_stealth()

/datum/action/xeno_action/stealth/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xenoowner = owner
	if(damage_taken > xenoowner.xeno_caste.stealth_break_threshold)
		cancel_stealth()

/datum/action/xeno_action/stealth/proc/plasma_regen(datum/source, list/plasma_mod)
	SIGNAL_HANDLER
	if(owner.last_move_intent < world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		plasma_mod[1] *= 0.5
	else
		plasma_mod[1] = 0

/datum/action/xeno_action/stealth/proc/sneak_attack_zone()
	SIGNAL_HANDLER
	if(!can_sneak_attack)
		return
	return COMSIG_ACCURATE_ZONE

/datum/action/xeno_action/stealth/disguise
	name = "Disguise"
	mechanics_text = "Disguise yourself as the enemy. Uses plasma to move. Select your disguise with Hunter's Mark."
	///the regular appearance of the hunter
	var/old_appearance

/datum/action/xeno_action/stealth/disguise/action_activate()
	if(stealth)
		cancel_stealth()
		return TRUE
	var/mob/living/carbon/xenomorph/xenoowner = owner
	var/datum/action/xeno_action/activable/hunter_mark/mark = xenoowner.actions_by_path[/datum/action/xeno_action/activable/hunter_mark]

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

/datum/action/xeno_action/stealth/disguise/cancel_stealth()
	. = ..()
	owner.appearance = old_appearance
	REMOVE_TRAIT(owner, TRAIT_MOB_ICON_UPDATE_BLOCKED, STEALTH_TRAIT)
	var/mob/living/carbon/xenomorph/xenoowner = owner
	xenoowner.update_wounds()

/datum/action/xeno_action/stealth/disguise/handle_stealth()
	var/mob/living/carbon/xenomorph/xenoowner = owner
	var/datum/action/xeno_action/activable/hunter_mark/mark = xenoowner.actions_by_path[/datum/action/xeno_action/activable/hunter_mark]
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
// *********** Pounce/sneak attack
// ***************************************
/datum/action/xeno_action/activable/pounce/hunter
	plasma_cost = 20
	range = 7

// ***************************************
// *********** Hunter's Mark
// ***************************************
/datum/action/xeno_action/activable/hunter_mark
	name = "Hunter's Mark"
	action_icon_state = "hunter_mark"
	mechanics_text = "Psychically mark a creature you have line of sight to, allowing you to sense its direction, distance and location with Psychic Trace."
	plasma_cost = 25
	keybind_signal = COMSIG_XENOABILITY_HUNTER_MARK
	cooldown_timer = 60 SECONDS
	///the target marked
	var/atom/movable/marked_target

/datum/action/xeno_action/activable/hunter_mark/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/xenomorph/X = owner

	if(!isliving(A) && (X.xeno_caste.upgrade != XENO_UPGRADE_FOUR) || !ismovable(A))
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


/datum/action/xeno_action/activable/hunter_mark/on_cooldown_finish()
	to_chat(owner, span_xenowarning("<b>We are able to impose our psychic mark again.</b>"))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()


/datum/action/xeno_action/activable/hunter_mark/use_ability(atom/A)

	var/mob/living/carbon/xenomorph/X = owner

	X.face_atom(A) //Face towards the target so we don't look silly

	if(!line_of_sight(X, A)) //Need line of sight.
		to_chat(X, span_xenowarning("We lost line of sight to the target!"))
		return fail_activate()

	if(marked_target)
		UnregisterSignal(marked_target, COMSIG_PARENT_QDELETING)

	marked_target = A

	RegisterSignal(marked_target, COMSIG_PARENT_QDELETING, .proc/unset_target) //For var clean up

	to_chat(X, span_xenodanger("We psychically mark [A] as our quarry."))
	X.playsound_local(X, 'sound/effects/ghost.ogg', 25, 0, 1)

	succeed_activate()

	GLOB.round_statistics.hunter_marks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "hunter_marks")
	add_cooldown()

///Nulls the target of our hunter's mark
/datum/action/xeno_action/activable/hunter_mark/proc/unset_target()
	SIGNAL_HANDLER
	UnregisterSignal(marked_target, COMSIG_PARENT_QDELETING)
	marked_target = null //Nullify hunter's mark target and clear the var

// ***************************************
// *********** Psychic Trace
// ***************************************
/datum/action/xeno_action/psychic_trace
	name = "Psychic Trace"
	action_icon_state = "toggle_queen_zoom"
	mechanics_text = "Psychically ping the creature you marked, letting you know its direction, distance and location, and general condition."
	plasma_cost = 1 //Token amount
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_TRACE
	cooldown_timer = HUNTER_PSYCHIC_TRACE_COOLDOWN

/datum/action/xeno_action/psychic_trace/can_use_action(silent = FALSE, override_flags)
	. = ..()

	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/xeno_action/activable/hunter_mark/mark = X.actions_by_path[/datum/action/xeno_action/activable/hunter_mark]

	if(!mark.marked_target)
		if(!silent)
			to_chat(owner, span_xenowarning("We have no target we can trace!"))
		return FALSE

	if(mark.marked_target.z != owner.z)
		if(!silent)
			to_chat(owner, span_xenowarning("Our target is too far away, and is beyond our senses!"))
		return FALSE


/datum/action/xeno_action/psychic_trace/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/xeno_action/activable/hunter_mark/mark = X.actions_by_path[/datum/action/xeno_action/activable/hunter_mark]
	to_chat(X, span_xenodanger("We sense our quarry <b>[mark.marked_target]</b> is currently located in <b>[AREACOORD_NO_Z(mark.marked_target)]</b> and is <b>[get_dist(X, mark.marked_target)]</b> tiles away. It is <b>[calculate_mark_health(mark.marked_target)]</b> and <b>[mark.marked_target.status_flags & XENO_HOST ? "impregnated" : "barren"]</b>."))
	X.playsound_local(X, 'sound/effects/ghost2.ogg', 10, 0, 1)

	var/obj/screen/arrow/hunter_mark_arrow/arrow_hud = new
	//Prepare the tracker object and set its parameters
	arrow_hud.add_hud(X, mark.marked_target) //set the tracker parameters
	arrow_hud.process() //Update immediately

	add_cooldown()

	return succeed_activate()

///Where we calculate the approximate health of our trace target
/datum/action/xeno_action/psychic_trace/proc/calculate_mark_health(mob/living/target)
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

/datum/action/xeno_action/mirage
	name = "Mirage"
	action_icon_state = "mirror_image"
	mechanics_text = "Create mirror images of ourselves. Reactivate to swap with an illusion."
	ability_name = "mirage"
	plasma_cost = 50
	keybind_signal = COMSIG_XENOABILITY_MIRAGE
	cooldown_timer = 30 SECONDS
	///How long will the illusions live
	var/illusion_life_time = 10 SECONDS
	///How many illusions are created
	var/illusion_count = 3
	/// List of illusions
	var/list/mob/illusion/illusions = list()
	/// If swap has been used during the current set of illusions
	var/swap_used = FALSE

/datum/action/xeno_action/mirage/remove_action()
	clean_illusions()
	return ..()

/datum/action/xeno_action/mirage/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(swap_used)
		if(!silent)
			to_chat(owner, span_xenowarning("We already swapped with an illusion!"))
		return FALSE

/datum/action/xeno_action/mirage/action_activate()
	succeed_activate()
	if (!illusions.len)
		spawn_illusions()
	else
		swap()

/// Spawns a set of illusions around the hunter
/datum/action/xeno_action/mirage/proc/spawn_illusions()
	switch(owner.a_intent)
		if(INTENT_HARM) //Escort us and attack nearby enemy
			var/mob/illusion/xeno/center_illusion = new (owner.loc, owner, owner, illusion_life_time)
			for(var/i in 1 to (illusion_count - 1))
				illusions += new /mob/illusion/xeno(owner.loc, owner, center_illusion, illusion_life_time)
			illusions += center_illusion
		if(INTENT_HELP, INTENT_GRAB, INTENT_DISARM) //Disperse
			for(var/i in 1 to illusion_count)
				illusions += new /mob/illusion/xeno(owner.loc, owner, null, illusion_life_time)
	addtimer(CALLBACK(src, .proc/clean_illusions), illusion_life_time)

/// Clean up the illusions list
/datum/action/xeno_action/mirage/proc/clean_illusions()
	illusions = list()
	add_cooldown()
	swap_used = FALSE

/// Swap places of hunter and an illusion
/datum/action/xeno_action/mirage/proc/swap()
	swap_used = TRUE
	var/mob/living/carbon/xenomorph/X = owner

	if(!illusions.len)
		to_chat(X, span_xenowarning("We have no illusions to swap with!"))
		return

	X.playsound_local(X, 'sound/effects/swap.ogg', 10, 0, 1)
	var/turf/current_turf = get_turf(X)

	var/mob/selected_illusion = illusions[1]
	X.forceMove(get_turf(selected_illusion.loc))
	selected_illusion.forceMove(current_turf)
