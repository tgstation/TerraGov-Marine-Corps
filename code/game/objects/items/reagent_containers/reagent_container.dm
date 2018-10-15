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
	var/list/list_reagents = null

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
		verbs -= /obj/item/reagent_container/verb/set_APTFT //which objects actually uses it?
	create_reagents(volume)

	add_initial_reagents()

/obj/item/reagent_container/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

//returns a text listing the reagents (and their volume) in the atom. Used by Attack logs for reagents in pills
/obj/item/reagent_container/proc/get_reagent_list_text()
	if(reagents.reagent_list && reagents.reagent_list.len)
		var/datum/reagent/R = reagents.reagent_list[1]
		. = "[R.id]([R.volume]u)"
		if(reagents.reagent_list.len < 2) return
		for (var/i = 2, i <= reagents.reagent_list.len, i++)
			R = reagents.reagent_list[i]
			if(!R) continue
			. += "; [R.id]([R.volume]u)"
	else
		. = "No reagents"