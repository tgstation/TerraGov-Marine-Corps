/obj/item/reagent_containers
	name = "Container"
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 5
	var/init_reagent_flags
	var/amount_per_transfer_from_this = 5
	///Used to adjust how many units are transfered/injected in a single click
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/liquifier = FALSE //Can liquify/grind pills without needing fluid to dissolve.
	var/list/list_reagents
	///Whether we can restock this in a vendor without it having its starting reagents
	var/free_refills = TRUE


/obj/item/reagent_containers/Initialize(mapload)
	. = ..()
	create_reagents(volume, init_reagent_flags, list_reagents)
	if(!possible_transfer_amounts)
		verbs -= /obj/item/reagent_containers/verb/set_APTFT

/obj/item/reagent_containers/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!possible_transfer_amounts)
		return
	var/result = tgui_input_list(user, "Amount per transfer from this:","[src]", possible_transfer_amounts)
	if(result)
		amount_per_transfer_from_this = result

/obj/item/reagent_containers/interact(mob/user)
	. = ..()
	if(.)
		return

	open_ui(user)

///Opens the relevant UI
/obj/item/reagent_containers/proc/open_ui(mob/user)
	if(!length(possible_transfer_amounts))
		return

	var/N = tgui_input_list(user, "Amount per transfer from this:", "[src]", possible_transfer_amounts)
	if(!N)
		return

	amount_per_transfer_from_this = N

/obj/item/reagent_containers/verb/set_APTFT()
	set name = "Set transfer amount"
	set category = "Object"
	set src in view(1)

	var/N = tgui_input_list(usr, "Amount per transfer from this:", "[src]", possible_transfer_amounts)
	if(!N)
		return

	amount_per_transfer_from_this = N


//returns a text listing the reagents (and their volume) in the atom. Used by Attack logs for reagents in pills
/obj/item/reagent_containers/proc/get_reagent_list_text()
	if(reagents.reagent_list && length(reagents.reagent_list))
		var/datum/reagent/R = reagents.reagent_list[1]
		. = "[R.name]([R.volume]u)"
		if(length(reagents.reagent_list) < 2) return
		for (var/i = 2, i <= length(reagents.reagent_list), i++)
			R = reagents.reagent_list[i]
			if(!R) continue
			. += "; [R.name]([R.volume]u)"
	else
		. = "No reagents"

///True if this object currently contains at least its starting reagents, false otherwise. Extra reagents are ignored.
/obj/item/reagent_containers/proc/has_initial_reagents()
	for(var/reagent_to_check in list_reagents)
		if(reagents.get_reagent_amount(reagent_to_check) != list_reagents[reagent_to_check])
			return FALSE
	return TRUE
