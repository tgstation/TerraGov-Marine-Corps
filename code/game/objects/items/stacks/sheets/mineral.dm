/*
Mineral Sheets
	Contains:
		- Sandstone
		- Diamond
		- Uranium
		- Phoron
		- Gold
		- Silver
		- Enriched Uranium
		- Platinum
		- Metallic Hydrogen
		- Tritium
		- Osmium
*/

/obj/item/stack/sheet/mineral
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/mineral/Initialize(mapload)
	. = ..()
	pixel_x = rand(-2, 2)
	pixel_y = rand(-2, 2)

/obj/item/stack/sheet/mineral/iron
	name = "iron"
	desc = "Iron is the most basic building material in space, a metal solid at room temperature, easy to shape and available in immense quantities."
	singular_name = "iron sheet"
	icon_state = "sheet-silver"
	sheettype = "iron"
	color = "#333333"
	perunit = 3750

GLOBAL_LIST_INIT(iron_recipes, list ( \
	/obj/structure/mineral_door/iron = new /datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	null, \
	))

/obj/item/stack/sheet/mineral/iron/get_main_recipes()
	. = ..()
	for(var/item in GLOB.iron_recipes)
		. += GLOB.iron_recipes[item]

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "Sandstone is a combination of sand and stone. A common building material for primitive civilisations, can still make a good enough wall"
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 4
	throw_range = 5
	sheettype = "sandstone"

GLOBAL_LIST_INIT(sandstone_recipes, list ( \
	/obj/machinery/hydroponics/soil = new /datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 1 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	/obj/structure/mineral_door/sandstone = new /datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/sandstone/get_main_recipes()
	. = ..()
	for(var/item in GLOB.sandstone_recipes)
		. += GLOB.sandstone_recipes[item]

/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	desc = "Diamond is a specific arrangement of carbon created under extreme pressure and heat. Valued for its look and properties, despite artificial manufacturing possibilities."
	singular_name = "diamond gem"
	icon_state = "sheet-diamond"
	perunit = 3750
	sheettype = "diamond"

GLOBAL_LIST_INIT(diamond_recipes, list ( \
	/obj/structure/mineral_door/transparent/diamond = new /datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/diamond/get_main_recipes()
	. = ..()
	for(var/item in GLOB.diamond_recipes)
		. += GLOB.diamond_recipes[item]

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	desc = "Uranium is a radioactive metal of the actinide series. Valued as reactor fuel for fission-type generators, and as a primer for fusion bombs."
	singular_name = "uranium rod"
	icon_state = "sheet-uranium"
	perunit = 2000
	sheettype = "uranium"

GLOBAL_LIST_INIT(uranium_recipes, list ( \
	/obj/structure/mineral_door/uranium = new /datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/uranium/get_main_recipes()
	. = ..()
	for(var/item in GLOB.uranium_recipes)
		. += GLOB.uranium_recipes[item]

/obj/item/stack/sheet/mineral/phoron
	name = "solid phoron"
	desc = "Phoron is an extremely rare mineral with exotic properties, often used in cutting-edge research. Just getting it into a stable, solid form is already hard enough."
	singular_name = "phoron ingot"
	icon_state = "sheet-phoron"
	perunit = 2000
	sheettype = "phoron"
	merge_type = /obj/item/stack/sheet/mineral/phoron

GLOBAL_LIST_INIT(phoron_recipes, list ( \
	/obj/structure/mineral_door/transparent/phoron = new /datum/stack_recipe("phoron door", /obj/structure/mineral_door/transparent/phoron, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/phoron/get_main_recipes()
	. = ..()
	for(var/item in GLOB.phoron_recipes)
		. += GLOB.phoron_recipes[item]

/obj/item/stack/sheet/mineral/phoron/small_stack
	amount = 10

/obj/item/stack/sheet/mineral/phoron/medium_stack
	amount = 30

/obj/item/stack/sheet/mineral/plastic
	name = "Plastic"
	desc = "Plastic is a synthetic polymer, manufactured from organic and inorganic components into a malleable and light fabric. It can be used for a wide range of objects."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	perunit = 2000

GLOBAL_LIST_INIT(plastic_recipes, list ( \
	/obj/structure/closet/crate/plastic = new /datum/stack_recipe("plastic crate", /obj/structure/closet/crate/plastic, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	/obj/item/ashtray/plastic = new /datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 2, crafting_flags = CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	/obj/item/tool/kitchen/utensil/pfork = new /datum/stack_recipe("plastic fork", /obj/item/tool/kitchen/utensil/pfork, 1, crafting_flags = CRAFT_ON_SOLID_GROUND), \
	/obj/item/tool/kitchen/utensil/pspoon = new /datum/stack_recipe("plastic spoon", /obj/item/tool/kitchen/utensil/pspoon, 1, crafting_flags = CRAFT_ON_SOLID_GROUND), \
	/obj/item/tool/kitchen/utensil/pknife = new /datum/stack_recipe("plastic knife", /obj/item/tool/kitchen/utensil/pknife, 1, crafting_flags = CRAFT_ON_SOLID_GROUND), \
	/obj/item/storage/bag/plasticbag = new /datum/stack_recipe("plastic bag", /obj/item/storage/bag/plasticbag, 3, crafting_flags = CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/plastic/get_main_recipes()
	. = ..()
	for(var/item in GLOB.plastic_recipes)
		. += GLOB.plastic_recipes[item]

/obj/item/stack/sheet/mineral/plastic/cyborg
	name = "plastic sheets"
	desc = "Plastic is a synthetic polymer, manufactured from organic and inorganic components into a malleable and light fabric. It can be used for a wide range of objects."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	perunit = 2000

/obj/item/stack/sheet/mineral/gold
	name = "gold"
	desc = "Gold is a transition metal. A relatively rare metal, known for its color, shine, chemical and electrical properties, it is sought after for both cosmetic, engineering and scientific uses."
	singular_name = "gold ingot"
	icon_state = "sheet-gold"
	perunit = 2000
	sheettype = "gold"
	number_of_extra_variants = 2

GLOBAL_LIST_INIT(gold_recipes, list ( \
	/obj/structure/mineral_door/gold = new /datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/gold/get_main_recipes()
	. = ..()
	for(var/item in GLOB.gold_recipes)
		. += GLOB.gold_recipes[item]

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	desc = "Silver is a transition metal. It is known for its namesake silver, gray color. It is used both for cosmetics as a cheaper alternative to gold, or for engineering."
	singular_name = "silver ingot"
	icon_state = "sheet-silver"
	perunit = 2000
	sheettype = "silver"
	number_of_extra_variants = 2

GLOBAL_LIST_INIT(silver_recipes, list ( \
	/obj/structure/mineral_door/silver = new /datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND), \
	))

/obj/item/stack/sheet/mineral/silver/get_main_recipes()
	. = ..()
	for(var/item in GLOB.silver_recipes)
		. += GLOB.silver_recipes[item]


//Valuable resource, cargo can sell it.
/obj/item/stack/sheet/mineral/platinum
	name = "platinum"
	desc = "Platinum is a transition metal. Relatively rare and pretty, it is used for its cosmetic value and chemical properties as a catalytic agent. It is also used in electrodes."
	singular_name = "platinum ingot"
	icon_state = "sheet-platinum"
	sheettype = "platinum"
	perunit = 2000
	number_of_extra_variants = 2


//Extremely valuable to Research.
/obj/item/stack/sheet/mineral/mhydrogen
	name = "metallic hydrogen"
	desc = "Metallic hydrogen is regular hydrogen in a near-solid state, turned into an ingot under immense pressures. The exact procedure to create and stabilize such ingots is still a trade secret."
	singular_name = "hydrogen ingot"
	icon_state = "sheet-mythril"
	sheettype = "mhydrogen"
	perunit = 2000


//Fuel for MRSPACMAN generator.
/obj/item/stack/sheet/mineral/tritium
	name = "tritium"
	desc = "Tritium is an isotope of hydrogen, H-3, turned into an ingot under immense pressures. The exact procedure to create and stabilize such ingots is still a trade secret."
	singular_name = "tritium ingot"
	icon_state = "sheet-silver"
	sheettype = "tritium"
	color = "#777777"
	perunit = 2000


/obj/item/stack/sheet/mineral/osmium
	name = "osmium"
	desc = "Osmium is a transition metal. The densest naturally-occuring element known to man, it is obviously known for its extreme hardness and durability and used as such."
	singular_name = "osmium ingot"
	icon_state = "sheet-silver"
	sheettype = "osmium"
	color = "#9999FF"
	perunit = 2000
