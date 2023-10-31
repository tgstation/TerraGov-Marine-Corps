//Reagent Canister pouch. Including the canister inside the pouch, as well as the pouch item.

/obj/item/reagent_containers/glass/reagent_canister // See the Reagent Canister Pouch, this is just the container
	name = "pressurized reagent container"
	desc = "A pressurized container. The inner part of a pressurized reagent canister pouch. Too large to fit in anything but the pouch it comes with."
	icon = 'icons/Marine/marine-pouches.dmi'
	icon_state = "r_canister"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tanks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tanks_right.dmi',
	)
	item_state = "anesthetic"
	possible_transfer_amounts = null
	volume = 1200 //The equivalent of 5 pill bottles worth of BKTT
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reagent_containers/glass/reagent_canister/examine(mob/user)
	. = ..()
	. += get_examine_info(user)

///Used on examine for properly skilled people to see contents.
/obj/item/reagent_containers/glass/reagent_canister/proc/get_examine_info(mob/user)
	if(isxeno(user))
		return
	if(!(user.skills.getRating(SKILL_MEDICAL) >= SKILL_MEDICAL_NOVICE)) //Failed skill check
		return "You don't know what's in it."
	if(isnull(reagents.total_volume))
		return span_notice("[src] is empty!")
	var/list/dat = list()
	dat += "\n \t [span_notice("<b>Total Reagents:</b> [reagents.total_volume]/[volume].")]</br>"
	for(var/datum/reagent/R in reagents.reagent_list)
		var/percent = round(R.volume / max(0.01 , reagents.total_volume * 0.01),0.01)
		if(R.scannable)
			dat += "\n \t <b>[R]:</b> [R.volume]|[percent]%</br>"
		else
			dat += "\n \t <b>Unknown:</b> [R.volume]|[percent]%</br>"
	return span_notice("[src]'s contains: [dat.Join(" ")]")

/obj/item/storage/pouch/pressurized_reagent_pouch //The actual pouch itself and all its function
	name = "pressurized reagent pouch"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY
	allow_drawing_method = TRUE
	icon_state = "reagent_pouch"
	desc = "A very large reagent pouch. It is used to refill custom injectors, and can also store one.\
	You can Alt-Click to remove the canister in order to refill it."
	can_hold = list(/obj/item/reagent_containers/hypospray)
	cant_hold = list(/obj/item/reagent_containers/glass/reagent_canister) //To prevent chat spam when you try to put the container in
	flags_item = NOBLUDGEON
	///The internal container of the pouch. Holds the reagent that you use to refill the connected injector
	var/obj/item/reagent_containers/glass/reagent_canister/inner

/obj/item/storage/pouch/pressurized_reagent_pouch/Initialize(mapload)
	. = ..()
	inner = new /obj/item/reagent_containers/glass/reagent_canister
	new /obj/item/reagent_containers/hypospray/advanced(src)
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_pouch/update_overlays()
	. = ..()
	if(!inner)
		. += image('icons/Marine/marine-pouches.dmi', src, "reagent_pouch_0")
		return
	. += image('icons/Marine/marine-pouches.dmi', src, "reagent_canister")
	var/percentage = round((inner.reagents.total_volume/inner.reagents.maximum_volume)*100)
	switch(percentage)
		if(0)
			. += image('icons/Marine/marine-pouches.dmi', src, "reagent_pouch_0")
		if(1 to 33)
			. += image('icons/Marine/marine-pouches.dmi', src, "reagent_pouch_1")
		if(34 to 66)
			. += image('icons/Marine/marine-pouches.dmi', src, "reagent_pouch_2")
		if(67 to 100)
			. += image('icons/Marine/marine-pouches.dmi', src, "reagent_pouch_3")

/obj/item/storage/pouch/pressurized_reagent_pouch/bktt/Initialize()
	. = ..()
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
		to_chat(user, span_warning("There is no container inside this pouch!"))
		return FALSE
	if(!user.put_in_active_hand(inner))
		user.put_in_hands(inner) //If put_in_active fails, we still pick up or drop the canister
	inner = null
	update_icon()
	return TRUE

/obj/item/storage/pouch/pressurized_reagent_pouch/attackby(obj/item/held_item, mob/user)
	if(istype(held_item, /obj/item/reagent_containers/hypospray))
		fill_autoinjector(held_item, user)
		return ..()

	if(istype(held_item, /obj/item/reagent_containers/glass/reagent_canister)) //If it's the reagent canister, we put it in the special holder
		if(!inner)
			user.temporarilyRemoveItemFromInventory(held_item)
			inner = held_item
			to_chat(user, span_notice("You insert [held_item] into [src]!"))
			update_icon()
			return
		return to_chat(user, span_warning("There already is a container inside [src]!"))

	return ..()

/obj/item/storage/pouch/pressurized_reagent_pouch/attackby_alternate(obj/item/held_item, mob/user, params)
	. = ..()
	if(istype(held_item, /obj/item/reagent_containers/hypospray))
		fill_autoinjector(held_item, user)

///Fills the hypo that gets stored in the pouch from the internal storage tank. Returns FALSE if you fail to refill your injector
/obj/item/storage/pouch/pressurized_reagent_pouch/proc/fill_autoinjector(obj/item/reagent_containers/hypospray/autoinjector, mob/user)
	if(!inner)
		user.balloon_alert(user, "No container")
		return FALSE
	if(inner.reagents.total_volume == 0)
		user.balloon_alert(user, "No reagent left")
		return FALSE
	if(inner.reagents.total_volume > 0)
		inner.reagents.trans_to(autoinjector, autoinjector.volume)
		playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
		autoinjector.update_icon()
		update_icon()

/obj/item/storage/pouch/pressurized_reagent_pouch/examine(mob/user)
	. = ..()
	. += get_display_contents(user)

///Used on examine for properly skilled people to see contents.
/obj/item/storage/pouch/pressurized_reagent_pouch/proc/get_display_contents(mob/user)
	if(isxeno(user))
		return
	if(!(user.skills.getRating(SKILL_MEDICAL) >= SKILL_MEDICAL_NOVICE)) //Failed skill check
		return "You don't know what's in it."
	if(isnull(inner))
		return "[src] has no container inside!"
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

