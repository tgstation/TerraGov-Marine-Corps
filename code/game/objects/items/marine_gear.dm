
/**********************Marine Gear**************************/

//MARINE COMBAT LIGHT

/obj/item/flashlight/combat
	name = "combat flashlight"
	desc = "A robust flashlight designed to be held in the hand, or attached to a rifle"
	force = 10 //This is otherwise no different from a normal flashlight minus the flavour.
	throwforce = 12 //"combat" flashlight

/obj/structure/broken_apc
	name = "\improper M577 armored personnel carrier"
	desc = "A large, armored behemoth capable of ferrying marines around. \nThis one is sitting nonfunctional."
	anchored = TRUE
	opacity = TRUE
	density = TRUE
	icon = 'icons/Marine/apc.dmi'
	icon_state = "apc"


/obj/item/storage/box/tgmc_mre
	name = "\improper TGMC meal ready to eat"
	desc = "<B>Instructions:</B> Extract food using maximum firepower. Eat.\n\nOn the box is a picture of a shouting Squad Leader. \n\"YOU WILL EAT YOUR NUTRIENT GOO AND YOU WILL ENJOY IT, MAGGOT.\""
	icon_state = "mre1"

/obj/item/storage/box/tgmc_mre/Initialize(mapload, ...)
	. = ..()
	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)
	var/list/randompick = list(
		/obj/item/reagent_containers/food/snacks/protein_pack,
		/obj/item/reagent_containers/food/snacks/protein_pack,
		/obj/item/reagent_containers/food/snacks/protein_pack,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal1,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal2,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal3,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal4,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal5,
		/obj/item/reagent_containers/food/snacks/mre_pack/meal6)

	for(var/i in 1 to 7)
		var/picked = pick(randompick)
		new picked(src)
/obj/item/reagent_containers/food/snacks/protein_pack

	name = "TGMC protein bar"
	desc = "The most fake looking protein bar you have ever laid eyes on, comes in many flavors"
	icon_state = "yummers"
	filling_color = "#ED1169"
	w_class = WEIGHT_CLASS_TINY
	bitesize = 4
	greyscale_config = /datum/greyscale_config/protein
	tastes = list(("flavored protein bar") = 1)
	///list of protein bar types
	var/static/list/randlist = list(
		list("stale TGMC protein bar","The most fake looking protein bar you have ever laid eyes on, covered in the a subtitution chocolate. The powder used to make these is a subsitute of a substitute of whey substitute.","#f37d43",list("nutraloafed food" = 1)),
		list("mint TGMC protein bar","A stale old protien bar, with an almost minty freshness to it, but not fresh enough","#61b36e",list("minty protein" = 1)),
		list("grape TGMC protein bar","Not the good type of grape flavor, tastes like medicine. Fills you up just as well as any protein bar.","#9900ff",list("artifical grape" = 1)),
		list("mystery TGMC protein bar","Some say they have tasted one of these and tasted their favorite childhood meal, especially for squad marines. Most say this tastes like crayons, though it fills like any other protein bar you've seen.","#ffffff",list("crayons" = 1)),
		list("dark chocolate TGMC protein bar","The dark chocolate flavor helps it out a bit, but its still a cheap protein bar.","#5a3b1d",list("bitter dark chocolate" = 1)),
		list("milk chocolate TGMC protein bar","A nice milky addition to a otherwise bland protein taste.","#efc296",list("off flavor milk chocolate"= 1)),
		list("raspberry lime TGMC protein bar","A flavored protein bar, some might say a bit too strongly flavored for their tastes.","#ff0066",list("sour raspberry and lime" = 1)),
		list("chicken TGMC protein bar","Protein bar covered with chicken powder one might find in ramen. Get some extra sodium with your protein.","#cccc00",list= ("powdered chicken")),
		list("blueberry TGMC protein bar","A nice blueberry crunch into your otherwise stale and boring protein bar.","#4e39c5",list("blueberry" = 1))
	)

/obj/item/reagent_containers/food/snacks/protein_pack/Initialize()
	. = ..()
	//list of picked variables
	var/list/picked = pick(randlist)
	name = picked[1]
	desc = picked[2]
	set_greyscale_colors(picked[3])
	tastes = picked[4]
	//due the way nutriment works it has to be added like this or the flavor is cached
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 8, picked[4])

/obj/item/reagent_containers/food/snacks/mre_pack
	name = "\improper generic MRE pack"
	//trash = /obj/item/trash/TGMCtray
	trash = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/mre_pack/meal1
	name = "\improper TGMC Prepared Meal (banana bread)"
	desc = "A slice of banana bread with cream pie spread. A slippery combination."
	icon_state = "MREa"
	filling_color = "#ED1169"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9)
	bitesize = 3
	tastes = list("something funny" = 2, "bread" = 4)

/obj/item/reagent_containers/food/snacks/mre_pack/meal2
	name = "\improper TGMC Prepared Meal (pork)"
	desc = "It's hard to go wrong with rice and pork."
	icon_state = "MREb"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9)
	bitesize = 2
	tastes = list("rice and pork" = 1)

/obj/item/reagent_containers/food/snacks/mre_pack/meal3
	name = "\improper TGMC Prepared Meal (spag)"
	desc = "That's-a spicy meat-aball!"
	icon_state = "MREc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9)
	tastes = list("pasta" = 3, "ground beef" = 1)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/mre_pack/meal4
	name = "\improper TGMC Prepared Meal (pizza)"
	desc = "Aubergine, carrot and sweetcorn, all on a bed of cheese and tomato sauce."
	icon_state = "MREd"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("pizza" = 3, "vegetables" = 1)
	bitesize = 1

/obj/item/reagent_containers/food/snacks/mre_pack/meal4/req
	desc = "This is supposedly a pizza MRE, fit for marine consumption. While it certainly looks like one, the first, active, primary, and only ingredient that went into it was a rounded metal plate. Maybe it'll taste better after it's sat in the ASRS for a while?"
	list_reagents = list(/datum/reagent/iron = 8)
	tastes = list("metal" = 3, "one of your teeth cracking" = 1)

/obj/item/reagent_containers/food/snacks/mre_pack/meal5
	name = "\improper TGMC Prepared Meal (monkey)"
	desc = "Sopa de Macaco, Uma Delicia."
	icon_state = "MREe"
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("meat soup" = 2, "the jungle" = 2)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/mre_pack/meal6
	name = "\improper TGMC Prepared Meal (tofu)"
	desc = "BBQ sticky tofu in a bun, hand crafted by Hungarian children who believe in a galaxy with soldiers that kill people, not animals."
	icon_state = "MREf"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	tastes = list("grilled tofu" = 2, "grass" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/mre_pack/xmas1
	name = "\improper Xmas Prepared Meal:sugar cookies"
	desc = "Delicious Sugar Cookies"
	icon_state = "mreCookies"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/sugar = 1)
	bitesize = 2
	tastes = list("cookies" = 1, "artificial flavoring" = 1)

/obj/item/reagent_containers/food/snacks/mre_pack/xmas2
	name = "\improper Xmas Prepared Meal:gingerbread cookie"
	desc = "A cookie without a soul."
	icon_state = "mreGingerbread"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/sugar = 1)
	tastes = list("batter" = 3, "ginger" = 1)
	bitesize = 2

/obj/item/reagent_containers/food/snacks/mre_pack/xmas3
	name = "\improper Xmas Prepared Meal:fruitcake"
	desc = "Also known as ''the Commander''."
	icon_state = "mreFruitcake"
	list_reagents = list(/datum/reagent/consumable/nutriment = 9, /datum/reagent/consumable/sugar = 1)
	tastes = list("fruits" = 3, "leadership" = 1)
	bitesize = 2

/obj/item/storage/box/pizza
	name = "food delivery box"
	desc = "A space-age food storage device, capable of keeping food extra fresh. Actually, it's just a box."

/obj/item/storage/box/pizza/Initialize(mapload, ...)
	. = ..()
	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	var/list/randompick = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/cheesyfries,
		/obj/item/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/reagent_containers/food/snacks/taco,
		/obj/item/reagent_containers/food/snacks/hotdog)

	for(var/i in 1 to 3)
		var/picked = pick(randompick)
		new picked(src)

/obj/item/paper/janitor
	name = "crumbled paper"
	icon_state = "pamphlet"
	info = "In loving memory of Cub Johnson."

/obj/item/storage/box/nt_mre
	name = "\improper Nanotrasen brand MRE"
	desc = "A prepackaged, long-lasting food box from Nanotrasen Industries.\nOn the box is the Nanotrasen logo, with a slogan surrounding it: \n<b>NANOTRASEN. BUILDING BETTER LUNCHES</b>"
	icon_state = "mre2"
	can_hold = list(/obj/item/reagent_containers/food/snacks)
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/box/nt_mre/Initialize(mapload, ...)
	. = ..()

	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/reagent_containers/food/drinks/coffee(src)
	var/list/randompick = list(
		/obj/item/reagent_containers/food/snacks/cheesiehonkers,
		/obj/item/reagent_containers/food/snacks/no_raisin,
		/obj/item/reagent_containers/food/snacks/spacetwinkie,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/chocolatebar)

	var/picked = pick(randompick)
	new picked(src)


//Harness Belts
/obj/item/belt_harness
	name = "gun sling"
	desc = "A leather sling with a spot to attach a gun. Should keep you from losing your weapon, hopefully."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "gun_sling"
	item_state = "gun_sling"
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY
	time_to_equip = 2 SECONDS
	time_to_unequip = 1 SECONDS
	flags_inventory = NOQUICKEQUIP

/obj/item/belt_harness/marine
	name = "\improper M45 pattern belt harness"
	desc = "A shoulder worn strap with clamps that can attach to a gun. Should keep you from losing your weapon, hopefully."
	icon_state = "heavy_harness"
	item_state = "heavy_harness"

/obj/item/belt_harness/marine/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_BELT)
		playsound(src,'sound/machines/click.ogg', 15, FALSE, 1)

/obj/item/compass
	name = "compass"
	desc = "A small compass that can tell you your coordinates on use."
	icon_state = "compass"
	w_class = WEIGHT_CLASS_TINY

/obj/item/compass/attack_self(mob/living/user)
	. = ..()
	var/turf/location = get_turf(src)
	to_chat(user, span_notice("After looking at the [src] you can tell your general coordinates.") + span_bold(" LONGITUDE [location.x]. LATITUDE [location.y]."))

/obj/item/compass/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(user.do_actions)
		return
	var/turf/target_turf = isturf(target)? target : get_turf(target)
	if(!do_after(user, 1 SECONDS))
		return
	to_chat(user, span_notice("Given your current position, target coordinates are:") + span_bold(" LONGITUDE [target_turf.x]. LATITUDE [target_turf.y]."))
