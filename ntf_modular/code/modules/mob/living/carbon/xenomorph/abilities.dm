
// Stew pod
/datum/action/ability/xeno_action/place_stew_pod
	name = "Place Ambrosia Pot"
	action_icon_state = "resin_stew_pod"
	action_icon = 'ntf_modular/icons/xeno/construction.dmi'
	desc = "Place down a dispenser that allows you to retrieve expensive jelly that may sold to humans. Each xeno can only own two pots at once."
	ability_cost = 50
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PLACE_STEW_POD,
	)

	use_state_flags = ABILITY_USE_LYING

/datum/action/ability/xeno_action/place_stew_pod/can_use_action(silent = FALSE, override_flags)
	. = ..()
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
