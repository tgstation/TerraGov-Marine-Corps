/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */

GLOBAL_LIST_EMPTY(possible_gifts)

/obj/item/a_gift
	name = "gift"
	desc = "A wrapped bundle of joy, you'll have to get closer to see who it's addressed to."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift0"
	inhand_icon_state = "gift0"
	resistance_flags = RESIST_ALL
	///if true the present can be opened by anybody
	var/freepresent = FALSE
	///who is the present addressed to?
	var/present_receiver = null
	///item contained in this gift
	var/obj/item/contains_type

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "gift[rand(0,4)]"

	contains_type = get_gift_type()

/obj/item/a_gift/attack_self(mob/M)
	if(present_receiver == null)
		get_recipient()
	to_chat(user, span_warning("You start unwrapping the present, trying to locate any sign of who the present belongs to..."))
	if(!do_after(user, 4 SECONDS))
		return
	if(!freepresent && present_receiver != M)
		if(tgui_alert(M, "This present is addressed to [present_receiver]. Open it anyways?", "Continue?", list("Yes", "No")) != "No")
			if(prob(99))
				new /obj/item/ore/coal(get_turf(M))
			else
				spawnpresent(M)
			qdel(src)
			return

	qdel(src)
	spawnpresent(M)

/obj/item/a_gift/proc/get_recipient(mob/M)
	var/list/eligible_targets = list()
	for(var/z in z_levels)
		for(var/i in GLOB.alive_human_list)
			var/mob/living/carbon/human/potential_gift_receiver = i
			if(!istype(possible_target) || !possible_target.client)
				continue
			eligible_targets += potential_gift_receiver
	if(!length(eligible_targets))
		freepresent = TRUE //nobody alive, anybody can open it
	present_receiver = (pick(eligible_targets))

/obj/item/a_gift/proc/spawnpresent(mob/M)
	var/obj/item/I = new contains_type(get_turf(M))
	if(!QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
		M.visible_message(span_notice("[M] unwraps \the [src], finding \a [I] inside!"))
		M.put_in_hands(I)
		I.add_fingerprint(M)
	else
		M.visible_message(span_danger("Oh no! The present that [M] opened had nothing inside it!"))

/obj/item/a_gift/proc/get_gift_type()
	var/gift_type_list = list(/obj/item/sord,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/diamond,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_official,
		/obj/item/book/manual/wiki/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/banhammer,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/pai_card,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/clothing/suit/costume/poncho,
		/obj/item/clothing/suit/costume/poncho/green,
		/obj/item/clothing/suit/costume/poncho/red,
		/obj/item/clothing/suit/costume/snowman,
		/obj/item/clothing/head/snowman,
		/obj/item/ore/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/figure + /obj/item/toy/ammo)) //All toys, except for abstract types and syndicate cards.

	var/gift_type = pick(gift_type_list)

	return gift_type


/obj/item/a_gift/anything
	name = "christmas gift"
	desc = "It could be anything!"

/obj/item/a_gift/anything/get_gift_type()
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		for(var/V in gift_types_list)
			var/obj/item/I = V
			if((!initial(I.icon_state)) || (!initial(I.inhand_icon_state)) || (initial(I.item_flags) & ABSTRACT))
				gift_types_list -= V
		GLOB.possible_gifts = gift_types_list
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type

/obj/item/a_gift/weapons

/obj/item/a_gift/medicine

/obj/item/a_gift/fluff
