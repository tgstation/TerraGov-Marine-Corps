// Lava "Lavaland" Outpost

//Base Area

/area/lavaland
	name = "\improper Lava"
	icon_state = "lava"

/area/lavaland/lava
	name = "\improper Lava"
	icon_state = "lava"
	always_unpowered = TRUE

//Caves
/area/lavaland/cave //Parent
	name = "Caves"
	icon_state ="lava"
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_CAVES
	always_unpowered = TRUE

/area/lavaland/cave/central
	name = "\improper Central Caves"
	icon_state = "lava_cave_c"

/area/lavaland/cave/north
	name = "\improper North Caves"
	icon_state = "lava_cave_n"

/area/lavaland/cave/northeast
	name = "\improper North East Caves"
	icon_state = "lava_cave_ne"

/area/lavaland/cave/northwest
	name = "\improper North West Caves"
	icon_state = "lava_cave_nw"

/area/lavaland/cave/south
	name = "\improper South Caves"
	icon_state = "lava_cave_s"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/lavaland/cave/southeast
	name = "\improper South East Caves"
	icon_state = "lava_cave_se"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/lavaland/cave/southwest
	name = "\improper South West Caves"
	icon_state = "lava_cave_sw"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/lavaland/cave/east
	name = "\improper East Caves"
	icon_state = "lava_cave_e"

/area/lavaland/cave/west
	name = "\improper West Caves"
	icon_state = "lava_cave_w"

//Medical

/area/lavaland/medical
	name = "\improper Medical Clinic"
	icon_state = "lava_med"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_MEDBAY

/area/lavaland/medical/chemistry
	name = "\improper Medical Clinic Chemistry"
	icon_state = "lava_chem"

/area/lavaland/medical/cmo
	name = "\improper Chief Medical Office"
	icon_state = "lava_cmo"

//"Engineer"
/area/lavaland/engie // Parent
	name ="Generator"
	icon_state = "lava_engi"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_ENGI

/area/lavaland/engie/one
	name = "\improper Generator One"
	icon_state = "lava_eng1"

/area/lavaland/engie/two
	name = "\improper Generator Two"
	icon_state = "lava_eng2"

/area/lavaland/engie/three
	name = "\improper Generator Three"
	icon_state = "lava_eng3"

/area/lavaland/engie/refine
	name = "\improper Ore Processing Facility"
	icon_state = "lava_eng4"

/area/lavaland/engie/engine
	name = "\improper Engineering Facility"
	icon_state = "lava_eng5"

//Security

/area/lavaland/security
	name = "\improper Prison Facility"
	icon_state = "lava_sec_prison"
	ceiling = CEILING_DEEP_UNDERGROUND
	minimap_color = MINIMAP_AREA_SEC

/area/lavaland/security/storage
	name = "\improper Prison Facility Storage"
	icon_state = "lava_sec_secure"

/area/lavaland/security/infocenter
	name = "\improper Prison Facility Information Center"
	icon_state = "lava_sec"

/area/lavaland/security/nuke
	name = "\improper Emergency Nuclear Fission Facility"
	icon_state = "lava_sec_nuke"

//Civilian

/area/lavaland/civilian
	name = "\improper Civilian Housing"
	icon_state = "lava_civ"
	ceiling = CEILING_METAL
	minimap_color = MINIMAP_AREA_LIVING

/area/lavaland/civilian/cook
	name = "\improper Civilian Kitchen"
	icon_state = "lava_civ_cook"

/area/lavaland/civilian/botany
	name = "\improper Civilian Botany"
	icon_state = "lava_civ_bot"

/area/lavaland/civilian/garden
	name = "\improper Civilian Garden"
	icon_state = "lava_civ_garden"

/area/lavaland/civilian/cargo
	name = "\improper Civilian Cargo"
	icon_state = "lava_civ_cargo"
