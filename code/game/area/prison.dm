//Base Instance
/area/prison
	name = "Fiorina Orbital Penitentiary"
	ceiling = CEILING_GLASS

//SECURITY
/area/prison/security
	name = "Security Department"
	icon_state = "security"
	minimap_color = MINIMAP_AREA_SEC
	ceiling = CEILING_METAL

/area/prison/security/briefing
	name = "Briefing"
	icon_state = "brig"

/area/prison/security/head
	name = "Head of Security's office"
	icon_state = "sec_hos"

/area/prison/security/armory/riot
	name = "Riot Armory"
	icon_state = "armory"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/armory/lethal
	name = "Lethal Armory"
	icon_state = "Tactical"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/armory/highsec_monitoring
	name = "High-Security Monitoring Armory"
	icon_state = "security_sub"

/area/prison/security/monitoring
	icon_state = "sec_prison"

/area/prison/security/monitoring/lowsec/ne
	name = "Northeast Low-Security Monitoring"

/area/prison/security/monitoring/lowsec/sw
	name = "Southwest Low-Security Monitoring"

/area/prison/security/monitoring/medsec/south
	name = "Medium-Security Monitoring"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/monitoring/medsec/central
	name = "Central Medium-Security Monitoring"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/monitoring/highsec
	name = "High-Security Monitoring"

/area/prison/security/monitoring/maxsec
	name = "Maximum-Security Monitoring"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/monitoring/maxsec/panopticon
	name = "Panopticon Monitoring"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/monitoring/protective
	name = "Protective Custody Monitoring"

/area/prison/security/checkpoint
	icon_state = "checkpoint1"

/area/prison/security/checkpoint/medsec
	name = "Medium-Security Checkpoint"

/area/prison/security/checkpoint/highsec/n
	name = "North High-Security Checkpoint"

/area/prison/security/checkpoint/highsec/s
	name = "South High-Security Checkpoint"

/area/prison/security/checkpoint/vip
	name = "VIP Checkpoint"

/area/prison/security/checkpoint/maxsec
	name = "Maximum-Security Checkpoint"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/checkpoint/highsec_medsec
	name = "High-to-Medium-Security Checkpoint"

/area/prison/security/checkpoint/maxsec_highsec
	name = "Maximum-to-High-Security Checkpoint"
	minimap_color = MINIMAP_AREA_SEC_CAVE

/area/prison/security/checkpoint/hangar
	name = "Main Hangar Traffic Control"

/area/prison/storage
	icon_state = "engine_storage"

/area/prison/storage/medsec
	name = "Medium-Security Storage"

/area/prison/storage/highsec/n
	name = "North High-Security Storage"

/area/prison/storage/highsec/s
	name = "South High-Security Storage"

/area/prison/storage/vip
	name = "VIP Storage"

/area/prison/recreation
	icon_state = "party"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/recreation/staff
	name = "Staff Recreation"

/area/prison/recreation/medsec
	name = "Medium-Security Recreation"

/area/prison/recreation/highsec/n
	name = "North High-Security Recreation"

/area/prison/recreation/highsec/s
	name = "South High-Security Recreation"

/area/prison/execution
	name = "Execution"
	icon_state = "dark"
	ceiling = CEILING_METAL

/area/prison/store
	name = "Prison Store"
	icon_state = "bar"

/area/prison/chapel
	name = "Chapel"
	icon_state = "chapel"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/holding

/area/prison/holding/holding1
	name = "Holding Cell 1"
	icon_state = "blue-red2"

/area/prison/holding/holding2
	name = "Holding Cell 2"
	icon_state = "blue-red-d"

/area/prison/cleaning
	name = "Custodial Supplies"
	icon_state = "janitor"

/area/prison/command/office
	name = "Warden's Office"
	icon_state = "Warden"
	minimap_color = MINIMAP_AREA_COMMAND

/area/prison/command/secretary_office
	name = "Warden's Secretary's Office"
	icon_state = "blue"
	minimap_color = MINIMAP_AREA_COMMAND

/area/prison/command/quarters
	name = "Warden's Quarters"
	icon_state = "party"
	minimap_color = MINIMAP_AREA_COMMAND

/area/prison/toilet
	icon_state = "restrooms"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/toilet/canteen
	name = "Canteen Restooms"

/area/prison/toilet/security
	name = "Security Restooms"

/area/prison/toilet/research
	name = "Research Restooms"

/area/prison/toilet/staff
	name = "Staff Restooms"

/area/prison/maintenance
	icon_state = "asmaint"

/area/prison/maintenance/residential/nw
	name = "Northwest Civilian Residences Maintenance"

/area/prison/maintenance/residential/ne
	name = "Northeast Civilian Residences Maintenance"

/area/prison/maintenance/residential/sw
	name = "Southwest Civilian Residences Maintenance"

/area/prison/maintenance/residential/se
	name = "Southeast Civilian Residences Maintenance"

/area/prison/maintenance/residential/access/north
	name = "North Civilian Residences Access"

/area/prison/maintenance/residential/access/south
	name = "South Civilian Residences Access"

/area/prison/maintenance/staff_research
	name = "Staff-Research Maintenance"
	icon_state = "maint_research_starboard"

/area/prison/maintenance/research_medbay
	name = "Research-Infirmary Maintenance"
	icon_state = "maint_research_port"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_CAVES

/area/prison/maintenance/hangar_barracks
	name = "Hangar-Barracks Maintenance"
	icon_state = "maint_e_shuttle"

/area/prison/canteen
	name = "Canteen"
	icon_state = "cafeteria"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/laundry
	name = "Laundry"
	icon_state = "bluenew"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/library
	name = "Library"
	icon_state = "green"
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/engineering
	name = "Engineering"
	icon_state = "engine"
	minimap_color = MINIMAP_AREA_ENGI
	ceiling = CEILING_UNDERGROUND_METAL

/area/prison/engineering/atmos
	name = "Atmospherics"
	icon_state = "atmos"

/area/prison/intake
	name = "Intake Processing"
	icon_state = "green"

/area/prison/parole/main
	name = "Parole"
	icon_state = "blue2"

/area/prison/parole/protective_custody
	name = "Protective Custody Parole"
	icon_state = "red2"

/area/prison/visitation
	name = "Visitation"
	icon_state = "yellow"

/area/prison/yard
	name = "Yard"
	icon_state = "thunder"
	ceiling = CEILING_NONE

/area/prison/beach
	name = "Beach recreation"
	icon_state = "thunder"
	ceiling = CEILING_NONE
	always_unpowered = TRUE

/area/prison/hallway

/area/prison/hallway/entrance
	name = "Entrance Hallway"
	icon_state = "entry"

/area/prison/hallway/central
	name = "Central Ring"
	icon_state = "hallC1"

/area/prison/hallway/east
	name = "East Hallway"
	icon_state = "east"

/area/prison/hallway/staff
	name = "Staff Hallway"
	icon_state = "hallS"

/area/prison/hallway/engineering
	name = "Engineering Hallway"
	icon_state = "dk_yellow"

/area/prison/quarters
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/quarters/staff
	name = "Staff Quarters"
	icon_state = "crew_quarters"

/area/prison/quarters/security
	name = "Security Barracks"
	icon_state = "sec_backroom"
	minimap_color = MINIMAP_AREA_SEC

/area/prison/quarters/research
	name = "Research Dorms"
	icon_state = "purple"

/area/prison/cellblock/
	minimap_color = MINIMAP_AREA_CELL_LOW

/area/prison/cellblock/lowsec/nw
	name = "Northwest Low-Security Cellblock"
	icon_state = "cells_low_nw"

/area/prison/cellblock/lowsec/ne
	name = "Northeast Low-Security Cellblock"
	icon_state = "cells_low_ne"

/area/prison/cellblock/lowsec/sw
	name = "Southwest Low-Security Cellblock"
	icon_state = "cells_low_sw"

/area/prison/cellblock/lowsec/se
	name = "Southeast Low-Security Cellblock"
	icon_state = "cells_low_se"

/area/prison/cellblock/mediumsec
	name = "Medium-Security Cellblock"
	icon_state = "cells_med"
	minimap_color = MINIMAP_AREA_CELL_MED
	ceiling = CEILING_UNDERGROUND_METAL

/area/prison/cellblock/mediumsec/north
	name = "Medium-Security Cellblock North"
	icon_state = "cells_med_n"

/area/prison/cellblock/mediumsec/south
	name = "Medium-Security Cellblock South"
	icon_state = "cells_med_s"

/area/prison/cellblock/mediumsec/east
	name = "Medium-Security Cellblock East"
	icon_state = "cells_med_e"

/area/prison/cellblock/mediumsec/west
	name = "Medium-Security Cellblock West"
	icon_state = "cells_med_w"

/area/prison/cellblock/highsec
	name = "North High-Security Cellblock"
	icon_state = "cells_high_nn"
	minimap_color = MINIMAP_AREA_CELL_HIGH
	ceiling = CEILING_METAL

/area/prison/cellblock/highsec/north/north
	name = "North High-Security Cellblock North"
	icon_state = "cells_high_nn"

/area/prison/cellblock/highsec/north/south
	name = "North High-Security Cellblock South"
	icon_state = "cells_high_ns"

/area/prison/cellblock/highsec/south/north
	name = "South High-Security Cellblock North"
	icon_state = "cells_high_sn"

/area/prison/cellblock/highsec/south/south
	name = "South High-Security Cellblock South"
	icon_state = "cells_high_ss"

/area/prison/cellblock/maxsec/north
	name = "Maximum-Security Panopticon Cellblock"
	icon_state = "cells_max_n"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_CELL_MAX

/area/prison/cellblock/maxsec/south
	name = "Maximum-Security Suspended Cellblock"
	icon_state = "cells_max_s"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_CELL_MAX

/area/prison/cellblock/vip
	name = "VIP Cells"
	icon_state = "cells_vip"
	minimap_color = MINIMAP_AREA_CELL_VIP

/area/prison/cellblock/protective
	name = "Protective Custody"
	icon_state = "cells_protective"
	minimap_color = MINIMAP_AREA_CELL_VIP

/area/prison/cellblock/protective/room101
	name = "Room 101"

/area/prison/material_processing
	name = "Material Processing"
	icon_state = "mining"

/area/prison/disposal
	name = "Disposals"
	icon_state = "disposal"

/area/prison/medbay
	name = "Infirmary"
	icon_state = "medbay"
	minimap_color = MINIMAP_AREA_MEDBAY
	ceiling = CEILING_METAL

/area/prison/medbay/foyer
	name = "Infirmary Foyer"
	icon_state = "medbay2"

/area/prison/medbay/surgery
	name = "Operating Theatre"
	icon_state = "medbay3"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/prison/medbay/morgue
	name = "Morgue"
	icon_state = "morgue"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_MEDBAY_CAVE

/area/prison/research/
	name = "Biological Research Department"
	icon_state = "research"
	ceiling = CEILING_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_RESEARCH_CAVE

/area/prison/research/RD
	name = "Research Director's office"
	icon_state = "disposal"

/area/prison/research/secret/
	name = "Classified Research"
	icon_state = "toxlab"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/prison/research/secret/dissection
	name = "Dissection"
	icon_state = "toxmix"

/area/prison/research/secret/chemistry
	name = "Chemistry"
	icon_state = "chem"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/prison/research/secret/bioengineering
	name = "Bioengineering"
	icon_state = "toxmisc"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/prison/research/secret/containment
	name = "Test Subject Containment"
	icon_state = "xeno_f_store"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/prison/research/secret/biolab
	name = "Biological Test Lab"
	icon_state = "anolab"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL

/area/prison/residential
	minimap_color = MINIMAP_AREA_LIVING

/area/prison/residential/central
	name = "Civilian Residences Central"
	icon_state = "blue-red2"

/area/prison/residential/north
	name = "Civilian Residences North"
	icon_state = "blue2"

/area/prison/residential/south
	name = "Civilian Residences South"
	icon_state = "red2"

/area/prison/monorail
	icon_state = "purple"

/area/prison/monorail/east
	name = "East Monorail Station"

/area/prison/monorail/west
	name = "West Monorail Station"

/area/prison/hangar/main
	ceiling = CEILING_NONE
	minimap_color = MINIMAP_AREA_LZ

/area/prison/hangar/main
	name = "Main Hangar"
	icon_state = "hangar_alpha"

/area/prison/hangar/civilian
	name = "Civilian Hangar"
	icon_state = "hangar_beta"

/area/prison/hangar_storage/main
	name = "Main Hangar Storage"
	icon_state = "quartstorage"
	minimap_color = MINIMAP_AREA_REQ

/area/prison/hangar_storage/research
	name = "Research Hangar Storage"
	icon_state = "toxstorage"
	minimap_color = MINIMAP_AREA_RESEARCH

/area/prison/telecomms
	name = "Telecommunications"
	icon_state = "tcomsatcham"

/area/prison/pirate
	name = "Tramp Freighter \"Rocinante\""
	icon_state = "syndie-ship"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_SHIP

/area/prison/secret
	name = "Secret Room"
	icon_state = "tcomsatcham"
	ceiling = CEILING_DEEP_UNDERGROUND_METAL
	minimap_color = MINIMAP_AREA_CAVES

/area/prison/console
	name = "Shuttle Console"
