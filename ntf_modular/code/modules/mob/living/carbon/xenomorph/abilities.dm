
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
