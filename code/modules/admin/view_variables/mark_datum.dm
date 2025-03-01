/**
 * # `mark_datum(datum/D)`
 * This proc marks a datum for the holder of this client, by setting the holder's marked_datum var.
 * If the holder already had a marked datum, unmarks said datum beforehand.
 * The client obviously must have a holder for this to work.
 * * Arg: The datum to mark.
 * * Has no return value.
*/
/client/proc/mark_datum(datum/D)
	if(!holder)
		return
	if(holder.marked_datum)
		holder.UnregisterSignal(holder.marked_datum, COMSIG_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	holder.RegisterSignal(holder.marked_datum, COMSIG_QDELETING, TYPE_PROC_REF(/datum/admins, handle_marked_del))
	vv_update_display(D, "marked", VV_MSG_MARKED)

ADMIN_VERB_ONLY_CONTEXT_MENU(mark_datum, R_DEBUG, "Mark Object", datum/target as mob|obj|turf|area in view())
	user.mark_datum(target)

/datum/admins/proc/handle_marked_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(marked_datum, COMSIG_QDELETING)
	marked_datum = null
