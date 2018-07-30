/obj/item/map
	name = "map"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	throw_speed = 1
	throw_range = 5
	w_class = 1
	// color = ... (Colors can be names - "red, green, grey, cyan" or a HEX color code "#FF0000")
	var/dat        // Page content
	var/html_link = ""
	var/window_size = "1280x720"

/obj/item/map/attack_self(var/mob/usr as mob) //Open the map
	usr.visible_message("<span class='notice'>[usr] opens the [src.name]. </span>")
	initialize_map()

// /obj/item/map/attack(mob/living/carbon/human/M as mob, mob/living/carbon/human/usr as mob) //Show someone the map by hitting them with it
//     usr.visible_message("<span class='notice'>You open up the [name] and show it to [M]. </span>", \
//         "<span class='notice'>[usr] opens up the [name] and shows it to \the [M]. </span>")
//     M << initialize_map()
/obj/item/map/attack()
	return

/obj/item/map/proc/initialize_map()
	var/wikiurl = config.wikiurl
	if(wikiurl)
		dat = {"

			<html><head>
			<style>
				iframe {
					display: none;
				}
			</style>
			</head>
			<body>
			<script type="text/javascript">
				function pageloaded(myframe) {
					document.getElementById("loading").style.display = "none";
					myframe.style.display = "inline";
    			}
			</script>
			<p id='loading'>You start unfolding the map...</p>
			<iframe width='100%' height='97%' onload="pageloaded(this)" src="[wikiurl]/[html_link]?printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
			</body>

			</html>

			"}
	usr << browse("[dat]", "window=map;size=[window_size]")

/obj/item/map/lazarus_landing_map
	name = "\improper Lazarus Landing Map"
	desc = "A satellite printout of the Lazarus Landing colony on LV-624."
	html_link = "images/6/6f/LV624.png"

/obj/item/map/ice_colony_map
	name = "\improper Ice Colony map"
	desc = "A satellite printout of the Ice Colony."
	html_link = "images/1/18/Map_icecolony.png"
	color = "cyan"

/obj/item/map/whiskey_outpost_map
	name = "\improper Whiskey Outpost map"
	desc = "A tactical printout of the Whiskey Outpost defensive positions and locations."
	html_link = "images/7/78/Whiskey_outpost.png"
	color = "grey"

/obj/item/map/big_red_map
	name = "\improper Solaris Ridge Map"
	desc = "A censored blueprint of the Solaris Ridge facility"
	html_link = "images/c/c5/Big_Red.png"
	color = "#e88a10"

/obj/item/map/FOP_map
	name = "\improper Fiorina Orbital Penitentiary Map"
	desc = "A labelled interior scan of Fiorina Orbital Penitentiary"
	html_link = "images/4/4c/Map_Prison.png"
	color = "#e88a10"



//used by marine equipment machines to spawn the correct map.
/obj/item/map/current_map

/obj/item/map/current_map/New()
	..()
	if(!map_tag)
		cdel(src)
		return
	switch(map_tag)
		if(MAP_LV_624)
			name = "\improper Lazarus Landing Map"
			desc = "A satellite printout of the Lazarus Landing colony on LV-624."
			html_link = "images/6/6f/LV624.png"
		if(MAP_ICE_COLONY)
			name = "\improper Ice Colony map"
			desc = "A satellite printout of the Ice Colony."
			html_link = "images/1/18/Map_icecolony.png"
			color = "cyan"
		if(MAP_BIG_RED)
			name = "\improper Solaris Ridge Map"
			desc = "A censored blueprint of the Solaris Ridge facility"
			html_link = "images/c/c5/Big_Red.png"
			color = "#e88a10"

		if(MAP_PRISON_STATION)
			name = "\improper Fiorina Orbital Penitentiary Map"
			desc = "A labelled interior scan of Fiorina Orbital Penitentiary"
			html_link = "images/4/4c/Map_Prison.png"
			color = "#e88a10"
		else
			cdel(src)



// Landmark - Used for mapping. Will spawn the appropriate map for each gamemode (LV map items will spawn when LV is the gamemode, etc)
/obj/effect/landmark/map_item
	name = "map item"
