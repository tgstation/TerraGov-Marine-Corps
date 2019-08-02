/*
	This state checks that the user is an admin, end of story
*/
GLOBAL_DATUM_INIT(admin_state, /datum/topic_state/admin_state, new)

/datum/topic_state/admin_state/can_use_topic(src_object, mob/user)
	return check_other_rights(user.client, R_ADMIN, FALSE) ? STATUS_INTERACTIVE : STATUS_CLOSE
