/obj/structure/xeno/upgrade_chamber
	name = "upgrade chamber"
	desc = "You shouldn't see this!"
	icon = 'icons/Xeno/1x1building.dmi'
	icon_state = "shell_chamber"
	bound_width = 32
	bound_height = 32
	max_integrity = 500
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL | CRITICAL_STRUCTURE

/obj/structure/xeno/upgrade_chamber/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "upgrade_chamber", ABOVE_FLOAT_LAYER))

/obj/structure/xeno/upgrade_chamber/shell
	name = "Shell Chamber"
	desc = "Shell upgrade chamber"
	icon_state = "shell_chamber"

/obj/structure/xeno/upgrade_chamber/shell/Initialize(mapload, _hivenumber)
	. = ..()
	set_light(3, 1, COLOR_DARK_CYAN)
	GLOB.hive_datums[hivenumber].shell_chambers += src
	SEND_GLOBAL_SIGNAL(COMSIG_UPGRADE_CHAMBER_SURVIVAL)

/obj/structure/xeno/upgrade_chamber/shell/Destroy()
	GLOB.hive_datums[hivenumber].shell_chambers -= src
	SEND_GLOBAL_SIGNAL(COMSIG_UPGRADE_CHAMBER_SURVIVAL)
	return ..()

/obj/structure/xeno/upgrade_chamber/spur
	name = "Spur Chamber"
	desc = "Spur upgrade chamber"
	icon_state = "spur_chamber"

/obj/structure/xeno/upgrade_chamber/spur/Initialize(mapload, _hivenumber)
	. = ..()
	set_light(3, 1, COLOR_RED)
	GLOB.hive_datums[hivenumber].spur_chambers += src
	SEND_GLOBAL_SIGNAL(COMSIG_UPGRADE_CHAMBER_ATTACK)

/obj/structure/xeno/upgrade_chamber/spur/Destroy()
	GLOB.hive_datums[hivenumber].spur_chambers -= src
	SEND_GLOBAL_SIGNAL(COMSIG_UPGRADE_CHAMBER_ATTACK)
	return ..()

/obj/structure/xeno/upgrade_chamber/veil
	name = "Veil Chamber"
	desc = "Veil upgrade chamber"
	icon_state = "veil_chamber"

/obj/structure/xeno/upgrade_chamber/veil/Initialize(mapload, _hivenumber)
	. = ..()
	set_light(3, 1, COLOR_LIME)
	GLOB.hive_datums[hivenumber].veil_chambers += src
	SEND_GLOBAL_SIGNAL(COMSIG_UPGRADE_CHAMBER_UTILITY)

/obj/structure/xeno/upgrade_chamber/veil/Destroy()
	GLOB.hive_datums[hivenumber].veil_chambers -= src
	SEND_GLOBAL_SIGNAL(COMSIG_UPGRADE_CHAMBER_UTILITY)
	return ..()
