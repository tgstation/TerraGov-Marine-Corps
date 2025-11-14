/datum/action/ability/activable/xeno/feed
	name = "Feed"
	action_icon_state = "lunge"
	desc = "Assault an organic, restoring health through the use of the their biomass."
	ability_cost = 0
	cooldown_duration = 35 SECONDS
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/feed/use_ability(mob/living/carbon/human/target_human)
	xeno_owner.face_atom(target_human)
	xeno_owner.do_attack_animation(target_human, ATTACK_EFFECT_REDSLASH)
	xeno_owner.visible_message(target_human, span_danger("[xeno_owner] tears into [target_human]!"))
	playsound(target_human, SFX_ALIEN_CLAW_FLESH, 25, TRUE)
	target_human.emote("scream")
	target_human.apply_damage(damage = 25, damagetype = BRUTE, def_zone = BODY_ZONE_CHEST, blocked = 0, sharp = TRUE, edge = FALSE, updating_health = TRUE, attacker = owner)
	var/amount = 15 //heal xeno damage needs a variable not a number
	HEAL_XENO_DAMAGE(xeno_owner, amount, FALSE)
	add_cooldown()

/datum/action/ability/activable/xeno/feed/can_use_ability(mob/living/target, silent = FALSE, override_flags)
	. = ..()
	if(!ishuman(target))
		return FALSE
	if(!owner.Adjacent(target))
		return FALSE
