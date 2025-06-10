
// Stew pod
/datum/action/ability/xeno_action/place_stew_pod
	name = "Place Ambrosia Pot"
	action_icon_state = "resin_stew_pod"
	action_icon = 'ntf_modular/icons/xeno/construction.dmi'
	desc = "Place down a dispenser that allows xenos to retrieve expensive jelly that may sold to humans."
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
			T.balloon_alert(owner, "Cannot place pod")
		return FALSE

	if(!xeno_owner.loc_weeds_type)
		if(!silent)
			T.balloon_alert(owner, "Cannot place pod, no weeds")
		return FALSE

	if(!T.check_disallow_alien_fortification(owner, silent))
		return FALSE

	if(!T.check_alien_construction(owner, silent, /obj/structure/xeno/resin_stew_pod))
		return FALSE

	var/hivenumber = owner.get_xeno_hivenumber()


/datum/action/ability/xeno_action/place_stew_pod/action_activate()
	var/turf/T = get_turf(owner)

	succeed_activate()

	playsound(owner, SFX_ALIEN_RESIN_BUILD, 25)
	var/obj/structure/xeno/resin_stew_pod/pod = new(T, owner.get_xeno_hivenumber())
	pod.creator_ckey = owner.ckey
	to_chat(owner, span_xenonotice("We shape some resin into \a [pod]."))
	add_cooldown()
