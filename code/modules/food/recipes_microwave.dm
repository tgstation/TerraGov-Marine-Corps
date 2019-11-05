
// see code/datums/recipe.dm


/* No telebacon. just no...
/datum/recipe/telebacon
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon

I said no!
/datum/recipe/syntitelebacon
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon
*/

/datum/recipe/friedegg
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/friedegg

/datum/recipe/boiledegg
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/boiledegg


/*
/datum/recipe/bananaphone
	reagents = list(/datum/reagent/consumable/psilocybin = 5) //Trippin' balls, man.
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/radio
	)
	result = /obj/item/reagent_containers/food/snacks/bananaphone
*/

/datum/recipe/jellydonut
	reagents = list(/datum/reagent/consumable/drink/berryjuice = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly

/datum/recipe/jellydonut/cherry
	reagents = list(/datum/reagent/consumable/cherryjelly = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/cherryjelly

/datum/recipe/donut
	reagents = list(/datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/normal

/* what is this
/datum/recipe/human
	//invalid recipe
	make_food(var/obj/container as obj)
		var/human_name
		var/human_job
		for (var/obj/item/reagent_containers/food/snacks/meat/human/HM in container)
			if (!HM.subjectname)
				continue
			human_name = HM.subjectname
			human_job = HM.subjectjob
			break
		var/lastname_index = findtext(human_name, " ")
		if (lastname_index)
			human_name = copytext(human_name,lastname_index+1)

		var/obj/item/reagent_containers/food/snacks/human/HB = ..(container)
		HB.name = human_name+HB.name
		HB.job = human_job
		return HB
*/

/datum/recipe/human/burger
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/human/burger

/* Duplicated by plainburger
/datum/recipe/monkeyburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat/monkey
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger
*/

/datum/recipe/plainburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat //do not place this recipe before /datum/recipe/humanburger
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger

/datum/recipe/syntiburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger

/datum/recipe/brainburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/organ/brain
	)
	result = /obj/item/reagent_containers/food/snacks/brainburger

/datum/recipe/xenoburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/xenomeat
	)
	result = /obj/item/reagent_containers/food/snacks/xenoburger

/datum/recipe/fishburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/carpmeat
	)
	result = /obj/item/reagent_containers/food/snacks/fishburger

/datum/recipe/tofuburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/tofu
	)
	result = /obj/item/reagent_containers/food/snacks/tofuburger

/datum/recipe/ghostburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/reagent_containers/food/snacks/ghostburger

/datum/recipe/clownburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/mask/gas/clown_hat,
		/* /obj/item/reagent_containers/food/snacks/grown/banana, */
	)
	result = /obj/item/reagent_containers/food/snacks/clownburger

/datum/recipe/mimeburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/beret
	)
	result = /obj/item/reagent_containers/food/snacks/mimeburger

/datum/recipe/hotdog
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/sausage
	)
	result = /obj/item/reagent_containers/food/snacks/hotdog

/datum/recipe/waffles
	reagents = list(/datum/reagent/consumable/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/donkpocket
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket //SPECIAL
	proc/warm_up(var/obj/item/reagent_containers/food/snacks/donkpocket/being_cooked)
		being_cooked.warm = 1
		being_cooked.reagents.add_reagent(/datum/reagent/medicine/tricordrazine, 5)
		being_cooked.bitesize = 6
		being_cooked.name = "Warm " + being_cooked.name
		being_cooked.cooltime()
	make_food(var/obj/container as obj)
		var/obj/item/reagent_containers/food/snacks/donkpocket/being_cooked = ..(container)
		warm_up(being_cooked)
		return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/reagent_containers/food/snacks/donkpocket
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket //SPECIAL
	make_food(var/obj/container as obj)
		var/obj/item/reagent_containers/food/snacks/donkpocket/being_cooked = locate() in container
		if(being_cooked && !being_cooked.warm)
			warm_up(being_cooked)
		return being_cooked

/datum/recipe/meatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/syntibread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/meatbread

/datum/recipe/xenomeatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/xenomeat,
		/obj/item/reagent_containers/food/snacks/xenomeat,
		/obj/item/reagent_containers/food/snacks/xenomeat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/xenomeatbread

/datum/recipe/bananabread
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bananabread

/datum/recipe/omelette
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/omelette

/datum/recipe/muffin
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/muffin

/datum/recipe/eggplantparm
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm

/datum/recipe/soylenviridians
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/grown/soybeans
	)
	result = /obj/item/reagent_containers/food/snacks/soylenviridians

/datum/recipe/soylentgreen
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/meat/human,
	)
	result = /obj/item/reagent_containers/food/snacks/soylentgreen

/datum/recipe/carrotcake
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/carrotcake

/datum/recipe/cheesecake
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/plaincake
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/plaincake

/datum/recipe/meatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie

/datum/recipe/tofupie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofupie

/datum/recipe/xemeatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/xenomeat,
	)
	result = /obj/item/reagent_containers/food/snacks/xemeatpie

/datum/recipe/pie
	reagents = list(/datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/pie

/datum/recipe/cherrypie
	reagents = list(/datum/reagent/consumable/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/cherries,
	)
	result = /obj/item/reagent_containers/food/snacks/cherrypie

/datum/recipe/berryclafoutis
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/berries,
	)
	result = /obj/item/reagent_containers/food/snacks/berryclafoutis

/datum/recipe/wingfangchu
	reagents = list(/datum/reagent/consumable/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/xenomeat,
	)
	result = /obj/item/reagent_containers/food/snacks/wingfangchu

/datum/recipe/chaosdonut
	reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/chaos

/datum/recipe/human/kabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/meat/human,
	)
	result = /obj/item/reagent_containers/food/snacks/human/kabob

/datum/recipe/monkeykabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/monkey,
		/obj/item/reagent_containers/food/snacks/meat/monkey,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/syntikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/tofukabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofukabob

/datum/recipe/tofubread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/tofubread

/datum/recipe/loadedbakedpotato
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/cheesyfries
	items = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyfries

/datum/recipe/cubancarp
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/cubancarp

/datum/recipe/popcorn
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/corn
	)
	result = /obj/item/reagent_containers/food/snacks/popcorn


/datum/recipe/cookie
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/cookie

/datum/recipe/fortunecookie
	reagents = list(/datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/snacks/fortunecookie
	make_food(var/obj/container as obj)
		var/obj/item/paper/paper = locate() in container
		paper.loc = null //prevent deletion
		var/obj/item/reagent_containers/food/snacks/fortunecookie/being_cooked = ..(container)
		paper.loc = being_cooked
		being_cooked.trash = paper //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
		return being_cooked
	check_items(var/obj/container as obj)
		. = ..()
		if (.)
			var/obj/item/paper/paper = locate() in container
			if (!paper.info)
				return 0
		return .

/datum/recipe/meatsteak
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/syntisteak
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/pizzamargherita
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/meatpizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/syntipizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/mushroompizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/vegetablepizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza

/datum/recipe/spacylibertyduff
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/ethanol/vodka = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
	)
	result = /obj/item/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/ethanol/vodka = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/reagent_containers/food/snacks/amanitajelly
	make_food(var/obj/container as obj)
		var/obj/item/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin/amatoxin)
		return being_cooked

/datum/recipe/meatballsoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball ,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/meatballsoup

/datum/recipe/vegetablesoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/vegetablesoup

/datum/recipe/nettlesoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/grown/nettle,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/nettlesoup

/datum/recipe/wishsoup
	reagents = list(/datum/reagent/water = 20)
	result= /obj/item/reagent_containers/food/snacks/wishsoup

/datum/recipe/hotchili
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/hotchili

/datum/recipe/coldchili
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/coldchili

/datum/recipe/amanita_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/reagent_containers/food/snacks/amanita_pie

/datum/recipe/plump_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/reagent_containers/food/snacks/plump_pie

/datum/recipe/spellburger
	items = list(
		/obj/item/reagent_containers/food/snacks/monkeyburger,
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/reagent_containers/food/snacks/spellburger

/datum/recipe/spellburger
	items = list(
		/obj/item/reagent_containers/food/snacks/monkeyburger,
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/reagent_containers/food/snacks/spellburger

/datum/recipe/bigbiteburger
	items = list(
		/obj/item/reagent_containers/food/snacks/monkeyburger,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/bigbiteburger

/datum/recipe/enchiladas
	items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/reagent_containers/food/snacks/enchiladas

/datum/recipe/creamcheesebread
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread

/datum/recipe/monkeysdelight
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/monkeycube,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/baguette
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/baguette

/datum/recipe/fishandchips
	items = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishandchips

/datum/recipe/birthdaycake
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/clothing/head/cakehat
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake

/datum/recipe/bread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread

/datum/recipe/sandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwich

/datum/recipe/toastedsandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwich
	)
	result = /obj/item/reagent_containers/food/snacks/toastedsandwich

/datum/recipe/grilledcheese
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/grilledcheese

/datum/recipe/tomatosoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/tomatosoup

/datum/recipe/rofflewaffles
	reagents = list(/datum/reagent/consumable/psilocybin = 5, /datum/reagent/consumable/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/stew
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
	)
	result = /obj/item/reagent_containers/food/snacks/stew

/datum/recipe/jelliedtoast
	reagents = list(/datum/reagent/consumable/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/milosoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/milosoup

/datum/recipe/stewedsoymeat
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/stewedsoymeat

/*/datum/recipe/spagetti We have the processor now
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice
	)
	result= /obj/item/reagent_containers/food/snacks/spagetti*/

/datum/recipe/boiledspagetti
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledspagetti

/datum/recipe/boiledrice
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/rice = 10)
	result = /obj/item/reagent_containers/food/snacks/boiledrice

/datum/recipe/ricepudding
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/rice = 10)
	result = /obj/item/reagent_containers/food/snacks/ricepudding

/datum/recipe/pastatomato
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/pastatomato

/datum/recipe/poppypretzel
	items = list(
		/obj/item/seeds/poppyseed,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/poppypretzel

/datum/recipe/meatballspagetti
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/meatballspagetti

/datum/recipe/spesslaw
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/spesslaw

/datum/recipe/superbiteburger
	reagents = list(/datum/reagent/consumable/sodiumchloride = 5, /datum/reagent/consumable/blackpepper = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/boiledegg,
	)
	result = /obj/item/reagent_containers/food/snacks/superbiteburger

/datum/recipe/candiedapple
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/reagent_containers/food/snacks/candiedapple

/datum/recipe/applepie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/applepie

/datum/recipe/applecake
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/applecake

/datum/recipe/jellyburger
	reagents = list(/datum/reagent/consumable/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/jellyburger/cherry

/datum/recipe/twobread
	reagents = list(/datum/reagent/consumable/ethanol/wine = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/twobread

/datum/recipe/cherrysandwich
	reagents = list(/datum/reagent/consumable/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/cherry

/datum/recipe/orangecake
	reagents = list(/datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/orange,
		/obj/item/reagent_containers/food/snacks/grown/orange,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/orangecake

/datum/recipe/limecake
	reagents = list(/datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/lime,
		/obj/item/reagent_containers/food/snacks/grown/lime,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/limecake

/datum/recipe/lemoncake
	reagents = list(/datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/lemon,
		/obj/item/reagent_containers/food/snacks/grown/lemon,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/lemoncake

/datum/recipe/chocolatecake
	reagents = list(/datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/chocolatecake

/datum/recipe/bloodsoup
	reagents = list(/datum/reagent/blood = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/reagent_containers/food/snacks/grown/bloodtomato,
	)
	result = /obj/item/reagent_containers/food/snacks/bloodsoup

/datum/recipe/braincake
	reagents = list(/datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/organ/brain
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/braincake

/datum/recipe/chocolateegg
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/chocolateegg

/datum/recipe/sausage
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/sausage

/datum/recipe/fishfingers
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishfingers

/datum/recipe/mysterysoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/badrecipe,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/mysterysoup

/datum/recipe/pumpkinpie
	reagents = list(/datum/reagent/consumable/drink/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie

/datum/recipe/plumphelmetbiscuit
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit

/datum/recipe/mushroomsoup
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/reagent_containers/food/snacks/mushroomsoup

/datum/recipe/chawanmushi
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/reagent_containers/food/snacks/chawanmushi

/datum/recipe/beetsoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/reagent_containers/food/snacks/beetsoup

/datum/recipe/appletart
	reagents = list(/datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/drink/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/goldapple,
	)
	result = /obj/item/reagent_containers/food/snacks/appletart

/datum/recipe/tossedsalad
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/tossedsalad

/datum/recipe/aesirsalad
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_containers/food/snacks/grown/goldapple,
	)
	result = /obj/item/reagent_containers/food/snacks/aesirsalad

/datum/recipe/validsalad
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/validsalad
	make_food(var/obj/container as obj)
		var/obj/item/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin)
		return being_cooked

/datum/recipe/cracker
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice
	)
	result = /obj/item/reagent_containers/food/snacks/cracker

/datum/recipe/stuffing
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/bread,
	)
	result = /obj/item/reagent_containers/food/snacks/stuffing

/datum/recipe/tofurkey
	items = list(
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/stuffing,
	)
	result = /obj/item/reagent_containers/food/snacks/tofurkey

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/taco
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/snacks/taco

/datum/recipe/bun
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/bun

/datum/recipe/flatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/flatbread

/datum/recipe/meatball
	items = list(
		/obj/item/reagent_containers/food/snacks/rawmeatball
	)
	result = /obj/item/reagent_containers/food/snacks/meatball

/datum/recipe/cutlet
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet
	)
	result = /obj/item/reagent_containers/food/snacks/cutlet

/datum/recipe/fries
	items = list(
		/obj/item/reagent_containers/food/snacks/rawsticks
	)
	result = /obj/item/reagent_containers/food/snacks/fries

/datum/recipe/mint
	reagents = list(/datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/frostoil = 5)
	result = /obj/item/reagent_containers/food/snacks/mint
