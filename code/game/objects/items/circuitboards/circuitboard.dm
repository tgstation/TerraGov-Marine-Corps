/obj/item/circuitboard
	w_class = WEIGHT_CLASS_TINY
	name = "Circuit board"
	icon = 'icons/obj/items/circuitboards.dmi'
	icon_state = "id_mod"
	item_state = "electronic"
	flags_atom = CONDUCT
	materials = list(/datum/material/metal = 50, /datum/material/glass = 50)
	var/build_path = null
	var/is_general_board = FALSE

/obj/item/circuitboard/attackby(obj/item/I , mob/user, params)
	. = ..()
	if(ismultitool(I) && is_general_board == TRUE)
		var/obj/item/circuitboard/new_board
		var/modepick = tgui_input_list(user, "Select a mode for this circuit.", null,list("APC", "Airlock", "Fire Alarm", "Air Alarm"))
		switch(modepick)
			if("APC")
				new_board = new /obj/item/circuitboard/apc(user.loc)
			if("Airlock")
				new_board = new /obj/item/circuitboard/airlock(user.loc)
			if("Fire Alarm")
				new_board = new /obj/item/circuitboard/firealarm(user.loc)
			if("Air Alarm")
				new_board = new /obj/item/circuitboard/airalarm(user.loc)
		if(new_board)
			qdel(src)
			to_chat(user, span_notice("You set the general circuit to act as [new_board]."))
			new_board.set_general()
			user.put_in_hands(new_board)


/obj/item/circuitboard/proc/set_general()
	is_general_board = TRUE
	name = "[initial(name)] (General)"
	desc = "[initial(desc)] This appears to be a modular general circuit that can switch between pre-programmed modes with a multitool."

//Called when the circuitboard is used to contruct a new machine.
/obj/item/circuitboard/proc/construct(obj/machinery/M)
	if (istype(M, build_path))
		return 1
	return 0


//Called when a computer is deconstructed to produce a circuitboard.
//Only used by computers, as other machines store their circuitboard instance.
/obj/item/circuitboard/proc/decon(obj/machinery/M)
	if (istype(M, build_path))
		return 1
	return 0



/obj/item/circuitboard/aicore
	name = "Circuit board (AI Core)"


/obj/item/circuitboard/airalarm
	name = "air alarm electronics"
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."



/obj/item/circuitboard/firealarm
	name = "fire alarm electronics"
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""


/obj/item/circuitboard/apc
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."


// Tracker Electronic
/obj/item/circuitboard/solar_tracker
	name = "tracker electronics"
	icon_state = "door_electronics"


/obj/item/circuitboard/airlock
	name = "airlock electronics"
	icon_state = "door_electronics"
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	var/list/conf_access = null
	var/one_access = 0 //if set to 1, door would receive req_one_access instead of req_access
	var/last_configurator = null
	var/locked = 1


/obj/item/circuitboard/airlock/interact(mob/user)
	. = ..()
	if(.)
		return

	var/t1
	if (last_configurator)
		t1 += "Operator: [last_configurator]<br>"

	if (locked)
		t1 += "<a href='?src=\ref[src];login=1'>Swipe ID</a><hr>"
	else
		t1 += "<a href='?src=\ref[src];logout=1'>Block</a><hr>"

		t1 += "Access requirement is set to "
		t1 += one_access ? "<a style='color: green' href='?src=\ref[src];one_access=1'>ONE</a><hr>" : "<a style='color: red' href='?src=\ref[src];one_access=1'>ALL</a><hr>"

		t1 += conf_access == null ? "<font color=red>All</font><br>" : "<a href='?src=\ref[src];access=all'>All</a><br>"

		t1 += "<br>"

		var/list/accesses = ALL_ACCESS
		for (var/acc in accesses)
			var/aname = get_access_desc(acc)

			if (!conf_access || !conf_access.len || !(acc in conf_access))
				t1 += "<a href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
			else if(one_access)
				t1 += "<a style='color: green' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"
			else
				t1 += "<a style='color: red' href='?src=\ref[src];access=[acc]'>[aname]</a><br>"

	var/datum/browser/popup = new(user, "airlock_electronics", "<div align='center'>Access Control</div>")
	popup.set_content(t1)
	popup.open()


/obj/item/circuitboard/airlock/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["login"])
		if(istype(usr, /mob/living/silicon))
			locked = 0
			last_configurator = usr.name
		else
			var/obj/item/I = usr.get_active_held_item()
			if(I && check_access(I))
				locked = FALSE
				last_configurator = I:registered_name

	if(locked)
		return

	if(href_list["logout"])
		locked = TRUE

	if(href_list["one_access"])
		one_access = !one_access

	if(href_list["access"])
		toggle_access(href_list["access"])

	updateUsrDialog()


/obj/item/circuitboard/airlock/proc/toggle_access(acc)
	if (acc == "all")
		conf_access = null
	else
		var/req = text2num(acc)

		if (conf_access == null)
			conf_access = list()

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if (!conf_access.len)
				conf_access = null


/obj/item/circuitboard/airlock/secure
	name = "secure airlock electronics"
	desc = "designed to be somewhat more resistant to hacking than standard electronics."


/obj/item/circuitboard/general
	name = "general circuit board"
	desc = "A reconfigurable general circuitboard that can switch between multiple pre-programmed modes by way of a multitool."
	is_general_board = TRUE
