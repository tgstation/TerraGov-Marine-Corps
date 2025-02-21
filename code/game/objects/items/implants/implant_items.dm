///Deployitem implant, holds a item that can then be placed inhand to do whatever with
/obj/item/implant/deployitem
	name = "item implants"
	desc = "you shouldnt be seeing this"
	allowed_limbs = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	///Held item we want to be put in hand when the implant is activated
	var/obj/item/helditem = /obj/item/healthanalyzer

/obj/item/implant/deployitem/Initialize(mapload)
	. = ..()
	helditem = new helditem(src)

/obj/item/implant/deployitem/activate()
	. = ..()
	if(!.)
		return
	if(malfunction == MALFUNCTION_PERMANENT)
		return FALSE
	if(helditem.loc != src)
		fetch_item()
		return
	put_in_slots()
	RegisterSignal(helditem, COMSIG_ITEM_DROPPED, PROC_REF(fetch_item))

///Takes the held item and puts it into it's predestined slot
/obj/item/implant/deployitem/proc/put_in_slots()
	switch(part.name)
		if(BODY_ZONE_R_ARM)
			implant_owner.put_in_r_hand(helditem)
		if(BODY_ZONE_L_ARM)
			implant_owner.put_in_l_hand(helditem)

///grabs the held item when it changes equip or is dropped
/obj/item/implant/deployitem/proc/fetch_item()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(helditem, COMSIG_ITEM_DROPPED)
	implant_owner.temporarilyRemoveItemFromInventory(helditem)
	helditem.forceMove(src)


/obj/item/implant/deployitem/blade
	name = "mantis blade implant"
	desc = "A large folding blade capable of being stored within an arm."
	icon = 'icons/obj/items/weapons/swords.dmi'
	icon_state = "armblade"
	helditem = /obj/item/weapon/sword/mantisblade

/obj/item/implant/deployitem/blade/get_data()
	return {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> Nanotrasen MA-12 Mantis Implant<BR>
	<HR>
	<b>Implant Details:</b><BR>
	<b>Function:</b> Upon activation, the user deploys a large blade from the their arm.<BR>"}

/obj/item/implant/deployitem/blade/put_in_slots()
	. = ..()
	playsound(implant_owner.loc, 'sound/weapons/wristblades_on.ogg', 15, TRUE)

/obj/item/implant/deployitem/blade/fetch_item()
	. = ..()
	playsound(implant_owner.loc, 'sound/weapons/wristblades_off.ogg', 15, TRUE)

/obj/item/weapon/sword/mantisblade
	name = "mantis arm blade"
	desc = "A wicked-looking folding blade capable of being concealed within a human's arm."
	icon_state = "armblade"
	worn_icon_state = "armblade"
	force = 75
	attack_speed = 8
	equip_slot_flags = NONE
	w_class = WEIGHT_CLASS_BULKY //not needed but just in case why not
	hitsound = 'sound/weapons/slash.ogg'
