/obj/item/map
	name = "map"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/html_link = ""


/obj/item/map/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] opens \the [src]. </span>")
	var/dat = "<iframe src='[html_link]' frameborder='0' width='1000' height='650'></iframe>"

	var/datum/browser/popup = new(user, "map", "<div align='center'>[src]</div>", 1280, 720)
	popup.set_content(dat)
	popup.open(TRUE)


/obj/item/map/lazarus_landing_map
	name = "\improper Lazarus Landing Map"
	desc = "A satellite printout of the Lazarus Landing colony on LV-624."


/obj/item/map/lazarus_landing_map/Initialize()
	. = ..()
	html_link = CONFIG_GET(string/lv624url)


/obj/item/map/ice_colony_map
	name = "\improper Ice Colony map"
	desc = "A satellite printout of the Ice Colony."
	color = "cyan"


/obj/item/map/ice_colony_map/Initialize()
	. = ..()
	html_link = CONFIG_GET(string/icecolonyurl)


/obj/item/map/whiskey_outpost_map
	name = "\improper Whiskey Outpost map"
	desc = "A tactical printout of the Whiskey Outpost defensive positions and locations."
	color = "grey"


/obj/item/map/whiskey_outpost_map/Initialize()
	. = ..()
	html_link = CONFIG_GET(string/whiskeyoutposturl)


/obj/item/map/big_red_map
	name = "\improper Solaris Ridge Map"
	desc = "A censored blueprint of the Solaris Ridge facility"
	color = "#e88a10"


/obj/item/map/big_red_map/Initialize()
	. = ..()
	html_link = CONFIG_GET(string/bigredurl)


/obj/item/map/FOP_map
	name = "\improper Fiorina Orbital Penitentiary Map"
	desc = "A labelled interior scan of Fiorina Orbital Penitentiary"
	color = "#e88a10"


/obj/item/map/FOP_map/Initialize()
	. = ..()
	html_link = CONFIG_GET(string/prisonstationurl)



//used by marine equipment machines to spawn the correct map.
/obj/item/map/current_map

/obj/item/map/current_map/Initialize()
	. = ..()
	if(!length(SSmapping.configs))
		return INITIALIZE_HINT_QDEL
	switch(SSmapping.configs[GROUND_MAP].map_name)
		if(MAP_LV_624)
			new /obj/item/map/lazarus_landing_map(loc)
		if(MAP_ICE_COLONY)
			new /obj/item/map/ice_colony_map(loc)
		if(MAP_BIG_RED)
			new /obj/item/map/big_red_map(loc)
		if(MAP_PRISON_STATION)
			new /obj/item/map/FOP_map(loc)

	return INITIALIZE_HINT_QDEL



// Landmark - Used for mapping. Will spawn the appropriate map for each gamemode (LV map items will spawn when LV is the gamemode, etc)
/obj/effect/landmark/map_item
	name = "map item"

/obj/effect/landmark/map_item/Initialize()
	. = ..()
	GLOB.map_items += loc
	return INITIALIZE_HINT_QDEL
