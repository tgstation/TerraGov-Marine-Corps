//// NEW TYPES ////

GLOBAL_LIST_INIT(weapon, list(
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_DRILLER, STEP_ICON_STATE = "req_empty_box1_s"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_COMPRESSOR, STEP_ICON_STATE = "req_empty_box1"),
	list(STEP_NEXT_MACHINE = FACTORY_MACHINE_FORMER, STEP_ICON_STATE = "hotplate"),
	))
/obj/item/factory_part/basic_rifle
	name = "unfinished AR12 parts"
	desc = "A box with unfinished rifle parts inside."
	result = /obj/item/weapon/gun/rifle/standard_assaultrifle

/obj/item/factory_part/basic_rifle/Initialize(mapload)
	. = ..()
	recipe = GLOB.weapon

/obj/item/factory_part/basic_sniper
	name = "unfinished SR127 parts"
	desc = "A box with unfinished sniper rifle parts inside."
	result = /obj/item/weapon/gun/rifle/chambered

/obj/item/factory_part/basic_sniper/Initialize(mapload)
	. = ..()
	recipe = GLOB.weapon

/obj/item/factory_part/light_sentry
	name = "unfinished ST480 parts"
	desc = "A box with sentry gun parts inside."
	result = /obj/item/storage/box/crate/minisentry

/obj/item/factory_part/light_sentry/Initialize(mapload)
	. = ..()
	recipe = GLOB.weapon

/obj/item/factory_part/automated_drone/nut
	name = "unfinished NUT parts"
	desc = "A box with drone parts inside."
	result = /obj/item/weapon/gun/rifle/drone/nut

/obj/item/factory_part/automated_drone/Initialize(mapload)
	. = ..()
	recipe = GLOB.weapon


//// ANTAG CONVERTED TYPES ////

/obj/item/factory_part/phosnade/upp
	name = "phosphorus grenade assembly"
	desc = "A incomplete phosphorus grenade assembly"
	result = /obj/item/explosive/grenade/phosphorus/upp

/obj/item/factory_part/sadar_wp/som_incind
	name = "84mm Thermobaric missile asssembly"
	desc = "An unfinished thermobaric missile."
	result = /obj/item/ammo_magazine/rocket/som/incendiary

/obj/item/factory_part/sadar_ap/som_heat
	name = "84mm HEAT asssembly"
	desc = "An unfinished sleek missile with a HEAT warhead."
	result = /obj/item/ammo_magazine/rocket/som/heat

/obj/item/factory_part/sadar_he/som_he
	name = "84mm HE missile asssembly"
	desc = "An unfinished High Explosive missile."
	result = /obj/item/ammo_magazine/rocket/som


/obj/item/factory_part/module_valk/apollo
	name = "\improper Apollo automedical armor system"
	desc = "An unfinished Apollo automedical armor system module."
	result = /obj/item/armor_module/module/valkyrie_autodoc/som

/obj/item/factory_part/module_surt/hades
	name = "\improper Hades incendiary insulation system"
	desc = "An unfinished Hades incendiary insulation system module."
	result = list(
		/obj/item/armor_module/module/fire_proof/som,
		/obj/item/clothing/head/modular/som/hades,
	)

/obj/item/factory_part/basic_rifle/v31
	name = "unfinished V31 parts"
	desc = "A box with unfinished rifle parts inside."
	result = /obj/item/weapon/gun/rifle/som

/obj/item/factory_part/basic_sniper/svd
	name = "unfinished Dragunov parts"
	desc = "A box with unfinished sniper rifle parts inside."
	result = /obj/item/weapon/gun/rifle/sniper/svd

/obj/item/factory_part/light_sentry/cope
	name = "unfinished COPE parts"
	desc = "A box with sentry gun parts inside."
	result = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope
