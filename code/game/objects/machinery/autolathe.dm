/obj/machinery/autolathe
	name = "\improper autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000

	var/list/stored_material =  list(/datum/material/metal = 0, /datum/material/glass = 0)
	var/list/storage_capacity = list(/datum/material/metal = 0, /datum/material/glass = 0)
	var/show_category = "All"

	var/hacked = FALSE
	var/disabled = FALSE
	var/shocked = FALSE
	var/busy = FALSE


/obj/machinery/autolathe/Initialize(mapload, ...)
	. = ..()

	//Create parts for lathe.
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/autolathe(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/console_screen(src)
	RefreshParts()

	wires = new /datum/wires/autolathe(src)


/obj/machinery/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/autolathe/interact(mob/user)
	. = ..()
	if(.)
		return


	var/dat = "<center>"

	dat += "<table width = '100%'>"
	var/material_top = "<tr>"
	var/material_bottom = "<tr>"

	for(var/material in stored_material)
		var/datum/material/M = GLOB.materials[material]
		material_top += "<td width = '25%' align = center><b>[M.name]</b></td>"
		material_bottom += "<td width = '25%' align = center>[stored_material[material]]<b>/[storage_capacity[material]]</b></td>"

	dat += "[material_top]</tr>[material_bottom]</tr></table><hr>"
	dat += "<h2>Printable Designs</h2><h3>Showing: <a href='?src=\ref[src];change_category=1'>[show_category]</a>.</h3></center><table width = '100%'>"

	var/index = 0
	for(var/z in GLOB.autolathe_recipes)
		var/datum/autolathe/recipe/R = z
		index++
		if(R.hidden && !hacked || (show_category != "All" && show_category != R.category))
			continue

		var/can_make = 1
		var/material_string = ""
		var/multiplier_string = ""
		var/max_sheets

		var/comma
		if(!R.resources || !R.resources.len)
			material_string = "No resources required.</td>"
		else

			//Make sure it's buildable and list requires resources.
			for(var/material in R.resources)
				var/sheets = round(stored_material[material]/R.resources[material])
				if(isnull(max_sheets) || max_sheets > sheets)
					max_sheets = sheets

				if(!isnull(stored_material[material]) && stored_material[material] < R.resources[material])
					can_make = 0
				if(!comma)
					comma = 1
				else
					material_string += ", "
				var/datum/material/M = GLOB.materials[material]
				material_string += "[R.resources[material]] [M.name]"
			material_string += ".<br></td>"

			//Build list of multipliers for sheets.
			if(R.is_stack)
				if(max_sheets && max_sheets > 0)
					multiplier_string  += "<br>"
					for(var/i = 5;i<max_sheets;i*=2) //5,10,20,40...
						multiplier_string  += "<a href='?src=\ref[src];make=[index];multiplier=[i]'>\[x[i]\]</a>"
					multiplier_string += "<a href='?src=\ref[src];make=[index];multiplier=[max_sheets]'>\[x[max_sheets]\]</a>"

		dat += "<tr><td width = 180>[R.hidden ? "<font color = 'red'>*</font>" : ""]<b>[can_make ? "<a href='?src=\ref[src];make=[index];multiplier=1'>" : ""][R.name][can_make ? "</a>" : ""]</b>[R.hidden ? "<font color = 'red'>*</font>" : ""][multiplier_string]</td><td align = right>[material_string]</tr>"

	dat += "</table><hr>"

	var/datum/browser/popup = new(user, "autolathe", "<div align='center'>Autolathe</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/autolathe/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!is_operational())
		return

	if(busy)
		to_chat(user, "<span class='warning'>\The [src] is busy. Please wait for completion of previous operation.</span>")
		return

	if(isscrewdriver(I))
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		icon_state = (CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "autolathe_t": "autolathe")
		to_chat(user, "You [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "close"] the maintenance hatch of [src].")
		updateUsrDialog()
		return

	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		//Don't eat multitools or wirecutters used on an open lathe.
		if(ismultitool(I) || iswirecutter(I))
			attack_hand(user)
			return

		//Dismantle the frame.
		if(iscrowbar(I))
			deconstruct()
			return

	//Resources are being loaded.
	var/obj/item/eating = I
	if(!eating.materials)
		to_chat(user, "<span class='warning'>\The [eating] does not contain significant amounts of useful materials and cannot be accepted.</span>")
		return

	if(eating.flags_item & (NODROP|DELONDROP))
		to_chat(user, "<span class='warning'>\The [eating] is stuck to you and cannot be placed into [src].</span>")
		return

	var/filltype = 0       // Used to determine message.
	var/total_used = 0     // Amount of material used.
	var/mass_per_sheet = 0 // Amount of material constituting one sheet.

	for(var/material in eating.materials)

		if(isnull(stored_material[material]) || isnull(storage_capacity[material]))
			continue

		if(stored_material[material] >= storage_capacity[material])
			continue

		var/total_material = eating.materials[material]

		//If it's a stack, we eat multiple sheets.
		if(istype(eating,/obj/item/stack))
			var/obj/item/stack/stack = eating
			total_material *= stack.get_amount()

		if(stored_material[material] + total_material > storage_capacity[material])
			total_material = storage_capacity[material] - stored_material[material]
			filltype = 1
		else
			filltype = 2

		stored_material[material] += total_material
		total_used += total_material
		mass_per_sheet += eating.materials[material]

	if(!filltype)
		to_chat(user, "<span class='warning'>\The [src] is full. Please remove material from the autolathe in order to insert more.</span>")
		return
	else if(filltype == 1)
		to_chat(user, "You fill \the [src] to capacity with \the [eating].")
	else
		to_chat(user, "You fill \the [src] with \the [eating].")

	flick("autolathe_o",src) // Plays metal insertion animation. Work out a good way to work out a fitting animation. ~Z

	if(istype(eating,/obj/item/stack))
		var/obj/item/stack/stack = eating
		stack.use(max(1,round(total_used/mass_per_sheet))) // Always use at least 1 to prevent infinite materials.
	else if(user.temporarilyRemoveItemFromInventory(I))
		qdel(I)

	updateUsrDialog()
	return TRUE //so the item's afterattack isn't called


/obj/machinery/autolathe/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(busy)
		to_chat(usr, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return

	if(href_list["change_category"])

		var/choice = input("Which category do you wish to display?") as null|anything in GLOB.autolathe_categories+"All"
		if(!choice) return
		show_category = choice

	if(href_list["make"] && GLOB.autolathe_recipes)

		var/index = text2num(href_list["make"])
		var/multiplier = text2num(href_list["multiplier"])
		var/datum/autolathe/recipe/making
		var/make_loc = get_step(loc, get_dir(src,usr))

		if(index > 0 && index <= length(GLOB.autolathe_recipes))
			making = GLOB.autolathe_recipes[index]

		//Exploit detection, not sure if necessary after rewrite.
		if(!making || multiplier < 0 || multiplier > 100)
			log_admin_private("[key_name(usr)] tried to exploit an autolathe to duplicate an item!")
			message_admins("[ADMIN_TPMONTY(usr)] tried to exploit an autolathe to duplicate an item!")
			return

		//This needs some work.
		use_power(max(active_power_usage, (making.power_use * multiplier)))

		//Check if we still have the materials.
		for(var/material in making.resources)
			if(!isnull(stored_material[material]))
				if(stored_material[material] < (making.resources[material]*multiplier))
					return

		busy = 1

		//Consume materials.
		for(var/material in making.resources)
			if(!isnull(stored_material[material]))
				stored_material[material] = max(0,stored_material[material]-(making.resources[material]*multiplier))

		//Fancy autolathe animation.
		flick("autolathe_n",src)

		//immediately update the autolathe window
		updateUsrDialog()

		sleep(50)

		busy = 0

		//Sanity check.
		if(!making || !src) return

		//Create the desired item.
		var/obj/item/I = new making.path(make_loc)
		if(multiplier>1 && istype(I,/obj/item/stack))
			var/obj/item/stack/S = I
			S.amount = multiplier

	updateUsrDialog()

//Updates overall lathe storage size.
/obj/machinery/autolathe/RefreshParts()
	. = ..()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating

	storage_capacity[/datum/material/metal] = tot_rating  * 25000
	storage_capacity[/datum/material/glass] = tot_rating  * 12500

/obj/machinery/autolathe/deconstruct()
	var/list/sheets = list(/datum/material/metal = /obj/item/stack/sheet/metal, /datum/material/glass = /obj/item/stack/sheet/glass)

	for(var/mat in stored_material)
		var/T = sheets[mat]
		var/obj/item/stack/sheet/S = new T
		if(stored_material[mat] > S.perunit)
			S.amount = round(stored_material[mat] / S.perunit)
			S.forceMove(loc)

	return ..()


/obj/machinery/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				hacked = FALSE
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE
