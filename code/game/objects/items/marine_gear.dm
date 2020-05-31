
/**********************Marine Gear**************************/

//MARINE COMBAT LIGHT

/obj/item/flashlight/combat
	name = "combat flashlight"
	desc = "A robust flashlight designed to be held in the hand, or attached to a rifle"
	force = 10 //This is otherwise no different from a normal flashlight minus the flavour.
	throwforce = 12 //"combat" flashlight

//MARINE SNIPER TARPS

/obj/item/bodybag/tarp
	name = "\improper V1 thermal-dampening tarp (folded)"
	desc = "A tarp carried by TGMC Snipers. When laying underneath the tarp, the sniper is almost indistinguishable from the landscape if utilized correctly. The tarp contains a thermal-dampening weave to hide the wearer's heat signatures, optical camoflauge, and smell dampening."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "jungletarp_folded"
	w_class = WEIGHT_CLASS_NORMAL
	unfoldedbag_path = /obj/structure/closet/bodybag/tarp


/obj/item/bodybag/tarp/snow
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "snowtarp_folded"
	unfoldedbag_path = /obj/structure/closet/bodybag/tarp/snow


/obj/structure/closet/bodybag/tarp
	name = "\improper V1 thermal-dampening tarp"
	bag_name = "V1 thermal-dampening tarp"
	desc = "An active camo tarp carried by TGMC Snipers. When laying underneath the tarp, the sniper is almost indistinguishable from the landscape if utilized correctly. The tarp contains a thermal-dampening weave to hide the wearer's heat signatures, optical camouflage, and smell dampening."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "jungletarp_closed"
	icon_closed = "jungletarp_closed"
	icon_opened = "jungletarp_open"
	open_sound = 'sound/effects/vegetation_walk_1.ogg'
	close_sound = 'sound/effects/vegetation_walk_2.ogg'
	foldedbag_path = /obj/item/bodybag/tarp
	closet_stun_delay = 0


/obj/structure/closet/bodybag/tarp/close()
	. = ..()
	if(!opened && bodybag_occupant)
		anchored = TRUE
		playsound(loc,'sound/effects/cloak_scout_on.ogg', 15, 1) //stealth mode engaged!
		animate(src, alpha = 13, time = 4 SECONDS) //Fade out gradually.


/obj/structure/closet/bodybag/tarp/open()
	anchored = FALSE
	if(alpha != initial(alpha))
		playsound(loc,'sound/effects/cloak_scout_off.ogg', 15, 1)
		alpha = initial(alpha) //stealth mode disengaged
		animate(src) //Cancel the fade out if still ongoing.
	if(bodybag_occupant)
		UnregisterSignal(bodybag_occupant, list(COMSIG_MOB_DEATH, COMSIG_PARENT_PREQDELETED))
	return ..()


/obj/structure/closet/bodybag/tarp/closet_special_handling(mob/living/mob_to_stuff) // overriding this
	if(!ishuman(mob_to_stuff))
		return FALSE //Humans only.
	if(mob_to_stuff.stat == DEAD) //Only the dead for bodybags.
		return FALSE
	return TRUE


/obj/structure/closet/bodybag/tarp/close()
	. = ..()
	if(bodybag_occupant)
		RegisterSignal(bodybag_occupant, list(COMSIG_MOB_DEATH, COMSIG_PARENT_PREQDELETED), .proc/on_bodybag_occupant_death)


/obj/structure/closet/bodybag/tarp/proc/on_bodybag_occupant_death(datum/source, gibbed)
	open()


/obj/structure/closet/bodybag/tarp/update_name()
	return //Shouldn't be revealing who's inside.


/obj/structure/closet/bodybag/tarp/fire_act(exposed_temperature, exposed_volume)
	var/mob/M = locate() in src //need to be occupied
	if(exposed_temperature > 300 && !opened && M)
		to_chat(M, "<span class='danger'>The intense heat forces you out of [src]!</span>")
		open()

/obj/structure/closet/bodybag/tarp/flamer_fire_act()
	var/mob/M = locate() in src //need to be occupied
	if(!opened && M)
		to_chat(M, "<span class='danger'>The intense heat forces you out of [src]!</span>")
		open()

/obj/structure/closet/bodybag/tarp/ex_act(severity)
	var/mob/M = locate() in src //need to be occupied
	if(!opened && M)
		to_chat(M, "<span class='danger'>The shockwave blows [src] open!</span>")
		open()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			visible_message("<span class='danger'>\The shockwave blows [src] apart!</span>")
			qdel(src) //blown apart

/obj/structure/closet/bodybag/tarp/bullet_act(obj/projectile/Proj)
	var/mob/M = locate() in src //need to be occupied
	if(!opened && M)
		M.bullet_act(Proj) //tarp isn't bullet proof; concealment, not cover; pass it on to the occupant.


/obj/structure/closet/bodybag/tarp/snow
	icon_state = "snowtarp_closed"
	icon_closed = "snowtarp_closed"
	icon_opened = "snowtarp_open"
	foldedbag_path = /obj/item/bodybag/tarp/snow


/obj/item/coin/marine
	name = "marine premium token"
	desc = "A special coin meant to be inserted in a marine vendor in order to access a single premium equipment or device... or just to suffice your vices."
	icon_state = "coin_adamantine"
	flags_token = TOKEN_MARINE|TOKEN_GENERAL //when you do prefer a premium smoke over else.

/obj/item/coin/marine/attackby(obj/item/I, mob/user, params) //To remove attaching a string functionality
	return

/obj/item/coin/marine/specialist
	name = "marine specialist weapon token"
	desc = "Insert this into a specialist vendor in order to access a single highly dangerous weapon."
	flags_token = TOKEN_SPEC

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
	name = "stale TGMC protein bar"
	desc = "The most fake looking protein bar you have ever laid eyes on, covered in the a subtitution chocolate. The powder used to make these is a subsitute of a substitute of whey substitute."
	icon_state = "yummers"
	filling_color = "#ED1169"
	w_class = WEIGHT_CLASS_TINY
	list_reagents = list(/datum/reagent/consumable/nutriment = 8)
	bitesize = 4
	tastes = list("nutraloafed food" = 7, "cocoa" = 1)


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

/obj/item/belt_harness/marine
	name = "\improper M45 pattern belt harness"
	desc = "A shoulder worn strap with clamps that can attach to a gun. Should keep you from losing your weapon, hopefully."
	icon_state = "heavy_harness"
	item_state = "heavy_harness"

/obj/item/belt_harness/marine/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_BELT)
		playsound(src,'sound/machines/click.ogg', 15, FALSE, 1)
