/obj/effect/spawner/random/machinery
	name = "Random base machinery spawner"
	icon = 'icons/effects/random/machinery.dmi'
	icon_state = "random_frame"
	loot = list(
		/obj/structure/prop/mainship/errorprop,
	)

/obj/effect/spawner/random/machinery/status_display
	name = "random status display spawner"
	icon_state = "random_status_display"
	spawn_loot_chance = 95
	loot = list(
		/obj/machinery/status_display,
	)

/obj/effect/spawner/random/machinery/random_broken_computer
	name = "Generic broken computer spawner"
	name = "random broken computer spawner"
	icon_state = "random_broke_computer"
	loot = list(
		/obj/structure/prop/computer/broken = 20,
		/obj/structure/prop/computer/broken/two = 5,
		/obj/structure/prop/computer/broken/three = 20,
		/obj/structure/prop/computer/broken/four = 5,
		/obj/structure/prop/computer/broken/five = 20,
		/obj/structure/prop/computer/broken/six = 20,
		/obj/structure/prop/computer/broken/seven = 1,
		/obj/structure/prop/computer/broken/eight = 50,
		/obj/structure/prop/computer/broken/nine = 40,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/genetics
	name = "Genetics console or broken computer spawner"
	loot = list(
		/obj/machinery/prop/computer/dna = 75,
		/obj/effect/spawner/random/machinery/random_broken_computer = 25,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/crewmonitor
	name = "Crew monitor or broken computer spawner"
	loot = list(
		/obj/machinery/prop/computer/crew = 65,
		/obj/effect/spawner/random/machinery/random_broken_computer = 35,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/solars
	name = "Solars computer or broken computer spawner"
	loot = list(
		/obj/machinery/computer/solars = 80,
		/obj/effect/spawner/random/machinery/random_broken_computer = 20,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/rdconsole
	name = "RD console or broken computer spawner"
	loot = list(
		/obj/machinery/prop/computer/rdconsole = 85,
		/obj/effect/spawner/random/machinery/random_broken_computer = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/medicalrecords
	name = "Medical records or broken computer spawner"
	loot = list(
		/obj/machinery/computer/med_data = 75,
		/obj/effect/spawner/random/machinery/random_broken_computer = 25,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/intel
	name = "Intel computer or broken computer spawner"
	icon_state = "random_intel_computer"
	loot = list(
		/obj/machinery/computer/intel_computer = 90,
		/obj/effect/spawner/random/machinery/random_broken_computer = 10,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small
	name = "Generic small broken computer spawner"
	icon_state = "random_broke_computer_small"
	loot = list(
		/obj/structure/prop/computer/broken/eleven = 20,
		/obj/structure/prop/computer/broken/fifteen = 5,
		/obj/structure/prop/computer/broken/ten = 20,
		/obj/structure/prop/computer/broken/sixteen = 5,
		/obj/structure/prop/computer/broken/nineteen = 5,
		/obj/structure/prop/computer/broken/fourteen = 20,
		/obj/structure/prop/computer/broken/twelve = 20,
		/obj/structure/prop/computer/broken/seventeen = 1,
		/obj/structure/prop/computer/broken/thirteen = 50,
		/obj/structure/prop/computer/broken/eighteen = 40,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/meddata
	name = "Medical data or broken computer spawner"
	loot = list(
		/obj/machinery/computer/med_data/laptop = 85,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/security
	name = "Security console or broken computer spawner"
	loot = list(
		/obj/machinery/computer/security = 65,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 35,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/comms
	name = "Comms console prop or broken computer spawner"
	loot = list(
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 9,
		/obj/machinery/prop/computer/communications = 1,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/securityrecords
	name = "Security records or broken computer spawner"
	loot = list(
		/obj/machinery/computer/security = 85,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/stationalert
	name = "Station alert or broken computer spawner"
	loot = list(
		/obj/machinery/computer/station_alert = 85,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/atmosalert
	name = "Atmos alert or broken computer spawner"
	loot = list(
		/obj/machinery/computer/atmos_alert = 85,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/operatingcomputer
	name = "Operating computer or broken computer spawner"
	loot = list(
		/obj/machinery/computer/operating = 85,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/emails
	name = "Email computer or broken computer spawner"
	loot = list(
		/obj/machinery/computer/emails = 80,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)

/obj/effect/spawner/random/machinery/random_broken_computer/small/pc
	name = "Personal computer or broken computer spawner"
	loot = list(
		/obj/machinery/prop/computer/PC = 95,
		/obj/effect/spawner/random/machinery/random_broken_computer/small = 15,
	)


/obj/effect/spawner/random/machinery/disposal
	name = "disposal spawner"
	icon_state = "random_disposal"
	spawn_loot_chance = 90
	loot = list(
		/obj/machinery/disposal = 9,
		/obj/item/stack/sheet/metal = 1,
		/obj/effect/spawner/random/engineering/metal = 1,
	)

/obj/effect/spawner/random/machinery/hydrotray
	name = "hydro tray spawner"
	icon_state = "random_hydrotray"
	spawn_loot_chance = 65
	loot = list(
		/obj/machinery/hydroponics/slashable = 8,
		/obj/effect/spawner/random/misc/seeds = 1,
		/obj/effect/spawner/random/machinery/machine_frame = 1,
	)

/obj/effect/spawner/random/machinery/microwave
	name = "microwave spawner"
	icon_state = "random_microwave"
	spawn_loot_chance = 85
	loot = list(
		/obj/machinery/microwave = 8,
		/obj/effect/spawner/random/food_or_drink/outdoors_snacks = 2,
	)

/obj/effect/spawner/random/machinery/photocopier
	name = "filing photocopier or metal spawner"
	icon_state = "random_photocopier"
	spawn_loot_chance = 45
	loot = list(
		/obj/item/stack/sheet/metal,
		/obj/machinery/photocopier,
	)

/obj/effect/spawner/random/machinery/photocopier/highspawn
	spawn_loot_chance = 85


/obj/effect/spawner/random/machinery/machine_frame
	name = "machine frame spawner"
	icon_state = "random_frame"
	spawn_loot_chance = 50
	loot = list(
		/obj/machinery/constructable_frame,
		/obj/machinery/constructable_frame/state_2,
		/obj/structure/prop/machine_frame3,
		/obj/structure/computer3frame,
		/obj/item/frame/rack,
	)

/obj/effect/spawner/random/machinery/dead_ai
	name = "dead ai spawner"
	icon_state = "random_dead_ai"
	spawn_loot_chance = 15
	loot = list(
		/obj/structure/prop/mainship/deadai,
	)

/obj/effect/spawner/random/machinery/cryo
	name = "cryo spawner"
	icon_state = "random_cryo"
	spawn_loot_chance = 45
	loot = list(
		/obj/machinery/atmospherics/components/unary/cryo_cell = 7,
		/obj/effect/spawner/random/machinery/machine_frame = 2,
		/obj/effect/spawner/random/engineering/metal = 1,
	)

/obj/effect/spawner/random/machinery/motorbike
	name = "random motorcycle spawner"
	icon_state = "random_motorbike"
	loot = list(
		/obj/vehicle/ridden/motorbike,
	)

/obj/effect/spawner/random/machinery/motorbike/west
	spawn_loot_chance = 75
	spawn_force_direction = WEST
