/proc/get_ground_map_url(map_name = SSmapping.configs[GROUND_MAP].map_name)
	var/current_map = length(SSmapping.configs) && SSmapping.configs[GROUND_MAP] ? SSmapping.configs[GROUND_MAP].map_name : null
	var/default_ground_url = current_map && current_map == map_name ? SSmapping.configs[GROUND_MAP].webmap_url : null
	var/ground_url
	switch(map_name)
		if(MAP_BIG_RED)
			ground_url = CONFIG_GET(string/webmap_url_ground_bigred)
		if(MAP_ICE_COLONY)
			ground_url = CONFIG_GET(string/webmap_url_ground_icecolony)
		if(MAP_ICY_CAVES)
			ground_url = CONFIG_GET(string/webmap_url_ground_icecaves)
		if(MAP_LV_624)
			ground_url = CONFIG_GET(string/webmap_url_ground_lv624)
		if(MAP_PRISON_STATION)
			ground_url = CONFIG_GET(string/webmap_url_ground_prisonstation)
		if(MAP_RESEARCH_OUTPOST)
			ground_url = CONFIG_GET(string/webmap_url_ground_researchoutpost)
		if(MAP_WHISKEY_OUTPOST)
			ground_url = CONFIG_GET(string/webmap_url_ground_whiskeyoutpost)
	if(!ground_url)
		ground_url = default_ground_url

	return ground_url

/proc/get_ship_map_url(ship_name = SSmapping.configs[SHIP_MAP].map_name)
	var/current_ship = length(SSmapping.configs) && SSmapping.configs[SHIP_MAP] ? SSmapping.configs[SHIP_MAP].map_name : null
	var/default_ship_url = current_ship && current_ship == ship_name ? SSmapping.configs[SHIP_MAP].webmap_url : null
	var/ship_url
	switch(ship_name)
		if(MAP_PILLAR_OF_SPRING)
			ship_url = CONFIG_GET(string/webmap_url_ship_pillar)
		if(MAP_SULACO)
			ship_url = CONFIG_GET(string/webmap_url_ship_sulaco)
		if(MAP_THESEUS)
			ship_url = CONFIG_GET(string/webmap_url_ship_thesues)
	if(!ship_url)
		ship_url = default_ship_url

	return ship_url
