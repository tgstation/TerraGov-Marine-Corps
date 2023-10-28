//Reagent Canister pouch. Including the canister inside the pouch, as well as the pouch item.

/obj/item/reagent_containers/glass/reagent_canister // See the Reagent Canister Pouch, this is just the container
	name = "Reagent canister"
	desc = "A pressurized container. The inner part of a pressurized reagent canister pouch. Only compatible with its pouch, machinery or a storage tank."
	icon_state = "pressurized_reagent_container"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tanks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tanks_right.dmi',
	)
	item_state = "anesthetic"
	amount_per_transfer_from_this = 0
	possible_transfer_amounts = null
	volume = 1200 //The equivalent of 5 pill bottles worth of BKTT
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reagent_containers/glass/reagent_canister/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/reagent_canister/update_icon()
	color = COLOR_WHITE
	if(reagents)
		color = mix_color_from_reagents(reagents.reagent_list)
	..()

/obj/item/storage/pouch/pressurized_reagent_pouch //The actual pouch itself and all its function
	name = "Pressurized Reagent Pouch"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY
	allow_drawing_method = TRUE
	icon_state = "reagent_pouch"
	desc = "A pressurized reagent pouch. It is used to refill custom injectors, and can also store one.\
	You can Alt-Click to remove the canister in order to refill it."
	can_hold = list(/obj/item/reagent_containers/hypospray)
	flags_item = NOBLUDGEON
	///The internal container of the pouch. Holds the reagent that you use to refill the connected injector
	var/obj/item/reagent_containers/glass/reagent_canister/inner

/obj/item/storage/pouch/pressurized_reagent_pouch/Initialize(mapload)
	. = ..()
	inner = new /obj/item/reagent_containers/glass/reagent_canister
	new /obj/item/reagent_containers/hypospray/advanced(src)
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_pouch/update_icon()
	overlays.Cut()
	if(length(contents))
		overlays += "[icon_state]_full"
	if(inner)
		//tint the inner display based on what chemical is inside
		var/image/I = image(icon, icon_state="[icon_state]_loaded")
		if(inner.reagents)
			I.color = mix_color_from_reagents(inner.reagents.reagent_list)
		overlays += I

/obj/item/storage/pouch/pressurized_reagent_pouch/bktt/Initialize()
	. = ..()
	//we don't call fill_with because of the complex mix of chemicals we have
	var/amount_to_fill = inner.volume/4
	inner.reagents.add_reagent(/datum/reagent/medicine/bicaridine, amount_to_fill)
	inner.reagents.add_reagent(/datum/reagent/medicine/kelotane, amount_to_fill)
	inner.reagents.add_reagent(/datum/reagent/medicine/tramadol, amount_to_fill)
	inner.reagents.add_reagent(/datum/reagent/medicine/tricordrazine, amount_to_fill)
	if(contents.len > 0)
		var/obj/item/reagent_containers/hypospray/advanced/hypo_to_fill = contents[1]
		amount_to_fill = hypo_to_fill.volume/4
		hypo_to_fill.reagents.add_reagent(/datum/reagent/medicine/bicaridine, amount_to_fill)
		hypo_to_fill.reagents.add_reagent(/datum/reagent/medicine/kelotane, amount_to_fill)
		hypo_to_fill.reagents.add_reagent(/datum/reagent/medicine/tramadol, amount_to_fill)
		hypo_to_fill.reagents.add_reagent(/datum/reagent/medicine/tricordrazine, amount_to_fill)
		hypo_to_fill.update_icon()
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_pouch/AltClick(mob/user)
	if(!remove_canister(user))
		return ..()

///Removes the reagent canister from the pouch. Returns FALSE if there is no canister to remove
/obj/item/storage/pouch/pressurized_reagent_pouch/proc/remove_canister(mob/user)
	if(!inner)
		to_chat(usr, span_warning("There is no container inside this pouch!"))
		return FALSE
	var/had_empty_hand = user.put_in_active_hand(inner)
	if(!had_empty_hand)
		user.put_in_hands(inner)
	inner = null
	update_icon()
	return TRUE

/obj/item/storage/pouch/pressurized_reagent_pouch/attackby(obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/reagent_containers/glass/reagent_canister))
		if(inner)
			to_chat(user, span_warning("There already is a container inside [src]!"))
			return
		else
			user.temporarilyRemoveItemFromInventory(held_item)
			inner = held_item
			to_chat(user, span_notice("You insert [held_item] into [src]!"))
			update_icon()
			return

	if(istype(held_item, /obj/item/reagent_containers/hypospray))
		fill_autoinjector(held_item)
		return

///Fills the hypo that gets stored in the pouch
/obj/item/storage/pouch/pressurized_reagent_pouch/proc/fill_autoinjector(obj/item/reagent_containers/hypospray/autoinjector)
	if(inner && inner.reagents.total_volume > 0)
		inner.reagents.trans_to(autoinjector, autoinjector.volume)
		playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
		autoinjector.update_icon()
		update_icon()

/obj/item/storage/pouch/pressurized_reagent_pouch/examine(mob/user)
	. = ..()
	var/display_info = display_contents(user)
	if(display_info)
		. += display_info

///Used on examine for properly skilled people to see contents.
/obj/item/storage/pouch/pressurized_reagent_pouch/proc/display_contents(mob/user)
	if(isxeno(user))
		return
	if(!inner)
		return "This [src] has no container inside!"
	if(user.skills.getRating(SKILL_MEDICAL) >= SKILL_MEDICAL_NOVICE)
		if(isnull(inner.reagents.total_volume))
			return span_notice("[src] is empty!")
		var/list/dat = list()
		dat += "\n \t [span_notice("<b>Total Reagents:</b> [inner.reagents.total_volume]/[inner.volume].")]</br>"
		if(length(inner.reagents.reagent_list) > 0)
			for(var/datum/reagent/R in inner.reagents.reagent_list)
				var/percent = round(R.volume / max(0.01 , inner.reagents.total_volume * 0.01),0.01)
				if(R.scannable)
					dat += "\n \t <b>[R]:</b> [R.volume]|[percent]%</br>"
				else
					dat += "\n \t <b>Unknown:</b> [R.volume]|[percent]%</br>"
		return span_notice("[src]'s reagent display shows the following contents: [dat.Join(" ")]")
	else
		return "You don't know what's in it."

