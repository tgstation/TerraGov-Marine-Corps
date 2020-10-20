// ***************************************
// *********** Reagent selection
// ***************************************

/datum/action/xeno_action/select_reagent
	name = "Select Reagent"
	action_icon_state = "select_reagent0"
	mechanics_text = "Switches between available reagents. Transvitox and Hemodile available at first with more unlocked at further maturity. \
	Transvitox converts brute/burn damage to 110% toxin damage. Hemodile increases stamina damage received by 50%. \
	Praelyx deals 20 damage (not affected by armor) to selected limb when one of the reagents is already present. \
	Decay Accelerant deals 1 Brute per tick and 1 additional Toxin for each unique medical reagent present"
	use_state_flags = XACT_USE_BUSY
	keybind_signal = COMSIG_XENOABILITY_SELECT_REAGENT

/datum/action/xeno_action/select_reagent/update_button_icon()
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/A = X.selected_reagent
	button.overlays.Cut()
	button.overlays += image('icons/mob/actions.dmi', button, initial(A.name))
	return ..()

/datum/action/xeno_action/select_reagent/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/available_reagents = X.xeno_caste.available_reagents_define
	var/i = available_reagents.Find(X.selected_reagent)
	if(length(available_reagents) == i)
		X.selected_reagent = available_reagents[1]
	else
		X.selected_reagent = available_reagents[i+1]
	var/atom/A = X.selected_reagent
	to_chat(X, "<span class='notice'>We will now inject <b>[initial(A.name)]</b>.</span>")
	update_button_icon()
	return succeed_activate()

// ***************************************
// *********** Reagent slash
// ***************************************
/datum/action/xeno_action/activable/reagent_slash
	name = "Reagent Slash"
	mechanics_text = "Deals damage and injects 15u of selected reagent."
	ability_name = "reagent slash"
	COOLDOWN_DECLARE(reagent_slash_cooldown)
	plasma_cost = 40
	keybind_signal = COMSIG_XENOABILITY_REAGENT_STING

/datum/action/xeno_action/activable/reagent_slash/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!COOLDOWN_CHECK(src, reagent_slash_cooldown))
		to_chat(owner, "<span class='warning'>[COOLDOWN_TIMELEFT(src, reagent_slash_cooldown) / 10] seconds left</span>")
		return FALSE
	if(!.)
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, "<span class='warning'>Our sting won't affect this target!</span>")
		return FALSE
	if(get_dist(owner, A) > 1)
		if(!silent)
			to_chat(owner, "<span class='warning'>We need to be closer to [A].</span>")
		return FALSE

/datum/action/xeno_action/activable/reagent_slash/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	succeed_activate()
	COOLDOWN_START(src, reagent_slash_cooldown, 6 SECONDS)
	X.recurring_injection(A, X.selected_reagent, XENO_REAGENT_STING_CHANNEL_TIME, count = 1, transfer_amount = 15, is_reagent_slash = TRUE)


// ***************************************
// *********** NANOCRYSTAL CAMOUFLAGE
// ***************************************
/datum/action/xeno_action/xeno_camouflage
	name = "Toggle Nanocrystal Camouflage"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, better camouflage when walking and almost invisible if you stand still. Uses plasma to move, more when running."
	ability_name = "stealth"
	plasma_cost = 10
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_NANOCRYSTAL_CAMOUFLAGE
	COOLDOWN_DECLARE(xeno_camouflage_cooldown)
	var/can_sneak_attack = FALSE
	var/last_stealth = null
	var/stealth = FALSE
	var/stealth_alpha_multiplier = 1

/datum/action/xeno_action/xeno_camouflage/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ZONE_SELECT, .proc/sneak_attack_zone)
	RegisterSignal(L, COMSIG_XENOMORPH_PLASMA_REGEN, .proc/plasma_regen)

	// TODO: attack_alien() overrides are a mess and need a lot of work to make them require parentcalling
	RegisterSignal(L, list(
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

	RegisterSignal(L, list(SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT), SIGNAL_ADDTRAIT(TRAIT_FLOORED)), .proc/cancel_stealth)

	RegisterSignal(src, list(COMSIG_XENOMORPH_TAKING_DAMAGE, COMSIG_HIVE_XENO_RECURRING_INJECTION), .proc/damage_taken)

/datum/action/xeno_action/xeno_camouflage/remove_action(mob/living/L)
	UnregisterSignal(L, list(
		COMSIG_XENOMORPH_POUNCE,
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
		COMSIG_XENOMORPH_PLASMA_REGEN))
	return ..()

/datum/action/xeno_action/xeno_camouflage/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!COOLDOWN_CHECK(src, xeno_camouflage_cooldown))
		to_chat(owner, "<span class='warning'>[COOLDOWN_TIMELEFT(src, xeno_camouflage_cooldown) / 10] seconds left</span>")
		return FALSE
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/stealthy_beno = owner
	if(stealthy_beno.on_fire)
		to_chat(stealthy_beno, "<span class='warning'>We're too busy being on fire to camouflage!</span>")
		return FALSE
	return TRUE

/datum/action/xeno_action/xeno_camouflage/action_activate()
	if(stealth)
		cancel_stealth()
	else
		stealth = TRUE
	succeed_activate()
	to_chat(owner, "<span class='xenodanger'>We blend in with the scenery...</span>")
	last_stealth = world.time
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/handle_stealth)
	COOLDOWN_START(src, xeno_camouflage_cooldown, 7 SECONDS)

/datum/action/xeno_action/xeno_camouflage/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	SIGNAL_HANDLER
	if(!stealth)//sanity check/safeguard
		return
	to_chat(owner, "<span class='xenodanger'>Our carapace relaxes.</span>")
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED) //This should be handled on the ability datum or a component.
	stealth = FALSE
	can_sneak_attack = FALSE
	owner.alpha = 255 //no transparency/translucency

/datum/action/xeno_action/xeno_camouflage/proc/handle_stealth()
	SIGNAL_HANDLER
	if(!stealth)
		return

	var/mob/living/carbon/xenomorph/xenoowner = owner
	//Initial stealth
	if(last_stealth > world.time - AFFLICTOR_CAMOUFLAGE_INITIAL_DELAY) //We don't start out at max invisibility
		owner.alpha = AFFLICTOR_CAMOUFLAGE_RUN_ALPHA * stealth_alpha_multiplier
		return
	//Stationary stealth
	else if(owner.last_move_intent < world.time - AFFLICTOR_CAMOUFLAGE_STEALTH_DELAY) //If we're standing still for 2 seconds we become almost completely invisible
		owner.alpha = AFFLICTOR_CAMOUFLAGE_STILL_ALPHA * stealth_alpha_multiplier
	//Walking stealth
	else if(owner.m_intent == MOVE_INTENT_WALK)
		xenoowner.use_plasma(AFFLICTOR_CAMOUFLAGE_WALK_PLASMADRAIN)
		owner.alpha = AFFLICTOR_CAMOUFLAGE_WALK_ALPHA * stealth_alpha_multiplier
	//Running stealth
	else
		xenoowner.use_plasma(AFFLICTOR_CAMOUFLAGE_RUN_PLASMADRAIN)
		owner.alpha = AFFLICTOR_CAMOUFLAGE_RUN_ALPHA * stealth_alpha_multiplier
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!xenoowner.plasma_stored)
		to_chat(xenoowner, "<span class='xenodanger'>We lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/datum/action/xeno_action/xeno_camouflage/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	SIGNAL_HANDLER
	if(damage_taken > 15)
		cancel_stealth()

/datum/action/xeno_action/xeno_camouflage/proc/plasma_regen(datum/source, list/plasma_mod)
	SIGNAL_HANDLER
	handle_stealth()

	if(stealth && owner.last_move_intent > world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		plasma_mod += 0.0
	else
		plasma_mod += 0.5

/datum/action/xeno_action/xeno_camouflage/proc/sneak_attack_zone()
	SIGNAL_HANDLER
	if(!stealth || !can_sneak_attack)
		return
	return COMSIG_ACCURATE_ZONE
