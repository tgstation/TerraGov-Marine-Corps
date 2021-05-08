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

#define BOX_OVERLAY_SHIFT_X 6
#define BOX_OVERLAY_SHIFT_Y 4 //one less than the 6x5 sprite to make them overlap on each other a bit.


/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/paper/crumpled
	storage_slots = null
	max_w_class = 2 //Changed because of in-game abuse
	w_class = WEIGHT_CLASS_BULKY //Changed becuase of in-game abuse
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
	w_class = WEIGHT_CLASS_NORMAL

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
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	spawn_type = /obj/item/clothing/mask/surgical
	spawn_number = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	spawn_type = /obj/item/reagent_containers/syringe
	spawn_number = 7
	icon_state = "syringe"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"
	spawn_type = /obj/item/reagent_containers/glass/beaker
	spawn_number = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"
	spawn_type = /obj/item/explosive/grenade/flashbang
	spawn_number = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"
	spawn_type = /obj/item/explosive/grenade/empgrenade
	spawn_number = 5

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	spawn_type = /obj/item/clothing/glasses/regular
	spawn_number = 7
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	spawn_type = /obj/item/reagent_containers/food/drinks/drinkingglass
	spawn_number = 6

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	spawn_type = /obj/item/reagent_containers/food/condiment
	spawn_number = 6

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	spawn_type = /obj/item/reagent_containers/food/drinks/sillycup
	spawn_number = 7

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	spawn_type = /obj/item/reagent_containers/food/snacks/donkpocket
	spawn_number = 6
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/items/food.dmi'
	icon_state = "monkeycubebox"
	spawn_type = /obj/item/reagent_containers/food/snacks/monkeycube/wrapped
	spawn_number = 5

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	spawn_type = /obj/item/reagent_containers/food/snacks/monkeycube/wrapped/farwacube

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	spawn_type = /obj/item/reagent_containers/food/snacks/monkeycube/wrapped/stokcube

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	spawn_type = /obj/item/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	spawn_type = /obj/item/card/id
	spawn_number = 7

/obj/item/storage/box/ids/dogtag
	name = "box of spare Dogtags"
	desc = "Has so many empty Dogtags."
	icon_state = "id"
	spawn_type = /obj/item/card/id/dogtag
	spawn_number = 7

/obj/item/storage/box/handcuffs
	name = "box of handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	spawn_type = /obj/item/restraints/handcuffs
	spawn_number = 7

/obj/item/storage/box/zipcuffs
	name = "box of zip cuffs"
	desc = "A box full of zip cuffs."
	icon_state = "handcuff"
	spawn_type = /obj/item/restraints/handcuffs/zip
	spawn_number = 14

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"
	spawn_type = /obj/item/assembly/mousetrap
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
	w_class = WEIGHT_CLASS_TINY
	flags_equip_slot = ITEM_SLOT_BELT
	spawn_type = /obj/item/tool/match
	spawn_number = 14

/obj/item/storage/box/matches/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tool/match))
		var/obj/item/tool/match/M = I

		if(M.heat || M.burnt)
			return ..()

		if(prob(50))
			playsound(loc, 'sound/items/matchstick_lit.ogg', 15, 1)
			M.light_match()
		else
			playsound(loc, 'sound/items/matchstick_hit.ogg', 15, 1)
		return TRUE
	else
		return ..()

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	spawn_type = /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine
	spawn_number = 7

/obj/item/storage/box/quickclot
	name = "box of quick-clot injectors"
	desc = "Contains quick-clot autoinjectors."
	icon_state = "syringe"
	spawn_type = /obj/item/reagent_containers/hypospray/autoinjector/quickclot
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
	w_class = WEIGHT_CLASS_NORMAL
	spawn_type = /obj/item/light_bulb/tube/large
	spawn_number = 21

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"
	can_hold = list(
		/obj/item/light_bulb/tube/large,
		/obj/item/light_bulb/bulb,
	)

/obj/item/storage/box/lights/mixed/Initialize(mapload, ...)
	. = ..()
	for(var/i in 1 to 14)
		new /obj/item/light_bulb/tube/large(src)
	for(var/i in 1 to 7)
		new /obj/item/light_bulb/bulb(src)

/obj/item/storage/box/trampop
	name = "box of Tram-pops"
	desc = "Maybe if you behave the doctor will reward you with one."
	icon_state = "trampop"
	spawn_type = /obj/item/reagent_containers/food/snacks/lollipop/tramadol
	spawn_number = 14
	w_class = WEIGHT_CLASS_SMALL



////////// MARINES BOXES //////////////////////////


/obj/item/storage/box/explosive_mines
	name = "\improper M20 mine box"
	desc = "A secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 10
	spawn_type = /obj/item/explosive/mine
	spawn_number = 5

/obj/item/storage/box/explosive_mines/update_icon_state()
	icon_state = initial(icon_state)
	if(!length(contents))
		icon_state += "_e"

/obj/item/storage/box/explosive_mines/large
	name = "\improper M20 mine box"
	desc = "A large secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	max_storage_space = 20
	spawn_type = /obj/item/explosive/mine
	spawn_number = 10

/obj/item/storage/box/explosive_mines/pmc
	name = "\improper M20P mine box"
	spawn_type = /obj/item/explosive/mine/pmc

/obj/item/storage/box/m94
	name = "\improper M40 FLDP flare pack"
	desc = "A packet of seven M40 FLDP Flares. Carried by TGMC soldiers to light dark areas that cannot be reached with the usual TNR Shoulder Lamp. Can be launched from an underslung grenade launcher."
	icon_state = "m40"
	w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 14
	spawn_type = /obj/item/explosive/grenade/flare
	spawn_number = 7

/obj/item/storage/box/m94/update_icon()
	icon_state = initial(icon_state)
	if(!length(contents))
		icon_state += "_e"

/obj/item/storage/box/m94/cas
	name = "\improper M50 CFDP signal pack"
	desc = "A packet of seven M40 CFPD signal Flares. Used to mark locations for fire support. Can be launched from an underslung grenade launcher."
	icon_state = "m50"
	spawn_type = /obj/item/explosive/grenade/flare/cas


/obj/item/storage/box/nade_box
	name = "\improper M40 HEDP grenade box"
	desc = "A secure box holding 25 M40 HEDP grenades. High explosive, don't store near the flamer fuel."
	icon_state = "nade"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = 25
	max_storage_space = 50
	spawn_type = /obj/item/explosive/grenade/frag
	spawn_number = 25

/obj/item/storage/box/nade_box/update_icon_state()
	icon_state = initial(icon_state)
	if(!length(contents))
		icon_state += "_e"

/obj/item/storage/box/nade_box/training
	name = "\improper M07 training grenade box"
	desc = "A secure box holding 25 M07 training grenades. Harmless and reusable."
	icon_state = "nade_train"
	spawn_type = /obj/item/explosive/grenade/frag/training

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
	w_class = WEIGHT_CLASS_SMALL
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
	new /obj/item/reagent_containers/food/snacks/packaged_meal(src, entree)
	new /obj/item/reagent_containers/food/snacks/packaged_meal(src, side)
	new /obj/item/reagent_containers/food/snacks/packaged_meal(src, snack)
	new /obj/item/reagent_containers/food/snacks/packaged_meal(src, desert)

/obj/item/storage/box/MRE/remove_from_storage()
	. = ..()
	if(. && !contents.len && !gc_destroyed)
		qdel(src)

/obj/item/storage/box/MRE/update_icon()
	if(!isopened)
		isopened = 1
		icon_state = "mealpackopened"

/** Fillable box
 *
 * Deployable box with fancy visuals of its contents
 * Visual content defined in the icon_state_mini var in /obj/item/ammo_magazine
 * All other visuals that do not have a icon_state_mini defined are in var/assoc_overlay
 */
/obj/item/storage/box/visual
	name = "generic box"
	desc = "This box is able to hold a wide variety of supplies."
	icon = 'icons/obj/items/storage/ammo_boxes.dmi'
	icon_state = "mag_box"
	item_state = "mag_box"
	w_class = WEIGHT_CLASS_HUGE
	slowdown = 0.4 // Big unhandly box
	max_w_class = 4
	storage_slots = 32 // 8 images x 4 items
	max_storage_space = 64
	use_to_pickup = TRUE
	can_hold = list(
		/obj/item, //This box should normally be unobtainable so here we go
	)
	///Assoc list linking each item to it's corresponding icon_state for the overlays if the item is not technically a magazine.
	var/list/assoc_overlay = list(
		/obj/item/cell/lasgun = "mag_cell",
		/obj/item/explosive/grenade/frag/PMC = "grenade_red_white",
		/obj/item/explosive/grenade/frag/m15 = "grenade_yellow",
		/obj/item/explosive/grenade/frag/training = "grenade_white",
		/obj/item/explosive/grenade/frag = "grenade_red",
		/obj/item/explosive/grenade/incendiary = "grenade_orange",
		/obj/item/explosive/grenade/smokebomb = "grenade_blue",
		/obj/item/explosive/grenade/cloakbomb = "grenade_green",
		/obj/item/explosive/grenade/drainbomb = "grenade_blue",
		/obj/item/explosive/grenade/phosphorus = "grenade_cyan",
		/obj/item/explosive/grenade/impact = "grenade_blue_white",
		/obj/item/explosive/grenade = "grenade",
		/obj/item = "", //Will default to the generic grey magazine blob thingies
	)
	///Assoc list of how much weight every item type takes. Used to determine how many overlays to make.
	var/list/contents_weight = list()
	///Initial offset of the overlays.
	var/overlay_pixel_x = 5
	var/overlay_pixel_y = 10
	///Amount of overlay spaces per axis.
	var/amt_horizontal = 4
	var/amt_vertical = 3
	///Amount of pixels to shift each overlay around only on one axis.
	var/shift_x = BOX_OVERLAY_SHIFT_X
	var/shift_y = BOX_OVERLAY_SHIFT_Y
	///Whether or not the box is deployed on the ground
	var/deployed = FALSE
	///Amount of different items in the ammo box.
	var/variety = 0
	///Amount of weight a single overlay can cover.
	var/overlay_w_class = 0
	///Total max amount of overlay spaces
	var/max_overlays = 0
	///Overlay icon_state to display on the box when it is closed
	var/closed_overlay

/obj/item/storage/box/visual/Initialize(mapload, ...)
	. = ..()
	max_overlays = amt_horizontal * amt_vertical
	overlay_w_class = FLOOR(max_storage_space / max_overlays, 1)
	can_hold -= cant_hold //Have cant_hold actually have a use
	update_icon_state() //Getting the closed_overlay onto it

/obj/item/storage/box/visual/examine(mob/user, distance, infix, suffix)
	. = ..()
	if (!deployed && !(loc == user)) //Closed and not in your possession
		return
	if(variety > max_overlays) //Too much shit inside, a literal clusterfuck of supplies
		to_chat(user, "It's too cluttered with all of these supplies inside.")
		return
	if(variety <= 0) //empy
		to_chat(user, "[src] is empty!")
		return
	to_chat(user, "Inside [src] you notice:")
	for(var/obj/I AS in contents_weight)
		if(contents_weight[I] < overlay_w_class)
			to_chat(user, "A bit of: [initial(I.name)].")
		else if(contents_weight[I] < 3 * overlay_w_class)
			to_chat(user, "Some of: [initial(I.name)].")
		else
			to_chat(user, "A lot of: [initial(I.name)].")

/obj/item/storage/box/visual/attack_self(mob/user)
	deployed = TRUE
	update_icon()
	user.dropItemToGround(src)
	pixel_x = 0 //Big sprite so lets not shift it around.
	pixel_y = 0

/obj/item/storage/box/visual/attack_hand(mob/living/user)
	if(loc == user)
		return ..()

	if(!deployed)
		user.put_in_hands(src)
		return

	else if(deployed)
		open(user)

/obj/item/storage/box/visual/MouseDrop(atom/over_object)
	if(!deployed)
		return

	if(!ishuman(over_object))
		return

	var/mob/living/carbon/human/H = over_object
	if(H == usr && !H.incapacitated() && Adjacent(H) && H.put_in_hands(src))
		deployed = FALSE
		update_icon()

/obj/item/storage/box/visual/update_icon_state()
	. = ..()
	update_visuals()

/// Proc to redo all the overlays and the icon_state of the ammo box
/obj/item/storage/box/visual/proc/update_visuals()

	//Clear all overlays for a fresh start
	overlays.Cut()
	variety = 0

	//Fill assoc list of every ammo type in the crate and have it's value be the total weight it takes up.
	contents_weight = list()
	for(var/obj/item/I AS in contents)
		if(!contents_weight[I.type])
			contents_weight[I.type] = 0
			variety += 1
		contents_weight[I.type] += I.w_class

	if(!deployed)
		icon_state = "[initial(icon_state)]"
		if(closed_overlay)
			overlays += image('icons/obj/items/storage/ammo_boxes.dmi', icon_state = closed_overlay)
		return
	if(variety > max_overlays) // Too many items inside so lets make it cluttered
		icon_state = "[initial(icon_state)]_mixed"
		return

	icon_state = "[initial(icon_state)]_open"

	//Warning: Shitcode ahead.

	//Determine the amount of overlays to draw
	var/total_overlays = 0
	for(var/W in contents_weight)
		total_overlays += 1 + FLOOR(contents_weight[W] / overlay_w_class, 1)

	//In case 6 overlays are for a LMG and then someone adds 7 unique tiny items into the mix
	var/overlay_overflow = max(0, total_overlays - max_overlays)

	//The Xth overlay being drawed.
	var/current_iteration = 1

	//Fun.exe has determined that the following lines contain 100% hardcoded shitcode. Maintainer discretion is advised.
	for(var/W in contents_weight) //Max 8 items in contents_weight since otherwise the icon_state would be "mixed"
		var/overlays_to_draw = 1 + FLOOR(contents_weight[W] / overlay_w_class, 1) //Always draw at least 1 icon per unique mag and add additional icons if it takes a lot of space inside.
		if(overlay_overflow)//This makes sure no matter the configuration, every item will get at least 1 spot in the mix.
			var/adjustment = min(overlay_overflow, overlays_to_draw - 1)
			overlay_overflow -= adjustment
			overlays_to_draw -= adjustment
			total_overlays -= adjustment

		for(var/i = 1, i <= overlays_to_draw, i++) //Same mag type, but now we actually draw them since we know how many to draw
			var/imagepixel_x = overlay_pixel_x + FLOOR((current_iteration / amt_vertical) - 0.01, 1) * shift_x //Shift to the right only after all vertical spaces are occupied.
			var/imagepixel_y = overlay_pixel_y + min(amt_vertical - WRAP(current_iteration - 1, 0, amt_vertical) - 1, total_overlays - current_iteration) * shift_y //Vertical shifting that draws the top overlays first if applicable
			//Getting the mini icon_state to display
			var/obj/item/ammo_magazine/relatedmag = W
			var/imagestate =  initial(relatedmag.icon_state_mini)
			if(!imagestate) //Might be a cell or a random item
				for(var/A in assoc_overlay)
					if(ispath(W, A))
						imagestate = assoc_overlay[A]
						break

			overlays += image('icons/obj/items/storage/ammo_mini.dmi', icon_state = imagestate, pixel_x = imagepixel_x, pixel_y = imagepixel_y)
			current_iteration++

// --MAG BOXES--
/obj/item/storage/box/visual/magazine
	name = "ammunition box"
	desc = "This box is able to hold a wide variety of supplies, mainly military-grade ammunition."
	icon_state = "mag_box"
	item_state = "mag_box"
	max_w_class = 4
	storage_slots = 32 // 8 images x 4 items
	max_storage_space = 64	//SMG and pistol sized (tiny and small) mags can fit all 32 slots, normal (LMG and AR) fit 21
	can_hold = list(
		/obj/item/ammo_magazine/acp,
		/obj/item/ammo_magazine/box10x24mm,
		/obj/item/ammo_magazine/box10x26mm,
		/obj/item/ammo_magazine/box10x27mm,
		/obj/item/ammo_magazine/box9mm,
		/obj/item/ammo_magazine/flamer_tank,
		/obj/item/ammo_magazine/handful,
		/obj/item/ammo_magazine/m412l1_hpr,
		/obj/item/ammo_magazine/magnum,
		/obj/item/ammo_magazine/minigun,
		/obj/item/ammo_magazine/pistol,
		/obj/item/ammo_magazine/railgun,
		/obj/item/ammo_magazine/revolver,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/shotgun,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/standard_gpmg,
		/obj/item/ammo_magazine/standard_hmg,
		/obj/item/ammo_magazine/standard_lmg,
		/obj/item/ammo_magazine/standard_smartmachinegun,
		/obj/item/cell/lasgun,
	)
	cant_hold = list(
		/obj/item/ammo_magazine/flamer_tank/backtank,
		/obj/item/ammo_magazine/flamer_tank/backtank/X,
	)
	overlay_pixel_x = 5
	overlay_pixel_y = 10
	amt_horizontal = 4
	amt_vertical = 3

// --GRENADE BOXES--
/obj/item/storage/box/visual/grenade
	name = "grenade box"
	desc = "This box is able to hold a wide variety of grenades."
	icon_state = "grenade_box"
	item_state = "grenade_box"
	max_w_class = 3
	storage_slots = 25
	max_storage_space = 50
	can_hold = list(
		/obj/item/explosive/grenade,
	)
	cant_hold = list()
	overlay_pixel_x = 7
	overlay_pixel_y = 10
	amt_horizontal = 3
	amt_vertical = 2

/obj/item/storage/box/visual/grenade/M15
	name = "M15 grenade box"
	desc = "A secure box holding 25 M15 fragmentation grenades."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/frag/m15
	closed_overlay = "grenade_box_overlay_m15"

/obj/item/storage/box/visual/grenade/frag
	name = "M40 HEDP grenade box"
	desc = "A secure box holding 25 M40 HEDP grenades. High explosive, don't store near the flamer fuel."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/frag
	closed_overlay = "grenade_box_overlay_hedp"

/obj/item/storage/box/visual/grenade/incendiary
	name = "M40 HIDP grenade box"
	desc = "A secure box holding 25 M40 HIDP incendiary grenades. Warning: highly flammable!!."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/incendiary
	closed_overlay = "grenade_box_overlay_hidp"

/obj/item/storage/box/visual/grenade/phosphorus
	name = "M40 HPDP grenade box"
	desc = "A secure box holding 15 M40 HPDP white phosphorous grenades. War crimes for the entire platoon!"
	spawn_number = 15
	spawn_type = /obj/item/explosive/grenade/phosphorus
	closed_overlay = "grenade_box_overlay_phosphorus"

/obj/item/storage/box/visual/grenade/impact
	name = "M15 grenade box"
	desc = "A secure box holding 25 M40 IMDP impact grenades. High explosive, don't store near the flamer fuel."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/impact
	closed_overlay = "grenade_box_overlay_impact"

/obj/item/storage/box/visual/grenade/cloak
	name = "M40-2 SCDP grenade box"
	desc = "A secure box holding 25 M40-2 SCDP cloak grenades. Don't blindly shoot into the smoke."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/cloakbomb
	closed_overlay = "grenade_box_overlay_cloak"

/obj/item/storage/box/visual/grenade/drain
	name = "M40-T grenade box"
	desc = "A secure box holding 25 M40-T gas grenades. 100% safe to use around masked marines."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/drainbomb
	closed_overlay = "grenade_box_overlay_drain"

/obj/item/storage/box/visual/grenade/razorburn
	name = "Razorburn grenade box"
	desc = "A secure box holding 15 razor burn grenades. Used for quick flank coverage."
	spawn_number = 15
	spawn_type = /obj/item/explosive/grenade/chem_grenade/razorburn_smol
	closed_overlay = "grenade_box_overlay_razorburn"

/obj/item/storage/box/visual/grenade/teargas
	name = "M66 teargas grenade box"
	desc = "A secure box holding 25 M66 tear gas grenades. Used for riot control."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/chem_grenade/teargas
	closed_overlay = "grenade_box_overlay_teargas"

/obj/item/storage/box/visual/grenade/training
	name = "M07 training grenade box"
	desc = "A secure box holding 25 M07 training grenades. Harmless and reusable."
	spawn_number = 25
	spawn_type = /obj/item/explosive/grenade/frag/training
	closed_overlay = "grenade_box_overlay_training"
