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
	use_state_flags = ABILITY_USE_LYING
	hidden = TRUE
	/// The amount of chips this xeno has stored
	var/chips = 0
	/// The total amount of chips this owner can store
	var/maxchips = 20
	/// The amount of succesfull gambles this owner has completed in a row. Used to determine the bonus damage
	var/succesfullgambles = 0
	// todo actually do this lole

// ***************************************
// *********** Deck of Disaster
// ***************************************
/datum/action/ability/activable/xeno/deck_of_disaster
	name = "Deck of Disaster"
	action_icon_state = "organic_bomb"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Afflicts your target with a random debuff."
	ability_cost = 50
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_DECK_OF_DISASTER,
	)
	cooldown_duration = JESTER_DECK_OF_DISASTER_COOLDOWN
	var/list/avalible_debuffs = list(
		STATUS_EFFECT_STAGGER,
		STATUS_EFFECT_STUN,
		STATUS_EFFECT_CONFUSED,
		STATUS_EFFECT_LIFEDRAIN,
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

	if(!ishuman(target) || issynth(target))
		return FALSE

	return TRUE

/datum/action/ability/activable/xeno/deck_of_disaster/use_ability(atom/A)
	xeno_owner.face_atom(A)

