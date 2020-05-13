/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	active_power_usage = 250
	req_one_access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	layer = BELOW_OBJ_LAYER //So beakers reliably appear above it
	interaction_flags = INTERACT_MACHINE_NANO

	ui_x = 565
	ui_y = 620

	var/obj/item/cell/cell
	var/powerefficiency = 0.1
	var/amount = 30
	var/recharge_amount = 10
	var/recharge_counter = 0

	var/working_state = "dispenser_working"

	var/obj/item/reagent_containers/beaker = null
	var/hackedcheck = 0
	var/list/dispensable_reagents = list(
		/datum/reagent/aluminum,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/radium,
		/datum/reagent/toxin/acid,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/water
	)

	var/list/recording_recipe

	var/list/saved_recipes = list()

/obj/machinery/chem_dispenser/process()
	if (recharge_counter >= 4)
		if(!is_operational())
			return
		var/usedpower = cell?.give(recharge_amount)
		if(usedpower)
			use_power(active_power_usage * recharge_amount)
		recharge_counter = 0
		return
	recharge_counter++

/obj/machinery/chem_dispenser/Initialize()
	. = ..()
	dispensable_reagents = sortList(dispensable_reagents)
	cell = new /obj/item/cell/hyper
	start_processing()

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)


/obj/machinery/chem_dispenser/proc/work_animation()
	if(working_state)
		flick(working_state,src)

/obj/machinery/chem_dispenser/handle_atom_del(atom/movable/AM)
	if(AM == beaker)
		beaker = null


/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemDispenser", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user)
	var/data = list()
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * powerefficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * powerefficiency
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var/beakerContents[0]
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = null

	var/list/chemicals = list()
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name))))
	data["chemicals"] = chemicals
	data["recipes"] = saved_recipes

	data["recordingRecipe"] = recording_recipe
	return data

/obj/machinery/chem_dispenser/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("amount")
			if(!is_operational() || QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				work_animation()
				. = TRUE
		if("dispense")
			if(!is_operational() || QDELETED(cell))
				return
			var/reagent_name = params["reagent"]
			if(!recording_recipe)
				var/reagent = GLOB.name2reagent[reagent_name]
				if(beaker && dispensable_reagents.Find(reagent))
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(amount, (cell.charge * powerefficiency)*10, free)

					if(!cell.use(actual / powerefficiency))
						say("Not enough energy to complete operation!")
						return
					R.add_reagent(reagent, actual)

					work_animation()
			else
				recording_recipe[reagent_name] += amount
			. = TRUE
		if("remove")
			if(!is_operational() || recording_recipe)
				return
			var/amount = text2num(params["amount"])
			if(beaker && (amount in beaker.possible_transfer_amounts))
				beaker.reagents.remove_all(amount)
				work_animation()
				. = TRUE
		if("eject")
			replace_beaker(usr)
			. = TRUE

/obj/machinery/chem_dispenser/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(beaker)
		to_chat(user, "Something is already loaded into the machine.")
		return

	else if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		if(!user.transferItemToLoc(I, src))
			return

		beaker =  I
		to_chat(user, "You set [I] on the machine.")
		updateUsrDialog()

	else if(istype(I, /obj/item/reagent_containers/glass))
		to_chat(user, "Take the lid off [I] first.")


/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	req_one_access = list()
	dispensable_reagents = list(
		/datum/reagent/water,
		/datum/reagent/consumable/drink/cold/ice,
		/datum/reagent/consumable/drink/coffee,
		/datum/reagent/consumable/drink/milk/cream,
		/datum/reagent/consumable/drink/tea,
		/datum/reagent/consumable/drink/tea/icetea,
		/datum/reagent/consumable/drink/cold/space_cola,
		/datum/reagent/consumable/drink/cold/spacemountainwind,
		/datum/reagent/consumable/drink/cold/dr_gibb,
		/datum/reagent/consumable/drink/cold/space_up,
		/datum/reagent/consumable/drink/cold/tonic,
		/datum/reagent/consumable/drink/cold/sodawater,
		/datum/reagent/consumable/drink/cold/lemon_lime,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/drink/orangejuice,
		/datum/reagent/consumable/drink/lemonjuice,
		/datum/reagent/consumable/drink/watermelonjuice
	)

/obj/machinery/chem_dispenser/soda/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ismultitool(I))
		hackedcheck = !hackedcheck
		if(hackedcheck)
			to_chat(user, "You change the mode from 'McNano' to 'Pizza King'.")
			dispensable_reagents += list(
				/datum/reagent/consumable/ethanol/thirteenloko,
				/datum/reagent/consumable/drink/grapesoda)
		else
			to_chat(user, "You change the mode from 'Pizza King' to 'McNano'.")
			dispensable_reagents -= list(
				/datum/reagent/consumable/ethanol/thirteenloko,
				/datum/reagent/consumable/drink/grapesoda)

/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	req_one_access = list()
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list(
		/datum/reagent/consumable/drink/cold/lemon_lime,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/drink/orangejuice,
		/datum/reagent/consumable/drink/limejuice,
		/datum/reagent/consumable/drink/cold/sodawater,
		/datum/reagent/consumable/drink/cold/tonic,
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/kahlua,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/wine,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/gin,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/tequila,
		/datum/reagent/consumable/ethanol/vermouth,
		/datum/reagent/consumable/ethanol/cognac,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/mead)

/obj/machinery/chem_dispenser/beer/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ismultitool(I))
		hackedcheck = !hackedcheck
		if(hackedcheck)
			to_chat(user, "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes.")
			dispensable_reagents += list(
				/datum/reagent/consumable/ethanol/goldschlager,
				/datum/reagent/consumable/ethanol/patron,
				/datum/reagent/consumable/drink/watermelonjuice,
				/datum/reagent/consumable/drink/berryjuice)
		else
			to_chat(user, "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes.")
			dispensable_reagents -= list(
				/datum/reagent/consumable/ethanol/goldschlager,
				/datum/reagent/consumable/ethanol/patron,
				/datum/reagent/consumable/drink/watermelonjuice,
				/datum/reagent/consumable/drink/berryjuice)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	layer = BELOW_OBJ_LAYER //So bottles/pills reliably appear above it
	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 16
	var/pillbottlesprite = "1"
	var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"
	var/autoinjectorsprite = "11"
	var/client/has_sprites = list()
	var/max_pill_count = 20

/obj/machinery/chem_master/Initialize()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(240)
	reagents = R
	R.my_atom = src

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)


/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I,/obj/item/reagent_containers) && I.is_open_container())
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		user.transferItemToLoc(I, src)
		beaker = I
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
		updateUsrDialog()
		icon_state = "mixer1"

	else if(istype(I,/obj/item/reagent_containers/glass))
		to_chat(user, "<span class='warning'>Take off the lid first.</span>")

	else if(istype(I, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into the machine.</span>")
			return

		loaded_pill_bottle = I
		user.transferItemToLoc(I, src)
		to_chat(user, "<span class='notice'>You add the pill bottle into the dispenser slot!</span>")
		updateUsrDialog()

/obj/machinery/chem_master/proc/transfer_chemicals(obj/dest, obj/source, amount, reagent_id)
	if(istype(source))
		if(amount > 0 && source.reagents && amount <= source.reagents.maximum_volume)
			if(!istype(dest))
				source.reagents.remove_reagent(reagent_id, amount)
			else if(dest.reagents)
				source.reagents.trans_id_to(dest, reagent_id, amount)

/obj/machinery/chem_master/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr

	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = loc
			loaded_pill_bottle = null

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
					dat += "Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Chemmaster 3000</div>", 575, 400)
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if (href_list["add"])

			if(href_list["amount"])
				var/id = text2path(href_list["add"])
				var/amount = text2num(href_list["amount"])
				if(amount < 0) //href protection
					log_admin_private("[key_name(usr)] attempted to add a negative amount of [id] ([amount]) to the buffer of [src] at [AREACOORD(usr.loc)].")
					message_admins("[ADMIN_TPMONTY(usr)] attempted to add a negative amount of [id] ([amount]) to the buffer of [src]. Possible HREF exploit.")
					return
				transfer_chemicals(src, beaker, amount, id)

		else if (href_list["addcustom"])

			var/id = text2path(href_list["addcustom"])
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			transfer_chemicals(src, beaker, useramount, id)

		else if (href_list["remove"])

			if(href_list["amount"])
				var/id = text2path(href_list["remove"])
				var/amount = text2num(href_list["amount"])
				if(amount < 0) //href protection
					log_admin_private("[key_name(usr)] attempted to transfer a negative amount of [id] ([amount]) to [mode ? beaker : "disposal"] in [src] at [AREACOORD(usr.loc)].")
					message_admins("[ADMIN_TPMONTY(usr)] attempted to transfer a negative amount of [id] ([amount]) to [mode ? beaker : "disposal"] in [src]. Possible HREF exploit.")
					return
				if(mode)
					transfer_chemicals(beaker, src, amount, id)
				else
					transfer_chemicals(null, src, amount, id)


		else if (href_list["removecustom"])

			var/id = text2path(href_list["removecustom"])
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

		else if (href_list["createpillbottle"])
			if(!condi)
				if(loaded_pill_bottle)
					to_chat(user, "<span class='warning'>A pill bottle is already loaded into the machine.</span>")
					return
				var/obj/item/storage/pill_bottle/I = new/obj/item/storage/pill_bottle
				I.icon_state = "pill_canister"+pillbottlesprite
				loaded_pill_bottle = I
				to_chat(user, "<span class='notice'>The Chemmaster 3000 sets a pill bottle into the dispenser slot.</span>")
				updateUsrDialog()

		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			if (href_list["createpill_multiple"])
				count = CLAMP(input("Select the number of pills to make. (max: [max_pill_count])", 16, pillamount) as num|null,0,max_pill_count)
				if(!count)
					return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 15) amount_per_pill = 15

			var/name = reject_bad_text(input(user,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)") as text|null)
			if(!name)
				return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return
			while (count--)
				var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = name
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
				var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "bottle-"+bottlesprite
				reagents.trans_to(P,60)
				P.update_icon()
			else
				var/obj/item/reagent_containers/food/condiment/P = new/obj/item/reagent_containers/food/condiment(loc)
				reagents.trans_to(P,50)

		else if (href_list["createautoinjector"])
			if(!condi)
				var/name = reject_bad_text(input(user,"Name:","Name your autoinjector!",reagents.get_master_reagent_name()) as text|null)
				if(!name)
					return
				var/obj/item/reagent_containers/hypospray/autoinjector/fillable/P = new/obj/item/reagent_containers/hypospray/autoinjector/fillable(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] autoinjector"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "autoinjector-"+autoinjectorsprite
				reagents.trans_to(P,30)
				P.update_icon()

		else if(href_list["change_pill_bottle"])
			#define MAX_PILL_BOTTLE_SPRITE 12 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_bottle_sprite=[i]\">Select</a><img src=\"pill_canister[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Pill Bottle</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 21 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\">Select</a><img src=\"pill[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Pill</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 4 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[i]\">Select</a><img src=\"bottle-[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Bottle</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["change_autoinjector"])
			#define MAX_AUTOINJECTOR_SPRITE 11 //max icon state of the autoinjector sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_AUTOINJECTOR_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&autoinjector_sprite=[i]\">Select</a><img src=\"autoinjector-[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Autoinjector</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["pill_bottle_sprite"])
			pillbottlesprite = href_list["pill_bottle_sprite"]
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
		else if(href_list["autoinjector_sprite"])
			autoinjectorsprite = href_list["autoinjector_sprite"]

	updateUsrDialog()


/obj/machinery/chem_master/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_BOTTLE_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill_canister" + num2text(i)), "pill_canister[i].png")
			for(var/i = 1 to MAX_PILL_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "bottle-" + num2text(i)), "bottle-[i].png")
			for(var/i = 1 to MAX_AUTOINJECTOR_SPRITE)
				user << browse_rsc(icon('icons/obj/items/syringe.dmi', "autoinjector-" + num2text(i)), "autoinjector-[i].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
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
				dat += "<A href='?src=\ref[src];add=[G.type];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.type]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name];reag_type=[N.type]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=[N.type]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpillbottle=1'>Load pill bottle</A><a href=\"?src=\ref[src]&change_pill_bottle=1\">Change</a><img src=\"pill_canister[pillbottlesprite].png\" /><BR>"
			dat += "<A href='?src=\ref[src];createpill=1'>Create pill (15 units max)</A><a href=\"?src=\ref[src]&change_pill=1\">Change</a><img src=\"pill[pillsprite].png\" /><BR>"
			dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (60 units max)<a href=\"?src=\ref[src]&change_bottle=1\">Change</A><img src=\"bottle-[bottlesprite].png\" /><BR>"
			dat += "<A href='?src=\ref[src];createautoinjector=1'>Create autoinjector (30 units max)<a href=\"?src=\ref[src]&change_autoinjector=1\">Change</A><img src=\"autoinjector-[autoinjectorsprite].png\" />"
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"

	var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Chemmaster menu</div>", 575, 450)
	popup.set_content(dat)
	popup.open()


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
	anchored = TRUE
	density = TRUE


/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "mixer0"
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/computer/pandemic


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = ABOVE_TABLE_LAYER
	density = FALSE
	anchored = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	var/inuse = 0
	var/obj/item/reagent_containers/beaker = null
	var/limit = 10
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/mineral/phoron = list(/datum/reagent/toxin/phoron = 20),
		/obj/item/stack/sheet/mineral/uranium = list(/datum/reagent/uranium = 20),
		/obj/item/stack/sheet/mineral/silver = list(/datum/reagent/silver = 20),
		/obj/item/stack/sheet/mineral/gold = list(/datum/reagent/gold = 20),
		/obj/item/grown/nettle/death = list(/datum/reagent/toxin/acid/polyacid = 0),
		/obj/item/grown/nettle = list(/datum/reagent/toxin/acid = 0),

		//Blender Stuff
		/obj/item/reagent_containers/food/snacks/grown/soybeans = list(/datum/reagent/consumable/drink/milk/soymilk = 0),
		/obj/item/reagent_containers/food/snacks/grown/tomato = list(/datum/reagent/consumable/ketchup = 0),
		/obj/item/reagent_containers/food/snacks/grown/corn = list(/datum/reagent/consumable/cornoil = 0),
		///obj/item/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/reagent_containers/food/snacks/grown/ricestalk = list(/datum/reagent/consumable/rice = -5),
		/obj/item/reagent_containers/food/snacks/grown/cherries = list(/datum/reagent/consumable/cherryjelly = 0),
		/obj/item/reagent_containers/food/snacks/grown/plastellium = list(/datum/reagent/toxin/plasticide = 5),


		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/reagent_containers/pill = list(),
		/obj/item/reagent_containers/food = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff
		/obj/item/reagent_containers/food/snacks/grown/tomato = list(/datum/reagent/consumable/drink/tomatojuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/carrot = list(/datum/reagent/consumable/drink/carrotjuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/berries = list(/datum/reagent/consumable/drink/berryjuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/banana = list(/datum/reagent/consumable/drink/banana = 0),
		/obj/item/reagent_containers/food/snacks/grown/potato = list(/datum/reagent/consumable/nutriment = 0),
		/obj/item/reagent_containers/food/snacks/grown/lemon = list(/datum/reagent/consumable/drink/lemonjuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/orange = list(/datum/reagent/consumable/drink/orangejuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/lime = list(/datum/reagent/consumable/drink/limejuice = 0),
		/obj/item/reagent_containers/food/snacks/watermelonslice = list(/datum/reagent/consumable/drink/watermelonjuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/grapes = list(/datum/reagent/consumable/drink/grapejuice = 0),
		/obj/item/reagent_containers/food/snacks/grown/poisonberries = list(/datum/reagent/consumable/drink/poisonberryjuice = 0),
	)


	var/list/holdingitems = list()

/obj/machinery/reagentgrinder/Initialize()
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)


/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		if(beaker)
			return TRUE

		beaker =  I
		user.transferItemToLoc(I, src)
		update_icon()
		updateUsrDialog()
		return FALSE

	else if(length(holdingitems) >= limit)
		to_chat(user, "The machine cannot hold anymore items.")
		return TRUE

	else if(istype(I, /obj/item/storage/bag/plants))
		for(var/obj/item/reagent_containers/food/snacks/grown/G in I.contents)
			I.contents -= G
			G.forceMove(src)
			holdingitems += G
			if(length(holdingitems) >= limit)
				to_chat(user, "You fill the All-In-One grinder to the brim.")
				break

		if(!length(I.contents))
			to_chat(user, "You empty the plant bag into the All-In-One grinder.")

		updateUsrDialog()
		return FALSE

	else if(!is_type_in_list(I, blend_items) && !is_type_in_list(I, juice_items))
		to_chat(user, "Cannot refine into a reagent.")
		return TRUE

	user.transferItemToLoc(I, src)
	holdingitems += I
	updateUsrDialog()
	return FALSE


/obj/machinery/reagentgrinder/interact(mob/user)
	. = ..()
	if(.)
		return
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
		if (is_beaker_ready && !is_chamber_empty && !(machine_stat & (NOPOWER|BROKEN)))
			dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += "<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."

	var/datum/browser/popup = new(user, "reagentgrinder", "<div align='center'>All-In-One Grinder</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/reagentgrinder/Topic(href, href_list)
	. = ..()
	if(.)
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()
	updateUsrDialog()

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

/obj/machinery/reagentgrinder/proc/is_allowed(obj/item/reagent_containers/O)
	for (var/i in blend_items)
		if(istype(O, i))
			return TRUE
	return FALSE

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(obj/item/grown/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(obj/item/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(obj/item/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(obj/item/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(obj/item/reagent_containers/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(obj/item/O)
	holdingitems -= O
	qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/juicer.ogg', 25, 1)
	inuse = 1
	spawn(50)
		inuse = 0
		interact(usr)
	//Snacks
	for (var/obj/item/reagent_containers/food/snacks/O in holdingitems)
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
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(src.loc, 'sound/machines/blender.ogg', 25, 1)
	inuse = 1
	spawn(60)
		inuse = 0
		interact(usr)
	//Snacks and Plants
	for (var/obj/item/reagent_containers/food/snacks/O in holdingitems)
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
					if (O.reagents != null && O.reagents.has_reagent(/datum/reagent/consumable/nutriment))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment), space))
						O.reagents.remove_reagent(/datum/reagent/consumable/nutriment, min(O.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment), space))
				else
					if (O.reagents != null && O.reagents.has_reagent(/datum/reagent/consumable/nutriment))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)*abs(amount)), space))
						O.reagents.remove_reagent(/datum/reagent/consumable/nutriment, min(O.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment), space))

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
	for (var/obj/item/reagent_containers/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)
