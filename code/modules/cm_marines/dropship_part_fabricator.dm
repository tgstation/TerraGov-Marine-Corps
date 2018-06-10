


/obj/machinery/dropship_part_fabricator
	name = "dropship part fabricator"
	desc = "A large automated 3D printer for producing new dropship parts."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/dropship_points = 0 //gains roughly 18 points per minute
	var/busy

/obj/machinery/dropship_part_fabricator/New()
	..()
	start_processing()

/obj/machinery/dropship_part_fabricator/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/dropship_part_fabricator/process()
	if(ticker.current_state < GAME_STATE_PLAYING)
		return
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"
		return
	if(busy)
		icon_state = "drone_fab_active"
		return
	else
		icon_state = "drone_fab_idle"
	dropship_points++


/obj/machinery/dropship_part_fabricator/attack_hand(mob/user)
	if(..())
		return
	user.set_interaction(src)
	var/dat = "<center><h2>Dropship Part Fabricator</h2></center><hr/>"
	dat += "<h4>Points Available: [dropship_points]</h4>"
	dat += "<h3>Dropship Equipment:</h3>"
	for(var/build_type in typesof(/obj/structure/dropship_equipment))
		var/obj/structure/dropship_equipment/DE = build_type
		var/build_name = initial(DE.name)
		var/build_cost = initial(DE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Dropship Ammo:</h3>"
	for(var/build_type in typesof(/obj/structure/ship_ammo))
		var/obj/structure/ship_ammo/SA = build_type
		var/build_name = initial(SA.name)
		var/build_cost = initial(SA.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"


	user << browse(dat, "window=dropship_part_fab")
	onclose(user, "dropship_part_fab")
	return

/obj/machinery/dropship_part_fabricator/proc/build_dropship_part(part_type, cost, mob/user)
	set waitfor = 0
	if(stat & NOPOWER) return
	if(dropship_points < cost)
		user << "<span class='warning'>You don't have enough points to build that.</span>"
		return
	visible_message("<span class='notice'>[src] starts printing something.</span>")
	dropship_points -= cost
	icon_state = "drone_fab_active"
	busy = TRUE
	sleep(100)
	busy = FALSE
	var/turf/T = locate(x+1,y-1,z)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)
	icon_state = "drone_fab_idle"

/obj/machinery/dropship_part_fabricator/Topic(href, href_list)
	if(..())
		return

	usr.set_interaction(src)
	add_fingerprint(usr)

	if(busy)
		usr << "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>"
		return

	if(href_list["produce"])
		build_dropship_part(href_list["produce"], text2num(href_list["cost"]), usr)
		return
