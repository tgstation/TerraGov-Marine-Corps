/// Rips off all the limbs of the target
/datum/smite/nugget
	name = "Nugget"

/datum/smite/nugget/effect(client/user, mob/living/carbon/human/target)
	. = ..()

	if (!ishuman(target))
		to_chat(user, span_warning("This must be used on a human mob."), confidential = TRUE)
		return

	var/timer = 2 SECONDS
	for(var/datum/limb/limb_to_destroy AS in target.limbs)
		if (limb_to_destroy.body_part == HEAD || limb_to_destroy.body_part == GROIN)
			continue
		addtimer(CALLBACK(limb_to_destroy, TYPE_PROC_REF(/datum/limb, droplimb)), timer)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), target, 'sound/effects/pop.ogg', 70), timer)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, spin), 4, 1), timer - 0.4 SECONDS)
		timer += 2 SECONDS
