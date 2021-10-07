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
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	vv_update_display(D, "marked", VV_MSG_MARKED)
