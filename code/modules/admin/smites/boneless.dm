/// Breaks the targets bones
/datum/smite/boneless
	name = "Boneless"

/datum/smite/boneless/effect(client/user, mob/living/carbon/human/target)
	. = ..()

	if (!ishuman(target))
		to_chat(user, span_warning("This must be used on a human."), confidential = TRUE)
		return
	
	var/timer = 2 SECONDS
	to_chat(target,span_userdanger("Your bones break in a spray of blood, sending bone fragments everywhere!"))
	for(var/datum/limb/limb_to_break AS in target.limbs)
		if(limb_to_break.limb_status & (LIMB_BROKEN | LIMB_DESTROYED | LIMB_AMPUTATED))
			continue
		timer += 2 SECONDS
		addtimer(CALLBACK(limb_to_break, /datum/limb.proc/fracture), timer)
