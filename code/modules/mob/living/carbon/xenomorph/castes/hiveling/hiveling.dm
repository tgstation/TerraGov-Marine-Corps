/mob/living/carbon/xenomorph/hiveling
	caste_base_type = /mob/living/carbon/xenomorph/hiveling
	name = "Hiveling"
	desc = "A live representation of the will of weeds and resin."
	icon = 'icons/Xeno/castes/hiveling.dmi'
	icon_state = "Hiveling_"
	health = 150
	maxHealth = 150
	plasma_stored = 5
	pixel_x = -16
	old_x = -16
	gib_chance = 100 //catch incase crit is skipped
	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	pull_speed = -2
	pass_flags = PASS_LOW_STRUCTURE|PASS_MOB|PASS_XENO
	a_intent = INTENT_HELP
	hud_type = /datum/hud/hivemind //gets hivemind hud
	hud_possible = list(PLASMA_HUD, HEALTH_HUD_XENO, PHEROMONE_HUD, XENO_RANK_HUD, QUEEN_OVERWATCH_HUD, XENO_BLESSING_HUD, XENO_EVASION_HUD)

/mob/living/carbon/xenomorph/hiveling/updatehealth()
	if(on_fire)
		gib() //fire instant kills
	if(health <= 0)
		gib() //no crit mode, just blowing up
	health = maxHealth - getFireLoss() - getBruteLoss()
	med_hud_set_health()
	update_wounds()

/mob/living/carbon/xenomorph/hiveling/handle_living_health_updates()
	var/turf/T = loc
	if(!istype(T))
		return
	// If off weeds, lets deal some damage.
	if(!loc_weeds_type)
		if(client) // AI dont gotta deal with offweed megadeath since they can only go 1 tile off
			adjustBruteLoss(40 * XENO_RESTING_HEAL, TRUE) // gets 3 ticks max then gibs
			to_chat(src, span_highdanger("We have no weeds nearby, we need to get on weeds now or we will die!"))
			updatehealth()
			return
	if(health >= maxHealth) //can't regenerate.
		updatehealth() //Update health-related stats, like health itself (using brute and fireloss), health HUD and status.
		return
	heal_wounds(XENO_RESTING_HEAL)
	updatehealth()

/mob/living/carbon/xenomorph/hiveling/set_jump_component(duration = 0.5 SECONDS, cooldown = 2 SECONDS, cost = 0, height = 16, sound = null, flags = JUMP_SHADOW, flags_pass = PASS_LOW_STRUCTURE|PASS_FIRE)
	return //no jumping

/// handles hiveling updating with their respective weedtype
/mob/living/carbon/xenomorph/hiveling/update_icon_state()
	icon_state = "Hiveling_[initial(loc_weeds_type.color_variant)]"

/mob/living/carbon/xenomorph/hiveling/update_icons()
	return

/mob/living/carbon/xenomorph/hiveling/a_intent_change()
	return //Unable to change intent, forced help intent

/mob/living/carbon/xenomorph/hiveling/set_resting()
	return

/// Hivelings specifically have no status hud element
/mob/living/carbon/xenomorph/hiveling/med_hud_set_status()
	return

//special gib anim length
/mob/living/carbon/xenomorph/hiveling/gib_animation()
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, 16, src, xeno_caste.gib_flick, icon)

/mob/living/carbon/xenomorph/hiveling/proc/check_weeds(turf/T, strict_turf_check = FALSE)
	SHOULD_BE_PURE(TRUE)
	if(isnull(T))
		return FALSE
	. = TRUE
	if(locate(/obj/flamer_fire) in T)
		return FALSE
	for(var/obj/alien/weeds/W in range(strict_turf_check ? 0 : 1, T ? T : get_turf(src)))
		if(QDESTROYING(W))
			continue
		return
	return FALSE

/mob/living/carbon/xenomorph/hiveling/Move(NewLoc, Dir = 0)
	if(!client) // AI cant move more than 1 tile off weeds, so if they run out of plasma they dont look weird
		if(!check_weeds(NewLoc))
			return FALSE
	return ..()
