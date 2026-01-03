/mob/living/carbon/xenomorph/dragon
	caste_base_type = /datum/xeno_caste/dragon
	name = "Dragon"
	desc = "A massive, ancient beast with scales that shimmer like polished armor. The fiercest and most formidable creature."
	icon = 'icons/Xeno/castes/dragon.dmi'
	icon_state = "Dragon Walking"
	attacktext = "bites"
	friendly = "nuzzles"
	health = 850
	maxHealth = 850
	plasma_stored = 0
	pixel_x = -48
	footstep_type = FOOTSTEP_XENO_HEAVY
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)
	attack_effect = list("dragonslash","dragonslash2")

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/dragon/throw_at(atom/target, range, speed = 5, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	return FALSE

/mob/living/carbon/xenomorph/dragon/handle_special_state()
	if(!(status_flags & INCORPOREAL))
		return FALSE
	var/datum/action/ability/activable/xeno/fly/fly_ability = actions_by_path[/datum/action/ability/activable/xeno/fly]
	if(!fly_ability || fly_ability.performing_landing_animation || COOLDOWN_TIMELEFT(fly_ability, animation_cooldown))
		return FALSE
	icon_state = "dragon_marker"
	return TRUE

/// If they have plasma, reduces their damage accordingly by up to 50%. Ratio is 4 plasma per 1 damage.
/mob/living/carbon/xenomorph/dragon/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, mob/living/attacker, bypass_flight = FALSE)
	if(((status_flags & INCORPOREAL) && !bypass_flight)|| damage <= 0)
		return FALSE
	if(damagetype != BRUTE && damagetype != BURN)
		return FALSE
	if(stat != DEAD && plasma_stored)
		var/damage_reduction = min(damage / 2, plasma_stored / 5)
		use_plasma(ROUND_UP(damage_reduction * 5))
		damage -= damage_reduction
	return ..()

/mob/living/carbon/xenomorph/dragon/on_crit()
	. = ..()
	if((status_flags & INCORPOREAL))
		var/datum/action/ability/activable/xeno/fly/fly_ability = actions_by_path[/datum/action/ability/activable/xeno/fly]
		if(!fly_ability.performing_landing_animation)
			fly_ability.start_landing()

/mob/living/carbon/xenomorph/dragon/death(gibbing, deathmessage, silent)
	if((status_flags & INCORPOREAL))
		var/datum/action/ability/activable/xeno/fly/fly_ability = actions_by_path[/datum/action/ability/activable/xeno/fly]
		if(!fly_ability.performing_landing_animation)
			fly_ability.start_landing()
	. = ..()

/mob/living/carbon/xenomorph/dragon/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!(status_flags & INCORPOREAL))
		return FALSE
	for(var/obj/machinery/deployable/mounted/sentry/ads_system/ads in range(GLOB.ads_intercept_range,loc))
		if(!COOLDOWN_FINISHED(ads, intercept_cooldown))
			continue
		var/datum/hive_status/hive = GLOB.hive_datums[ads.get_xeno_hivenumber()]
		if(istype(hive) && (faction in hive.allied_factions))
			continue
		if(ads.try_intercept(loc, src, 0.5, 5))
			to_chat(src, span_xenodanger("We are shot by the talls' defenses!"))
			apply_damage(rand(75,125), BRUTE, BODY_ZONE_CHEST, BULLET, updating_health = TRUE, penetration = 25, attacker = src, bypass_flight = TRUE)
			continue //so others shoot too.
