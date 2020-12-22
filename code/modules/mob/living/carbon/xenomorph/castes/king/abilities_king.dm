/datum/action/xeno_action/activable/whisper
	name = "Whisper"
	action_icon_state = "emit_neurogas2"
	mechanics_text = "A large area attack that distorts marine vision and accuracy in a radius."
	ability_name = "whisper"
	plasma_cost = 250
	cooldown_timer = 180 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_WHISPER

/datum/action/xeno_action/activable/whisper/on_cooldown_finish()
	to_chat(owner, "<span class='warning'>Our mind floods with the whispers of our slain sisters. We are ready to whisper again.</span>")
	return ..()

/datum/action/xeno_action/activable/whisper/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!length(GLOB.humans_by_zlevel["[owner.z]"]))
		return FALSE

/datum/action/xeno_action/activable/whisper/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	succeed_activate()
	add_cooldown()

	X.whispering = TRUE
	X.update_icon()
	playsound(X.loc, 'sound/voice/king_xeno_whispers.ogg', 125, 0)
	X.visible_message("<span class='xenohighdanger'>\The [X] opens its jaw and silently screeches!</span>")

	for(var/mob/living/carbon/human/victim as() in GLOB.humans_by_zlevel["[X.z]"])
		if(get_dist(victim, X) > WORLD_VIEW_NUM)
			continue
		if(!victim.hud_used)
			continue
		//Single out and apply filters on thier plane masters for the spooky blurry vision effect
		var/obj/screen/plane_master/floor/OT = victim.hud_used.plane_masters["[FLOOR_PLANE]"]
		var/obj/screen/plane_master/game_world/GW = victim.hud_used.plane_masters["[GAME_PLANE]"]
		addtimer(CALLBACK(OT, /atom.proc/remove_filter, "whisper"), KING_WHISPER_DURATION)
		if(victim.client?.prefs.safe_visuals) //Some players feel sick with the effect so allow them to get gaussian blur instead
			OT.add_filter("whisper", 2, GAUSSIAN_BLUR(1.2))
			GW.add_filter("whisper", 2, GAUSSIAN_BLUR(1.2))
		else
			GW.add_filter("whisper", 2, list("type" = "radial_blur", "size" = 0.07))
			animate(GW.get_filter("whisper"), size = 0.12, time = 5, loop = -1)
			OT.add_filter("whisper", 2, list("type" = "radial_blur", "size" = 0.07))
			animate(OT.get_filter("whisper"), size = 0.12, time = 5, loop = -1)
		addtimer(CALLBACK(GW, /atom.proc/remove_filter, "whisper"), KING_WHISPER_DURATION)
		victim.set_stagger(KING_WHISPER_DURATION / 4 SECONDS)
		to_chat(victim, "<span class='xenohighdanger'>Your vision contracts as a thousand dead xenomorphs assail your mind.</span>")
	addtimer(VARSET_CALLBACK(X, whispering, FALSE), KING_WHISPER_DURATION)
	addtimer(CALLBACK(X, /atom.proc/update_icon), KING_WHISPER_DURATION)


/datum/action/xeno_action/activable/whisper/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/whisper/ai_should_use(target)
	if(!ishuman(target))
		return ..()
	if(get_dist(target, owner) > 5)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

/datum/action/xeno_action/activable/area_crush
	name = "Gravity Crush"
	action_icon_state = "fortify"
	mechanics_text = "Increases the localized gravity in an area and crushes things."
	ability_name = "Gravity crush"
	plasma_cost = 100
	cooldown_timer = 30 SECONDS
	keybind_signal = COMSIG_XENOABILITY_GRAVITY_CRUSH
	var/king_crush_dist = 5

/datum/action/xeno_action/activable/area_crush/on_cooldown_finish()
	to_chat(owner, "<span class='warning'>Our psychic aura restores itself. We are ready to area crush again.</span>")
	return ..()

/datum/action/xeno_action/activable/area_crush/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return
	if(!owner.line_of_sight(A, king_crush_dist))
		if(!silent)
			to_chat(owner, "<span class='warning'>We must get closer to crush, our mind cannot reach this far.</span>")
		return FALSE

/datum/action/xeno_action/activable/area_crush/use_ability(atom/A)
	var/list/turfs = RANGE_TURFS(2, A)
	for(var/turf/targetted as() in turfs)
		targetted.add_filter("crushblur",1,list("type"="radial_blur", "size" = 0.3))
	if(!do_after(owner, 1 SECONDS, FALSE, owner, BUSY_ICON_DANGER))
		for(var/turf/targetted as() in turfs)
			targetted.remove_filter("crushblur")
		return fail_activate()
	succeed_activate()
	add_cooldown()
	A.visible_message("<span class='warning'> [A] collapses inward as it's gravity suddenly increases!</span>")
	playsound(A, 'sound/effects/bomb_fall.ogg', 75, FALSE)
	for(var/turf/targetted as() in turfs)
		for(var/atom/movable/item as() in targetted.contents)
			if(ismob(item))
				continue
			item.ex_act(EXPLODE_HEAVY)	//crushing without damaging the nearby area
		addtimer(CALLBACK(targetted, /atom.proc/remove_filter, "crushblur"), 1 SECONDS)

/datum/action/xeno_action/activable/area_crush/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/area_crush/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

/datum/action/xeno_action/psychic_summon
	name = "Psychic Summon"
	action_icon_state = "stomp"
	mechanics_text = "Summons all xenos in a hive to the caller's location, uses all plasma to activate."
	ability_name = "Psychic summon"
	plasma_cost = 1100 //uses all an elder kings plasma
	cooldown_timer = 10 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_HIVE_SUMMON

/datum/action/xeno_action/activable/psychic_summon/on_cooldown_finish()
	to_chat(owner, "<span class='warning'>The hives power swells. We may summon our sisters again.</span>")
	return ..()

/datum/action/xeno_action/psychic_summon/can_use_action(silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(length(X.hive.get_all_xenos()) <= 1)
		if(!silent)
			to_chat(owner, "<span class='notice'>We have no hive to call. We are alone on our throne of nothing.</span>")
		return FALSE

/datum/action/xeno_action/psychic_summon/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	log_game("[key_name(owner)] has begun summoning hive in [AREACOORD(owner)]")
	xeno_message("King: \The [owner] has begun a psychic summon in <b>[get_area(owner)]</b>!", 3, X.hivenumber)
	var/list/allxenos = X.hive.get_all_xenos()
	for(var/mob/living/carbon/xenomorph/sister as() in allxenos)
		sister.add_filter("summonoutline", 2, list("type" = "outline", "size" = 1, "color" = COLOR_VIOLET))

	if(!do_after(X, 15 SECONDS, FALSE, X, BUSY_ICON_HOSTILE))
		for(var/mob/living/carbon/xenomorph/sister as() in allxenos)
			sister.remove_filter("summonoutline")
		return fail_activate()

	for(var/mob/living/carbon/xenomorph/sister as() in allxenos)
		sister.remove_filter("summonoutline")
		sister.forceMove(get_turf(X))
	log_game("[key_name(owner)] has summoned hive ([length(allxenos)] Xenos) in [AREACOORD(owner)]")
	X.emote("roar")

	add_cooldown()
	succeed_activate()
