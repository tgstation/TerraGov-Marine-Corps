/mob/living/carbon/human/attack_paw(mob/living/carbon/human/user)
	. = ..()
	if (user.a_intent == INTENT_HELP)
		help_shake_act(user)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return

		user.do_attack_animation(src, ATTACK_EFFECT_BITE)
		visible_message(span_danger("[user] has bit [src]!"), null, null, 5)
		var/damage = rand(1, 3)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/datum/limb/affecting = get_limb(ran_zone(dam_zone))
		apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"), updating_health = TRUE)
