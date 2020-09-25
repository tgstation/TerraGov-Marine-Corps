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
