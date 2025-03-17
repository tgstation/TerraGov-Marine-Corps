/client/proc/tag_datum(datum/target_datum)
	if(!holder || QDELETED(target_datum))
		return
	holder.add_tagged_datum(target_datum)

/client/proc/toggle_tag_datum(datum/target_datum)
	if(!holder || !target_datum)
		return

	if(LAZYFIND(holder.tagged_datums, target_datum))
		holder.remove_tagged_datum(target_datum)
	else
		holder.add_tagged_datum(target_datum)

ADMIN_VERB_AND_CONTEXT_MENU(tag_datum_mapview, R_VAREDIT, "Tag Datum", "Tag a datum", ADMIN_CATEGORY_DEBUG, datum/target_datum as mob|obj|turf|area in view())
	user.tag_datum(target_datum)
