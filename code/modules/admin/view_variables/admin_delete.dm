/client/proc/admin_delete(datum/delete)
	var/atom/atom_delete = delete
	var/coords = ""
	var/jmp_coords = ""
	if(istype(atom_delete))
		var/turf/turf_delete = get_turf(atom_delete)
		if(turf_delete)
			coords = "at [COORD(turf_delete)]"
			jmp_coords = "at [ADMIN_COORDJMP(turf_delete)]"
		else
			jmp_coords = coords = "in nullspace"

	if (tgui_alert(usr, "Are you sure you want to delete:\n[delete]\n[coords]?", "Confirmation", list("Yes", "No")) == "Yes")
		log_admin("[key_name(usr)] deleted [delete] [coords]")
		message_admins("[key_name_admin(usr)] deleted [delete] [jmp_coords]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(isturf(delete))
			var/turf/turf_delete = delete
			turf_delete.ScrapeAway()
		else
			vv_update_display(delete, "deleted", VV_MSG_DELETED)
			qdel(delete)
			if(!QDELETED(delete))
				vv_update_display(delete, "deleted", "")
