///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////

/datum/design/board/aicore
	name = "AI Design (AI Core)"
	desc = ""
	id = "aicore"
	build_path = /obj/item/circuitboard/aicore
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/safeguard_module
	name = "Module Design (Safeguard)"
	desc = ""
	id = "safeguard_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/aiModule/supplied/safeguard
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/onehuman_module
	name = "Module Design (OneHuman)"
	desc = ""
	id = "onehuman_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 6000)
	build_path = /obj/item/aiModule/zeroth/oneHuman
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/protectstation_module
	name = "Module Design (ProtectStation)"
	desc = ""
	id = "protectstation_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/aiModule/supplied/protectStation
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/quarantine_module
	name = "Module Design (Quarantine)"
	desc = ""
	id = "quarantine_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/aiModule/supplied/quarantine
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/oxygen_module
	name = "Module Design (OxygenIsToxicToHumans)"
	desc = ""
	id = "oxygen_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/aiModule/supplied/oxygen
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/freeform_module
	name = "Module Design (Freeform)"
	desc = ""
	id = "freeform_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 10000)//Custom inputs should be more expensive to get
	build_path = /obj/item/aiModule/supplied/freeform
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/reset_module
	name = "Module Design (Reset)"
	desc = ""
	id = "reset_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000)
	build_path = /obj/item/aiModule/reset
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/purge_module
	name = "Module Design (Purge)"
	desc = ""
	id = "purge_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/reset/purge
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/remove_module
	name = "Module Design (Law Removal)"
	desc = ""
	id = "remove_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/remove
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/freeformcore_module
	name = "AI Core Module (Freeform)"
	desc = ""
	id = "freeformcore_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 10000)//Ditto
	build_path = /obj/item/aiModule/core/freeformcore
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/asimov
	name = "Core Module Design (Asimov)"
	desc = ""
	id = "asimov_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/core/full/asimov
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/paladin_module
	name = "Core Module Design (P.A.L.A.D.I.N.)"
	desc = ""
	id = "paladin_module"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/core/full/paladin
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/tyrant_module
	name = "Core Module Design (T.Y.R.A.N.T.)"
	desc = ""
	id = "tyrant_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/core/full/tyrant
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/overlord_module
	name = "Core Module Design (Overlord)"
	desc = ""
	id = "overlord_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/core/full/overlord
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/corporate_module
	name = "Core Module Design (Corporate)"
	desc = ""
	id = "corporate_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/core/full/corp
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/default_module
	name = "Core Module Design (Default)"
	desc = ""
	id = "default_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 2000)
	build_path = /obj/item/aiModule/core/full/custom
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
