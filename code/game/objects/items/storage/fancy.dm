/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * WARNING: var/icon_type is used for both examine text and sprite name. Please look at the procs below and adjust your sprite names accordingly
 *		TODO: Cigarette boxes should be ported to this standard
 *
 * Contains:
 *		Donut Box
 *		Egg Box
 *		Candle Box
 *		Cigarette Box
 *		Cigar Case
 *		Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	name = "donut box"
	desc = ""
	resistance_flags = FLAMMABLE
	var/icon_type = "donut"
	var/spawn_type = null
	var/fancy_open = FALSE

/obj/item/storage/fancy/PopulateContents()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	for(var/i = 1 to STR.max_items)
		new spawn_type(src)

/obj/item/storage/fancy/update_icon()
	if(fancy_open)
		icon_state = "[icon_type]box[contents.len]"
	else
		icon_state = "[icon_type]box"

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(fancy_open)
		if(length(contents) == 1)
			. += "There is one [icon_type] left."
		else
			. += "There are [contents.len <= 0 ? "no" : "[contents.len]"] [icon_type]s left."

/obj/item/storage/fancy/attack_self(mob/user)
	fancy_open = !fancy_open
	update_icon()
	. = ..()

/obj/item/storage/fancy/Exited()
	. = ..()
	fancy_open = TRUE
	update_icon()

/obj/item/storage/fancy/Entered()
	. = ..()
	fancy_open = TRUE
	update_icon()

/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "donutbox6"
	icon_type = "donut"
	name = "donut box"
	spawn_type = /obj/item/reagent_containers/food/snacks/donut
	fancy_open = TRUE

/obj/item/storage/fancy/donut_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/donut))

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon = 'icons/obj/food/containers.dmi'
	item_state = "eggbox"
	icon_state = "eggbox"
	icon_type = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	name = "egg box"
	desc = ""
	spawn_type = /obj/item/reagent_containers/food/snacks/egg

/obj/item/storage/fancy/egg_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/egg))

/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = ""
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	icon_type = "candle"
	item_state = "candlebox5"
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/candle
	fancy_open = TRUE

/obj/item/storage/fancy/candle_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5

/obj/item/storage/fancy/candle_box/attack_self(mob_user)
	return

////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "\improper Space Cigarettes packet"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig"
	item_state = "cigpacket"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_BELT
	icon_type = "cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/space_cigarette
	var/candy = FALSE //for cigarette overlay

/obj/item/storage/fancy/cigarettes/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette, /obj/item/lighter))

/obj/item/storage/fancy/cigarettes/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to extract contents.</span>"

/obj/item/storage/fancy/cigarettes/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/obj/item/clothing/mask/cigarette/W = locate(/obj/item/clothing/mask/cigarette) in contents
	if(W && contents.len > 0)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, user)
		user.put_in_hands(W)
		contents -= W
		to_chat(user, "<span class='notice'>I take \a [W] out of the pack.</span>")
	else
		to_chat(user, "<span class='notice'>There are no [icon_type]s left in the pack.</span>")

/obj/item/storage/fancy/cigarettes/update_icon()
	if(fancy_open || !contents.len)
		cut_overlays()
		if(!contents.len)
			icon_state = "[initial(icon_state)]_empty"
		else
			icon_state = initial(icon_state)
			add_overlay("[icon_state]_open")
			var/cig_position = 1
			for(var/C in contents)
				var/mutable_appearance/inserted_overlay = mutable_appearance(icon)

				if(istype(C, /obj/item/lighter/greyscale))
					inserted_overlay.icon_state = "lighter_in"
				else if(istype(C, /obj/item/lighter))
					inserted_overlay.icon_state = "zippo_in"
				else if(candy)
					inserted_overlay.icon_state = "candy"
				else
					inserted_overlay.icon_state = "cigarette"

				inserted_overlay.icon_state = "[inserted_overlay.icon_state]_[cig_position]"
				add_overlay(inserted_overlay)
				cig_position++
	else
		cut_overlays()

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!ismob(M))
		return
	var/obj/item/clothing/mask/cigarette/cig = locate(/obj/item/clothing/mask/cigarette) in contents
	if(cig)
		if(M == user && contents.len > 0 && !user.wear_mask)
			var/obj/item/clothing/mask/cigarette/W = cig
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_TAKE, W, M)
			M.equip_to_slot_if_possible(W, SLOT_WEAR_MASK)
			contents -= W
			to_chat(user, "<span class='notice'>I take \a [W] out of the pack.</span>")
		else
			..()
	else
		to_chat(user, "<span class='notice'>There are no [icon_type]s left in the pack.</span>")

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = ""
	icon_state = "dromedary"
	spawn_type = /obj/item/clothing/mask/cigarette/dromedary

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = ""
	icon_state = "uplift"
	spawn_type = /obj/item/clothing/mask/cigarette/uplift

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = ""
	icon_state = "robust"
	spawn_type = /obj/item/clothing/mask/cigarette/robust

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = ""
	icon_state = "robustg"
	spawn_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = ""
	icon_state = "carp"
	spawn_type = /obj/item/clothing/mask/cigarette/carp

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = ""
	icon_state = "syndie"
	spawn_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = ""
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/nicotine

/obj/item/storage/fancy/cigarettes/cigpack_candy
	name = "\improper Timmy's First Candy Smokes packet"
	desc = ""
	icon_state = "candy"
	icon_type = "candy cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/candy
	candy = TRUE

/obj/item/storage/fancy/cigarettes/cigpack_candy/Initialize()
	. = ..()
	if(prob(7))
		spawn_type = /obj/item/clothing/mask/cigarette/candy/nicotine //uh oh!

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name = "\improper Shady Jim's Super Slims packet"
	desc = ""
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_xeno
	name = "\improper Xeno Filtered packet"
	desc = ""
	icon_state = "slime"
	spawn_type = /obj/item/clothing/mask/cigarette/xeno

/obj/item/storage/fancy/cigarettes/cigpack_cannabis
	name = "\improper Freak Brothers' Special packet"
	desc = ""
	icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/cannabis

/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker
	name = "\improper Leary's Delight packet"
	desc = ""
	icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/mindbreaker

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = ""
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	icon_type = "rolling paper"
	spawn_type = /obj/item/rollingpaper

/obj/item/storage/fancy/rollingpapers/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.set_holdable(list(/obj/item/rollingpaper))

/obj/item/storage/fancy/rollingpapers/update_icon()
	cut_overlays()
	if(!contents.len)
		add_overlay("[icon_state]_empty")

/////////////
//CIGAR BOX//
/////////////

/obj/item/storage/fancy/cigarettes/cigars
	name = "\improper premium cigar case"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	w_class = WEIGHT_CLASS_NORMAL
	icon_type = "premium cigar"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar

/obj/item/storage/fancy/cigarettes/cigars/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.set_holdable(list(/obj/item/clothing/mask/cigarette/cigar))

/obj/item/storage/fancy/cigarettes/cigars/update_icon()
	cut_overlays()
	if(fancy_open)
		icon_state = "[initial(icon_state)]_open"

		var/cigar_position = 1 //generate sprites for cigars in the box
		for(var/obj/item/clothing/mask/cigarette/cigar/smokes in contents)
			var/mutable_appearance/cigar_overlay = mutable_appearance(icon, "[smokes.icon_off]_[cigar_position]")
			add_overlay(cigar_overlay)
			cigar_position++

	else
		icon_state = "[initial(icon_state)]"

/obj/item/storage/fancy/cigarettes/cigars/cohiba
	name = "\improper Cohiba Robusto cigar case"
	desc = ""
	icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/storage/fancy/cigarettes/cigars/havana
	name = "\improper premium Havanian cigar case"
	desc = ""
	icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/havana

/*
 * Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = ""
	icon = 'icons/obj/food/containers.dmi'
	item_state = "chocolatebox"
	icon_state = "chocolatebox"
	icon_type = "chocolate"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	spawn_type = /obj/item/reagent_containers/food/snacks/tinychocolate

/obj/item/storage/fancy/heart_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 8
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/tinychocolate))


/obj/item/storage/fancy/nugget_box
	name = "nugget box"
	desc = ""
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "nuggetbox"
	icon_type = "nugget"
	spawn_type = /obj/item/reagent_containers/food/snacks/nugget

/obj/item/storage/fancy/nugget_box/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/nugget))
