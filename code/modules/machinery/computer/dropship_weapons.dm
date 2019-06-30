
/obj/machinery/computer/dropship_weapons
	name = "abstract dropship weapons controls"
	desc = "A computer to manage equipments and weapons installed on the dropship."
	density = TRUE
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "consoleright"
	circuit = null
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/shuttle_tag  // Used to know which shuttle we're linked to.
	var/obj/structure/dropship_equipment/selected_equipment //the currently selected equipment installed on the shuttle this console controls.
	var/list/shuttle_equipments = list() //list of the equipments on the shuttle this console controls



/obj/machinery/computer/dropship_weapons/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1

	user.set_interaction(src)
	ui_interact(user)


/obj/machinery/computer/dropship_weapons/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/computer/dropship_weapons/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	// no more cas

/obj/machinery/computer/dropship_weapons/dropship1
	name = "\improper 'Alamo' weapons controls"
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/computer/dropship_weapons/dropship1/Initialize()
	. = ..()
	shuttle_tag = "[CONFIG_GET(string/ship_name)] Dropship 1"

/obj/machinery/computer/dropship_weapons/dropship2
	name = "\improper 'Normandy' weapons controls"
	req_access = list(ACCESS_MARINE_DROPSHIP)

/obj/machinery/computer/dropship_weapons/dropship2/Initialize()
	. = ..()
	shuttle_tag = "[CONFIG_GET(string/ship_name)] Dropship 2"
