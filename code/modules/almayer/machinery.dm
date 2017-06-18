//-----USS Almayer Machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.

/obj/machinery/vending/uniform_supply
	name = "\improper ColMarTech surplus uniform vendor"
	desc = "A automated weapon rack hooked up to a colossal storage of uniforms"
	icon_state = "uniform_marine"
	icon_vend = "uniform_marine_vend"
	icon_deny = "uniform_marine"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/storage/backpack/marine = 10,
					/obj/item/weapon/storage/belt/marine = 10,
					/obj/item/clothing/shoes/marine = 10,
					/obj/item/clothing/under/marine = 10
					)

	prices = list()

	New()

		..()
		var/products2[]
		if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
			switch(squad_tag)
				if("Alpha")
					products2 = list(/obj/item/device/radio/headset/almayer/marine/alpha = 20,
									/obj/item/clothing/gloves/marine/alpha = 10)
				if("Bravo")
					products2 = list(/obj/item/device/radio/headset/almayer/marine/bravo = 20,
									/obj/item/clothing/gloves/marine/bravo = 10)
				if("Charlie")
					products2 = list(/obj/item/device/radio/headset/almayer/marine/charlie = 20,
									/obj/item/clothing/gloves/marine/charlie = 10)
				if("Delta")
					products2 = list(/obj/item/device/radio/headset/almayer/marine/delta = 20,
									/obj/item/clothing/gloves/marine/delta = 10)
		else
			products2 = list(/obj/item/device/radio/headset/almayer = 10,
							/obj/item/clothing/gloves/marine = 10)
		build_inventory(products2)
		marine_vendors.Add(src)



//-----USS Almayer Props -----//
//Put any props that don't function properly, they could function in the future but for now are for looks. This system could be expanded for other maps too. ~Art

/obj/item/prop/almayer
	name = "GENERIC USS ALMAYER PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P03' IF SEEN IN ROUND WITH LOCATION"
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "hangarbox"

/obj/item/prop/almayer/box
	name = "metal crate"
	desc = "A metal crate used often for storing small electronics that go into dropships"
	icon_state = "hangarbox"
	w_class = 4

/obj/item/prop/almayer/flight_recorder
	name = "\improper FR-112 flight recorder"
	desc = "A small red box that contains flight data from a dropship while its on mission. Usually refered to the black box, although this one comes in bloody red."
	icon_state = "flight_recorder"
	w_class = 4

/obj/item/prop/almayer/lantern_pod
	name = "\improper LANTERN pod"
	desc = "A long green box mounted into a dropship to provide various optical support for its ground targeting systems."
	icon_state = "lantern_pod"
	w_class = 4

/obj/item/prop/almayer/flare_launcher
	name = "\improper MJU-77/C case"
	desc = "A flare launcher that usually gets mounted onto dropships to help survivability against infrared tracking missiles."
	icon_state = "flare_launcher"
	w_class = 2

/obj/item/prop/almayer/chaff_launcher
	name = "\improper RR-247 Chaff case"
	desc = "A chaff launcher that usually gets mounted onto dropships to help survivability against radar tracking missiles."
	icon_state = "chaff_launcher"
	w_class = 3

/obj/item/prop/almayer/handheld1
	name = "small handheld"
	desc = "A small piece of electronic doodads"
	icon_state = "handheld1"
	w_class = 2

/obj/item/prop/almayer/comp_closed
	name = "dropship maintenance computer"
	desc = "A closed dropship maintenance computer that technicans and pilots use to find out whats wrong with a dropship. It has various outlets for different systems."
	icon_state = "hangar_comp"
	w_class = 4

/obj/item/prop/almayer/comp_open
	name = "dropship maintenance computer"
	desc = "A opened dropship maintenance computer, it seems to be off however. Its used by technicans and pilots to find damaged or broken systems on a dropship. It has various outlets for different systems."
	icon_state = "hangar_comp_open"
	w_class = 4

/obj/machinery/prop/almayer
	name = "GENERIC USS ALMAYER PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P01' IF SEEN IN ROUND WITH LOCATION"

/obj/machinery/prop/almayer/hangar/dropship_part_fabricator
	name = "dropship part fabricator"
	desc = "A large automated 3D printer for producing new dropship parts."

	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20

	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"


/obj/machinery/prop/almayer/computer/PC
	name = "personal desktop"
	desc = "A small computer hooked up into the ship's computer network."
	icon_state = "terminal1"

/obj/machinery/prop/almayer/computer
	name = "systems computer"
	desc = "A small computer hooked up into the ship's systems."

	density = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 20

	icon = 'icons/obj/almayer.dmi'
	icon_state = "terminal"

/obj/machinery/prop/almayer/CICmap
	name = "map table"
	desc = "A table that displays a map of the current target location"

	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20

	icon = 'icons/obj/almayer.dmi'
	icon_state = "maptable"

//Nonpower using props

/obj/structure/prop/almayer
	name = "GENERIC USS ALMAYER PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P02' IF SEEN IN ROUND WITH LOCATION"
	density = 1
	anchored = 1

/obj/structure/prop/almayer/minigun_crate
	name = "30mm ammo crate"
	desc = "A crate full of 30mm bullets used on one of the weapon pod types for the dropship. Moving this will require some sort of lifter."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "30mm_crate"


/obj/structure/prop/almayer/mission_planning_system
	name = "\improper MPS IV computer"
	desc = "The Mission Planning System IV (MPS IV), a enhancement in mission planning and charting for dropship pilots across the USCM. Fully capable of customizing their flight paths and loadouts to suit their combat needs."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "mps"

/obj/structure/prop/almayer/mapping_computer
	name = "\improper CMPS II computer"
	desc = "The Common Mapping Production System version II allows for sensory imput from satellites and ship systems to derive planetary maps in a standardized fashion for all USCM pilots."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "mapping_comp"

/obj/structure/prop/almayer/sensor_computer1
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "sensor_comp1"

/obj/structure/prop/almayer/sensor_computer2
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "sensor_comp2"

/obj/structure/prop/almayer/sensor_computer3
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "sensor_comp3"

/obj/structure/prop/almayer/missile_rack
	name = "\improper AIM-224 'Widowmaker'"
	desc = "The AIM-224 is the latest in air to air missile technology. Earning the nickname of 'Widowmaker' from various dropship pilots after improvements to its guidence warhead prevents it from being jammed leading to its high kill rate."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "double"
	bound_width = 64
	bound_height = 32

/obj/structure/prop/almayer/paveway_bomb
	name = "\improper GBU-67 'Keeper II'"
	desc = "The GBU-67 'Keeper II' is the latest in a generation of laser guided weaponry that spans all the way back to the 20th century. Earning its nickname from a shortening of 'Peacekeeper' which comes from the program that developed its guidance system and the various uses of it during peacekeeping conflicts."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "paveway"
	bound_width = 64
	bound_height = 32

/obj/structure/prop/almayer/banshee_missile
	name = "\improper AGM-227 'Banshee'"
	desc = "The AGM-227 missile is a mainstay of the overhauled dropship fleet against any mobile or armored ground targets. It's earned the nickname of 'Banshee' from the sudden wail that it emitts right before hitting a target."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "banshee"
	bound_width = 64
	bound_height = 32

/obj/structure/prop/almayer/gau_21
	name = "\improper GAU-21 30mm cannon"
	desc = "A dismounted GAU-21 'Rattler' 30mm rotary cannon. It seems to be missing its feed links and has exposed connection wires. Capable of firing 5200 rounds a minute, feared by many for its power. Earned the nickname 'Rattler' from the vibrations it would cause on dropships in its inital production run."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "30mm_cannon"
	bound_width = 64
	bound_height = 32

/obj/structure/prop/almayer/missile_tube
	name = "\improper Mk 33 ASAT launcher system"
	desc = "Cold launch tubes that can fire a few varieties of missiles out of them The most common being the ASAT-21 Rapier IV missile used against satellites and other spacecraft and the BGM-227 Sledgehammer missile which is used for ground attack."
	icon = 'icons/Marine/almayer_props96.dmi'
	icon_state = "missiletubenorth"
	bound_width = 32
	bound_height = 96
	unacidable = 1

/obj/structure/prop/almayer/ship_memorial
	name = "slab of victory"
	desc = "A ship memorial dedicated to the triumphs of the USCM and the fallen marines of this ship. On the left there are grand tales of victory etched into the slab. On the right there is a list of famous marines who have fallen in combat serving the USCM."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "ship_memorial"
	bound_width = 64
	bound_height = 32
	unacidable = 1

/obj/structure/prop/almayer/particle_cannon
	name = "\improper 0.75cm/140 Mark 74 General Atomics railgun"
	desc = "The Mark 74 Railgun is top of the line for space based weaponry. Capable of firing a round with a diameter of 3/4ths of a meter at 24 kilometers per second. It also is capable of using a variety of round types which can be interchanged at anytime with its newly designed feed system."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "1"
	unacidable = 1

/obj/structure/prop/almayer/name_stencil
	desc = "The name of the ship stenciled on the hull."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "almayer0"
	density = 0 //dunno who would walk on it, but you know.
	unacidable = 1

	New()
		..()
		name = MAIN_SHIP_NAME

/obj/structure/prop/almayer/hangar_stencil
	name = "floor"
	desc = "A large number stenciled on the hangar floor used to designate which dropship it is."
	icon = 'icons/Marine/almayer_props96.dmi'
	icon_state = "dropship1"
	density = 0
	layer = 2.1

//---USS Almayer Computers ---//

/obj/machinery/computer/overwatch/almayer
	density = 0
	icon = 'icons/obj/almayer.dmi'
	icon_state = "overwatch"

/obj/machinery/computer/security/almayer
	density = 0
	icon = 'icons/obj/almayer.dmi'
	icon_state = "security"

/obj/machinery/computer/shuttle_control/dropship1
	name = "\improper 'Alamo' dropship console"
	desc = "The remote controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"

	unacidable = 1
	exproof = 1
	req_one_access_txt = "22;200"

	New()
		..()
		shuttle_tag = "[MAIN_SHIP_NAME] Dropship 1"

/obj/machinery/computer/shuttle_control/dropship1/onboard
	name = "\improper 'Alamo' flight controls"
	desc = "The flight controls for the 'Alamo' Dropship. Named after the Alamo Mission, stage of the Battle of the Alamo in the United States' state of Texas in the Spring of 1836. The defenders held to the last, encouraging other Texians to rally to the flag."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	onboard = 1

/obj/machinery/computer/shuttle_control/dropship2
	name = "\improper 'Normandy' dropship console"
	desc = "The remote controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decivise victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "12;22;200"

	New()
		..()
		shuttle_tag = "[MAIN_SHIP_NAME] Dropship 2"

/obj/machinery/computer/shuttle_control/dropship2/onboard
	name = "\improper 'Normandy' flight controls"
	desc = "The flight controls for the 'Normandy' Dropship. Named after a department in France, noteworthy for the famous naval invasion of Normandy on the 6th of June 1944, a bloody but decivise victory in World War II and the campaign for the Liberation of France."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	onboard = 1

//---USS Almayer Lights -----//

/obj/machinery/light/almayer/New()
	..()
	switch(dir)
		if(1)	pixel_y = 23
		if(4)	pixel_x = 10
		if(8)	pixel_x = -10

// the smaller bulb light fixture

/obj/machinery/light/small/almayer/New()
	..()
	switch(dir)
		if(1)	pixel_y = 23
		if(4)	pixel_x = 10
		if(8)	pixel_x = -10

/obj/machinery/camera/autoname/almayer
	icon = 'icons/obj/almayer.dmi'

	New()
		..()
		switch(dir)
			if(1)	pixel_y = 40
			if(2)	pixel_y = -18
			if(4)	pixel_x = -27
			if(8)	pixel_x = 27

//------APCs ------//

/obj/machinery/power/apc/almayer
	icon = 'icons/obj/almayer.dmi'
	cell_type = /obj/item/weapon/cell/high
//------ Air Alarms -----//

/obj/machinery/alarm/almayer
	icon = 'icons/obj/almayer.dmi' // I made these really quickly because idk where they have their new air alarm ~Art

	New()
		..()
		switch(dir)
			if(1) pixel_y = 25
			if(2) pixel_y = 25

//------USS Almayer Tables ------//
/obj/structure/table/almayer
	icon = 'icons/obj/almayer.dmi'
	icon_state = "table"

//------Dropship Cargo Doors -----//
/obj/machinery/door/airlock/multi_tile/almayer //god damnit MSD, IT SHOULD BE WIDTH = 2 FOR ALL DOUBLE/BIGGER DOORS AT LEAST FOR THE BASE LINE
	name = "dropship cargo door"
	opacity = 1
	width = 2

/obj/machinery/door/airlock/multi_tile/almayer/handle_multidoor()
	if(!(width > 1)) return //Bubblewrap

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			T.SetOpacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			T.SetOpacity(opacity)

	if(dir in list(NORTH, SOUTH))
		bound_height = world.icon_size * width
	else if(dir in list(EAST, WEST))
		bound_width = world.icon_size * width

//We have to find these again since these doors are used on shuttles a lot so the turfs changes
/obj/machinery/door/airlock/multi_tile/almayer/proc/update_filler_turfs()

	for(var/i = 1, i < width, i++)
		if(dir in list(NORTH, SOUTH))
			var/turf/T = locate(x, y + i, z)
			if(T) T.SetOpacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			if(T) T.SetOpacity(opacity)

/obj/machinery/door/airlock/multi_tile/almayer/open()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/almayer/close()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/almayer/dropship1
	icon = 'icons/obj/doors/almayer/dropship1_cargo.dmi'
	width = 3

/obj/machinery/door/airlock/multi_tile/almayer/dropship2
	icon = 'icons/obj/doors/almayer/dropship2_cargo.dmi'
	width = 3

//------USS Almayer Door Section-----//
// This is going to be fucken huge. This is where all babeh perspective doors go to grow up.

/obj/machinery/door/airlock/almayer
	name = "\improper Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/poddoor/almayer
	icon = 'icons/obj/doors/almayer/blastdoors_shutters.dmi'
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/poddoor/shutters/almayer
	icon = 'icons/obj/doors/almayer/blastdoors_shutters.dmi'
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/airlock/almayer/security
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/almayer/secdoor.dmi'
	req_access_txt = "3"

/obj/machinery/door/airlock/almayer/security/glass
	name = "\improper Security Airlock"
	icon = 'icons/obj/doors/almayer/secdoor_glass.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/command
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/secure
	name = "\improper Secure Airlock"
	icon = 'icons/obj/doors/almayer/securedoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/maint
	name = "\improper Maintenance Hatch"
	icon = 'icons/obj/doors/almayer/maintdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/engineering
	name = "\improper Engineering Airlock"
	icon = 'icons/obj/doors/almayer/engidoor.dmi'
	opacity = 0
	glass = 1
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/medical
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/medical/glass
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor_glass.dmi'
	opacity = 0
	glass = 1
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/generic
	name = "\improper Airlock"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'

/obj/machinery/door/airlock/almayer/generic/corporate
	name = "Corporate Liason's Quarters"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'
	req_access_txt = "200"

/obj/machinery/door/airlock/almayer/marine
	name = "\improper Airlock"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/requisitions
	name = "\improper Requisitions Bay"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;21"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha
	name = "\improper Alpha Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_alpha.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;15"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/sl
	name = "\improper Alpha Squad Leader Preparations"
	req_access_txt ="12;15"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/spec
	name = "\improper Alpha Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/engineer
	name = "\improper Alpha Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/medic
	name = "\improper Alpha Squad Medic Preparations"
	req_access_txt ="10;15"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/alpha/smart
	name = "\improper Alpha Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo
	name = "\improper Bravo Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_bravo.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;16"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/sl
	name = "\improper Bravo Squad Leader Preparations"
	req_access_txt ="12;16"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/spec
	name = "\improper Bravo Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/engineer
	name = "\improper Bravo Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/medic
	name = "\improper Bravo Squad Medic Preparations"
	req_access_txt ="10;16"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/bravo/smart
	name = "\improper Bravo Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie
	name = "\improper Charlie Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_charlie.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;17"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/sl
	name = "\improper Charlie Squad Leader Preparations"
	req_access_txt ="12;17"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/spec
	name = "\improper Charlie Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/engineer
	name = "\improper Charlie Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/medic
	name = "\improper Charlie Squad Medic Preparations"
	req_access_txt ="10;17"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/charlie/smart
	name = "\improper Charlie Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta
	name = "\improper Delta Squad Preparations"
	icon = 'icons/obj/doors/almayer/prepdoor_delta.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;18"
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/sl
	name = "\improper Delta Squad Leader Preparations"
	req_access_txt ="12;18"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/spec
	name = "\improper Delta Squad Specialist Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/engineer
	name = "\improper Delta Squad Engineer Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/medic
	name = "\improper Delta Squad Medic Preparations"
	req_access_txt ="10;18"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/almayer/marine/delta/smart
	name = "\improper Delta Squad Smartgunner Preparations"
	req_access_txt ="0"
	req_one_access_txt =  "25"
	dir = 2
	opacity = 0
	glass = 1

// Double Doors

/obj/machinery/door/airlock/multi_tile/almayer
	name = "\improper Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/airlock/multi_tile/almayer/generic
	name = "\improper Airlock"
	icon = 'icons/obj/doors/almayer/2x1generic.dmi'
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/multi_tile/almayer/medidoor
	name = "\improper Medical Airlock"
	icon = 'icons/obj/doors/almayer/2x1medidoor.dmi'
	opacity = 0
	glass = 1
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/multi_tile/almayer/comdoor
	name = "\improper Command Airlock"
	icon = 'icons/obj/doors/almayer/2x1comdoor.dmi'
	opacity = 0
	glass = 1
	req_access_txt = "19"

/obj/machinery/door/firedoor/border_only/almayer
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/almayer/purinadoor.dmi'
	openspeed = 4


//------- Cryobag Recycler -------//
// Wanted to put this in, but since we still have extra time until tomorrow and this is really simple thing. It just recycles opened cryobags to make it nice-r for medics.
// Also the lack of sleep makes me keep typing cyro instead of cryo. FFS ~Art

/obj/machinery/cryobag_recycler
	name = "cryogenic bag recycler"
	desc = "A small tomb like structure. Capable of taking in used and opened cryobags and refill the liner and attach new sealants."
	icon = 'icons/Marine/almayer_props.dmi'
	icon_state = "recycler"

	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20

//What is this even doing? Why is it making a new item?
/obj/machinery/cryobag_recycler/attackby(obj/item/W, mob/user) //Hope this works. Don't see why not.
	..()
	if (istype(W, /obj/item))
		if(W.name == "used stasis bag") //possiblity for abuse, but fairly low considering its near impossible to rename something without VV
			var/obj/item/bodybag/cryobag/R = new /obj/item/bodybag/cryobag //lets give them the bag considering having it unfolded would be a pain in the ass.
			R.add_fingerprint(user)
			user.temp_drop_inv_item(W)
			cdel(W)
			user.put_in_hands(R)
			r_TRU
	..()

/obj/structure/closet/basketball
	name = "athletic wardrobe"
	desc = "It's a storage unit for athletic wear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/basketball/New()
	..()
	sleep(2)
	new /obj/item/clothing/under/shorts/grey(src)
	new /obj/item/clothing/under/shorts/black(src)
	new /obj/item/clothing/under/shorts/red(src)
	new /obj/item/clothing/under/shorts/blue(src)
	new /obj/item/clothing/under/shorts/green(src)
