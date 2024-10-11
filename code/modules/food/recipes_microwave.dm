
// see code/datums/recipe.dm


/datum/recipe/friedegg
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/friedegg

/datum/recipe/boiledegg
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledegg


/datum/recipe/jellydonut
	reagents = list(/datum/reagent/consumable/berryjuice = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly

/datum/recipe/jellydonut/cherry
	reagents = list(/datum/reagent/consumable/cherryjelly = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/cherryjelly

/datum/recipe/donut
	reagents = list(/datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/normal


/datum/recipe/human
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/burger/bun,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/human


/datum/recipe/plainburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/reagent_containers/food/snacks/meat //do not place this recipe before /datum/recipe/humanburger
	)
	result = /obj/item/reagent_containers/food/snacks/burger/plain

/datum/recipe/syntiburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/plain

/datum/recipe/brainburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/organ/brain,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/brain

/datum/recipe/xenoburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/reagent_containers/food/snacks/meat/xeno,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/xeno

/datum/recipe/fishburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/fishburger

/datum/recipe/tofuburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/tofu

/datum/recipe/ghostburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/reagent_containers/food/snacks/burger/ghostburger

/datum/recipe/clownburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/clothing/mask/gas/clown_hat,
		/* /obj/item/reagent_containers/food/snacks/grown/banana, */
	)
	result = /obj/item/reagent_containers/food/snacks/burger/clown

/datum/recipe/mimeburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/clothing/head/beret,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/mime

/datum/recipe/hotdog
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
		/obj/item/reagent_containers/food/snacks/sausage,
	)
	result = /obj/item/reagent_containers/food/snacks/hotdog

/datum/recipe/waffles
	reagents = list(/datum/reagent/consumable/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/donkpocket
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket //SPECIAL

/datum/recipe/donkpocket/proc/warm_up(obj/item/reagent_containers/food/snacks/donkpocket/being_cooked)
	being_cooked.warm = 1
	being_cooked.reagents.add_reagent(/datum/reagent/medicine/tricordrazine, 5)
	being_cooked.bitesize = 6
	being_cooked.name = "Warm " + being_cooked.name
	being_cooked.cooltime()

/datum/recipe/donkpocket/make_food(obj/container as obj)
	var/obj/item/reagent_containers/food/snacks/donkpocket/being_cooked = ..(container)
	warm_up(being_cooked)
	return being_cooked

/datum/recipe/donkpocket/warm
	reagents = list() //This is necessary since this is a child object of the above recipe and we don't want donk pockets to need flour
	items = list(
		/obj/item/reagent_containers/food/snacks/donkpocket,
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket //SPECIAL

/datum/recipe/donkpocket/warm/make_food(obj/container as obj)
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread

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
	result = /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread

/datum/recipe/xenomeatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat/xeno,
		/obj/item/reagent_containers/food/snacks/meat/xeno,
		/obj/item/reagent_containers/food/snacks/meat/xeno,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/xenomeatbread

/datum/recipe/bananabread
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/bananabread

/datum/recipe/omelette
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/omelette

/datum/recipe/muffin
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/muffin

/datum/recipe/eggplantparm
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm

/datum/recipe/soylenviridians
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
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
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/carrotcake

/datum/recipe/cheesecake
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/cheesecake

/datum/recipe/plaincake
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/plaincake

/datum/recipe/meatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/meatpie

/datum/recipe/tofupie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/tofupie

/datum/recipe/xemeatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/xeno,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/xemeatpie

/datum/recipe/pie
	reagents = list(/datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/pie

/datum/recipe/cherrypie
	reagents = list(/datum/reagent/consumable/sugar = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/cherries,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/cherrypie

/datum/recipe/berryclafoutis
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/berries,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/berryclafoutis

/datum/recipe/wingfangchu
	reagents = list(/datum/reagent/consumable/soysauce = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/xeno,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/wingfangchu

/datum/recipe/chaosdonut
	reagents = list(/datum/reagent/consumable/frostoil = 5, /datum/reagent/consumable/capsaicin = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/tofubread

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
		/obj/item/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/reagent_containers/food/snacks/popcorn


/datum/recipe/cookie
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 5)
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

/datum/recipe/fortunecookie/make_food(obj/container as obj)
	var/obj/item/paper/paper = locate() in container
	paper.loc = null //prevent deletion
	var/obj/item/reagent_containers/food/snacks/fortunecookie/being_cooked = ..(container)
	paper.loc = being_cooked
	being_cooked.trash = paper //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	return being_cooked

/datum/recipe/fortunecookie/check_items(obj/container as obj)
	. = ..()
	if (.)
		var/obj/item/paper/paper = locate() in container
		if (!paper.info)
			return 0

/datum/recipe/meatsteak
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/syntisteak
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/margherita

/datum/recipe/meatpizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/meatpizza

/datum/recipe/syntipizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/meatpizza

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
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/mushroompizza

/datum/recipe/vegetablepizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizzapasta/vegetablepizza

/datum/recipe/spacylibertyduff
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/ethanol/vodka = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/spacylibertyduff

/datum/recipe/amanitajelly
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/ethanol/vodka = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/amanitajelly

/datum/recipe/amanitajelly/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/soup/amanitajelly/being_cooked = ..(container)
	being_cooked.reagents.del_reagent(/datum/reagent/toxin/amatoxin)
	return being_cooked

/datum/recipe/meatballsoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball ,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/meatballsoup

/datum/recipe/vegetablesoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/vegetablesoup

/datum/recipe/nettlesoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/grown/nettle,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/nettlesoup

/datum/recipe/wishsoup
	reagents = list(/datum/reagent/water = 20)
	result= /obj/item/reagent_containers/food/snacks/soup/wishsoup

/datum/recipe/hotchili
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/hotchili

/datum/recipe/coldchili
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/coldchili

/datum/recipe/amanita_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/amanita_pie

/datum/recipe/plump_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/plump_pie

/datum/recipe/spellburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/plain,
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/spell

/datum/recipe/spellburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/plain,
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/spell

/datum/recipe/bigbiteburger
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/plain,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/bigbite

/datum/recipe/enchiladas
	items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/reagent_containers/food/snacks/mexican/enchiladas

/datum/recipe/creamcheesebread
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/creamcheesebread

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
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/clothing/head/cakehat,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/birthdaycake

/datum/recipe/bread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/bread

/datum/recipe/sandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/sandwich

/datum/recipe/toastedsandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwiches/sandwich,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/toastedsandwich

/datum/recipe/grilledcheese
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/grilled_cheese_sandwich

/datum/recipe/tomatosoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/tomatosoup

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
	result = /obj/item/reagent_containers/food/snacks/soup/stew

/datum/recipe/jelliedtoast
	reagents = list(/datum/reagent/consumable/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/jelliedtoast/cherry

/datum/recipe/milosoup
	reagents = list(/datum/reagent/water = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/milosoup

/datum/recipe/stewedsoymeat
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/stewedsoymeat

/datum/recipe/boiledspagetti
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pizzapasta/spagetti,
	)
	result = /obj/item/reagent_containers/food/snacks/pizzapasta/boiledspaghetti

/datum/recipe/boiledrice
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/rice = 10)
	result = /obj/item/reagent_containers/food/snacks/soup/boiledrice

/datum/recipe/ricepudding
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/rice = 10)
	result = /obj/item/reagent_containers/food/snacks/soup/ricepudding

/datum/recipe/pastatomato
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pizzapasta/spagetti,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/pizzapasta/pastatomato

/datum/recipe/poppypretzel
	items = list(
		/obj/item/seeds/poppyseed,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/poppypretzel

/datum/recipe/meatballspaghetti
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pizzapasta/spagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/pizzapasta/meatballspaghetti

/datum/recipe/spesslaw
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pizzapasta/spagetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/spesslaw

/datum/recipe/superbiteburger
	reagents = list(/datum/reagent/consumable/sodiumchloride = 5, /datum/reagent/consumable/blackpepper = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bigbite,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/boiledegg,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/superbite

/datum/recipe/candiedapple
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/candiedapple

/datum/recipe/applepie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/applepie

/datum/recipe/applecake
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/applecake

/datum/recipe/jellyburger
	reagents = list(/datum/reagent/consumable/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/burger/bun,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/jelly

/datum/recipe/twobread
	reagents = list(/datum/reagent/consumable/ethanol/wine = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/twobread

/datum/recipe/cherrysandwich
	reagents = list(/datum/reagent/consumable/cherryjelly = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
		/obj/item/reagent_containers/food/snacks/sandwiches/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwiches/jellysandwich/cherry

/datum/recipe/orangecake
	reagents = list(/datum/reagent/consumable/milk = 5)
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/orangecake

/datum/recipe/limecake
	reagents = list(/datum/reagent/consumable/milk = 5)
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/limecake

/datum/recipe/lemoncake
	reagents = list(/datum/reagent/consumable/milk = 5)
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/lemoncake

/datum/recipe/chocolatecake
	reagents = list(/datum/reagent/consumable/milk = 5)
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
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/chocolatecake

/datum/recipe/bloodsoup
	reagents = list(/datum/reagent/blood = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/bloodtomato,
		/obj/item/reagent_containers/food/snacks/grown/bloodtomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/bloodsoup

/datum/recipe/braincake
	reagents = list(/datum/reagent/consumable/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/organ/brain,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/braincake

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
	result = /obj/item/reagent_containers/food/snacks/soup/mysterysoup

/datum/recipe/pumpkinpie
	reagents = list(/datum/reagent/consumable/milk = 5, /datum/reagent/consumable/sugar = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pastries/pumpkinpie

/datum/recipe/plumphelmetbiscuit
	reagents = list(/datum/reagent/water = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit

/datum/recipe/mushroomsoup
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/mushroomsoup

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
	result = /obj/item/reagent_containers/food/snacks/soup/beetsoup

/datum/recipe/appletart
	reagents = list(/datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/milk = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/flour,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/goldapple,
	)
	result = /obj/item/reagent_containers/food/snacks/pastries/appletart

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
	result = /obj/item/reagent_containers/food/snacks/soup/aesirsalad

/datum/recipe/validsalad
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosiavulgaris,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/validsalad

/datum/recipe/validsalad/make_food(obj/container as obj)
		var/obj/item/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent(/datum/reagent/toxin)
		return being_cooked

/datum/recipe/cracker
	reagents = list(/datum/reagent/consumable/sodiumchloride = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
	)
	result = /obj/item/reagent_containers/food/snacks/cracker

/datum/recipe/stuffing
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/sodiumchloride = 1, /datum/reagent/consumable/blackpepper = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwiches/bread,
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
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/mexican/taco

/datum/recipe/bun
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/burger/bun

/datum/recipe/flatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/flatbread

/datum/recipe/meatball
	items = list(
		/obj/item/reagent_containers/food/snacks/rawmeatball,
	)
	result = /obj/item/reagent_containers/food/snacks/meatball

/datum/recipe/cutlet
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/cutlet

/datum/recipe/fries
	items = list(
		/obj/item/reagent_containers/food/snacks/rawsticks,
	)
	result = /obj/item/reagent_containers/food/snacks/fries

/datum/recipe/mint
	reagents = list(/datum/reagent/consumable/sugar = 5, /datum/reagent/consumable/frostoil = 5)
	result = /obj/item/reagent_containers/food/snacks/mint

/datum/recipe/larva_soup
	reagents = list(/datum/reagent/water = 5, /datum/reagent/consumable/larvajelly = 5)
	result = /obj/item/reagent_containers/food/snacks/soup/larvasoup

