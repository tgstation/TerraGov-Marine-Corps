///Base item used in factories, only changes icon and stage for the item then creates a new item when its done
///in order to set a recipe set recipe = GLOB.myrecipe in Initialize
/obj/item/factory_part
	name = "test part"
	desc = "you shouldnt be seeing this"
	icon = 'icons/obj/factory/factoryparts.dmi'
	icon_state = "implant_evil"
	///How many cycles of processing we've gone through
	var/stage = 0
	///How many cycles we go through until we become the result
	var/completion_stage = 4
	///What type of machine the obj goes through first/next
	var/next_machine = FACTORY_MACHINE_FLATTER
	///reference to a glob list containing the recipe
	var/list/recipe
	///What result we become when we've run through all our machines
	var/result = /obj/item/violin

/obj/item/factory_part/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/factory_part/LateInitialize(mapload)
	advance_stage()

///once the part is processed this proc updates iconstate, result, completion etc
/obj/item/factory_part/proc/advance_stage()
	stage++
	if(length(recipe) < stage)
		GLOB.round_statistics.req_items_produced[result]++
		new result(loc)
		qdel(src)
		return
	next_machine = recipe[stage][STEP_NEXT_MACHINE]
	icon_state = recipe[stage][STEP_ICON_STATE]

GLOBAL_LIST_INIT(phosnade_recipe, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "hotplate"),
	))

/obj/item/factory_part/phosnade
	name = "Phosphorus Grenade assembly"
	desc = "A incomplete phosphorus grenade assembly"
	result = /obj/item/explosive/grenade/phosphorus

/obj/item/factory_part/phosnade/Initialize()
	. = ..()
	recipe = GLOB.phosnade_recipe


GLOBAL_LIST_INIT(bignade_recipe,  list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "roundplate"),
	))

/obj/item/factory_part/bignade
	name = "M15 grenade assembly"
	desc = "An incomplete M15 grenade"
	result = /obj/item/explosive/grenade/m15

/obj/item/factory_part/bignade/Initialize()
	. = ..()
	recipe = GLOB.bignade_recipe

GLOBAL_LIST_INIT(pizza_recipe,  list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "dough"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "rounddough"),
	))

/obj/item/factory_part/pizza
	name = "Unfinished pizza"
	desc = "Wait I dont think thats how you make pizza..."
	result = /obj/item/reagent_containers/food/snacks/mre_pack/meal4/req

/obj/item/factory_part/pizza/Initialize()
	. = ..()
	recipe = GLOB.pizza_recipe

GLOBAL_LIST_INIT(sadar_ammo_recipe, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FLATTER, STEP_ICON_STATE = "hotplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "rockettube"),
	))

/obj/item/factory_part/sadar_wp
	name = "SADAR WP missile asssembly"
	desc = "An unfinished white phosphorus missile."
	result = /obj/item/ammo_magazine/rocket/sadar/wp

/obj/item/factory_part/sadar_wp/Initialize()
	. = ..()
	recipe = GLOB.sadar_ammo_recipe

/obj/item/factory_part/sadar_ap
	name = "SADAR AP missile asssembly"
	desc = "An unfinished sleek missile with an AP warhead."
	result = /obj/item/ammo_magazine/rocket/sadar/ap

/obj/item/factory_part/sadar_ap/Initialize()
	. = ..()
	recipe = GLOB.sadar_ammo_recipe

/obj/item/factory_part/sadar_he
	name = "SADAR HE missile asssembly"
	desc = "An unfinished squat missile."
	result = /obj/item/ammo_magazine/rocket/sadar

/obj/item/factory_part/sadar_he/Initialize()
	. = ..()
	recipe = GLOB.sadar_ammo_recipe

GLOBAL_LIST_INIT(recoilless_missile_recipe, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "rockettube"),
	))

/obj/item/factory_part/light_rr_missile
	name = "Light Recoilless ammo assembly"
	desc = "An unfinished recoilless ammo. It has a particularily large booster."
	result = /obj/item/ammo_magazine/rocket/recoilless/light

/obj/item/factory_part/light_rr_missile/Initialize()
	. = ..()
	recipe = GLOB.recoilless_missile_recipe

/obj/item/factory_part/normal_rr_missile
	name = "Standard Recoilless ammo assembly"
	desc = "An unfinished squat missile. It has a particularily large warhead."
	result = /obj/item/ammo_magazine/rocket/recoilless

/obj/item/factory_part/normal_rr_missile/Initialize()
	. = ..()
	recipe = GLOB.recoilless_missile_recipe

GLOBAL_LIST_INIT(claymore_recipe, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "claymoreframe"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "claymorefilled"),
	))

/obj/item/factory_part/claymore
	name = "claymore assembly"
	desc = "An unfinished claymore"
	result = /obj/item/explosive/mine

/obj/item/factory_part/claymore/Initialize()
	. = ..()
	recipe = GLOB.claymore_recipe

GLOBAL_LIST_INIT(IFF_ammo, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "bulletbox"),
	))

/obj/item/factory_part/smartgunner_minigun_box
	name = "IFF bullet box"
	desc = "A box with unfinished smart-rounds inside"
	result = /obj/item/ammo_magazine/packet/smart_minigun

/obj/item/factory_part/smartgunner_minigun_box/Initialize()
	. = ..()
	recipe = GLOB.IFF_ammo

/obj/item/factory_part/smartgunner_machinegun_magazine
	name = "IFF drums box"
	desc = "A box with unfinished smart-rounds inside and empty drums inside"
	result = /obj/item/ammo_magazine/standard_smartmachinegun

/obj/item/factory_part/smartgunner_machinegun_magazine/Initialize()
	. = ..()
	recipe = GLOB.IFF_ammo

/obj/item/factory_part/auto_sniper_magazine
	name = "IFF high caliber bullet box"
	desc = "A box with unfinished high caliber smart-rounds inside"
	result = /obj/item/ammo_magazine/rifle/autosniper

/obj/item/factory_part/auto_sniper_magazine/Initialize()
	. = ..()
	recipe = GLOB.IFF_ammo

/obj/item/factory_part/scout_rifle_magazine
	name = "IFF high velocity bullet box"
	desc = "A box with unfinished high velocity smart-rounds inside"
	result = /obj/item/ammo_magazine/rifle/tx8

/obj/item/factory_part/scout_rifle_magazine/Initialize()
	. = ..()
	recipe = GLOB.IFF_ammo

GLOBAL_LIST_INIT(mateba_speedloader, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FLATTER, STEP_ICON_STATE = "bulletbox"),
	))

/obj/item/factory_part/mateba_speedloader
	name = "\improper Mateba speed loader (.454)"
	desc = "A speedloader with unfinished hand cannon rounds inside"
	result = /obj/item/ammo_magazine/revolver/mateba

/obj/item/factory_part/mateba_speedloader/Initialize()
	. = ..()
	recipe = GLOB.mateba_speedloader

GLOBAL_LIST_INIT(railgun_magazine, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FLATTER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "rockettube"),
	))

/obj/item/factory_part/railgun_magazine
	name = "Railgun round"
	desc = "An unfinished magnetically propelled steel rod"
	result = /obj/item/ammo_magazine/railgun

/obj/item/factory_part/railgun_magazine/Initialize()
	. = ..()
	recipe = GLOB.railgun_magazine
