/obj/machinery/deployable/reagent_tank
	name = "portable reagent dispenser"
	desc = "A large vessel for transporting chemicals."
	density = TRUE
	max_integrity = 200
	examine_internal_item = FALSE
	///Properties relating to reagents for this container; whether you can check if reagents are visible, if it is refillable, etc.
	var/container_flags = TRANSPARENT|DRAINABLE
	///Maximum units of reagents this container can hold
	var/max_volume = 1000
	///List of reagents this dispenser will start with
	var/list/list_reagents

/obj/machinery/deployable/reagent_tank/Initialize()
	. = ..()
	create_reagents(max_volume, container_flags, list_reagents)
	playsound(src, 'sound/machines/disposalflush.ogg', 50)

/obj/machinery/deployable/reagent_tank/examine(mob/user)
	. = ..()
	. += "The refilling hatch is [is_refillable() ? "open" : "closed"]."

/obj/machinery/deployable/reagent_tank/update_icon()
	//Remove overlays and reset the icon
	overlays.Cut()
	icon_state = initial(internal_item.icon_state)
	//If reagents are present, add some overlays
	if(reagents?.total_volume)
		var/image/filling = image(icon, src, "[icon_state]")
		var/percent = round((reagents.total_volume/max_volume) * 100)
		switch(percent)
			if(0 to 19)
				filling.icon_state = "[icon_state]_1"
			if(20 to 39)
				filling.icon_state = "[icon_state]_2"
			if(40 to 59)
				filling.icon_state = "[icon_state]_3"
			if(60 to 79)
				filling.icon_state = "[icon_state]_4"
			if(80 to 99)
				filling.icon_state = "[icon_state]_5"
			if(99 to INFINITY)
				filling.icon_state = "[icon_state]_full"
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
	//Change the sprite to the one that looks opened to indicate it is in refilling mode
	if(is_refillable())
		icon_state += "_open"

/obj/machinery/deployable/reagent_tank/on_reagent_change()
	update_icon()

/obj/machinery/deployable/reagent_tank/attackby(obj/item/I, mob/user, params)
	if(I.is_refillable())
		return FALSE //Beakers run the refilling code in afterattack()
	return ..()

/obj/machinery/deployable/reagent_tank/AltClick(mob/user)
	if(is_refillable())
		balloon_alert(user, "Dispense mode!")
		DISABLE_BITFIELD(reagents.reagent_flags, REFILLABLE)
		ENABLE_BITFIELD(reagents.reagent_flags, DRAINABLE)
	else
		balloon_alert(user, "Refill mode!")
		DISABLE_BITFIELD(reagents.reagent_flags, DRAINABLE)
		ENABLE_BITFIELD(reagents.reagent_flags, REFILLABLE)
	playsound(src, 'sound/effects/pop.ogg', 100)
	update_icon()

/obj/machinery/deployable/reagent_tank/disassemble(mob/user)
	. = ..()
	playsound(src, 'sound/machines/elevator_openclose.ogg', 50)

/obj/item/reagent_containers/reagent_tank
	name = "portable reagent dispenser"
	desc = "A large vessel for transporting chemicals."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "dispenser"
	item_state_worn = TRUE
	item_state = "reagent_dispenser"
	w_class = WEIGHT_CLASS_HUGE
	flags_equip_slot = ITEM_SLOT_BACK
	init_reagent_flags = TRANSPARENT
	max_integrity = 200
	volume = 1000

/obj/item/reagent_containers/reagent_tank/Initialize()
	. = ..()
	AddElement(/datum/element/deployable_item, /obj/machinery/deployable/reagent_tank, 3 SECONDS, 3 SECONDS)

/obj/item/reagent_containers/reagent_tank/update_icon()
	overlays.Cut()
	icon_state = initial(icon_state)
	if(reagents.total_volume)
		var/image/filling = image(icon, src, "[icon_state]")
		var/percent = round((reagents.total_volume/volume) * 100)
		switch(percent)
			if(0 to 19)
				filling.icon_state = "[icon_state]_1"
			if(20 to 39)
				filling.icon_state = "[icon_state]_2"
			if(40 to 59)
				filling.icon_state = "[icon_state]_3"
			if(60 to 79)
				filling.icon_state = "[icon_state]_4"
			if(80 to 99)
				filling.icon_state = "[icon_state]_5"
			if(99 to INFINITY)
				filling.icon_state = "[icon_state]_full"
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/reagent_containers/reagent_tank/on_reagent_change()
	update_icon()
