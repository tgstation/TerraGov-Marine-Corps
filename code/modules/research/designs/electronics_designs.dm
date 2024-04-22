
///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = ""
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 200)
	build_path = /obj/item/aicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = ""
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/paicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/ai_cam_upgrade
	name = "AI Surveillance Software Update"
	desc = ""
	id = "ai_cam_upgrade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/gold = 15000, /datum/material/silver = 15000, /datum/material/diamond = 20000, /datum/material/plasma = 10000)
	build_path = /obj/item/surveillance_upgrade
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

///////////////////////////////////
//////////Nanite Devices///////////
///////////////////////////////////
/datum/design/nanite_remote
	name = "Nanite Remote"
	desc = ""
	id = "nanite_remote"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_remote
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_comm_remote
	name = "Nanite Communication Remote"
	desc = ""
	id = "nanite_comm_remote"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_remote/comm
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_scanner
	name = "Nanite Scanner"
	desc = ""
	id = "nanite_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500)
	build_path = /obj/item/nanite_scanner
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE


////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = ""
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/design_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/design_disk_adv
	name = "Advanced Design Storage Disk"
	desc = ""
	id = "design_disk_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver=50)
	build_path = /obj/item/disk/design_disk/adv
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = ""
	id = "tech_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/tech_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_disk
	name = "Nanite Program Disk"
	desc = ""
	id = "nanite_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/nanite_program
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
