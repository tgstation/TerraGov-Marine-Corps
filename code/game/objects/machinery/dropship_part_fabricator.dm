


/obj/machinery/dropship_part_fabricator
	name = "dropship part fabricator"
	desc = "A large automated 3D printer for producing new dropship parts."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
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
	dat += "<h3>Dropship Equipment:</h3>"
	for(var/build_type in typesof(/obj/structure/dropship_equipment))
		var/obj/structure/dropship_equipment/DE = build_type
		var/build_name = initial(DE.name)
		var/build_cost = initial(DE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Dropship Ammo:</h3>"
	for(var/build_type in typesof(/obj/structure/ship_ammo))
		var/obj/structure/ship_ammo/SA = build_type
		var/build_name = initial(SA.name)
		var/build_cost = initial(SA.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type]'>[build_name] ([build_cost])</a><br>"

	var/datum/browser/popup = new(user, "dropship_part_fab", "<div align='center'>Dropship Part Fabricator</div>")
	popup.set_content(dat)
	popup.open()

/obj/machinery/dropship_part_fabricator/proc/build_dropship_part(part_type, cost, mob/user)
	if(machine_stat & NOPOWER) return
	if(SSpoints.dropship_points < cost)
		to_chat(user, span_warning("You don't have enough points to build that."))
		return
	visible_message(span_notice("[src] starts printing something."))
	SSpoints.dropship_points -= cost
	update_icon()
	busy = TRUE
	addtimer(CALLBACK(src, .proc/do_build_dropship_part, part_type), 10 SECONDS)

/obj/machinery/dropship_part_fabricator/proc/do_build_dropship_part(part_type)
	busy = FALSE
	var/turf/T = get_step(src, SOUTHEAST)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)
	update_icon()

/obj/machinery/dropship_part_fabricator/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(busy)
		to_chat(usr, span_warning("The autolathe is busy. Please wait for completion of previous operation."))
		return

	if(href_list["produce"])
		var/produce = text2path(href_list["produce"])
		if(!produce)
			return
		var/build_type
		var/cost
		if(produce in typesof(/obj/structure/dropship_equipment))
			var/obj/structure/dropship_equipment/DE = produce
			cost = initial(DE.point_cost)
			build_type = produce
		else if(produce in typesof(/obj/structure/ship_ammo))
			var/obj/structure/dropship_equipment/SA = produce
			cost = initial(SA.point_cost)
			build_type = produce
		else
			log_admin_private("[key_name(usr)] may have attempted a href exploit on a dropship printer [AREACOORD(usr)].")
			message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href exploit on a dropship printer [ADMIN_VERBOSEJMP(usr)].")
			return

		build_dropship_part(build_type, cost, usr)
		return

/obj/machinery/dropship_part_fabricator/attackby(obj/item/H, mob/user, params)
	. = ..()
	if(!istype(H, /obj/item/dropship_points_voucher))
		return
	var/obj/item/dropship_points_voucher/voucher = H
	to_chat(user, span_notice("You add [voucher.extra_points] dropship points to \the [src]."))
	SSpoints.dropship_points += voucher.extra_points
	qdel(H)
