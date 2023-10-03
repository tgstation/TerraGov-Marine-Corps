/datum/squad
	var/list/squad_orbital_beacons = list()

/datum/squad/New()
	. = ..()
	tracking_id = SSdirection.init_squad(name, squad_leader)

	for(var/state in GLOB.playable_squad_icons)
		var/icon/top = icon('modular_RUtgmc/icons/UI_icons/map_blips.dmi', state, frame = 1)
		top.Blend(color, ICON_MULTIPLY)
		var/icon/bottom = icon('modular_RUtgmc/icons/UI_icons/map_blips.dmi', "squad_underlay", frame = 1)
		top.Blend(bottom, ICON_UNDERLAY)

		var/icon_state = lowertext(name) + "_" + state
		GLOB.minimap_icons[icon_state] = icon2base64(top)
