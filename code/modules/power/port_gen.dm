//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "Placeholder Generator"	//seriously, don't use this. It can't be anchored without VV magic.
	desc = "A portable generator for emergency backup power"
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE

	var/active = FALSE
	var/power_gen = 5000
	var/power_output = 1

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return TRUE

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/power_change()
	return

/obj/machinery/power/port_gen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/port_gen/proc/TogglePower()
	if(active)
		active = FALSE
		update_icon()
	else if(HasFuel())
		active = TRUE
		update_icon()
		start_processing()

/obj/machinery/power/port_gen/update_icon()
	icon_state = "portgen[active]"

/obj/machinery/power/port_gen/process()
	if(active)
		if(!HasFuel() || !anchored)
			TogglePower()
			return
		if(powernet)
			add_avail(power_gen * power_output)
		UseFuel()
	else
		handleInactive()

/obj/machinery/power/powered()
	return TRUE //doesn't require an external power source

/obj/machinery/power/port_gen/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The generator is [active ? "on" : "off"].</span>")
	if(!anchored)
		to_chat(user,"<span class='warning'>It isn't anchored.</span>")

//A power generator that runs on solid plasma sheets.
/obj/machinery/power/port_gen/pacman
	name = "P.A.C.M.A.N.-type Portable Generator"
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_name = ""
	var/sheet_path = /obj/item/stack/sheet/mineral/phoron
	var/board_path = /obj/item/circuitboard/machine/pacman
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 60
	var/heat = 0
	power_gen = 20000
	drag_delay = 1 //They got them rollers

/obj/machinery/power/port_gen/pacman/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/cable_coil(src)
	component_parts += new /obj/item/stack/cable_coil(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new board_path(src)
	RefreshParts()
	var/obj/S = sheet_path
	sheet_name = initial(S.name)
	if(anchored)
		connect_to_network()

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	. = ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = 0
	var/temp_reliability = 0
	for(var/obj/item/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/stock_parts/micro_laser) || istype(SP, /obj/item/stock_parts/capacitor))
			temp_rating += SP.rating
	for(var/obj/item/CP in component_parts)
		temp_reliability += CP.reliability
	reliability = min(round(temp_reliability / 4), 100)
	power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The generator has [sheets] units of [sheet_name] fuel left, producing [DisplayPower(power_gen)] per cycle.</span>")


/obj/machinery/power/port_gen/pacman/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		var/fail_safe = 0
		while(sheets > 0 && fail_safe < 100)
			fail_safe += 1
			var/obj/item/stack/sheet/S = new sheet_path(loc)
			var/amount = min(sheets, S.max_amount)
			S.amount = amount
			sheets -= amount

/obj/machinery/power/port_gen/pacman/UseFuel()
	var/needed_sheets = 1 / (time_per_sheet / power_output)
	var/temp = min(needed_sheets, sheet_left)
	needed_sheets -= temp
	sheet_left -= temp
	sheets -= round(needed_sheets)
	needed_sheets -= round(needed_sheets)
	if (sheet_left <= 0 && sheets > 0)
		sheet_left = 1 - needed_sheets
		sheets--

	var/lower_limit = 56 + power_output * 10
	var/upper_limit = 76 + power_output * 10
	var/bias = 0
	if (power_output > 4)
		upper_limit = 400
		bias = power_output * 3
	if (heat < lower_limit)
		heat += 3
	else
		heat += rand(-7 + bias, 7 + bias)
		if (heat < lower_limit)
			heat = lower_limit
		if (heat > upper_limit)
			heat = upper_limit

	if (heat > 300)
		overheat()
		qdel(src)

/obj/machinery/power/port_gen/pacman/handleInactive()
	heat = max(heat - 2, 0)
	if(heat == 0)
		stop_processing()

/obj/machinery/power/port_gen/pacman/proc/overheat()
	explosion(src.loc, 2, 5, 2, -1)

/obj/machinery/power/port_gen/pacman/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, sheet_path))
		var/obj/item/stack/addstack = I
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, "<span class='notice'>\The [src] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You add [amount] sheets to \the [src].</span>")
		sheets += amount
		addstack.use(amount)

	else if(!active && iswrench(I))
		anchored = !anchored

		if(anchored)
			connect_to_network()
			to_chat(user, "<span class='notice'>You secure the generator to the floor.</span>")
		else
			disconnect_from_network()
			to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")

		playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)


/obj/machinery/power/port_gen/pacman/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/machinery/power/port_gen/pacman/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/power/port_gen/pacman/attack_paw(mob/living/carbon/monkey/user)
	ui_interact(user)

/obj/machinery/power/port_gen/pacman/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	. = ..()

	var/list/data = list()

	data["active"] = active
	data["sheet_name"] = capitalize(sheet_name)
	data["sheets"] = sheets
	data["stack_percent"] = sheet_left * 100

	data["connected"] = (powernet == null ? 0 : 1)
	data["ready_to_boot"] = anchored && HasFuel()
	data["power_generated"] = DisplayPower(power_gen)
	data["power_output"] = DisplayPower(power_gen * power_output)
	data["power_available"] = (powernet == null ? 0 : DisplayPower(avail()))
	data["heat"] = heat

	data += "<b>[name]</b><br>"

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "port_gen.tmpl", "Generator Interface", 460, 320)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(TRUE)

/obj/machinery/power/port_gen/pacman/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["toggle_power"])
		TogglePower()
		. = TRUE
	if(href_list["eject"])
		if(!active)
			DropFuel()
			. = TRUE
	if(href_list["lower_power"])
		if (power_output > 1)
			power_output--
			. = TRUE
	if (href_list["higher_power"])
		if (power_output < 4)
			power_output++
			. = TRUE

/obj/machinery/power/port_gen/pacman/super
	name = "S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "portgen1"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	power_gen = 40000
	time_per_sheet = 120
	board_path = /obj/item/circuitboard/machine/pacman/super
	overheat()
		explosion(src.loc, 3, 3, 3, -1)

/obj/machinery/power/port_gen/pacman/mrs
	name = "M.R.S.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "portgen2"
	sheet_path = /obj/item/stack/sheet/mineral/tritium
	power_gen = 80000
	time_per_sheet = 240
	board_path = /obj/item/circuitboard/machine/pacman/mrs
	overheat()
		explosion(src.loc, 4, 4, 4, -1)
