/obj/item/weapon/map
	name = "map"
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "map"
	item_state = "map"
	throw_speed = 1
	throw_range = 5
	w_class = 3
	// color = ... (Colors can be names - "red, green, grey, cyan" or a HEX color code "#FF0000")
	var/dat        // Page content
	var/author = "<TT><I>Authenticated by Weyland-Yutani.</I></TT> <BR>"
	var/size = "800x800" // The size of the window. This should be at most 25 pixels more than the map image in both width and height in order for it to fit nicely in the window without scrollbars.

/obj/item/weapon/map/attack_self(var/mob/usr as mob) //Open the map
	if(src.dat)
		usr << browse("[author]" + "[dat]", "window=map;size=[size]")
		usr.visible_message("[usr] opens the [src.name].")
		onclose(usr, "map")
	else
		usr << "This map is completely blank!"

/obj/item/weapon/map/attack(mob/living/carbon/human/M as mob, mob/living/carbon/human/usr as mob) //Show someone the map by hitting them with it
	usr.visible_message("<span class='notice'>You open up the [name] and show it to [M]. </span>", \
		"<span class='notice'>[usr] opens up the [name] and shows it to \the [M]. </span>")
	M << browse("[author]" + "[dat]", "window=map;size=[size]")


/*
Map images should be placed in html\images. The image name must then be added to the send_resources() proc in \code\modules\client\client procs.dm.
*/


/obj/item/weapon/map/lazarus_landing
	name = "\improper Lazarus Landing Map"
	desc = "A satellite printout of the Lazarus Landing colony."
	size = "800x475"
	dat = {"
		<html><head>
			</head>
				<body>
					<img src="LV624.png">
				</body>
			</html>
		"}

/obj/item/weapon/map/ice_colony
	name = "\improper Ice Colony map"
	desc = "A satellite printout of the Ice Colony."
	size = "725x475"
	color = "cyan"
	dat = {"
		<html><head>
			</head>
				<body>
					<img src="IceColony.png">
				</body>
			</html>
		"}

/obj/item/weapon/map/whiskey_outpost
	name = "\improper Whiskey Outpost Map"
	desc = "A tactical printout of the Whiskey Outpost defensive positions and locations."
	size = "775x725"
	color = "grey"
	dat = {"
		<html><head>
			</head>
				<body>
					<img src="whiskeyoutpost.png">
				</body>
			</html>
		"}

/obj/item/weapon/map/big_red
	name = "\improper Solaris Ridge Map"
	desc = "A censored blueprint of the Solaris Ridge facility."
	size = "775x725"
	color = "#e88a10"
	dat = {"
		<html><head>
			</head>
				<body>
					<img src="BigRed.png">
				</body>
			</html>
		"}
