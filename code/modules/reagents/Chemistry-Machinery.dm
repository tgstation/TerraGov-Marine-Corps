/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "dispenser"
	use_power = 0
	idle_power_usage = 40
	req_one_access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	layer = BELOW_OBJ_LAYER //So beakers reliably appear above it
	var/ui_title = "Chem Dispenser 5000"
	var/energy = 100
	var/max_energy = 100
	var/amount = 30
	var/accept_glass = FALSE //just used for the title name on the NanoUI now. Kinda misleading varname.
	var/obj/item/reagent_container/beaker = null
	var/recharged = 0
	var/hackedcheck = 0
	var/list/dispensable_reagents = list(
	"aluminum","carbon","chlorine","copper","ethanol","fluorine","hydrogen",
	"iron","lithium","mercury","nitrogen","oxygen","phosphorus","potassium",
	"radium","sacid","silicon","sodium","sugar","sulfur","tungsten","water")

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER))
		return
	var/addenergy = 10
	var/oldenergy = energy
	energy = min(energy + addenergy, max_energy)
	if(energy != oldenergy)
		use_power(1500) // This thing uses up alot of power (this is still low as shit for creating reagents from thin air)
		nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/power_change()
	..()
	nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/process()
	if(recharged <= 0)
		recharge()
		recharged = 15
	else
		recharged -= 1

/obj/machinery/chem_dispenser/New()
	..()
	recharge()
	dispensable_reagents = sortList(dispensable_reagents)
	start_processing()


/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return


/obj/machinery/chem_dispenser/on_stored_atom_del(atom/movable/AM)
	if(AM == beaker)
		beaker = null

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  *
  * @return nothing
  */
/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main",var/datum/nanoui/ui = null, var/force_open = 0)
	if(stat & (BROKEN|NOPOWER))
		return
	if(user.stat || user.is_mob_restrained())
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["energy"] = round(energy)
	data["maxEnergy"] = round(max_energy)
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["glass"] = accept_glass
	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", ui_title, 390, 655)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return FALSE // don't update UIs attached to this object

	if(href_list["amount"])
		amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		if (amount < 0) // Since the user can actually type the commands himself, some sanity checking
			amount = 0
		if (amount > 240)
			amount = 240

	if(href_list["dispense"])
		if (dispensable_reagents.Find(href_list["dispense"]) && beaker != null && beaker.is_open_container())
			var/obj/item/reagent_container/B = src.beaker
			var/datum/reagents/R = B.reagents
			var/space = R.maximum_volume - R.total_volume

			R.add_reagent(href_list["dispense"], min(amount, energy * 10, space))
			energy = max(energy - min(amount, energy * 10, space) / 10, 0)

	if(href_list["ejectBeaker"])
		if(beaker)
			var/obj/item/reagent_container/B = beaker
			B.loc = loc
			beaker = null

	add_fingerprint(usr)
	attack_hand(usr)
	return TRUE // update UIs attached to this object

/obj/machinery/chem_dispenser/attackby(var/obj/item/reagent_container/B as obj, var/mob/user as mob)
	if(iscyborg(user))
		return
	if(src.beaker)
		to_chat(user, "Something is already loaded into the machine.")
		return
	if(istype(B, /obj/item/reagent_container) && B.is_open_container())
		if(user.transferItemToLoc(B, src))
			beaker =  B
			to_chat(user, "You set [B] on the machine.")
			nanomanager.update_uis(src) // update all UIs attached to src
	else if (istype(B, /obj/item/reagent_container/glass))
		to_chat(user, "Take the lid off [B] first.")

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	var/mob/living/carbon/human/H = user
	if(!check_access(H.wear_id))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	ui_interact(user)

/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	ui_title = "Soda Dispens-o-matic"
	energy = 100
	accept_glass = TRUE
	req_one_access = list()
	max_energy = 100
	dispensable_reagents = list("water","ice","coffee","cream","tea","icetea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","watermelonjuice")

/obj/machinery/chem_dispenser/soda/attackby(var/obj/item/B as obj, var/mob/user as mob)
	..()
	if(ismultitool(B))
		if(hackedcheck == 0)
			to_chat(user, "You change the mode from 'McNano' to 'Pizza King'.")
			dispensable_reagents += list("thirteenloko","grapesoda")
			hackedcheck = 1
			return

		else
			to_chat(user, "You change the mode from 'Pizza King' to 'McNano'.")
			dispensable_reagents -= list("thirteenloko","grapesoda")
			hackedcheck = 0
			return

/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	ui_title = "Booze Portal 9001"
	energy = 100
	accept_glass = 1
	max_energy = 100
	req_one_access = list()
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","sake","wine","vodka","gin","rum","tequilla","vermouth","cognac","ale","mead")

/obj/machinery/chem_dispenser/beer/attackby(var/obj/item/B as obj, var/mob/user as mob)
	..()

	if(ismultitool(B))
		if(hackedcheck == 0)
			to_chat(user, "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes.")
			dispensable_reagents += list("goldschlager","patron","watermelonjuice","berryjuice")
			hackedcheck = 1
			return

		else
			to_chat(user, "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes.")
			dispensable_reagents -= list("goldschlager","patron","watermelonjuice","berryjuice")
			hackedcheck = 0
			return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	layer = BELOW_OBJ_LAYER //So bottles/pills reliably appear above it
	var/obj/item/reagent_container/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"
	var/client/has_sprites = list()
	var/max_pill_count = 20

/obj/machinery/chem_master/New()
	..()
	var/datum/reagents/R = new/datum/reagents(240)
	reagents = R
	R.my_atom = src

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/attackby(obj/item/I as obj, mob/living/user as mob)
	if(istype(I,/obj/item/reagent_container) && I.is_open_container())
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		user.transferItemToLoc(I, src)
		beaker = I
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
		updateUsrDialog()
		icon_state = "mixer1"
	else if (istype(I,/obj/item/reagent_container/glass))
		to_chat(user, "<span class='warning'>Take off the lid first.</span>")

	else if(istype(I, /obj/item/storage/pill_bottle))

		if(loaded_pill_bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into the machine.</span>")
			return

		loaded_pill_bottle = I
		user.transferItemToLoc(I, src)
		to_chat(user, "<span class='notice'>You add the pill bottle into the dispenser slot!</span>")
		updateUsrDialog()
	return

/obj/machinery/chem_master/proc/transfer_chemicals(var/obj/dest, var/obj/source, var/amount, var/reagent_id)
	if(istype(source))
		if(amount > 0 && source.reagents && amount <= source.reagents.maximum_volume)
			if(!istype(dest))
				source.reagents.remove_reagent(reagent_id, amount)
			else if(dest.reagents)
				source.reagents.trans_id_to(dest, reagent_id, amount)

/obj/machinery/chem_master/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(user.stat || user.is_mob_restrained())
		return
	if(!in_range(src, user))
		return

	add_fingerprint(user)
	user.set_interaction(src)


	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = loc
			loaded_pill_bottle = null
	else if(href_list["close"])
		user << browse(null, "window=chemmaster")
		user.unset_interaction()
		return

	if(beaker)
		if (href_list["analyze"])
			var/dat = ""
			if(!condi)
				var/reag_path = text2path(href_list["reag_type"])
				if(ispath(reag_path, /datum/reagent/blood))
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in beaker.reagents.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			user << browse(dat, "window=chem_master;size=575x400")
			return

		else if (href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				transfer_chemicals(src, beaker, amount, id)

		else if (href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			transfer_chemicals(src, beaker, useramount, id)

		else if (href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(mode)
					transfer_chemicals(beaker, src, amount, id)
				else
					transfer_chemicals(null, src, amount, id)


		else if (href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			if(mode)
				transfer_chemicals(beaker, src, useramount, id)
			else
				transfer_chemicals(null, src, useramount, id)

		else if (href_list["toggle"])
			mode = !mode

		else if (href_list["main"])
			attack_hand(user)
			return
		else if (href_list["eject"])
			if(beaker)
				beaker.loc = loc
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"
		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			if (href_list["createpill_multiple"])
				count = CLAMP(input("Select the number of pills to make. (max: [max_pill_count])", 10, pillamount) as num|null,0,max_pill_count)
				if(!count)
					return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 60) amount_per_pill = 60

			var/name = reject_bad_text(input(user,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)") as text|null)
			if(!name)
				return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return
			while (count--)
				var/obj/item/reagent_container/pill/P = new/obj/item/reagent_container/pill(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.pill_desc = "A [name] pill."
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill"+pillsprite
				reagents.trans_to(P,amount_per_pill)
				if(loaded_pill_bottle)
					if(loaded_pill_bottle.contents.len < loaded_pill_bottle.max_storage_space)
						loaded_pill_bottle.handle_item_insertion(P, TRUE)
						updateUsrDialog()

		else if (href_list["createbottle"])
			if(!condi)
				var/name = reject_bad_text(input(user,"Name:","Name your bottle!",reagents.get_master_reagent_name()) as text|null)
				if(!name)
					return
				var/obj/item/reagent_container/glass/bottle/P = new/obj/item/reagent_container/glass/bottle(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "bottle-"+bottlesprite
				reagents.trans_to(P,60)
				P.update_icon()
			else
				var/obj/item/reagent_container/food/condiment/P = new/obj/item/reagent_container/food/condiment(loc)
				reagents.trans_to(P,50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td></tr>"
			dat += "</table>"
			user << browse(dat, "window=chem_master")
			return
		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 4 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[i]\"><img src=\"bottle-[i].png\" /></a></td></tr>"
			dat += "</table>"
			user << browse(dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]

	//src.updateUsrDialog()
	attack_hand(user)


/obj/machinery/chem_master/attack_hand(mob/living/user)
	if(stat & BROKEN)
		return
	user.set_interaction(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "bottle-" + num2text(i)), "bottle-[i].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		if(!beaker.reagents.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in beaker.reagents.reagent_list)
				dat += "[G.name] , [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name];reag_type=[G.type]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name];reag_type=[N.type]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (60 units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
			dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (60 units max)<a href=\"?src=\ref[src]&change_bottle=1\"><img src=\"bottle-[bottlesprite].png\" /></A>"
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
	if(!condi)
		user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	else
		user << browse("<TITLE>Condimaster 3000</TITLE>Condimaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	onclose(user, "chem_master")
	return


/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

//this machine does nothing
/obj/machinery/disease2/diseaseanalyser
	name = "Disease Analyser"
	icon = 'icons/obj/machines/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1


/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	density = 1
	anchored = 1
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "mixer0"
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/computer/pandemic
	var/temphtml = ""
	var/wait = null
	var/obj/item/reagent_container/glass/beaker = null
	var/list/discovered_diseases = list()


/obj/machinery/computer/pandemic/set_broken()
	icon_state = (beaker?"mixer1_b":"mixer0_b")
	stat |= BROKEN


/obj/machinery/computer/pandemic/power_change()
	..()
	if(stat & BROKEN)
		icon_state = (beaker?"mixer1_b":"mixer0_b")

	else if(!(stat & NOPOWER))
		icon_state = (beaker?"mixer1":"mixer0")

	else
		spawn(rand(0, 15))
			icon_state = (beaker?"mixer1_nopower":"mixer0_nopower")


/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(user.stat || user.is_mob_restrained())
		return
	if(!in_range(src, user))
		return

	user.set_interaction(src)
	if(!beaker)
		return

	if (href_list["create_vaccine"])
		if(!wait)
			var/path = href_list["create_vaccine"]
			var/vaccine_type = text2path(path)
			if(!(vaccine_type in discovered_diseases))
				return
			var/obj/item/reagent_container/glass/bottle/B = new/obj/item/reagent_container/glass/bottle(loc)
			if(B)
				var/datum/disease/D = null
				if(!vaccine_type)
					D = archive_diseases[path]
					vaccine_type = path
				else
					if(vaccine_type in diseases)
						D = new vaccine_type(0, null)

				if(D)
					B.name = "[D.name] vaccine bottle"
					B.reagents.add_reagent("vaccine",15,vaccine_type)
					wait = 1
					var/datum/reagent/blood/Blood = null
					for(var/datum/reagent/blood/L in beaker.reagents.reagent_list)
						if(L)
							Blood = L
							break
					var/list/res = Blood.data["resistances"]
					spawn(res.len*200)
						wait = null
		else
			temphtml = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if (href_list["create_virus_culture"])
		if(!wait)
			var/virus_type = text2path(href_list["create_virus_culture"])//the path is received as string - converting
			if(!(virus_type in discovered_diseases))
				return
			var/obj/item/reagent_container/glass/bottle/B = new/obj/item/reagent_container/glass/bottle(src.loc)
			B.icon_state = "bottle3"
			var/datum/disease/D = null
			if(!virus_type)
				var/datum/disease/advance/A = archive_diseases[href_list["create_virus_culture"]]
				if(A)
					D = new A.type(0, A)
			else
				if(virus_type in diseases) // Make sure this is a disease
					D = new virus_type(0, null)
			var/list/data = list("viruses"=list(D))
			var/name = sanitize(input(user,"Name:","Name the culture",D.name))
			if(!name || name == " ") name = D.name
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			updateUsrDialog()
			wait = 1
			spawn(1000)
				wait = null
		else
			temphtml = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if (href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		updateUsrDialog()
		return
	else if (href_list["eject"])
		beaker.forceMove(loc)
		beaker = null
		icon_state = "mixer0"
		updateUsrDialog()
		return
	else if(href_list["clear"])
		temphtml = ""
		updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = stripped_input(user, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(stat & (NOPOWER|BROKEN))
			return
		if(user.stat || user.is_mob_restrained())
			return
		if(!in_range(src, user))
			return
		var/id = href_list["name_disease"]
		if(archive_diseases[id])
			var/datum/disease/advance/A = archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in active_diseases)
				AD.Refresh()
		updateUsrDialog()


	else
		user << browse(null, "window=pandemic")
		updateUsrDialog()
		return

	add_fingerprint(usr)
	return

/obj/machinery/computer/pandemic/attack_hand(mob/living/user)
	if(..())
		return
	user.set_interaction(src)
	var/dat = ""
	if(temphtml)
		dat = "[temphtml]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
	else if(!beaker)
		dat += "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"
	else
		var/datum/reagent/blood/Blood = null
		for(var/datum/reagent/blood/B in beaker.reagents.reagent_list)
			if(B)
				Blood = B
				break
		if(!beaker.reagents.total_volume||!beaker.reagents.reagent_list.len)
			dat += "The beaker is empty<BR>"
		else if(!Blood)
			dat += "No blood sample found in beaker"
		else if(!Blood.data)
			dat += "No blood data found in beaker."
		else
			dat += "<h3>Blood sample data:</h3>"
			dat += "<b>Blood DNA:</b> [(Blood.data["blood_DNA"]||"none")]<BR>"
			dat += "<b>Blood Type:</b> [(Blood.data["blood_type"]||"none")]<BR>"


			if(Blood.data["viruses"])
				var/list/vir = Blood.data["viruses"]
				if(vir.len)
					for(var/datum/disease/D in Blood.data["viruses"])
						if(!D.hidden[PANDEMIC])


							var/disease_creation = D.type
							if(istype(D, /datum/disease/advance))

								var/datum/disease/advance/A = D
								D = archive_diseases[A.GetDiseaseID()]
								disease_creation = A.GetDiseaseID()
								if(D.name == "Unknown")
									dat += "<b><a href='?src=\ref[src];name_disease=[A.GetDiseaseID()]'>Name Disease</a></b><BR>"

							if(!D)
								CRASH("We weren't able to get the advance disease from the archive.")

							dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[disease_creation]'>Create virus culture bottle</A>":"none"]<BR>"
							dat += "<b>Common name:</b> [(D.name||"none")]<BR>"
							dat += "<b>Description: </b> [(D.desc||"none")]<BR>"
							dat += "<b>Spread:</b> [(D.spread||"none")]<BR>"
							dat += "<b>Possible cure:</b> [(D.cure||"none")]<BR><BR>"

							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/A = D
								dat += "<b>Symptoms:</b> "
								var/english_symptoms = list()
								for(var/datum/symptom/S in A.symptoms)
									english_symptoms += S.name
								dat += english_list(english_symptoms)


			dat += "<BR><b>Contains antibodies to:</b> "
			if(Blood.data["resistances"])
				var/list/res = Blood.data["resistances"]
				if(res.len)
					dat += "<ul>"
					for(var/type in Blood.data["resistances"])
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/advance/A = archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type(0, null)
							disease_name = D.name

						dat += "<li>[disease_name] - <A href='?src=\ref[src];create_vaccine=[type]'>Create vaccine bottle</A></li>"
					dat += "</ul><BR>"
				else
					dat += "nothing<BR>"
			else
				dat += "nothing<BR>"
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((beaker.reagents.total_volume && beaker.reagents.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"

	user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
	onclose(user, "pandemic")
	return


/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/reagent_container) && I.is_open_container())
		if(stat & (NOPOWER|BROKEN))
			return
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return

		beaker =  I
		user.transferItemToLoc(I, src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
		updateUsrDialog()
		icon_state = "mixer1"

	else
		..()
	return
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = ABOVE_TABLE_LAYER
	density = 0
	anchored = 0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/inuse = 0
	var/obj/item/reagent_container/beaker = null
	var/limit = 10
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/mineral/phoron = list("phoron" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
		/obj/item/grown/nettle/death = list("pacid" = 0),
		/obj/item/grown/nettle = list("sacid" = 0),

		//Blender Stuff
		/obj/item/reagent_container/food/snacks/grown/soybeans = list("soymilk" = 0),
		/obj/item/reagent_container/food/snacks/grown/tomato = list("ketchup" = 0),
		/obj/item/reagent_container/food/snacks/grown/corn = list("cornoil" = 0),
		///obj/item/reagent_container/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/reagent_container/food/snacks/grown/ricestalk = list("rice" = -5),
		/obj/item/reagent_container/food/snacks/grown/cherries = list("cherryjelly" = 0),
		/obj/item/reagent_container/food/snacks/grown/plastellium = list("plasticide" = 5),


		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/reagent_container/pill = list(),
		/obj/item/reagent_container/food = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff
		/obj/item/reagent_container/food/snacks/grown/tomato = list("tomatojuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/carrot = list("carrotjuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/berries = list("berryjuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/reagent_container/food/snacks/grown/potato = list("potato" = 0),
		/obj/item/reagent_container/food/snacks/grown/lemon = list("lemonjuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/orange = list("orangejuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/lime = list("limejuice" = 0),
		/obj/item/reagent_container/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/grapes = list("grapejuice" = 0),
		/obj/item/reagent_container/food/snacks/grown/poisonberries = list("poisonberryjuice" = 0),
	)


	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/New()
	..()
	beaker = new /obj/item/reagent_container/glass/beaker/large(src)
	return

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)


	if (istype(O,/obj/item/reagent_container) && O.is_open_container())

		if (beaker)
			return TRUE
		else
			beaker =  O
			user.transferItemToLoc(O, src)
			update_icon()
			updateUsrDialog()
			return FALSE

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold anymore items.")
		return TRUE

	//Fill machine with the plantbag!
	if(istype(O, /obj/item/storage/bag/plants))

		for (var/obj/item/reagent_container/food/snacks/grown/G in O.contents)
			O.contents -= G
			G.loc = src
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "You fill the All-In-One grinder to the brim.")
				break

		if(!O.contents.len)
			to_chat(user, "You empty the plant bag into the All-In-One grinder.")

		src.updateUsrDialog()
		return FALSE

	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "Cannot refine into a reagent.")
		return TRUE

	user.transferItemToLoc(O, src)
	holdingitems += O
	updateUsrDialog()
	return FALSE

/obj/machinery/reagentgrinder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return FALSE

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	user.set_interaction(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!inuse)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = 1
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = 0
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = 1
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"


		dat = {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))
			dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += "<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."
	user << browse("<HEAD><TITLE>All-In-One Grinder</TITLE></HEAD><TT>[dat]</TT>", "window=reagentgrinder")
	onclose(user, "reagentgrinder")
	return


/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_interaction(src)
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/reagentgrinder/proc/detach()

	if (usr.stat != 0)
		return
	if (!beaker)
		return
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()

	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems = list()

/obj/machinery/reagentgrinder/proc/is_allowed(var/obj/item/reagent_container/O)
	for (var/i in blend_items)
		if(istype(O, i))
			return TRUE
	return FALSE

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(var/obj/item/grown/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(var/obj/item/reagent_container/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(var/obj/item/reagent_container/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(var/obj/item/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(var/obj/item/reagent_container/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(var/obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 25, 1)
	inuse = 1
	spawn(50)
		inuse = 0
		interact(usr)
	//Snacks
	for (var/obj/item/reagent_container/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 25, 1)
	inuse = 1
	spawn(60)
		inuse = 0
		interact(usr)
	//Snacks and Plants
	for (var/obj/item/reagent_container/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for (var/obj/item/stack/sheet/O in holdingitems)
		var/allowed = get_allowed_by_id(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.amount, 1); i++)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if (space < amount)
					break
			if (i == round(O.amount, 1))
				remove_object(O)
				break
	//Plants
	for (var/obj/item/grown/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//Everything else - Transfers reagents from it into beaker
	for (var/obj/item/reagent_container/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)
