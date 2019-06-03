// This outfit preserves varedits made on the items
// Created from admin helpers.
/datum/outfit/varedit
	var/list/vv_values
	var/list/stored_access


/datum/outfit/varedit/pre_equip(mob/living/carbon/human/H, visualsOnly)
	H.delete_equipment() //Applying VV to wrong objects is not reccomended.
	. = ..()


/datum/outfit/varedit/proc/set_equipement_by_slot(slot,item_path)
	switch(slot)
		if(SLOT_W_UNIFORM)
			w_uniform = item_path
		if(SLOT_BACK)
			back = item_path
		if(SLOT_WEAR_SUIT)
			wear_suit = item_path
		if(SLOT_BELT)
			belt = item_path
		if(SLOT_GLOVES)
			gloves = item_path
		if(SLOT_SHOES)
			shoes = item_path
		if(SLOT_HEAD)
			head = item_path
		if(SLOT_WEAR_MASK)
			mask = item_path
		if(SLOT_EARS)
			ears = item_path
		if(SLOT_GLASSES)
			glasses = item_path
		if(SLOT_WEAR_ID)
			id = item_path
		if(SLOT_S_STORE)
			suit_store = item_path
		if(SLOT_L_STORE)
			l_store = item_path
		if(SLOT_R_STORE)
			r_store = item_path


/proc/collect_vv(obj/item/I)
	//Temporary/Internal stuff, do not copy these.
	var/static/list/ignored_vars = list("vars","x","y","z","plane","layer","override","animate_movement","pixel_step_size","screen_loc","tip_timer")

	if(istype(I) && I.datum_flags & DF_VAR_EDITED)
		var/list/vedits = list()
		for(var/varname in I.vars)
			if(!I.can_vv_get(varname))
				continue
			if(varname in ignored_vars)
				continue
			var/vval = I.vars[varname]
			//Does it even work ?
			if(vval == initial(I.vars[varname]))
				continue
			//Only text/numbers and icons variables to make it less weirdness prone.
			if(!istext(vval) && !isnum(vval) && !isicon(vval))
				continue
			vedits[varname] = I.vars[varname]
		return vedits


/mob/living/carbon/human/proc/copy_outfit()
	var/datum/outfit/varedit/O = new

	//Copy equipment
	var/list/result = list()
	var/list/slots_to_check = list(SLOT_W_UNIFORM,SLOT_BACK,SLOT_WEAR_SUIT,SLOT_BELT,SLOT_GLOVES,SLOT_SHOES,SLOT_HEAD,SLOT_WEAR_MASK,SLOT_EARS,SLOT_GLASSES,SLOT_WEAR_ID,SLOT_S_STORE,SLOT_L_STORE,SLOT_R_STORE)
	for(var/s in slots_to_check)
		var/obj/item/I = get_item_by_slot(s)
		var/vedits = collect_vv(I)
		if(vedits)
			result["[s]"] = vedits
		if(istype(I))
			O.set_equipement_by_slot(s,I.type)

	//Copy access
	O.stored_access = list()
	var/obj/item/id_slot = get_item_by_slot(SLOT_WEAR_ID)
	if(id_slot)
		O.stored_access = id_slot.GetAccess()
	//Copy hands
	var/obj/item/left_hand = l_hand
	var/obj/item/right_hand = r_hand
	if(istype(left_hand))
		O.l_hand = left_hand.type
		var/vedits = collect_vv(left_hand)
		if(vedits)
			result["LHAND"] = vedits
	if(istype(right_hand))
		O.r_hand = right_hand.type
		var/vedits = collect_vv(left_hand)
		if(vedits)
			result["RHAND"] = vedits
	O.vv_values = result
	//Copy to outfit cache
	var/outfit_name = stripped_input(usr, "Enter the outfit name")
	O.name = outfit_name
	GLOB.custom_outfits += O


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
	var/obj/item/id_slot = H.get_item_by_slot(SLOT_WEAR_ID)
	if(id_slot)
		var/obj/item/card/id/card = id_slot.GetID()
		var/datum/job/J = SSjob.GetJob(H.job)
		if(istype(card))
			card.access = stored_access
			card.registered_name = H.real_name
			card.assignment = H.job
			card.rank = H.job
			if(J)
				card.paygrade = J.paygrade
			card.update_label()
			H.sec_hud_set_ID()

	H.name = H.get_visible_name()
	H.hud_set_squad()