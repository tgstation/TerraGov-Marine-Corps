/// Inflicts crippling brain damage on the target
/datum/smite/brain_damage
	name = "Brain damage"

/datum/smite/brain_damage/effect(client/user, mob/living/target)
	. = ..()

	if (!ishuman(target))
		to_chat(user, span_warning("This must be used on a human."), confidential = TRUE)
		return
		
	to_chat(target, span_userdanger("Your mind snaps under the strain of existence, you just can't take it anymore."), confidential = TRUE)
	target.adjustBrainLoss(BRAIN_DAMAGE_DEATH - 1, BRAIN_DAMAGE_DEATH - 1)
