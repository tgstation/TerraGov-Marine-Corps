/**
 * tgui state: voting_state
 *
 * Checks that the user is not banned from voting
 */

GLOBAL_DATUM_INIT(voting_state, /datum/ui_state/voting_state, new)

/datum/ui_state/voting_state/can_use_topic(src_object, mob/user)
	if(is_banned_from(user.ckey, "Voting"))
		return UI_CLOSE
	return UI_INTERACTIVE
