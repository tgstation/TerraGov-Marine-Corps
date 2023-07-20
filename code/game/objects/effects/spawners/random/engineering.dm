/obj/effect/spawner/random/engineering
	name = "Random base engineering spawner"
	icon = 'icons/effects/random/engineering.dmi'
	icon_state = "random_tool"
	loot = list(
		/obj/structure/prop/mainship/errorprop,
	)

/obj/effect/spawner/random/engineering/tool
	name = "Random Tool"
	icon_state = "random_tool"
	loot = list(
		/obj/item/tool/screwdriver,
		/obj/item/tool/wirecutters,
		/obj/item/tool/weldingtool,
		/obj/item/tool/crowbar,
		/obj/item/tool/wrench,
		/obj/item/flashlight,
	)

/obj/effect/spawner/random/engineering/technology_scanner
	name = "Random Scanner"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "atmos"
	loot = list(
		/obj/item/t_scanner = 4,
		/obj/item/radio = 2,
		/obj/item/tool/analyzer = 4,
	)

/obj/effect/spawner/random/engineering/powercell
	name = "Random Powercell"
	icon_state = "random_cell"
	loot = list(
		/obj/item/cell = 40,
		/obj/item/cell/high = 40,
		/obj/item/cell/crap = 10,
		/obj/item/cell/super = 9,
		/obj/item/cell/hyper = 1,
	)

/obj/effect/spawner/random/engineering/pickaxe
	name = "Random pickaxe spawner"
	icon_state = "random_pickaxe"
	loot = list(
		/obj/item/tool/pickaxe = 600,
		/obj/item/tool/pickaxe/drill = 100,
		/obj/item/tool/pickaxe/borgdrill = 100,
		/obj/item/tool/pickaxe/plasmacutter = 10, //10 in 800 chance of showing up
	)

/obj/effect/spawner/random/engineering/shovel
	name = "Random digging instrument spawner"
	icon_state = "random_shovel"
	loot = list(
		/obj/item/tool/shovel = 700,
		/obj/effect/spawner/random/engineering/pickaxe = 100,
	)

/obj/effect/spawner/random/engineering/bomb_supply
	name = "Bomb Supply"
	icon_state = "random_scanner"
	loot = list(
		/obj/item/assembly/igniter,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/signaler,
		/obj/item/tool/multitool,
	)

/obj/effect/spawner/random/engineering/toolbox
	name = "Random Toolbox"
	icon_state = "random_toolbox"
	loot = list(
		/obj/item/storage/toolbox/mechanical = 5,
		/obj/item/storage/toolbox/electrical = 3,
		/obj/item/storage/toolbox/emergency = 2,
	)

/obj/effect/spawner/random/engineering/tech_supply
	name = "Random Tech Supply"
	icon_state = "random_cell"
	spawn_loot_chance = 50
	loot = list(
		/obj/effect/spawner/random/engineering/powercell = 3,
		/obj/effect/spawner/random/engineering/technology_scanner = 2,
		/obj/item/packageWrap = 1,
		/obj/effect/spawner/random/engineering/bomb_supply = 2,
		/obj/item/tool/extinguisher = 1,
		/obj/item/clothing/gloves/yellow = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/effect/spawner/random/engineering/toolbox = 2,
		/obj/item/storage/belt/utility = 2,
		/obj/effect/spawner/random/engineering/tool = 5,
	)

/obj/effect/spawner/random/engineering/structure/gascan
	name = "gascan spawner"
	icon_state = "random_gascan"
	spawn_loot_chance = 85
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/reagent_containers/jerrycan,
	)

/obj/effect/spawner/random/engineering/structure/handheld_lighting
	name = "handheld lighting spawner"
	icon_state = "random_lighting"
	spawn_loot_chance = 80
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/flashlight = 15,
		/obj/item/explosive/grenade/flare/civilian = 5,
		/obj/item/flashlight/lantern = 1,
		/obj/item/flashlight/pen = 1,
	)

/obj/effect/spawner/random/engineering/fuelcell
	name = "Random fuel cell spawner"
	icon_state = "random_fuelcell"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/fuel_cell/random,
		/obj/item/fuel_cell/medium,
		/obj/item/fuel_cell/low,
		/obj/item/fuel_cell/high,
		/obj/item/fuel_cell/full,
	)

/obj/effect/spawner/random/engineering/fuelcell/fullweighted
	loot = list(
		/obj/item/fuel_cell/full = 9,
		/obj/effect/spawner/random/engineering/fuelcell = 1,
	)

/obj/effect/spawner/random/engineering/engibelt
	name = "Random engi belt spawner"
	icon_state = "random_engibelt"
	spawn_loot_chance = 45
	loot = list(
		/obj/item/storage/belt/utility = 50,
		/obj/effect/spawner/random/engineering/tool = 25,
		/obj/effect/spawner/random/engineering/toolbox = 15,
		/obj/item/storage/belt/utility/full = 10,
		/obj/item/storage/belt/utility/atmostech = 10,
	)

/obj/effect/spawner/random/engineering/engibelt/emptyornot
	spawn_loot_chance = 90
	loot = list(
		/obj/item/storage/belt/utility/full = 90,
		/obj/item/storage/belt/utility = 10,
	)

/obj/effect/spawner/random/engineering/cable
	name = "Random cable spawner"
	icon_state = "random_cable"
	spawn_random_offset = TRUE
	spawn_loot_chance = 90
	loot = list(
		/obj/item/stack/cable_coil = 75,
		/obj/item/stack/cable_coil/cut = 30,
		/obj/item/stack/cable_coil/twentyfive = 25,
		/obj/item/stack/cable_coil/five = 10,
	)

/obj/effect/spawner/random/engineering/metal
	name = "metal spawner"
	icon_state = "random_metal"
	spawn_loot_chance = 80
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/stack/sheet/metal = 70,
		/obj/item/stack/sheet/metal/small_stack = 55,
		/obj/item/stack/sheet/metal/medium_stack = 10,
		/obj/item/stack/sheet/metal/large_stack = 2,
	)

/obj/effect/spawner/random/engineering/metal/nooffset
	spawn_random_offset = FALSE

/obj/effect/spawner/random/engineering/plasteel
	name = "plasteel spawner"
	icon_state = "random_plasteel"
	spawn_loot_chance = 75
	loot = list(
		/obj/item/stack/sheet/plasteel = 55,
		/obj/item/stack/sheet/plasteel/small_stack = 35,
		/obj/item/stack/sheet/plasteel/medium_stack = 10,
		/obj/item/stack/sheet/plasteel/large_stack = 3,
	)

/obj/effect/spawner/random/engineering/wood
	name = "wood spawner"
	icon_state = "random_wood"
	spawn_loot_chance = 80
	spawn_random_offset = TRUE
	loot = list(
		/obj/item/stack/sheet/wood = 15,
		/obj/item/stack/sheet/wood/large_stack = 5,
	)

/obj/effect/spawner/random/engineering/glass
	name = "glass spawner"
	icon_state = "random_glass"
	spawn_loot_chance = 90
	loot = list(
		/obj/item/stack/sheet/glass = 25,
		/obj/item/stack/sheet/glass/large_stack = 1,
	)

/obj/effect/spawner/random/engineering/insulatedgloves
	name = "insulated glove spawner"
	icon_state = "random_insuls"
	spawn_scatter_radius = 1
	spawn_random_offset = TRUE
	spawn_loot_chance = 65
	loot = list(
		/obj/item/clothing/gloves/yellow = 85,
		/obj/item/clothing/gloves/insulated = 15,
	)

/obj/effect/spawner/random/engineering/insulatedgloves/nooffset
	spawn_scatter_radius = 0
	spawn_random_offset = FALSE
	spawn_loot_chance = 65

/obj/effect/spawner/random/engineering/radio
	name = "radio spawner"
	icon_state = "random_radio"
	spawn_loot_chance = 35
	loot = list(
		/obj/item/radio/survivor,
	)

/obj/effect/spawner/random/engineering/radio/highspawn
	spawn_loot_chance = 90


/obj/effect/spawner/random/engineering/structure/powergenerator
	name = "generator spawner"
	icon_state = "random_generator"
	spawn_loot_chance = 75
	loot = list(
		/obj/machinery/power/port_gen/pacman = 9,
		/obj/machinery/power/port_gen/pacman/mrs = 1,
	)

/obj/effect/spawner/random/engineering/structure/powergenerator/superweighted
	spawn_loot_chance = 90
	icon_state = "random_generator_super"
	loot = list(
		/obj/machinery/power/port_gen/pacman/super = 9,
		/obj/effect/spawner/random/engineering/structure/powergenerator = 1,
	)



/obj/effect/spawner/random/engineering/structure/tank_dispenser
	name = "tank dispenser spawner"
	icon_state = "random_dispenser"
	loot = list(
		/obj/structure/dispenser/oxygen,
		/obj/structure/dispenser/phoron,
	)

/obj/effect/spawner/random/engineering/structure/tank_dispenser/oxygenweighted
	loot = list(
		/obj/structure/dispenser/oxygen = 8,
		/obj/structure/dispenser/phoron = 2,
	)

/obj/effect/spawner/random/engineering/structure/tank_dispenser/phoronweighted
	loot = list(
		/obj/structure/dispenser/phoron = 8,
		/obj/structure/dispenser/oxygen = 2,
	)

/obj/effect/spawner/random/engineering/structure/tank
	name = "tank spawner"
	icon_state = "random_watertank"
	loot = list(
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/reagent_dispensers/watertank,
	)

/obj/effect/spawner/random/engineering/structure/tank/fuelweighted
	name = "fuel weighted tank spawner"
	icon_state = "random_weldtank"
	loot = list(
		/obj/structure/reagent_dispensers/fueltank = 8,
		/obj/structure/reagent_dispensers/watertank = 2,
	)

/obj/effect/spawner/random/engineering/structure/tank/waterweighted
	name = "water weighted tank spawner"
	icon_state = "random_watertank"
	loot = list(
		/obj/structure/reagent_dispensers/fueltank = 3,
		/obj/structure/reagent_dispensers/watertank = 7,
	)

/obj/effect/spawner/random/engineering/structure/atmospherics_portable
	name = "portable atmospherics machine spawner"
	icon_state = "random_heater"
	loot = list(
		/obj/machinery/space_heater = 8,
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1,
	)

/obj/effect/spawner/random/engineering/structure/atmospherics_portable/icecolony
	loot = list(
		/obj/machinery/space_heater = 20,
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1,
	)

/obj/effect/spawner/random/engineering/computercircuit
	name = "Random computer circuit spawner"
	icon_state = "random_ccircuit"
	spawn_loot_chance = 75
	loot_subtype_path = /obj/item/circuitboard/computer
	loot = list()

/obj/effect/spawner/random/engineering/structure/random_tank_holder
	name = "random tankholder spawner"
	icon_state = "random_tank_holder"
	loot = list(
		/obj/structure/tankholder,
		/obj/structure/tankholder/oxygen,
		/obj/structure/tankholder/oxygentwo,
		/obj/structure/tankholder/oxygenthree,
		/obj/structure/tankholder/generic,
		/obj/structure/tankholder/extinguisher,
		/obj/structure/tankholder/foamextinguisher,
		/obj/structure/tankholder/anesthetic,
		/obj/structure/tankholder/emergencyoxygen,
		/obj/structure/tankholder/emergencyoxygentwo,
	)

/obj/effect/spawner/random/engineering/structure/canister
	name = "air canister spawner"
	icon_state = "random_canister"
	loot = list(
		/obj/machinery/portable_atmospherics/canister/air = 4,
		/obj/machinery/portable_atmospherics/canister/oxygen = 1,
	)

/obj/effect/spawner/random/engineering/assemblies
	name = "random assembly spawner"
	icon_state = "random_assembly"
	loot_subtype_path = /obj/item/assembly
	loot = list()

/obj/effect/spawner/random/engineering/mineral
	name = "mineral spawner"
	icon_state = "random_mineral"
	spawn_loot_chance = 70
	loot_subtype_path = /obj/item/stack/sheet/mineral
	loot = list()

/obj/effect/spawner/random/engineering/extinguisher
	name = "extinguisher spawner"
	icon_state = "random_extinguisher"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/tool/extinguisher,
		/obj/item/tool/extinguisher/mini,
	)

/obj/effect/spawner/random/engineering/extinguisher/regularweighted
	name = "extinguisher spawner"
	spawn_loot_chance = 95
	loot = list(
		/obj/item/tool/extinguisher = 10,
		/obj/item/tool/extinguisher/mini = 2,
	)

/obj/effect/spawner/random/engineering/extinguisher/miniweighted
	name = "extinguisher spawner"
	spawn_loot_chance = 95
	icon_state = "random_extinguisher_mini"
	loot = list(
		/obj/item/tool/extinguisher/mini = 10,
		/obj/item/tool/extinguisher = 2,
	)

/obj/effect/spawner/random/engineering/ore_box
	name = "ore box spawner"
	icon_state = "random_orebox"
	spawn_loot_chance = 40
	loot = list(
		/obj/structure/ore_box = 10,
		/obj/effect/spawner/random/engineering/mineral = 1,
	)
