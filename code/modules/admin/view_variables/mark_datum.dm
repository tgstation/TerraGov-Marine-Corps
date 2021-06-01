/client/proc/mark_datum(datum/D)
	if(!holder)
		return
	if(holder.marked_datum)
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	vv_update_display(D, "marked", VV_MSG_MARKED)
