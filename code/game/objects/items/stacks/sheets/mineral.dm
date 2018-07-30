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

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/portable_atmospherics/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/phoron_recipes = list ( \
	new/datum/stack_recipe("phoron door", /obj/structure/mineral_door/transparent/phoron, 10, one_per_turf = 1, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/plastic_recipes = list ( \
	new/datum/stack_recipe("plastic crate", /obj/structure/closet/crate/plastic, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plastic fork", /obj/item/tool/kitchen/utensil/pfork, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spoon", /obj/item/tool/kitchen/utensil/pspoon, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic knife", /obj/item/tool/kitchen/utensil/pknife, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic bag", /obj/item/storage/bag/plasticbag, 3, on_floor = 1), \
	)

var/global/list/datum/stack_recipe/iron_recipes = list ( \
	new/datum/stack_recipe("iron door", /obj/structure/mineral_door/iron, 20, one_per_turf = 1, on_floor = 1), \
	null, \
)

/obj/item/stack/sheet/mineral
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/mineral/New()
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

obj/item/stack/sheet/mineral/iron
	name = "iron"
	desc = "Iron is the most basic building material in space, a metal solid at room temperature, easy to shape and available in immense quantities."
	singular_name = "iron sheet"
	icon_state = "sheet-silver"
	origin_tech = "materials=1"
	sheettype = "iron"
	color = "#333333"
	perunit = 3750
	stack_id = "iron"

obj/item/stack/sheet/mineral/iron/New()
	..()
	recipes = iron_recipes

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "Sandstone is a combination of sand and stone. A common building material for primitive civilisations, can still make a good enough wall"
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 4
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"
	stack_id = "sandstone"

/obj/item/stack/sheet/mineral/sandstone/New()
	..()
	recipes = sandstone_recipes

/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	desc = "Diamond is a specific arrangement of carbon created under extreme pressure and heat. Valued for its look and properties, despite artificial manufacturing possibilities."
	singular_name = "diamond gem"
	icon_state = "sheet-diamond"
	origin_tech = "materials=6"
	perunit = 3750
	sheettype = "diamond"
	stack_id = "diamond"


/obj/item/stack/sheet/mineral/diamond/New()
	..()
	recipes = diamond_recipes

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	desc = "Uranium is a radioactive metal of the actinide series. Valued as reactor fuel for fission-type generators, and as a primer for fusion bombs."
	singular_name = "uranium rod"
	icon_state = "sheet-uranium"
	origin_tech = "materials=5"
	perunit = 2000
	sheettype = "uranium"
	stack_id = "uranium"

/obj/item/stack/sheet/mineral/uranium/New()
	..()
	recipes = uranium_recipes

/obj/item/stack/sheet/mineral/phoron
	name = "solid phoron"
	desc = "Phoron is an extremely rare mineral with exotic properties, often used in cutting-edge research. Just getting it into a stable, solid form is already hard enough."
	singular_name = "phoron ingot"
	icon_state = "sheet-phoron"
	origin_tech = "phorontech=2;materials=2"
	perunit = 2000
	sheettype = "phoron"
	stack_id = "phoron"

/obj/item/stack/sheet/mineral/phoron/New()
	..()
	// recipes = phoron_recipes // Disabled phoron doors

/obj/item/stack/sheet/mineral/phoron/small_stack
	amount = 10

/obj/item/stack/sheet/mineral/phoron/medium_stack
	amount = 30

/obj/item/stack/sheet/mineral/plastic
	name = "Plastic"
	desc = "Plastic is a synthetic polymer, manufactured from organic and inorganic components into a malleable and light fabric. It can be used for a wide range of objects."
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	origin_tech = "materials=3"
	perunit = 2000
	stack_id = "plastic"

/obj/item/stack/sheet/mineral/plastic/New()
	..()
	recipes = plastic_recipes

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
	origin_tech = "materials=4"
	perunit = 2000
	sheettype = "gold"
	stack_id = "gold"

/obj/item/stack/sheet/mineral/gold/New()
	..()
	recipes = gold_recipes

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	desc = "Silver is a transition metal. It is known for its namesake silver, gray color. It is used both for cosmetics as a cheaper alternative to gold, or for engineering."
	singular_name = "silver ingot"
	icon_state = "sheet-silver"
	origin_tech = "materials=3"
	perunit = 2000
	sheettype = "silver"
	stack_id = "silver"

/obj/item/stack/sheet/mineral/silver/New()
	..()
	recipes = silver_recipes

/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	desc = "Enriched uranium rods are made out of around 3 to 5 percent of U-235 mixed with regular U-238. While nowhere near weapons-grade, it is good enough to be used in a fission engine."
	singular_name = "enriched uranium rod"
	icon_state = "sheet-enruranium"
	origin_tech = "materials=5"
	perunit = 1000
	stack_id = "uranium"

//Valuable resource, cargo can sell it.
/obj/item/stack/sheet/mineral/platinum
	name = "platinum"
	desc = "Platinum is a transition metal. Relatively rare and pretty, it is used for its cosmetic value and chemical properties as a catalytic agent. It is also used in electrodes."
	singular_name = "platinum ingot"
	icon_state = "sheet-adamantine"
	origin_tech = "materials=2"
	sheettype = "platinum"
	perunit = 2000
	stack_id = "platinum"

//Extremely valuable to Research.
/obj/item/stack/sheet/mineral/mhydrogen
	name = "metallic hydrogen"
	desc = "Metallic hydrogen is regular hydrogen in a near-solid state, turned into an ingot under immense pressures. The exact procedure to create and stabilize such ingots is still a trade secret."
	singular_name = "hydrogen ingot"
	icon_state = "sheet-mythril"
	origin_tech = "materials=6;powerstorage=5;magnets=5"
	sheettype = "mhydrogen"
	perunit = 2000
	stack_id = "mhydrogen"

//Fuel for MRSPACMAN generator.
/obj/item/stack/sheet/mineral/tritium
	name = "tritium"
	desc = "Tritium is an isotope of hydrogen, H-3, turned into an ingot under immense pressures. The exact procedure to create and stabilize such ingots is still a trade secret."
	singular_name = "tritium ingot"
	icon_state = "sheet-silver"
	sheettype = "tritium"
	origin_tech = "materials=5"
	color = "#777777"
	perunit = 2000
	stack_id = "tritium"

/obj/item/stack/sheet/mineral/osmium
	name = "osmium"
	desc = "Osmium is a transition metal. The densest naturally-occuring element known to man, it is obviously known for its extreme hardness and durability and used as such."
	singular_name = "tritium ingot"
	icon_state = "sheet-silver"
	sheettype = "osmium"
	origin_tech = "materials=5"
	color = "#9999FF"
	perunit = 2000
	stack_id = "osmium"
