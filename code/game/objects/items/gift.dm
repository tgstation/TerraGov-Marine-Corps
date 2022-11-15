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
	to_chat(M, span_warning("You start unwrapping the present, trying to locate any sign of who the present belongs to..."))
	if(!do_after(M, 4 SECONDS))
		return
	if(!freepresent && present_receiver != M)
		if(tgui_alert(M, "This present is addressed to [present_receiver]. Open it anyways?", "Continue?", list("Yes", "No")) != "No")
			M.visible_message(span_notice("[M] tears into [present_receiver]'s gift with reckless abandon!"))
			M.balloon_alert_to_viewers("Open's [present_receiver]'s gift" ,ignored_mobs = M)
			if(prob(75))
				GLOB.round_statistics.presents_grinched += 1
				new /obj/item/ore/coal(get_turf(M))
			else
				spawnpresent(M)
			qdel(src)
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

/obj/item/a_gift/proc/spawnpresent(mob/M)
	var/obj/item/I = new contains_type(get_turf(M))
	if(!freepresent)
		GLOB.round_statistics.presents_delivered += 1
	if(!QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
		M.balloon_alert_to_viewers("Found a [I]")
		M.put_in_hands(I)
	else
		M.balloon_alert_to_viewers("Nothing inside [M]'s gift" ,ignored_mobs = M)
		M.balloon_alert(M, "Nothing inside")

/obj/item/a_gift/proc/get_gift_type()
	var/gift_type_list = list(/obj/item/weapon/claymore/mercsword/commissar_sword,
		/obj/item/weapon/claymore/mercsword,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/energy/sword/blue,
		/obj/item/weapon/holo/esword,
		/obj/item/toy/sword,
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
		/obj/item/cell/infinite,
		/obj/item/assembly/mousetrap/armed,
		/obj/item/clothing/glasses/sunglasses/aviator/yellow,
		/obj/item/clothing/head/boonie,
		/obj/item/clothing/mask/cigarette/pipe/cobpipe,
		/obj/item/book/manual/chef_recipes,
		/obj/item/clothing/head/helmet/space/santahat,
		/obj/item/instrument/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/card/id/syndicate_command,
		/obj/item/clothing/head/helmet/space/syndicate/black/red,
		/obj/item/clothing/suit/space/syndicate/black/red,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/instrument/violin,
		/obj/item/tool/shovel/etool,
		/obj/item/instrument/piano_synth,
		/obj/item/instrument/banjo,
		/obj/item/instrument/guitar,
		/obj/item/instrument/glockenspiel,
		/obj/item/instrument/accordion,
		/obj/item/stack/barbed_wire/small_stack,
		/obj/item/instrument/trumpet,
		/obj/item/instrument/saxophone,
		/obj/item/instrument/trombone,
		/obj/item/instrument/recorder,
		/obj/item/instrument/harmonica,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/tie/horrible,
		/obj/item/card/emag_broken,
		/obj/item/tool/pickaxe/plasmacutter,
		/obj/item/clothing/glasses/night/imager_goggles,
		/obj/item/clothing/suit/poncho,
		/obj/item/clothing/suit/poncho/green,
		/obj/item/clothing/suit/poncho/red,
		/obj/item/clothing/suit/costume/snowman,
		/obj/item/clothing/head/snowman,
		/obj/item/toy/crossbow,
		/obj/item/toy/prize/durand,
		/obj/item/stack/sheet/mineral/phoron/small_stack,
		/obj/item/stack/sheet/metal/small_stack,
		/obj/item/stack/sheet/plasteel/small_stack,
		/obj/item/ore/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy) //All toys, except for abstract types and syndicate cards.
	gift_type_list += subtypesof(/obj/item/cell)
	gift_type_list += subtypesof(/obj/item/explosive/grenade)
	gift_type_list += subtypesof(/obj/item/clothing/gloves)
	gift_type_list += subtypesof(/obj/item/clothing/mask)
	var/gift_type = pick(gift_type_list)

	return gift_type


/obj/item/a_gift/anything
	name = "christmas gift"
	desc = "It could be anything!"

/obj/item/a_gift/anything/get_gift_type()
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		GLOB.possible_gifts = gift_types_list
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type

/obj/item/a_gift/free
	freepresent = TRUE
