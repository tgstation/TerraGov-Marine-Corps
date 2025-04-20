// This outfit preserves varedits made on the items
// Created from admin helpers.
/datum/outfit/varedit
	var/list/vv_values
	var/list/stored_access


/datum/outfit/varedit/pre_equip(mob/living/carbon/human/H, visualsOnly)
	H.delete_equipment() //Applying VV to wrong objects is not reccomended.
	return ..()

/datum/outfit/varedit/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	//Apply VV
	for(var/slot in vv_values)
		var/list/edits = vv_values[slot]
		var/obj/item/I
		switch(slot)
			if("LHAND")
				I = H.l_hand
			if("RHAND")
				I = H.r_hand
			else
				I = H.get_item_by_slot(text2num(slot))
		for(var/vname in edits)
			I.vv_edit_var(vname,edits[vname])
	//Apply access
	var/obj/item/id_slot = H.get_item_by_slot(ITEM_SLOT_ID)
	if(id_slot)
		var/obj/item/card/id/card = id_slot
		var/datum/job/J = H.job
		if(istype(card))
			card.access = stored_access
			card.registered_name = H.real_name
			card.assignment = H.job
			card.rank = H.job.title
			if(J)
				card.paygrade = J.paygrade
			card.update_label()

	H.name = H.get_visible_name()
	H.hud_set_job(H.faction)


/datum/outfit/varedit/get_json_data()
	. = .. ()
	.["stored_access"] = stored_access
	var/list/stripped_vv = list()
	for(var/slot in vv_values)
		var/list/vedits = vv_values[slot]
		var/list/stripped_edits = list()
		for(var/edit in vedits)
			if(istext(vedits[edit]) || isnum(vedits[edit]) || isnull(vedits[edit]))
				stripped_edits[edit] = vedits[edit]
		if(length(stripped_edits))
			stripped_vv[slot] = stripped_edits
	.["vv_values"] = stripped_vv


/datum/outfit/varedit/load_from(list/outfit_data)
	. = ..()
	stored_access = outfit_data["stored_access"]
	vv_values = outfit_data["vv_values"]
