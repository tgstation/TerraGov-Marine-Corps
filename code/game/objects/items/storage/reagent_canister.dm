//Reagent Canister pouch. Including the canister inside the pouch, as well as the pouch item.

// See the Pressurized Reagent Canister Pouch, this is just the container
/obj/item/reagent_containers/glass/pressurized_canister
	name = "Pressurized canister"
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

/obj/item/reagent_containers/glass/pressurized_canister/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/pressurized_canister/attackby(obj/item/I, mob/user)
	return

/obj/item/reagent_containers/glass/pressurized_canister/afterattack(obj/target, mob/user, flag)
	//if(!istype(target, /obj/structure/reagent_dispensers))
	//	return
	. = ..()

/obj/item/reagent_containers/glass/pressurized_canister/set_APTFT()
	to_chat(usr, span_warning("[src] has no transfer control valve! Use a dispenser to fill it!"))
	return

/obj/item/reagent_containers/glass/pressurized_canister/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/pressurized_canister/update_icon()
	color = COLOR_WHITE
	if(reagents)
		color = mix_color_from_reagents(reagents.reagent_list)
	..()

//The actual pouch itself and all its function
/obj/item/storage/pouch/pressurized_reagent_canister
	name = "Pressurized Reagent Canister Pouch"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY
	allow_drawing_method = TRUE
	icon_state = "pressurized_reagent_canister"
	desc = "A pressurized reagent canister pouch. It is used to refill custom injectors, and can also store one.\
	You can Alt-Click to remove the canister in order to refill it."
	can_hold = list(/obj/item/reagent_containers/hypospray)
	flags_item = NOBLUDGEON
	///The internal container of the pouch. Holds the reagent that you use to refill the connected injector
	var/obj/item/reagent_containers/glass/pressurized_canister/inner

/obj/item/storage/pouch/pressurized_reagent_canister/Initialize(mapload)
	. = ..()
	inner = new /obj/item/reagent_containers/glass/pressurized_canister
	new /obj/item/reagent_containers/hypospray/advanced(src)
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/update_icon()
	overlays.Cut()
	if(length(contents))
		overlays += "+[icon_state]_full"
	if(inner)
		//tint the inner display based on what chemical is inside
		var/image/I = image(icon, icon_state="+[icon_state]_loaded")
		if(inner.reagents)
			I.color = mix_color_from_reagents(inner.reagents.reagent_list)
		overlays += I

/obj/item/storage/pouch/pressurized_reagent_canister/proc/fill_with(chem_to_fill)
	var/amount_to_fill = inner.volume
	inner.reagents.add_reagent(chem_to_fill, amount_to_fill)
	var/obj/item/reagent_containers/hypospray/advanced/hypo_in_pouch = contents[1]
	amount_to_fill = hypo_in_pouch.volume
	hypo_in_pouch.reagents.add_reagent(chem_to_fill, amount_to_fill)
	hypo_in_pouch.update_icon()
	update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/bktt/Initialize()
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

/obj/item/storage/pouch/pressurized_reagent_canister/bicaridine/Initialize()
	. = ..()
	fill_with(/datum/reagent/medicine/bicaridine)

/obj/item/storage/pouch/pressurized_reagent_canister/kelotane/Initialize()
	. = ..()
	fill_with(/datum/reagent/medicine/kelotane)

/obj/item/storage/pouch/pressurized_reagent_canister/tramadol/Initialize()
	. = ..()
	fill_with(/datum/reagent/medicine/tramadol)

/obj/item/storage/pouch/pressurized_reagent_canister/tricordrazine/Initialize()
	. = ..()
	fill_with(/datum/reagent/medicine/tricordrazine)

/obj/item/storage/pouch/pressurized_reagent_canister/AltClick(mob/user)
	if(!remove_canister())
		return ..()


/obj/item/storage/pouch/pressurized_reagent_canister/attackby(obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/reagent_containers/glass/pressurized_canister))
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

/obj/item/storage/pouch/pressurized_reagent_canister/proc/fill_autoinjector(obj/item/reagent_containers/hypospray/autoinjector)
	if(inner && inner.reagents.total_volume > 0)
		inner.reagents.trans_to(autoinjector, autoinjector.volume)
		playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)
		autoinjector.update_icon()
		update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/examine(mob/user)
	. = ..()
	var/display_info = display_contents(user)
	if(display_info)
		. += display_info

/obj/item/storage/pouch/pressurized_reagent_canister/proc/display_contents(mob/user) // Used on examine for properly skilled people to see contents.
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

/obj/item/storage/pouch/pressurized_reagent_canister/verb/flush_container()
	set category = "Weapons"
	set name = "Flush Container"
	set desc = "Forces the container to empty its reagents."
	set src in usr
	if(!inner)
		to_chat(usr, span_warning("There is no container inside this pouch!"))
		return

	usr.balloon_alert(usr, "Emptying...")
	if(!do_after(usr, 3 SECONDS, TRUE, usr, BUSY_ICON_DANGER))
		return usr.balloon_alert(usr, "Cancelled")
	if(inner)
		to_chat(usr, span_notice("You flush the [src]."))
		inner.reagents.clear_reagents()
		update_icon()

/obj/item/storage/pouch/pressurized_reagent_canister/verb/remove_canister()
	set category = "Weapons"
	set name = "Remove Canister"
	set desc = "Removes the Pressurized Canister from the pouch."
	set src in usr
	if(!inner)
		to_chat(usr, span_warning("There is no container inside this pouch!"))
		return

	var/had_empty_hand = usr.put_in_active_hand(inner)
	if(!had_empty_hand)
		usr.put_in_hands(inner)

	inner = null
	update_icon()
