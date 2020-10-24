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
	mechanics_text = "Deals damage 4 times and injects 4u of selected reagent per slash. Can move next to target while slashing."
	ability_name = "reagent slash"
	cooldown_timer = 6 SECONDS
	plasma_cost = 40
	keybind_signal = COMSIG_XENOABILITY_REAGENT_STING

/datum/action/xeno_action/activable/reagent_slash/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(get_dist(owner, A) > 1)
		to_chat(owner, "<span class='warning'>We need to be next to our prey.</span>")
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/reagent_slash/proc/figure_out_living_target(atom/A)
	var/clickDir = get_dir(owner, A)
	var/turf/presumedPos = get_step(owner, clickDir)
	var/mob/living/L = locate() in presumedPos
	if((presumedPos == get_turf(A) && L == null) || L == owner || istype(L, /mob/living/carbon/xenomorph))
		to_chat(owner, "<span class='warning'>Our slash won't affect this target!</span>")
		return A
	return L

/datum/action/xeno_action/activable/reagent_slash/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/T
	if(isturf(A))
		T = A
	else
		T = get_turf(A)
	var/atom/hold = figure_out_living_target(T,	owner)
	var/atom/Z = hold
	if(X.is_ventcrawling)
		return
	if(isnull(Z))
		return
	if(isturf(Z))
		return
	var/slash_count = 4
	var/reagent_transfer_amount = 4
	if(X.selected_reagent == /datum/reagent/toxin/xeno_praelyx)
		slash_count = 1
		reagent_transfer_amount = 16
	succeed_activate()
	X.recurring_injection(Z, X.selected_reagent, channel_time = 1.2 SECONDS, count = slash_count, transfer_amount = reagent_transfer_amount, is_reagent_slash = TRUE)
	add_cooldown()

// ***************************************
// *********** NANOCRYSTAL CAMOUFLAGE
// ***************************************
/datum/action/xeno_action/xeno_camouflage
	name = "Toggle Nanocrystal Camouflage"
	action_icon_state = "stealth_on"
	mechanics_text = "Become harder to see, better camouflage when walking and almost invisible if you stand still. Uses plasma to move, more when running."
	ability_name = "nanocrystal camouflage"
	plasma_cost = 40
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_NANOCRYSTAL_CAMOUFLAGE
	cooldown_timer = 7 SECONDS
	var/stealth = FALSE
	COOLDOWN_DECLARE(deep_stealth)

/datum/action/xeno_action/xeno_camouflage/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_PLASMA_REGEN, .proc/plasma_regen)

	// TODO: attack_alien() overrides are a mess and need a lot of work to make them require parentcalling
	RegisterSignal(L, list(
		COMSIG_HIVE_XENO_RECURRING_INJECTION,
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

	RegisterSignal(L, list(COMSIG_XENOMORPH_TAKING_DAMAGE), .proc/damage_taken)

/datum/action/xeno_action/xeno_camouflage/remove_action(mob/living/L)
	UnregisterSignal(L, list(
		COMSIG_HIVE_XENO_RECURRING_INJECTION,
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
		to_chat(owner, "<span class='xenodanger'>We blend in with the scenery...</span>")
	succeed_activate()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/deep_stealth_cooldown)

/datum/action/xeno_action/xeno_camouflage/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	if(!stealth)//sanity check/safeguard
		return
	to_chat(owner, "<span class='xenodanger'>Our carapace relaxes.</span>")
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED) //This should be handled on the ability datum or a component.
	stealth = FALSE
	owner.alpha = 255 //no transparency/translucency
	add_cooldown()

/datum/action/xeno_action/xeno_camouflage/proc/handle_stealth()
	if(!stealth)
		return
	var/mob/living/carbon/xenomorph/xenoowner = owner
	//Stationary stealth
	if(COOLDOWN_CHECK(src, deep_stealth)) //If we're standing still for 1 seconds we become almost completely invisible
		owner.alpha = AFFLICTOR_CAMOUFLAGE_STILL_ALPHA
	//Walking stealth
	else if(owner.m_intent == MOVE_INTENT_WALK)
		xenoowner.use_plasma(AFFLICTOR_CAMOUFLAGE_WALK_PLASMADRAIN)
		owner.alpha = AFFLICTOR_CAMOUFLAGE_WALK_ALPHA
	//Running stealth
	else if(owner.m_intent == MOVE_INTENT_RUN)
		xenoowner.use_plasma(AFFLICTOR_CAMOUFLAGE_RUN_PLASMADRAIN)
		owner.alpha = AFFLICTOR_CAMOUFLAGE_RUN_ALPHA
	//If we have 0 plasma after expending stealth's upkeep plasma, end stealth.
	if(!xenoowner.plasma_stored)
		to_chat(xenoowner, "<span class='xenodanger'>We lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/datum/action/xeno_action/xeno_camouflage/proc/deep_stealth_cooldown()
	COOLDOWN_START(src, deep_stealth, 1 SECONDS)
	handle_stealth()

/datum/action/xeno_action/xeno_camouflage/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	if(damage_taken > 15)
		cancel_stealth()

/datum/action/xeno_action/xeno_camouflage/proc/plasma_regen(datum/source, list/plasma_mod)
	handle_stealth()

	if(stealth && owner.last_move_intent > world.time - 20) //Stealth halves the rate of plasma recovery on weeds, and eliminates it entirely while moving
		plasma_mod += 0.0
	else
		plasma_mod += 0.5
