/obj/item/mass_spectrometer
	desc = "A hand-held mass spectrometer which identifies trace chemicals in a blood sample."
	name = "mass-spectrometer"
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

/obj/item/mass_spectrometer/Initialize(mapload)
	. = ..()
	create_reagents(5, OPENCONTAINER)

/obj/item/mass_spectrometer/on_reagent_change()
	if(reagents.total_volume)
		icon_state = initial(icon_state) + "_s"
	else
		icon_state = initial(icon_state)

/obj/item/mass_spectrometer/attack_self(mob/user as mob)
	if (user.stat)
		return
	if(!reagents.total_volume)
		return
	var/list/blood_traces
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.type != /datum/reagent/blood)
			reagents.clear_reagents()
			to_chat(user, span_warning("The sample was contaminated! Please insert another sample"))
			return
		else
			blood_traces = params2list(R.data["trace_chem"])
			break
	var/dat = "Trace Chemicals Found: "
	for(var/R in blood_traces)
		dat += "\n\t[R][details ? " ([blood_traces[R]] units)" : "" ]"
	to_chat(user, "[dat]")
	reagents.clear_reagents()


/obj/item/mass_spectrometer/adv
	name = "advanced mass-spectrometer"
	icon_state = "adv_spectrometer"
	details = TRUE
