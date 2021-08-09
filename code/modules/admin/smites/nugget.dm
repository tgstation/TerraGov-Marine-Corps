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
		addtimer(CALLBACK(limb_to_destroy, /datum/limb/.proc/droplimb), timer)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, target, 'sound/effects/pop.ogg', 70), timer)
		addtimer(CALLBACK(target, /mob/living/.proc/spin, 4, 1), timer - 0.4 SECONDS)
		timer += 2 SECONDS
