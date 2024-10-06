//Large vehicles need overlays for correct cropping
/obj/structure/prop/urban/vehicles/large
	icon = 'icons/obj/structures/prop/urban/128x32_vehiclesexpanded.dmi'
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/urban/vehicles/large/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/prop/urban/vehicles/large/setDir(newdir)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/prop/urban/vehicles/large/update_overlays()
	. = ..()
	switch(dir) //Todo: Consolidate the overlays into a single overlay state per icon instead of 4
		if(NORTH)
			. += image(icon, src, "[initial(icon_state)]_top_r", layer = ABOVE_ALL_MOB_LAYER)
		if(SOUTH)
			. += image(icon, src, "[initial(icon_state)]_top_l", layer = ABOVE_ALL_MOB_LAYER)
		if(WEST)
			. += image(icon, src, "[initial(icon_state)]_top_rb", layer = ABOVE_ALL_MOB_LAYER)
		if(EAST)
			. += image(icon, src, "[initial(icon_state)]_top_lb", layer = ABOVE_ALL_MOB_LAYER)

/obj/structure/prop/urban/vehicles/large/ambulance
	name = "ambulance"
	desc = "Seems to be broken down."
	icon_state = "ambulance"
	bound_height = 32
	bound_width = 96

// Armored Truck

/obj/structure/prop/urban/vehicles/large/armored_trucks
	icon_state = "armoredtruck_wy_security_1"
	bound_height = 32
	bound_width = 96

/obj/structure/prop/urban/vehicles/large/armored_trucks/nt_security/truck_1
	name = "\improper Nanotrasen security truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_nt_security_1"

/obj/structure/prop/urban/vehicles/large/armored_trucks/nt_security/truck_2
	name = "\improper Nanotrasen security truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_nt_security_2"

// Armored Truck Goods
/obj/structure/prop/urban/vehicles/large/armored_trucks/heavy_loader/white
	name = "heavy loader truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_white_white"

/obj/structure/prop/urban/vehicles/large/armored_trucks/heavy_loader/white_teal
	name = "heavy loader truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_white_teal"

/obj/structure/prop/urban/vehicles/large/armored_trucks/heavy_loader/blue_white
	name = "heavy loader truck"
	desc = "Seems to be broken down."
	icon_state = "armoredtruck_blue_white"

// Mega-Hauler Trucks 128x64

/obj/structure/prop/urban/vehicles/large/mega_hauler_truck
	name = "mega-hauler truck"
	icon_state = "longtruck_kellandmining"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/128x32_vehiclesexpanded.dmi'
	bound_height = 32
	bound_width = 128
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 1000 //mega hauler trucks are still tanks that soak up fire
	coverage = 100
	soft_armor = list(MELEE = 30, BULLET = 90, LASER = 95, ENERGY = 55, BOMB = 60, BIO = 10, FIRE = 10, ACID = 10)


/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/kelland
	icon_state = "longtruck_kellandmining"

/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/red_stripe
	icon_state = "longtruck_blue_redstripe"

/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/blue_stripe
	icon_state = "longtruck_red_bluestripe"

/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/brown
	icon_state = "longtruck_brown"

/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/donk
	icon_state = "longtruck_donk"

//WY
/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/nt_black
	name = "\improper Nanotrasen mega-hauler truck"
	icon_state = "longtruck_nt_black"

/obj/structure/prop/urban/vehicles/large/mega_hauler_truck/nt_blue
	name = "\improper Nanotrasen mega-hauler truck"
	icon_state = "longtruck_nt_blue"

// SUV
/obj/structure/prop/urban/vehicles/large/suv
	name = "SUV"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "SUV"
	bound_height = 32
	bound_width = 64
	coverage = 75

/obj/structure/prop/urban/vehicles/large/suv/suv_1
	icon_state = "SUV1"

/obj/structure/prop/urban/vehicles/large/suv/suv_2
	icon_state = "SUV2"

/obj/structure/prop/urban/vehicles/large/suv/suv_5
	icon_state = "SUV5"

/obj/structure/prop/urban/vehicles/large/suv/suv_6
	icon_state = "SUV6"

/obj/structure/prop/urban/vehicles/large/suv/suv_7
	icon_state = "SUV7"

/obj/structure/prop/urban/vehicles/large/suv/suv_8
	icon_state = "SUV8"

// damaged suv

/obj/structure/prop/urban/vehicles/large/suv/suvdamaged
	name = "heavily damaged SUV"
	desc = "A shell of a vehicle, broken down beyond repair."
	icon_state = "SUV_damaged"

/obj/structure/prop/urban/vehicles/large/suv/suvdamaged/suv_damaged1
	icon_state = "SUV1_damaged"

/obj/structure/prop/urban/vehicles/large/suv/suvdamaged/suv_damaged2
	icon_state = "SUV2_damaged"

// small trucks

/obj/structure/prop/urban/vehicles/large/truck
	name = "truck"
	icon_state = "zentruck1"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	bound_height = 32
	bound_width = 64
	max_integrity = 120

/obj/structure/prop/urban/vehicles/large/truck/truck1
	icon_state = "zentruck2"

/obj/structure/prop/urban/vehicles/large/truck/truck2
	icon_state = "zentruck3"

/obj/structure/prop/urban/vehicles/large/truck/truck3
	icon_state = "zentruck4"

/obj/structure/prop/urban/vehicles/large/truck/truck4
	icon_state = "zentruck5"

/obj/structure/prop/urban/vehicles/large/truck/truck5
	icon_state = "truck_cargo"

/obj/structure/prop/urban/vehicles/large/truck/truck6
	icon_state = "truck"

/obj/structure/prop/urban/vehicles/large/truck/garbage
	name = "garbage truck"
	icon_state = "zengarbagetruck"
	desc = "Seems to be broken down."

/obj/structure/prop/urban/vehicles/large/truck/mining
	name = "mining supply truck"
	icon_state = "truck_mining"
	desc = "Seems to be broken down."

// large trucks
/obj/structure/prop/urban/vehicles/large/big_truck
	name = "mega-hauler truck"
	icon_state = "zenithlongtruck4"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/vehicles/large/big_truck/largetruck1
	icon_state = "zenithlongtruck2"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruck2
	icon_state = "zenithlongtruck3"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruck3
	icon_state = "zenithlongtruck4"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruck4
	icon_state = "zenithlongtruck5"

// mining truck

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckmining
	icon_state = "zenithlongtruckkellandmining1"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckmining
	name = "Kelland mining mega-hauler truck"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckmining/mining
	icon_state = "zenithlongtruckkellandmining1"

// w-y truck

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckwy
	icon_state = "zenithlongtruckweyland1"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckwy
	name = "\improper Nanotrasen mega-hauler truck"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckwy/wy1
	icon_state = "zenithlongtruckweyland1"

/obj/structure/prop/urban/vehicles/large/big_truck/largetruckwy/wy2
	icon_state = "zenithlongtruckweyland2"

// Colony Crawlers

/obj/structure/prop/urban/vehicles/large/colonycrawlers
	icon_state = "crawler_wy2"
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining
	icon_state = "miningcrawler1"
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining2
	icon_state = "crawler_fuel"
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining3
	icon_state = "crawler_covered_bed"
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/large/colonycrawlers/science
	icon_state = "crawler_wy2"
	desc = "It is a tread bound crawler used in harsh conditions. This one is designed for personnel transportation. Supplied by Orbital Blue International; 'Your friends, in the Aerospace business.' A subsidiary of Nanotrasen."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

// science crawlers

/obj/structure/prop/urban/vehicles/large/colonycrawlers/science
	name = "\improper Nanotrasen colony crawler"

/obj/structure/prop/urban/vehicles/large/colonycrawlers/science/science1
	icon_state = "crawler_wy1"
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

/obj/structure/prop/urban/vehicles/large/colonycrawlers/science/science2
	icon_state = "crawler_wy2"
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'

// Mining Crawlers

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining
	name = "kelland mining colony crawler"

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining/mining1
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawler2"

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining/mining2
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawler3"

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining/mining3
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawler4"

/obj/structure/prop/urban/vehicles/large/colonycrawlers/mining/mining4
	desc = "It is a tread bound crawler used in harsh conditions. Supplied by The Kelland Mining Company; A subsidiary of Nanotrasen."
	icon_state = "miningcrawlerblank"

// Special SUV's

/obj/structure/prop/urban/vehicles/large/suv/misc
	name = "\improper Nanotrasen rapid response vehicle"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "WYSUV1"
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/vehicles/large/suv/misc/wy1
	icon_state = "WYSUV1"

/obj/structure/prop/urban/vehicles/large/suv/misc/wy2
	icon_state = "WYSUV2"

/obj/structure/prop/urban/vehicles/large/suv/misc/wy3
	icon_state = "WYSUV3"

/obj/structure/prop/urban/vehicles/large/suv/misc/ambulance
	name = "emergency response medical van"
	desc = "Seems to be broken down."
	icon_state = "ambulance"

/obj/structure/prop/urban/vehicles/large/suv/misc/whitevan
	name = "maintenance SUV"
	desc = "Seems to be broken down."
	icon_state = "whitevan"

/obj/structure/prop/urban/vehicles/large/suv/misc/maintenance
	name = "maintenance SUV"
	desc = "Seems to be broken down."
	icon_state = "maintenaceSUV"

/obj/structure/prop/urban/vehicles/large/suv/misc/marshalls
	name = "colonial marshalls rapid response SUV"
	desc = "Seems to be broken down."
	icon_state = "marshalls"

/obj/structure/prop/urban/vehicles/large/suv/misc/expensive
	name = "Expensive looking SUV"
	desc = "Seems to be broken down."
	icon_state = "SUV9"

/obj/structure/prop/urban/vehicles/large/suv/misc/expensive2
	name = "Expensive Nanotrasen SUV"
	desc = "Seems to be broken down."
	icon_state = "blackSUV"

/obj/structure/prop/urban/vehicles/large/suv/misc/expensive3
	name = "The Pimp-Mobile"
	desc = "Seems to be broken down."
	icon_state = "pimpmobile"

// Vans

/obj/structure/prop/urban/vehicles/large/van
	name = "van"
	desc = "Seems to be broken down."
	icon = 'icons/obj/structures/prop/urban/vehiclesexpanded.dmi'
	icon_state = "greyvan"
	bound_height = 32
	bound_width = 64

/obj/structure/prop/urban/vehicles/large/van/vandamaged
	name = "van"
	desc = "A shell of a vehicle, broken down beyond repair."
	icon_state = "greyvan_damaged"

/obj/structure/prop/urban/vehicles/large/van/vanpizza
	name = "pizza delivery van"
	icon_state = "pizzavan"

/obj/structure/prop/urban/vehicles/large/van/vanmining
	name = "Kelland Mining van"
	icon_state = "kellandminingvan"

/obj/structure/prop/urban/vehicles/large/van/hyperdynevan
	name = "Hyperdyne van"
	icon_state = "hyperdynevan"

/obj/structure/prop/urban/vehicles/large/crashedcarsleft
	name = "car pileup"
	desc = "Burned out wrecked vehicles block your path."
	icon = 'icons/obj/structures/prop/urban/crashedcars.dmi'
	icon_state = "crashedcarsleft"
	bound_height = 64
	bound_width = 64
	layer = 5

/obj/structure/prop/urban/vehicles/large/crashedcarsright
	name = "car pileup"
	desc = "Burned out wrecked vehicles block your path."
	icon = 'icons/obj/structures/prop/urban/crashedcars.dmi'
	icon_state = "crashedcarsright"
	bound_height = 64
	bound_width = 64
	layer = 5
