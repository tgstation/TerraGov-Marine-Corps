


/obj/machinery/dropship_part_fabricator
	name = "dropship part fabricator"
	desc = "A large automated 3D printer for producing new dropship parts."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	/// List of everything in queue
	var/list/queue = list()
	/// Whether the fabricator is currently printing something or not
	var/busy = FALSE

/obj/machinery/dropship_part_fabricator/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "drone_fab_nopower"
		return
	if(busy)
		icon_state = "drone_fab_active"
		return
	else
		icon_state = "drone_fab_idle"

/obj/machinery/dropship_part_fabricator/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat
	dat += "<h4>Points Available: [SSpoints.dropship_points]</h4>"
	dat += "<a href='byond://?src=\ref[src];choice=clear'>CLEAR PRINT QUEUE</a><br>"

	dat += "<h3>Dropship Equipment:</h3>"
	for(var/build_type in typesof(/obj/structure/dropship_equipment))
		var/obj/structure/dropship_equipment/DE = build_type
		var/build_name = initial(DE.name)
		var/build_cost = initial(DE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];choice=[build_type]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Dropship Ammo:</h3>"
	for(var/build_type in typesof(/obj/structure/ship_ammo))
		var/obj/structure/ship_ammo/SA = build_type
		var/build_name = initial(SA.name)
		var/build_cost = initial(SA.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];choice=[build_type]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Current Print Queue:</h3>"
	for(var/item_to_print in queue)
		var/obj/structure/toprint = item_to_print
		dat += ("- " + initial(toprint.name) + "<br>")

	var/datum/browser/popup = new(user, "dropship_part_fab", "<div align='center'>Dropship Part Fabricator</div>")
	popup.set_content(dat)
	popup.open()


/// Starts the printing process, does point calculations
/obj/machinery/dropship_part_fabricator/proc/build_dropship_part(part_type)
	var/cost = get_cost(part_type)

	if((machine_stat & NOPOWER) || !cost)
		next_queue()
		return

	if(SSpoints.dropship_points < cost) //We'll check for points again here in case queue has taken too many points
		balloon_alert_to_viewers("Not enough points")
		next_queue()
		return

	balloon_alert_to_viewers("Printing...")
	SSpoints.dropship_points -= cost
	busy = TRUE
	update_icon()

	addtimer(CALLBACK(src, .proc/do_build_dropship_part, part_type), 10 SECONDS)

/// Gets the cost of the product we want to make
/obj/machinery/dropship_part_fabricator/proc/get_cost(build_type)
	if(build_type in typesof(/obj/structure/dropship_equipment))
		var/obj/structure/dropship_equipment/DE = build_type
		return initial(DE.point_cost)

	if(build_type in typesof(/obj/structure/ship_ammo))
		var/obj/structure/dropship_equipment/SA = build_type
		return initial(SA.point_cost)

	//If it's not equipment or ammo, it might be something fucky..
	log_admin_private("[key_name(usr)] may have attempted a href exploit on a dropship printer [AREACOORD(usr)].")
	message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href exploit on a dropship printer [ADMIN_VERBOSEJMP(usr)].")
	return FALSE

/// Finishes up printing, checks for next in queue, prints the actual part
/obj/machinery/dropship_part_fabricator/proc/do_build_dropship_part(part_type)
	var/turf/T = get_step(src, SOUTHEAST)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)

	next_queue()

/// Processes next item in queue, if queue has not finished already
/obj/machinery/dropship_part_fabricator/proc/next_queue()
	if(queue.len > 0) //Cont n inue queue
		var/part_to_build = queue[1]
		queue.Remove(part_to_build)
		build_dropship_part(part_to_build)
		return TRUE

	//There's nothing left, finish up queue
	balloon_alert_to_viewers("Printing complete!")
	playsound(src,'sound/machines/ping.ogg', 40, FALSE)
	busy = FALSE
	update_icon()

/obj/machinery/dropship_part_fabricator/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["choice"])
		if(href_list["choice"] == "clear")
			queue = list()
			balloon_alert_to_viewers("Entire queue cleared")
			return

		var/build_type = text2path(href_list["choice"])
		if(!build_type)
			return

		if(SSpoints.dropship_points < get_cost(build_type))
			balloon_alert_to_viewers("Not enough points")
			return

		if(busy)
			balloon_alert_to_viewers("Part added to queue")
			queue.Add(build_type)
			return

		build_dropship_part(build_type)
		return

/obj/machinery/dropship_part_fabricator/attackby(obj/item/H, mob/user, params)
	. = ..()
	if(!istype(H, /obj/item/dropship_points_voucher))
		return
	var/obj/item/dropship_points_voucher/voucher = H
	to_chat(user, span_notice("You add [voucher.extra_points] dropship points to \the [src]."))
	SSpoints.dropship_points += voucher.extra_points
	qdel(H)
