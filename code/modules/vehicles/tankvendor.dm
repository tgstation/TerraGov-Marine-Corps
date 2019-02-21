//special TC's machinery for the Garage
/obj/machinery/vehicle_vendor
	name = "ColMarTech Automated Vehicle Vendor"
	desc = "Only TCs have access to these"
	icon = 'icons/obj/machines/vending.dmi'
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = 1
	idle_power_usage = 20
	var/return_timer = 12000

	var/list/vendor_role = list()

	var/list/listed_products


/obj/machinery/vehicle_vendor/tank_vendor_ui
	name = "ColMarTech Automated Vehicle Vendor"
	desc = "This vendor is connected to main ship storage, allows to fetch one hardpoint module per category for free."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "robotics"

	vendor_role = list("Tank Crewman") //everyone else, mind your business

	var/list/aval_tank_mod = list("manual", "primary", "secondary", "support", "armor", "treads")

	listed_products = list(
							list("GUIDE FOR DUMMIES", null, null, null, null),
							list("Guide For Dummies: How To Tank", null, /obj/item/book/manual/tank_manual, "manual", "gold"),
							list("TANK MODULES CATEGORIES:", null, null, null, null),
							list("PRIMARY WEAPON", null, null, null, null),
							list("M21 Autocannon", 1, /obj/item/hardpoint/tank/primary/autocannon, "primary", "orange"),
							list("M5 LTB Cannon", 2, /obj/item/hardpoint/tank/primary/cannon, "primary", "black"),
							list("M74 LTAA-AP Minigun", 3, /obj/item/hardpoint/tank/primary/minigun, "primary", "black"),
							list("SECONDARY WEAPON", null, null, null, null),
							list("M56 \"Cupola\"", 2, /obj/item/hardpoint/tank/secondary/m56cupola, "secondary", "orange"),
							list("M8-3 TOW Launcher", 2, /obj/item/hardpoint/tank/secondary/towlauncher, "secondary", "black"),
							list("M7 \"Dragon\" Flamethrower Unit", 2, /obj/item/hardpoint/tank/secondary/flamer, "secondary", "black"),
							list("M92 Grenade Launcher", 2, /obj/item/hardpoint/tank/secondary/grenade_launcher, "secondary", "black"),
							list("SUPPORT MODULE", null, null, null, null),
							list("M40 Integrated Weapons Sensor Array", 1, /obj/item/hardpoint/tank/support/weapons_sensor, "support", "black"),
							list("M6 Artillery Module", 1, /obj/item/hardpoint/tank/support/artillery_module, "support", "orange"),
							list("M103 Overdrive Enhancer", 1, /obj/item/hardpoint/tank/support/overdrive_enhancer, "support", "black"),
							list("ARMOR", null, null, null, null),
							list("M65-B Armor", 7, /obj/item/hardpoint/tank/armor/ballistic, "armor", "orange"),
							list("M70 \"Caustic\" Armor", 5, /obj/item/hardpoint/tank/armor/caustic, "armor", "black"),
							list("M66-LC Armor", 3, /obj/item/hardpoint/tank/armor/concussive, "armor", "black"),
							list("M90 \"Paladin\" Armor", 10, /obj/item/hardpoint/tank/armor/paladin, "armor", "black"),
							list("M37 \"Snowplow\" Armor", 4, /obj/item/hardpoint/tank/armor/snowplow, "armor", "black"),
							list("TREADS", null, null, null, null),
							list("M2 Tank Treads", 1, /obj/item/hardpoint/tank/treads/standard, "treads", "orange"),
							list("M2-R Tank Treads", 3, /obj/item/hardpoint/tank/treads/heavy, "treads", "black"),
							list("APC MODULES:", null, null, null, null),
							list("M78 Dual Cannon", null, /obj/item/hardpoint/apc/primary/dual_cannon, "primary", "orange"),
							list("M26 Frontal Cannon", null, /obj/item/hardpoint/apc/secondary/front_cannon, "secondary", "orange"),
							list("M9 Flare Launcher System", null, /obj/item/hardpoint/apc/support/flare_launcher, "support", "orange"),
							list("M3 APC Wheels Kit", null, /obj/item/hardpoint/apc/wheels, "treads", "orange"),
							)


/obj/machinery/vehicle_vendor/tank_vendor_ui/New()
	..()
	start_processing()

/obj/machinery/vehicle_vendor/tank_vendor_ui/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "robotics_off"

/obj/machinery/vehicle_vendor/tank_vendor_ui/process()
	if(ticker.current_state < GAME_STATE_PLAYING)
		return
	if(stat & NOPOWER)
		icon_state = "robotics_off"
		return
	icon_state = "robotics"

/obj/machinery/vehicle_vendor/tank_vendor_ui/attack_hand(mob/user)

	if(..())
		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	user.set_interaction(src)
	ui_interact(user)

/obj/machinery/vehicle_vendor/tank_vendor_ui/attackby(obj/item/W, mob/user)

//	if(..())
//		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	if(istype(W, /obj/item/book/manual/tank_manual))
		if(aval_tank_mod.Find("manual"))
			to_chat(H, "<span class='warning'>Can't accept this. Manual is still in the vendor... Wait a minute, where did you get that?!</span>")
			return
		aval_tank_mod.Add("manual")
		user.temp_drop_inv_item(W, 0)
		to_chat(user, "<span class='notice'>You insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	if(world.time > return_timer)
		to_chat(H, "<span class='warning'>Operation has begun, you can't swap modules anymore.</span>")
		return

	if(istype(W, /obj/item/hardpoint/tank/primary) || istype(W, /obj/item/hardpoint/apc/primary))
		if(aval_tank_mod.Find("primary"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Primary\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("primary")
		user.temp_drop_inv_item(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	if(istype(W, /obj/item/hardpoint/tank/secondary) || istype(W, /obj/item/hardpoint/apc/secondary))
		if(aval_tank_mod.Find("secondary"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Secondary\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("secondary")
		user.temp_drop_inv_item(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	if(istype(W, /obj/item/hardpoint/tank/support) || istype(W, /obj/item/hardpoint/apc/support))
		if(aval_tank_mod.Find("support"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Support\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("support")
		user.temp_drop_inv_item(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	if(istype(W, /obj/item/hardpoint/tank/armor))
		if(aval_tank_mod.Find("armor"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Armor\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("armor")
		user.temp_drop_inv_item(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	if(istype(W, /obj/item/hardpoint/tank/treads) || istype(W, /obj/item/hardpoint/apc/wheels))
		if(aval_tank_mod.Find("treads"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Treads\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("treads")
		user.temp_drop_inv_item(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	to_chat(user, "<span class='warning'>This is not a hardpoint module.</span>")
	return


/obj/machinery/vehicle_vendor/tank_vendor_ui/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	if(!ishuman(user)) return

	var/list/display_list = list()

	for(var/i in 1 to listed_products.len)
		var/list/myprod = listed_products[i]
		var/p_name = myprod[1]
		var/p_weight = myprod[2]
		if(p_weight > 0)
			p_name += " ([p_weight] RW)"

		var/prod_available = FALSE
		if(aval_tank_mod.Find(myprod[4]))
			prod_available = TRUE

								//place in main list, name with Relative Weight, available or not, color.
		display_list += list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[5]))


	var/list/data = list(
		"vendor_name" = name,
		"displayed_records" = display_list,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "tank_vendor.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/vehicle_vendor/tank_vendor_ui/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.is_mob_incapacitated())
		return

	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["vend"])

			var/idx=text2num(href_list["vend"])

			var/list/L = listed_products[idx]
			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(!vendor_role.Find(I.rank))
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return

			var/type_p = L[3]
			var/obj/item/IT = new type_p(loc)
			IT.add_fingerprint(usr)

			if(aval_tank_mod.Find(L[4]))
				aval_tank_mod -= L[4]
				H.update_action_buttons()
			else
				to_chat(H, "<span class='warning'>You already took something from this category.</span>")
				return

		src.add_fingerprint(usr)
		ui_interact(usr) //updates the nanoUI window

///////////////////////////////////////////////////////////////////////////////////
//APC vendor
/*
/obj/machinery/vehicle_vendor/apc_vendor_ui
	name = "ColMarTech Automated APC Vendor"
	desc = "This vendor is connected to main ship storage, allows to fetch one hardpoint module per category for free."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "engi"

	vendor_role = list("Tank Crewman") //everyone else, mind your business

	var/list/aval_tank_mod = list("manual", "primary", "secondary", "support", "wheels")

	listed_products = list(
							//list("GUIDE FOR DUMMIES", null, null, null),
							//list("Guide For Dummies: How To Tank", /obj/item/book/manual/tank_manual, "manual", "gold"),
							list("PRIMARY WEAPON", null, null, null),
							list("M78 Dual Cannon", /obj/item/hardpoint/apc/primary/dual_cannon, "primary", "orange"),
							list("SECONDARY WEAPON", null, null, null),
							list("M26 Frontal Cannon", /obj/item/hardpoint/apc/secondary/front_cannon, "secondary", "orange"),
							list("SUPPORT MODULE", null, null, null),
							list("M9 Flare Launcher System", /obj/item/hardpoint/apc/support/flare_launcher, "support", "orange"),
							list("WHEELS", null, null, null),
							list("M3 APC Wheels Kit", /obj/item/hardpoint/apc/wheels, "treads", "orange"),
							)


/obj/machinery/vehicle_vendor/apc_vendor_ui/New()
	..()
	start_processing()

/obj/machinery/vehicle_vendor/apc_vendor_ui/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "engi_off"

/obj/machinery/vehicle_vendor/apc_vendor_ui/process()
	if(ticker.current_state < GAME_STATE_PLAYING)
		return
	if(stat & NOPOWER)
		icon_state = "engi_off"
		return
	icon_state = "engi"

/obj/machinery/vehicle_vendor/apc_vendor_ui/attack_hand(mob/user)

	if(..())
		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	user.set_interaction(src)
	ui_interact(user)

/obj/machinery/vehicle_vendor/apc_vendor_ui/attackby(obj/item/W, mob/user)

//	if(..())
//		return

	if(stat & (BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	if(world.time > return_timer)
		to_chat(H, "<span class='warning'>Operation has begun, you can't swap modules anymore.</span>")
		return

	if(istype(W, /obj/item/hardpoint/apc/primary))
		if(aval_tank_mod.Find("primary"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Primary\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("primary")

	if(istype(W, /obj/item/hardpoint/apc/secondary))
		if(aval_tank_mod.Find("secondary"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Secondary\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("secondary")

	if(istype(W, /obj/item/hardpoint/apc/support))
		if(aval_tank_mod.Find("support"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Support\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("support")

	if(istype(W, /obj/item/hardpoint/apc/wheels))
		if(aval_tank_mod.Find("treads"))
			to_chat(H, "<span class='warning'>Can't accept this. Module from \"Wheels\" category wasn't taken yet.</span>")
			return
		aval_tank_mod.Add("wheels")

	user.temp_drop_inv_item(W, 0)
	cdel(W)
	to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
	return


/obj/machinery/vehicle_vendor/apc_vendor_ui/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	if(!ishuman(user)) return

	var/list/display_list = list()

	for(var/i in 1 to listed_products.len)
		var/list/myprod = listed_products[i]
		var/p_name = myprod[1]

		var/prod_available = FALSE
		if(aval_tank_mod.Find(myprod[3]))
			prod_available = TRUE

								//place in main list, name with Relative Weight, available or not, color.
		display_list += list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[4]))


	var/list/data = list(
		"vendor_name" = name,
		"displayed_records" = display_list,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "apc_vendor.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/machinery/vehicle_vendor/apc_vendor_ui/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.is_mob_incapacitated())
		return

	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["vend"])

			var/idx=text2num(href_list["vend"])

			var/list/L = listed_products[idx]
			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(!vendor_role.Find(I.rank))
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return

			var/type_p = L[3]
			var/obj/item/IT = new type_p(loc)
			IT.add_fingerprint(usr)

			if(aval_tank_mod.Find(L[4]))
				aval_tank_mod -= L[4]
				H.update_action_buttons()
			else
				to_chat(H, "<span class='warning'>You already took something from this category.</span>")
				return

		src.add_fingerprint(usr)
		ui_interact(usr) //updates the nanoUI window
*/
///////////////////////////////////////////////////////////////////////////////////
//repair station, based on old Barsik's module printer
/obj/machinery/vehicle_vendor/module_repair_station
	name = "ColMarTech Automated Module Repair Station"
	desc = "A big piece of machinery capable of repairing vehicle modules. One at a time."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	vendor_role = list ("Tank Crewman", "Synthetic", "Maintenance Technician")	//Having MTs and Synthetic to have access to repair machinery seems logical thing.
	var/busy
	var/obj/item/hardpoint/HP = null

/obj/machinery/vehicle_vendor/module_repair_station/New()
	..()
	start_processing()

/obj/machinery/vehicle_vendor/module_repair_station/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"

/obj/machinery/vehicle_vendor/module_repair_station/process()
	if(ticker.current_state < GAME_STATE_PLAYING)
		return
	if(stat & NOPOWER)
		icon_state = "drone_fab_nopower"
		if(busy)
			playsound(src, pick('sound/machines/hydraulics_1.ogg', 'sound/machines/hydraulics_2.ogg'), 40, 1)
			sleep(10)
			var/turf/T = locate(x+1,y,z)
			HP.Move(T)
			HP = null
			busy = FALSE
		return
	if(busy)
		icon_state = "drone_fab_active"
		return
	else
		icon_state = "drone_fab_idle"

/obj/machinery/vehicle_vendor/module_repair_station/attack_hand(mob/user)
	if(..())
		return
	user.set_interaction(src)
	var/dat = "<center><h2>ColMarTech Automated Module Repair Station</h2></center><hr/>"
	if(HP == null)
		dat += "<h4>No module detected. Please, put module into receiver.</h4>"
	else
		var/health_per
		var/health = HP.health
		if(HP.health < 0)
			health = 0
		health_per = round(health * 100 / HP.maxhealth)//calculate health in %

		dat += "<h3>Module inserted:</h3>"
		dat += "<h4>[HP.name]</h4>"
		dat += "<h4>Integrity: [health_per]%</h4>"
		dat += "<a href='byond://?src=\ref[src];repair=[health_per]'>Start module repair</a><br>"
		dat += "<a href='byond://?src=\ref[src];eject=[health_per]'>Eject module</a><br>"

	user << browse(dat, "window=module_repair_station")
	onclose(user, "module_repair_station")
	return

/obj/machinery/vehicle_vendor/module_repair_station/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/hardpoint))
		if(HP == null)
			src.HP = O
			O.Move(src)
			user.temp_drop_inv_item(O, 0)
			to_chat(user, "<span class='notice'>With a click you insert the [src.HP.name] into the machine's receiver.</span>")
		else
			to_chat(user, "<span class='warning'>Machine's receiver is closed, perhaps there is already module inserted.</span>")


/obj/machinery/vehicle_vendor/module_repair_station/proc/repair_module(health_per, mob/user)
	set waitfor = 0
	if(stat & NOPOWER) return
	if(health_per == 100)
		to_chat(user, "<span class='warning'>Module doesn't require repair.</span>")
		return
	var/turf/T = locate(x+1,y,z)
	visible_message("<span class='notice'>[src] starts clanking and humming as it begins repairing process.</span>")
	icon_state = "drone_fab_active"
	busy = TRUE
	var/timer = (100 - health_per) * 30	//here we check the amount of missing hp in % and then multiply by 30, so competely broken module requires 5min (300s) to fix
	var/adjustment = rand(0, 600)		//here we adjust that number by random amount of deciseconds. Adjustment will be from 0 to 1 min.
	timer += adjustment
	to_chat(user, "<span class='notice'>On [src] screen you see that estimated time till module is repaired: [timer / 10] seconds.</span>")

	for(var/i=0;i<5;i++)
		sleep(timer/5)
		HP.health += round((100 - health_per)/5)
	HP.health = HP.maxhealth
	busy = FALSE
	playsound(src, pick('sound/machines/hydraulics_1.ogg', 'sound/machines/hydraulics_2.ogg'), 40, 1)
	sleep(10)
	playsound(src, 'sound/machines/twobeep.ogg', 40, 1)
	visible_message("<span class='notice'>[src] states: \"Repair complete\" and ejects module.</span>")
	HP.Move(T)
	HP = null
	icon_state = "drone_fab_idle"

/obj/machinery/vehicle_vendor/module_repair_station/proc/eject_module(mob/user)
	if(HP == null)
		to_chat(user, "<span class='warning'>You can't eject module, nothing in there!</span>")
		return
	else
		var/turf/T = locate(x+1,y,z)
		visible_message("<span class='notice'>[src] beeps and ejects module.</span>")
		playsound(src, 'sound/machines/twobeep.ogg', 40, 1)
		HP.Move(T)
		HP = null
		return

/obj/machinery/vehicle_vendor/module_repair_station/Topic(href, href_list)
	if(..())
		return

	usr.set_interaction(src)
	add_fingerprint(usr)

	if(busy)
		to_chat(usr, "<span class='warning'>Repair station is busy. Please wait for current process to finish.</span>")
		return

	if(href_list["repair"])
		repair_module(text2num(href_list["repair"]), usr)
		return
	if(href_list["eject"])
		eject_module(usr)
		return


/*
//UI Repair station for modules repair
/obj/machinery/vehicle_vendor/modules_repair_station
	name = "ColMarTech Automated Modules Repair Station"
	desc = "This piece of machinery automatically fixes damage of insterted modules. One at a time."
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/obj/item/hardpoint/HP
	var/list/module = list(name, health, maxhealth)
	var/busy = FALSE
/obj/machinery/vehicle_vendor/modules_repair_station/New()
	..()
	start_processing()
/obj/machinery/vehicle_vendor/modules_repair_station/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "drone_fab_nopower"
/obj/machinery/vehicle_vendor/modules_repair_station/process()
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
/obj/machinery/vehicle_vendor/modules_repair_station/attack_hand(mob/user)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return
	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return
	if(I.rank != vendor_role)
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return
	user.set_interaction(src)
	ui_interact(user)
/obj/machinery/vehicle_vendor/modules_repair_station/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/hardpoint))
		O.Move(src)
		user.temp_drop_inv_item(O, 0)
/obj/machinery/vehicle_vendor/modules_repair_station/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)
	if(!ishuman(user)) return
	var/list/display_list = list()
	var/hp_name = module[1]
	var/hp_health = round(module[2]*100/module[3])
	var/hp_maxhealth = module[3]
	var/hp_inserted
	if(hp_maxhealth <= 0)
		hp_inserted = FALSE
	else
		hp_inserted = TRUE
							//place in main list, name, health in %, available or not.
	display_list += list(list("hp_index" = 1, "hp_name" = hp_name, "hp_health" = hp_health, "hp_available" = hp_available))
	var/list/data = list(
		"vendor_name" = name,
		"displayed_records" = display_list,
	)
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "module_repair_station.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)
/obj/machinery/vehicle_vendor/modules_repair_station/proc/repair_module(obj/item/hardpoint/HP, mob/user)
	set waitfor = 0
	if(stat & NOPOWER) return
	if(HP.health >= HP.maxhealth)
		to_chat(user, "<span class='warning'>Module is intact.</span>")
		return
	visible_message("<span class='notice'>[src] starts clanking and humming as it begind repair process.</span>")
	icon_state = "drone_fab_active"
	busy = TRUE
	var/timer = 100 - round(HP.health * 100 / HP.maxhealth)	//here we check the amount of missing hp in %
	var/multiplier = 4										//here we adjust that number by multiplier to get we need to fix module
	sleep(timer * multiplier)
	busy = FALSE
	var/turf/T = locate(src)
	playsound(src, pick('sound/machines/hydraulics_1.ogg', 'sound/machines/hydraulics_2.ogg'), 40, 1)
	sleep(10)
	new part_type(T)
	playsound(src, 'sound/machines/twobeep.ogg', 40, 1)
	HP.move(T)
	icon_state = "drone_fab_idle"
/obj/machinery/vehicle_vendor/modules_repair_station/Topic(href, href_list)
	if(..())
		return
	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		add_fingerprint(usr)
		if(busy)
			to_chat(usr, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
			return
		if(href_list["repair"])
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return
			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return
			if(I.rank != vendor_role)
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return
			repair_module(href_list["repair"], usr)
			return
	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["repair"])
			var/idx=text2num(href_list["repair"])
			var/list/L = listed_products[idx]
			var/mob/living/carbon/human/H = usr
			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return
			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return
			if(I.rank != vendor_role)
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return
			var/type_p = L[3]
			var/obj/item/IT = new type_p(loc)
			IT.add_fingerprint(usr)
			if(aval_tank_mod.Find(L[4]))
				aval_tank_mod -= L[4]
				H.update_action_buttons()
			else
				to_chat(H, "<span class='warning'>You already took something from this category.</span>")
				return
		src.add_fingerprint(usr)
		ui_interact(usr) //updates the nanoUI window
*/




//based on Barsik's fabricator, vendor
/*
/obj/machinery/vehicle_vendor/tank_vendor
	name = "ColMarTech Automated Tank Vendor"
	desc = "This vendor is connected to main ship storage, allows to fetch one hardpoint module per category for free."
	density = 1
	anchored = 1
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "engi"
	use_power = 1
	idle_power_usage = 30
	var/busy
	var/list/aval_tank_mod = list("manual", "primary", "secondary", "support", "armor", "treads")
/obj/machinery/vehicle_vendor/tank_vendor/process()
	if(ticker.current_state < GAME_STATE_PLAYING)
		return
	if(stat & NOPOWER)
		icon_state = "engi_off"
		return
	if(busy)
		icon_state = "engi-deny"
		return
	else
		icon_state = "engi"
/obj/machinery/vehicle_vendor/tank_vendor/New()
	..()
	start_processing()
/obj/machinery/vehicle_vendor/tank_vendor/power_change()
	..()
	if (stat & NOPOWER)
		icon_state = "engi_off"
/obj/machinery/vehicle_vendor/tank_vendor/attack_hand(mob/user)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return
	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return
	if(vendor_role && I.rank != vendor_role)
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return
	user.set_interaction(src)
	var/dat = "<center><h2>ColMarTech Automated Tank Vendor</h2></center><hr/>"
	dat += "<h3>Guide For Dummies:</h3>"
	for(var/build_type in typesof(/obj/item/book/manual/tank_manual))
		var/cat = aval_tank_mod[1]
		dat += "<a href='byond://?src=\ref[src];vend=[build_type];category=[cat]'>Guide For Dummies: How To Tank</a><br>"
	dat += "<h3>Primary Weapon:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/primary))
		var/obj/item/hardpoint/primary/PR = build_type
		if(PR.point_cost != 0)
			var/build_name = initial(PR.name)
			var/cat = aval_tank_mod[2]
			dat += "<a href='byond://?src=\ref[src];vend=[build_type];category=[cat]'>[build_name]</a><br>"
	dat += "<h3>Secondary Weapon:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/secondary))
		var/obj/item/hardpoint/secondary/SE = build_type
		if(SE.point_cost != 0)
			var/build_name = initial(SE.name)
			var/cat = aval_tank_mod[3]
			dat += "<a href='byond://?src=\ref[src];vend=[build_type];category=[cat]'>[build_name]</a><br>"
	dat += "<h3>Support Module:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/support))
		var/obj/item/hardpoint/support/SP = build_type
		if(SP.point_cost != 0)
			var/build_name = initial(SP.name)
			var/cat = aval_tank_mod[4]
			dat += "<a href='byond://?src=\ref[src];vend=[build_type];category=[cat]'>[build_name]</a><br>"
	dat += "<h3>Armor:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/armor))
		var/obj/item/hardpoint/armor/AR = build_type
		if(AR.point_cost != 0)
			var/build_name = initial(AR.name)
			var/cat = aval_tank_mod[5]
			dat += "<a href='byond://?src=\ref[src];vend=[build_type];category=[cat]'>[build_name]</a><br>"
	dat += "<h3>Treads:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/treads))
		var/obj/item/hardpoint/treads/TR = build_type
		if(TR.point_cost != 0)
			var/build_name = initial(TR.name)
			var/cat = aval_tank_mod[6]
			dat += "<a href='byond://?src=\ref[src];vend=[build_type];category=[cat]'>[build_name]</a><br>"
	user << browse(dat, "window=tank_vendor")
	onclose(user, "tank_vendor")
	return
/obj/machinery/vehicle_vendor/tank_vendor/proc/vend_tank_part(part_type, cat, mob/user)
	set waitfor = 0
	if(stat & NOPOWER) return
	if(!aval_tank_mod.Find(cat))
		to_chat(user, "<span class='warning'>You already vended something from this category.</span>")
		return
	visible_message("<span class='notice'>[src] hums as it extracts module from ship's storage.</span>")
	aval_tank_mod -= cat
	icon_state = "engi-deny"
	busy = TRUE
	sleep(50)
	busy = FALSE
	var/turf/T = locate(x,y-1,z)
	playsound(src, pick('sound/machines/hydraulics_1.ogg', 'sound/machines/hydraulics_2.ogg'), 40, 1)
	sleep(10)
	new part_type(T)
	playsound(src, 'sound/machines/twobeep.ogg', 40, 1)
	icon_state = "engi"
/obj/machinery/vehicle_vendor/tank_vendor/Topic(list, href_list)
	if(..())
		return
	usr.set_interaction(src)
	add_fingerprint(usr)
	if(busy)
		to_chat(usr, "<span class='warning'>Vendor is fetching module from ship storage, standby.</span>")
		return
	if(href_list["vend"])
		vend_tank_part(href_list["vend"], href_list["category"], usr)
		return
*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//old fabricator made by Barsik
/obj/machinery/tank_part_fabricator
	name = "tank part fabricator"
	desc = "A large automated 3D printer for producing new tank parts."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"
	var/tank_points = 425
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
	for(var/build_type in typesof(/obj/item/hardpoint/tank/armor))
		var/obj/item/hardpoint/tank/armor/AR = build_type
		var/build_name = initial(AR.name)
		var/build_cost = initial(AR.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Primary Weapon:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/tank/primary))
		var/obj/item/hardpoint/tank/primary/PR = build_type
		var/build_name = initial(PR.name)
		var/build_cost = initial(PR.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Secondary Weapon:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/tank/secondary))
		var/obj/item/hardpoint/tank/secondary/SE = build_type
		var/build_name = initial(SE.name)
		var/build_cost = initial(SE.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Support Module:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/tank/support))
		var/obj/item/hardpoint/tank/support/SP = build_type
		var/build_name = initial(SP.name)
		var/build_cost = initial(SP.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	dat += "<h3>Treads:</h3>"
	for(var/build_type in typesof(/obj/item/hardpoint/tank/treads))
		var/obj/item/hardpoint/tank/treads/TR = build_type
		var/build_name = initial(TR.name)
		var/build_cost = initial(TR.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"

	/*dat += "<h3>Weapon Ammo:</h3>"
	for(var/build_type in typesof(/obj/item/ammo_magazine/tank))
		var/obj/item/ammo_magazine/tank/AM = build_type
		var/build_name = initial(AM.name)
		var/build_cost = initial(AM.point_cost)
		if(build_cost)
			dat += "<a href='byond://?src=\ref[src];produce=[build_type];cost=[build_cost]'>[build_name] ([build_cost])</a><br>"
*/

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
	var/turf/T = locate(x+1,y,z)
	playsound(src, 'sound/machines/hydraulics_1.ogg', 40, 1)
	new part_type(T)
	icon_state = "drone_fab_idle"

/obj/machinery/tank_part_fabricator/Topic(href, href_list)
	if(..())
		return

	usr.set_interaction(src)
	add_fingerprint(usr)

	if(busy)
		to_chat(usr, "<span class='warning'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return

	if(href_list["produce"])
		build_tank_part(href_list["produce"], text2num(href_list["cost"]), usr)
		return