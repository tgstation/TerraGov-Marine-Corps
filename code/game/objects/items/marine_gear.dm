
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
	icon = 'icons/obj/items/food/mre.dmi'
	icon_state = "yummers"
	filling_color = "#ED1169"
	w_class = WEIGHT_CLASS_TINY
	bitesize = 4
	greyscale_config = /datum/greyscale_config/protein
	tastes = list(("flavored protein bar") = 1)
	var/faction = FACTION_TERRAGOV
	///list of protein bar types
	var/static/list/flavor_list = list(
		FACTION_TERRAGOV = list(
			list("stale TGMC protein bar","The most fake looking protein bar you have ever laid eyes on, covered in the a subtitution chocolate. The powder used to make these is a subsitute of a substitute of whey substitute.","#f37d43",list("nutraloafed food" = 1)),
			list("mint TGMC protein bar","A stale old protein bar, with an almost minty freshness to it, but not fresh enough.","#61b36e",list("minty protein" = 1)),
			list("grape TGMC protein bar","Not the good type of grape flavor, tastes like medicine. Fills you up just as well as any protein bar.","#9900ff",list("artifical grape" = 1)),
			list("mystery TGMC protein bar","Some say they have tasted one of these and tasted their favorite childhood meal, especially for squad marines. Most say this tastes like crayons, though it fills like any other protein bar you've seen.","#ffffff",list("crayons" = 1)),
			list("dark chocolate TGMC protein bar","The dark chocolate flavor helps it out a bit, but its still a cheap protein bar.","#5a3b1d",list("bitter dark chocolate" = 1)),
			list("milk chocolate TGMC protein bar","A nice milky addition to a otherwise bland protein taste.","#efc296",list("off flavor milk chocolate"= 1)),
			list("raspberry lime TGMC protein bar","A flavored protein bar, some might say a bit too strongly flavored for their tastes.","#ff0066",list("sour raspberry and lime" = 1)),
			list("chicken TGMC protein bar","Protein bar covered with chicken powder one might find in ramen. Get some extra sodium with your protein.","#cccc00",list= ("powdered chicken")),
			list("blueberry TGMC protein bar","A nice blueberry crunch into your otherwise stale and boring protein bar.","#4e39c5",list("blueberry" = 1)),
			list("cement TGMC protein bar", "A gray bar that's allegedly made of cement. It seems to have hardened up. Perhaps it'll make you harden up, too.", "#B2B2B2", list("cement" = 1))
		),
		FACTION_SOM = list(
			list("stale SOM protein bar","The most fake looking protein bar you have ever laid eyes on, covered in the a subtitution chocolate. Its supposedly made with real Martian soil for that patriotic flavour. It has a grainy, metallic taste.","#f37d43",list("rust" = 1)),
			list("salted SOM protein bar","A satisfying protein bar, although quite salty. Made with real TGMC tears.","#86a9b8",list("salt" = 1)),
			list("grape SOM protein bar","Not the good type of grape flavor, tastes like medicine. Fills you up just as well as any protein bar.","#9900ff",list("artifical grape" = 1)),
			list("mystery SOM protein bar","Some say they have tasted one of these and tasted their favorite childhood meal, especially for squad marines. Most say this tastes like crayons, though it fills like any other protein bar you've seen.","#ffffff",list("crayons" = 1)),
			list("dark chocolate SOM protein bar","The dark chocolate flavor helps it out a bit, but its still a cheap protein bar.","#5a3b1d",list("bitter dark chocolate" = 1)),
			list("milk chocolate SOM protein bar","A nice milky addition to a otherwise bland protein taste.","#efc296",list("off flavor milk chocolate"= 1)),
			list("beef SOM protein bar","A beef flavored protein bar, doesn't taste like any cow you've ever tried.","#ff0066",list("meat substitute" = 1)),
			list("meat SOM protein bar","A surprisingly tasty protein bar made from an unspecified meat. Rumors claiming they're made from reconstituted TGMC personnel have been widely dismissed.","#a7576b",list("pork" = 1)),
			list("chicken SOM protein bar","Protein bar covered with chicken powder one might find in ramen. Get some extra sodium with your protein.","#cccc00",list= ("powdered chicken")),
			list("blueberry SOM protein bar","A nice blueberry crunch into your otherwise stale and boring protein bar.","#4e39c5",list("blueberry" = 1))
		),
	)

/obj/item/reagent_containers/food/snacks/protein_pack/Initialize(mapload)
	. = ..()
	//list of picked variables
	var/list/picked = pick(flavor_list[faction])
	name = picked[1]
	desc = picked[2]
	set_greyscale_colors(picked[3])
	tastes = picked[4]
	//due the way nutriment works it has to be added like this or the flavor is cached
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 8, picked[4])

/obj/item/reagent_containers/food/snacks/protein_pack/som
	name = "SOM protein bar"
	desc = "The most fake looking protein bar you have ever laid eyes on, comes in many flavors"
	icon = 'icons/obj/items/food/mre.dmi'
	faction = FACTION_SOM

/obj/item/reagent_containers/food/snacks/req_pizza
	name = "\improper TGMC PFC Jim pizza"
	desc = "You think that is a pizza. You definitely shouldn't eat this, but you can sell this for a PROFIT! While it certainly looks like one, the first, active, primary, and only ingredient that went into it was a rounded metal plate. Maybe it'll taste better after it sat in the ASRS for a while? Oh well, time to sell it to some poor customer in space."
	icon = 'icons/obj/items/food/pizzaspaghetti.dmi'
	icon_state = "mushroompizza"
	list_reagents = list(/datum/reagent/iron = 8)
	tastes = list("metal" = 3, "one of your teeth cracking" = 1)

/obj/item/reagent_containers/food/snacks/mre_pack
	name = "\improper generic MRE pack"
	//trash = /obj/item/trash/TGMCtray
	trash = null
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/items/food/mre.dmi'

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
	icon = 'icons/obj/items/storage/storage.dmi'

/obj/item/storage/box/pizza/Initialize(mapload, ...)
	. = ..()
	pixel_y = rand(-3,3)
	pixel_x = rand(-3,3)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	new /obj/item/reagent_containers/food/snacks/donkpocket(src)
	var/list/randompick = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/cheesyfries,
		/obj/item/reagent_containers/food/snacks/burger/bigbite,
		/obj/item/reagent_containers/food/snacks/mexican/taco,
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
	desc = "A leather sling with a clip to attach something. Should keep you from losing your weapon, hopefully."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "gun_sling"
	item_state = "gun_sling"
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY
	equip_delay_self = 2 SECONDS
	unequip_delay_self = 1 SECONDS
	flags_inventory = NOQUICKEQUIP
	///The current attacher. Gets remade for every new item
	var/datum/component/reequip/reequip_component

/obj/item/belt_harness/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(reequip_component)
		. += "There is \a [reequip_component.parent] hooked into it."

/obj/item/belt_harness/unequipped(mob/unequipper, slot)
	if(reequip_component)
		detach_item(reequip_component.parent, unequipper)
	return ..()

/obj/item/belt_harness/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/huser = user
	if(huser.belt != src)
		to_chat(user, span_notice("You need to be wearing [src] to attach something to it!"))
		return
	if(reequip_component)
		if(reequip_component.parent == I)
			detach_item(I, user)
			return
		to_chat(user, span_notice("[src] already has \a [reequip_component.parent] hooked into it!"))
		return
	attach_item(I, user)

/obj/item/belt_harness/update_icon_state()
	. = ..()
	if(reequip_component)
		icon_state = initial(icon_state) + "_clipped"
	else
		icon_state = initial(icon_state)

///Set up the link between belt and object
/obj/item/belt_harness/proc/attach_item(obj/item/to_attach, mob/user)
	reequip_component = to_attach.AddComponent(/datum/component/reequip, list(SLOT_S_STORE, SLOT_BACK))
	RegisterSignals(reequip_component, list(COMSIG_REEQUIP_FAILURE, COMSIG_QDELETING), PROC_REF(detach_item))
	playsound(src,'sound/machines/click.ogg', 15, FALSE, 1)
	to_chat(user, span_notice("[src] clicks as you hook \the [to_attach] into it."))
	update_icon()

///Clean out attachment refs/signals
/obj/item/belt_harness/proc/detach_item(source)
	SIGNAL_HANDLER
	if(!reequip_component)
		return
	UnregisterSignal(reequip_component, list(COMSIG_REEQUIP_FAILURE, COMSIG_QDELETING))
	if(ishuman(loc))
		to_chat(loc, span_notice("[src] clicks as \the [reequip_component.parent] unhook[reequip_component.parent.p_s()] from it."))
		playsound(src,'sound/machines/click.ogg', 15, FALSE, 1)
	if(!QDELING(reequip_component)) //We might've come here from parent qdeling, so we can't just qdel_null it
		qdel(reequip_component)
	reequip_component = null
	update_icon()

/obj/item/belt_harness/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

/obj/item/belt_harness/marine
	name = "\improper M45 pattern belt harness"
	desc = "A shoulder worn strap with clamps that can attach to most anything. Should keep you from losing your weapon, hopefully."
	icon_state = "heavy_harness"
	item_state = "heavy_harness"

/obj/item/belt_harness/marine/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_BELT)
		playsound(src,'sound/machines/click.ogg', 15, FALSE, 1)
		to_chat(user, span_danger("!!REMEMBER TO ATTACH YOUR WEAPON TO YOUR HARNESS OR IT WON'T WORK!!"))

/obj/item/compass
	name = "compass"
	desc = "A small compass that can tell you your coordinates on use."
	icon = 'icons/Marine/marine-navigation.dmi'
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
