/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"

	if(!check_rights(R_ADMIN))	
		return

	var/dat = {"
		<center><B>Game Panel</B></center><hr>\n
		<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>
		<BR>
		<A href='?src=\ref[src];create_object=1'>Create Object</A><br>
		<A href='?src=\ref[src];quick_create_object=1'>Quick Create Object</A><br>
		<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>
		<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>
		"}

	usr << browse(dat, "window=admin2;size=210x280")
	return

/var/create_mob_html = null

/client/proc/create_mob(var/mob/user)
	if(!create_mob_html)
		var/mobjs = null
		mobjs = list2text(typesof(/mob), ";")
		create_mob_html = file2text('html/create_object.html')
		create_mob_html = oldreplacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(oldreplacetext(create_mob_html, "/* ref src */", "\ref[src]"), "window=create_mob;size=425x475")


/var/create_object_html = null

/client/proc/create_object(var/mob/user)
	if(!create_object_html)
		var/objectjs = null
		objectjs = list2text(typesof(/obj), ";")
		create_object_html = file2text('html/create_object.html')
		create_object_html = oldreplacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(oldreplacetext(create_object_html, "/* ref src */", "\ref[src]"), "window=create_object;size=425x475")


/client/proc/quick_create_object(var/mob/user)

	var/quick_create_object_html = null
	var/pathtext = null

	pathtext = input("Select the path of the object you wish to create.", "Path", "/obj") as null|anything in list("/obj","/obj/structure","/obj/machinery","/obj/mecha","/obj/item","/obj/item/weapon","/obj/item/ammo_magazine","/obj/item/clothing","/obj/item/storage")
	if(!pathtext)
		return
	var path = text2path(pathtext)

	if(!quick_create_object_html)
		var/objectjs = null
		objectjs = list2text(typesof(path), ";")
		quick_create_object_html = file2text('html/create_object.html')
		quick_create_object_html = oldreplacetext(quick_create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(oldreplacetext(quick_create_object_html, "/* ref src */", "\ref[src]"), "window=quick_create_object;size=425x475")


/var/create_turf_html = null

/client/proc/create_turf(var/mob/user)
	if(!create_turf_html)
		var/turfjs = null
		turfjs = list2text(typesof(/turf), ";")
		create_turf_html = file2text('html/create_object.html')
		create_turf_html = oldreplacetext(create_turf_html, "null /* object types */", "\"[turfjs]\"")

	user << browse(oldreplacetext(create_turf_html, "/* ref src */", "\ref[src]"), "window=create_turf;size=425x475")