#define TANKFAB_MAIN_MENU	0
#define TANKFAB_MOD_MAINT	1
#define TANKFAB_PRINTER		2
#define TANKFAB_BUSY		3

/obj/machinery/tank_part_fabricator
	name = "tank part fabricator"
	desc = "A large automated 3D printer for producing new tank parts."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/obj/item/loaded_mod
	var/tank_points = 625
	var/busy = FALSE
	var/screen = TANKFAB_MAIN_MENU

/obj/machinery/tank_part_fabricator/power_change()
	. = ..()
	update_icon()

/obj/machinery/tank_part_fabricator/proc/set_busy(business = TRUE)
	busy = business
	update_icon()

/obj/machinery/tank_part_fabricator/update_icon()
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
	if(screen == TANKFAB_BUSY)
		dat += "<i>[src] is busy. Please wait for completion of the current operation...</i>"
	else
		dat += "<h4>Points Available: [tank_points]</h4>"
		dat += "<h4>Loaded Hardpoint/Magazine: [loaded_mod ? "(icon2html(loaded_mod, usr) <a href='byond://?src=\ref[src];eject'>(loaded_mod)</a>" : "None"]</h4>"

	switch(screen)

		if(TANKFAB_MAIN_MENU)
			dat += "<center><table><tr><td><center><a href='byond://?src=\ref[src];printer'>Hardpoint Printer</a></center><td><td><center><a href='byond://?src=\ref[src];module_maint'>Hardpoint Maintenance</a></center><td><tr><table></center>"

		if(TANKFAB_MOD_MAINT)
			if(!loaded_mod)
				dat += "<i>No hardpoint or magazine loaded. Please stand-by...</i>"
			else
				var/price = calculate_mod_value(loaded_mod)
				dat += "<center><table><tr><td><center><a href='byond://?src=\ref[src];printer'>Hardpoint Printer</a></center><td><td><center><a href='byond://?src=\ref[src];refund'>Refund([price])</a></center><td><tr><table></center>"

		if(TANKFAB_PRINTER)
			dat += "<h3>Armor:</h3>"
			for(var/build_type in typesof(/obj/item/hardpoint/armor))
				var/obj/item/hardpoint/armor/AR = build_type
				if(!initial(AR.buyable))
					continue
				var/build_name = initial(AR.name)
				var/build_cost = initial(AR.point_cost)
				if(build_cost)
					dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Primary Weapon:</h3>"
			for(var/build_type in typesof(/obj/item/hardpoint/primary))
				var/obj/item/hardpoint/primary/PR = build_type
				if(!initial(PR.buyable))
					continue
				var/build_name = initial(PR.name)
				var/build_cost = initial(PR.point_cost)
				if(build_cost)
					dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Secondary Weapon:</h3>"
			for(var/build_type in typesof(/obj/item/hardpoint/secondary))
				var/obj/item/hardpoint/secondary/SE = build_type
				if(!initial(SE.buyable))
					continue
				var/build_name = initial(SE.name)
				var/build_cost = initial(SE.point_cost)
				if(build_cost)
					dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Support Module:</h3>"
			for(var/build_type in typesof(/obj/item/hardpoint/support))
				var/obj/item/hardpoint/support/SP = build_type
				if(!initial(SP.buyable))
					continue
				var/build_name = initial(SP.name)
				var/build_cost = initial(SP.point_cost)
				if(build_cost)
					dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Treads:</h3>"
			for(var/build_type in typesof(/obj/item/hardpoint/treads))
				var/obj/item/hardpoint/treads/TR = build_type
				if(!initial(TR.buyable))
					continue
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
	if(stat & (NOPOWER|BROKEN) || busy)
		return
	if(tank_points < cost)
		to_chat(user, "<span class='warning'>You don't have enough points to build that.</span>")
		return
	visible_message("<span class='notice'>[src] starts printing something.</span>")
	tank_points -= cost
	set_busy()
	addtimer(CALLBACK(src, .proc/dispense_tank_part, part_type), 100)

/obj/machinery/tank_part_fabricator/proc/dispense_tank_part(part_type)
	set_busy(FALSE)
	var/turf/T = get_step(src, SOUTHEAST)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)

/obj/machinery/tank_part_fabricator/proc/calculate_mod_value(obj/item/I)
	if(istype(I, /obj/item/hardpoint))
		var/obj/item/hardpoint/mod = I
		. = CLAMP(mod.point_cost * PERCENT(mod.health/mod.maxhealth), mod.point_cost * 0.3, mod.point_cost * 0.75)
		if(mod.starter_ammo)
			if(mod.ammo)
				. = max(. * PERCENT(mod.ammo.current_rounds/mod.ammo.max_rounds), . * 0.5)
			else
				. *= 0.5
			for(var/O in mod.backup_clips)
				var/obj/item/ammo_magazine/tank/A = O
				. += CLAMP(A.point_cost * PERCENT(A.current_rounds/A.max_rounds), A * 0.1, A * 0.75)
	else if(istype(I, /obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/A = I
		. = CLAMP(A.point_cost * PERCENT(A.current_rounds/A.max_rounds), A * 0.1, A * 0.75)

	. = max(round(.), 0)

/obj/machinery/tank_part_fabricator/proc/refund_tank_part()
	if(stat & (NOPOWER|BROKEN) || busy || !loaded_mod)
		return
	tank_points += calculate_mod_value(loaded_mod)
	visible_message("<span class='notice'>[src] starts disassembling [loaded_mod].</span>")
	QDEL_NULL(loaded_mod)
	set_busy()
	addtimer(CALLBACK(src, .proc/set_busy, FALSE), 100)

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

	if(href_list["refund"])
		refund_tank_part()

	if(href_list["printer"])
		screen = TANKFAB_PRINTER

	if(href_list["module_maint"])
		screen = TANKFAB_MOD_MAINT

		updateUsrDialog()