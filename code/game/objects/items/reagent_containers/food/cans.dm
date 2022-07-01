/obj/item/reagent_containers/food/drinks/cans
	name = "soda can"
	init_reagent_flags = NONE
	var/canopened = FALSE

/obj/item/reagent_containers/food/drinks/cans/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(X)


/obj/item/reagent_containers/food/drinks/cans/attack_self(mob/user as mob)
	if(canopened == FALSE)
		playsound(src,'sound/effects/canopen.ogg', 15, 1)
		to_chat(user, span_notice("You open the drink with [pick("an audible", "a satisfying")] pop!"))
		canopened = TRUE
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER_NOUNIT)
		return
	var/obj/item/reagent_containers/H = usr.get_active_held_item()
	var/N = tgui_input_list(user, "Amount per transfer from this:","[H]", possible_transfer_amounts)
	if (N)
		H.amount_per_transfer_from_this = N

/obj/item/reagent_containers/food/drinks/cans/attack(mob/M as mob, mob/user as mob, def_zone)
	if (canopened == FALSE)
		to_chat(user, span_notice("You need to open the drink first!"))
		return
	..()

//DRINKS

/obj/item/reagent_containers/food/drinks/cans/cola
	name = "\improper TGM Cola"
	desc = "A can of artificial flavors, sweeteners, and coloring, at least it's carbonated. Canned by Nanotrasen."
	icon_state = "tgm_cola"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/space_cola = 30)

/obj/item/reagent_containers/food/drinks/cans/waterbottle
	name = "\improper Nanotrasen bottled spring water"
	desc = "Overpriced 'Spring' water. Bottled by Nanotrasen."
	icon_state = "bottled_water"
	center_of_mass = list("x"=15, "y"=8)
	list_reagents = list(/datum/reagent/water = 30)

/obj/item/reagent_containers/food/drinks/cans/beer
	name = "can of beer"
	desc = "Beer. You've dialed in your target. Time to fire for effect."
	icon_state = "beercan"
	center_of_mass = list("x"=16, "y"=12)
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 30)

/obj/item/reagent_containers/food/drinks/cans/ale
	name = "can of ale"
	desc = "Beer's misunderstood cousin."
	icon_state = "alecan"
	item_state = "beer"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/ethanol/ale = 30)

/obj/item/reagent_containers/food/drinks/cans/space_mountain_wind
	name = "\improper Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/spacemountainwind = 30)

/obj/item/reagent_containers/food/drinks/cans/thirteenloko
	name = "\improper Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	center_of_mass = list("x"=16, "y"=8)
	list_reagents = list(/datum/reagent/consumable/ethanol/thirteenloko = 30)

/obj/item/reagent_containers/food/drinks/cans/dr_gibb
	name = "\improper Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors of chemicals that you can't pronoounce."
	icon_state = "dr_gibb"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/dr_gibb = 30)

/obj/item/reagent_containers/food/drinks/cans/starkist
	name = "\improper Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/space_cola = 15, /datum/reagent/consumable/drink/orangejuice = 15)

/obj/item/reagent_containers/food/drinks/cans/space_up
	name = "\improper Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/space_up = 30)

/obj/item/reagent_containers/food/drinks/cans/lemon_lime
	name = "lemon-lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/lemon_lime = 30)

/obj/item/reagent_containers/food/drinks/cans/iced_tea
	name = "iced tea can"
	desc = "Just like the squad redneck's grandmother used to buy."
	icon_state = "ice_tea_can"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/ = 30)

/obj/item/reagent_containers/food/drinks/cans/grape_juice
	name = "grape juice"
	desc = "A can of probably not grape juice."
	icon_state = "purple_can"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/grapejuice = 30)

/obj/item/reagent_containers/food/drinks/cans/tonic
	name = "tonic water"
	desc = "Step One: Tonic. Check. Step Two: Gin."
	icon_state = "tonic"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/tonic = 50)

/obj/item/reagent_containers/food/drinks/cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Tap water's more refreshing cousin...according to those Europe-folk."
	icon_state = "sodawater"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/sodawater = 50)

/obj/item/reagent_containers/food/drinks/cans/souto
	name = "\improper Souto Classic"
	desc = "The can boldly proclaims it to be tangerine flavored. You can't help but think that's a lie. Canned in Havana."
	icon_state = "souto_classic"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/suoto = 50)

/obj/item/reagent_containers/food/drinks/cans/souto/diet
	name = "\improper Diet Souto"
	desc = "Now with 0% fruit juice! Canned in Havana"
	icon_state = "souto_diet_classic"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/suoto = 25, /datum/reagent/water = 25)

/obj/item/reagent_containers/food/drinks/cans/souto/cherry
	name = "\improper Cherry Souto"
	desc = "Now with more artificial flavors! Canned in Havana"
	icon_state = "souto_cherry"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/suoto/cherry = 50)

/obj/item/reagent_containers/food/drinks/cans/souto/cherry/diet
	name = "\improper Diet Cherry Souto"
	desc = "It's neither diet nor cherry flavored. Canned in Havanna."
	icon_state = "souto_diet_cherry"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/suoto/cherry = 25, /datum/reagent/consumable/ethanol = 25)

/obj/item/reagent_containers/food/drinks/cans/aspen
	name = "\improper Nanotrasen Aspen Beer"
	desc = "Pretty good when you get past the fact that it tastes like piss. Canned by Nanotrasen."
	icon_state = "6_pack_1"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/ethanol/nt_beer = 50)

/obj/item/reagent_containers/food/drinks/cans/souto/lime
	name = "\improper Lime Souto"
	desc = "It's not bad. It's not good either, but it's not bad. Canned in Havana."
	icon_state = "souto_lime"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/lemon_lime = 50)

/obj/item/reagent_containers/food/drinks/cans/souto/lime/diet
	name = "\improper Diet Lime Souto"
	desc = "Ten kinds of acid, two cups of fake sugar, almost a full tank of carbon dioxide, and about 210 kPs all crammed into an aluminum can. What's not to love? Canned in Havana."
	icon_state = "souto_diet_lime"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/cold/lemon_lime = 25, /datum/reagent/water = 25)

/obj/item/reagent_containers/food/drinks/cans/souto/grape
	name = "\improper Grape Souto"
	desc = "An old standby for soda flavors. This, however, tastes like grape flavored cough syrup. Canned in Havana."
	icon_state = "souto_grape"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/grapejuice = 50)

/obj/item/reagent_containers/food/drinks/cans/souto/grape/diet
	name = "\improper Diet Grape Souto"
	desc = "You're fairly certain that this is just grape cough syrup and carbonated water. Canned in Havana."
	icon_state = "souto_diet_grape"
	center_of_mass = list("x"=16, "y"=10)
	list_reagents = list(/datum/reagent/consumable/drink/grapejuice = 25, /datum/reagent/water = 25)

/obj/item/reagent_containers/food/drinks/cans/doctor_delight
	name = "\improper Doctor's Delight"
	desc = "Fruity goodness, to keep the medibots away. What's a medibot? Improves any pills you take with it."
	icon_state = "doctordelightcan"
	center_of_mass = list("x" = 16, "y" = 10)
	list_reagents = list(/datum/reagent/consumable/drink/doctor_delight = 30)
