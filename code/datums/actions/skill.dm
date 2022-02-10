/datum/action/skill
	var/skill_name
	var/skill_min

/datum/action/skill/should_show()
	return can_use_action()

/datum/action/skill/can_use_action()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/skill/fail_activate()
	if(owner)
		owner << span_warning("You are not competent enough to do that.") // This message shouldn't show since incompetent people shouldn't have the button, but JIC.
