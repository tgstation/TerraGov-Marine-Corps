#define TANKFAB_MAIN_MENU 0
#define TANKFAB_MOD_MAINT 1
#define TANKFAB_PRINTER 2
#define TANKFAB_BUSY 3


/obj/machinery/tank_part_fabricator
	name = "tank part fabricator"
	desc = "A large automated 3D printer for producing new tank parts and maintaining old ones."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/obj/item/loaded_mod
	var/tank_points = 625
	var/busy = FALSE
	var/screen = TANKFAB_MAIN_MENU

/obj/machinery/tank_part_fabricator/proc/set_busy(business = TRUE, timer)
	busy = business
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(set_busy), !business), timer)
	update_icon()
	updateUsrDialog()

/obj/machinery/tank_part_fabricator/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "drone_fab_nopower"
		return
	if(busy)
		icon_state = "drone_fab_active"
		return
	else
		icon_state = "drone_fab_idle"

/obj/machinery/tank_part_fabricator/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat
	if(screen == TANKFAB_BUSY)
		dat += "<i>[src] is busy. Please wait for completion of the current operation...</i>"
	else
		dat += "<h4>Points Available: [tank_points]</h4>"
		var/slot = loaded_mod ? "[icon2html(loaded_mod, usr)] <a href='byond://?src=[text_ref(src)];eject=1'>[loaded_mod]</a>" : "None"
		dat += "<h4>Loaded Hardpoint/Ammo Clip: [slot]</h4>"

		var/screen_menu = screen != TANKFAB_MAIN_MENU ? "<a href='byond://?src=[text_ref(src)];screen=[TANKFAB_MAIN_MENU]'>Main Menu</a>" : "Main Menu"
		var/screen_maint = screen != TANKFAB_MOD_MAINT ? "<a href='byond://?src=[text_ref(src)];screen=[TANKFAB_MOD_MAINT]'>Hardpoint Maintenance</a>" : "Hardpoint Maintenance"
		var/screen_fab = screen != TANKFAB_PRINTER ? "<a href='byond://?src=[text_ref(src)];screen=[TANKFAB_PRINTER]'>Hardpoint Printer</a>" : "Hardpoint Printer"
		dat += "<center><table><tr><td><center>[screen_fab]</center><td><td><center>[screen_menu]</center><td><td><center>[screen_maint]</center><td><tr><table></center>"


	switch(screen)

		if(TANKFAB_MOD_MAINT)
			if(!loaded_mod)
				dat += "<i>No hardpoint or clip loaded. Please stand-by...</i>"
			else
				var/price = calculate_mod_value(loaded_mod)
				var/restore = istype(loaded_mod, /obj/item/hardpoint) ? "Repair" : "Refill"
				var/cost = calculate_repair_price(loaded_mod)
				dat += "<center><table><tr><td><center><a href='byond://?src=[text_ref(src)];restore=1'><b>[restore]</b> ([cost])</a></center><td><td><center><a href='byond://?src=[text_ref(src)];refund=1'><b>Refund</b> ([price])</a></center><td><tr><table></center><br>"
				dat += "<h4>Hardpoint/Ammo Clip infos:</h4>"
				dat += "<b>Brief description</b>: [loaded_mod.desc]<br>"
				if(istype(loaded_mod, /obj/item/hardpoint))
					var/obj/item/hardpoint/H = loaded_mod
					dat += "<b>Hardpoint integrity</b>: [PERCENT(H.obj_integrity/H.max_integrity)]%<br>"
					if(H.starter_ammo)
						var/ammo_count = H.ammo ? "[H.ammo] ([H.ammo.current_rounds]/[H.ammo.max_rounds])" : "No clip loaded"
						dat += "<b>Current clip</b>: [ammo_count]<br>"
					if(H.max_clips)
						dat += "<b>Backup clips</b>:<br>"
						for(var/I in H.backup_clips)
							var/obj/item/ammo_magazine/tank/A = I
							dat += "[A] ([A.current_rounds]/[A.max_rounds])<br>"
				else if(istype(loaded_mod, /obj/item/ammo_magazine))
					var/obj/item/ammo_magazine/A = loaded_mod
					dat += "<b>Current rounds</b>: [A] [A.current_rounds]/[A.max_rounds]<br>"
					dat += "<b>Caliber</b>: [A.caliber]<br>"
					//var/obj/item/hardpoint/H = A.gun_type //Ima break this.
					//dat += "<b>Supported Hardpoint</b>: [initial(H.name)]<br>"

		if(TANKFAB_PRINTER)
			dat += "<h3>Armor:</h3>"
			for(var/build_type in subtypesof(/obj/item/hardpoint/armor))
				var/obj/item/hardpoint/armor/AR = build_type
				if(!initial(AR.buyable))
					continue
				var/build_name = initial(AR.name)
				var/build_cost = initial(AR.point_cost)
				dat += "<a href='byond://?src=[text_ref(src)];produce=[build_type]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Primary Weapon:</h3>"
			for(var/build_type in subtypesof(/obj/item/hardpoint/primary))
				var/obj/item/hardpoint/primary/PR = build_type
				if(!initial(PR.buyable))
					continue
				var/build_name = initial(PR.name)
				var/build_cost = initial(PR.point_cost)
				dat += "<a href='byond://?src=[text_ref(src)];produce=[build_type]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Secondary Weapon:</h3>"
			for(var/build_type in subtypesof(/obj/item/hardpoint/secondary))
				var/obj/item/hardpoint/secondary/SE = build_type
				if(!initial(SE.buyable))
					continue
				var/build_name = initial(SE.name)
				var/build_cost = initial(SE.point_cost)
				dat += "<a href='byond://?src=[text_ref(src)];produce=[build_type]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Support Module:</h3>"
			for(var/build_type in subtypesof(/obj/item/hardpoint/support))
				var/obj/item/hardpoint/support/SP = build_type
				if(!initial(SP.buyable))
					continue
				var/build_name = initial(SP.name)
				var/build_cost = initial(SP.point_cost)
				dat += "<a href='byond://?src=[text_ref(src)];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Treads:</h3>"
			for(var/build_type in subtypesof(/obj/item/hardpoint/treads))
				var/obj/item/hardpoint/treads/TR = build_type
				if(!initial(TR.buyable))
					continue
				var/build_name = initial(TR.name)
				var/build_cost = initial(TR.point_cost)
				dat += "<a href='byond://?src=[text_ref(src)];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

			dat += "<h3>Weapon Ammo:</h3>"
			for(var/build_type in subtypesof(/obj/item/ammo_magazine/tank))
				var/obj/item/ammo_magazine/tank/AM = build_type
				var/build_name = initial(AM.name)
				var/build_cost = initial(AM.point_cost)
				dat += "<a href='byond://?src=[text_ref(src)];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	var/datum/browser/popup = new(user, "dropship_part_fab", "<div align='center'>Tank Part Fabricator</div>")
	popup.set_content(dat)
	popup.open(TRUE)


/obj/machinery/tank_part_fabricator/attackby(obj/item/W, mob/user)
	if((istype(W, /obj/item/hardpoint) || istype(W, /obj/item/ammo_magazine/tank)) && user.a_intent != INTENT_HARM)
		if(machine_stat & (NOPOWER|BROKEN))
			return
		if(busy)
			to_chat(usr, span_warning("[src] is busy. Please wait for completion of previous operation."))
		else if(user.transferItemToLoc(W, src))
			user.visible_message(span_notice("[user] loads [W] into [src]'s maintenance slot."), span_notice("You load [W] into [src]'s maintenance slot."), null, 4)
			loaded_mod = W
		else
			to_chat(user, span_warning("[W] appears to be stuck to your hands."))
	else if(iscrowbar(W) && machine_stat & (NOPOWER|BROKEN) && !QDELETED(loaded_mod))
		user.visible_message(span_warning("[user] starts to pry [src]'s maintenance slot open."), span_notice("You start to pry [loaded_mod] out of [src]'s maintenance slot..."))
		if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_GENERIC) || QDELETED(loaded_mod))
			return
		user.visible_message("[user] pries [loaded_mod] out of [src].", span_notice("You retrieve [loaded_mod] from [src]."))
		eject_tank_part()
	else
		return ..()

/obj/machinery/tank_part_fabricator/proc/build_tank_part(part_type, cost, mob/user)
	if(machine_stat & (NOPOWER|BROKEN) || busy)
		return
	if(tank_points < cost)
		to_chat(user, span_warning("You don't have enough points to build that."))
		return
	visible_message(span_notice("[src] starts printing something."))
	tank_points -= cost
	set_busy()
	addtimer(CALLBACK(src, PROC_REF(dispense_tank_part), part_type), 10 SECONDS)

/obj/machinery/tank_part_fabricator/proc/dispense_tank_part(part_type)
	set_busy(FALSE)
	var/turf/T = get_step(src, SOUTHEAST)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)

/obj/machinery/tank_part_fabricator/proc/calculate_mod_value()
	if(istype(loaded_mod, /obj/item/hardpoint))
		var/obj/item/hardpoint/mod = loaded_mod
		. = (mod.point_cost - mod.point_cost * (1 - (mod.obj_integrity/mod.max_integrity)) * 0.5) * 0.5
		if(mod.starter_ammo)
			if(mod.ammo)
				. += (mod.ammo.point_cost - mod.ammo.point_cost * (1 - (mod.ammo.current_rounds/mod.ammo.max_rounds)) * 0.5) * 0.5
			else
				. -= initial(mod.starter_ammo.point_cost) * 0.5
			for(var/O in mod.backup_clips)
				var/obj/item/ammo_magazine/tank/A = O
				. = (A.point_cost - A.point_cost * (1 - (A.current_rounds/A.max_rounds)) * 0.5) * 0.5
	else if(istype(loaded_mod, /obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/A = loaded_mod
		. = (A.point_cost - A.point_cost * (1 - (A.current_rounds/A.max_rounds)) * 0.5) * 0.5
	. = max(round(.), 0)

/obj/machinery/tank_part_fabricator/proc/calculate_repair_price()
	if(istype(loaded_mod, /obj/item/hardpoint))
		var/obj/item/hardpoint/mod = loaded_mod
		. = ((mod.point_cost - mod.point_cost * (mod.obj_integrity/mod.max_integrity)) * 0.1)
		if(mod.starter_ammo)
			if(mod.ammo)
				. += ((mod.ammo.point_cost - mod.ammo.point_cost * (mod.ammo.current_rounds/mod.ammo.max_rounds)) * 0.9)
			else
				. += initial(mod.starter_ammo.point_cost) * 0.9
	else if(istype(loaded_mod, /obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/A = loaded_mod
		. = ((A.point_cost - A.point_cost * (A.current_rounds/A.max_rounds)) * 0.9)

	. = max(round(.), 0)

/obj/machinery/tank_part_fabricator/proc/eject_tank_part(mob/user)
	if(busy || QDELETED(loaded_mod))
		return
	var/turf/T = get_step(src, SOUTHEAST)
	if(user)
		to_chat(user, span_notice("You retrieve [loaded_mod] from [src]."))
	loaded_mod.forceMove(T)
	loaded_mod = null

/obj/machinery/tank_part_fabricator/proc/refund_tank_part()
	if(machine_stat & (NOPOWER|BROKEN) || busy || QDELETED(loaded_mod))
		return
	tank_points += calculate_mod_value()
	visible_message(span_notice("[src] starts disassembling [loaded_mod]."))
	QDEL_NULL(loaded_mod)
	set_busy(TRUE, 10 SECONDS)

/obj/machinery/tank_part_fabricator/proc/restore_tank_part(mob/user)
	if(machine_stat & (NOPOWER|BROKEN) || busy || QDELETED(loaded_mod))
		return
	var/cost = calculate_repair_price()
	if(tank_points < cost)
		to_chat(user, span_warning("You don't have enough points to repair that."))
	tank_points -= cost
	if(istype(loaded_mod, /obj/item/hardpoint))
		var/obj/item/hardpoint/H = loaded_mod
		H.repair_damage(H.max_integrity)
		if(H.ammo)
			H.ammo.current_rounds = H.ammo.max_rounds
			H.ammo.update_icon()
		else if(H.starter_ammo)
			H.ammo = new H.starter_ammo
	else if(istype(loaded_mod, /obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/A = loaded_mod
		A.current_rounds = A.max_rounds
	set_busy(TRUE, 6 SECONDS)

/obj/machinery/tank_part_fabricator/Topic(href, href_list)
	. =..()
	if(.)
		return

	if(busy)
		to_chat(usr, span_warning("[src] is busy. Please wait for completion of previous operation."))
		return

	if(href_list["produce"])
		var/produce = text2path(href_list["produce"])
		var/cost
		if(ispath(produce, /obj/item/hardpoint))
			var/obj/item/hardpoint/H = produce
			cost = initial(H.point_cost)
		else if(ispath(produce, /obj/item/ammo_magazine/tank))
			var/obj/item/ammo_magazine/tank/A = produce
			cost = initial(A.point_cost)
		if(isnull(cost))
			updateUsrDialog()
			return
		build_tank_part(produce, cost, usr)

	if(href_list["eject"])
		eject_tank_part(usr)

	if(href_list["refund"])
		refund_tank_part()

	if(href_list["restore"])
		restore_tank_part(usr)

	if(href_list["screen"])
		screen = text2num(href_list["screen"])

	updateUsrDialog()

#undef TANKFAB_MAIN_MENU
#undef TANKFAB_MOD_MAINT
#undef TANKFAB_PRINTER
#undef TANKFAB_BUSY
