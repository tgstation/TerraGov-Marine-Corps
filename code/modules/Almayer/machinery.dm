//-----USS Almayer Machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.

/obj/machinery/vending/marine/uniform_supply
	name = "ColMarTech Surplus Uniform Vender"
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


/obj/machinery/prop/almayer/computer
	name = "Personal Desktop"
	desc = "A small computer hooked up into the ship's computer network."

	density = 0
	anchored = 1
	use_power = 1
	idle_power_usage = 20

	icon = 'icons/obj/almayer.dmi'
	icon_state = "terminal1"

/obj/machinery/prop/almayer/CICmap
	name = "Map table"
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

/obj/structure/prop/almayer/nissile_rack
	name = "Missile Rack"
	desc = "A rack used for missiles, often even holding them."
	icon = 'icons/Marine/almayer_props64.dmi'
	icon_state = "double"
	bound_x = 64
	bound_y = 32

/obj/structure/prop/almayer/nissile_tube
	name = "Missile Tube"
	desc = "A cold launch missile tube."
	icon = 'icons/Marine/almayer_props96.dmi'
	icon_state = "missiletubenorth"
	bound_x = 32
	bound_y = 96

/obj/structure/prop/almayer/particle_cannon
	name = "Phased Pulse Particle Cannon"
	desc = "The main guns of a ship. Who would have known?"
	icon = 'icons/obj/machines/artillery.dmi'

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
	name = "Dropship Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Almayer Dropship 1"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "22;200"

/obj/machinery/computer/shuttle_control/dropship1/onboard
	name = "Flight Controls"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "console"
	onboard = 1

/obj/machinery/computer/shuttle_control/dropship2
	name = "Dropship Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	shuttle_tag = "Almayer Dropship 2"
	unacidable = 1
	exproof = 1
	req_one_access_txt = "12;22;200"

/obj/machinery/computer/shuttle_control/dropship2/onboard
	name = "Flight Controls"
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
			if(1)	pixel_y = 23
			if(4)	pixel_x = 10
			if(8)	pixel_x = -10
//------APCs ------//

/obj/machinery/power/apc/almayer
	icon = 'icons/obj/almayer.dmi'
	cell_type = /obj/item/weapon/cell/high

//------USS Almayer Tables ------//
/obj/structure/table/almayer
	icon = 'icons/obj/almayer.dmi'
	icon_state = "table"

//------Dropship Cargo Doors -----//
/obj/machinery/door/airlock/multi_tile/almayer/dropship1
	name = "Dropship Cargo door"
	icon = 'icons/obj/doors/almayer/dropship1_cargo.dmi'
	opacity = 0
	width = 3

/obj/machinery/door/airlock/multi_tile/almayer/dropship2
	name = "Dropship Cargo door"
	icon = 'icons/obj/doors/almayer/dropship2_cargo.dmi'
	opacity = 0
	width = 3

//------USS Almayer Door Section-----//
// This is going to be fucken huge. This is where all babeh perspective doors go to grow up.

/obj/machinery/door/airlock/almayer
	name = "Airlock"
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
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/secdoor.dmi'
	req_access_txt = "3"

/obj/machinery/door/airlock/almayer/security/glass
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/secdoor_glass.dmi'
	opacity = 0

/obj/machinery/door/airlock/almayer/command
	name = "Command Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/secure
	name = "Secure Airlock"
	icon = 'icons/obj/doors/almayer/securedoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/maint
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/almayer/maintdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/engineering
	name = "Engineering Airlock"
	icon = 'icons/obj/doors/almayer/engidoor.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/medical
	name = "Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/medical/glass
	name = "Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor_glass.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/generic
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/personaldoor.dmi'

/obj/machinery/door/airlock/almayer/marine
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	opacity = 0

/obj/machinery/door/airlock/almayer/marine/requisitions
	name = "Requisitions"
	icon = 'icons/obj/doors/almayer/prepdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;21"

/obj/machinery/door/airlock/almayer/marine/alpha
	name = "Alpha Squad Prep Room"
	icon = 'icons/obj/doors/almayer/prepdoor_alpha.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;15"

/obj/machinery/door/airlock/almayer/marine/alpha/sl
	name = "Alpha Squad Leader Prep"
	req_access_txt ="12;15"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/alpha/spec
	name = "Alpha Specialist Prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/alpha/engineer
	name = "Alpha Squad Engineer Prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/alpha/medic
	name = "Alpha Squad Medic Prep"
	req_access_txt ="10;15"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/bravo
	name = "Bravo Squad Prep Room"
	icon = 'icons/obj/doors/almayer/prepdoor_bravo.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;16"

/obj/machinery/door/airlock/almayer/marine/bravo/sl
	name = "Bravo Squad Leader Prep"
	req_access_txt ="12;16"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/bravo/spec
	name = "Bravo Specialist Prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/bravo/engineer
	name = "Bravo Squad Engineer Prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/bravo/medic
	name = "Bravo Squad Medic Prep"
	req_access_txt ="10;16"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/charlie
	name = "Charlie Squad Prep Room"
	icon = 'icons/obj/doors/almayer/prepdoor_charlie.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;17"

/obj/machinery/door/airlock/almayer/marine/charlie/sl
	name = "Charlie Squad Leader Prep"
	req_access_txt ="12;17"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/charlie/spec
	name = "Charlie Specialist Prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/charlie/engineer
	name = "Charlie Squad Engineer Prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/charlie/medic
	name = "Charlie Squad Medic Prep"
	req_access_txt ="10;17"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/delta
	name = "Delta Squad Prep Room"
	icon = 'icons/obj/doors/almayer/prepdoor_delta.dmi'
	req_access_txt = "9"
	req_one_access_txt =  "2;18"

/obj/machinery/door/airlock/almayer/marine/delta/sl
	name = "Delta Squad Leader Prep"
	req_access_txt ="12;18"
	req_one_access_txt =  "0"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/delta/spec
	name = "Delta Specialist Prep"
	req_access_txt ="0"
	req_one_access_txt =  "13"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/delta/engineer
	name = "Delta Squad Engineer Prep"
	req_access_txt ="0"
	req_one_access_txt =  "11"
	dir = 2

/obj/machinery/door/airlock/almayer/marine/delta/medic
	name = "Delta Squad Medic Prep"
	req_access_txt ="10;18"
	req_one_access_txt =  "0"
	dir = 2


// Double Doors

/obj/machinery/door/airlock/multi_tile/almayer
	name = "Airlock"
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
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/2x1generic.dmi'
	opacity = 0

/obj/machinery/door/airlock/multi_tile/almayer/medidoor
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/2x1medidoor.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/multi_tile/almayer/comdoor
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/2x1comdoor.dmi'
	opacity = 0
	req_access_txt = "19"