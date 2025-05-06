/obj/item/reagent_containers/cup
	name = "open container"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	volume = 50
	reagent_flags = OPENCONTAINER
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
	var/can_shatter = FALSE

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
		if(!do_after(user, 3 SECONDS, target = target_mob))
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
