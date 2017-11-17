/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 *
 *  EDITED BY APOPHIS 09OCT2015 to prevent in-game abuse of boxes.
 */



/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
//	foldable = /obj/item/stack/sheet/cardboard	//Changed because of in-game abuse
	foldable = /obj/item/paper/crumpled
	storage_slots = null
	max_w_class = 2 //Changed because of in-game abuse
	w_class = 4 //Changed becuase of in-game abuse

/obj/item/storage/box/survival/
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath( src )
		new /obj/item/tank/emergency_oxygen( src )
		w_class = 3
		return

/obj/item/storage/box/engineer/
	New()
		..()
		contents = list()
		sleep(1)
		new /obj/item/clothing/mask/breath( src )
		new /obj/item/tank/emergency_oxygen/engi( src )
		return


/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	can_hold = list("/obj/item/clothing/gloves/latex")
	w_class = 2


	New()
		..()
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)
		new /obj/item/clothing/gloves/latex(src)

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	can_hold = list("/obj/item/clothing/mask/surgical")
	w_class = 2

	New()
		..()
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/mask/surgical(src)


/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	can_hold = list("/obj/item/reagent_container/syringe")
	icon_state = "syringe"
	w_class = 2

	New()
		..()
		new /obj/item/reagent_container/syringe( src )
		new /obj/item/reagent_container/syringe( src )
		new /obj/item/reagent_container/syringe( src )
		new /obj/item/reagent_container/syringe( src )
		new /obj/item/reagent_container/syringe( src )
		new /obj/item/reagent_container/syringe( src )
		new /obj/item/reagent_container/syringe( src )

/obj/item/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"
	can_hold = list("/obj/item/reagent_container/glass/beaker")
	w_class = 3

	New()
		..()
		new /obj/item/reagent_container/glass/beaker( src )
		new /obj/item/reagent_container/glass/beaker( src )
		new /obj/item/reagent_container/glass/beaker( src )
		new /obj/item/reagent_container/glass/beaker( src )
		new /obj/item/reagent_container/glass/beaker( src )
		new /obj/item/reagent_container/glass/beaker( src )
		new /obj/item/reagent_container/glass/beaker( src )

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."
	can_hold = list("/obj/item/dnainjector")
	w_class = 3

	New()
		..()
		new /obj/item/dnainjector/h2m(src)
		new /obj/item/dnainjector/h2m(src)
		new /obj/item/dnainjector/h2m(src)
		new /obj/item/dnainjector/m2h(src)
		new /obj/item/dnainjector/m2h(src)
		new /obj/item/dnainjector/m2h(src)
/*

/obj/item/storage/box/blanks
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."

	New()
		..()
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)
		new /obj/item/ammo_casing/shotgun/blank(src)

/obj/item/storage/box/beanbags
	name = "box of beanbag shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	can_hold = list("/obj/item/ammo_casing/shotgun/beanbag")
	w_class = 2
	New()
		..()
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/storage/box/shotgunammo
	name = "box of shotgun shells"
	desc = "It has a picture of a gun and several warning symbols on the front.<br>WARNING: Live ammunition. Misuse may result in serious injury or death."
	icon_state = "shells"
	New()
		..()
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
		new /obj/item/ammo_casing/shotgun(src)
*/
/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"
	can_hold = list("/obj/item/explosive/grenade/flashbang")
	w_class = 3
	New()
		..()
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/explosive/grenade/flashbang(src)
		new /obj/item/explosive/grenade/flashbang(src)

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"

	New()
		..()
		new /obj/item/explosive/grenade/empgrenade(src)
		new /obj/item/explosive/grenade/empgrenade(src)
		new /obj/item/explosive/grenade/empgrenade(src)
		new /obj/item/explosive/grenade/empgrenade(src)
		new /obj/item/explosive/grenade/empgrenade(src)


/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

	New()
		..()
		new /obj/item/implantcase/tracking(src)
		new /obj/item/implantcase/tracking(src)
		new /obj/item/implantcase/tracking(src)
		new /obj/item/implantcase/tracking(src)
		new /obj/item/implanter(src)
		new /obj/item/implantpad(src)
		new /obj/item/device/locator(src)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

	New()
		..()
		new /obj/item/implantcase/chem(src)
		new /obj/item/implantcase/chem(src)
		new /obj/item/implantcase/chem(src)
		new /obj/item/implantcase/chem(src)
		new /obj/item/implantcase/chem(src)
		new /obj/item/implanter(src)
		new /obj/item/implantpad(src)



/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	can_hold = list("/obj/item/clothing/glasses/regular")
	w_class = 3

	New()
		..()
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

	New()
		..()
		new /obj/item/reagent_container/food/drinks/drinkingglass(src)
		new /obj/item/reagent_container/food/drinks/drinkingglass(src)
		new /obj/item/reagent_container/food/drinks/drinkingglass(src)
		new /obj/item/reagent_container/food/drinks/drinkingglass(src)
		new /obj/item/reagent_container/food/drinks/drinkingglass(src)
		new /obj/item/reagent_container/food/drinks/drinkingglass(src)

/obj/item/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

	New()
		..()
		new /obj/item/implanter(src)
		new /obj/item/implantcase/death_alarm(src)
		new /obj/item/implantcase/death_alarm(src)
		new /obj/item/implantcase/death_alarm(src)
		new /obj/item/implantcase/death_alarm(src)
		new /obj/item/implantcase/death_alarm(src)
		new /obj/item/implantcase/death_alarm(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

	New()
		..()
		new /obj/item/reagent_container/food/condiment(src)
		new /obj/item/reagent_container/food/condiment(src)
		new /obj/item/reagent_container/food/condiment(src)
		new /obj/item/reagent_container/food/condiment(src)
		new /obj/item/reagent_container/food/condiment(src)
		new /obj/item/reagent_container/food/condiment(src)



/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	New()
		..()
		new /obj/item/reagent_container/food/drinks/sillycup( src )
		new /obj/item/reagent_container/food/drinks/sillycup( src )
		new /obj/item/reagent_container/food/drinks/sillycup( src )
		new /obj/item/reagent_container/food/drinks/sillycup( src )
		new /obj/item/reagent_container/food/drinks/sillycup( src )
		new /obj/item/reagent_container/food/drinks/sillycup( src )
		new /obj/item/reagent_container/food/drinks/sillycup( src )


/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	can_hold = list("/obj/item/reagent_container/food/snacks")
	w_class = 3

	New()
		..()
		new /obj/item/reagent_container/food/snacks/donkpocket(src)
		new /obj/item/reagent_container/food/snacks/donkpocket(src)
		new /obj/item/reagent_container/food/snacks/donkpocket(src)
		new /obj/item/reagent_container/food/snacks/donkpocket(src)
		new /obj/item/reagent_container/food/snacks/donkpocket(src)
		new /obj/item/reagent_container/food/snacks/donkpocket(src)

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/items/food.dmi'
	icon_state = "monkeycubebox"
	can_hold = list("/obj/item/reagent_container/food/snacks/monkeycube")
	New()
		..()
		if(src.type == /obj/item/storage/box/monkeycubes)
			for(var/i = 1; i <= 5; i++)
				new /obj/item/reagent_container/food/snacks/monkeycube/wrapped(src)

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/reagent_container/food/snacks/monkeycube/wrapped/farwacube(src)

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/reagent_container/food/snacks/monkeycube/wrapped/stokcube(src)

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	New()
		..()
		for(var/i = 1; i <= 5; i++)
			new /obj/item/reagent_container/food/snacks/monkeycube/wrapped/neaeracube(src)

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	can_hold = list("/obj/item/card/id")

	New()
		..()
		new /obj/item/card/id(src)
		new /obj/item/card/id(src)
		new /obj/item/card/id(src)
		new /obj/item/card/id(src)
		new /obj/item/card/id(src)
		new /obj/item/card/id(src)
		new /obj/item/card/id(src)


/obj/item/storage/box/seccarts
	name = "box of spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon_state = "pda"

	New()
		..()
		new /obj/item/cartridge/security(src)
		new /obj/item/cartridge/security(src)
		new /obj/item/cartridge/security(src)
		new /obj/item/cartridge/security(src)
		new /obj/item/cartridge/security(src)
		new /obj/item/cartridge/security(src)
		new /obj/item/cartridge/security(src)


/obj/item/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	can_hold = list("/obj/item/handcuffs")

	New()
		..()
		new /obj/item/handcuffs(src)
		new /obj/item/handcuffs(src)
		new /obj/item/handcuffs(src)
		new /obj/item/handcuffs(src)
		new /obj/item/handcuffs(src)
		new /obj/item/handcuffs(src)
		new /obj/item/handcuffs(src)


/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"

	New()
		..()
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )
		new /obj/item/device/assembly/mousetrap( src )

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	can_hold = list("/obj/item/storage/pill_bottle")

	New()
		..()
		new /obj/item/storage/pill_bottle( src )
		new /obj/item/storage/pill_bottle( src )
		new /obj/item/storage/pill_bottle( src )
		new /obj/item/storage/pill_bottle( src )
		new /obj/item/storage/pill_bottle( src )
		new /obj/item/storage/pill_bottle( src )
		new /obj/item/storage/pill_bottle( src )


/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/items/toy.dmi'
	icon_state = "spbox"
	max_storage_space = 8
	can_hold = list("/obj/item/toy/snappop")
	New()
		..()
		for(var/i=1; i <= 8; i++)
			new /obj/item/toy/snappop(src)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = 1
	flags_equip_slot = SLOT_WAIST
	can_hold = list("/obj/item/tool/match")

	New()
		..()
		for(var/i=1; i <= 14; i++)
			new /obj/item/tool/match(src)

	attackby(obj/item/tool/match/W as obj, mob/user as mob)
		if(istype(W) && !W.heat_source && !W.burnt)
			W.light_match()

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	can_hold = list("/obj/item/reagent_container/hypospray/autoinjector")
	New()
		..()
		for (var/i; i < 7; i++)
			new /obj/item/reagent_container/hypospray/autoinjector/tricord(src)

/obj/item/storage/box/quickclot
	name = "box of quickclot injectors"
	desc = "Contains quickclot autoinjectors."
	icon_state = "syringe"
	can_hold = list("/obj/item/reagent_container/hypospray/autoinjector")
	New()
		..()
		for (var/i; i < 7; i++)
			new /obj/item/reagent_container/hypospray/autoinjector/quickclot(src)

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	can_hold = list("/obj/item/light_bulb/tube", "/obj/item/light_bulb/bulb")
	max_storage_space = 42	//holds 21 items of w_class 2
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try

/obj/item/storage/box/lights/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/light_bulb/bulb(src)

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"
	w_class = 3

/obj/item/storage/box/lights/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/light_bulb/tube/large(src)

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"

/obj/item/storage/box/lights/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/light_bulb/tube/large(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/light_bulb/bulb(src)





////////// MARINES BOXES //////////////////////////


/obj/item/storage/box/explosive_mines
	name = "\improper M20 mine box"
	desc = "A secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	w_class = 3
	max_storage_space = 8
	can_hold = list(
		"/obj/item/explosive/mine"
		)

	New()
		..()
		contents = list()
		sleep(1)
		var/I = type == /obj/item/storage/box/explosive_mines/pmc ? /obj/item/explosive/mine/pmc : /obj/item/explosive/mine
		var/i = 0
		while(++i < 5)
			new I(src)

/obj/item/storage/box/explosive_mines/pmc
	name = "\improper M20P mine box"

/obj/item/storage/box/m94
	name = "\improper M94 marking flare pack"
	desc = "A packet of five M94 Marking Flares. Carried by USCM soldiers to light dark areas that cannot be reached with the usual TNR Shoulder Lamp."
	icon_state = "m94"
	w_class = 3
	max_storage_space = 10
	can_hold = list(
		"/obj/item/device/flashlight/flare"
		)

	New()
		..()
		contents = list()
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		new /obj/item/device/flashlight/flare(src)
		return

	update_icon()
		if(!contents.len)
			icon_state = "m94_e"
		else
			icon_state = "m94"

/obj/item/storage/box/nade_box
	name = "\improper M40 HEDP grenade box"
	desc = "A secure box holding 25 M40 HEDP grenades. High explosive, don't store near the flamer fuel."
	icon_state = "nade_placeholder"
	w_class = 4
	storage_slots = 25
	var/nade_box_icon
	can_hold = list(
		"/obj/item/explosive/grenade/frag"
		)

	New()
		..()
		contents = list()
		select_gamemode_skin(/obj/item/storage/box/nade_box)
		nade_box_icon = icon_state
		var/i = 0
		while(++i < 25)
			new /obj/item/explosive/grenade/frag(src)

	update_icon()
		if(!contents.len)
			icon_state = "[nade_box_icon]_e"
		else
			icon_state = nade_box_icon
