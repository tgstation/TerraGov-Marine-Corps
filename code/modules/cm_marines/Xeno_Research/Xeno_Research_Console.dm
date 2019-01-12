/* Xeno RnD console from polion1232 */

//Circuits
/obj/item/circuitboard/computer/XenoRnD
	name = "Circuit board (RnD)"
	build_path = /obj/machinery/computer/XenoRnD
	origin_tech = "programming=3" // juuuust a placehonder

/obj/item/circuitboard/machine/dissector
	name = "Circuit board (Organic dissector)"
	build_path = /obj/machinery/Research_Machinery/dissector
	origin_tech = "programming=3" // juuuust a placehonder
	req_components = list(
							"/obj/item/stock_parts/scanning_module" = 1,
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/stock_parts/micro_laser" = 1
							)

/obj/item/circuitboard/machine/marineprotolathe
	name = "Circuit board (Armory Protolathe)"
	build_path = /obj/machinery/Research_Machinery/marineprotolathe
	origin_tech = null
	req_components = list(
							"/obj/item/stock_parts/matter_bin" = 3,
							"/obj/item/stock_parts/manipulator" = 2
							)

/obj/item/circuitboard/machine/biorganic
	name = "Circuit board (Bio-Organic Generator)"
	build_path = /obj/machinery/Research_Machinery/biogenerator
	origin_tech = RESEARCH_XENO_HIVELORD
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/marineResearch/xenomorph/secretor/hivelord" = 1
							)

/obj/item/circuitboard/machine/analyze_console
	name = "Circuit board (Speciemen Analyze Console)"
	build_path = /obj/machinery/computer/analyze_console
	origin_tech = "programming=3" // juuuust a placehonder

/obj/machinery/computer/XenoRnD
	name = "R&D Console"
	icon = 'icons/Marine/Research/Research_Machinery.dmi'
	icon_state = "w-y_console"
	circuit = /obj/item/circuitboard/computer/XenoRnD

	var/obj/item/research_disk/inserted_disk = null
	var/datum/marineResearch/files							//Stores all the collected research data.
	var/obj/machinery/Research_Machinery/dissector/linked_dissector = null      //linked Organic Dissector
	var/obj/machinery/Research_Machinery/marineprotolathe/linked_lathe = null 		//linked marine protolathe

	var/screen = 1.0	//Which screen is currently showing.
	var/errored = 0		//Errored during item construction.
	var/res_in_prog = 0 //Science takes time

	req_access = list(ACCESS_MARINE_RESEARCH)

/obj/machinery/computer/XenoRnD/update_icon()
	if(stat & NOPOWER)
		icon_state = "w-y_console_off"
	else if(stat & BROKEN)
		icon_state = "w-y_console_b"
	else
		icon_state = "w-y_console"

/obj/machinery/computer/XenoRnD/proc/CallTechName(var/ID) // //A simple helper proc to find the name of a tech with a given ID.
	var/datum/marineTech/tech
	var/return_name = null
	for(var/T in subtypesof(/datum/marineTech))
		tech = null
		tech = new T()
		if(tech.id == ID)
			return_name = tech.name
			qdel(tech)
			tech = null
			break

	return return_name

/obj/machinery/computer/XenoRnD/proc/CanConstruct(metal, glass, biomass)	//Check for available resource
	if(metal > linked_lathe.material_storage["metal"])
		return 0
	if(glass > linked_lathe.material_storage["glass"])
		return 0
	if(biomass > linked_lathe.material_storage["biomass"])
		return 0
	return 1

/obj/machinery/computer/XenoRnD/New()
	..()
	files = new /datum/marineResearch(src)

/obj/machinery/computer/XenoRnD/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any). Derived from rdconsole.dm
	for(var/obj/machinery/Research_Machinery/D in oview(3,src))
		if(D.linked_console != null || D.opened)
			continue
		if(istype(D, /obj/machinery/Research_Machinery/dissector))
			if(linked_dissector == null)
				linked_dissector = D
				D.linked_console = src
		if(istype(D, /obj/machinery/Research_Machinery/marineprotolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
	return

/obj/machinery/computer/XenoRnD/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/research_disk))
		user.drop_held_item()
		inserted_disk = O
		O.loc = src
		return 1
	return

/obj/machinery/computer/XenoRnD/Topic(href, href_list)				//Brutally teared from rdconsole.dm
	if(..())
		return

	add_fingerprint(usr)

	usr.set_interaction(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		if(temp_screen <= 1.0 || (3 <= temp_screen && 4.9 >= temp_screen) || src.allowed(usr) || emagged) //Unless you are making something, you need access.
			screen = temp_screen
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["reset"])
		warning("RnD console has errored during protolathe operation. Resetting.")
		errored = 0
		screen = 1.0
		updateUsrDialog()

	else if(href_list["eject"])
		inserted_disk.loc = src.loc
		inserted_disk = null
		screen = 1.0
		updateUsrDialog()

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer
		switch(href_list["eject_item"])
			if("dissector")
				if(linked_dissector)
					if(linked_dissector.busy)
						to_chat(usr, "\red The organic dissector is busy at the moment.")

					else if(linked_dissector.loaded_item)
						if(istype(linked_dissector, /obj/item/marineResearch/xenomorph/weed))
							to_chat(usr, "\red You cannot eject that.")
							screen = 2.2
							return
						linked_dissector.loaded_item.loc = linked_dissector.loc
						linked_dissector.loaded_item = null
						linked_dissector.icon_state = "d_analyzer"
						screen = 2.1

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_dissector)
			if(linked_dissector.busy)
				to_chat(usr, "\red The organic dissector is busy at the moment.")
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_dissector) return
				linked_dissector.busy = 1
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_dissector)
				spawn(24)
					if(linked_dissector)
						linked_dissector.busy = 0
						if(!linked_dissector.loaded_item)
							to_chat(usr, "\red The organic dissector appears to be empty.")
							screen = 1.0
							return
						linked_dissector.icon_state = "d_analyzer"
						files.AddToAvail(linked_dissector.loaded_item)
						linked_dissector.loaded_item = null
						use_power(linked_dissector.active_power_usage)
						screen = 1.0
						updateUsrDialog()

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		spawn(20)
			SyncRDevices()
			screen = 1.0
			updateUsrDialog()

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("dissector")
				linked_dissector.linked_console = null
				linked_dissector = null
			/*
			if("modifyer")
				linked_modifyer.linked_console = null
				linked_modifyer = null
			*/
			if("protolathe")
				linked_lathe.linked_console = null
				linked_lathe = null

	else if(href_list["research"])
		var/topic = text2num(href_list["research"])
		for(var/datum/marineTech/avail in files.available_tech)
			if(avail.id == topic)
				var/reser = input("Start research [avail.name]?") in list("Proceed", "Cancel")
				if(reser == "Cancel") return
				screen = 0.5
				res_in_prog = 1
				spawn(10*avail.time)
					errored = 1
					files.AvailToKnown(avail)
					res_in_prog = 0
					screen = 1.0
					errored = 0
					files.CheckAvail()
					updateUsrDialog()
				break

	else if(href_list["download"])
		if(!inserted_disk)
			screen = 1.0
			updateUsrDialog()
			return
		for(var/tech in inserted_disk.teches)
			switch(files.Check_tech(tech))
				if(1)						//Already known
					continue
				if(2)
					for(var/datum/marineTech/avail in files.available_tech)
						if(avail.id != tech)
							continue
						files.AvailToKnown(avail)
						break
				if(0)
					for(var/datum/marineTech/possible in files.possible_tech)
						if(possible.id != tech)
							continue
						files.ForcedToKnown(possible)
						break
		inserted_disk.loc = src.loc
		inserted_disk = null
		screen = 1.0
		updateUsrDialog()

	else if(href_list["install"])
		if(!inserted_disk)
			screen = 1.0
			updateUsrDialog()
			return
		for(var/datum/marineTech/tech in files.known_tech)
			inserted_disk.teches += tech
		inserted_disk.loc = src.loc
		inserted_disk = null
		screen = 1.0
		updateUsrDialog()

	else if(href_list["create"])
		for(var/datum/marine_design/design in files.known_design)
			if(href_list["create"] != design.id)
				continue
			if(!CanConstruct(design.materials["metal"], design.materials["glass"], design.materials["biomass"]))
				break
			errored = 1
			if(design.build_path)
				flick("protolathe_n", linked_lathe)
				errored = 0
				screen = 0.6
				linked_lathe.material_storage["metal"] -= design.materials["metal"]
				linked_lathe.material_storage["glass"] -= design.materials["glass"]
				linked_lathe.material_storage["biomass"] -= design.materials["biomass"]
				spawn(16)
					new design.build_path(linked_lathe.loc)
					screen = 4.1
					linked_lathe.RefilBio()
					break

	else if(href_list["print"])
		var/topic = text2num(href_list["print"])
		for(var/datum/marineTech/known in files.known_tech)
			if(known.id == topic)
				var/obj/item/paper/printed = new /obj/item/paper()
				printed.name = "Research report: " + known.name
				printed.info = "<B><center>TGS Theseus Medical and Research Division</B><BR>Topic: "+ known.name + "</center><HR><BR>" + known.resdesc + "<HR>Signature: "
				printed.loc = src.loc

	updateUsrDialog()
	return

/obj/machinery/computer/XenoRnD/attack_hand(mob/user as mob)			//Even more brutally teared off
	if(stat & (BROKEN|NOPOWER))
		return

	user.set_interaction(src)
	var/dat = ""
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected. 3.X will be used by modifyer
		if(2 to 2.9)
			if(linked_dissector == null)
				screen = 2.0
			else if(linked_dissector.loaded_item == null)
				screen = 2.1
			else
				screen = 2.2
		if(4 to 4.9)
			if(linked_lathe == null)
				screen = 4.0
			else
				screen = 4.1

	if(errored)
		dat += "An error has occured when constructing prototype. Try refreshing the console."
		dat += "<br>If problem persists submit bug report stating which item you tried to build."
		dat += "<br><A href='?src=\ref[src];reset=1'>RESET CONSOLE</A><br><br>"

	switch(screen)

		//////////////////////R&D CONSOLE SCREENS//////////////////
		if(0.0) dat += "Updating Database...."

		if(0.1) dat += "Dissecting in progress..."

		if(0.2)
			dat += "SYSTEM LOCKED<BR><BR>"
			dat += "<A href='?src=\ref[src];lock=1.3'>Unlock</A>"

		if(0.3)
			dat += "Modification in progress. Please Wait..."

		if(0.4)
			dat += "Imprinting Circuit. Please Wait..."

		if(0.5)
			dat += "Analysis in prosess. Please Wait..."

		if(0.6)
			dat += "Constructing equipment. Please, Stand-By..."

		if(1.0) //Main Menu
			dat += "Main Menu:<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.1'>Current Available Research</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.2'>Current Research Level</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.3'>Device Linkage Menu</A><BR>"
			//dat += "<A href='?src=\ref[src];menu=1.5'>Available Modifications</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.6'>Disk Operations</A><BR><HR>"

			if(linked_dissector != null)
				dat += "<A href='?src=\ref[src];menu=2.2'>Organic Dissector Menu</A><BR>"
			else
				dat += "NO ORGANIC DISSECTOR LINKED<BR>"

			if(linked_dissector != null)
				dat += "<A href='?src=\ref[src];menu=4.1'>Armory Protolathe Menu</A><BR>"
			else
				dat += "NO ARMORY PROTOLATHE LINKED<BR>"
/*
			if(linked_modifyer != null)
				dat += "<A href='?src=\ref[src];menu=3.2'>Equipment Modification Unit Menu</A><BR>"
			else
				dat += "NO EMU LINKED<BR>"
*/
		if(1.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><BR><BR>"
			dat += "Active Topics:<BR><BR>"
			for(var/datum/marineTech/avail in files.available_tech)
				dat += "Topic: <A href='?src=\ref[src];research=[num2text(avail.id)]'>[CallTechName(avail.id)]</A><BR>"
				dat += "Description: [avail.desc]<BR><BR>"

		if(1.2)
			dat += "Current Research Level:<HR><HR>"
			for(var/datum/marineTech/known in files.known_tech)
				dat += "Name: [known.name]<BR>"
				dat += "Description: [known.resdesc]<BR>"
				dat += "<A href='?src=\ref[src];print=[num2text(known.id)]'>PRINT</A><HR>"
			dat += "<HR><A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(1.3) //R&D device linkage
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "R&D Console Device Linkage Menu:<BR><BR>"
			dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A><BR>"
			dat += "Linked Devices:<BR>"
			if(linked_dissector)
				dat += "* Organic Dissector <A href='?src=\ref[src];disconnect=dissector'>(Disconnect)</A><BR>"
			else
				dat += "* (No Organic Dissector Linked)<BR>"
			if(linked_lathe)
				dat += "* Armory Protolathe <A href='?src=\ref[src];disconnect=protolathe'>(Disconnect)</A><BR>"
			else
				dat += "* (No Armory Protolathe Linked)<BR>"

		// 1.5 will be used for modifyer

		if(1.6)
			if(!inserted_disk)
				dat += "No Disk Inserted.<HR>"
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"
			else
				dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
				dat += "Disk Founded. Tech check result:<BR>"
				for(var/tech in inserted_disk.teches)
					dat += "[CallTechName(tech)]. "
				dat += "<HR>"
				dat += "Disk Operations: "
				dat += "<A href='?src=\ref[src];download=1'>Download technologies.</A> || <A href='?src=\ref[src];install=1'>Install technologies.</A> || <A href='?src=\ref[src];eject=1'>Eject disk.</A>"

		//////////////////////Dissector Screens//////////////////
		if(2.0)
			dat += "NO ORGANIC DISSECTOR LINKED TO CONSOLE<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(2.1)
			dat += "No Organic Item Loaded. Standing-by...<BR><HR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(2.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "Dissection Menu<HR>"
			dat += "Name: [linked_dissector.loaded_item.name]<BR>"
			dat += "Topics:<BR>"
			for(var/T in linked_dissector.loaded_item.id)
				if(files.TechMakeReqInDiss(T) != 0)
					dat += "[CallTechName(T)], "
			dat += "<BR><HR><A href='?src=\ref[src];deconstruct=1'>Dissect Item</A> || "
			dat += "<A href='?src=\ref[src];eject_item=dissector'>Eject Item</A> || "

		// 3.X will be used by modifyer

		//////////////////////Protolate Screens//////////////////
		if(4.0)
			dat += "NO ARMORY PROTOLATE LINKED TO CONSOLE<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(4.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "Current Material Amount: [linked_lathe.TotalMaterials()] units total.<BR>"
			dat += "Material Amount per resource:<BR>"
			dat += "Metal: [linked_lathe.material_storage["metal"]]/[linked_lathe.max_per_resource["metal"]]<BR>"
			dat += "Glass: [linked_lathe.material_storage["glass"]]/[linked_lathe.max_per_resource["glass"]]<BR>"
			if(files.Check_tech(RESEARCH_XENOSTART) == 1)
				dat += "Xenomorph biomatter: [linked_lathe.material_storage["biomass"]]/[linked_lathe.max_per_resource["biomass"]]<BR>"
			dat += "<BR>Available experimental equipment.<HR><HR>"
			for(var/datum/marine_design/design in files.known_design)
				dat += "<A href='?src=\ref[src];create=[design.id]'>[design.name]</A>:<BR>Description: [design.desc]<BR>"
				dat += "Requirements:<BR>Metal: [design.materials["metal"]]<BR>Glass: [design.materials["glass"]]<BR>Biomatter: [design.materials["biomass"]]<HR>"

	user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
	onclose(user, "rdconsole")