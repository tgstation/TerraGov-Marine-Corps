/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */

GLOBAL_LIST_EMPTY(possible_gifts)

///special grenade that looks like a present, santa spawn only
/obj/item/explosive/grenade/gift
	name = "gift"
	desc = "A wrapped bundle of joy, you'll have to get closer to see who it's addressed to."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift0"
	hud_state = "gift0"
	light_impact_range = 6

/obj/item/explosive/grenade/gift/Initialize(mapload)
	. = ..()
	icon_state = "gift[rand(0,10)]"
	item_state = icon_state
	hud_state = icon_state
	icon_state_mini = icon_state

/obj/item/explosive/grenade/gift/attack_self(mob/user)
	if(HAS_TRAIT(user, TRAIT_SANTA_CLAUS)) //santa uses the present as a grenade
		to_chat(user, "This present is now live, toss it at somebody naughty!")
		. = ..()
	else //anyone else opening the present gets an explosion, yes this also affects elves
		explosion(loc, light_impact_range = src.light_impact_range, weak_impact_range = src.weak_impact_range)
		qdel(src)

/obj/item/explosive/grenade/gift/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_SANTA_CLAUS))
		. += "This present is rigged to blow! Activate it yourself to throw it like a grenade, or give it to somebody on the naughty list and watch it blow up in their face."
	if(HAS_TRAIT(user, TRAIT_CHRISTMAS_ELF))
		. += "One of the boss' presents, this one is explosive and will go off if you open it."


/obj/item/a_gift
	name = "gift"
	desc = "A wrapped bundle of joy, you'll have to get closer to see who it's addressed to."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift0"
	resistance_flags = RESIST_ALL
	///if true the present can be opened by anybody
	var/freepresent = FALSE
	///who is the present addressed to?
	var/mob/living/carbon/human/present_receiver = null
	///item contained in this gift
	var/obj/item/contains_type
	///real name of the present receiver
	var/present_receiver_name = null
	///is santa the giver of this present?
	var/is_santa_present = FALSE

/obj/item/a_gift/santa
	is_santa_present = TRUE

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "gift[rand(0,10)]"

	contains_type = get_gift_type()

/obj/item/a_gift/examine(mob/user)
	. = ..()
	if(present_receiver)
		. += "This present is addressed to [present_receiver_name]."

/obj/item/a_gift/attack_self(mob/M)
	if(HAS_TRAIT(M, TRAIT_SANTA_CLAUS) || HAS_TRAIT(M, TRAIT_CHRISTMAS_ELF))
		to_chat(M, "You're supposed to deliver presents, not open them.")
		return
	if(present_receiver == null && !freepresent)
		get_recipient() //generate owner of gift
	to_chat(M, span_warning("You start unwrapping the present, trying to locate any sign of who the present belongs to..."))
	if(!do_after(M, 4 SECONDS))
		return
	if(!freepresent && present_receiver != M)
		switch(tgui_alert(M, "This present is addressed to [present_receiver_name]. Open it anyways?", "Continue?", list("Yes", "No")))
			if("Yes")
				M.visible_message(span_notice("[M] tears into [present_receiver_name]'s gift with reckless abandon!"))
				M.balloon_alert_to_viewers("Open's [present_receiver_name]'s gift" ,ignored_mobs = M)
				log_game("[M] has opened a present that belonged to [present_receiver_name] at [AREACOORD(loc)]")
				if(prob(70) || HAS_TRAIT(M, TRAIT_CHRISTMAS_GRINCH))
					GLOB.round_statistics.presents_grinched += 1
					if(!HAS_TRAIT(M, TRAIT_CHRISTMAS_GRINCH))
						GLOB.round_statistics.number_of_grinches += 1
						ADD_TRAIT(M, TRAIT_CHRISTMAS_GRINCH, TRAIT_CHRISTMAS_GRINCH) //bad present openers are effectively cursed to receive nothing but coal for the rest of the round
						to_chat(M, span_boldannounce("Your heart feels three sizes smaller..."))
						M.color = COLOR_LIME
					spawnpresent(M) //they have the grinch trait, the presents will always spawn coal
				else
					spawnpresent(M, TRUE) //they got lucky, the present will open as normal but with a STOLEN label in the desc
				qdel(src)
			else
				return

	qdel(src)
	spawnpresent(M)

/obj/item/a_gift/proc/get_recipient(mob/M)
	var/list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED))
	var/list/eligible_targets = list()
	for(var/z in z_levels)
		for(var/i in GLOB.alive_human_list)
			var/mob/living/carbon/human/potential_gift_receiver = i
			if(!istype(potential_gift_receiver) || !potential_gift_receiver.client)
				continue
			eligible_targets += potential_gift_receiver
	if(!length(eligible_targets))
		freepresent = TRUE //nobody alive, anybody can open it
	present_receiver = (pick(eligible_targets))
	present_receiver_name = present_receiver.real_name //assign real name for maximum readability on examine

/obj/item/a_gift/proc/spawnpresent(mob/M, stolen_gift)
	if(HAS_TRAIT(M, TRAIT_CHRISTMAS_GRINCH))
		var/obj/item/C = new /obj/item/ore/coal(get_turf(M))
		to_chat(M, span_boldannounce("You feel the icy tug of Santa's magic envelop the present before you can open it!"))
		M.put_in_hands(C)
		M.balloon_alert_to_viewers("Received a piece of [C]")
		return
	else
		var/obj/item/I = new contains_type(get_turf(M))
		log_game("[M] has opened a present that contained a [I] at [AREACOORD(loc)]")
		if(QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
			M.balloon_alert_to_viewers("Nothing inside [M]'s gift" ,ignored_mobs = M)
			M.balloon_alert(M, "Nothing inside")
			return
		if(!freepresent)
			if(is_santa_present)
				GLOB.round_statistics.santa_presents_delivered += 1
			GLOB.round_statistics.presents_delivered += 1
		if(!stolen_gift)
			I.desc += " Property of [M.real_name]."
		else
			I.color = pick(COLOR_SOFT_RED, COLOR_GREEN, COLOR_LIME, COLOR_RED_LIGHT)
			I.desc += " The word 'STOLEN' is visible in bright red and green ink."
		M.balloon_alert_to_viewers("Found a [I]")
		M.put_in_hands(I)

/obj/item/a_gift/proc/get_gift_type()
	var/gift_type_list = list(/obj/item/weapon/claymore/mercsword/commissar_sword,
		/obj/item/weapon/holo/esword,
		/obj/item/toy/sword,
		/obj/item/weapon/claymore,
		/obj/item/toy/dice/d20,
		/obj/item/toy/plush/rouny,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/syndicateballoon,
		/obj/item/storage/wallet,
		/obj/item/storage/wallet/random,
		/obj/item/megaphone,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/tool/soap/deluxe,
		/obj/item/tool/pickaxe/diamond,
		/obj/item/tool/pen/invisible,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/corncob,
		/obj/item/spacecash/c500,
		/obj/item/spacecash/c100,
		/obj/item/coin/diamond,
		/obj/item/ashtray,
		/obj/item/clothing/head/boonie,
		/obj/item/clothing/head/beaverhat,
		/obj/item/clothing/head/cakehat,
		/obj/item/clothing/head/cardborg,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/head/cat,
		/obj/item/clothing/head/powdered_wig,
		/obj/item/clothing/head/xenos,
		/obj/item/clothing/mask/cigarette/pipe/cobpipe,
		/obj/item/book/manual/chef_recipes,
		/obj/item/clothing/head/helmet/space/santahat,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/card/id/syndicate_command,
		/obj/item/clothing/head/helmet/space/syndicate/black/red,
		/obj/item/clothing/suit/space/syndicate/black/red,
		/obj/item/clothing/suit/xenos,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/tool/shovel/etool,
		/obj/item/stack/barbed_wire/small_stack,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/mask/facehugger/lamarr,
		/obj/item/clothing/tie/horrible,
		/obj/item/card/emag_broken,
		/obj/item/tweezers,
		/obj/item/taperecorder,
		/obj/item/tool/pickaxe/plasmacutter,
		/obj/item/clothing/suit/poncho,
		/obj/item/clothing/suit/poncho/green,
		/obj/item/clothing/suit/poncho/red,
		/obj/item/toy/crossbow,
		/obj/item/weapon/nullrod,
		/obj/item/pinpointer,
		/obj/item/blueprints,
		/obj/item/a_gift/anything,
		/obj/item/toy/prize/durand,
		/obj/item/stack/sheet/mineral/phoron/small_stack,
		/obj/item/stack/sheet/metal/small_stack,
		/obj/item/jetpack_marine,
		/obj/item/phone,
		/obj/item/binoculars,
		/obj/item/clock,
		/obj/item/bananapeel,
		/obj/item/staff,
		/obj/item/staff/broom,
		/obj/item/skub,
		/obj/item/ectoplasm,
		/obj/item/tool/multitool,
		/obj/item/lightreplacer,
		/obj/item/stack/sheet/plasteel/small_stack,
		/obj/item/ore/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy)
	gift_type_list += subtypesof(/obj/item/cell)
	gift_type_list += subtypesof(/obj/item/explosive/grenade)
	gift_type_list += subtypesof(/obj/item/clothing/gloves)
	gift_type_list += subtypesof(/obj/item/clothing/mask)
	gift_type_list += subtypesof(/obj/item/reagent_containers/food)
	gift_type_list += subtypesof(/obj/item/reagent_containers/spray)
	gift_type_list += subtypesof(/obj/item/reagent_containers/blood)
	gift_type_list += subtypesof(/obj/item/tool)
	gift_type_list += subtypesof(/obj/item/organ)
	gift_type_list += subtypesof(/obj/item/research_resource)
	gift_type_list += subtypesof(/obj/item/research_product)
	gift_type_list += subtypesof(/obj/item/stack/pipe_cleaner_coil)
	gift_type_list += subtypesof(/obj/item/stack/sheet/animalhide)
	gift_type_list += subtypesof(/obj/item/stack/sheet/mineral)
	gift_type_list += subtypesof(/obj/item/robot_parts)
	gift_type_list += subtypesof(/obj/item/seeds)
	gift_type_list += subtypesof(/obj/item/stock_parts)
	gift_type_list += subtypesof(/obj/item/storage/pill_bottle) - /obj/item/reagent_containers/pill/adminordrazine - /obj/item/reagent_containers/pill/russian_red
	gift_type_list += subtypesof(/obj/item/storage/toolbox)
	gift_type_list += subtypesof(/obj/item/reagent_containers/glass)
	gift_type_list += subtypesof(/obj/item/reagent_containers/pill)
	gift_type_list += subtypesof(/obj/item/tank)
	gift_type_list += subtypesof(/obj/item/trash)
	gift_type_list += subtypesof(/obj/item/instrument)
	gift_type_list += subtypesof(/obj/item/paper)
	gift_type_list += subtypesof(/obj/item/weapon/gun/flamer)
	gift_type_list += subtypesof(/obj/item/portable_vendor)
	gift_type_list += subtypesof(/obj/item/storage/fancy)
	gift_type_list += subtypesof(/obj/item/storage/holster)
	gift_type_list += subtypesof(/obj/item/storage/syringe_case)
	gift_type_list += subtypesof(/obj/item/shard)
	gift_type_list += subtypesof(/obj/item/minerupgrade)
	gift_type_list += subtypesof(/obj/item/weapon/shield)
	gift_type_list += subtypesof(/obj/item/weapon/claymore)
	gift_type_list += subtypesof(/obj/item/bedsheet)
	gift_type_list += subtypesof(/obj/item/assembly)
	gift_type_list += subtypesof(/obj/item/book)
	gift_type_list += subtypesof(/obj/item/cell)
	gift_type_list += subtypesof(/obj/item/ammo_magazine)
	gift_type_list += subtypesof(/obj/item/weapon/twohanded)
	gift_type_list += subtypesof(/obj/item/circuitboard)
	gift_type_list += subtypesof(/obj/item/armor_module/module)
	gift_type_list += subtypesof(/obj/item/armor_module/storage)
	gift_type_list += subtypesof(/obj/item/clothing/mask/cigarette)
	gift_type_list += subtypesof(/obj/item/clothing/head/wizard)
	gift_type_list += subtypesof(/obj/item/clothing/head/hardhat)
	gift_type_list += subtypesof(/obj/item/clothing/head/soft)
	gift_type_list += subtypesof(/obj/item/clothing/head/surgery)
	gift_type_list += subtypesof(/obj/item/clothing/head/tgmcberet)
	gift_type_list += subtypesof(/obj/item/clothing/head/helmet/space)
	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/clothing/head/beret)
	gift_type_list += subtypesof(/obj/item/clothing/head/bio_hood)
	gift_type_list += subtypesof(/obj/item/clothing/glasses/sunglasses) - /obj/item/clothing/glasses/sunglasses/sa - /obj/item/clothing/glasses/sunglasses/sa/nodrop
	gift_type_list += subtypesof(/obj/item/clothing/under) - /obj/item/clothing/under/acj - /obj/item/clothing/under/spec_operative
	gift_type_list += subtypesof(/obj/item/circuitboard/computer)
	gift_type_list += subtypesof(/obj/item/attachable)
	gift_type_list += subtypesof(/obj/item/bodybag)
	gift_type_list += subtypesof(/obj/item/encryptionkey)
	gift_type_list += subtypesof(/obj/item/flashlight)
	gift_type_list += subtypesof(/obj/item/frame)
	gift_type_list += subtypesof(/obj/item/implant)
	gift_type_list += subtypesof(/obj/item/implanter)
	gift_type_list += subtypesof(/obj/item/mortal_shell)
	gift_type_list += subtypesof(/obj/item/ore)
	gift_type_list += subtypesof(/obj/item/storage/backpack)
	var/gift_type = pick(gift_type_list)

	return gift_type


/obj/item/a_gift/anything
	name = "christmas gift"
	desc = "It could be anything!"
	freepresent = TRUE

/obj/item/a_gift/anything/get_gift_type()
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		GLOB.possible_gifts = gift_types_list
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type

/obj/item/a_gift/free
	freepresent = TRUE
