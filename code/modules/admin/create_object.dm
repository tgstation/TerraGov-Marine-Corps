/var/create_object_html = null

/datum/admins/proc/create_object(var/mob/user)
	if (!create_object_html)
		var/objectjs = null
		objectjs = list2text(typesof(/obj), ";")
		create_object_html = file2text('html/create_object.html')
		create_object_html = oldreplacetext(create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(oldreplacetext(create_object_html, "/* ref src */", "\ref[src]"), "window=create_object;size=425x475")


/datum/admins/proc/quick_create_object(var/mob/user)

	var/quick_create_object_html = null
	var/pathtext = null

	pathtext = input("Select the path of the object you wish to create.", "Path", "/obj") as null|anything in list("/obj","/obj/structure","/obj/machinery","/obj/mecha","/obj/item","/obj/item/weapon","/obj/item/ammo_magazine","/obj/item/clothing","/obj/item/storage")
	if(!pathtext)
		return
	var path = text2path(pathtext)

	if (!quick_create_object_html)
		var/objectjs = null
		objectjs = list2text(typesof(path), ";")
		quick_create_object_html = file2text('html/create_object.html')
		quick_create_object_html = oldreplacetext(quick_create_object_html, "null /* object types */", "\"[objectjs]\"")

	user << browse(oldreplacetext(quick_create_object_html, "/* ref src */", "\ref[src]"), "window=quick_create_object;size=425x475")
