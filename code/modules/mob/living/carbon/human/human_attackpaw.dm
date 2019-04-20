/mob/living/carbon/human/attack_paw(mob/living/M)
	..()
	if (M.a_intent == INTENT_HELP)
		help_shake_act(M)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return

		M.animation_attack_on(src)
		M.flick_attack_overlay(src, "punch")
		visible_message("<span class='danger'>[M] has bit [src]!</span>", null, null, 5)
		var/damage = rand(1, 3)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/datum/limb/affecting = get_limb(ran_zone(dam_zone))
		apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"))
	return
