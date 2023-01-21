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
		if(islist(result))
			for(var/production AS in result)
				GLOB.round_statistics.req_items_produced[production]++
				new production(loc)
		else
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
	result = /obj/item/reagent_containers/food/snacks/req_pizza

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

/obj/item/factory_part/amr_magazine
	name = "IFF antimaterial bullet box"
	desc = "A box with unfinished antimaterial rifle rounds inside"
	result = /obj/item/ammo_magazine/sniper

/obj/item/factory_part/amr_magazine/Initialize()
	. = ..()
	recipe = GLOB.IFF_ammo

/obj/item/factory_part/amr_magazine_incend
	name = "IFF antimaterial Incendiary bullet box"
	desc = "A box with unfinished antimaterial Incendiary rifle rounds inside"
	result = /obj/item/ammo_magazine/sniper/incendiary

/obj/item/factory_part/amr_magazine_incend/Initialize()
	. = ..()
	recipe = GLOB.IFF_ammo

/obj/item/factory_part/amr_magazine_flak
	name = "IFF antimaterial Flak bullet box"
	desc = "A box with unfinished antimaterial rifle Flak rounds inside"
	result = /obj/item/ammo_magazine/sniper/flak

/obj/item/factory_part/amr_magazine_flak/Initialize()
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

GLOBAL_LIST_INIT(minigun_powerpack, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "hotplate"),
	))
/obj/item/factory_part/minigun_powerpack
	name = "Minigun powerpack"
	desc = "A powerpack with unfinished minigun rounds inside"
	result = /obj/item/ammo_magazine/minigun_powerpack

/obj/item/factory_part/minigun_powerpack/Initialize()
	. = ..()
	recipe = GLOB.minigun_powerpack

GLOBAL_LIST_INIT(razornade, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "roundplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "cutplate"),
	))
/obj/item/factory_part/razornade
	name = "Razorfoam grenade"
	desc = "An unfinished Razorfoam grenade casing"
	result = /obj/item/explosive/grenade/chem_grenade/razorburn_smol

/obj/item/factory_part/razornade/Initialize()
	. = ..()
	recipe = GLOB.razornade

GLOBAL_LIST_INIT(howitzer_shell, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_DRILLER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_COMPRESSOR, STEP_ICON_STATE = "barrelplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_GALVANIZER, STEP_ICON_STATE = "rockettube"),
	))
/obj/item/factory_part/howitzer_shell_he
	name = "Howitzer shell"
	desc = "An unfinished High Explosive Howitzer shell"
	result = /obj/item/mortal_shell/howitzer/he

/obj/item/factory_part/howitzer_shell_he/Initialize()
	. = ..()
	recipe = GLOB.howitzer_shell

/obj/item/factory_part/howitzer_shell_incen
	name = "Howitzer shell"
	desc = "An unfinished Incendiary Howitzer shell"
	result = /obj/item/mortal_shell/howitzer/incendiary

/obj/item/factory_part/howitzer_shell_incen/Initialize()
	. = ..()
	recipe = GLOB.howitzer_shell

/obj/item/factory_part/howitzer_shell_wp
	name = "Howitzer shell"
	desc = "An unfinished White Phosphorus Howitzer shell"
	result = /obj/item/mortal_shell/howitzer/white_phos

/obj/item/factory_part/howitzer_shell_wp/Initialize()
	. = ..()
	recipe = GLOB.howitzer_shell

/obj/item/factory_part/howitzer_shell_tfoot
	name = "Howitzer shell"
	desc = "An unfinished High Explosive Howitzer shell"
	result = /obj/item/mortal_shell/howitzer/plasmaloss

/obj/item/factory_part/howitzer_shell_tfoot/Initialize()
	. = ..()
	recipe = GLOB.howitzer_shell

GLOBAL_LIST_INIT(swat_mask, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_COMPRESSOR, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_GALVANIZER, STEP_ICON_STATE = "steelingot"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "req_bag4"),
	))

/obj/item/factory_part/swat_mask
	name = "SWAT mask"
	desc = "An unfinished SWAT mask assembly"
	result = /obj/item/clothing/mask/gas/swat

/obj/item/factory_part/swat_mask/Initialize()
	. = ..()
	recipe = GLOB.swat_mask

GLOBAL_LIST_INIT(meds, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FLATTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_COMPRESSOR, STEP_ICON_STATE = "req_bag3"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_DRILLER, STEP_ICON_STATE = "req_bag1"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_GALVANIZER, STEP_ICON_STATE = "req_bag2"),
	))

/obj/item/factory_part/med_advpack
	name = "Advanced First-Aid kit"
	desc = "An unfinished Advanced First-Aid kit"
	result = list(
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
	)

/obj/item/factory_part/med_advpack/Initialize()
	. = ..()
	recipe = GLOB.meds

GLOBAL_LIST_INIT(module, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FLATTER, STEP_ICON_STATE = "roundplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_DRILLER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "barrelplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_COMPRESSOR, STEP_ICON_STATE = "unfinished_module_top"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_GALVANIZER, STEP_ICON_STATE = "unfinished_module_bottom"),
	))

/obj/item/factory_part/module_valk
	name = "Valkyrie Automedical Armor System"
	desc = "An unfinished Valkyrie Automedical Armor System module"
	result = /obj/item/armor_module/module/valkyrie_autodoc

/obj/item/factory_part/module_valk/Initialize()
	. = ..()
	recipe = GLOB.module

/obj/item/factory_part/module_mimir2
	name = "Mark 2 Mimir Environmental Resistance System"
	desc = "An unfinished Mark 2 Mimir Environmental Resistance System module"
	result = list(
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
	)

/obj/item/factory_part/module_mimir2/Initialize()
	. = ..()
	recipe = GLOB.module

/obj/item/factory_part/module_tyr2
	name = "Mark 2 Tyr Armor Reinforcement"
	desc = "An unfinished Mark 2 Tyr Armor Reinforcement module"
	result = /obj/item/armor_module/module/tyr_extra_armor

/obj/item/factory_part/module_tyr2/Initialize()
	. = ..()
	recipe = GLOB.module

/obj/item/factory_part/module_hlin
	name = "Hlin Explosive Compensation Module"
	desc = "An unfinished Hlin Explosive Compensation module"
	result = /obj/item/armor_module/module/hlin_explosive_armor

/obj/item/factory_part/module_hlin/Initialize()
	. = ..()
	recipe = GLOB.module

/obj/item/factory_part/module_surt
	name = "Surt Pyrotechnical Insulation System"
	desc = "An unfinished Surt Pyrotechnical Insulation System module"
	result = /obj/item/armor_module/module/fire_proof

/obj/item/factory_part/module_surt/Initialize()
	. = ..()
	recipe = GLOB.module
GLOBAL_LIST_INIT(mortar_shell, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_DRILLER, STEP_ICON_STATE = "hotplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CONSTRUCTOR, STEP_ICON_STATE = "rockettube"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_GALVANIZER, STEP_ICON_STATE = "rockettube"),
	))

/obj/item/factory_part/mortar_shell_he
	name = "Mortar shell"
	desc = "An unfinished High Explosive Mortar shell"
	result = /obj/item/mortal_shell/he

/obj/item/factory_part/mortar_shell_he/Initialize()
	. = ..()
	recipe = GLOB.mortar_shell

/obj/item/factory_part/mortar_shell_incen
	name = "Mortar shell"
	desc = "An unfinished Incendiary Mortar shell"
	result = /obj/item/mortal_shell/incendiary

/obj/item/factory_part/mortar_shell_incen/Initialize()
	. = ..()
	recipe = GLOB.mortar_shell

/obj/item/factory_part/mortar_shell_flare
	name = "Mortar shell"
	desc = "An unfinished Flare Mortar shell"
	result = /obj/item/mortal_shell/flare

/obj/item/factory_part/mortar_shell_flare/Initialize()
	. = ..()
	recipe = GLOB.mortar_shell

/obj/item/factory_part/mortar_shell_tfoot
	name = "Mortar shell"
	desc = "An unfinished Flare Mortar shell"
	result = /obj/item/mortal_shell/plasmaloss

/obj/item/factory_part/mortar_shell_tfoot/Initialize()
	. = ..()
	recipe = GLOB.mortar_shell

GLOBAL_LIST_INIT(mlrs_rocket, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_CUTTER, STEP_ICON_STATE = "uncutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_HEATER, STEP_ICON_STATE = "cutplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_DRILLER, STEP_ICON_STATE = "hotplate"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_COMPRESSOR, STEP_ICON_STATE = "rockettube"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_GALVANIZER, STEP_ICON_STATE = "rockettube"),
	))

/obj/item/factory_part/mlrs_rocket
	name = "MLRS rocket"
	desc = "An unfinished high explosive rocket"
	result = /obj/item/storage/box/mlrs_rockets

/obj/item/factory_part/mlrs_rockets/Initialize()
	. = ..()
	recipe = GLOB.mlrs_rocket
