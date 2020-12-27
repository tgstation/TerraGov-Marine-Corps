/datum/map_template/modular
	name = "Generic modular template"
	mappath = "_maps/modularmaps"
	///ID of this map template
	var/modular_id = "none"
	///Number for its height, used for sanity
	var/template_height = 0
	///Number for its width, used for sanity
	var/template_width = 0
	///Bool for whether we want to to be spawning from the middle or to the topright of the spawner (true is centered)
	var/keepcentered = FALSE

/datum/map_template/modular/prison
	mappath = "_maps/modularmaps/prison"

/datum/map_template/modular/prison/civresbeach
	name = "Civres South beach"
	mappath = "_maps/modularmaps/prison/civresbeach.dmm"
	modular_id = "southcivres"
	template_width = 9
	template_height = 11

/datum/map_template/modular/prison/civrespool
	name = "Civres south pool"
	mappath = "_maps/modularmaps/prison/civresgym.dmm"
	modular_id = "southcivres"
	template_width = 9
	template_height = 11

/datum/map_template/modular/prison
	mappath = "_maps/modularmaps/lv624"

/datum/map_template/modular/lv624/hydro_path
	name = "Hydro road"
	mappath = "_maps/modularmaps/lv624/hydro_path.dmm"
	modular_id = "hydroroad"
	template_width = 20
	template_height = 20

/datum/map_template/modular/lv624/hydro_jungle
	name = "Hydro maintenance path"
	mappath = "_maps/modularmaps/lv624/hydro_jungle.dmm"
	modular_id = "hydroroad"
	template_width = 20
	template_height = 20

/datum/map_template/modular/lv624/dome_atmos
	name = "LV atmos dome"
	mappath = "_maps/modularmaps/lv624/atmospherics.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_robotics
	name = "LV robotics dome"
	mappath = "_maps/modularmaps/lv624/robotics.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_telecomms
	name = "LV telecomms dome"
	mappath = "_maps/modularmaps/lv624/telecomms.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_cargo_bay
	name = "LV cargo dome"
	mappath = "_maps/modularmaps/lv624/cargo_bay.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_internal_affairs
	name = "LV internal affairs dome"
	mappath = "_maps/modularmaps/lv624/internal_affairs.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/bigred/barracks
	name = "Big red Barracks"
	mappath = "_maps/modularmaps/big_red/barracks.dmm"
	modular_id = "broperations"
	template_width = 29
	template_height = 25

/datum/map_template/modular/bigred/operations
	name = "Big red administration"
	mappath = "_maps/modularmaps/big_red/operation.dmm"
	modular_id = "broperations"
	template_width = 29
	template_height = 25

/datum/map_template/modular/end_of_round/original
	name = "Original EORG"
	mappath = "_maps/modularmaps/EORG/original.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/de_dust2
	name = "de dust 2"
	mappath = "_maps/modularmaps/EORG/de_dust2.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46
