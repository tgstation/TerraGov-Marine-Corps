/obj/item/reagent_containers/food/snacks/frozen/
	icon = 'icons/obj/items/food/frozen_treats.dmi'

/obj/item/reagent_containers/food/snacks/frozen/icecreamsandwich
	name = "icecream sandwich"
	desc = "Portable Ice-cream in its own packaging."
	icon_state = "icecreamsandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3)
	tastes = list("ice cream" = 1)

/obj/item/reagent_containers/food/snacks/frozen/strawberryicecreamsandwich
	name = "strawberry ice cream sandwich"
	desc = "Portable ice-cream in its own packaging of the strawberry variety."
	icon_state = "strawberryicecreamsandwich"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("ice cream" = 2, "berry" = 2)


/obj/item/reagent_containers/food/snacks/frozen/spacefreezy
	name = "space freezy"
	desc = "The best icecream in space."
	icon_state = "spacefreezy"
	list_reagents = list(/datum/reagent/consumable/nutriment = 8, /datum/reagent/consumable/nutriment/vitamin = 5)
	tastes = list("blue cherries" = 2, "ice cream" = 2)

/obj/item/reagent_containers/food/snacks/frozen/sundae
	name = "sundae"
	desc = "A classic dessert."
	icon_state = "sundae"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("ice cream" = 1, "banana" = 1)

/obj/item/reagent_containers/food/snacks/frozen/honkdae
	name = "honkdae"
	desc = "The clown's favorite dessert."
	icon_state = "honkdae"
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/banana = 10, /datum/reagent/consumable/nutriment/vitamin = 4)
	tastes = list("ice cream" = 1, "banana" = 1, "a bad joke" = 1)

/////////////
//SNOWCONES//
/////////////

/obj/item/reagent_containers/food/snacks/frozen/snowcones //We use this as a base for all other snowcones
	name = "flavorless snowcone"
	desc = "It's just shaved ice. Still fun to chew on."
	icon_state = "flavorless_sc"
	list_reagents = list(/datum/reagent/water = 11) // We dont get food for water/juices
	tastes = list("ice" = 1, "water" = 1)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/lime
	name = "lime snowcone"
	desc = "Lime syrup drizzled over a snowball in a paper cup."
	icon_state = "lime_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/limejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "limes" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/lemon
	name = "lemon snowcone"
	desc = "Lemon syrup drizzled over a snowball in a paper cup."
	icon_state = "lemon_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "lemons" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/apple
	name = "apple snowcone"
	desc = "Apple syrup drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "apples" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/grape
	name = "grape snowcone"
	desc = "Grape syrup drizzled over a snowball in a paper cup."
	icon_state = "grape_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/grapejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "grape" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/orange
	name = "orange snowcone"
	desc = "Orange syrup drizzled over a snowball in a paper cup."
	icon_state = "orange_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/orangejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "orange" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/blue
	name = "bluecherry snowcone"
	desc = "Bluecherry syrup drizzled over a snowball in a paper cup, how rare!"
	icon_state = "blue_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "blue" = 5, "cherries" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/red
	name = "cherry snowcone"
	desc = "Cherry syrup drizzled over a snowball in a paper cup."
	icon_state = "red_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/cherryjelly = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "red" = 5, "cherries" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/berry
	name = "berry snowcone"
	desc = "Berry syrup drizzled over a snowball in a paper cup."
	icon_state = "berry_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/berryjuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "berries" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/fruitsalad
	name = "fruit salad snowcone"
	desc = "A delightful mix of citrus syrups drizzled over a snowball in a paper cup."
	icon_state = "fruitsalad_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/lemonjuice = 5, /datum/reagent/consumable/limejuice = 5, /datum/reagent/consumable/orangejuice = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "oranges" = 5, "limes" = 5, "lemons" = 5, "citrus" = 5, "salad" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/pineapple
	name = "pineapple snowcone"
	desc = "Pineapple syrup drizzled over a snowball in a paper cup."
	icon_state = "pineapple_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "pineapples" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/mime
	name = "mime snowcone"
	desc = "..."
	icon_state = "mime_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nothing = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "nothing" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/clown
	name = "clown snowcone"
	desc = "Laughter drizzled over a snowball in a paper cup."
	icon_state = "clown_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/laughter = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "jokes" = 5, "brainfreeze" = 5, "joy" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/soda
	name = "space cola snowcone"
	desc = "Space Cola drizzled over a snowball in a paper cup."
	icon_state = "soda_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/space_cola = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "cola" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/spacemountainwind
	name = "Space Mountain Wind snowcone"
	desc = "Space Mountain Wind drizzled over a snowball in a paper cup."
	icon_state = "mountainwind_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/spacemountainwind = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "mountain wind" = 5)


/obj/item/reagent_containers/food/snacks/frozen/snowcones/pwrgame
	name = "pwrgame snowcone"
	desc = "Pwrgame soda drizzled over a snowball in a paper cup."
	icon_state = "pwrgame_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "valid" = 5, "salt" = 5, "wats" = 5)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/honey
	name = "honey snowcone"
	desc = "Honey drizzled over a snowball in a paper cup."
	icon_state = "amber_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/honey = 5, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "flowers" = 5, "sweetness" = 5, "wax" = 1)

/obj/item/reagent_containers/food/snacks/frozen/snowcones/rainbow
	name = "rainbow snowcone"
	desc = "A very colorful snowball in a paper cup."
	icon_state = "rainbow_sc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/laughter = 25, /datum/reagent/water = 11)
	tastes = list("ice" = 1, "water" = 1, "sunlight" = 5, "light" = 5, "slime" = 5, "paint" = 3, "clouds" = 3)

/obj/item/reagent_containers/food/snacks/frozen/popsicle
	name = "bug popsicle"
	desc = "Mmmm, this should not exist."
	icon_state = "popsicle_stick_s"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/milk = 2, /datum/reagent/consumable/vanilla = 2, /datum/reagent/consumable/sugar = 4)
	tastes = list("beetlejuice")

	var/overlay_state = "creamsicle_o" //This is the edible part of the popsicle.
	var/bite_states = 4 //This value value is used for correctly setting the bitesize to ensure every bite changes the sprite. Do not set to zero.


/obj/item/reagent_containers/food/snacks/frozen/popsicle/Initialize(mapload)
	. = ..()
	bitesize = reagents.total_volume / bite_states
	update_icon() // make sure the popsicle overlay is primed so it's not just a stick until you start eating it

/obj/item/reagent_containers/food/snacks/frozen/popsicle/update_overlays()
	. = ..()
	if(!bitecount)
		. += initial(overlay_state)
		return
	. += "[initial(overlay_state)]_[min(bitecount, 3)]"

/obj/item/reagent_containers/food/snacks/frozen/popsicle/proc/after_bite(mob/living/eater, mob/living/feeder, bitecount)
	src.bitecount = bitecount

/obj/item/popsicle_stick
	name = "popsicle stick"
	icon = 'icons/obj/items/food/frozen_treats.dmi'
	icon_state = "popsicle_stick"
	desc = "This humble little stick usually carries a frozen treat, at the moment it seems freed from this Atlassian burden."

/obj/item/reagent_containers/food/snacks/frozen/popsicle/creamsicle_orange
	name = "orange creamsicle"
	desc = "A classic orange creamsicle. A sunny frozen treat."
	list_reagents = list(/datum/reagent/consumable/orangejuice = 4, /datum/reagent/consumable/milk = 2, /datum/reagent/consumable/vanilla = 2, /datum/reagent/consumable/sugar = 4)

/obj/item/reagent_containers/food/snacks/frozen/popsicle/creamsicle_berry
	name = "berry creamsicle"
	desc = "A vibrant berry creamsicle. A berry good frozen treat."
	list_reagents = list(/datum/reagent/consumable/berryjuice = 4, /datum/reagent/consumable/milk = 2, /datum/reagent/consumable/vanilla = 2, /datum/reagent/consumable/sugar = 4)
	overlay_state = "creamsicle_m"

/obj/item/reagent_containers/food/snacks/frozen/popsicle/jumbo
	name = "jumbo icecream"
	desc = "A luxurious icecream covered in rich chocolate. It seems smaller than you remember it being."
	list_reagents = list(/datum/reagent/consumable/hot_coco = 4, /datum/reagent/consumable/milk = 2, /datum/reagent/consumable/vanilla = 3, /datum/reagent/consumable/sugar = 2)
	overlay_state = "jumbo"

/obj/item/reagent_containers/food/snacks/frozen/popsicle/nogga_black
	name = "nogga black"
	desc = "A salty licorice icecream recently reintroduced due to all records of the controversy being lost to time. Those who cannot remember the past are doomed to repeat it."
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/salt = 1,  /datum/reagent/consumable/milk = 2, /datum/reagent/consumable/vanilla = 1, /datum/reagent/consumable/sugar = 4)
	tastes = list("salty liquorice")
	overlay_state = "nogga_black"

/obj/item/reagent_containers/food/snacks/frozen/cornuto
	name = "cornuto"
	icon_state = "cornuto"
	desc = "A neapolitan vanilla and chocolate icecream cone. It menaces with a sprinkling of caramelized nuts."
	tastes = list("chopped hazelnuts", "waffle")
	list_reagents = list(/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/hot_coco = 4, /datum/reagent/consumable/milk = 2, /datum/reagent/consumable/vanilla = 4, /datum/reagent/consumable/sugar = 2)
