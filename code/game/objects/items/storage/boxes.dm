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
	foldable = /obj/item/paper/crumpled
	storage_slots = null
	max_w_class = 2 //Changed because of in-game abuse
	w_class = 4 //Changed becuase of in-game abuse
	var/spawn_type
	var/spawn_number

/obj/item/storage/box/Initialize(mapload, ...)
	if(spawn_type)
		can_hold = list(spawn_type) // must be set before parent init for typecacheof
	. = ..()
	if(spawn_type)
		for(var/i in 1 to spawn_number)
			new spawn_type(src)

/obj/item/storage/box/survival
	w_class = 3

/obj/item/storage/box/survival/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/emergency_oxygen( src )

/obj/item/storage/box/engineer/Initialize(mapload, ...)
	. = ..()
	new /obj/item/clothing/mask/breath( src )
	new /obj/item/tank/emergency_oxygen/engi( src )

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	spawn_type = /obj/item/clothing/gloves/latex
	spawn_number = 7
	w_class = 2

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	spawn_type = /obj/item/clothing/mask/surgical
	spawn_number = 7
	w_class = 2

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	spawn_type = /obj/item/reagent_container/syringe
	spawn_number = 7
	icon_state = "syringe"
	w_class = 2

/obj/item/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"
	spawn_type = /obj/item/reagent_container/glass/beaker
	spawn_number = 7
	w_class = 3

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors it seems."
	spawn_type = /obj/item/dnainjector/h2m
	spawn_number = 6
	w_class = 3

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"
	spawn_type = /obj/item/explosive/grenade/flashbang
	spawn_number = 7
	w_class = 3

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"
	spawn_type = /obj/item/explosive/grenade/empgrenade
	spawn_number = 5

/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	icon_state = "implant"

/obj/item/storage/box/trackimp/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to 4)
		new /obj/item/implantcase/tracking(src)
	new /obj/item/implanter(src)
	new /obj/item/implantpad(src)
	new /obj/item/device/locator(src)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"

/obj/item/storage/box/chemimp/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to 5)
		new /obj/item/implantcase/chem(src)
	new /obj/item/implanter(src)
	new /obj/item/implantpad(src)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	spawn_type = /obj/item/clothing/glasses/regular
	spawn_number = 7
	w_class = 3

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	spawn_type = /obj/item/reagent_container/food/drinks/drinkingglass
	spawn_number = 6

/obj/item/storage/box/cdeathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

/obj/item/storage/box/cdeathalarm_kit/Initialize(mapload, ...)
	. = ..()
	new /obj/item/implanter(src)
	for(var/i in 1 to 6)
		new /obj/item/implantcase/death_alarm(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	spawn_type = /obj/item/reagent_container/food/condiment
	spawn_number = 6

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	spawn_type = /obj/item/reagent_container/food/drinks/sillycup
	spawn_number = 7

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	spawn_type = /obj/item/reagent_container/food/snacks/donkpocket
	spawn_number = 6
	w_class = 3

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/items/food.dmi'
	icon_state = "monkeycubebox"
	spawn_type = /obj/item/reagent_container/food/snacks/monkeycube/wrapped
	spawn_number = 5

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	spawn_type = /obj/item/reagent_container/food/snacks/monkeycube/wrapped/farwacube

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	spawn_type = /obj/item/reagent_container/food/snacks/monkeycube/wrapped/stokcube

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	spawn_type = /obj/item/reagent_container/food/snacks/monkeycube/wrapped/neaeracube

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	spawn_type = /obj/item/card/id
	spawn_number = 7

/obj/item/storage/box/handcuffs
	name = "box of handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	spawn_type = /obj/item/handcuffs
	spawn_number = 7

/obj/item/storage/box/zipcuffs
	name = "box of zip cuffs"
	desc = "A box full of zip cuffs."
	icon_state = "handcuff"
	spawn_type = /obj/item/handcuffs/zip
	spawn_number = 14

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"
	spawn_type = /obj/item/device/assembly/mousetrap
	spawn_number = 6

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	spawn_type = /obj/item/storage/pill_bottle
	spawn_number = 7

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/items/toy.dmi'
	icon_state = "spbox"
	max_storage_space = 8
	spawn_type = /obj/item/toy/snappop
	spawn_number = 8

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = 1
	flags_equip_slot = ITEM_SLOT_BELT
	spawn_type = /obj/item/tool/match
	spawn_number = 14

/obj/item/storage/box/matches/attackby(obj/item/tool/match/W as obj, mob/user as mob)
	if(istype(W) && !W.heat_source && !W.burnt)
		W.light_match()
		return TRUE
	return ..()

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	spawn_type = /obj/item/reagent_container/hypospray/autoinjector/tricordrazine
	spawn_number = 7

/obj/item/storage/box/quickclot
	name = "box of quick-clot injectors"
	desc = "Contains quick-clot autoinjectors."
	icon_state = "syringe"
	spawn_type = /obj/item/reagent_container/hypospray/autoinjector/quickclot
	spawn_number = 7

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	max_storage_space = 42	//holds 21 items of w_class 2
	use_to_pickup = 1 // for picking up broken bulbs, not that most people will try
	spawn_type = /obj/item/light_bulb/bulb
	spawn_number = 21

/obj/item/storage/box/lights/bulbs // mapping placeholder

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"
	w_class = 3
	spawn_type = /obj/item/light_bulb/tube/large
	spawn_number = 21

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"
	can_hold = list(
		/obj/item/light_bulb/tube/large,
		/obj/item/light_bulb/bulb)

/obj/item/storage/box/lights/mixed/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to 14)
		new /obj/item/light_bulb/tube/large(src)
	for(var/i in 1 to 7)
		new /obj/item/light_bulb/bulb(src)





////////// MARINES BOXES //////////////////////////


/obj/item/storage/box/explosive_mines
	name = "\improper M20 mine box"
	desc = "A secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	w_class = 3
	max_storage_space = 8
	spawn_type = /obj/item/explosive/mine
	spawn_number = 5

/obj/item/storage/box/explosive_mines/pmc
	name = "\improper M20P mine box"
	spawn_type = /obj/item/explosive/mine/pmc
	spawn_number = 5

/obj/item/storage/box/m94
	name = "\improper M40 FLDP flare pack"
	desc = "A packet of five M40 FLDP Flares. Carried by TGMC soldiers to light dark areas that cannot be reached with the usual TNR Shoulder Lamp. Can be launched from an underslung grenade launcher."
	icon_state = "m94"
	w_class = 3
	max_storage_space = 10
	spawn_type = /obj/item/explosive/grenade/flare
	spawn_number = 5

/obj/item/storage/box/m94/update_icon()
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
	max_storage_space = 50
	spawn_type = /obj/item/explosive/grenade/frag
	spawn_number = 25
	var/nade_box_icon

/obj/item/storage/box/nade_box/update_icon()
	if(!contents.len)
		icon_state = "[nade_box_icon]_e"
	else
		icon_state = nade_box_icon


/obj/item/storage/box/nade_box/training
	name = "\improper M07 training grenade box"
	desc = "A secure box holding 25 M07 training grenades. Harmless and reusable."
	icon_state = "train_nade_placeholder"
	spawn_type = /obj/item/explosive/grenade/frag/training

/obj/item/storage/box/nade_box/HIDP
	name = "\improper HIDP incendiary grenade box"
	desc = "A secure box holding 25 incendiary grenades. Warning: highly flammable!!."
	icon_state = "HIDP_nade_placeholder"
	storage_slots = 15
	max_storage_space = 30
	spawn_type = /obj/item/explosive/grenade/incendiary
	spawn_number = 15

/obj/item/storage/box/nade_box/M15
	name = "\improper M15 grenade box"
	desc = "A secure box holding M15 fragmentation grenades."
	icon_state = "M15_nade_placeholder"
	storage_slots = 15
	max_storage_space = 30
	spawn_type = /obj/item/explosive/grenade/frag/m15
	spawn_number = 15

/obj/item/storage/box/nade_box/tear_gas
	name = "\improper M66 tear gas grenade box"
	desc = "A secure box holding 25 M66 tear gas grenades. Used for riot control."
	icon_state = "teargas_nade_placeholder"
	spawn_type = /obj/item/explosive/grenade/chem_grenade/teargas

/obj/item/storage/box/nade_box/impact
	name = "\improper M40 IMDP grenade box"
	desc = "A secure box holding 25 M40 IMDP impact grenades. High explosive, don't store near the flamer fuel."
	icon_state = "nade_placeholder"
	spawn_type = /obj/item/explosive/grenade/impact


//ITEMS-----------------------------------//
/obj/item/storage/box/lightstick
	name = "box of lightsticks"
	desc = "Contains blue lightsticks."
	icon_state = "lightstick"
	spawn_type = /obj/item/lightstick
	spawn_number = 7

/obj/item/storage/box/lightstick/red
	desc = "Contains red lightsticks."
	icon_state = "lightstick2"
	spawn_type = /obj/item/lightstick/red
	spawn_number = 7


/obj/item/storage/box/MRE
	name = "\improper TGMC MRE"
	desc = "Meal Ready-to-Eat, meant to be consumed in the field, and has an expiration that is two decades past a marine's average combat life expectancy."
	icon_state = "mealpack"
	w_class = 2
	can_hold = list()
	storage_slots = 4
	max_w_class = 0
	foldable = 0
	var/isopened = 0

/obj/item/storage/box/MRE/Initialize()
	. = ..()
	pickflavor()

/obj/item/storage/box/MRE/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		new /obj/item/trash/mre(T)
	return ..()

/obj/item/storage/box/MRE/proc/pickflavor()
	var/entree = pick("boneless pork ribs", "grilled chicken", "pizza square", "spaghetti", "chicken tenders")
	var/side = pick("meatballs", "cheese spread", "beef turnover", "mashed potatoes")
	var/snack = pick("biscuit", "pretzels", "peanuts", "cracker")
	var/desert = pick("spiced apples", "chocolate brownie", "sugar cookie", "choco bar", "crayon")
	name = "[initial(name)] ([entree])"
	new /obj/item/reagent_container/food/snacks/packaged_meal(src, entree)
	new /obj/item/reagent_container/food/snacks/packaged_meal(src, side)
	new /obj/item/reagent_container/food/snacks/packaged_meal(src, snack)
	new /obj/item/reagent_container/food/snacks/packaged_meal(src, desert)

/obj/item/storage/box/MRE/remove_from_storage()
	. = ..()
	if(. && !contents.len && !gc_destroyed)
		qdel(src)

/obj/item/storage/box/MRE/update_icon()
	if(!isopened)
		isopened = 1
		icon_state = "mealpackopened"
