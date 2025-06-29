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
	///Wether or not this ability is active and can be used
	var/active = TRUE
	///Temporary storage for the ability to be used on next activation of this ability
	var/datum/action/ability/ability_container
	///Containers for for the two types of abilties, so that targetable abilties can be used even though this is a nontargeted ability
	var/datum/action/ability/xeno_action/tarot_deck_container/nontargetable = new
	var/datum/action/ability/activable/xeno/tarot_deck_container/targetable = new
	///List of all abilties that cannot be picked. Includes noncombat abilties and or certain buggy / irrelevant abilties
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
		/datum/action/ability/xeno_action/dodge,
		/datum/action/ability/xeno_action/centrifugal_force,
		/datum/action/ability/activable/xeno/conqueror_will,
		/datum/action/ability/xeno_action/tarot_deck_container,
		/datum/action/ability/activable/xeno/earth_riser,
		/datum/action/ability/activable/xeno/psychic_shield,
		/datum/action/ability/xeno_action/acid_mine,
		/datum/action/ability/activable/xeno/snatch,
		/datum/action/ability/activable/xeno/drain_sting,
		/datum/action/ability/xeno_action/sow,
		/datum/action/ability/xeno_action/build_hugger_turret,
	)
	///List of all the parent abilties that should have themselves and all of their children also blacklisted
	var/list/parent_blacklist_abilties = list(
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
		/datum/action/ability/activable/xeno/secrete_resin,
		/datum/action/ability/activable/xeno/transfer_plasma,
		/datum/action/ability/xeno_action/ready_charge,
		/datum/action/ability/xeno_action/call_of_the_burrowed,
		/datum/action/ability/activable/xeno/corrosive_acid,
		/datum/action/ability/activable/xeno/tarot_deck_container,

	)
	///List of all castes that should have all of their abilties removed.
	var/list/blacklist_castes = list(
		new /datum/xeno_caste/wraith/primordial, ///no fun allowed
		new /datum/xeno_caste/hivemind, ///No combat abilties
		new /datum/xeno_caste/jester/primordial, ///Buggy
		new /datum/xeno_caste/dragon, // no fun allowed
		new /datum/xeno_caste/king/conqueror, ///Unbalanced and buggy
		new /datum/xeno_caste/behemoth, ///Abilties rely on alot of snowflake maptext in order to not runntime
	)

GLOBAL_LIST_INIT(tarot_deck_actions, list())

/datum/action/ability/xeno_action/tarot_deck/give_action(mob/living/L)
	. = ..()
	if(length(GLOB.tarot_deck_actions) == 0) //If the actions list is empty, this is the first tikme this round a jester has evolved, and the list must be constructed
		for(var/datum/xeno_caste/i AS in blacklist_castes)
			for(var/x in i.actions)
				blacklist_actions += x
		for(var/i in parent_blacklist_abilties)
			for(var/x in typesof(i))
				blacklist_actions += x
		var/list/allabilties = subtypesof(/datum/action/ability/xeno_action) + subtypesof(/datum/action/ability/activable/xeno)
		for(var/datum/action/ability/i AS in allabilties)
			if(!(i in blacklist_actions))
				GLOB.tarot_deck_actions += i
	targetable.give_action(xeno_owner)
	nontargetable.give_action(xeno_owner)

/datum/action/ability/xeno_action/tarot_deck/can_use_action(silent, override_flags)
	. = ..()
	if(!active)
		return FALSE

/datum/action/ability/xeno_action/tarot_deck/action_activate()
	if(ability_container) // If we have no ability then select one and inform the jester of what was selected
		return
	var/picked_ability = pick(GLOB.tarot_deck_actions)
	ability_container = new picked_ability
	ability_container.ability_cost = 0
	xeno_owner.balloon_alert(xeno_owner,"Picked [ability_container.name] for next use!")
	if(ispath(ability_container.type, /datum/action/ability/activable/xeno))
		targetable.active = TRUE
		targetable.name = ability_container.name
		targetable.action_icon = ability_container.action_icon
		targetable.action_icon_state = ability_container.action_icon_state
		targetable.hidden = FALSE
		targetable.desc = ability_container.desc
		targetable.container = ability_container
		targetable.container.give_action(xeno_owner)
		targetable.container.hidden = TRUE
	else
		nontargetable.active = TRUE
		nontargetable.name = ability_container.name
		nontargetable.action_icon = ability_container.action_icon
		nontargetable.action_icon_state = ability_container.action_icon_state
		nontargetable.hidden = FALSE
		nontargetable.desc = ability_container.desc
		nontargetable.container = ability_container
		nontargetable.container.give_action(xeno_owner)
		nontargetable.container.hidden = TRUE
	hidden = TRUE
	active = FALSE
	xeno_owner.update_action_buttons(TRUE)
	succeed_activate()

//Containers for tarot deck, of both types of abilties.
/datum/action/ability/activable/xeno/tarot_deck_container
	action_icon_state = "tarot"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	ability_cost = 0
	hidden = TRUE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)
	///Wether or not this ability is currently active and allowed to be used
	var/active
	///Container for the ability we are actively mimicing
	var/datum/action/ability/activable/xeno/container

/datum/action/ability/activable/xeno/tarot_deck_container/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!active)
		return FALSE
	if(!container)
		return FALSE
	if(!container.can_use_ability(A, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE

/datum/action/ability/activable/xeno/tarot_deck_container/use_ability(atom/A)
	container.xeno_owner = xeno_owner
	container.owner = owner
	container.select()
	RegisterSignal(owner, COMSIG_ABILITY_SUCCEED_ACTIVATE, PROC_REF(clean_up))
	container.use_ability(A)

///Called after the mimiced ability has been used, handles returning Tarot deck, deleting the contained ability, and hiding itself
/datum/action/ability/activable/xeno/tarot_deck_container/proc/clean_up()
	SIGNAL_HANDLER
	hidden = TRUE
	active = FALSE
	var/datum/action/ability/xeno_action/tarot_deck/main_ability = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/tarot_deck]
	main_ability.active = TRUE
	main_ability.hidden = FALSE
	xeno_owner.update_action_buttons(TRUE)
	main_ability.ability_container = null
	main_ability.add_cooldown()
	UnregisterSignal(owner, COMSIG_ABILITY_SUCCEED_ACTIVATE)
	addtimer(CALLBACK(src, PROC_REF(delete_mimic)), 10 SECONDS)

/datum/action/ability/activable/xeno/tarot_deck_container/proc/delete_mimic()
	qdel(container)

/datum/action/ability/xeno_action/tarot_deck_container
	action_icon_state = "tarot"
	action_icon = 'icons/Xeno/actions/jester.dmi'
	ability_cost = 0
	hidden = TRUE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAROT_DECK,
	)
	///Wether or not this ability is currently active and allowed to be used
	var/active
	///Container for the ability we are actively mimicing
	var/datum/action/ability/xeno_action/container

/datum/action/ability/xeno_action/tarot_deck_container/can_use_action(silent, override_flags)
	. = ..()
	if(!active)
		return FALSE
	if(!container)
		return FALSE
	if(!container.can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE

/datum/action/ability/xeno_action/tarot_deck_container/action_activate()
	container.xeno_owner = xeno_owner
	container.owner = owner
	container.select()
	if(container.action_activate())
		hidden = TRUE
		active = FALSE
		container.remove_action(xeno_owner)
		var/datum/action/ability/xeno_action/tarot_deck/main_ability = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/tarot_deck]
		main_ability.active = TRUE
		main_ability.hidden = FALSE
		xeno_owner.update_action_buttons(TRUE)
		main_ability.ability_container = null
		main_ability.add_cooldown()

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
		/datum/action/ability/xeno_action/blessing_menu,
		/datum/action/ability/activable/xeno/place_pattern,
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





