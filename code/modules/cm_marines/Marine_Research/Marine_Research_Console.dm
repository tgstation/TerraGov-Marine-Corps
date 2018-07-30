//MARINE RESEARCH CONSOLE 15JAN2016 BY APOP

//This is the Research Console for the new Marine Research System.  It controls the research database, as well as the Sample Analyzer and 3d Fabricator.
//Future machines will also be controlled from this.
//Basically, this is a rehashed RD console.
//FYI:  All the marine research weapons, still use the r_n_d class.  Don't see a reason to make another one, and this will let the w-y system link with Legacy.
#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals

/obj/machinery/computer/WYresearch
	name = "R&D Console"
	icon = 'icons/obj/mainframe.dmi'
	icon_state = "aimainframe"
//	icon_state = "rdcomp"  //Temp till i figure out what the shit is going on with the icon file.
	circuit = /obj/item/circuitboard/computer/rdconsole  //It will eventually need it's own circuit.
	var/datum/XenoResearch/files/							//Stores all the data on Le Xenos


//THIS WILL BE FOR LINKING THE ANALYZER AND FABRICATOR
	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter
	//CM MACHINES
	var/obj/machinery/r_n_d/organic_analyzer/linked_organic = null      //linked Organic Analyzer
	var/obj/machinery/r_n_d/bioprinter/linked_bioprinter = null			//linked bioprinter

	var/screen = 1.0	//Which screen is currently showing.
	var/id = 0			//ID of the computer (for server restrictions).
	var/sync = 1		//If sync = 0, it doesn't show up on Server Control Console
	var/errored = 0		//Errored during item construction.

	req_access = list(ACCESS_MARINE_RESEARCH)	//Data and setting manipulation requires scientist access.



/obj/machinery/computer/WYresearch/proc/CallTechName(var/ID) //A simple helper proc to find the name of a tech with a given ID.
	var/datum/tech/check_tech
	var/return_name = null
	for(var/T in typesof(/datum/tech) - /datum/tech)
		check_tech = null
		check_tech = new T()
		if(check_tech.id == ID)
			return_name = check_tech.name
			cdel(check_tech)
			check_tech = null
			break

	return return_name

/obj/machinery/computer/WYresearch/proc/CallMaterialName(var/ID)
	var/datum/reagent/temp_reagent
	var/return_name = null
	if (copytext(ID, 1, 2) == "$")
		return_name = copytext(ID, 2)
		switch(return_name)
			if("metal")
				return_name = "Metal"
			if("glass")
				return_name = "Glass"
			if("gold")
				return_name = "Gold"
			if("silver")
				return_name = "Silver"
			if("phoron")
				return_name = "Solid Phoron"
			if("uranium")
				return_name = "Uranium"
			if("diamond")
				return_name = "Diamond"
			if("blood") //Xeno blood - retreived during autopsy
				return_name = "Acid Blood"
			if("chitin")    //Xeno Chitin - retreived during autopsy
				return_name = "Alien Chitin"
			if("resin")   //Xeno Biomass - if an organ/sample is placed into the 3D printer instead of the Organic Analyzer, it generates this instead of research points.
				return_name = "Alien Resin"
	else
		for(var/R in typesof(/datum/reagent) - /datum/reagent)
			temp_reagent = null
			temp_reagent = new R()
			if(temp_reagent.id == ID)
				return_name = temp_reagent.name
				cdel(temp_reagent)
				temp_reagent = null
				break
	return return_name

/obj/machinery/computer/WYresearch/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
			//These are the old consoles.  This will need to be rewritten for the new ones.

	for(var/obj/machinery/r_n_d/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.opened)
			continue
		if(istype(D, /obj/machinery/r_n_d/organic_analyzer)) // CM MACHINE
			if(linked_organic == null)
				linked_organic = D
				D.linked_console = src
		if(istype(D, /obj/machinery/r_n_d/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/bioprinter)) // CM MACHINE
			if(linked_imprinter == null)
				linked_bioprinter = D
				D.linked_console = src

	return

/obj/machinery/computer/WYresearch/proc/griefProtection()
//this should be fine.  The RND server will get adjusted to work so that we can support legacy as well.
	for(var/obj/machinery/r_n_d/server/centcom/C in machines)
		for(var/datum/tech/T in files.known_tech)
			C.files.AddTech2Known(T)
		for(var/datum/design/D in files.known_designs)
			C.files.AddDesign2Known(D)
		C.files.RefreshResearch()

/obj/machinery/computer/WYresearch/New()
	..()
	files = new /datum/XenoResearch(src) //Setup the research data holder.
	/*if(!id)
		for(var/obj/machinery/r_n_d/server/centcom/S in machines)
			S.initialize()
			break*/  //THIS TOO!

/obj/machinery/computer/WYresearch/initialize()
	SyncRDevices()

/*  //LEAVING THIS FOR NOW.  Eventually, they'll be able to use a W-Y DATACUBE to copy the entire system.  Either for merc theft, Russian shenanigans, or W-Y retreival.
/obj/machinery/computer/rdconsole/attackby(var/obj/item/D as obj, var/mob/user as mob)
	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(t_disk || d_disk)
			user << "A disk is already loaded into the machine."
			return

		if(istype(D, /obj/item/disk/tech_disk)) t_disk = D
		else if (istype(D, /obj/item/disk/design_disk)) d_disk = D
		else
			user << "\red Machine cannot accept disks in that format."
			return
		user.drop_held_item()
		D.loc = src
		user << "\blue You add the disk to the machine!"
	else if(istype(D, /obj/item/card/emag) && !emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		user << "\blue You you disable the security protocols"
	else
		//The construction/deconstruction of the console code.
		..()

	src.updateUsrDialog()
	return*/


	//THIS IS A BIG'UN.  Also, I've temporarily brutalized it, but we can fix the syntax/formatting later.
/obj/machinery/computer/WYresearch/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)

	usr.set_interaction(src)
	if(href_list["menu"]) //Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		var/temp_screen = text2num(href_list["menu"])
		if(temp_screen <= 1.1 || (3 <= temp_screen && 4.9 >= temp_screen) || src.allowed(usr) || emagged) //Unless you are making something, you need access.
			screen = temp_screen
		else
			usr << "Unauthorized Access."

	else if(href_list["reset"])
		warning("RnD console has errored during protolathe operation. Resetting.")
		errored = 0
		screen = 1.0
		updateUsrDialog()

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "\red The destructive analyzer is busy at the moment."

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.loc = linked_destroy.loc
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 2.1

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(linked_destroy)
			if(linked_destroy.busy)
				usr << "\red The destructive analyzer is busy at the moment."
			else
				var/choice = input("Proceeding will destroy loaded item.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_destroy) return
				linked_destroy.busy = 1
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_destroy)
				spawn(24)
					if(linked_destroy)
						linked_destroy.busy = 0
						if(!linked_destroy.hacked)
							if(!linked_destroy.loaded_item)
								usr <<"\red The destructive analyzer appears to be empty."
								screen = 1.0
								return
							if(linked_destroy.loaded_item.reliability >= 90)
								var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
								for(var/T in temp_tech)
									files.UpdateTech(T, temp_tech[T])
							if(linked_destroy.loaded_item.reliability < 100 && linked_destroy.loaded_item.crit_fail)
								files.UpdateDesign(linked_destroy.loaded_item.type)
							if(linked_lathe && linked_destroy.loaded_item.matter) //Also sends salvaged materials to a linked protolathe, if any.
								linked_lathe.m_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.matter["metal"]*linked_destroy.decon_mod))
								linked_lathe.g_amount += min((linked_lathe.max_material_storage - linked_lathe.TotalMaterials()), (linked_destroy.loaded_item.matter["glass"]*linked_destroy.decon_mod))
							linked_destroy.loaded_item = null
						for(var/obj/I in linked_destroy.contents)
							for(var/mob/M in I.contents)
								M.death()
							if(istype(I,/obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
								var/obj/item/stack/sheet/S = I
								if(S.get_amount() > 1)
									S.use(1)
									linked_destroy.loaded_item = S
								else
									cdel(S)
									linked_destroy.icon_state = "d_analyzer"
							else
								if(!(I in linked_destroy.component_parts))
									cdel(I)
									linked_destroy.icon_state = "d_analyzer"
						use_power(linked_destroy.active_power_usage)
						screen = 1.0
						updateUsrDialog()

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			usr << "Unauthorized Access."

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		screen = 0.0
		if(!sync)
			usr << "\red You must connect to the network first!"
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in machines)
						var/server_processed = 0
						if(S.disabled)
							continue
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/datum/tech/T in files.known_tech)
								S.files.AddTech2Known(T)
							for(var/datum/design/D in files.known_designs)
								S.files.AddDesign2Known(D)
							S.files.RefreshResearch()
							server_processed = 1
						if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
							for(var/datum/tech/T in S.files.known_tech)
								files.AddTech2Known(T)
							for(var/datum/design/D in S.files.known_designs)
								files.AddDesign2Known(D)
							files.RefreshResearch()
							server_processed = 1
						if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
							S.produce_heat()
					screen = 1.6
					updateUsrDialog()

	else if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync

	else if(href_list["build"]) //Causes the Protolathe to build something.
		if(linked_lathe)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["build"])
					being_built = D
					break
			if(being_built)
				var/power = linked_lathe.active_power_usage
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(linked_lathe.active_power_usage, power)
				screen = 0.3
				linked_lathe.busy = 1
				flick("protolathe_n",linked_lathe)
				var/key = usr.key	//so we don't lose the info during the spawn delay
				spawn(16)
					use_power(power)
					spawn(16)
						errored = 1
						for(var/M in being_built.materials)
							switch(M)
								if("$metal")
									linked_lathe.m_amount = max(0, (linked_lathe.m_amount-being_built.materials[M]))
								if("$glass")
									linked_lathe.g_amount = max(0, (linked_lathe.g_amount-being_built.materials[M]))
								if("$gold")
									linked_lathe.gold_amount = max(0, (linked_lathe.gold_amount-being_built.materials[M]))
								if("$silver")
									linked_lathe.silver_amount = max(0, (linked_lathe.silver_amount-being_built.materials[M]))
								if("$phoron")
									linked_lathe.phoron_amount = max(0, (linked_lathe.phoron_amount-being_built.materials[M]))
								if("$uranium")
									linked_lathe.uranium_amount = max(0, (linked_lathe.uranium_amount-being_built.materials[M]))
								if("$diamond")
									linked_lathe.diamond_amount = max(0, (linked_lathe.diamond_amount-being_built.materials[M]))
								else
									linked_lathe.reagents.remove_reagent(M, being_built.materials[M])

						if(being_built.build_path)
							var/buildPath = text2path(being_built.build_path)
							var/obj/new_item = new buildPath(src)
							if( new_item.type == /obj/item/storage/backpack/holding )
								new_item.investigate_log("built by [key]","singulo")
							new_item.reliability = being_built.reliability
							if(linked_lathe.hacked) being_built.reliability = max((reliability / 2), 0)
							/*if(being_built.locked)
								var/obj/item/storage/lockbox/L = new/obj/item/storage/lockbox(linked_lathe.loc)
								new_item.loc = L
								L.name += " ([new_item.name])"*/
							else
								new_item.loc = linked_lathe.loc
							linked_lathe.busy = 0
							screen = 3.1
							errored = 0
						updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		if(linked_imprinter)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["imprint"])
					being_built = D
					break
			if(being_built)
				var/power = linked_imprinter.active_power_usage
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(linked_imprinter.active_power_usage, power)
				screen = 0.4
				linked_imprinter.busy = 1
				flick("circuit_imprinter_ani",linked_imprinter)
				spawn(16)
					errored = 1
					use_power(power)
					for(var/M in being_built.materials)
						switch(M)
							if("$glass")
								linked_imprinter.g_amount = max(0, (linked_imprinter.g_amount-being_built.materials[M]))
							if("$gold")
								linked_imprinter.gold_amount = max(0, (linked_imprinter.gold_amount-being_built.materials[M]))
							if("$diamond")
								linked_imprinter.diamond_amount = max(0, (linked_imprinter.diamond_amount-being_built.materials[M]))
							if("$uranium")
								linked_imprinter.uranium_amount = max(0, (linked_imprinter.uranium_amount-being_built.materials[M]))
							else
								linked_imprinter.reagents.remove_reagent(M, being_built.materials[M])
					var/obj/new_item = new being_built.build_path(src)
					new_item.reliability = being_built.reliability
					if(linked_imprinter.hacked) being_built.reliability = max((reliability / 2), 0)
					new_item.loc = linked_imprinter.loc
					linked_imprinter.busy = 0
					screen = 4.1
					errored = 0
					updateUsrDialog()

	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["dispose"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["dispose"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["lathe_ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		var/res_amount, type
		switch(href_list["lathe_ejectsheet"])
			if("metal")
				type = /obj/item/stack/sheet/metal
				res_amount = "m_amount"
			if("glass")
				type = /obj/item/stack/sheet/glass
				res_amount = "g_amount"
			if("gold")
				type = /obj/item/stack/sheet/mineral/gold
				res_amount = "gold_amount"
			if("silver")
				type = /obj/item/stack/sheet/mineral/silver
				res_amount = "silver_amount"
			if("phoron")
				type = /obj/item/stack/sheet/mineral/phoron
				res_amount = "phoron_amount"
			if("uranium")
				type = /obj/item/stack/sheet/mineral/uranium
				res_amount = "uranium_amount"
			if("diamond")
				type = /obj/item/stack/sheet/mineral/diamond
				res_amount = "diamond_amount"

		if(ispath(type) && hasvar(linked_lathe, res_amount))
			var/obj/item/stack/sheet/sheet = new type(linked_lathe.loc)
			var/available_num_sheets = round(linked_lathe.vars[res_amount]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_lathe.vars[res_amount] = max(0, (linked_lathe.vars[res_amount]-sheet.amount * sheet.perunit))
			else
				cdel(sheet)
	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the protolathe to eject a sheet of material
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		var/res_amount, type
		switch(href_list["imprinter_ejectsheet"])
			if("glass")
				type = /obj/item/stack/sheet/glass
				res_amount = "g_amount"
			if("gold")
				type = /obj/item/stack/sheet/mineral/gold
				res_amount = "gold_amount"
			if("diamond")
				type = /obj/item/stack/sheet/mineral/diamond
				res_amount = "diamond_amount"
			if("uranium")
				type = /obj/item/stack/sheet/mineral/uranium
				res_amount = "uranium_amount"
		if(ispath(type) && hasvar(linked_imprinter, res_amount))
			var/obj/item/stack/sheet/sheet = new type(linked_imprinter.loc)
			var/available_num_sheets = round(linked_imprinter.vars[res_amount]/sheet.perunit)
			if(available_num_sheets>0)
				sheet.amount = min(available_num_sheets, desired_num_sheets)
				linked_imprinter.vars[res_amount] = max(0, (linked_imprinter.vars[res_amount]-sheet.amount * sheet.perunit))
			else
				cdel(sheet)

	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		spawn(20)
			SyncRDevices()
			screen = 1.7
			updateUsrDialog()

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null
			if("organic")
				linked_organic.linked_console = null
				linked_organic = null

	else if(href_list["reset"]) //Reset the R&D console's database.
		griefProtection()
		var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			screen = 0.0
			cdel(files)
			files = new /datum/research(src)
			spawn(20)
				screen = 1.6
				updateUsrDialog()
	// CM HREFS FOR THE NEW MACHINES
	else if (href_list["organScan"])//initiate an organic scan - CM
		if(linked_organic)
			if(linked_organic.busy)
				usr << "\red The Weyland Brand Organic Analyzer(TM) is busy at the moment."
			else
				var/choice = input("Proceeding will destroy loaded item, preventing it's use for biomass.") in list("Proceed", "Cancel")
				if(choice == "Cancel" || !linked_organic) return
				linked_organic.busy = 1
				screen = 0.1
				updateUsrDialog()
				flick("d_analyzer_process", linked_organic)
				spawn(24)
					if(linked_organic)
						linked_organic.busy = 0
						if(!linked_organic.hacked)
							if(!linked_organic.loaded_item)
								usr <<"\red The Weyland Brand Organic Analyzer(TM) appears to be empty."
								screen = 1.0
								return
							if(linked_organic.loaded_item.reliability >= 90)
								var/list/temp_tech = linked_organic.ConvertReqString2List(linked_organic.loaded_item.origin_tech)
								for(var/T in temp_tech)
									files.UpdateTech(T, temp_tech[T])
							if(linked_organic.loaded_item.reliability < 100 && linked_organic.loaded_item.crit_fail)
								files.UpdateDesign(linked_organic.loaded_item.type)
							linked_organic.loaded_item = null
						for(var/obj/I in linked_organic.contents)
							for(var/mob/M in I.contents)
								M.death()
							if(!(I in linked_organic.component_parts))
								cdel(I)
								linked_organic.icon_state = "d_analyzer"
						use_power(linked_organic.active_power_usage)
						screen = 1.0
						updateUsrDialog()
	else if(href_list["eject_organ"]) //Eject the item inside the destructive analyzer.
		if(linked_organic)
			if(linked_organic.busy)
				usr << "\red The Weyland Brand Organic Analyzer(TM) is busy at the moment."

			else if(linked_organic.loaded_item)
				linked_organic.loaded_item.loc = linked_organic.loc
				linked_organic.loaded_item = null
				linked_organic.icon_state = "d_analyzer"
				screen = 5.1



	else if(href_list["bioprint"]) //Causes the bioprinter to print something
		if(linked_bioprinter)
			var/datum/design/being_built = null
			for(var/datum/design/D in files.known_designs)
				if(D.id == href_list["bioprint"])
					being_built = D
					break
			if(being_built)
				var/power = linked_bioprinter.active_power_usage
				for(var/M in being_built.materials)
					power += round(being_built.materials[M] / 5)
				power = max(linked_bioprinter.active_power_usage, power)
				screen = 0.6
				linked_bioprinter.busy = 1
				flick("protolathe",linked_bioprinter)
				spawn(16)
					use_power(power)
					spawn(16)
						errored = 1
						for(var/M in being_built.materials)
							switch(M)
								if("$chitin")
									linked_bioprinter.chitin_amount = max(0, (linked_bioprinter.chitin_amount-being_built.materials[M]))
								if("$blood")
									linked_bioprinter.blood_amount = max(0, (linked_bioprinter.blood_amount-being_built.materials[M]))
								if("$resin")
									linked_bioprinter.resin_amount = max(0, (linked_bioprinter.resin_amount-being_built.materials[M]))

						if(being_built.build_path)
							var/buildPath = text2path(being_built.build_path)
							var/obj/new_item = new buildPath(src)
							new_item.loc = linked_bioprinter.loc
							linked_bioprinter.busy = 0
							screen = 6.1
							errored = 0
						updateUsrDialog()



	updateUsrDialog()
	return



/obj/machinery/computer/WYresearch/attack_hand(mob/user as mob)
	if(stat & (BROKEN|NOPOWER))
		return

	user.set_interaction(src)
	var/dat = ""
	files.RefreshResearch()
	switch(screen) //A quick check to make sure you get the right screen when a device is disconnected.
		if(2 to 2.9)
			if(linked_destroy == null)
				screen = 2.0
			else if(linked_destroy.loaded_item == null)
				screen = 2.1
			else
				screen = 2.2
		if(3 to 3.9)
			if(linked_lathe == null)
				screen = 3.0
		if(4 to 4.9)
			if(linked_imprinter == null)
				screen = 4.0
		if(5 to 5.9)
			if(linked_organic == null)
				screen = 5.0
			else if(linked_organic.loaded_item == null)
				screen = 5.1
			else
				screen = 5.2

	if(errored)
		dat += "An error has occured when constructing prototype. Try refreshing the console."
		dat += "<br>If problem persists submit bug report stating which item you tried to build."
		dat += "<br><A href='?src=\ref[src];reset=1'>RESET CONSOLE</A><br><br>"

	switch(screen)

		//////////////////////R&D CONSOLE SCREENS//////////////////
		if(0.0) dat += "Updating Database...."

		if(0.1) dat += "Processing and Updating Database..."

		if(0.2)
			dat += "SYSTEM LOCKED<BR><BR>"
			dat += "<A href='?src=\ref[src];lock=1.6'>Unlock</A>"

		if(0.3)
			dat += "Constructing Prototype. Please Wait..."

		if(0.4)
			dat += "Imprinting Circuit. Please Wait..."

		if(0.6)
			dat += "Bioprinting. Please Wait..."

		if(1.0) //Main Menu
			dat += "Main Menu:<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.1'>Current Research Levels</A><BR>"
			if(linked_destroy != null) dat += "<A href='?src=\ref[src];menu=2.2'>Destructive Analyzer Menu</A><BR>"
			if(linked_organic != null) dat += "<A href='?src=\ref[src];menu=5.2'>Weyland Brand Organic Analyzer(TM) Menu</A><BR>"
			if(linked_lathe != null) dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Construction Menu</A><BR>"
			if(linked_imprinter != null) dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Construction Menu</A><BR>"
			if(linked_bioprinter != null) dat += "<A href='?src=\ref[src];menu=6.1'>Weyland Yutani Brand Bioprinter(TM) menu</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.6'>Settings</A>"

		if(1.1) //Research viewer
			dat += "Current Research Levels:<BR><BR>"
			for(var/datum/tech/T in files.known_tech)
				dat += "[T.name]<BR>"
				dat +=  "* Level: [T.level]<BR>"
				dat +=  "* Summary: [T.desc]<HR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(1.6) //R&D console settings
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "R&D Console Setting:<BR><BR>"
			if(sync)
				dat += "<A href='?src=\ref[src];sync=1'>Sync Database with Network</A><BR>"
				dat += "<A href='?src=\ref[src];togglesync=1'>Disconnect from Research Network</A><BR>"
			else
				dat += "<A href='?src=\ref[src];togglesync=1'>Connect to Research Network</A><BR>"
			dat += "<A href='?src=\ref[src];menu=1.7'>Device Linkage Menu</A><BR>"
			dat += "<A href='?src=\ref[src];lock=0.2'>Lock Console</A><BR>"
			dat += "<A href='?src=\ref[src];reset=1'>Reset R&D Database.</A><BR>"

		if(1.7) //R&D device linkage
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=1.6'>Settings Menu</A><HR> "
			dat += "R&D Console Device Linkage Menu:<BR><BR>"
			dat += "<A href='?src=\ref[src];find_device=1'>Re-sync with Nearby Devices</A><BR>"
			dat += "Linked Devices:<BR>"
			if(linked_destroy)
				dat += "* Destructive Analyzer <A href='?src=\ref[src];disconnect=destroy'>(Disconnect)</A><BR>"
			else
				dat += "* (No Destructive Analyzer Linked)<BR>"
			if(linked_lathe)
				dat += "* Protolathe <A href='?src=\ref[src];disconnect=lathe'>(Disconnect)</A><BR>"
			else
				dat += "* (No Protolathe Linked)<BR>"
			if(linked_imprinter)
				dat += "* Circuit Imprinter <A href='?src=\ref[src];disconnect=imprinter'>(Disconnect)</A><BR>"
			else
				dat += "* (No Circuit Imprinter Linked)<BR>"

			if(linked_organic)
				dat += "* Weyland Brand Organic Analyzer(TM) <A href='?src=\ref[src];disconnect=organic'>(Disconnect)</A><BR>"
			else
				dat += "* (No Weyland Brand Organic Analyzer(TM) linked)<BR>"
			if(linked_bioprinter)
				dat += "* Weyland Yutanii Brand Bioprinter(TM) <A href='?src=\ref[src];disconnect=bioprinter'>(Disconnect)</A><BR>"
			else
				dat += "* (No Weyland Yutani Brand Bioprinter(TM) linked)<BR>"
		////////////////////DESTRUCTIVE ANALYZER SCREENS////////////////////////////
		if(2.0)
			dat += "NO DESTRUCTIVE ANALYZER LINKED TO CONSOLE<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(2.1)
			dat += "No Item Loaded. Standing-by...<BR><HR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(2.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "Deconstruction Menu<HR>"
			dat += "Name: [linked_destroy.loaded_item.name]<BR>"
			dat += "Origin Tech:<BR>"
			var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
			for(var/T in temp_tech)
				dat += "* [CallTechName(T)] [temp_tech[T]]<BR>"
			dat += "<HR><A href='?src=\ref[src];deconstruct=1'>Deconstruct Item</A> || "
			dat += "<A href='?src=\ref[src];eject_item=1'>Eject Item</A> || "

		/////////////////////PROTOLATHE SCREENS/////////////////////////
		if(3.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "NO PROTOLATHE LINKED TO CONSOLE<BR><BR>"

		if(3.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=3.2'>Material Storage</A> || "
			dat += "<A href='?src=\ref[src];menu=3.3'>Chemical Storage</A><HR>"
			dat += "Protolathe Menu:<BR><BR>"
			dat += "<B>Material Amount:</B> [linked_lathe.TotalMaterials()] cm<sup>3</sup> (MAX: [linked_lathe.max_material_storage])<BR>"
			dat += "<B>Chemical Volume:</B> [linked_lathe.reagents.total_volume] (MAX: [linked_lathe.reagents.maximum_volume])<HR>"
			for(var/datum/design/D in files.known_designs)
				if(!(D.build_type & PROTOLATHE))//Giving an undefined va error.  It might be related to Data/Design Disks.
					continue
				var/temp_dat = "[D.name]"
				var/check_materials = 1
				for(var/M in D.materials)
					temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
					if(copytext(M, 1, 2) == "$")
						switch(M)
							if("$glass")
								if(D.materials[M] > linked_lathe.g_amount) check_materials = 0
							if("$metal")
								if(D.materials[M] > linked_lathe.m_amount) check_materials = 0
							if("$gold")
								if(D.materials[M] > linked_lathe.gold_amount) check_materials = 0
							if("$silver")
								if(D.materials[M] > linked_lathe.silver_amount) check_materials = 0
							if("$phoron")
								if(D.materials[M] > linked_lathe.phoron_amount) check_materials = 0
							if("$uranium")
								if(D.materials[M] > linked_lathe.uranium_amount) check_materials = 0
							if("$diamond")
								if(D.materials[M] > linked_lathe.diamond_amount) check_materials = 0
					else if (!linked_lathe.reagents.has_reagent(M, D.materials[M]))
						check_materials = 0
				if (check_materials)
					dat += "* <A href='?src=\ref[src];build=[D.id]'>[temp_dat]</A><BR>"
				else
					dat += "* [temp_dat]<BR>"

		if(3.2) //Protolathe Material Storage Sub-menu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A><HR>"
			dat += "Material Storage<BR><HR>"
			//Metal
			dat += "* [linked_lathe.m_amount] cm<sup>3</sup> of Metal || "
			dat += "Eject: "
			if(linked_lathe.m_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.m_amount >= 18750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.m_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=metal;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Glass
			dat += "* [linked_lathe.g_amount] cm<sup>3</sup> of Glass || "
			dat += "Eject: "
			if(linked_lathe.g_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.g_amount >= 18750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.g_amount >= 3750) dat += "<A href='?src=\ref[src];lathe_ejectsheet=glass;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Gold
			dat += "* [linked_lathe.gold_amount] cm<sup>3</sup> of Gold || "
			dat += "Eject: "
			if(linked_lathe.gold_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.gold_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.gold_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=gold;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Silver
			dat += "* [linked_lathe.silver_amount] cm<sup>3</sup> of Silver || "
			dat += "Eject: "
			if(linked_lathe.silver_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.silver_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.silver_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=silver;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Phoron
			dat += "* [linked_lathe.phoron_amount] cm<sup>3</sup> of Solid Phoron || "
			dat += "Eject: "
			if(linked_lathe.phoron_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=phoron;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.phoron_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=phoron;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.phoron_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=phoronlathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Uranium
			dat += "* [linked_lathe.uranium_amount] cm<sup>3</sup> of Uranium || "
			dat += "Eject: "
			if(linked_lathe.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.uranium_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=uranium;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Diamond
			dat += "* [linked_lathe.diamond_amount] cm<sup>3</sup> of Diamond || "
			dat += "Eject: "
			if(linked_lathe.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_lathe.diamond_amount >= 10000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_lathe.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];lathe_ejectsheet=diamond;lathe_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"

		if(3.3) //Protolathe Chemical Storage Submenu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=3.1'>Protolathe Menu</A><HR>"
			dat += "Chemical Storage<BR><HR>"
			for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
				dat += "Name: [R.name]|Units: [R.volume] "
				dat += "<A href='?src=\ref[src];disposeP=[R.id]'>(Purge)</A><BR>"
				dat += "<A href='?src=\ref[src];disposeallP=1'><U>Disposal All Chemicals in Storage</U></A><BR>"

		///////////////////CIRCUIT IMPRINTER SCREENS////////////////////
		if(4.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "NO CIRCUIT IMPRINTER LINKED TO CONSOLE<BR><BR>"

		if(4.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=4.3'>Material Storage</A> || "
			dat += "<A href='?src=\ref[src];menu=4.2'>Chemical Storage</A><HR>"
			dat += "Circuit Imprinter Menu:<BR><BR>"
			dat += "Material Amount: [linked_imprinter.TotalMaterials()] cm<sup>3</sup><BR>"
			dat += "Chemical Volume: [linked_imprinter.reagents.total_volume]<HR>"

			for(var/datum/design/D in files.known_designs)
				if(!(D.build_type & IMPRINTER))
					continue
				var/temp_dat = "[D.name]"
				var/check_materials = 1
				for(var/M in D.materials)
					temp_dat += " [D.materials[M]] [CallMaterialName(M)]"
					if(copytext(M, 1, 2) == "$")
						switch(M)
							if("$glass")
								if(D.materials[M] > linked_imprinter.g_amount) check_materials = 0
							if("$gold")
								if(D.materials[M] > linked_imprinter.gold_amount) check_materials = 0
							if("$diamond")
								if(D.materials[M] > linked_imprinter.diamond_amount) check_materials = 0
							if("$uranium")
								if(D.materials[M] > linked_imprinter.uranium_amount) check_materials = 0
					else if (!linked_imprinter.reagents.has_reagent(M, D.materials[M]))
						check_materials = 0
				if (check_materials)
					dat += "* <A href='?src=\ref[src];imprint=[D.id]'>[temp_dat]</A><BR>"
				else
					dat += "* [temp_dat]<BR>"

		if(4.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=4.1'>Imprinter Menu</A><HR>"
			dat += "Chemical Storage<BR><HR>"
			for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
				dat += "Name: [R.name]|Units: [R.volume] "
				dat += "<A href='?src=\ref[src];disposeI=[R.id]'>(Purge)</A><BR>"
				dat += "<A href='?src=\ref[src];disposeallI=1'><U>Disposal All Chemicals in Storage</U></A><BR>"

		if(4.3)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=4.1'>Circuit Imprinter Menu</A><HR>"
			dat += "Material Storage<BR><HR>"
			//Glass
			dat += "* [linked_imprinter.g_amount] cm<sup>3</sup> of Glass || "
			dat += "Eject: "
			if(linked_imprinter.g_amount >= 3750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_imprinter.g_amount >= 18750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_imprinter.g_amount >= 3750) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=glass;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Gold
			dat += "* [linked_imprinter.gold_amount] cm<sup>3</sup> of Gold || "
			dat += "Eject: "
			if(linked_imprinter.gold_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_imprinter.gold_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_imprinter.gold_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=gold;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Diamond
			dat += "* [linked_imprinter.diamond_amount] cm<sup>3</sup> of Diamond || "
			dat += "Eject: "
			if(linked_imprinter.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_imprinter.diamond_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_imprinter.diamond_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=diamond;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"
			dat += "<BR>"
			//Uranium
			dat += "* [linked_imprinter.uranium_amount] cm<sup>3</sup> of Uranium || "
			dat += "Eject: "
			if(linked_imprinter.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=uranium;imprinter_ejectsheet_amt=1'>(1 Sheet)</A> "
			if(linked_imprinter.uranium_amount >= 10000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=uranium;imprinter_ejectsheet_amt=5'>(5 Sheets)</A> "
			if(linked_imprinter.uranium_amount >= 2000) dat += "<A href='?src=\ref[src];imprinter_ejectsheet=uranium;imprinter_ejectsheet_amt=50'>(Max Sheets)</A>"

				////////////////////ORGANIC ANALYZER SCREENS////////////////////////////
		if(5.0)
			dat += "NO WEYLAND BRAND ORGANIC ANALYZER(TM) LINKED TO CONSOLE<BR><BR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(5.1)
			dat += "No Item Loaded. Standing-by...<BR><HR>"
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A>"

		if(5.2)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "Analyzer Menu<HR>"
			dat += "Name: [linked_organic.loaded_item.name]<BR>"
			dat += "Origin Tech:<BR>"
			var/list/temp_tech = linked_organic.ConvertReqString2List(linked_organic.loaded_item.origin_tech)
			for(var/T in temp_tech)
				dat += "* [CallTechName(T)] [temp_tech[T]]<BR>"
			dat += "<HR><A href='?src=\ref[src];organScan=1'>Analyze Item</A> || "
			dat += "<A href='?src=\ref[src];eject_organ=1'>Eject Item</A> || "


				////////////////////BIOPRINTER SCREENS////////////////////////////
		if(6.0)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A><HR>"
			dat += "NO BIOPRINTER LINKED TO CONSOLE<BR><BR>"

		if(6.1)
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=6.2'>Material Storage</A> || "
			dat += "Bioprinter Menu:<BR><BR>"
			dat += "<B>Material Amount:</B> [linked_bioprinter.TotalMaterials()] cm<sup>3</sup> (MAX: [linked_bioprinter.max_material_storage])<BR>"
			for(var/datum/design/D in files.known_designs)
				if(!(D.build_type & BIOPRINTER))//Giving an undefined va error.  It might be related to Data/Design Disks.
					continue
				var/temp_dat = "[D.name] || "
				var/check_materials = 1
				for(var/M in D.materials)
					temp_dat += " [D.materials[M]] [CallMaterialName(M)] |"
					if(copytext(M, 1, 2) == "$")
						switch(M)
							if("$blood")
								if(D.materials[M] > linked_bioprinter.blood_amount) check_materials = 0
							if("$chitin")
								if(D.materials[M] > linked_bioprinter.chitin_amount) check_materials = 0
							if("$resin")
								if(D.materials[M] > linked_bioprinter.resin_amount) check_materials = 0
					else if (!linked_bioprinter.reagents.has_reagent(M, D.materials[M]))
						check_materials = 0
				if (check_materials)
					dat += "* <A href='?src=\ref[src];bioprint=[D.id]'>[temp_dat]</A><BR>"
				else
					dat += "* [temp_dat]<BR>"

		if(6.2) //bioprinter Material Storage Sub-menu
			dat += "<A href='?src=\ref[src];menu=1.0'>Main Menu</A> || "
			dat += "<A href='?src=\ref[src];menu=6.1'>Bioprinter Menu</A><HR>"
			dat += "Material Storage<BR><HR>"
			//blood
			dat += "* [linked_bioprinter.blood_amount] cm<sup>3</sup> of Alien Blood || "
			dat += "<BR>"
			//chitin
			dat += "* [linked_bioprinter.chitin_amount] cm<sup>3</sup> of Alien Chitin || "
			dat += "<BR>"
			//resin
			dat += "* [linked_bioprinter.resin_amount] cm<sup>3</sup> of Alien Resin "
			dat += "<BR>"


	user << browse("<TITLE>Research and Development Console</TITLE><HR>[dat]", "window=rdconsole;size=575x400")
	onclose(user, "rdconsole")


/obj/machinery/computer/WYresearch/core
	name = "Core Weyland Research Console"
	id = 1
