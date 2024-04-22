///////////////////Computer Boards///////////////////////////////////

/datum/design/board
	name = "Computer Design ( NULL ENTRY )"
	desc = ""
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000)

/datum/design/board/arcade_battle
	name = "Computer Design (Battle Arcade Machine)"
	desc = ""
	id = "arcade_battle"
	build_path = /obj/item/circuitboard/computer/arcade/battle
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/orion_trail
	name = "Computer Design (Orion Trail Arcade Machine)"
	desc = ""
	id = "arcade_orion"
	build_path = /obj/item/circuitboard/computer/arcade/orion_trail
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/seccamera
	name = "Computer Design (Security Camera)"
	desc = ""
	id = "seccamera"
	build_path = /obj/item/circuitboard/computer/security
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/rdcamera
	name = "Computer Design (Research Monitor)"
	desc = ""
	id = "rdcamera"
	build_path = /obj/item/circuitboard/computer/research
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/xenobiocamera
	name = "Computer Design (Xenobiology Console)"
	desc = ""
	id = "xenobioconsole"
	build_path = /obj/item/circuitboard/computer/xenobiology
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/aiupload
	name = "Computer Design (AI Upload)"
	desc = ""
	id = "aiupload"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/circuitboard/computer/aiupload
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/borgupload
	name = "Computer Design (Cyborg Upload)"
	desc = ""
	id = "borgupload"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/circuitboard/computer/borgupload
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/med_data
	name = "Computer Design (Medical Records)"
	desc = ""
	id = "med_data"
	build_path = /obj/item/circuitboard/computer/med_data
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/operating
	name = "Computer Design (Operating Computer)"
	desc = ""
	id = "operating"
	build_path = /obj/item/circuitboard/computer/operating
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/pandemic
	name = "Computer Design (PanD.E.M.I.C. 2200)"
	desc = ""
	id = "pandemic"
	build_path = /obj/item/circuitboard/computer/pandemic
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/scan_console
	name = "Computer Design (DNA Machine)"
	desc = ""
	id = "scan_console"
	build_path = /obj/item/circuitboard/computer/scan_consolenew
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/comconsole
	name = "Computer Design (Communications)"
	desc = ""
	id = "comconsole"
	build_path = /obj/item/circuitboard/computer/communications
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY				//Honestly should have a bridge techfab for this sometime.

/datum/design/board/idcardconsole
	name = "Computer Design (ID Console)"
	desc = ""
	id = "idcardconsole"
	build_path = /obj/item/circuitboard/computer/card
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY				//Honestly should have a bridge techfab for this sometime.

/datum/design/board/crewconsole
	name = "Computer Design (Crew monitoring computer)"
	desc = ""
	id = "crewconsole"
	build_path = /obj/item/circuitboard/computer/crew
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/secdata
	name = "Computer Design (Security Records Console)"
	desc = ""
	id = "secdata"
	build_path = /obj/item/circuitboard/computer/secure_data
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/atmosalerts
	name = "Computer Design (Atmosphere Alert)"
	desc = ""
	id = "atmosalerts"
	build_path = /obj/item/circuitboard/computer/atmos_alert
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/atmos_control
	name = "Computer Design (Atmospheric Monitor)"
	desc = ""
	id = "atmos_control"
	build_path = /obj/item/circuitboard/computer/atmos_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/robocontrol
	name = "Computer Design (Robotics Control Console)"
	desc = ""
	id = "robocontrol"
	build_path = /obj/item/circuitboard/computer/robotics
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/slot_machine
	name = "Computer Design (Slot Machine)"
	desc = ""
	id = "slotmachine"
	build_path = /obj/item/circuitboard/computer/slot_machine
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/powermonitor
	name = "Computer Design (Power Monitor)"
	desc = ""
	id = "powermonitor"
	build_path = /obj/item/circuitboard/computer/powermonitor
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/solarcontrol
	name = "Computer Design (Solar Control)"
	desc = ""
	id = "solarcontrol"
	build_path = /obj/item/circuitboard/computer/solar_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/prisonmanage
	name = "Computer Design (Prisoner Management Console)"
	desc = ""
	id = "prisonmanage"
	build_path = /obj/item/circuitboard/computer/prisoner
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/mechacontrol
	name = "Computer Design (Exosuit Control Console)"
	desc = ""
	id = "mechacontrol"
	build_path = /obj/item/circuitboard/computer/mecha_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/mechapower
	name = "Computer Design (Mech Bay Power Control Console)"
	desc = ""
	id = "mechapower"
	build_path = /obj/item/circuitboard/computer/mech_bay_power_console
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/rdconsole
	name = "Computer Design (R&D Console)"
	desc = ""
	id = "rdconsole"
	build_path = /obj/item/circuitboard/computer/rdconsole
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/cargo
	name = "Computer Design (Supply Console)"
	desc = ""
	id = "cargo"
	build_path = /obj/item/circuitboard/computer/cargo
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/cargorequest
	name = "Computer Design (Supply Request Console)"
	desc = ""
	id = "cargorequest"
	build_path = /obj/item/circuitboard/computer/cargo/request
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/bounty
	name = "Computer Design (Bounty Console)"
	desc = ""
	id = "bounty"
	build_path = /obj/item/circuitboard/computer/bounty
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/mining
	name = "Computer Design (Outpost Status Display)"
	desc = ""
	id = "mining"
	build_path = /obj/item/circuitboard/computer/mining
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/comm_monitor
	name = "Computer Design (Telecommunications Monitoring Console)"
	desc = ""
	id = "comm_monitor"
	build_path = /obj/item/circuitboard/computer/comm_monitor
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/comm_server
	name = "Computer Design (Telecommunications Server Monitoring Console)"
	desc = ""
	id = "comm_server"
	build_path = /obj/item/circuitboard/computer/comm_server
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/message_monitor
	name = "Computer Design (Messaging Monitor Console)"
	desc = ""
	id = "message_monitor"
	build_path = /obj/item/circuitboard/computer/message_monitor
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/aifixer
	name = "Computer Design (AI Integrity Restorer)"
	desc = ""
	id = "aifixer"
	build_path = /obj/item/circuitboard/computer/aifixer
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/libraryconsole
	name = "Computer Design (Library Console)"
	desc = ""
	id = "libraryconsole"
//	build_path = /obj/item/circuitboard/computer/libraryconsole
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/apc_control
	name = "Computer Design (APC Control)"
	desc = ""
	id = "apc_control"
	build_path = /obj/item/circuitboard/computer/apc_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/nanite_chamber_control
	name = "Computer Design (Nanite Chamber Control)"
	desc = ""
	id = "nanite_chamber_control"
	build_path = /obj/item/circuitboard/computer/nanite_chamber_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/nanite_cloud_control
	name = "Computer Design (Nanite Cloud Control)"
	desc = ""
	id = "nanite_cloud_control"
	build_path = /obj/item/circuitboard/computer/nanite_cloud_controller
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/advanced_camera
	name = "Computer Design (Advanced Camera Console)"
	desc = ""
	id = "advanced_camera"
	build_path = /obj/item/circuitboard/computer/advanced_camera
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
