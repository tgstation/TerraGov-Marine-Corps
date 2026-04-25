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
/mob/living/carbon/xenomorph/dragon/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, mob/living/attacker)
	if((status_flags & GODMODE) || damage <= 0)
		return FALSE
	if(damagetype != BRUTE && damagetype != BURN)
		return FALSE
	if(stat != DEAD && plasma_stored)
		var/damage_reduction = min(damage / 2, plasma_stored / 5)
		use_plasma(ROUND_UP(damage_reduction * 5))
		damage -= damage_reduction
	return ..()
