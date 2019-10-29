/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "dispenser"
	use_power = 0
	idle_power_usage = 40
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
			use_power(250*recharge_amount)
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
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

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
		ui = new(user, src, ui_key, "chem_dispenser", name, ui_x, ui_y, master_ui, state)
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
			if(beaker && amount in beaker.possible_transfer_amounts)
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