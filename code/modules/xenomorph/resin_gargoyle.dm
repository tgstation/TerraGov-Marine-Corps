/obj/structure/xeno/resin_gargoyle
	name = "resin gargoyle"
	desc = "A resin monument to your tresspass. Alerts the xenomorph hive when an enemy approaches."
	icon = 'icons/Xeno/2x2building.dmi'
	icon_state = "gargoyle"
	max_integrity = 100
	xeno_structure_flags = CRITICAL_STRUCTURE|IGNORE_WEED_REMOVAL
	///Bool if we're currently alerting
	var/is_alerting = FALSE
	//cd tracking for the alert
	COOLDOWN_DECLARE(proxy_alert_cooldown)

/obj/structure/xeno/resin_gargoyle/Initialize(mapload, _hivenumber, mob/living/carbon/xenomorph/creator)
	. = ..()
	for(var/turfs in RANGE_TURFS(XENO_GARGOYLE_DETECTION_RANGE, src))
		RegisterSignal(turfs, COMSIG_ATOM_ENTERED, PROC_REF(gargoyle_alarm))
	add_overlay(emissive_appearance(icon, "[icon_state]_emissive"))
	INVOKE_ASYNC(src, PROC_REF(set_name), creator)

/obj/structure/xeno/resin_gargoyle/proc/set_name(mob/living/carbon/xenomorph/creator)
	name = initial(name) + " (" + tgui_input_text(creator, "Add a gargoyle name", "Naming") + ")"

/// Checks performed every time an atom moves in a turf watched by the gargoyle
/obj/structure/xeno/resin_gargoyle/proc/gargoyle_alarm(datum/source, atom/movable/hostile, direction)
	SIGNAL_HANDLER

	if(!COOLDOWN_CHECK(src, proxy_alert_cooldown))
		return

	if(!isliving(hostile))
		return

	var/mob/living/living_triggerer = hostile
	if(living_triggerer.stat == DEAD)
		return

	if(isxeno(hostile))
		var/mob/living/carbon/xenomorph/X = hostile
		if(X.hive == GLOB.hive_datums[hivenumber]) //Trigger proxy alert only for hostile xenos
			return

	is_alerting = TRUE
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] has detected a hostile [hostile] at [get_area(hostile)].", "xenoannounce", 5, FALSE, hostile, 'sound/voice/alien_talk2.ogg', FALSE, null, /atom/movable/screen/arrow/leader_tracker_arrow)
	COOLDOWN_START(src, proxy_alert_cooldown, XENO_GARGOYLE_DETECTION_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_GARGOYLE_DETECTION_COOLDOWN, TIMER_STOPPABLE)
	update_minimap_icon()
	update_appearance()

///resets gargoyle to normal state after yelling
/obj/structure/xeno/resin_gargoyle/proc/clear_warning()
	is_alerting = FALSE
	update_minimap_icon()
	update_appearance()

/obj/structure/xeno/resin_gargoyle/update_icon_state()
	. = ..()
	icon_state = is_alerting ? "gargoyle_alarm" : "gargoyle"

///resets minimap icon for the gargoyle
/obj/structure/xeno/resin_gargoyle/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "gargoyle[is_alerting ? "_alarm" : ""]", ABOVE_FLOAT_LAYER))
