/obj/structure/xeno/resin_gargoyle
	name = "resin gargoyle"
	desc = "A resin monument to your tresspass. Alerts the xenomorph hive when an enemy approaches."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "gargoyle"
	max_integrity = 100
	xeno_structure_flags = CRITICAL_STRUCTURE|IGNORE_WEED_REMOVAL|XENO_STRUCT_WARNING_RADIUS

/obj/structure/xeno/resin_gargoyle/Initialize(mapload, _hivenumber, mob/living/carbon/xenomorph/creator)
	. = ..()
	add_overlay(emissive_appearance(icon, "[icon_state]_emissive", src))
	INVOKE_ASYNC(src, PROC_REF(set_name), creator)
	update_minimap_icon()

/obj/structure/xeno/resin_gargoyle/proc/set_name(mob/living/carbon/xenomorph/creator)
	name = initial(name) + " (" + tgui_input_text(creator, "Add a gargoyle name", "Naming") + ")"

/obj/structure/xeno/resin_gargoyle/update_icon_state()
	. = ..()
	icon_state = threat_warning ? "gargoyle_alarm" : "gargoyle"

/obj/structure/xeno/resin_gargoyle/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "gargoyle[threat_warning ? "_warn" : "_passive"]", MINIMAP_LOCATOR_LAYER))
