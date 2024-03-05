/obj/machinery/space_heater
	anchored = FALSE
	density = TRUE
	icon = 'icons/obj/machines/atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	/// The cell inside the heater, used for making it work
	var/obj/item/cell/high/cell
	/// Is the heater on?
	var/on = FALSE
	/// Is the panel on the heater open?
	var/open = FALSE


/obj/machinery/space_heater/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/space_heater/update_icon_state()
	. = ..()
	icon_state = "sheater[on]"

/obj/machinery/space_heater/update_overlays()
	. = ..()
	cut_overlays()
	if(open)
		. += "sheater-open"

/obj/machinery/space_heater/examine(mob/user)
	. = ..()
	. += "The heater is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"]."
	if(open)
		. += "The power cell is [cell ? "installed" : "missing"]."
	else
		. += "The charge meter reads [cell ? round(cell.percent(),1) : 0]%"


/obj/machinery/space_heater/emp_act(severity)
	if(machine_stat & (BROKEN|NOPOWER))
		return ..()
	if(cell)
		cell.emp_act(severity)
	return ..()

/obj/machinery/space_heater/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	open = !open
	balloon_alert_to_viewers("[user] [open ? "opens" : "closes"] the hatch on the [src]")
	update_icon()

/obj/machinery/space_heater/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(on)
		balloon_alert(user, "Turn [src] off first")
		return
	if(!open)
		balloon_alert(user, "The hatch is closed")
		return
	if(!cell)
		balloon_alert(user, "There isn't a cell to pry out")
		return
	balloon_alert(user, "You pry the cell out")
	cell.forceMove(user.drop_location())
	cell = null

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I, /obj/item/cell))
		return
	if(!open)
		balloon_alert(user, "Open the hatch")
		return

	if(cell)
		balloon_alert(user, "[src] already has a cell.")
		return

	var/obj/item/cell/user_cell = I
	if(!istype(user_cell))
		return

	if(!user.transferItemToLoc(user_cell, src))
		return

	cell = user_cell

	balloon_alert_to_viewers("[user] inserts a cell into [src]")

/obj/machinery/space_heater/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	on = !on
	if(on)
		start_processing()
	else
		stop_processing()

	balloon_alert_to_viewers("[user] switches [src] [on ? "on" : "off"]")
	update_icon()


/obj/machinery/space_heater/process()
	if(!on || !cell || !cell.charge)
		balloon_alert_to_viewers("[src] shuts off")
		update_icon()
		stop_processing()
		return

	for(var/mob/living/carbon/human/H in range(2, src))
		H.adjust_bodytemperature(min(round(T20C - H.bodytemperature)*0.7, 25), 0, T20C)


	cell.use(50*GLOB.CELLRATE)
