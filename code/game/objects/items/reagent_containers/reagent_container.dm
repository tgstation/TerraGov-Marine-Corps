/obj/item/reagent_containers
	name = "Container"
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	throwforce = 3
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 5
	var/init_reagent_flags
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/liquifier = FALSE //Can liquify/grind pills without needing fluid to dissolve.
	var/list/list_reagents
	///Whether we can restock this in a vendor without it having its starting reagents
	var/free_refills = TRUE


/obj/item/reagent_containers/Initialize()
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
	if(reagents.reagent_list && reagents.reagent_list.len)
		var/datum/reagent/R = reagents.reagent_list[1]
		. = "[R.name]([R.volume]u)"
		if(reagents.reagent_list.len < 2) return
		for (var/i = 2, i <= reagents.reagent_list.len, i++)
			R = reagents.reagent_list[i]
			if(!R) continue
			. += "; [R.name]([R.volume]u)"
	else
		. = "No reagents"

/obj/item/reagent_containers/proc/has_initial_reagents()
	for(var/reagent_to_check in list_reagents)
		if(reagents.get_reagent_amount(reagent_to_check) != list_reagents[reagent_to_check])
			return FALSE
	return TRUE
