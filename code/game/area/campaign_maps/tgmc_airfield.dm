//TGMC airfield areas
/area/campaign/tgmc_airfield
	area_flags = ALWAYS_RADIO
	icon_state = "lv-626"

/area/campaign/tgmc_airfield/outside
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE
	ambience = list('sound/ambience/ambigen10.ogg','sound/ambience/ambilava2.ogg')

/area/campaign/tgmc_airfield/outside/cave
	name = "Caves"
	icon_state = "alarm_down"
	ceiling = CEILING_UNDERGROUND
	outside = FALSE

/area/campaign/tgmc_airfield/outside/cave/enclosed
	icon_state = "invi"
	ceiling = CEILING_DEEP_UNDERGROUND

/area/campaign/tgmc_airfield/outside/desert
	name = "Central Desert"
	icon_state = "central"
	minimap_color = MINIMAP_AREA_CELL_MED

/area/campaign/tgmc_airfield/outside/desert/west
	name = "Western Desert"
	icon_state = "west"

/area/campaign/tgmc_airfield/outside/desert/east
	name = "Eastern Desert"
	icon_state = "east"

/area/campaign/tgmc_airfield/outside/desert/north
	name = "Northern Desert"
	icon_state = "north"

/area/campaign/tgmc_airfield/outside/desert/south
	name = "Southern Desert"
	icon_state = "south"

/area/campaign/tgmc_airfield/outside/dry_river
	name = "Dry River"
	icon_state = "blueold"

/area/campaign/tgmc_airfield/outside/west_base
	name = "Western Base Grounds"
	icon_state = "west2"
	always_unpowered = FALSE

/area/campaign/tgmc_airfield/outside/east_base
	name = "Eastern Base Grounds"
	icon_state = "east2"
	always_unpowered = FALSE

/area/campaign/tgmc_airfield/outside/airstrip_north
	name = "Northern Airstrip"
	icon_state = "runway"
	always_unpowered = FALSE

/area/campaign/tgmc_airfield/outside/airstrip_south
	name = "Northern Airstrip"
	icon_state = "runway2"
	always_unpowered = FALSE

/area/campaign/tgmc_airfield/base
	name = "sidewalk"
	icon_state = "dark"
	ambience = list('sound/ambience/ambigen7.ogg','sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg')
	ceiling = CEILING_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/tgmc_airfield/base/hangar_bay
	name = "Hangar"
	icon_state = "hangar_cas"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/tgmc_airfield/base/hangar_bay/generator
	name = "generator"
	icon_state = "substation"

/area/campaign/tgmc_airfield/base/barracks
	name = "Western Barracks"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/campaign/tgmc_airfield/base/barracks/east
	name = "Eastern Barracks"
	icon_state = "crew_quarters"

/area/campaign/tgmc_airfield/base/barracks/officer
	name = "Officers Barracks"
	icon_state = "captain"

/area/campaign/tgmc_airfield/base/barracks/mess_hall
	name = "Mess Hall"
	icon_state = "cafeteria"

/area/campaign/tgmc_airfield/base/command_center
	name = "Command Center"
	icon_state = "observatory"
	minimap_color = MINIMAP_AREA_COMMAND

/area/campaign/tgmc_airfield/base/medical
	name = "Medical"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/campaign/tgmc_airfield/base/storage
	name = "Storage Warehouse"
	icon_state = "auxstorage"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/tgmc_airfield/base/security_checkpoint
	name = "Western Security Checkpoint"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/tgmc_airfield/base/security_checkpoint/east
	name = "Eastern Security Checkpoint"
	icon_state = "checkpoint1"

/area/campaign/tgmc_airfield/base/armory
	name = "Armory"
	icon_state = "armory"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/tgmc_airfield/base/armory_workshop
	name = "Armory Workshop"
	icon_state = "red"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/tgmc_airfield/base/water_purification
	name = "Water Purification Center"
	icon_state = "decontamination"
	minimap_color = MINIMAP_AREA_ENGI
