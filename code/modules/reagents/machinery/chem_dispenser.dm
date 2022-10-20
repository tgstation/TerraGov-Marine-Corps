/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	active_power_usage = 250
	interaction_flags = INTERACT_MACHINE_TGUI
	req_one_access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	layer = BELOW_OBJ_LAYER //So beakers reliably appear above it


	var/obj/item/cell/cell
	var/powerefficiency = 0.1
	var/amount = 30
	var/recharge_amount = 30
	var/recharge_counter = 0

	///Reagent amounts that are dispenced
	var/static/list/possible_transfer_amounts = list(1,5,10,15,20,30,40,60,120)

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

	var/list/emagged_reagents = list()

	var/list/emagged_message = list(
		"You manipulate the internal storage comparent to load from the extended storage.", // When hacked
		"You reset the internal storage compartment", // When de-hacked
	)

	var/list/recording_recipe
	///Whether untrained people get a delay when using it
	var/needs_medical_training = TRUE
	var/needs_engineer_training = TRUE
	///If TRUE, we'll clear a recipe we click on instead of dispensing it
	var/clearing_recipe = FALSE

/obj/machinery/chem_dispenser/Initialize()
	. = ..()
	dispensable_reagents = sortList(dispensable_reagents, /proc/cmp_reagents_asc)
	if(emagged_reagents)
		emagged_reagents = sortList(emagged_reagents, /proc/cmp_reagents_asc)

	cell = new /obj/item/cell/hyper
	start_processing()

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	. = ..()
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		. += "The battery compartment is open[cell ? " and there's a cell inside" : ""]."

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

/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(INFINITY)
		if(EXPLODE_HEAVY)
			if (prob(50))
				take_damage(INFINITY)

/obj/machinery/chem_dispenser/AltClick(mob/user)
	. = ..()
	replace_beaker(user)


/obj/machinery/chem_dispenser/proc/work_animation()
	if(working_state)
		flick(working_state,src)

/obj/machinery/chem_dispenser/handle_atom_del(atom/movable/AM)
	if(AM == beaker)
		beaker = null


/obj/machinery/chem_dispenser/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	// I dont care about the type of tool, if it triggers multitool act its good enough.
	hackedcheck = !hackedcheck
	if(hackedcheck)
		to_chat(user, emagged_message[1])
		dispensable_reagents += emagged_reagents
	else
		to_chat(user, emagged_message[2])
		dispensable_reagents -= emagged_reagents

/obj/machinery/chem_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser", name)
		ui.open()

/obj/machinery/chem_dispenser/ui_static_data(mob/user)
	. = list()
	.["beakerTransferAmounts"] = possible_transfer_amounts

/obj/machinery/chem_dispenser/ui_data(mob/user)
	. = list()
	.["amount"] = amount
	.["energy"] = cell?.charge * powerefficiency
	.["maxEnergy"] = cell?.maxcharge * powerefficiency
	.["isBeakerLoaded"] = beaker ? 1 : 0

	var/list/beakerContents = list()
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))	 // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	.["beakerContents"] = beakerContents

	if (beaker)
		.["beakerCurrentVolume"] = beakerCurrentVolume
		.["beakerMaxVolume"] = beaker.volume
	else
		.["beakerCurrentVolume"] = null
		.["beakerMaxVolume"] = null

	var/list/chemicals = list()
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name))))
	.["chemicals"] = chemicals
	.["recipes"] = user.client.prefs.chem_macros

	.["recordingRecipe"] = recording_recipe
	.["clearingRecipe"] = clearing_recipe

/obj/machinery/chem_dispenser/ui_act(action, list/params)
	. = ..()
	if(.)
		return



	if(needs_medical_training || needs_engineer_training && ishuman(usr))
		var/mob/living/carbon/human/user = usr
		if((user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI) && (user.skills.getRating("medical") < SKILL_MEDICAL_PRACTICED))
			to_chat(user, span_notice("You start fiddling with \the [src]..."))
			if(!do_after(user, SKILL_TASK_EASY, TRUE, src, BUSY_ICON_UNSKILLED))
				return

	switch(action)
		if("amount")
			if(!is_operational() || QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in possible_transfer_amounts)
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
			if(beaker && (amount in possible_transfer_amounts))
				beaker.reagents.remove_all(amount)
				work_animation()
				. = TRUE
		if("eject")
			replace_beaker(usr)
			. = TRUE
		if("dispense_recipe")
			if(!is_operational() || QDELETED(cell))
				return
			if(clearing_recipe)
				if(tgui_alert(usr, "Clear recipe [params["recipe"]]?", null, list("Yes","No")) == "Yes")
					usr.client.prefs.chem_macros.Remove(params["recipe"])
					usr.client.prefs.save_preferences()
				return TRUE
			var/list/chemicals_to_dispense = usr.client.prefs.chem_macros[params["recipe"]]
			if(!LAZYLEN(chemicals_to_dispense))
				return
			for(var/key in chemicals_to_dispense)
				var/reagent = GLOB.name2reagent[key]
				var/dispense_amount = chemicals_to_dispense[key]
				if(!dispensable_reagents.Find(reagent))
					to_chat(usr, span_danger("[src] cannot find <b>[key]</b>!"))
					return
				if(!recording_recipe)
					if(!beaker)
						return
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(dispense_amount, (cell.charge * powerefficiency)*10, free)
					if(actual)
						if(!cell.use(actual / powerefficiency))
							say("Not enough energy to complete operation!")
							return
						R.add_reagent(reagent, actual)
						work_animation()
				else
					recording_recipe[key] += dispense_amount
			. = TRUE
		if("clear_recipes")
			if(!is_operational())
				return
			if(clearing_recipe)
				clearing_recipe = FALSE
				return TRUE
			switch(tgui_alert(usr, "Clear all recipes?", null, list("Yes","No", "Only one")))
				if("Only one")
					clearing_recipe = TRUE
				if("Yes")
					usr.client.prefs.chem_macros = list()
					usr.client.prefs.save_preferences()
			. = TRUE
		if("record_recipe")
			if(!is_operational())
				return
			clearing_recipe = FALSE
			recording_recipe = list()
			. = TRUE
		if("save_recording")
			if(!is_operational())
				return
			var/name = stripped_input(usr, "Name", "What do you want to name this recipe?", "Recipe", MAX_NAME_LEN)
			if(usr.client.prefs.chem_macros[name] && tgui_alert(usr, "\"[name]\" already exists, do you want to overwrite it?", null, list("Yes", "No")) == "No")
				return
			else if(length(usr.client.prefs.chem_macros) >= 10)
				to_chat(usr, span_danger("You can remember <b>up to 10</b> recipes!"))
				return
			if(name && recording_recipe)
				for(var/reagent in recording_recipe)
					var/reagent_id = GLOB.name2reagent[reagent]
					if(!dispensable_reagents.Find(reagent_id))
						visible_message(span_warning("[src] buzzes."), span_hear("You hear a faint buzz."))
						to_chat(usr, span_danger("[src] cannot find <b>[reagent]</b>!"))
						playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
						return
				usr.client.prefs.chem_macros[name] = recording_recipe
				usr.client.prefs.save_preferences()
				recording_recipe = null
				. = TRUE
		if("cancel_recording")
			if(!is_operational())
				return
			recording_recipe = null
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

	if(isreagentcontainer(I))
		if(beaker)
			to_chat(user, "Something is already loaded into the machine.")
			return

		for(var/datum/reagent/X in I.reagents.reagent_list)
			if(X.medbayblacklist)
				to_chat(user, span_warning("The chemical dispenser's automatic safety features beep softly, they must have detected a harmful substance in the beaker."))
				return

		if(I.is_open_container())
			if(!user.transferItemToLoc(I, src))
				return

			beaker =  I
			to_chat(user, "You set [I] on the machine.")
			updateUsrDialog()
			return

		if(istype(I, /obj/item/reagent_containers/glass))
			to_chat(user, "Take the lid off [I] first.")
			return

		to_chat(user, "The machine can't dispense into that.")
		return

	if(istype(I, /obj/item/cell))
		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			to_chat(user, span_notice("[src]'s battery panel is closed!"))
			return
		if(cell)
			to_chat(user, span_notice("[src] already has a battery installed!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		to_chat(user, span_notice("You install \the [cell]."))
		start_processing()
		update_icon()
		return

/obj/machinery/chem_dispenser/screwdriver_act(mob/living/user, obj/item/I)
	TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
	to_chat(user, span_notice("You [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "close"] the battery compartment."))
	update_icon()
	return TRUE

/obj/machinery/chem_dispenser/crowbar_act(mob/living/user, obj/item/I)
	if(!cell || !CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return FALSE
	cell.forceMove(loc)
	cell = null
	to_chat(user, span_notice("You pry out the dispenser's battery."))
	stop_processing()
	update_icon()
	return TRUE

/obj/machinery/chem_dispenser/update_overlays()
	. = ..()
	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return
	if(cell)
		. += image(icon, "[initial(icon_state)]_open")
	else
		. += image(icon, "[initial(icon_state)]_nobat")

/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	req_one_access = list()
	dispensable_reagents = list(
		/datum/reagent/water,
		/datum/reagent/consumable/drink/milk,
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
		/datum/reagent/consumable/drink/watermelonjuice,
	)

	emagged_message = list(
		"You change the mode from 'McNano' to 'Pizza King'.",
		"You change the mode from 'Pizza King' to 'McNano'.",
	)
	emagged_reagents = list(
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/drink/grapesoda,
	)
	needs_medical_training = FALSE
	needs_engineer_training = FALSE


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
		/datum/reagent/consumable/drink/tomatojuice,
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
		/datum/reagent/consumable/ethanol/mead,
	)

	emagged_message = list(
		"You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes.",
		"You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes.",
	)
	emagged_reagents = list(
		/datum/reagent/consumable/ethanol/goldschlager,
		/datum/reagent/consumable/ethanol/patron,
		/datum/reagent/consumable/drink/watermelonjuice,
		/datum/reagent/consumable/drink/berryjuice,
	)
	needs_medical_training = FALSE
	needs_engineer_training = FALSE

/obj/machinery/chem_dispenser/valhalla
	needs_medical_training = FALSE
	needs_engineer_training = FALSE
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

/obj/machinery/chem_dispenser/valhalla/Initialize()
	. = ..()
	qdel(cell)
	cell = new /obj/item/cell/infinite

/obj/machinery/chem_dispenser/soda/nopower
	use_power = NO_POWER_USE

/obj/machinery/chem_dispenser/beer/nopower
	use_power = NO_POWER_USE
