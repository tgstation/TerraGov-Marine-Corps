
// Stew pod
/datum/action/ability/xeno_action/place_stew_pod
	name = "Place Ambrosia Pot"
	action_icon_state = "resin_stew_pod"
	action_icon = 'ntf_modular/icons/xeno/construction.dmi'
	desc = "Place down a dispenser that allows you to retrieve expensive jelly that may sold to humans. Each xeno can only own two pots at once."
	ability_cost = 50
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_STEW_POD,
	)

	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/place_stew_pod/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(owner)
	if(!T || !T.is_weedable() || T.density)
		if(!silent)
			owner.balloon_alert(owner, "Cannot place pot")
		return FALSE

	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			owner.balloon_alert(owner, "Cannot place pot, no weeds")
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

	if(!T.check_alien_construction(owner, silent, /obj/structure/xeno/resin_stew_pod))
		return FALSE

	var/hivenumber = owner.get_xeno_hivenumber()
	for(var/obj/silo AS in GLOB.xeno_resin_silos_by_hive[hivenumber])
		if((silo.z == xeno_owner.z) && (get_dist(xeno_owner, silo) <= 15))
			if(!silent)
				owner.balloon_alert(owner, "One of our hive's silos is too close!")
			return FALSE
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	for(var/obj/req_jelly_pod AS in hive.req_jelly_pods)
		if((req_jelly_pod.z == xeno_owner.z) && (get_dist(xeno_owner, req_jelly_pod) <= 10))
			if(!silent)
				owner.balloon_alert(owner, "One of our hive's ambrosia pots is too close!")
			return FALSE

/datum/action/ability/xeno_action/place_stew_pod/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()
	var/hivenumber = owner.get_xeno_hivenumber()
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	var/list/existing_pods = list()
	for(var/obj/structure/xeno/resin_stew_pod/resin_stew_pod AS in hive.req_jelly_pods)
		if(resin_stew_pod.creator_ckey == xeno_owner.ckey)
			existing_pods += resin_stew_pod
			if(length(existing_pods) >= 2) // max two per xeno
				qdel(existing_pods[1]) // should be the oldest one
				existing_pods -= null
				to_chat(owner, span_xenonotice("One of your existing ambrosia pots was destroyed because you have too many."))
	playsound(owner, SFX_ALIEN_RESIN_BUILD, 25)
	var/obj/structure/xeno/resin_stew_pod/pod = new(T, hivenumber)
	pod.creator_ckey = owner.ckey
	to_chat(owner, span_xenonotice("We shape some resin into \a [pod]."))
	add_cooldown()

// ***************************************
// *********** Psychic Radiance
// ***************************************
/datum/action/ability/xeno_action/psychic_radiance
	name = "Psychic Radiance"
	desc = "Use your psychic powers to send a message to all humans you can see."
	action_icon_state = "psychic_radiance"
	action_icon = 'ntf_modular/icons/xeno/actions.dmi'
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_RADIANCE,
	)
	use_state_flags = ABILITY_USE_INCAP|ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED|ABILITY_USE_NOTTURF|ABILITY_USE_BUSY|ABILITY_USE_SOLIDOBJECT|ABILITY_USE_BURROWED // Proudly copypasted from psychic whisper
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/xeno_action/psychic_radiance/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, X))
		if(possible_target == X || !possible_target.client || isxeno(possible_target)) // Would ruin the whole point if we whisper to xenos too
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(X, span_warning("There's nobody nearby to radiate to."))
		return

	var/msg = tgui_input_text(usr, desc, name, "", MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)

	msg = copytext_char(trim(sanitize(msg)), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	if(X.stat)
		to_chat(src, span_warning("We cannot do this while not conscious."))
		return

	for(var/mob/living/L in target_list)
		to_chat(L, span_psychicin("You hear a strange, alien voice in your head. <i>\"[msg]\"</i>"))
		log_directed_talk(X, L, msg, LOG_SAY, "psychic radiance")

	to_chat(X, span_psychicout("We radiated: \"[msg]\" to everyone nearby."))
	message_admins("[ADMIN_LOOKUP(X)] has sent this psychic radiance: \"[msg]\" at [ADMIN_VERBOSEJMP(X)].")

// ***************************************
// *********** Psychic Influence
// ***************************************
/datum/action/ability/xeno_action/psychic_influence
	name = "Psychic Influence"
	desc = "Use your psychic powers to plant a thought in the mind of an individual you can see."
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "psychic_whisper"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_INFLUENCE,
	)
	use_state_flags = ABILITY_USE_INCAP|ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED|ABILITY_USE_NOTTURF|ABILITY_USE_BUSY|ABILITY_USE_SOLIDOBJECT|ABILITY_USE_BURROWED
	target_flags = ABILITY_MOB_TARGET


/datum/action/ability/xeno_action/psychic_influence/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/list/target_list = list()
	for(var/mob/living/possible_target in view(WORLD_VIEW, X))
		if(possible_target == X || !possible_target.client) // Removed the Isxeno; time for some xeno on xeno psychic shenanigans ;
			continue
		target_list += possible_target

	if(!length(target_list))
		to_chat(X, "<span class='warning'>There's nobody nearby to influence.</span>")
		return

	var/mob/living/L = tgui_input_list(X, "Target", "Send a Psychic Influence to whom?", target_list)
	if(!L)
		return

	if(X.stat)
		to_chat(src, span_warning("We cannot do this while not conscious."))
		return

	var/msg = tgui_input_text(usr, desc, name, "", MAX_MESSAGE_LEN, multiline = TRUE, encode = FALSE)

	msg = copytext_char(trim(sanitize(msg)), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	if(X.stat)
		to_chat(src, span_warning("We cannot do this while not conscious."))
		return

	log_directed_talk(X, L, msg, LOG_SAY, "psychic influence")
	to_chat(L, "<span class='psychicin'><i>[msg]</i></span>")
	to_chat(X, "<span class='psychicout'>We influenced: [msg] to [L]</span>")
	for(var/_M in GLOB.observer_list) // it's the xeno's main method of S M U T, so it should be visible
		var/mob/M = _M
		if(M == L || M == X)
			continue
		if(M.stat != DEAD) //not dead, not important
			continue
		if(!M.client)
			continue
		if(get_dist(M, X) > 7 || M.z != X.z) //they're out of range of normal S M U T
			if(!(M.client.prefs.toggles_chat & CHAT_GHOSTEARS) && !check_other_rights(M.client, R_ADMIN, FALSE))
				continue
		if((istype(M.remote_control, /mob/camera/aiEye) || isAI(M))) // Not sure why this is here really, but better S M U T than sorry
			continue

		if(check_other_rights(M.client, R_ADMIN, FALSE))
			to_chat(M, "[FOLLOW_LINK(M, X)]<span class='psychicin'>Psychic Influence: <b>[ADMIN_LOOKUP(X)] > [ADMIN_LOOKUP(L)]:</b> <i>\"[msg]\"</i></span>")
		else
			to_chat(M, "[FOLLOW_LINK(M, X)]<span class='psychicin'>Psychic Influence: <b>[X] > [L]:</b> <i>\"[msg]\"</i></span>")

//Xeno Larval Growth Sting
/datum/action/ability/activable/xeno/larval_growth_sting
	name = "Larval Growth Sting"
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "larval_growth"
	desc = "Inject an impregnated host with growth serum, causing the larva inside to grow quicker. Has harmful effects for non-infected hosts while stabilizing larva-infected hosts."

	ability_cost = 150
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LARVAL_GROWTH_STING,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/larval_growth_sting/on_cooldown_finish()
	playsound(owner.loc, SFX_ALIEN_DROOL, 25, 1)
	to_chat(owner, "<span class='xenodanger'>We feel our growth toxin glands refill. We can use Growth Sting again.</span>")
	return ..()

/datum/action/ability/activable/xeno/larval_growth_sting/can_use_ability(mob/living/carbon/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(QDELETED(A))
		return FALSE

	if(!A?.can_sting())
		if(!silent)
			to_chat(owner, "<span class='warning'>Our sting won't affect this target!</span>")
		return FALSE

	if(!owner.Adjacent(A))
		var/mob/living/carbon/xenomorph/X = owner
		if(!silent && world.time > (X.recent_notice + X.notice_delay))
			to_chat(X, "<span class='warning'>We can't reach this target!</span>")
			X.recent_notice = world.time //anti-notice spam
		return FALSE

/datum/action/ability/activable/xeno/larval_growth_sting/use_ability(mob/living/carbon/A)
	var/mob/living/carbon/xenomorph/X = owner

	succeed_activate()

	add_cooldown()
	if(locate(/obj/item/alien_embryo) in A)
		X.recurring_injection(A, list(/datum/reagent/consumable/larvajelly,/datum/reagent/medicine/tricordrazine,/datum/reagent/medicine/inaprovaline,/datum/reagent/medicine/dexalin), XENO_LARVAL_CHANNEL_TIME, XENO_LARVAL_AMOUNT_RECURRING, 3)
		A.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, 1)
	else
		X.recurring_injection(A, list(/datum/reagent/toxin/xeno_neurotoxin,/datum/reagent/consumable/larvajelly), XENO_LARVAL_CHANNEL_TIME, XENO_LARVAL_AMOUNT_RECURRING, 3)

/mob/living/carbon/human/salve_healing()
	. = ..()
	xeno_heals++
	if((xeno_heals % 3) == 0)
		for(var/datum/limb/limb_to_fix in shuffle(limbs))
			if(limb_to_fix.limb_status & (LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED))
				if(limb_to_fix.brute_dam > limb_to_fix.min_broken_damage)
					continue
				limb_to_fix.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
				limb_to_fix.add_limb_flags(LIMB_REPAIRED)
				visible_message("[src]'s broken [limb_to_fix.name] is repaired by the healing!", "Your broken [limb_to_fix.name] is repaired by the healing!")
				break

/mob/living/carbon/human/psychic_cure()
	. = ..()
	xeno_heals++
	if((xeno_heals % 3) == 0)
		for(var/datum/limb/limb_to_fix in shuffle(limbs))
			if(limb_to_fix.limb_status & (LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED))
				if(limb_to_fix.brute_dam > limb_to_fix.min_broken_damage)
					continue
				limb_to_fix.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
				limb_to_fix.add_limb_flags(LIMB_REPAIRED)
				visible_message("[src]'s broken [limb_to_fix.name] is repaired by the healing!", "Your broken [limb_to_fix.name] is repaired by the healing!")
				break

///
/// ******** Possession *****
/// For taking over mobs as mob makers/hivemind
/datum/action/ability/activable/xeno/possession
	name = "Minion Possession"
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "baneling"
	desc = "Take control of a minion that you have jurisdiction over."

	ability_cost = 1 // Change later
	cooldown_duration = 1 SECONDS // Same here
	action_type = ACTION_SELECT
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_POSSESS,
	)
	target_flags = ABILITY_XENO_TARGET

/*/datum/action/ability/activable/xeno/possession/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if (owner.status_flags & INCORPOREAL)
		return FALSE*/

/datum/action/ability/activable/xeno/possession/use_ability(atom/movable/A)
	var/mob/living/carbon/xenomorph/X = owner
	if(!ismob(A))
		return FALSE
	if(X.do_actions)
		return FALSE
	if(!X.issamexenohive(A))
		return FALSE
	if(!can_use_action(X, TRUE))
		return FALSE
	if(!isxeno(A))
		return FALSE

	var/mob/living/carbon/xenomorph/new_mob = A
	if(istype(X.xeno_caste, /datum/xeno_caste/hivemind))
		if(!istype(new_mob.xeno_caste, /datum/xeno_caste/beetle) && \
			!istype(new_mob.xeno_caste, /datum/xeno_caste/mantis) && \
			!istype(new_mob.xeno_caste, /datum/xeno_caste/scorpion) && \
			!istype(new_mob.xeno_caste, /datum/xeno_caste/nymph) \
		)
			return FALSE

	if(isxenopuppeteer(X))
		if(!istype(new_mob.xeno_caste, /datum/xeno_caste/puppet))
			return FALSE
			/*if( /datum/weakref/weak_master < puppytear ref) Allows puppeteers to take over other peoples puppets until this works... nobody plays puppeteer though*/

	if(isxenowidow(X))
		if(!istype(new_mob.xeno_caste, /datum/xeno_caste/spiderling))
			return FALSE
			/*if( mob/living/carbon/xenomorph/spidermother < widdy ref) Allows widows to take over other peoples spiders until this works... nobody plays widow though*/

	A.visible_message(span_xenowarning("[A] lightly shimmers and wakes up."), \
	span_xenowarning("We feel a controlling chill."))
	playsound(A, SFX_ALIEN_DROOL, 25)
	new /obj/effect/temp_visual/telekinesis(get_turf(A))
	succeed_activate()
	add_cooldown()
	if(HAS_TRAIT(new_mob, TRAIT_POSSESSING))
		to_chat(X, span_warning("That mob is currently possessing a different mob."))
		return FALSE

	if(new_mob.client)
		to_chat(X, span_warning("That mob has been occupied."))
		return FALSE

	if(new_mob.stat == DEAD)
		to_chat(X, span_warning("You cannot join if the mob is dead."))
		return FALSE

	if(!ishuman(new_mob))
		log_admin("[owner.key] took control of [new_mob.name] as [new_mob.p_they()] used the possession ability.")
		new_mob.transfer_mob(owner)
		var/datum/action/ability/xeno_action/return_to_body/returning = new /datum/action/ability/xeno_action/return_to_body
		if(!new_mob.actions_by_path[/datum/action/ability/xeno_action/return_to_body])
			returning.give_action(new_mob)
		returning.old_mob = owner
		ADD_TRAIT(X, TRAIT_POSSESSING, TRAIT_POSSESSING)
		return

///****For getting back to your body****
/datum/action/ability/xeno_action/return_to_body
	name = "Return to Body"
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "baneling"
	desc = "Release control of a minion that you have jurisdiction over."
	ability_cost = 0 // Change later
	cooldown_duration = 0 SECONDS // Same here
	action_type = ACTION_CLICK
	target_flags = ABILITY_XENO_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RETURN,
	)

/datum/action/ability/xeno_action/return_to_body
	var/mob/living/carbon/xenomorph/old_mob = null

	var/datum/action/ability/xeno_action/return_to_body/leaving = /datum/action/ability/xeno_action/return_to_body
	use_state_flags = ABILITY_USE_INCAP|ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED|ABILITY_USE_NOTTURF|ABILITY_USE_BUSY|ABILITY_USE_SOLIDOBJECT|ABILITY_USE_BURROWED


/datum/action/ability/xeno_action/return_to_body/action_activate(xeno_owner)
	var/mob/living/carbon/xenomorph/X = owner
	if(!owner || QDELETED(old_mob))
		to_chat(src, span_warning("Your old body is gone."))
		return FALSE

	if(old_mob.key)
		to_chat(src, span_warning("Another consciousness is in your body...It is resisting you."))
		return FALSE

	old_mob.transfer_mob(owner)
	X.possessor = null
	leaving.remove_action(X)
	src.old_mob = null
	REMOVE_TRAIT(old_mob, TRAIT_POSSESSING, TRAIT_POSSESSING)
	return TRUE

// For the hivemind to create non-AI driven minions, unfortunately this doesn't work right now. Try again later.
/*/datum/action/ability/activable/xeno/creation
	name = "Minion Creation"
	action_icon = 'ntf_modular/icons/Xeno/actions.dmi'
	action_icon_state = "spawn_pod"
	desc = "Create a brainless minion to be possessed by you."

	ability_cost = 1 // Change later
	cooldown_duration = 1 SECONDS // Same here
	action_type = ACTION_TOGGLE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREATE,
	)
	target_flags = ABILITY_TURF_TARGET
	var/list/spawnable_minions = list(
		/mob/living/carbon/xenomorph/beetle,
		/mob/living/carbon/xenomorph/nymph,
		/mob/living/carbon/xenomorph/mantis,
		/mob/living/carbon/xenomorph/scorpion,)


/datum/action/ability/activable/xeno/creation/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if (owner.status_flags & INCORPOREAL)
		return FALSE

/datum/action/ability/activable/xeno/creation/action_activate()
	//Left click on the secrete resin button opens up radial menu (new type of changing structures).
	if(xeno_owner.selected_ability != src)
		return ..()
	. = ..()
	var/spawn_choice = show_radial_menu(owner, owner, GLOB.spawnable_minion_list, radius = 35)
	if(!spawn_choice)
		return
	set_spawn_type(spawnable_minions[GLOB.spawnable_minion_list.Find(spawn_choice)])

/*	var/mob/living/carbon/xenomorph/spiderling/new_spiderling = new(owner.loc, owner, owner)*/

/datum/action/ability/activable/xeno/creation/proc/set_spawn_type(new_spawn, silent = FALSE)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.spawn_choice = new_spawn
	update_button_icon()
	if(silent)
		return
	var/atom/spawnn = xeno_owner.spawn_choice
	xeno_owner.balloon_alert(xeno_owner, lowertext(spawnn::name))

	/datum/action/ability/activable/xeno/creation/proc/choose_spawn()
	var/list/available_spawns = list()
	for(var/obj/alien/weeds/node/minion_type_possible AS in spawnable_minions)
		var/minion_image = GLOB.spawnable_minion_list[initial(weed_type_possible.name)]
		if(!minion_image)
			continue
		available_spawns[initial(minion_type_possible.name)] = minion_image

	var/weed_choice = show_radial_menu(xeno_owner, xeno_owner, available_weeds, radius = 48)
	if(!weed_choice)
		return
	else
		for(var/obj/alien/weeds/node/weed_type_possible AS in GLOB.weed_type_list)
			if(initial(weed_type_possible.name) == weed_choice)
				weed_type = weed_type_possible
				update_ability_cost()
				break
		to_chat(owner, span_xenonotice("We will now spawn <b>[weed_choice]\s</b> when using the plant weeds ability."))
	update_button_icon()*/
