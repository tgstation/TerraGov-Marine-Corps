/obj/item/reagent_containers/cup
	name = "open container"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	init_reagent_flags = OPENCONTAINER
	resistance_flags = UNACIDABLE
	icon_state = "bottle"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/drinks_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/drinks_righthand.dmi',
	)

	///Like Edible's food type, what kind of drink is this?
	var/drink_type = NONE
	///The last time we have checked for taste.
	var/last_check_time
	///How much we drink at once, shot glasses drink more.
	var/gulp_size = 5
	///Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it.
	var/isGlass = FALSE

/obj/item/reagent_containers/cup/examine(mob/user)
	. = ..()
	if(drink_type)
		var/list/types = bitfield_to_list(drink_type, FOOD_FLAGS)
		. += span_notice("It is [LOWER_TEXT(english_list(types))].")

/obj/item/reagent_containers/cup/attack(mob/living/target_mob, mob/living/user, obj/target)
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return

	if(!istype(target_mob))
		return

	if(target_mob != user)
		target_mob.visible_message(span_danger("[user] attempts to feed [target_mob] something from [src]."), \
					span_userdanger("[user] attempts to feed you something from [src]."))
		if(!do_after(user, 3 SECONDS, target_mob))
			return
		if(!reagents || !reagents.total_volume)
			return // The drink might be empty after the delay, such as by spam-feeding
		target_mob.visible_message(span_danger("[user] feeds [target_mob] something from [src]."), \
					span_userdanger("[user] feeds you something from [src]."))
	else
		to_chat(user, span_notice("You swallow a gulp of [src]."))

	SEND_SIGNAL(src, COMSIG_GLASS_DRANK, target_mob, user)
	reagents.trans_to(target_mob, gulp_size)
	playsound(target_mob.loc,'sound/items/drink.ogg', rand(10,50), TRUE)

/obj/item/reagent_containers/cup/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(!has_proximity)
		return ..()

	if(!check_allowed_items(target, target_self = TRUE))
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty!"))
			return

		if(target.reagents.holder_full())
			to_chat(user, span_warning("[target] is full."))
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, span_notice("You transfer [trans] unit\s of the solution to [target]."))
		SEND_SIGNAL(src, COMSIG_REAGENTS_CUP_TRANSFER_TO, target)
		target.update_appearance()

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty and can't be refilled!"))
			return

		if(reagents.holder_full())
			to_chat(user, span_warning("[src] is full."))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))
		SEND_SIGNAL(src, COMSIG_REAGENTS_CUP_TRANSFER_FROM, target)
		target.update_appearance()

/obj/item/reagent_containers/cup/afterattack_alternate(atom/target, mob/user, has_proximity, click_parameters)
	if((!has_proximity) || !check_allowed_items(target, target_self = TRUE))
		return FALSE

	if(!target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		return FALSE

	if(!target.reagents.total_volume)
		to_chat(user, span_warning("[target] is empty!"))
		return FALSE

	if(reagents.holder_full())
		to_chat(user, span_warning("[src] is full."))
		return FALSE

	var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
	to_chat(user, span_notice("You fill [src] with [trans] unit\s of the contents of [target]."))

	target.update_appearance()

/obj/item/reagent_containers/cup/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/reagent_containers/food/snacks/egg)) //breaking eggs // TG FOOD PORT -> Turn this into real eggs
		var/obj/item/reagent_containers/food/snacks/egg/attacking_egg = attacking_item
		if(!reagents)
			return TRUE
		if(reagents.holder_full())
			to_chat(user, span_notice("[src] is full."))
		else
			to_chat(user, span_notice("You break [attacking_egg] in [src]."))
			attacking_egg.reagents.trans_to(src, attacking_egg.reagents.total_volume)
			qdel(attacking_egg)
		return TRUE

	return ..()

/// Callback for [datum/component/takes_reagent_appearance] to inherent style footypes
/obj/item/reagent_containers/cup/proc/on_cup_change(datum/glass_style/has_foodtype/style)
	if(!istype(style))
		return
	drink_type = style.drink_type

/// Callback for [datum/component/takes_reagent_appearance] to reset to no foodtypes
/obj/item/reagent_containers/cup/proc/on_cup_reset()
	drink_type = NONE

/*
/obj/item/reagent_containers/cup/beaker
	name = "beaker"
	desc = "A beaker. It can hold up to 50 units."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "beaker"
	inhand_icon_state = "beaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	worn_icon_state = "beaker"
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

/obj/item/reagent_containers/cup/beaker/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/beaker/get_part_rating()
	return reagents.maximum_volume

/obj/item/reagent_containers/cup/beaker/jar
	name = "honey jar"
	desc = "A jar for honey. It can hold up to 50 units of sweet delight."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "vapour"

/obj/item/reagent_containers/cup/beaker/large
	name = "large beaker"
	desc = "A large beaker. Can hold up to 100 units."
	icon_state = "beakerlarge"
	volume = 100
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100)
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)

/obj/item/reagent_containers/cup/beaker/plastic
	name = "x-large beaker"
	desc = "An extra-large beaker. Can hold up to 120 units."
	icon_state = "beakerwhite"
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120)
	fill_icon_thresholds = list(0, 1, 10, 20, 40, 60, 80, 100)

/obj/item/reagent_containers/cup/beaker/meta
	name = "metamaterial beaker"
	desc = "A large beaker. Can hold up to 180 units."
	icon_state = "beakergold"
	volume = 180
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,60,120,180)
	fill_icon_thresholds = list(0, 1, 10, 25, 35, 50, 60, 80, 100)

/obj/item/reagent_containers/cup/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without \
		reactions. Can hold up to 50 units."
	icon_state = "beakernoreact"
	init_reagent_flags = OPENCONTAINER | NO_REACT
	volume = 50
	amount_per_transfer_from_this = 10

/obj/item/reagent_containers/cup/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology \
		and Element Cuban combined with the Compound Pete. Can hold up to \
		300 units."
	icon_state = "beakerbluespace"
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,20,25,30,50,100,300)
*/ // XANTODO Turn beakers into cups ? Maybe TG sprites ?

/obj/item/reagent_containers/cup/bucket
	name = "bucket"
	desc = "It's a bucket."
	icon = 'icons/obj/service/janitor.dmi'
	worn_icon = 'icons/mob/clothing/head/utility.dmi'
	icon_state = "bucket"
	inhand_icon_state = "bucket"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	fill_icon_state = "bucket"
	fill_icon_thresholds = list(50, 90)
	w_class = WEIGHT_CLASS_NORMAL
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(5,10,15,20,25,30,50,70)
	volume = 70
	flags_inv = HIDEHAIR
	slot_flags = ITEM_SLOT_HEAD
	resistance_flags = NONE
	armor_type = /datum/armor/cup_bucket
	slot_equipment_priority = list( \
		ITEM_SLOT_BACK, ITEM_SLOT_ID,\
		ITEM_SLOT_ICLOTHING, ITEM_SLOT_OCLOTHING,\
		ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_NECK,\
		ITEM_SLOT_FEET, ITEM_SLOT_GLOVES,\
		ITEM_SLOT_EARS, ITEM_SLOT_EYES,\
		ITEM_SLOT_BELT, ITEM_SLOT_SUITSTORE,\
		ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET,\
		ITEM_SLOT_DEX_STORAGE
	)

/datum/armor/cup_bucket
	melee = 10
	fire = 75
	acid = 50

/obj/item/reagent_containers/cup/bucket/wooden
	name = "wooden bucket"
	icon_state = "woodbucket"
	inhand_icon_state = "woodbucket"
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/bucket_wooden

/datum/armor/bucket_wooden
	melee = 10
	acid = 50

/obj/item/reagent_containers/cup/bucket/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/mop))
		if(reagents.total_volume < 1)
			user.balloon_alert(user, "empty!")
		else
			reagents.trans_to(O, 5)
			user.balloon_alert(user, "doused [O]")
			playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
		return
	else if(isprox(O)) //This works with wooden buckets for now. Somewhat unintended, but maybe someone will add sprites for it soon(TM)
		to_chat(user, span_notice("You add [O] to [src]."))
		qdel(O)
		var/obj/item/bot_assembly/cleanbot/new_cleanbot_ass = new(null, src)
		user.put_in_hands(new_cleanbot_ass)
		return

	return ..()

/obj/item/reagent_containers/cup/bucket/equipped(mob/user, slot)
	. = ..()
	if (slot & ITEM_SLOT_HEAD)
		if(reagents.total_volume)
			to_chat(user, span_userdanger("[src]'s contents spill all over you!"))
			reagents.expose(user, TOUCH)
			reagents.clear_reagents()
		reagents.reagent_flags = NONE

/obj/item/reagent_containers/cup/bucket/dropped(mob/user)
	. = ..()
	reagents.reagent_flags = initial(init_reagent_flags)

/obj/item/reagent_containers/cup/bucket/equip_to_best_slot(mob/M)
	if(reagents.total_volume) //If there is water in a bucket, don't quick equip it to the head
		var/index = slot_equipment_priority.Find(ITEM_SLOT_HEAD)
		slot_equipment_priority.Remove(ITEM_SLOT_HEAD)
		. = ..()
		slot_equipment_priority.Insert(index, ITEM_SLOT_HEAD)
		return
	return ..()

/obj/item/pestle
	name = "pestle"
	desc = "An ancient, simple tool used in conjunction with a mortar to grind or juice items."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "pestle"
	force = 7

/obj/item/reagent_containers/cup/mortar
	name = "mortar"
	desc = "A specially formed bowl of ancient design. It is possible to crush or juice items placed in it using a pestle; however the process, unlike modern methods, is slow and physically exhausting."
	desc_controls = "Alt click to eject the item."
	icon_state = "mortar"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50, 100)
	volume = 100
	resistance_flags = FLAMMABLE
	init_reagent_flags = OPENCONTAINER
	var/obj/item/grinded

/obj/item/reagent_containers/cup/mortar/click_alt(mob/user)
	if(!grinded)
		return CLICK_ACTION_BLOCKING
	grinded.forceMove(drop_location())
	grinded = null
	balloon_alert(user, "ejected")
	return CLICK_ACTION_SUCCESS

/obj/item/reagent_containers/cup/mortar/attackby(obj/item/I, mob/living/carbon/human/user)
	..()
	if(istype(I,/obj/item/pestle))
		if(grinded)
			if(user.getStaminaLoss() > 50)
				to_chat(user, span_warning("You are too tired to work!"))
				return
			var/list/choose_options = list(
				"Grind" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_grind"),
				"Juice" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_juice")
			)
			var/picked_option = show_radial_menu(user, src, choose_options, radius = 38, require_near = TRUE)
			if(grinded && in_range(src, user) && user.is_holding(I) && picked_option)
				to_chat(user, span_notice("You start grinding..."))
				if(do_after(user, 2.5 SECONDS, target = src))
					user.adjustStaminaLoss(40)
					switch(picked_option)
						if("Juice")
							return juice_item(grinded, user)
						if("Grind")
							return grind_item(grinded, user)
						else
							to_chat(user, span_notice("You try to grind the mortar itself instead of [grinded]. You failed."))
							return
			return
		else
			to_chat(user, span_warning("There is nothing to grind!"))
			return
	if(grinded)
		to_chat(user, span_warning("There is something inside already!"))
		return
	if(I.juice_typepath || I.grind_results)
		I.forceMove(src)
		grinded = I
		return
	to_chat(user, span_warning("You can't grind this!"))

/obj/item/reagent_containers/cup/mortar/proc/grind_item(obj/item/item, mob/living/carbon/human/user)
	if(item.flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("You try to grind [item], but it fades away!"))
		qdel(item)
		return

	if(!item.grind(reagents, user))
		if(isstack(item))
			to_chat(usr, span_notice("[src] attempts to grind as many pieces of [item] as possible."))
		else
			to_chat(user, span_danger("You fail to grind [item]."))
		return
	to_chat(user, span_notice("You grind [item] into a nice powder."))
	grinded = null
	QDEL_NULL(item)

/obj/item/reagent_containers/cup/mortar/proc/juice_item(obj/item/item, mob/living/carbon/human/user)
	if(item.flags_1 & HOLOGRAM_1)
		to_chat(user, span_notice("You try to juice [item], but it fades away!"))
		qdel(item)
		return

	if(!item.juice(reagents, user))
		to_chat(user, span_notice("You fail to juice [item]."))
		return
	to_chat(user, span_notice("You juice [item] into a fine liquid."))
	grinded = null
	QDEL_NULL(item)

//Coffeepots: for reference, a standard cup is 30u, to allow 20u for sugar/sweetener/milk/creamer
/obj/item/reagent_containers/cup/coffeepot
	name = "coffeepot"
	desc = "A large pot for dispensing that ambrosia of corporate life known to mortals only as coffee. Contains 4 standard cups."
	volume = 120
	icon_state = "coffeepot"
	fill_icon_state = "coffeepot"
	fill_icon_thresholds = list(0, 1, 30, 60, 100)

/obj/item/reagent_containers/cup/coffeepot/bluespace
	name = "bluespace coffeepot"
	desc = "The most advanced coffeepot the eggheads could cook up: sleek design; graduated lines; connection to a pocket dimension for coffee containment; yep, it's got it all. Contains 8 standard cups."
	volume = 240
	icon_state = "coffeepot_bluespace"
	fill_icon_thresholds = list(0)

///Test tubes created by chem master and pandemic and placed in racks
/obj/item/reagent_containers/cup/tube
	name = "tube"
	desc = "A small test tube."
	icon_state = "test_tube"
	fill_icon_state = "tube"
	inhand_icon_state = "atoxinbottle"
	worn_icon_state = "beaker"
	possible_transfer_amounts = list(5, 10, 15, 30)
	volume = 30
	fill_icon_thresholds = list(0, 1, 20, 40, 60, 80, 100)
