/datum/action/skill
	var/skill_type
	var/skill_min

/datum/action/skill/should_show()
	return can_use_action()

/datum/action/skill/can_use_action()
	var/mob/living/carbon/human/human = owner
	return istype(human) && HAS_SKILL_LEVEL(human, skill_type, skill_min)

/datum/action/skill/fail_activate()
	if(owner)
		to_chat(owner, "<span class='warning'>You are not competent enough to do that.</span>") // This message shouldn't show since incompetent people shouldn't have the button, but JIC.
