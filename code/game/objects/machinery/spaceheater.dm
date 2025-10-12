/obj/machinery/space_heater
	anchored = FALSE
	density = TRUE
	icon = 'icons/obj/machines/atmos.dmi'
	icon_state = "sheater"
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
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/space_heater/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)]_on"

/obj/machinery/space_heater/update_overlays()
	. = ..()
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
	balloon_alert_to_viewers("hatch [open ? "opened" : "closed"]")
	update_icon()

/obj/machinery/space_heater/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(on)
		balloon_alert(user, "turn it off first!")
		return
	if(!open)
		balloon_alert(user, "the hatch is closed!")
		return
	if(!cell)
		balloon_alert(user, "there isn't a cell to pry out!")
		return
	balloon_alert(user, "cell pried out")
	cell.forceMove(user.drop_location())
	cell = null

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(!istype(I, /obj/item/cell))
		return
	if(!open)
		balloon_alert(user, "open the hatch!")
		return

	if(cell)
		balloon_alert(user, "it already has a cell!")
		return

	var/obj/item/cell/user_cell = I
	if(!istype(user_cell))
		return

	if(!user.transferItemToLoc(user_cell, src))
		return

	cell = user_cell

	balloon_alert_to_viewers("cell inserted")

/obj/machinery/space_heater/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	on = !on
	if(on)
		start_processing()
	else
		stop_processing()

	balloon_alert_to_viewers("switched [on ? "on" : "off"]")
	update_icon()


/obj/machinery/space_heater/process()
	if(!on || !cell || !cell.charge)
		balloon_alert_to_viewers("shuts off")
		update_icon()
		stop_processing()
		return

	for(var/mob/living/carbon/human/H in range(2, src))
		H.adjust_bodytemperature(min(round(T20C - H.bodytemperature)*0.7, 25), 0, T20C)


	cell.use(50*GLOB.CELLRATE)

/obj/machinery/space_heater/radiator
	name = "radiator"
	desc = "It's a radiator. It heats the room through convection with hot water. This one has a red handle."
	icon_state = "radiator"
	density = FALSE

/obj/machinery/space_heater/radiator/red
	icon_state = "radiator-r"
