/obj/machinery/tank_part_fabricator
	name = "tank part fabricator"
	desc = "A large automated 3D printer for producing new tank parts."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/tank_points = 625
	var/busy

/obj/machinery/tank_part_fabricator/New()
	..()
	start_processing()

/obj/machinery/tank_part_fabricator/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/tank_part_fabricator/process()
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

/obj/machinery/tank_part_fabricator/attack_hand(mob/user)
	if(..())
		return
	user.set_interaction(src)
	var/dat = "<center><h2>Tank Part Fabricator</h2></center><hr/>"
	dat += "<h4>Points Available: [tank_points]</h4>"
	dat += "<h3>Armor:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/armor))
		var/obj/item/hardpoint/armor/AR = build_type
		var/build_name = initial(AR.name)
		var/build_cost = initial(AR.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Primary Weapon:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/primary))
		var/obj/item/hardpoint/primary/PR = build_type
		var/build_name = initial(PR.name)
		var/build_cost = initial(PR.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Secondary Weapon:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/secondary))
		var/obj/item/hardpoint/secondary/SE = build_type
		var/build_name = initial(SE.name)
		var/build_cost = initial(SE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Support Module:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/support))
		var/obj/item/hardpoint/support/SP = build_type
		var/build_name = initial(SP.name)
		var/build_cost = initial(SP.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Treads:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/treads))
		var/obj/item/hardpoint/treads/TR = build_type
		var/build_name = initial(TR.name)
		var/build_cost = initial(TR.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Weapon Ammo:</h3>"
	for(var/build_type in typesof(/obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/AM = build_type
		var/build_name = initial(AM.name)
		var/build_cost = initial(AM.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"


	user << browse(dat, "window=dropship_part_fab")
	onclose(user, "dropship_part_fab")
	return

/obj/machinery/tank_part_fabricator/proc/build_tank_part(part_type, cost, mob/user)
	set waitfor = 0
	if(stat & NOPOWER) return
	if(tank_points < cost)
		to_chat(user, "<span class='warning'>You don't have enough points to build that.</span>")
		return
	visible_message("<span class='notice'>[src] starts printing something.</span>")
	tank_points -= cost
	icon_state = "drone_fab_active"
	busy = TRUE
	sleep(100)
	busy = FALSE
	var/turf/T = locate(x+1,y-1,z)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)
	icon_state = "drone_fab_idle"

/obj/machinery/tank_part_fabricator/Topic(href, href_list)
	if(..())
		return

	usr.set_interaction(src)
	add_fingerprint(usr)

	if(busy)
		to_chat(usr, "<span class='warning'>[src] is busy. Please wait for completion of previous operation.</span>")
		return

	if(href_list["produce"])
		build_tank_part(href_list["produce"], text2num(href_list["cost"]), usr)
		return