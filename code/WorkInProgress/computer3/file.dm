// I am deciding that for sayustation's purposes directories are right out,
// we can't even get backpacks to work right with recursion, and that
// actually fucking matters.  Metadata too, that can be added if ever needed.

/*
	Files are datums that can be stored in digital storage devices
*/

/datum/file
	var/name = "File"
	var/extension = "dat"
	var/volume = 10 // in KB
	var/image = 'icons/ntos/file.png' // determines the icon to use, found in icons/ntos
	var/obj/machinery/computer3/computer // the parent computer, if fixed
	var/obj/item/computer3_part/storage/device // the device that is containing this file
	var/hidden_file = 0 // Prevents file from showing up on NTOS program list.
	var/drm	= 0			// Copy protection, called by copy() and move()
	var/readonly = 0	// Edit protection, called by edit(), which is just a failcheck proc

	proc/execute(var/datum/file/source)
		return

	//
	// Copy file to device.
	// If you overwrite this function, use the return value to make sure it succeeded
	//
	proc/copy(var/obj/item/computer3_part/storage/dest)
		if(!computer || computer.crit_fail) return null
		if(drm)
			if(!computer.emagged)
				return null
		var/datum/file/F = new type()
		if(!dest.addfile(F))
			return null // todo: arf here even though the player can't do a damn thing due to concurrency
		return F

	//
	// Move file to device
	// Returns null on failure even though the existing file doesn't go away
	//
	proc/move(var/obj/item/computer3_part/storage/dest)
		if(!computer || computer.crit_fail) return null
		if(drm)
			if(!computer.emagged)
				return null
		var/obj/item/computer3_part/storage/current = device
		if(!dest.addfile(src))
			return null
		current.removefile(src)
		return src

	//
	// Determines if the file is editable.  This does not use the DRM flag,
	// but instead the readonly flag.
	//

	proc/edit()
		if(!computer || computer.crit_fail)
			return 0
		if(readonly && !computer.emagged)
			return 0 //
		return 1

/*
	Centcom root authorization certificate

	Non-destructive, officially sanctioned.
	Has the same effect on computers as an emag.
*/
/datum/file/centcom_auth
	name = "Centcom Root Access Token"
	extension = "auth"
	volume = 100
	copy()
		return null

/*
	Infernus: /data now falls under /program, since it contains most procs needed to finish them.
*/
/*
/datum/file/program/data

	var/content			= "content goes here"
	var/file_increment	= 1
	var/binary			= 0 // determines if the file can't be opened by editor

	// Set the content to a specific amount, increase filesize appropriately.
	proc/set_content(var/text)
		content = text
		if(file_increment > 1)
			volume = round(file_increment * length(text))

	copy(var/obj/O)
		var/datum/file/program/data/D = ..(O)
		if(D)
			D.content = content
			D.readonly = readonly

	New()
		if(content)
			if(file_increment > 1)
				volume = round(file_increment * length(content))

/*
	A generic file that contains text
*/
*/
/datum/file/program/data/text
	name = "Text File"
	extension = "txt"
	image = 'icons/ntos/file.png'
	var/dat = "text goes here!"
	var/list/logs = list()
	//file_increment = 0.002 // 0.002 kilobytes per character (1024 characters per KB)
	active_state = "text"

	interact()
		if(!interactable())
			return

		popup.set_content(dat)
		popup.open()

	New()
		..()
		if(logs.len)
			for(var/i in logs)
				dat += "<b><a href='?src=\ref[src];text_file=[i]'>[i]</a></b><br>"

	text/Topic(href, list/href_list)
		if(!interactable() || ..(href,href_list))
			return
		..()
		if ("text_file" in href_list)
			var/text_file = href_list["text_file"]
			dat = "[logs[text_file]]"
			dat += "<br><br>[topic_link(src,"return","Return")]"
			interact()
		if ("return" in href_list)
			dat = "[initial(dat)]"
			for(var/i in logs)
				dat += "<b><a href='?src=\ref[src];text_file=[i]'>[i]</a></b><br>"
			interact()



/*
/*
	A file that contains research
*/

/datum/file/program/data/research
	name = "Untitled Research"
	binary = 1
	content = "Untitled Tier X Research"
	var/datum/tech/stored // the actual tech contents
	volume = 1440

/*
	A file that contains genetic information
*/

/datum/file/program/data/genome
	name = "Genetic Buffer"
	binary = 1
	var/real_name = "Poop"


/datum/file/program/data/genome/SE
	name = "Structural Enzymes"
	var/mutantrace = null

/datum/file/program/data/genome/UE
	name = "Unique Enzymes"

/*
the way genome computers now work, a subtype is the wrong way to do this;
it will no longer be picked up.  You can change this later if you need to.
for now put it on a disk

/datum/file/data/genome/UE/GodEmperorOfMankind
	name = "G.E.M.K."
	content = "066000033000000000AF00330660FF4DB002690"
	label = "God Emperor of Mankind"
*/
/datum/file/program/data/genome/UI
	name = "Unique Identifier"

/datum/file/program/data/genome/UI/UE
	name = "Unique Identifier + Unique Enzymes"

/datum/file/program/data/genome/cloning
	name = "Cloning Data"
	var/datum/data/record/record
*/