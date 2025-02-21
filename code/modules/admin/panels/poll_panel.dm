/client/proc/poll_panel()
	set name = "Server Poll Management"
	set category = "Admin"
	if(!check_rights(R_POLLS))
		return
	holder.poll_list_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Server Poll Management") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
