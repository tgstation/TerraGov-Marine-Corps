/obj/item/gift
	name = "gift"
	desc = "Presents!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"

	var/list/gift_types = list(
		/obj/item/storage/wallet,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/tool/soap/deluxe,
		/obj/item/tool/pickaxe/silver,
		/obj/item/tool/pen/invisible,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/corncob,
		/obj/item/contraband/poster,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/toy/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/katana,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/instrument/violin,
		/obj/item/clothing/tie/horrible)


/obj/item/gift/Initialize(mapload, ...)
	. = ..()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)


/obj/item/gift/ex_act()
	qdel(src)


/obj/item/gift/attack_self(mob/user)
	var/gift_type = pick(gift_types)
	var/obj/item/I = new gift_type
	user.put_in_hands(I)
	qdel(src)


/obj/item/gift/marine
	name = "Present"
	desc = "One, standard issue TGMC Present"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"

	var/fancy_chance = 0
	var/fancy_type = 0

	gift_types = list(
		/obj/item/clothing/tie/horrible,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/foldable/bipod,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope,
	)


/obj/item/gift/marine/Initialize(mapload, ...)
	. = ..()
	fancy_chance = rand(1, 30)
	fancy_type = rand(1, 20)


/obj/item/gift/marine/attack_self(mob/user)
	if(!prob(fancy_chance))
		return ..()

	var/gift_type
	var/gift_message

	switch(fancy_type)
		if(1)
			gift_message = span_notice("It's a brand new, un-restricted, THERMOBARIC ROCKET LAUNCHER!  What are the chances?")
			gift_type = /obj/item/weapon/gun/launcher/rocket/m57a4/xmas
		if(10)
			gift_message = span_notice("It's a brand new, un-restricted, ANTI-MATERIAL SNIPER RIFLE!  What are the chances?")
			gift_type = /obj/item/weapon/gun/rifle/sniper/elite/xmas
		if(20)
			gift_message = span_notice("Just what the fuck is it?")
			gift_type = /obj/item/clothing/mask/facehugger/lamarr
		else
			gift_message = span_notice("It's a REAL gift!")
			gift_type = pick(
			/obj/item/weapon/gun/revolver/mateba,
			/obj/item/weapon/gun/pistol/heavy,
			/obj/item/weapon/claymore,
			/obj/item/weapon/energy/sword/green,
			/obj/item/weapon/energy/sword/red,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/burstfire_assembly,
			)

	to_chat(user, gift_message)
	var/obj/item/I = new gift_type
	user.put_in_hands(I)
	qdel(src)


/obj/item/weapon/gun/launcher/rocket/m57a4/xmas
	flags_gun_features = NONE


/obj/item/weapon/gun/launcher/rocket/m57a4/xmas/able_to_fire(mob/living/user)
	var/turf/current_turf = get_turf(user)
	if(is_mainship_level(current_turf.z))
		balloon_alert(user, "Can't fire")
		return FALSE
	return TRUE


/obj/item/weapon/gun/rifle/sniper/elite/xmas
	flags_gun_features = NONE


/obj/item/weapon/gun/rifle/sniper/elite/xmas/able_to_fire(mob/living/user)
	return TRUE


/obj/effect/spresent/relaymove(mob/user)
	if(user.stat != CONSCIOUS)
		return
	to_chat(user, span_notice("You can't move."))


/obj/effect/spresent/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!iswirecutter(I))
		to_chat(user, span_notice("You need wirecutters for that."))
		return

	to_chat(user, span_notice("You cut open the present."))

	for(var/mob/M in src) //Should only be one but whatever.
		M.forceMove(loc)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	qdel(src)



/obj/item/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "wrap_paper"
	var/amount = 20


/obj/item/wrapping_paper/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/a_used = 2 ** (w_class - 1)

	if(!(locate(/obj/structure/table) in loc))
		to_chat(user, span_notice("You must put the paper on a table!"))
		return

	if(I.w_class >= WEIGHT_CLASS_BULKY)
		to_chat(user, span_notice("The object is far too large!"))
		return


	if(!iswirecutter(user.l_hand) && !iswirecutter(user.r_hand))
		to_chat(user, span_notice("You need scissors!"))
		return

	if(amount < a_used)
		to_chat(user, span_notice("You need more paper!"))
		return

	if(istype(I, /obj/item/smallDelivery) || istype(I, /obj/item/gift)) //No gift wrapping gifts!
		return

	if(!user.drop_held_item())
		return

	amount -= a_used
	var/obj/item/gift/G = new(loc)
	G.size = I.w_class
	G.w_class = G.size + 1
	G.icon_state = "gift[G.size]"
	G.gift = I
	I.forceMove(G)

	if(amount <= 0)
		new /obj/item/trash/c_tube(loc)
		qdel(src)


/obj/item/wrapping_paper/examine(mob/user)
	. = ..()
	. += "There is about [amount] square units of paper left!"


/obj/item/wrapping_paper/attack(mob/target, mob/user)
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target

	if(!istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) && H.stat == CONSCIOUS)
		to_chat(user, "They are moving around too much. A straightjacket would help.")
		return

	if(amount <= 2)
		to_chat(user, span_notice("You need more paper."))
		return

	var/obj/effect/spresent/present = new(H.loc)
	amount -= 2

	if(H.client)
		H.client.perspective = EYE_PERSPECTIVE
		H.client.eye = present

	H.forceMove(present)

	log_combat(user, H, "wrapped")
