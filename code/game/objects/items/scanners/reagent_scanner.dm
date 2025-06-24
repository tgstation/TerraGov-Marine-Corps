/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	worn_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20

	var/details = FALSE

/obj/item/reagent_scanner/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return
	if (user.stat)
		return
	if(!istype(O))
		return
	if(!O.reagents || !length(O.reagents.reagent_list))
		to_chat(user, span_notice("No chemical agents found in [O]"))
		return
	var/dat = ""
	var/one_percent = O.reagents.total_volume / 100
	for (var/datum/reagent/R in O.reagents.reagent_list)
		dat += "\n \t [span_notice(" [R.name][details ? ": [R.volume / one_percent]%" : ""]")]"
	to_chat(user, span_notice("Chemicals found: [dat]"))

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
