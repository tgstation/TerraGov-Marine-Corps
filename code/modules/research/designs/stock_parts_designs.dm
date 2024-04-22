////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = ""
	id = "rped"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000) //hardcore
	build_path = /obj/item/storage/part_replacer
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/BS_RPED
	name = "Bluespace RPED"
	desc = ""
	id = "bs_rped"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/silver = 2500) //hardcore
	build_path = /obj/item/storage/part_replacer/bluespace
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Capacitors
/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = ""
	id = "basic_capacitor"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/stock_parts/capacitor
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = ""
	id = "adv_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 150)
	build_path = /obj/item/stock_parts/capacitor/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = ""
	id = "super_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/gold = 100)
	build_path = /obj/item/stock_parts/capacitor/super
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	desc = ""
	id = "quadratic_capacitor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/gold = 100, /datum/material/diamond = 100)
	build_path = /obj/item/stock_parts/capacitor/quadratic
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Scanning modules
/datum/design/basic_scanning
	name = "Basic Scanning Module"
	desc = ""
	id = "basic_scanning"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50)
	build_path = /obj/item/stock_parts/scanning_module
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/adv_scanning
	name = "Advanced Scanning Module"
	desc = ""
	id = "adv_scanning"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100)
	build_path = /obj/item/stock_parts/scanning_module/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/phasic_scanning
	name = "Phasic Scanning Module"
	desc = ""
	id = "phasic_scanning"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 150, /datum/material/silver = 60)
	build_path = /obj/item/stock_parts/scanning_module/phasic
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	desc = ""
	id = "triphasic_scanning"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/diamond = 30, /datum/material/bluespace = 30)
	build_path = /obj/item/stock_parts/scanning_module/triphasic
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Maipulators
/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = ""
	id = "micro_mani"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100)
	build_path = /obj/item/stock_parts/manipulator
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = ""
	id = "nano_mani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/stock_parts/manipulator/nano
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = ""
	id = "pico_mani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/stock_parts/manipulator/pico
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/femto_mani
	name = "Femto Manipulator"
	desc = ""
	id = "femto_mani"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/diamond = 30, /datum/material/titanium = 30)
	build_path = /obj/item/stock_parts/manipulator/femto
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Micro-lasers
/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = ""
	id = "basic_micro_laser"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50)
	build_path = /obj/item/stock_parts/micro_laser
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = ""
	id = "high_micro_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100)
	build_path = /obj/item/stock_parts/micro_laser/high
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = ""
	id = "ultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 150, /datum/material/uranium = 60)
	build_path = /obj/item/stock_parts/micro_laser/ultra
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	desc = ""
	id = "quadultra_micro_laser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/uranium = 100, /datum/material/diamond = 60)
	build_path = /obj/item/stock_parts/micro_laser/quadultra
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = ""
	id = "basic_matter_bin"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 100)
	build_path = /obj/item/stock_parts/matter_bin
	category = list("Stock Parts","Machinery","initial")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = ""
	id = "adv_matter_bin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/stock_parts/matter_bin/adv
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = ""
	id = "super_matter_bin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/stock_parts/matter_bin/super
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	desc = ""
	id = "bluespace_matter_bin"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 250, /datum/material/diamond = 100, /datum/material/bluespace = 100)
	build_path = /obj/item/stock_parts/matter_bin/bluespace
	category = list("Stock Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//T-Comms devices
/datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = ""
	id = "s-ansible"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/silver = 100)
	build_path = /obj/item/stock_parts/subspace/ansible
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = ""
	id = "s-filter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/silver = 100)
	build_path = /obj/item/stock_parts/subspace/filter
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = ""
	id = "s-amplifier"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/gold = 100, /datum/material/uranium = 100)
	build_path = /obj/item/stock_parts/subspace/amplifier
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = ""
	id = "s-treatment"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/silver = 200)
	build_path = /obj/item/stock_parts/subspace/treatment
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = ""
	id = "s-analyzer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/gold = 100)
	build_path = /obj/item/stock_parts/subspace/analyzer
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = ""
	id = "s-crystal"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 800, /datum/material/silver = 100, /datum/material/gold = 100)
	build_path = /obj/item/stock_parts/subspace/crystal
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = ""
	id = "s-transmitter"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 100, /datum/material/silver = 100, /datum/material/uranium = 100)
	build_path = /obj/item/stock_parts/subspace/transmitter
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE
