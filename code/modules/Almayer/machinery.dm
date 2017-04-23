//-----USS Almayer Machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.

/obj/machinery/vending/marine/uniform_supply
	name = "\improper ColMarTech surplus uniform vender"
	desc = "A automated weapon rack hooked up to a colossal storage of uniforms"
	icon_state = "armory"
	icon_vend = "armory-vend"
	icon_deny = "armory"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/storage/backpack/marine = 10,
					/obj/item/device/radio/headset/msulaco = 10,
					/obj/item/weapon/storage/belt/marine = 10,
					/obj/item/clothing/shoes/marine = 10,
					/obj/item/clothing/under/marine = 10
					)

	prices = list()

	New()

		..()
		if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
			var/products2[]
			switch(squad_tag)
				if("Alpha")
					products2 = list(/obj/item/device/radio/headset/malpha = 20)
				if("Bravo")
					products2 = list(/obj/item/device/radio/headset/mbravo = 20)
				if("Charlie")
					products2 = list(/obj/item/device/radio/headset/mcharlie = 20)
				if("Delta")
					products2 = list(/obj/item/device/radio/headset/mdelta = 20)
			build_inventory(products2)
		marine_vendors.Add(src)



//-----USS Almayer Props -----//
//Put any props that don't function properly, they could function in the future but for now are for looks. This system could be expanded for other maps too. ~Art

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
	desc = "A small computer hooked up into the ships systems."

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

/obj/structure/prop/almayer/missile_rack
	name = "missile rack"
	desc = "A rack used for missiles, often even holding them."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "double"
	bound_x = 64
	bound_y = 32

/obj/structure/prop/almayer/missile_tube
	name = "missile tube"
	desc = "A cold launch missile tube."
	icon = 'icons/Marine/almayer_props96.dmi'
	icon_state = "missiletubenorth"
	bound_x = 32
	bound_y = 96

/obj/structure/prop/almayer/particle_cannon
	name = "phased pulse particle cannon"
	desc = "The main guns of a ship. Who would have known?"
	icon = 'icons/obj/machines/artillery.dmi'

/obj/structure/prop/almayer/name_stencil
	name = "USS Almayer"
	desc = "The name of the ship stenciled on the hull."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "almayer0"
	density = 0 //dunno who would walk on it, but you know.

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
	name = "dropship console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Almayer Dropship 1"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "22;200"

/obj/machinery/computer/shuttle_control/dropship1/onboard
	name = "flight controls"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	onboard = 1

/obj/machinery/computer/shuttle_control/dropship2
	name = "dropship console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Almayer Dropship 2"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "12;22;200"

/obj/machinery/computer/shuttle_control/dropship2/onboard
	name = "flight controls"
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
/obj/machinery/door/airlock/multi_tile/almayer
	name = "dropship cargo door"
	opacity = 1
	width = 3

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
			T.SetOpacity(opacity)
		else if(dir in list(EAST, WEST))
			var/turf/T = locate(x + i, y, z)
			T.SetOpacity(opacity)

/obj/machinery/door/airlock/multi_tile/almayer/open()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/almayer/close()
	. = ..()
	update_filler_turfs()

/obj/machinery/door/airlock/multi_tile/almayer/dropship1
	icon = 'icons/obj/doors/almayer/dropship1_cargo.dmi'

/obj/machinery/door/airlock/multi_tile/almayer/dropship2
	icon = 'icons/obj/doors/almayer/dropship2_cargo.dmi'

//------USS Almayer Door Section-----//
// This is going to be fucken huge. This is where all babeh perspective doors go to grow up.

/obj/machinery/door/airlock/almayer
	name = "airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
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
		/obj/structure/falsewall,
		/obj/structure/falserwall,
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
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/airlock/almayer/security
	name = "airlock"
	icon = 'icons/obj/doors/almayer/secdoor.dmi'
	req_access_txt = "3"

/obj/machinery/door/airlock/almayer/security/glass
	name = "airlock"
	icon = 'icons/obj/doors/almayer/secdoor_glass.dmi'
	opacity = 0

/obj/machinery/door/airlock/almayer/command
	name = "command airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/secure
	name = "secure airlock"
	icon = 'icons/obj/doors/almayer/securedoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/maint
	name = "maintenance hatch"
	icon = 'icons/obj/doors/almayer/maintdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/engineering
	name = "engineering airlock"
	icon = 'icons/obj/doors/almayer/engidoor.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/medical
	name = "medical airlock"
	icon = 'icons/obj/doors/almayer/medidoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/medical/glass
	name = "medical airlock"
	icon = 'icons/obj/doors/almayer/medidoor_glass.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/generic
	name = "airlock"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'

/obj/machinery/door/airlock/almayer/generic/corporate
	name = "Corporate Liason's Quarters"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'
	req_access_txt = "200"

/obj/machinery/door/airlock/almayer/marine
	name = "airlock"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/requisitions
	name = "requisitions"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;21"
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/alpha
	name = "alpha squad prep room"
	icon = 'icons/obj/doors/almayer/prepdoor_alpha.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;15"
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/alpha/sl
	name = "alpha squad leader prep"
	req_access_txt ="12;15"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/alpha/spec
	name = "alpha specialist prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/alpha/engineer
	name = "alpha squad engineer prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/alpha/medic
	name = "alpha squad medic prep"
	req_access_txt ="10;15"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/bravo
	name = "bravo squad prep room"
	icon = 'icons/obj/doors/almayer/prepdoor_bravo.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;16"
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/bravo/sl
	name = "bravo squad leader prep"
	req_access_txt ="12;16"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/bravo/spec
	name = "bravo specialist prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/bravo/engineer
	name = "bravo squad engineer prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/bravo/medic
	name = "bravo squad medic prep"
	req_access_txt ="10;16"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/charlie
	name = "charlie squad prep room"
	icon = 'icons/obj/doors/almayer/prepdoor_charlie.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;17"
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/charlie/sl
	name = "charlie squad leader prep"
	req_access_txt ="12;17"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/charlie/spec
	name = "charlie specialist prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/charlie/engineer
	name = "charlie squad engineer prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/charlie/medic
	name = "charlie squad medic prep"
	req_access_txt ="10;17"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/delta
	name = "delta squad prep room"
	icon = 'icons/obj/doors/almayer/prepdoor_delta.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;18"
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/delta/sl
	name = "delta squad leader prep"
	req_access_txt ="12;18"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/delta/spec
	name = "delta specialist prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/delta/engineer
	name = "delta squad engineer prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/delta/medic
	name = "delta squad medic prep"
	req_access_txt ="10;18"
	req_one_access_txt =  "0"
	dir = 2
	opacity = 0


// Double Doors

/obj/machinery/door/airlock/multi_tile/almayer
	name = "airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	openspeed = 4 //shorter open animation.
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/airlock/multi_tile/almayer/generic
	name = "airlock"
	icon = 'icons/obj/doors/almayer/2x1generic.dmi'
	opacity = 0

/obj/machinery/door/airlock/multi_tile/almayer/medidoor
	name = "airlock"
	icon = 'icons/obj/doors/almayer/2x1medidoor.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/multi_tile/almayer/comdoor
	name = "airlock"
	icon = 'icons/obj/doors/almayer/2x1comdoor.dmi'
	opacity = 0
	req_access_txt = "19"

/obj/machinery/door/firedoor/border_only/almayer
	name = "emergency shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/almayer/purinadoor.dmi'
	openspeed = 4