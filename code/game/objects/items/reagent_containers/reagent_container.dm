/obj/item/reagent_container
	name = "Container"
	desc = ""
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = null
	throwforce = 3
	w_class = 2.0
	throw_speed = 1
	throw_range = 5
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30

/obj/item/reagent_container/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/reagent_container/New()
	..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/reagent_container/verb/set_APTFT //which objects actually uses it?
	create_reagents(volume)


//returns a text listing the reagents (and their volume) in the atom. Used by Attack logs for reagents in pills
/obj/item/reagent_container/proc/get_reagent_list_text()
	. = ""
	if(reagents.reagent_list && reagents.reagent_list.len)
		for (var/datum/reagent/R in reagents.reagent_list)
			. += "[R.id]([R.volume] units); "
	else
		. = "No reagents"