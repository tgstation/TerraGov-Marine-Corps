/obj/machinery/deployable/reagent_tank
	name = "portable reagent dispenser"
	desc = "A large vessel for transporting chemicals. Has a cabinet for storing chemical supplies."
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	max_integrity = 200
	///Properties relating to reagents for this container; whether you can check if reagents are visible, if it is refillable, etc.
	var/container_flags = TRANSPARENT|DRAINABLE
	///Maximum units of reagents this container can hold
	var/max_volume = 3000

/obj/machinery/deployable/reagent_tank/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, container_flags)
	playsound(src, 'sound/machines/disposalflush.ogg', 50)
	var/obj/item/_internal_item = get_internal_item()
	if(!internal_item)
		return
	default_icon_state = initial(_internal_item.icon_state)	//For adding overlays, otherwise the game fetches sprites that don't exist

//Using examine() because deployable descriptions are overwritten by the internal object's description
/obj/machinery/deployable/reagent_tank/examine(mob/user)
	. = ..()
	. += "The refilling hatch is [is_refillable() ? "open" : "closed"]. [span_bold("Alt Click")] to toggle the hatch."
	. += "[span_bold("Click")] with an open hand to access the storage cabinet."
	. += "[span_bold("Click")] with an open hand on [span_bold("Grab")] intent to drink from the nozzle."
	. += "[span_bold("Drag")] to yourself to undeploy."

/obj/machinery/deployable/reagent_tank/update_icon_state()
	. = ..()
	//Reset the icon
	icon_state = default_icon_state
	//Change the sprite to the one that looks opened to indicate it is in refilling mode
	if(is_refillable())
		icon_state += "_open"

/obj/machinery/deployable/reagent_tank/update_overlays()
	. = ..()
	//If reagents are present, add some overlays
	if(reagents?.total_volume)
		var/image/filling = image(icon, src, "[default_icon_state]")
		var/percent = round((reagents.total_volume/max_volume) * 100)
		switch(percent)
			if(0 to 19)
				filling.icon_state = "[default_icon_state]_1"
			if(20 to 39)
				filling.icon_state = "[default_icon_state]_2"
			if(40 to 59)
				filling.icon_state = "[default_icon_state]_3"
			if(60 to 79)
				filling.icon_state = "[default_icon_state]_4"
			if(80 to 99)
				filling.icon_state = "[default_icon_state]_5"
			if(99 to INFINITY)
				filling.icon_state = "[default_icon_state]_full"
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/machinery/deployable/reagent_tank/on_reagent_change()
	update_icon()

/obj/machinery/deployable/reagent_tank/attack_hand(mob/living/user)
	. = ..()
	if(user.a_intent == INTENT_GRAB)
		return drink_from_nozzle(user)
	var/obj/item/storage/internal_bag = get_internal_item()
	internal_bag?.storage_datum.open(user)

/obj/machinery/deployable/reagent_tank/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.a_intent != INTENT_HARM)
		return drink_from_nozzle(xeno_attacker, TRUE)
	return ..()

///Process for drinking reagents directly from the dispenser's nozzle
/obj/machinery/deployable/reagent_tank/proc/drink_from_nozzle(mob/living/user, is_xeno = FALSE)
	if(isrobot(user) || issynth(user))
		balloon_alert(user, "you can't drink!")
		return FALSE
	if(reagents?.total_volume)
		if(!is_xeno)
			//Everyone will be made aware of your nasty habits!
			visible_message(span_alert("[user] is putting [user.p_their()] mouth on [src]'s nozzle. Gross!"))
		if(!do_after(user, 0.5 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_DANGER))
			return FALSE
		if(is_xeno)
			visible_message(span_alert("[user] sips from [src]'s nozzle. Adorable."))
		record_sippies(5, reagents.reagent_list, user)
		playsound(user.loc,'sound/items/drink.ogg', 25, 2)
		reagents.reaction(user, INGEST)
		reagents.trans_to(user, 5)
		return TRUE
	balloon_alert(user, "it's empty!")

/obj/machinery/deployable/reagent_tank/attackby(obj/item/I, mob/user, params)
	if(I.is_refillable())
		return FALSE //Beakers run the refilling code in afterattack()
	return ..()

/obj/machinery/deployable/reagent_tank/AltClick(mob/user)
	if(is_refillable())
		balloon_alert(user, "dispense mode")
		reagents.reagent_flags &= ~REFILLABLE
		reagents.reagent_flags |= DRAINABLE
	else
		balloon_alert(user, "refill mode")
		reagents.reagent_flags &= ~DRAINABLE
		reagents.reagent_flags |= REFILLABLE
	playsound(src, 'sound/effects/pop.ogg', 100)
	update_icon()

/obj/machinery/deployable/reagent_tank/disassemble(mob/user)
	var/obj/item/storage/internal_bag = get_internal_item()
	for(var/mob/watching in internal_bag?.storage_datum.content_watchers)
		internal_bag.storage_datum.close(watching)
	playsound(src, 'sound/machines/elevator_openclose.ogg', 50)
	return ..()

/obj/item/storage/reagent_tank
	name = "portable reagent dispenser"
	desc = "A large vessel for transporting chemicals. Has a cabinet for storing chemical supplies."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "dispenser"
	item_state_worn = TRUE
	worn_icon_state = "reagent_dispenser"
	equip_slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	max_integrity = 200
	storage_type = /datum/storage/reagent_tank
	///Properties relating to reagents for this container; whether you can check if reagents are visible, if it is refillable, etc.
	var/container_flags = TRANSPARENT
	///Maximum units of reagents this container can hold
	var/max_volume = 3000
	///List of reagents this dispenser will start with
	var/list/starting_reagents

/obj/item/storage/reagent_tank/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, container_flags, starting_reagents)
	AddComponent(/datum/component/deployable_item, /obj/machinery/deployable/reagent_tank, 3 SECONDS, 3 SECONDS)
	//Comes with a scanner by default so players can scan the tanks
	new /obj/item/reagent_scanner/adv (src)

/obj/item/storage/reagent_tank/examine(mob/user)
	. = ..()
	. += "[span_bold("Ctrl Click")] an adjacent tile to deploy."

/obj/item/storage/reagent_tank/update_overlays()
	. = ..()
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
		. += filling

/obj/item/storage/reagent_tank/on_reagent_change()
	update_icon()

/obj/item/storage/reagent_tank/attack_hand(mob/living/user)
	if(CHECK_BITFIELD(item_flags, IS_DEPLOYED))
		return storage_datum.open(user)
	return ..()

/obj/item/storage/reagent_tank/do_quick_equip(mob/user)
	balloon_alert(user, "not deployed!")

//Preset tanks so you can have these ready for a round and not need to drain the chem master's energy
/obj/item/storage/reagent_tank/bicaridine
	name = "portable Bicaridine dispenser"
	starting_reagents = list(/datum/reagent/medicine/bicaridine = 3000)

/obj/item/storage/reagent_tank/kelotane
	name = "portable Kelotane dispenser"
	starting_reagents = list(/datum/reagent/medicine/kelotane = 3000)

/obj/item/storage/reagent_tank/tramadol
	name = "portable Tramadol dispenser"
	starting_reagents = list(/datum/reagent/medicine/tramadol = 3000)

/obj/item/storage/reagent_tank/tricordrazine
	name = "portable Tricordrazine dispenser"
	starting_reagents = list(/datum/reagent/medicine/tricordrazine = 3000)

/obj/item/storage/reagent_tank/bktt
	name = "portable BKTT-mix dispenser"
	starting_reagents = list(
		/datum/reagent/medicine/bicaridine = 750,
		/datum/reagent/medicine/kelotane = 750,
		/datum/reagent/medicine/tramadol = 750,
		/datum/reagent/medicine/tricordrazine = 750,
	)
