// :ets go GAMBLING
// ***************************************
// *********** Gamble / Chips mechanic (passive)
// ***************************************
/datum/action/ability/xeno_action/chips
	name = "Gamble"
	action_icon_state = "pincushion"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "" // no desc cause this is hidden
	ability_cost = 0
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_INCAP|ABILITY_USE_STAGGERED|ABILITY_USE_STAGGERED // Theres probally a better way to ensure this can always be used, right?
	hidden = TRUE
	/// The amount of chips this xeno has stored
	var/chips = 0
	/// The total amount of chips this owner can store
	var/maxchips = 20
	/// The total scalar of damage, based on prior gambles. Formula for total damage dealt is [Slash Damage] + [Slash Damage * damagemult]
	var/damagemult = 0
	/// The current state of the gamble bar, from 0 (empty) to 4 (full)
	var/gamblestate = 0
	/// The ID of the timer that controls forcing this jester to gamble after some time of their bar being full.
	var/force_gamble_timer

///Halves the jester's chips, and resets the gamble timer.
/datum/action/ability/xeno_action/chips/proc/hold()
	if(!handle_gamble_validation())
		return
	var/mob/living/carbon/xenomorph/jester/xeno = xeno_owner
	chips *= 0.5
	gamblestate = 0
	xeno.hud_set_chips()
	xeno.hud_set_gamble_bar(FALSE)
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob/living/carbon/xenomorph/jester, hud_set_gamble_bar)), 15 SECONDS)

///Takes all of the jester's chips, and rolls a 50/50 to either reset the damage bonus or increase it by 10% of the chips amount
/datum/action/ability/xeno_action/chips/proc/allin(silent = FALSE)
	if(!handle_gamble_validation())
		return
	var/mob/living/carbon/xenomorph/jester/xeno = xeno_owner
	if(prob(50))
		///1/20th of chips added as damage mult.
		var/addeddamagemult = 0.05 * chips
		damagemult += addeddamagemult
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "Now dealing [damagemult * 100]% more damage")
	else
		//womp womp womp woooomp
		xeno.playsound_local(get_turf(xeno), 'sound/effects/wompwomp.ogg', 50, 1)
		damagemult = 0
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "Reset to base damage")
	gamblestate = 0
	chips = 0
	xeno.hud_set_chips()
	xeno.hud_set_gamble_bar(FALSE)
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob/living/carbon/xenomorph/jester, hud_set_gamble_bar)), 15 SECONDS)

///Handles checking that it is time to gamble, and removes the timers that would force gambling
/datum/action/ability/xeno_action/chips/proc/handle_gamble_validation()
	if(gamblestate != 4)
		return FALSE
	deltimer(force_gamble_timer)
	return TRUE

// ***************************************
// *********** Deck of Disaster
// ***************************************
/datum/action/ability/activable/xeno/deck_of_disaster
	name = "Deck of Disaster"
	action_icon_state = "deckofdisaster"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Afflicts your target with a random debuff."
	ability_cost = 50
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DECK_OF_DISASTER,
	)
	cooldown_duration = JESTER_DECK_OF_DISASTER_COOLDOWN
	///List of debuffs that this ability picks from, to apply
	var/list/debuffs = list(
		STATUS_EFFECT_STAGGER,
		STATUS_EFFECT_STUN,
		STATUS_EFFECT_CONFUSED,
		STATUS_EFFECT_INTOXICATED,
	)


/datum/action/ability/activable/xeno/deck_of_disaster/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	var/distance = get_dist(xeno_owner, A)
	if(distance > JESTER_DECK_OF_DISASTER_RANGE)
		if(!silent)
			to_chat(xeno_owner, span_xenodanger("The target location is too far! We must be [distance - JESTER_DECK_OF_DISASTER_RANGE] tiles closer!"))
		return FALSE

	if(!line_of_sight(xeno_owner, A)) //Need line of sight.
		if(!silent)
			to_chat(xeno_owner, span_xenowarning("We require line of sight to the target location!") )
		return FALSE

	if(!ishuman(A) || issynth(A))
		return FALSE
	var/mob/living/carbon/human/victim = A
	if(victim.stat == DEAD)
		if(!silent)
			to_chat(xeno_owner, span_xenowarning("They must be alive!") )
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/deck_of_disaster/use_ability(atom/A)
	xeno_owner.face_atom(A)
	var/mob/living/carbon/human/target = A
	switch(pick(debuffs))

		if(STATUS_EFFECT_STAGGER)
			owner.balloon_alert(owner, "Staggered!")
			target.Stagger(2 SECONDS) // Stagger for 2 Seconds

		if(STATUS_EFFECT_STUN)
			owner.balloon_alert(owner, "Knocked!")
			target.Knockdown(XENO_POUNCE_STUN_DURATION) //Knockdown for 2 seconds
			target.balloon_alert(owner, "You are tripped by a unseen force!")

		if(STATUS_EFFECT_CONFUSED)
			owner.balloon_alert(owner, "Confused!")
			target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 100)
			target.apply_status_effect(STATUS_EFFECT_CONFUSED, 40) // Same as what king applies

		if(STATUS_EFFECT_INTOXICATED)
			owner.balloon_alert(owner, "Intoxicated!")
			if(target.has_status_effect(STATUS_EFFECT_INTOXICATED))
				var/datum/status_effect/stacking/intoxicated/debuff = target.has_status_effect(STATUS_EFFECT_INTOXICATED)
				debuff.add_stacks(SENTINEL_TOXIC_SPIT_STACKS_PER * 2)
			target.apply_status_effect(STATUS_EFFECT_INTOXICATED, SENTINEL_TOXIC_SPIT_STACKS_PER * 2) //2x what sentinel spit applies (4)

	target.updatehealth() // So the other xenos can see the effect applied instead of waiting for next tick (could expire before then lole)
	succeed_activate()
	add_cooldown()

/datum/action/ability/xeno_action/tarot_deck
	name = "Tarot Deck"
	action_icon_state = "tarot"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Swaps this ability for a random one, from a pool"
	ability_cost = 75
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)
	cooldown_duration = JESTER_TAROT_DECK_COOLDOWN
	///The list of all possible abilties this ability can be swaped for
	var/list/possible_abilities = list(
		/datum/action/ability/activable/xeno/warrior/punch/jester, // Warrior punch
		/datum/action/ability/xeno_action/tail_sweep/jester, // Defenders tailsweep
		/datum/action/ability/activable/xeno/tail_trip/jester // Dancers tailsweep
	)

/datum/action/ability/xeno_action/tarot_deck/action_activate()
	var/chosen = pick(possible_abilities)
	var/datum/action/ability/togrant = new chosen
	togrant.give_action(owner)
	remove_action(xeno_owner)
	succeed_activate()

//Defender Spin, Warrior Punch, Dancer Spin

/datum/action/ability/activable/xeno/spray_acid/line/jester/use_ability()
	. = ..()
	return_tarot_deck(owner)

/datum/action/ability/activable/xeno/warrior/punch/jester
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)

/datum/action/ability/activable/xeno/warrior/punch/jester/do_ability()
	. = ..()
	return_tarot_deck(owner)

/datum/action/ability/xeno_action/tail_sweep/jester
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)

/datum/action/ability/xeno_action/tail_sweep/jester/action_activate()
	. = ..()
	return_tarot_deck(owner)

/datum/action/ability/activable/xeno/tail_trip/jester
	ability_cost = 0
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)

/datum/action/ability/activable/xeno/tail_trip/jester/use_ability(atom/target_atom)
	. = ..()
	return_tarot_deck(owner)

// ***************************************
// *********** Doppelganger (Primo)
// ***************************************

/datum/action/ability/xeno_action/doppelganger
	name = "Doppelgänger"
	action_icon_state = "tarot"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Temporarily obtain the abilties of another caste"
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DOPPELGANGER,
	)
	cooldown_duration = JESTER_DOPPLEGANGER_COOLDOWN
	///How much plasma was added by this ability on use.
	var/added_plasma

	///Whitelist of the most common castes, 50% chance
	var/list/common_castes = list(
		new /datum/xeno_caste/runner,
		new /datum/xeno_caste/defender,
		new /datum/xeno_caste/sentinel,
	)

	///Whitelist of the somewhat common castes, 30% chance
	var/list/uncommon_castes = list(
		new /datum/xeno_caste/bull,
		new /datum/xeno_caste/carrier,
		new /datum/xeno_caste/spitter,
	)

	///Whitelist of the somewhat rare castes, 15% chance
	var/list/rare_castes = list(
		new /datum/xeno_caste/warrior,
		new /datum/xeno_caste/warlock,
		new /datum/xeno_caste/crusher,
		new /datum/xeno_caste/ravager,
	)

	///Whitelist of the very rare castes, 5% chance
	var/list/ultrare_castes = list(
		new /datum/xeno_caste/queen,
		new /datum/xeno_caste/defiler,
	)

	///Blacklisted abilties, etiher to avoid buggy behaviour, duplicated abilties, or just general unbalancedness
	var/list/blacklist_abilties = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/xeno_action/chips,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/xeno_action/pheromones/emit_recovery,
		/datum/action/ability/xeno_action/pheromones/emit_warding,
		/datum/action/ability/xeno_action/pheromones/emit_frenzy,
		/datum/action/toggle_seethrough,
	)

	///The temporarily added abilties
	var/list/added_ablties = list()

/datum/action/ability/xeno_action/doppelganger/action_activate()
	var/datum/xeno_caste/picked_caste
	switch(rand(1,100))
		if(1 to 50)
			picked_caste = pick(common_castes)
		if(51 to 80)
			picked_caste = pick(uncommon_castes)
		if(81 to 95)
			picked_caste = pick(rare_castes)
		if(96 to 100)
			picked_caste = pick(ultrare_castes)
	for(var/action in picked_caste.actions)
		if(!(action in blacklist_abilties))
			if(ispath(action, /datum/action/ability/xeno_action))
				var/datum/action/ability/xeno_action/ability = new action(xeno_owner)
				ability.give_action(xeno_owner)
				added_ablties += ability
			else
				var/datum/action/ability/activable/xeno/ability = new action(xeno_owner)
				ability.give_action(xeno_owner)
				added_ablties += ability
	xeno_owner.plasma_stored += picked_caste.plasma_max
	added_plasma = picked_caste.plasma_max
	xeno_owner.add_filter("doppelganger_outline", 4, outline_filter(0.5, picked_caste.doppelganger_color)) //My stand, blatant cheating
	if(ispath(picked_caste, /datum/xeno_caste/queen))
		xeno_owner.add_filter("doppelganger_outline_extra", 4, outline_filter(1, "#FF66FF")) //Should we pick queen, add a additional outer outline for the extra pop
	var/mob/living/carbon/xenomorph/jester/jestermob = xeno_owner
	jestermob.has_doppelganger = TRUE
	jestermob.doppelganger_caste = picked_caste
	jestermob.update_icons()
	xeno_owner.emote("roar")
	addtimer(CALLBACK(src, PROC_REF(remove_added_abilties)), 30 SECONDS)
	succeed_activate()
	add_cooldown()

/datum/action/ability/xeno_action/doppelganger/proc/remove_added_abilties()
	for(var/action in added_ablties)
		if(ispath(action, /datum/action/ability/xeno_action))
			var/datum/action/ability/xeno_action/ability = action
			ability.remove_action(xeno_owner)
			added_ablties -= action
		else
			var/datum/action/ability/activable/xeno/ability = action
			ability.remove_action(xeno_owner)
			added_ablties -= action
		qdel(action)
	xeno_owner.plasma_stored -= added_plasma
	added_plasma = 0
	xeno_owner.remove_filter("doppelganger_outline")
	var/mob/living/carbon/xenomorph/jester/jestermob = xeno_owner
	jestermob.has_doppelganger = FALSE
	jestermob.doppelganger_caste = null
	jestermob.update_icons()





