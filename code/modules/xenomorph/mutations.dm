/obj/structure/xeno/mutation_chamber
	name = "mutation chamber"
	desc = "You shouldn't see this!"
	icon = 'icons/Xeno/1x1building.dmi'
	icon_state = "shell_chamber"
	max_integrity = 500
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL | CRITICAL_STRUCTURE

/obj/structure/xeno/upgrade_chamber/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "mutation_chamber", MINIMAP_BLIPS_LAYER))

/obj/structure/xeno/mutation_chamber/shell
	name = "Shell Chamber"
	desc = "A mash of bone, rock, and lots of resin."
	icon_state = "shell_chamber"

/obj/structure/xeno/mutation_chamber/shell/Initialize(mapload, _hivenumber)
	. = ..()
	set_light(3, 1, COLOR_DARK_CYAN)
	GLOB.hive_datums[hivenumber].shell_chambers += src
	var/total_buildings = length(GLOB.hive_datums[hivenumber].shell_chambers)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MUTATION_CHAMBER_SHELL, total_buildings - 1, total_buildings)

/obj/structure/xeno/mutation_chamber/shell/Destroy(force)
	GLOB.hive_datums[hivenumber].shell_chambers -= src
	var/total_buildings = length(GLOB.hive_datums[hivenumber].shell_chambers)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MUTATION_CHAMBER_SHELL, total_buildings + 1, total_buildings)
	return ..()

/obj/structure/xeno/mutation_chamber/spur
	name = "Spur Chamber"
	desc = "It pulses with energy."
	icon_state = "spur_chamber"

/obj/structure/xeno/mutation_chamber/spur/Initialize(mapload, _hivenumber)
	. = ..()
	set_light(3, 1, COLOR_RED)
	GLOB.hive_datums[hivenumber].spur_chambers += src
	var/total_buildings = length(GLOB.hive_datums[hivenumber].spur_chambers)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MUTATION_CHAMBER_SPUR, total_buildings - 1, total_buildings)

/obj/structure/xeno/mutation_chamber/spur/Destroy(force)
	GLOB.hive_datums[hivenumber].spur_chambers -= src
	var/total_buildings = length(GLOB.hive_datums[hivenumber].spur_chambers)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MUTATION_CHAMBER_SPUR, total_buildings + 1, total_buildings)
	return ..()

/obj/structure/xeno/mutation_chamber/veil
	name = "Veil Chamber"
	desc = "It bulges with whatever is inside it."
	icon_state = "veil_chamber"

/obj/structure/xeno/mutation_chamber/veil/Initialize(mapload, _hivenumber)
	. = ..()
	set_light(3, 1, COLOR_LIME)
	GLOB.hive_datums[hivenumber].veil_chambers += src
	var/total_buildings = length(GLOB.hive_datums[hivenumber].veil_chambers)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MUTATION_CHAMBER_VEIL, total_buildings - 1, total_buildings)

/obj/structure/xeno/mutation_chamber/veil/Destroy(force)
	GLOB.hive_datums[hivenumber].veil_chambers -= src
	var/total_buildings = length(GLOB.hive_datums[hivenumber].veil_chambers)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MUTATION_CHAMBER_VEIL, total_buildings + 1, total_buildings)
	return ..()
