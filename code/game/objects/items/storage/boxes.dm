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

#define BOX_MAGAZINE_OFFSET_X 5
#define BOX_MAGAZINE_OFFSET_Y 11
#define BOX_MAGAZINE_COLUMNS 4
#define BOX_MAGAZINE_ROWS 2

#define BOX_MAGAZINE_COMPACT_OFFSET_X 7
#define BOX_MAGAZINE_COMPACT_OFFSET_Y 10
#define BOX_MAGAZINE_COMPACT_COLUMNS 3
#define BOX_MAGAZINE_COMPACT_ROWS 2

#define BOX_GRENADE_OFFSET_X 7
#define BOX_GRENADE_OFFSET_Y 10
#define BOX_GRENADE_COLUMNS 3
#define BOX_GRENADE_ROWS 2

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/paper/crumpled
	storage_slots = null
	max_w_class = 2 //Changed because of in-game abuse
	w_class = WEIGHT_CLASS_BULKY //Changed becuase of in-game abuse

/obj/item/storage/box/survival
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/survival
	spawns_with = list(
		/obj/item/clothing/mask/breath,
		/obj/item/tank/emergency_oxygen,
	)

/obj/item/storage/box/engineer
	spawns_with = list(
		/obj/item/clothing/mask/breath,
		/obj/item/tank/emergency_oxygen/engi,
	)

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	spawns_with = list(/obj/item/clothing/gloves/latex = 7)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains masks of sterility."
	icon_state = "sterile"
	spawns_with = list(/obj/item/clothing/mask/surgical = 7)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	spawns_with = list(/obj/item/reagent_containers/syringe = 2)
	icon_state = "syringe"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/box/beakers
	name = "box of beakers"
	icon_state = "beaker"
	spawns_with = list(/obj/item/reagent_containers/glass/beaker = 7)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "flashbang"
	spawns_with = list(/obj/item/explosive/grenade/flashbang = 7)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"
	spawns_with = list(/obj/item/explosive/grenade/empgrenade = 5)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	spawns_with = list(/obj/item/clothing/glasses/regular = 7)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	spawns_with = list(/obj/item/reagent_containers/food/drinks/drinkingglass = 6)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	spawns_with = list(/obj/item/reagent_containers/food/condiment = 6)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	spawns_with = list(/obj/item/reagent_containers/food/drinks/sillycup = 7)

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <item>Heat in microwave. Product will cool if not eaten within seven minutes.</item>"
	icon_state = "donk_kit"
	spawns_with = list(/obj/item/reagent_containers/food/snacks/donkpocket = 6)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon = 'icons/obj/items/food.dmi'
	icon_state = "monkeycubebox"
	spawns_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped = 5)

/obj/item/storage/box/monkeycubes/farwacubes
	name = "farwa cube box"
	desc = "Drymate brand farwa cubes, shipped from Ahdomai. Just add water!"
	spawns_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/farwacube)

/obj/item/storage/box/monkeycubes/stokcubes
	name = "stok cube box"
	desc = "Drymate brand stok cubes, shipped from Moghes. Just add water!"
	spawns_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/stokcube)

/obj/item/storage/box/monkeycubes/neaeracubes
	name = "neaera cube box"
	desc = "Drymate brand neaera cubes, shipped from Jargon 4. Just add water!"
	spawns_with = list(/obj/item/reagent_containers/food/snacks/monkeycube/wrapped/neaeracube)

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	icon_state = "id"
	spawns_with = list(/obj/item/card/id = 7)

/obj/item/storage/box/ids/dogtag
	name = "box of spare Dogtags"
	desc = "Has so many empty Dogtags."
	icon_state = "id"
	spawns_with = list(/obj/item/card/id/dogtag = 7)

/obj/item/storage/box/handcuffs
	name = "box of handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	spawns_with = list(/obj/item/restraints/handcuffs = 7)

/obj/item/storage/box/zipcuffs
	name = "box of zip cuffs"
	desc = "A box full of zip cuffs."
	icon_state = "handcuff"
	spawns_with = list(/obj/item/restraints/handcuffs/zip = 14)

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = "<B><FONT color='red'>WARNING:</FONT></B> <item>Keep out of reach of children</item>."
	icon_state = "mousetraps"
	spawns_with = list(/obj/item/assembly/mousetrap = 6)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	spawns_with = list(/obj/item/storage/pill_bottle = 7)

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/items/toy.dmi'
	icon_state = "spbox"
	max_storage_space = 8
	spawns_with = list(/obj/item/toy/snappop = 8)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY
	flags_equip_slot = ITEM_SLOT_BELT
	spawns_with = list(/obj/item/tool/match = 14)

/obj/item/storage/box/matches/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tool/match))
		var/obj/item/tool/match/match = item

		if(match.heat || match.burnt)
			return ..()

		if(prob(50))
			playsound(loc, 'sound/items/matchstick_lit.ogg', 15, 1)
			match.light_match()
		else
			playsound(loc, 'sound/items/matchstick_hit.ogg', 15, 1)
		return TRUE
	else
		return ..()

/obj/item/storage/box/autoinjectors
	name = "box of injectors"
	desc = "Contains autoinjectors."
	icon_state = "syringe"
	spawns_with = list(/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 7)

/obj/item/storage/box/quickclot
	name = "box of quick-clot injectors"
	desc = "Contains quick-clot autoinjectors."
	icon_state = "syringe"
	spawns_with = list(/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 7)

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	max_storage_space = 42	//holds 21 items of w_class 2
	flags_storage = STORAGE_FLAG_PICKUP
	spawns_with = list(/obj/item/light_bulb/bulb = 21)

/obj/item/storage/box/lights/bulbs // mapping placeholder

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	icon_state = "lighttube"
	w_class = WEIGHT_CLASS_NORMAL
	spawns_with = list(/obj/item/light_bulb/tube/large = 21)

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	icon_state = "lightmixed"
	can_hold = list(
		/obj/item/light_bulb/tube/large,
		/obj/item/light_bulb/bulb,
	)
	spawns_with = list(
		/obj/item/light_bulb/tube/large = 14,
		/obj/item/light_bulb/bulb = 7,
	)

/obj/item/storage/box/trampop
	name = "box of Tram-pops"
	desc = "Maybe if you behave the doctor will reward you with one."
	icon_state = "trampop"
	spawns_with = list(/obj/item/reagent_containers/food/snacks/lollipop/tramadol = 14)
	w_class = WEIGHT_CLASS_SMALL

////////// MARINES BOXES //////////////////////////

/obj/item/storage/box/explosive_mines
	name = "\improper M20 mine box"
	desc = "A secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 10
	spawns_with = list(/obj/item/explosive/mine = 5)

/obj/item/storage/box/explosive_mines/update_icon_state()
	icon_state = initial(icon_state)
	if(!length(contents))
		icon_state += "_e"

/obj/item/storage/box/explosive_mines/large
	name = "\improper M20 mine box"
	desc = "A large secure box holding anti-personel proximity mines."
	icon_state = "minebox"
	max_storage_space = 20
	spawns_with = list(/obj/item/explosive/mine = 10)

/obj/item/storage/box/explosive_mines/pmc
	name = "\improper M20P mine box"
	spawns_with = list(/obj/item/explosive/mine/pmc)

/obj/item/storage/box/m94
	name = "\improper M40 FLDP flare pack"
	desc = "A packet of seven M40 FLDP Flares. Carried by TGMC soldiers to light dark areas that cannot be reached with the usual TNR Shoulder Lamp. Can be launched from an underslung grenade launcher."
	icon_state = "m40"
	w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 14
	spawns_with = list(/obj/item/explosive/grenade/flare = 7)

/obj/item/storage/box/m94/update_icon()
	icon_state = initial(icon_state)
	if(!length(contents))
		icon_state += "_e"

/obj/item/storage/box/m94/cas
	name = "\improper M50 CFDP signal pack"
	desc = "A packet of seven M40 CFPD signal Flares. Used to mark locations for fire support. Can be launched from an underslung grenade launcher."
	icon_state = "m50"
	spawns_with = list(/obj/item/explosive/grenade/flare/cas)

//ITEMS-----------------------------------//
/obj/item/storage/box/lightstick
	name = "box of lightsticks"
	desc = "Contains blue lightsticks."
	icon_state = "lightstick"
	spawns_with = list(/obj/item/lightstick = 7)

/obj/item/storage/box/lightstick/red
	desc = "Contains red lightsticks."
	icon_state = "lightstick2"
	spawns_with = list(/obj/item/lightstick/red = 7)

/obj/item/storage/box/MRE
	name = "\improper TGMC MRE"
	desc = "Meal Ready-to-Eat, meant to be consumed in the field, and has an expiration that is two decades past a marine's average combat life expectancy."
	icon_state = "mealpack"
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list()
	storage_slots = 4
	max_w_class = 0
	foldable = 0
	///Are we open
	var/isopened = 0

/obj/item/storage/box/MRE/Initialize()
	. = ..()
	pickflavor()

/obj/item/storage/box/MRE/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		new /obj/item/trash/mre(T)
	return ..()

///Picks a random flavor and spawns the foods inside of ourself
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

/**
 * # fillable box
 *
 * Deployable box with fancy visuals of its contents
 * Visual content defined in the icon_state_mini var in /obj/item
 * All other visuals that do not have a icon_state_mini defined are in var/assoc_overlay
 */
/obj/item/storage/box/visual
	name = "generic box"
	desc = "This box is able to hold a wide variety of supplies."
	icon = 'icons/obj/items/storage/storage_boxes.dmi'
	icon_state = "mag_box"
	item_state = "mag_box"
	w_class = WEIGHT_CLASS_HUGE
	slowdown = 0.4 // Big unhandly box
	max_w_class = 4
	storage_slots = 32 // 8 images x 4 items
	max_storage_space = 64
	flags_storage = STORAGE_FLAG_PICKUP|STORAGE_FLAG_FULLNESS_VISIBLE
	can_hold = list(
		/obj/item, //This box should normally be unobtainable so here we go
	)
	///Assoc list of how much weight every item type takes. Used to determine how many overlays to make.
	var/list/contents_weight = list()
	///Initial pixel_x offset of the overlays.
	var/overlay_pixel_x = BOX_MAGAZINE_OFFSET_X
	///Initial pixel_y offset of the overlays.
	var/overlay_pixel_y = BOX_MAGAZINE_OFFSET_Y
	///Amount of columns in the overlay grid.
	var/amt_horizontal = BOX_MAGAZINE_COLUMNS
	///Amount of rows in the overlay grid.
	var/amt_vertical = BOX_MAGAZINE_ROWS
	///Amount of pixels to shift each overlay for each column.
	var/shift_x = BOX_OVERLAY_SHIFT_X
	///Amount of pixels to shift each overlay for each row.
	var/shift_y = BOX_OVERLAY_SHIFT_Y
	///Whether or not the box is deployed on the ground
	var/deployed = FALSE
	///Amount of different items in the box.
	var/variety = 0
	///Amount of weight a single overlay can cover.
	var/overlay_w_class = 0
	///Total max amount of overlay spaces
	var/max_overlays = 0
	///Overlay icon_state to display on the box when it is closed
	var/closed_overlay

/obj/item/storage/box/visual/Initialize(mapload, ...)
	. = ..()
	update_stats()

/// Updates certain vars used primarily (but not exclusively) for the creation of the overlays.
/obj/item/storage/box/visual/proc/update_stats()
	SHOULD_CALL_PARENT(TRUE)
	max_overlays = amt_horizontal * amt_vertical
	overlay_w_class = FLOOR(max_storage_space / max_overlays, 1)
	can_hold -= cant_hold //Have cant_hold actually have a use
	update_icon() //Getting the closed_overlay onto it

/obj/item/storage/box/visual/examine(mob/user, distance, infix, suffix)
	. = ..()
	if (!deployed && !(loc == user)) //Closed and not in your possession
		return
	if(variety > max_overlays) //Too much shit inside, a literal clusterfuck of supplies
		to_chat(user, "It's too cluttered with all of these supplies inside.")
		return
	if(variety <= 0) //empy
		to_chat(user, "It is empty!")
		return
	to_chat(user, "It contains:")
	for(var/obj/item/item AS in contents_weight)
		if(contents_weight[item] < overlay_w_class)
			to_chat(user, "A bit of: [initial(item.name)].")
		else if(contents_weight[item] < 3 * overlay_w_class)
			to_chat(user, "Some of: [initial(item.name)].")
		else
			to_chat(user, "A lot of: [initial(item.name)].")

/obj/item/storage/box/visual/attack_self(mob/user)
	deployed = TRUE
	update_icon()
	user.dropItemToGround(src)
	pixel_x = 0 //Big sprite so lets not shift it around.
	pixel_y = 0

/obj/item/storage/box/visual/attack_hand(mob/living/user)
	if(loc == user)
		open(user) //Always show content when holding box
		return

	if(!deployed)
		user.put_in_hands(src)
		return

	else if(deployed)
		if((flags_storage & STORAGE_FLAG_QUICKDRAW_ENABLED) && ishuman(user) && contents.len)
			var/obj/item/item = contents[contents.len]
			item.attack_hand(user)
			return
		open(user)

///Someone click dragged us to them; they want to pick us up
/obj/item/storage/box/visual/MouseDrop(atom/over_object)
	if(!deployed || !ishuman(over_object) || over_object != usr)
		return // You can't click drag this if its to someone else or we aren't deployed
	var/mob/living/carbon/human/user = over_object
	if(user.incapacitated() || !Adjacent(user) || !user.put_in_hands(src))
		return // You are either: unconcious, not adjacent, or can't hold us
	deployed = FALSE
	update_icon()

/obj/item/storage/box/visual/update_icon_state()
	. = ..()

	variety = 0

	//Fill assoc list of every item type in the crate and have it's value be the total weight it takes up.
	contents_weight = list()
	for(var/obj/item/I AS in contents)
		if(!contents_weight[I.type])
			contents_weight[I.type] = 0
			variety++
		contents_weight[I.type] += I.w_class

	if(!deployed)
		icon_state = "[initial(icon_state)]"
		return
	if(variety > max_overlays) // Too many items inside so lets make it cluttered
		icon_state = "[initial(icon_state)]_mixed"
		return

	icon_state = "[initial(icon_state)]_open"

/obj/item/storage/box/visual/update_overlays()
	. = ..()

	if(!deployed)
		icon_state = "[initial(icon_state)]"
		if(closed_overlay)
			. += image('icons/obj/items/storage/storage_boxes.dmi', icon_state = closed_overlay)
		return
	if(variety > max_overlays) // Too many items inside so lets make it cluttered
		return

	//Determine the amount of overlays to draw
	var/total_overlays = 0
	for(var/object in contents_weight)
		total_overlays += 1 + FLOOR(contents_weight[object] / overlay_w_class, 1)

	//In case 6 overlays are for a LMG and then someone adds 7 unique tiny items into the mix
	var/overlay_overflow = max(0, total_overlays - max_overlays)

	//The Xth overlay being drawed.
	var/current_iteration = 1

	for(var/obj_typepath in contents_weight) //Max [total_overlays] items in contents_weight since otherwise the icon_state would be "mixed"
		var/overlays_to_draw = 1 + FLOOR(contents_weight[obj_typepath] / overlay_w_class, 1) //Always draw at least 1 icon per unique item and add additional icons if it takes a lot of weight inside.
		if(overlay_overflow)//This makes sure no matter the configuration, every item will get at least 1 spot in the mix.
			var/adjustment = min(overlay_overflow, overlays_to_draw - 1)
			overlay_overflow -= adjustment
			overlays_to_draw -= adjustment
			total_overlays -= adjustment

		for(var/i = 1 to overlays_to_draw) //Same item type, but now we actually draw them since we know how many to draw
			var/imagepixel_x = overlay_pixel_x + FLOOR((current_iteration / amt_vertical) - 0.01, 1) * shift_x //Shift to the right only after all vertical spaces are occupied.
			var/imagepixel_y = overlay_pixel_y + min(amt_vertical - WRAP(current_iteration - 1, 0, amt_vertical) - 1, total_overlays - current_iteration) * shift_y //Vertical shifting that draws the top overlays first if applicable
			//Getting the mini icon_state to display
			var/obj/item/relateditem = obj_typepath

			. += image('icons/obj/items/items_mini.dmi', icon_state = initial(relateditem.icon_state_mini), pixel_x = imagepixel_x, pixel_y = imagepixel_y)
			current_iteration++

// --MAG BOXES--
/obj/item/storage/box/visual/magazine
	name = "ammunition box"
	desc = "This box is able to hold a wide variety of supplies, mainly military-grade ammunition."
	icon_state = "mag_box"
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

/obj/item/storage/box/visual/magazine/compact
	name = "compact magazine box"
	desc = "A magnifically designed box specifically designed to hold a large quantity of ammo."
	icon_state = "mag_box_small"
	storage_slots = 40 //Same storage as the old prefilled mag boxes found in the req vendor.
	max_storage_space = 40 //Adjusted in update_stats() to fit the needs.
	can_hold = list(
		/obj/item/ammo_magazine, //Able to hold all ammo due to this box being unobtainable. admemes beware of the rocket crate.
	)
	cant_hold = list()
	overlay_pixel_x = BOX_MAGAZINE_COMPACT_OFFSET_X
	overlay_pixel_y = BOX_MAGAZINE_COMPACT_OFFSET_Y
	amt_horizontal = BOX_MAGAZINE_COMPACT_COLUMNS
	amt_vertical = BOX_MAGAZINE_COMPACT_ROWS

/obj/item/storage/box/visual/magazine/compact/update_stats()
	for(var/item_path in can_hold)
		var/obj/item/I = item_path
		if(I)
			max_storage_space = max(initial(I.w_class) * storage_slots, max_storage_space)
			max_w_class = max(initial(I.w_class), max_w_class)
	return ..()

// --PREFILLED MAG BOXES--

// -Pistol-

/obj/item/storage/box/visual/magazine/compact/standard_pistol
	name = "TP-14 magazine box"
	desc = "A box specifically designed to hold a large amount of TP-14 magazines."
	closed_overlay = "mag_box_small_overlay_tp14"
	can_hold = list(
		/obj/item/ammo_magazine/pistol/standard_pistol,
	)

/obj/item/storage/box/visual/magazine/compact/standard_pistol/full
	spawns_with = list(/obj/item/ammo_magazine/pistol/standard_pistol = 40)

/obj/item/storage/box/visual/magazine/compact/standard_heavypistol
	name = "TP-23 magazine box"
	desc = "A box specifically designed to hold a large amount of TP-23 magazines."
	closed_overlay = "mag_box_small_overlay_tp23"
	can_hold = list(
		/obj/item/ammo_magazine/pistol/standard_heavypistol,
	)

/obj/item/storage/box/visual/magazine/compact/standard_heavypistol/full
	spawns_with = list(/obj/item/ammo_magazine/pistol/standard_heavypistol = 40)

/obj/item/storage/box/visual/magazine/compact/standard_revolver
	name = "TP-44 speedloader box"
	desc = "A box specifically designed to hold a large amount of TP-44 speedloaders."
	closed_overlay = "mag_box_small_overlay_tp44"
	can_hold = list(
		/obj/item/ammo_magazine/revolver/standard_revolver,
	)

/obj/item/storage/box/visual/magazine/compact/standard_revolver/full
	spawns_with = list(/obj/item/ammo_magazine/revolver/standard_revolver = 40)

/obj/item/storage/box/visual/magazine/compact/standard_pocketpistol
	name = "TP-17 magazine box"
	desc = "A box specifically designed to hold a large amount of TP-17 magazines."
	closed_overlay = "mag_box_small_overlay_tp17"
	can_hold = list(
		/obj/item/ammo_magazine/pistol/standard_pocketpistol,
	)

/obj/item/storage/box/visual/magazine/compact/standard_pocketpistol/full
	spawns_with = list(/obj/item/ammo_magazine/pistol/standard_pocketpistol = 40)

/obj/item/storage/box/visual/magazine/compact/vp70
	name = "88M4 magazine box"
	desc = "A box specifically designed to hold a large amount of 88M4 magazines."
	closed_overlay = "mag_box_small_overlay_88m4"
	can_hold = list(
		/obj/item/ammo_magazine/pistol/vp70,
	)

/obj/item/storage/box/visual/magazine/compact/vp70/full
	spawns_with = list(/obj/item/ammo_magazine/pistol/vp70 = 40)

/obj/item/storage/box/visual/magazine/compact/plasma_pistol
	name = "TX-8 plasma cell box"
	desc = "A box specifically designed to hold a large amount of TX-8 plasma cells."
	closed_overlay = "mag_box_small_overlay_tx8"
	can_hold = list(
		/obj/item/ammo_magazine/pistol/plasma_pistol,
	)

/obj/item/storage/box/visual/magazine/compact/plasma_pistol/full
	spawns_with = list(/obj/item/ammo_magazine/pistol/plasma_pistol = 40)

// -SMG-

/obj/item/storage/box/visual/magazine/compact/standard_smg
	name = "T-90 magazine box"
	desc = "A box specifically designed to hold a large amount of T-90 magazines."
	closed_overlay = "mag_box_small_overlay_t90"
	can_hold = list(
		/obj/item/ammo_magazine/smg/standard_smg,
	)

/obj/item/storage/box/visual/magazine/compact/standard_smg/full
	spawns_with = list(/obj/item/ammo_magazine/smg/standard_smg = 40)

/obj/item/storage/box/visual/magazine/compact/standard_machinepistol
	name = "T-19 magazine box"
	desc = "A box specifically designed to hold a large amount of T-19 magazines."
	closed_overlay = "mag_box_small_overlay_t19"
	can_hold = list(
		/obj/item/ammo_magazine/smg/standard_machinepistol,
	)

/obj/item/storage/box/visual/magazine/compact/standard_machinepistol/full
	spawns_with = list(/obj/item/ammo_magazine/smg/standard_machinepistol = 40)

/obj/item/storage/box/visual/magazine/compact/ppsh
	name = "PPSh drum magazine box"
	desc = "A box specifically designed to hold a large amount of PPSh drum magazines."
	closed_overlay = "mag_box_small_overlay_ppsh"
	can_hold = list(
		/obj/item/ammo_magazine/smg/ppsh/extended,
	)

/obj/item/storage/box/visual/magazine/compact/ppsh/full
	spawns_with = list(/obj/item/ammo_magazine/smg/ppsh/extended = 40)

// -Rifle-

/obj/item/storage/box/visual/magazine/compact/standard_assaultrifle
	name = "T-12 magazine box"
	desc = "A box specifically designed to hold a large amount of T-12 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_t12"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle,
	)

/obj/item/storage/box/visual/magazine/compact/standard_assaultrifle/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/standard_assaultrifle = 30)

/obj/item/storage/box/visual/magazine/compact/standard_carbine
	name = "T-18 magazine box"
	desc = "A box specifically designed to hold a large amount of T-18 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_t18"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/standard_carbine,
	)

/obj/item/storage/box/visual/magazine/compact/standard_carbine/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/standard_carbine = 30)

/obj/item/storage/box/visual/magazine/compact/tx11
	name = "TX-11 magazine box"
	desc = "A box specifically designed to hold a large amount of TX-11 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_tx11"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/tx11,
	)

/obj/item/storage/box/visual/magazine/compact/tx11/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/tx11 = 30)

/obj/item/storage/box/visual/magazine/compact/lasrifle
	name = "TX-73 cell box"
	desc = "A box specifically designed to hold a large amount of TX-73 cells."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_tx73"
	can_hold = list(
		/obj/item/cell/lasgun/lasrifle,
	)

/obj/item/storage/box/visual/magazine/compact/lasrifle/full
	spawns_with = list(/obj/item/cell/lasgun/lasrifle = 30)

/obj/item/storage/box/visual/magazine/compact/lasrifle/marine
	name = "Terra Experimental cell box"
	desc = "A box specifically designed to hold a large amount of Terra Experimental cells."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_te"
	can_hold = list(
		/obj/item/cell/lasgun/lasrifle/marine,
	)

/obj/item/storage/box/visual/magazine/compact/lasrifle/marine/full
	spawns_with = list(/obj/item/cell/lasgun/lasrifle/marine = 30)

/obj/item/storage/box/visual/magazine/compact/tx15
	name = "TX-15 magazine box"
	desc = "A box specifically designed to hold a large amount of TX-15 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_tx15"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/tx15_flechette,
		/obj/item/ammo_magazine/rifle/tx15_slug,
	)

/obj/item/storage/box/visual/magazine/compact/tx15/flechette
	name = "TX-15 flechette magazine box"
	closed_overlay = "mag_box_small_overlay_tx15_flechette"

/obj/item/storage/box/visual/magazine/compact/tx15/flechette/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/tx15_flechette = 30)

/obj/item/storage/box/visual/magazine/compact/tx15/slug
	name = "TX-15 slug magazine box"
	closed_overlay = "mag_box_small_overlay_tx15_slug"

/obj/item/storage/box/visual/magazine/compact/tx15/slug/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/tx15_slug = 30)

// -Marksmen-

/obj/item/storage/box/visual/magazine/compact/standard_dmr
	name = "T-37 magazine box"
	desc = "A box specifically designed to hold a large amount of T-37 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_t37"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/standard_dmr,
	)

/obj/item/storage/box/visual/magazine/compact/standard_dmr/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/standard_dmr = 30)

/obj/item/storage/box/visual/magazine/compact/standard_br
	name = "T-64 magazine box"
	desc = "A box specifically designed to hold a large amount of T-64 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_t64"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/standard_br,
	)

/obj/item/storage/box/visual/magazine/compact/standard_br/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/standard_br = 30)

/obj/item/storage/box/visual/magazine/compact/chamberedrifle
	name = "TL-127 magazine box"
	desc = "A box specifically designed to hold a large amount of TL-127 magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_tl127"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/chamberedrifle,
	)

/obj/item/storage/box/visual/magazine/compact/chamberedrifle/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/chamberedrifle = 30)

/obj/item/storage/box/visual/magazine/compact/mosin
	name = "mosin packet box"
	desc = "A box specifically designed to hold a large amount of mosin packets."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_mosin"
	can_hold = list(
		/obj/item/ammo_magazine/rifle/bolt,
	)

/obj/item/storage/box/visual/magazine/compact/mosin/full
	spawns_with = list(/obj/item/ammo_magazine/rifle/bolt = 30)

// -Machinegun-

/obj/item/storage/box/visual/magazine/compact/standard_lmg
	name = "T-42 drum magazine box"
	desc = "A box specifically designed to hold a large amount of T-42 drum magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_t42"
	can_hold = list(
		/obj/item/ammo_magazine/standard_lmg,
	)

/obj/item/storage/box/visual/magazine/compact/standard_lmg/full
	spawns_with = list(/obj/item/ammo_magazine/standard_lmg = 30)

/obj/item/storage/box/visual/magazine/compact/standard_gpmg
	name = "T-60 magazine box"
	desc = "A box specifically designed to hold a large amount of T-60 box magazines."
	storage_slots = 30
	closed_overlay = "mag_box_small_overlay_t60"
	can_hold = list(
		/obj/item/ammo_magazine/standard_gpmg,
	)

/obj/item/storage/box/visual/magazine/compact/standard_gpmg/full
	spawns_with = list(/obj/item/ammo_magazine/standard_gpmg = 30)

// --GRENADE BOXES--
/obj/item/storage/box/visual/grenade
	name = "grenade box"
	desc = "This box is able to hold a wide variety of grenades."
	icon_state = "grenade_box"
	max_w_class = 3
	storage_slots = 25
	max_storage_space = 50
	can_hold = list(
		/obj/item/explosive/grenade,
	)
	cant_hold = list()
	overlay_pixel_x = BOX_GRENADE_OFFSET_X
	overlay_pixel_y = BOX_GRENADE_OFFSET_Y
	amt_horizontal = BOX_GRENADE_COLUMNS
	amt_vertical = BOX_GRENADE_ROWS

/obj/item/storage/box/visual/grenade/M15
	name = "\improper M15 grenade box"
	desc = "A secure box holding 25 M15 fragmentation grenades."
	spawns_with = list(/obj/item/explosive/grenade/frag/m15 = 25)
	closed_overlay = "grenade_box_overlay_m15"

/obj/item/storage/box/visual/grenade/frag
	name = "\improper M40 HEDP grenade box"
	desc = "A secure box holding 25 M40 HEDP grenades. High explosive, don't store near the flamer fuel."
	spawns_with = list(/obj/item/explosive/grenade/frag = 25)
	closed_overlay = "grenade_box_overlay_hedp"

/obj/item/storage/box/visual/grenade/incendiary
	name = "\improper M40 HIDP grenade box"
	desc = "A secure box holding 25 M40 HIDP incendiary grenades. Warning: highly flammable!!."
	spawns_with = list(/obj/item/explosive/grenade/incendiary = 25)
	closed_overlay = "grenade_box_overlay_hidp"

/obj/item/storage/box/visual/grenade/phosphorus
	name = "\improper M40 HPDP grenade box"
	desc = "A secure box holding 15 M40 HPDP white phosphorous grenades. War crimes for the entire platoon!"
	storage_slots = 15
	max_storage_space = 30
	spawns_with = list(/obj/item/explosive/grenade/phosphorus = 15)
	closed_overlay = "grenade_box_overlay_phosphorus"

/obj/item/storage/box/visual/grenade/impact
	name = "\improper M15 grenade box"
	desc = "A secure box holding 25 M40 IMDP impact grenades. High explosive, don't store near the flamer fuel."
	spawns_with = list(/obj/item/explosive/grenade/impact = 25)
	closed_overlay = "grenade_box_overlay_impact"

/obj/item/storage/box/visual/grenade/cloak
	name = "\improper M40-2 SCDP grenade box"
	desc = "A secure box holding 25 M40-2 SCDP cloak grenades. Don't blindly shoot into the smoke."
	spawns_with = list(/obj/item/explosive/grenade/cloakbomb = 25)
	closed_overlay = "grenade_box_overlay_cloak"

/obj/item/storage/box/visual/grenade/drain
	name = "\improper M40-T grenade box"
	desc = "A secure box holding 25 M40-T gas grenades. 100% safe to use around masked marines."
	spawns_with = list(/obj/item/explosive/grenade/drainbomb = 25)
	closed_overlay = "grenade_box_overlay_drain"

/obj/item/storage/box/visual/grenade/razorburn
	name = "razorburn grenade box"
	desc = "A secure box holding 15 razor burn grenades. Used for quick flank coverage."
	storage_slots = 15
	max_storage_space = 30
	spawns_with = list(/obj/item/explosive/grenade/chem_grenade/razorburn_smol = 15)
	closed_overlay = "grenade_box_overlay_razorburn"

/obj/item/storage/box/visual/grenade/teargas
	name = "\improper M66 teargas grenade box"
	desc = "A secure box holding 25 M66 tear gas grenades. Used for riot control."
	spawns_with = list(/obj/item/explosive/grenade/chem_grenade/teargas = 25)
	closed_overlay = "grenade_box_overlay_teargas"

/obj/item/storage/box/visual/grenade/training
	name = "\improper M07 training grenade box"
	desc = "A secure box holding 25 M07 training grenades. Harmless and reusable."
	spawns_with = list(/obj/item/explosive/grenade/frag/training = 25)
	closed_overlay = "grenade_box_overlay_training"

#undef BOX_OVERLAY_SHIFT_X
#undef BOX_OVERLAY_SHIFT_Y

#undef BOX_MAGAZINE_OFFSET_X
#undef BOX_MAGAZINE_OFFSET_Y
#undef BOX_MAGAZINE_COLUMNS
#undef BOX_MAGAZINE_ROWS

#undef BOX_MAGAZINE_COMPACT_OFFSET_X
#undef BOX_MAGAZINE_COMPACT_OFFSET_Y
#undef BOX_MAGAZINE_COMPACT_COLUMNS
#undef BOX_MAGAZINE_COMPACT_ROWS

#undef BOX_GRENADE_OFFSET_X
#undef BOX_GRENADE_OFFSET_Y
#undef BOX_GRENADE_COLUMNS
#undef BOX_GRENADE_ROWS
