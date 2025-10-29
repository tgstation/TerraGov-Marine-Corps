// Lets go GAMBLING
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
		///1/40th of chips added as damage mult.
		var/addeddamagemult = 0.025 * chips
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
	/// List of debuffs that this ability picks from, to apply
	var/list/debuffs = list(
		STATUS_EFFECT_STAGGER,
		STATUS_EFFECT_CONFUSED,
		STATUS_EFFECT_INTOXICATED,
	)
	/// Wether or not this ability is usable
	var/active = TRUE


/datum/action/ability/activable/xeno/deck_of_disaster/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!active)
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
	desc = "Swaps this ability for a random one, from a deck. Right click the picked ability to reroll it, at the cost of invoking the cooldown of this ability"
	ability_cost = 75
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)
	cooldown_duration = JESTER_TAROT_DECK_COOLDOWN
	///Wether or not this ability is active and can be used
	var/active = TRUE
	///Admin tarot deck override, for testing. Will always draw this ability, regardless of blacklist
	var/tarot_override
	///Container for the mimiced ability
	var/datum/action/ability/activable/xeno/draw_deck_container/ability_container = new
	///Amount of options to pick from when using tarot deck. Uses a pick wheek if greater than 1
	var/tarot_options = 1
	///List of all abilties that cannot be picked. Includes noncombat abilties and or certain buggy / irrelevant abilties
	///Is a blacklist to cover the case of new caste gets added -> not added here, new abilties are then never added
	///Players are much more vocal about broken or unbalanced abilties than they are about abilities they may or may not know exist.
	var/list/blacklist_actions = list(
		/datum/action/ability/xeno_action/xeno_resting,
		/datum/action/ability/xeno_action/chips,
		/datum/action/ability/activable/xeno/cocoon,
		/datum/action/ability/xeno_action/tarot_deck,
		/datum/action/toggle_seethrough,
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/place_pattern,
		/datum/action/ability/xeno_action/rally_hive,
		/datum/action/ability/xeno_action/rally_minion,
		/datum/action/ability/activable/xeno/recycle,
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/xeno_action/toggle_speed,
		/datum/action/ability/xeno_action/build_tunnel,
		/datum/action/ability/activable/xeno/essence_link,
		/datum/action/ability/activable/xeno/psychic_cure/acidic_salve,
		/datum/action/ability/xeno_action/enhancement,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/xeno_action/choose_hugger_type,
		/datum/action/ability/activable/xeno/call_younger, //Is probally fine, but is restrictive in its use.
		/datum/action/ability/xeno_action/carrier_panic,
		/datum/action/ability/xeno_action/spawn_hugger,
		/datum/action/ability/xeno_action/place_trap,
		/datum/action/ability/activable/xeno/throw_hugger,
		/datum/action/ability/activable/xeno/screech, // No fun allowed
		/datum/action/ability/xeno_action/toggle_queen_zoom,
		/datum/action/ability/xeno_action/set_xeno_lead,
		/datum/action/ability/activable/xeno/queen_give_plasma,
		/datum/action/ability/xeno_action/bulwark,
		/datum/action/ability/xeno_action/ready_charge,
		/datum/action/ability/xeno_action/attach_spiderlings,
		/datum/action/ability/activable/xeno/spiderling_mark,
		/datum/action/ability/activable/xeno/cannibalise,
		/datum/action/ability/xeno_action/create_spiderling,
		/datum/action/ability/xeno_action/pheromones/hivemind,
		/datum/action/ability/xeno_action/xenohide,
		/datum/action/ability/xeno_action/psychic_whisper,
		/datum/action/ability/xeno_action/lay_egg,
		/datum/action/ability/xeno_action/baneling_explode,
		/datum/action/ability/xeno_action/primal_wrath,
		/datum/action/ability/xeno_action/toggle_bomb,
		/datum/action/ability/xeno_action/create_boiler_bomb,
		/datum/action/ability/xeno_action/fortify,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/xeno_action/change_form,
		/datum/action/ability/xeno_action/return_to_core,
		/datum/action/ability/xeno_action/psychic_trace,
		/datum/action/ability/xeno_action/conqueror_endurance,
		/datum/action/ability/xeno_action/hive_message/free,
		/datum/action/ability/xeno_action/bloodthirst,
		/datum/action/ability/xeno_action/vampirism,
		/datum/action/ability/xeno_action/place_acidwell,
		/datum/action/ability/activable/xeno/spray_acid,
		/datum/action/ability/activable/xeno/charge/forward_charge/unprecise,
		/datum/action/ability/activable/xeno/bombard,
		/datum/action/ability/activable/xeno/fly,
		/datum/action/ability/activable/xeno/grab,
		/datum/action/ability/activable/xeno/scorched_land,
		/datum/action/ability/activable/xeno/devour,
		/datum/action/ability/activable/xeno/command_minions,
		/datum/action/ability/activable/xeno/shoot_xeno_artillery,
		/datum/action/ability/activable/xeno/hunter_mark,
		/datum/action/ability/activable/xeno/warrior,
		/datum/action/ability/xeno_action,
		/datum/action/ability/activable/xeno,
		/datum/action/ability/xeno_action/deathmark,
		/datum/action/ability/xeno_action/toggle_agility,
		/datum/action/ability/xeno_action/burrow,
		/datum/action/ability/xeno_action/psychic_summon,
		/datum/action/ability/xeno_action/smokescreen_spit,
		/datum/action/ability/xeno_action/place_jelly_pod,
		/datum/action/ability/xeno_action/regenerate_skin,
		/datum/action/ability/xeno_action/zero_form_beam, //no fun allowed also buggy as hell
		/datum/action/ability/xeno_action/centrifugal_force,
		/datum/action/ability/activable/xeno/conqueror_will,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/xeno_action/acid_mine,
		/datum/action/ability/activable/xeno/drain_sting,
		/datum/action/ability/xeno_action/build_hugger_turret,
		/datum/action/ability/activable/xeno/inject_egg_neurogas,
		/datum/action/ability/xeno_action/steam_rush,
		/datum/action/ability/xeno_action/endure,
		/datum/action/ability/xeno_action/psychic_summon,
		/datum/action/ability/activable/xeno/acidic_missile,
		/datum/action/ability/activable/xeno/psy_blast,
		/datum/action/ability/xeno_action/evasion,
		/datum/action/ability/xeno_action/place_recovery_pylon,
		/datum/action/ability/xeno_action/petrify,
		/datum/action/ability/activable/xeno/psychic_link,
		/datum/action/ability/activable/xeno/infernal_trigger,
		/datum/action/ability/activable/xeno/oppressor/abduct,
		/datum/action/ability/activable/xeno/drain,
		/datum/action/ability/activable/xeno/transfusion,
		/datum/action/ability/activable/xeno/shattering_roar,
		/datum/action/ability/activable/xeno/feast,

	)
	///List of all the parent abilties that should have themselves and all of their children also blacklisted
	var/list/parent_blacklist_abilties = list(
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/activable/xeno/bull_charge,
		/datum/action/ability/xeno_action/stealth,
		/datum/action/ability/xeno_action/toggle_long_range,
		/datum/action/ability/xeno_action/select_reagent,
		/datum/action/ability/xeno_action/hive_message,
		/datum/action/ability/xeno_action/create_jelly,
		/datum/action/ability/xeno_action/pheromones,
		/datum/action/ability/activable/xeno/psydrain,
		/datum/action/ability/xeno_action/watch_xeno,
		/datum/action/ability/activable/xeno/plant_weeds,
		/datum/action/ability/activable/xeno/transfer_plasma,
		/datum/action/ability/xeno_action/ready_charge,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/draw_deck_container,
		/datum/action/ability/activable/xeno/xeno_spit,
	)
	///List of all castes that should have all of their abilties removed.
	var/list/blacklist_castes = list(
		/datum/xeno_caste/wraith = XENO_UPGRADE_PRIMO, // no fun allowed
		/datum/xeno_caste/hivemind = XENO_UPGRADE_BASETYPE, // No combat abilties
		/datum/xeno_caste/jester = XENO_UPGRADE_PRIMO, // Buggy
		/datum/xeno_caste/dragon = XENO_UPGRADE_PRIMO, // no fun allowed
		/datum/xeno_caste/king/conqueror = XENO_UPGRADE_PRIMO, // Unbalanced and buggy
		/datum/xeno_caste/behemoth = XENO_UPGRADE_PRIMO, // Buggy
		/datum/xeno_caste/warlock = XENO_UPGRADE_PRIMO, //Buggy
	)

GLOBAL_LIST_INIT(tarot_deck_actions, list())

/datum/action/ability/xeno_action/tarot_deck/give_action(mob/living/L)
	. = ..()
	if(length(GLOB.tarot_deck_actions) == 0) //If the actions list is empty, this is the first tikme this round a jester has evolved, and the list must be constructed
		for(var/y in blacklist_castes)
			var/datum/xeno_caste/i = GLOB.xeno_caste_datums[y][blacklist_castes[y]]
			for(var/x in i.actions)
				blacklist_actions += x
		for(var/i in parent_blacklist_abilties)
			for(var/x in typesof(i))
				blacklist_actions += x
		var/list/allabilties = subtypesof(/datum/action/ability/xeno_action) + subtypesof(/datum/action/ability/activable/xeno)
		for(var/datum/action/ability/i AS in allabilties)
			if(!(i in blacklist_actions))
				GLOB.tarot_deck_actions += i
	ability_container.give_action(xeno_owner)

/datum/action/ability/xeno_action/tarot_deck/can_use_action(silent, override_flags)
	. = ..()
	if(!active)
		return FALSE

/datum/action/ability/xeno_action/tarot_deck/action_activate()
	var/picked_ability
	if(tarot_options > 1)
		var/list/ability_candidates = list()
		var/list/ability_icons = list()
		for(var/i in 1 to tarot_options)
			var/chosen = pick(GLOB.tarot_deck_actions)
			ability_candidates += chosen
			var/datum/action/ability/ability_copy = GLOB.xeno_ability_datums[chosen]
			ability_icons[chosen] = image(ability_copy.action_icon, icon_state = ability_copy.action_icon_state)
		picked_ability = show_radial_menu(owner, owner, ability_icons, radius = 48)
		if(!picked_ability)
			picked_ability = pick(ability_candidates)
	else
		if(!tarot_override)
			picked_ability = pick(GLOB.tarot_deck_actions)
		else
			picked_ability = tarot_override
	ability_container.mimic(picked_ability, TRUE)
	hidden = TRUE
	active = FALSE
	xeno_owner.update_action_buttons(TRUE)
	succeed_activate()

/datum/action/ability/activable/xeno/draw_deck_container
	name = "Tarot Card"
	desc = "When Tarot Deck is used, this turns into a ability. Currently, it is empty. (report this as a bug if you see this)"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	action_icon_state = "tarot"
	ability_cost = 0
	hidden = TRUE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)
	///Wether or not this ability is currently active and allowed to be used
	var/active
	///Container for the ability we are actively mimicing
	var/datum/action/ability/container
	///Wether or not we should hide this ability after use, and reveal the parent tarot deck ability
	var/should_hide = TRUE


///Takes in a ability, and turns itself into that ability. Also zeros the cost of the ability
/datum/action/ability/activable/xeno/draw_deck_container/proc/mimic(datum/action/ability/ability_to_mimic, inform = FALSE)
	var/datum/action/ability/clone = new ability_to_mimic
	if(inform)
		xeno_owner.balloon_alert(xeno_owner,"Picked [clone.name] for next use!")
	active = TRUE
	hidden = FALSE
	clone.owner = owner
	name = clone.name
	action_icon = clone.action_icon
	action_icon_state = clone.action_icon_state
	desc = clone.desc
	container = clone
	container.give_action(xeno_owner)
	container.hidden = TRUE
	container.ability_cost = 0
	container.owner = owner
	container.on_jester_roll()
	xeno_owner.update_action_buttons(TRUE)
	//Typecasting to approipate level to set xeno_owner, as almost every ability uses it at some point
	if(ispath(ability_to_mimic, /datum/action/ability/activable/xeno))
		var/datum/action/ability/activable/xeno/targetable = clone
		targetable.xeno_owner = xeno_owner
	else if(ispath(ability_to_mimic, /datum/action/ability/xeno_action))
		var/datum/action/ability/xeno_action/nontargetable = clone
		nontargetable.xeno_owner = xeno_owner

/datum/action/ability/activable/xeno/draw_deck_container/can_use_action(silent, override_flags)
	. = ..()
	if(!active) // So that the ability gets darkened when it cant be used.
		return FALSE

/datum/action/ability/activable/xeno/draw_deck_container/can_use_ability(atom/A, silent, override_flags)
	if(!active)
		return FALSE
	///Effectively checking what type of ability we are mimicing, and calling the appropiate can_use
	if(istype(container, /datum/action/ability/activable))
		var/datum/action/ability/activable/targetable = container //can_use_ability is defined at this level
		if(!targetable.can_use_ability(A, TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
			return FALSE
	else if(istype(container, /datum/action/ability/xeno_action))
		if(!container.can_use_action(TRUE, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
			return FALSE
	return TRUE

/datum/action/ability/activable/xeno/draw_deck_container/use_ability(atom/A)
	container.select()
	RegisterSignal(owner, COMSIG_ABILITY_SUCCEED_ACTIVATE, PROC_REF(clean_up))
	///Effectively checking what type of ability we are mimicing, and calling the appropiate use_ability
	if(istype(container, /datum/action/ability/activable))
		var/datum/action/ability/activable/targetable = container //use_ability is defined at this level
		targetable.use_ability(A)
	else if(istype(container, /datum/action/ability/xeno_action))
		container.action_activate()

///Reset icons, deactivate so we cant be used again, and delete the contained ability
/datum/action/ability/activable/xeno/draw_deck_container/proc/clean_up()
	SIGNAL_HANDLER
	active = FALSE
	if(should_hide)
		hidden = TRUE
		var/datum/action/ability/xeno_action/tarot_deck/main_ability = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/tarot_deck]
		main_ability.active = TRUE
		main_ability.hidden = FALSE
		main_ability.add_cooldown()
	UnregisterSignal(owner, COMSIG_ABILITY_SUCCEED_ACTIVATE)
	action_icon = initial(action_icon)
	action_icon_state = initial(action_icon_state)
	name = initial(name)
	desc = initial(desc)
	xeno_owner.update_action_buttons(TRUE)
	addtimer(CALLBACK(src, PROC_REF(delete_mimic)), 10 SECONDS)

///Handles removing the action and qdeling it - theres gotta be a way to remove this race condition...
/datum/action/ability/activable/xeno/draw_deck_container/proc/delete_mimic()
	container.remove_action(owner)
	qdel(container)
	xeno_owner.update_action_buttons(TRUE)

/datum/action/ability/activable/xeno/draw_deck_container/alternate_action_activate()
	clean_up()

// ***************************************
// *********** Draw
// ***************************************
/datum/action/ability/xeno_action/draw
	name = "Draw"
	action_icon_state = "draw"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Draw two abilties, randomly - One from a deck focused on movement, and a second deck focused on defense."
	ability_cost = 25
	cooldown_duration = JESTER_DRAW_COOLDOWN
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAW,
	)

	///List of all abilties the movement deck pulls from
	var/list/movement_deck = list(
		/datum/action/ability/activable/xeno/pounce,
		/datum/action/ability/activable/xeno/warrior/lunge,
		/datum/action/ability/activable/xeno/advance/jester,
		/datum/action/ability/activable/xeno/charge/forward_charge/unprecise, //Beetle charge

	)

	///List of all abilties the defeense deck pulls from
	var/list/defense_deck = list(
		/datum/action/ability/xeno_action/mirage,
		/datum/action/ability/activable/xeno/ravage,
		/datum/action/ability/activable/xeno/feast/jester,
		/datum/action/ability/xeno_action/repulse,
		/datum/action/ability/activable/xeno/acid_shroud,
	)

	///Container for the movement deck ability
	var/datum/action/ability/activable/xeno/draw_deck_container/agility/movement = new
	///Container for the defense deck ability
	var/datum/action/ability/activable/xeno/draw_deck_container/defense/defense = new
	///Storage for the last used movement deck ability, to prevent it from being rolled twice in a row
	var/last_used_movement_ability
	///Storage for the last used defense deck ability, to prevent it from being rolled twice in a row
	var/last_used_defense_ability

/datum/action/ability/xeno_action/draw/give_action(mob/living/L)
	. = ..()
	movement.give_action(xeno_owner)
	defense.give_action(xeno_owner)
	xeno_owner.update_action_buttons(TRUE)

/datum/action/ability/xeno_action/draw/action_activate()
	. = ..()
	var/list/movement_list = movement_deck - last_used_movement_ability
	var/list/defense_list = defense_deck - last_used_defense_ability
	var/defense_ability = pick(defense_list)
	var/movement_ability = pick(movement_list)
	last_used_movement_ability = movement_ability
	last_used_defense_ability = defense_ability
	movement.deselect()
	defense.deselect()
	movement.mimic(movement_ability)
	defense.mimic(defense_ability)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/draw_deck_container/agility
	name = "Draw Deck : Agility"
	desc = "When Draw is used, this turns into a agility focused ability. Currently, it is empty."
	action_icon = 'icons/Xeno/actions/jester.dmi'
	action_icon_state = "draw_agility"
	ability_cost = 50
	hidden = FALSE
	should_hide = FALSE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAW_AGILITY,
	)

/datum/action/ability/activable/xeno/draw_deck_container/agility/alternate_action_activate()
	return

/datum/action/ability/activable/xeno/draw_deck_container/defense
	name = "Draw Deck: Defense"
	desc = "When Draw is used, this turns into a defense focused ability. Currently, it is empty."
	action_icon_state = "draw_defense"
	ability_cost = 50
	hidden = FALSE
	should_hide = FALSE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAW_DEFENSE,
	)

/datum/action/ability/activable/xeno/draw_deck_container/defense/alternate_action_activate()
	return

// ***************************************
// *********** Repulse, Rapid Retreat
// ***************************************
// Note : These are all for Draw, and are only avalible through that ability.

/datum/action/ability/xeno_action/repulse
	name = "Repulse"
	action_icon_state = "organic_bomb"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Fling all nearby humans away from you."
	ability_cost = 50
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAW_DEFENSE,
	)

/datum/action/ability/xeno_action/repulse/action_activate()
	. = ..()
	var/list/nearby_hostiles = cheap_get_humans_near(owner, 1.5)
	if(isemptylist(nearby_hostiles))
		owner.balloon_alert(owner, "No nearby humans!")
		return fail_activate()
	for(var/mob/i in nearby_hostiles)
		if(i.x < owner.x)
			if(i.y > owner.y)
				fling(JESTER_REPULSE_RANGE, NORTHWEST, i)
			if(i.y == owner.y)
				fling(JESTER_REPULSE_RANGE, WEST, i)
			if(i.y < owner.y)
				fling(JESTER_REPULSE_RANGE, SOUTHWEST, i)
		if(i.x == owner.x)
			if(i.y > owner.y)
				fling(JESTER_REPULSE_RANGE, NORTH, i)
			if(i.y < owner.y)
				fling(JESTER_REPULSE_RANGE, SOUTH, i)
		if(i.x > owner.x)
			if(i.y > owner.y)
				fling(JESTER_REPULSE_RANGE, NORTHEAST, i)
			if(i.y == owner.y)
				fling(JESTER_REPULSE_RANGE, EAST, i)
			if(i.y < owner.y)
				fling(JESTER_REPULSE_RANGE, SOUTHEAST, i)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/advance/jester
	name = "Rapid Retreat"
	action_icon_state = "crest_defense"
	action_icon = 'icons/Xeno/actions/defender.dmi'
	desc = "Rapidly retreat towards a location, disarming any marines in your path."
	ability_cost = 175
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAW_AGILITY,
	)
	advance_range = 7

/datum/action/ability/activable/xeno/advance/jester/use_ability(atom/A)
	xeno_owner.face_atom(A)
	var/datum/action/ability/xeno_action/ready_charge/bull_charge/charge = new
	charge.hidden = TRUE
	charge.give_action(xeno_owner)
	var/aimdir = get_dir(xeno_owner, A)
	if(charge)
		charge.charge_on(FALSE)
		charge.do_stop_momentum(FALSE) //Reset charge so next_move_limit check_momentum() does not cuck us and 0 out steps_taken
		charge.do_start_crushing()
		charge.valid_steps_taken = charge.max_steps_buildup - 1
		charge.charge_dir = aimdir //Set dir so check_momentum() does not cuck us
	for(var/i=0 to max(get_dist(xeno_owner, A), advance_range))
		xeno_owner.Move(get_step(xeno_owner, aimdir), aimdir)
		aimdir = get_dir(xeno_owner, A)
	charge.remove_action(xeno_owner)
	qdel(charge)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Doppelganger (Primo)
// ***************************************

/datum/action/ability/xeno_action/doppelganger
	name = "Doppelgänger"
	action_icon_state = "doppelganger"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	desc = "Temporarily obtain the abilties of another caste"
	ability_cost = 150
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DOPPELGANGER,
	)
	cooldown_duration = JESTER_DOPPELGANGER_COOLDOWN
	///How much plasma was added by this ability on use.
	var/added_plasma

	///Whitelist of the most common castes, 40% chance
	var/list/common_castes = list(
		/datum/xeno_caste/runner,
		/datum/xeno_caste/defender,
		/datum/xeno_caste/sentinel,
		/datum/xeno_caste/spitter,
		/datum/xeno_caste/pyrogen,
	)

	///Whitelist of the somewhat common castes, 35% chance
	var/list/uncommon_castes = list(
		/datum/xeno_caste/bull,
		/datum/xeno_caste/carrier,
		/datum/xeno_caste/hunter,
		/datum/xeno_caste/shrike,
		/datum/xeno_caste/warrior,
	)

	///Whitelist of the somewhat rare castes, 20% chance
	var/list/rare_castes = list(
		/datum/xeno_caste/widow,
		/datum/xeno_caste/warlock,
		/datum/xeno_caste/crusher,
		/datum/xeno_caste/ravager,
		/datum/xeno_caste/defiler,
	)

	///Whitelist of the very rare castes, 5% chance
	var/list/ultrare_castes = list(
		/datum/xeno_caste/queen,
		/datum/xeno_caste/king,
		/datum/xeno_caste/dragon, //teehee
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
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/place_pattern,
		/datum/action/ability/xeno_action/toggle_crest_defense,
		/datum/action/ability/xeno_action/fortify,
		/datum/action/ability/xeno_action/toggle_agility,
	)

	///The temporarily added abilties
	var/list/added_ablties = list()

/datum/action/ability/xeno_action/doppelganger/action_activate()
	var/caste_type_path
	var/datum/xeno_caste/picked_caste
	switch(rand(1,100))
		if(1 to 40)
			caste_type_path = pick(common_castes)
		if(41 to 75)
			caste_type_path = pick(uncommon_castes)
		if(75 to 95)
			caste_type_path = pick(rare_castes)
		if(96 to 100)
			caste_type_path = pick(ultrare_castes)
	picked_caste = GLOB.xeno_caste_datums[caste_type_path][XENO_UPGRADE_BASETYPE]
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
	if(picked_caste.spit_types)
		xeno_owner.ammo = picked_caste.spit_types[1]
	added_plasma = picked_caste.plasma_max
	xeno_owner.hud_set_plasma()
	xeno_owner.add_filter("doppelganger_outline", 4, outline_filter(0.5, picked_caste.doppelganger_color)) //My stand, blatant cheating
	if(ispath(picked_caste, /datum/xeno_caste/queen))
		xeno_owner.add_filter("doppelganger_outline_extra", 4, outline_filter(1, "#FF66FF")) //Should we pick queen, add a additional outer outline for the extra pop
	var/mob/living/carbon/xenomorph/jester/jestermob = xeno_owner
	jestermob.doppelganger_caste = picked_caste
	jestermob.update_icons()
	xeno_owner.emote("roar")
	addtimer(CALLBACK(src, PROC_REF(remove_added_abilties)), 30 SECONDS)
	succeed_activate()
	add_cooldown()

///Handles removing all of the abilties that were previously added by this ability, and removing the overlays + stand reference
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
	xeno_owner.plasma_stored = max(xeno_owner.plasma_stored - added_plasma, 0)
	xeno_owner.hud_set_plasma()
	xeno_owner.ammo = /datum/ammo/xeno/acid/medium
	added_plasma = 0
	xeno_owner.remove_filter("doppelganger_outline")
	var/mob/living/carbon/xenomorph/jester/jestermob = xeno_owner
	jestermob.doppelganger_caste = null
	jestermob.update_icons()





