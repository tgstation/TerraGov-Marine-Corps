/obj/item/reagent_containers/food/snacks/donut
	name = "donut"
	desc = "A donut pastry, which is a common snack on Earth. Goes great with coffee."
	icon = 'icons/obj/items/food/donuts.dmi'
	icon_state = "donut"
	filling_color = "#D9C386"
	var/overlay_state = "donut"
	tastes = list("donut" = 1)

/obj/item/reagent_containers/food/snacks/donut/normal
	name = "donut"
	desc = "A donut. Rare on the frontier, so take care of it."
	icon_state = "donut"
	tastes = list("donut" = 1)
	list_reagents = list (/datum/reagent/consumable/nutriment = 3)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/donut/normal/Initialize(mapload)
	. = ..()
	if(prob(40))
		icon_state = "donut_pink"
		overlay_state = "fdonut"
		name = "frosted donut"
		desc = "A pink frosted donut. Even more rare on the frontier."
		reagents.add_reagent(/datum/reagent/consumable/sprinkles, 2)
	else if(prob(10))
		icon_state = "donut_homer"
		overlay_state = "fdonut"
		name = "frosted sprinkled donut"
		desc = "A pink frosted donut. The rarest on the frontier."
		reagents.add_reagent(/datum/reagent/consumable/sprinkles, 3)

/obj/item/reagent_containers/food/snacks/donut/chaos
	name = "Chaos Donut"
	desc = "Like life, it never quite tastes the same."
	icon_state = "donut_chaos"
	filling_color = "#ED11E6"
	tastes = list("donut" = 3, "chaos" = 1)
	list_reagents = list (/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sprinkles = 1)
	bitesize = 10


/obj/item/reagent_containers/food/snacks/donut/chaos/Initialize(mapload)
	. = ..()
	var/chaosselect = pick(1,2,3,4,5,6,7,8,9)
	switch(chaosselect)
		if(1)
			reagents.add_reagent(/datum/reagent/consumable/nutriment, 3)
		if(2)
			reagents.add_reagent(/datum/reagent/consumable/capsaicin, 3)
		if(3)
			reagents.add_reagent(/datum/reagent/consumable/frostoil, 3)
		if(4)
			reagents.add_reagent(/datum/reagent/consumable/sprinkles, 3)
		if(5)
			reagents.add_reagent(/datum/reagent/toxin/phoron, 3)
		if(6)
			reagents.add_reagent(/datum/reagent/consumable/coco, 3)
		if(7)
			reagents.add_reagent(/datum/reagent/consumable/drink/banana, 3)
		if(8)
			reagents.add_reagent(/datum/reagent/consumable/drink/berryjuice, 3)
		if(9)
			reagents.add_reagent(/datum/reagent/medicine/tricordrazine, 3)
	if(prob(30))
		icon_state = "donut2"
		overlay_state = "fdonut2"
		name = "Frosted Chaos Donut"
		reagents.add_reagent(/datum/reagent/consumable/sprinkles, 2)


/obj/item/reagent_containers/food/snacks/donut/jelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jelly"
	filling_color = "#ED1169"
	tastes = list("jelly" = 1, "donut" = 3)
	bitesize = 5
	list_reagents = list (/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/drink/berryjuice = 5)


/obj/item/reagent_containers/food/snacks/donut/jelly/Initialize(mapload)
	. = ..()
	if(prob(30))
		icon_state = "jelly_pink"
		overlay_state = "fdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent(/datum/reagent/consumable/sprinkles, 2)

/obj/item/reagent_containers/food/snacks/donut/cherryjelly
	name = "Jelly Donut"
	desc = "You jelly?"
	icon_state = "jelly_pink"
	filling_color = "#ED1169"
	list_reagents = list (/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/cherryjelly = 5)


/obj/item/reagent_containers/food/snacks/donut/cherryjelly/Initialize(mapload)
	. = ..()
	if(prob(30))
		icon_state = "jelly_pink"
		overlay_state = "box-donut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent(/datum/reagent/consumable/sprinkles, 2)

/obj/item/reagent_containers/food/snacks/donut/meat
	name = "Meat Donut"
	desc = "Tastes as gross as it looks."
	icon_state = "donut_meat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/ketchup = 3)
	tastes = list("meat" = 1, "grease" = 3)

/obj/item/reagent_containers/food/snacks/donut/berry
	name = "pink donut"
	desc = "Goes great with a soy latte."
	icon_state = "donut_pink"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/drink/berryjuice = 3, /datum/reagent/consumable/sprinkles = 1) //Extra sprinkles to reward frosting

/obj/item/reagent_containers/food/snacks/donut/trumpet
	name = "spaceman's donut"
	desc = "Goes great with a cold beaker of malk."
	icon_state = "donut_purple"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1)
	tastes = list("donut" = 3, "violets" = 1)

/obj/item/reagent_containers/food/snacks/donut/apple
	name = "apple donut"
	desc = "Goes great with a shot of cinnamon schnapps."
	icon_state = "donut_green"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1)
	tastes = list("donut" = 3, "green apples" = 1)

/obj/item/reagent_containers/food/snacks/donut/caramel
	name = "caramel donut"
	desc = "Goes great with a mug of hot coco."
	icon_state = "donut_beige"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/caramel = 3, /datum/reagent/consumable/sprinkles = 1)
	tastes = list("donut" = 3, "buttery sweetness" = 1)

/obj/item/reagent_containers/food/snacks/donut/choco
	name = "chocolate donut"
	desc = "Goes great with a glass of warm milk."
	icon_state = "donut_choc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/hot_coco = 3, /datum/reagent/consumable/sprinkles = 1) //the coco reagent is just bitter.
	tastes = list("donut" = 4, "bitterness" = 1)

/obj/item/reagent_containers/food/snacks/donut/choco/Initialize(mapload)
	. = ..()
	if(prob(40))
		icon_state = "donut_choc_sprinkles"
		overlay_state = "fdonut"
		name = "frosted donut"
		desc = "A chocolate frosted donut. Goes great with hot chocolate."
		reagents.add_reagent(/datum/reagent/consumable/sprinkles, 2)

/obj/item/reagent_containers/food/snacks/donut/blumpkin
	name = "blumpkin donut"
	desc = "Goes great with a mug of soothing drunken blumpkin."
	icon_state = "donut_blue"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1)
	tastes = list("donut" = 2, "blumpkin" = 1)

/obj/item/reagent_containers/food/snacks/donut/bungo
	name = "bungo donut"
	desc = "Goes great with a mason jar of hippie's delight."
	icon_state = "donut_yellow"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1)
	tastes = list("donut" = 3, "tropical sweetness" = 1)

/obj/item/reagent_containers/food/snacks/donut/matcha
	name = "matcha donut"
	desc = "Goes great with a cup of tea."
	icon_state = "donut_olive"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/drink/poisonberryjuice = 3, /datum/reagent/consumable/sprinkles = 1)
	tastes = list("donut" = 3, "matcha" = 1)

/obj/item/reagent_containers/food/snacks/donut/laugh
	name = "sweet pea donut"
	desc = "Goes great with a bottle of Bastion Burbon!"
	icon_state = "donut_laugh"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/laughter = 3)
	tastes = list("donut" = 3, "fizzy tutti frutti" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/trumpet
	name = "spaceman's jelly donut"
	desc = "Goes great with a cold beaker of malk."
	icon_state = "jelly_purple"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "violets" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/apple
	name = "apple jelly donut"
	desc = "Goes great with a shot of cinnamon schnapps."
	icon_state = "jelly_green"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/caramel
	name = "caramel jelly donut"
	desc = "Goes great with a mug of hot coco."
	icon_state = "jelly_beige"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/caramel = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "buttery sweetness" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/choco
	name = "chocolate jelly donut"
	desc = "Goes great with a glass of warm milk."
	icon_state = "jelly_choc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/hot_coco = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1) //the coco reagent is just bitter.
	tastes = list("jelly" = 1, "donut" = 4, "bitterness" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/blumpkin
	name = "blumpkin jelly donut"
	desc = "Goes great with a mug of soothing drunken blumpkin."
	icon_state = "jelly_blue"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 2, "blumpkin" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/bungo
	name = "bungo jelly donut"
	desc = "Goes great with a mason jar of hippie's delight."
	icon_state = "jelly_yellow"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "tropical sweetness" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/matcha
	name = "matcha jelly donut"
	desc = "Goes great with a cup of tea."
	icon_state = "jelly_olive"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/drink/poisonberryjuice = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "matcha" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/laugh
	name = "sweet pea jelly donut"
	desc = "Goes great with a bottle of Bastion Burbon!"
	icon_state = "jelly_laugh"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/laughter = 3)
	tastes = list("jelly" = 3, "donut" = 1, "fizzy tutti frutti" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	list_reagents = list(/datum/reagent/toxin/phoron = 3)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/plain
	icon_state = "jelly"

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/berry
	name = "pink jelly donut"
	desc = "Goes great with a soy latte."
	icon_state = "jelly_pink"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/drink/berryjuice = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1) //Extra sprinkles to reward frosting

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/trumpet
	name = "spaceman's jelly donut"
	desc = "Goes great with a cold beaker of malk."
	icon_state = "jelly_purple"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "violets" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/apple
	name = "apple jelly donut"
	desc = "Goes great with a shot of cinnamon schnapps."
	icon_state = "jelly_green"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "green apples" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/caramel
	name = "caramel jelly donut"
	desc = "Goes great with a mug of hot coco."
	icon_state = "jelly_beige"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/caramel = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "buttery sweetness" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/choco
	name = "chocolate jelly donut"
	desc = "Goes great with a glass of warm milk."
	icon_state = "jelly_choc"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/hot_coco = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1) //the coco reagent is just bitter.
	tastes = list("jelly" = 1, "donut" = 4, "bitterness" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/blumpkin
	name = "blumpkin jelly donut"
	desc = "Goes great with a mug of soothing drunken blumpkin."
	icon_state = "jelly_blue"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 2, "blumpkin" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/bungo
	name = "bungo jelly donut"
	desc = "Goes great with a mason jar of hippie's delight."
	icon_state = "jelly_yellow"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "tropical sweetness" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/matcha
	name = "matcha jelly donut"
	desc = "Goes great with a cup of tea."
	icon_state = "jelly_olive"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/drink/poisonberryjuice = 3, /datum/reagent/consumable/sprinkles = 1, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("jelly" = 1, "donut" = 3, "matcha" = 1)

/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly/laugh
	name = "sweet pea jelly donut"
	desc = "Goes great with a bottle of Bastion Burbon!"
	icon_state = "jelly_laugh"
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 3, /datum/reagent/consumable/laughter = 3)
	tastes = list("jelly" = 3, "donut" = 1, "fizzy tutti frutti" = 1)
