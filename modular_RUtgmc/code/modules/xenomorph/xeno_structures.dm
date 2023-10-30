/obj/structure/xeno/silo
	plane = FLOOR_PLANE
	icon = 'modular_RUtgmc/icons/Xeno/resin_silo.dmi'

/obj/structure/xeno/silo/crash
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE | PLASMACUTTER_IMMUNE | INDESTRUCTIBLE

/obj/structure/xeno/acidwell
	icon = 'modular_RUtgmc/icons/Xeno/acid_pool.dmi'
	plane = FLOOR_PLANE

/obj/structure/xeno/pherotower
	icon = 'modular_RUtgmc/icons/Xeno/1x1building.dmi'

/obj/structure/xeno/pherotower/crash
	name = "Recovery tower"
	resistance_flags = RESIST_ALL
	xeno_structure_flags = IGNORE_WEED_REMOVAL | CRITICAL_STRUCTURE

/obj/structure/xeno/pherotower/crash/attack_alien(isrightclick = FALSE)
	return

/obj/structure/xeno/evotower/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('modular_RUtgmc/icons/UI_icons/map_blips.dmi', null, "tower"))

/obj/structure/xeno/psychictower/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('modular_RUtgmc/icons/UI_icons/map_blips.dmi', null, "tower"))

/obj/structure/xeno/plant
	icon = 'modular_RUtgmc/icons/Xeno/plants.dmi'

//Sentient facehugger can get in the trap
/obj/structure/xeno/trap/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, isrightclick = FALSE)
	. = ..()
	if(tgui_alert(F, "Do you want to get into the trap?", "Get inside the trap", list("Yes", "No")) != "Yes")
		return

	if(trap_type)
		F.balloon_alert(F, "The trap is occupied")
		return

	var/obj/item/clothing/mask/facehugger/FH = new(src)
	FH.go_idle(TRUE)
	hugger = FH
	set_trap_type(TRAP_HUGGER)

	F.visible_message(span_xenowarning("[F] slides back into [src]."),span_xenonotice("You slides back into [src]."))
	F.ghostize()
	F.death(deathmessage = "get inside the trap", silent = TRUE)
	qdel(F)

/obj/structure/xeno/tunnel/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, isrightclick = FALSE)
	attack_alien(F)

/obj/structure/xeno/spawner
	icon = 'modular_RUtgmc/icons/Xeno/2x2building.dmi.dmi'
	bound_width = 64
	bound_height = 64
	plane = FLOOR_PLANE

/obj/structure/xeno/spawner/Initialize(mapload)
	. = ..()
	set_light(2, 2, LIGHT_COLOR_GREEN)

/obj/structure/xeno/spawner/update_minimap_icon()
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('modular_RUtgmc/icons/UI_icons/map_blips.dmi', null, "spawner[warning ? "_warn" : "_passive"]"))

/obj/structure/xeno/pherotower/Initialize(mapload, _hivenumber)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('modular_RUtgmc/icons/UI_icons/map_blips.dmi', null, "phero"))

/obj/structure/xeno/xeno_turret/update_minimap_icon()
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('modular_RUtgmc/icons/UI_icons/map_blips.dmi', null, "xeno_turret[firing ? "_firing" : "_passive"]"))

/obj/structure/xeno/silo/update_minimap_icon()
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('modular_RUtgmc/icons/UI_icons/map_blips.dmi', null, "silo[warning ? "_warn" : "_passive"]"))
