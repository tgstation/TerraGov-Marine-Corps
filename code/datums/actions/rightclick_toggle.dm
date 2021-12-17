/datum/action/toggle_rightclick
	name = "Toggle Right Clicking"
	action_icon_state = "rclick"

/datum/action/toggle_rightclick/action_activate()
	owner.client?.toggle_right_click()
	return TRUE
