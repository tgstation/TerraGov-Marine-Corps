/datum/action/xeno_action/activable/feed
	name = "Feed"
	action_icon_state = "lunge"
	desc = "Assault an organic, restoring health through the use of the their biomass."
	ability_name = "feed"
	plasma_cost = 0
	cooldown_timer = 35 SECONDS
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/feed/use_ability(mob/living/carbon/human/target_human)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.face_atom(target_human)
	owner_xeno.do_attack_animation(target_human, ATTACK_EFFECT_REDSLASH)
	owner_xeno.visible_message(target_human, span_danger("[owner_xeno] tears into [target_human]!"))
	playsound(target_human, "alien_claw_flesh", 25, TRUE)
	target_human.emote("scream")
	target_human.apply_damage(damage = 25, damagetype = BRUTE, def_zone = BODY_ZONE_CHEST, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE)
	var/amount = 15 //heal xeno damage needs a variable not a number
	HEAL_XENO_DAMAGE(owner_xeno, amount, FALSE)
	add_cooldown()

/datum/action/xeno_action/activable/flay/can_use_ability(mob/living/target, silent = FALSE, override_flags)
	. = ..()
	if(!ishuman(target))
		return FALSE
	if(!owner.Adjacent(target))
		return FALSE
