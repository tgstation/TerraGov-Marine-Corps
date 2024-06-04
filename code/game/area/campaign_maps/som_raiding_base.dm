
/area/campaign/som_raiding
	icon_state = "lv-626"
	area_flags = ALWAYS_RADIO
	ambience = list('sound/ambience/ambigen3.ogg','sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg')

/area/campaign/som_raiding/ground
	name = "Ground"
	icon_state = "green"
	always_unpowered = TRUE
	ambience = list('sound/ambience/jungle_amb1.ogg')

//Jungle
/area/campaign/som_raiding/ground/jungle
	name = "Central Jungle"
	icon_state = "central"
	minimap_color = MINIMAP_AREA_JUNGLE

/area/campaign/som_raiding/ground/jungle/south_west
	name = "Southwestern Jungle"
	icon_state = "southwest"

/area/campaign/som_raiding/ground/jungle/south_east
	name = "Southeastern Jungle"
	icon_state = "southeast"

/area/campaign/som_raiding/ground/jungle/north_west
	name = "Northwestern Jungle"
	icon_state = "northwest"

/area/campaign/som_raiding/ground/jungle/north_east
	name = "Northeastern Jungle"
	icon_state = "northeast"

/area/campaign/som_raiding/ground/jungle/west
	name = "Western Jungle"
	icon_state = "west"

/area/campaign/som_raiding/ground/jungle/south
	name = "Southern Jungle"
	icon_state = "south"

/area/campaign/som_raiding/ground/jungle/east
	name = "Eastern Jungle"
	icon_state = "east"

/area/campaign/som_raiding/ground/jungle/north
	name = "Northern Jungle"
	icon_state = "north"

//river
/area/campaign/som_raiding/ground/river
	name = "\improper Southern River"
	icon_state = "blueold"

/area/campaign/som_raiding/ground/river/north
	name = "\improper Northern River"

/area/campaign/som_raiding/ground/river/west
	name = "\improper Western River"

/area/campaign/som_raiding/ground/river/east
	name = "\improper Eastern River"

/area/campaign/som_raiding/ground/river/lake
	name = "\improper Southern Lake"

//outpost
/area/campaign/som_raiding/cave
	name = "\improper Mountain"
	icon_state = "cave"
	ceiling = CEILING_UNDERGROUND
	outside = FALSE
	minimap_color = MINIMAP_AREA_CAVES

/area/campaign/som_raiding/cave/tunnel
	name = "\improper Old tunnels - South"
	icon_state = "explored"

/area/campaign/som_raiding/cave/tunnel_west
	name = "\improper Old tunnels - West"
	icon_state = "explored"

//outpost
/area/campaign/som_raiding/outpost
	name = "\improper Outpost"
	icon_state = "green"
	ceiling = CEILING_UNDERGROUND_METAL
	outside = FALSE
	minimap_color = MINIMAP_AREA_COLONY

/area/campaign/som_raiding/outpost/firing_range
	name = "\improper Firing range"

/area/campaign/som_raiding/outpost/construction
	name = "\improper Construction site"

/area/campaign/som_raiding/outpost/central_corridor
	name = "\improper Central corridor"

/area/campaign/som_raiding/outpost/maintenance
	name = "\improper Southwest maintenance"
	minimap_color = MINIMAP_AREA_CAVES
	icon_state = "maint_security_starboard"

/area/campaign/som_raiding/outpost/maintenance/engie
	name = "\improper Engineering maintenance"
	icon_state = "maint_engine"

/area/campaign/som_raiding/outpost/maintenance/operation
	name = "\improper Operations maintenance"
	icon_state = "apmaint"

/area/campaign/som_raiding/outpost/maintenance/cic
	name = "\improper CIC maintenance"
	icon_state = "fpmaint"

/area/campaign/som_raiding/outpost/maintenance/req
	name = "\improper Requisitions maintenance"
	icon_state = "maint_cargo"

/area/campaign/som_raiding/outpost/maintenance/med
	name = "\improper medbay maintenance"
	icon_state = "maint_medbay"

/area/campaign/som_raiding/outpost/medbay
	name = "\improper Medbay"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY

/area/campaign/som_raiding/outpost/security
	name = "\improper Armoury"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC

/area/campaign/som_raiding/outpost/security/south_post
	name = "\improper South security checkpoint"

/area/campaign/som_raiding/outpost/security/southeast_post
	name = "\improper Southeast security checkpoint"

/area/campaign/som_raiding/outpost/security/west_post
	name = "\improper West security checkpoint"

/area/campaign/som_raiding/outpost/security/north_post
	name = "\improper North security checkpoint"

/area/campaign/som_raiding/outpost/security/cargo_post
	name = "\improper Caro security checkpoint"

/area/campaign/som_raiding/outpost/command
	name = "\improper Operations"
	icon_state = "bridge"
	minimap_color = MINIMAP_AREA_COMMAND

/area/campaign/som_raiding/outpost/command/captain
	name = "\improper Executive Office"
	icon_state = "captain"

/area/campaign/som_raiding/outpost/command/telecom
	name = "\improper Telecommunications"
	icon_state = "tcomms"

/area/campaign/som_raiding/outpost/command/cic
	name = "\improper Combat Information Centre"

/area/campaign/som_raiding/outpost/command/north
	name = "\improper North offices"

/area/campaign/som_raiding/outpost/command/living
	name = "\improper Officer's quarters"

/area/campaign/som_raiding/outpost/engineering
	name = "\improper Engineering"
	icon_state = "engine_smes"
	minimap_color = MINIMAP_AREA_ENGI

/area/campaign/som_raiding/outpost/living
	name = "\improper Barracks"
	icon_state = "Sleep"
	minimap_color = MINIMAP_AREA_LIVING

/area/campaign/som_raiding/outpost/living/briefing
	name = "\improper Briefing room"
	icon_state = "conference"

/area/campaign/som_raiding/outpost/living/bathroom
	name = "\improper Bathrooms"
	icon_state = "restrooms"

/area/campaign/som_raiding/outpost/living/canteen
	name = "\improper Canteen"
	icon_state = "cafeteria"

/area/campaign/som_raiding/outpost/living/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/campaign/som_raiding/outpost/req
	name = "\improper Main cargo bay"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/som_raiding/outpost/req/north
	name = "\improper North cargo bay"

/area/campaign/som_raiding/outpost/req/aux
	name = "\improper North auxiliary storage"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/som_raiding/outpost/req/secure
	name = "\improper Secure storage"
	icon_state = "quart"
	minimap_color = MINIMAP_AREA_REQ

/area/campaign/som_raiding/outpost/req/qm
	name = "\improper Quartermaster's Office"
	icon_state = "quartoffice"

/area/campaign/som_raiding/outpost/tunnel
	name = "\improper South tunnel"
	icon_state = "explored"
	ceiling = CEILING_UNDERGROUND

/area/campaign/som_raiding/outpost/tunnel/west
	name = "\improper West tunnel"
