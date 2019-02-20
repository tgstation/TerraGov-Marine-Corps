//TANKS, HURRAY
//Read the documentation in cm_armored.dm and multitile.dm before trying to decipher this stuff


/obj/vehicle/multitile/root/cm_armored/tank
	name = "M46 \"Stingray\" Tank"
	desc = "M46 \"Stingray\" Modular Multipurpose Tank. A giant piece of armor, was made as a budget version of a tank specifically for USCM. Supports installing different types of modules and weapons, allowing technicians to refit tank for any type of operation. Has inbuilt M75 Smoke Deploy System. Entrance in the back."

	icon = 'icons/obj/tank_NS.dmi'
	icon_state = "tank_base"
	pixel_x = -32
	pixel_y = -32

	var/named = FALSE
	var/mob/gunner
	var/mob/driver
	var/mob/swap_seat	//this is a temp seat for switching seats when both TCs are in tank

	var/obj/machinery/camera/camera = null	//Yay! Working camera in the tank!

	var/occupant_exiting = 0
	var/next_sound_play = 0

	luminosity = 7

/obj/effect/multitile_spawner/cm_armored/tank

	width = 3
	height = 3
	spawn_dir = EAST

/obj/effect/multitile_spawner/cm_armored/tank/New()

	var/obj/vehicle/multitile/root/cm_armored/tank/R = new(src.loc)
	R.dir = EAST

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	//Entrance relative to the root object. The tank spawns with the root centered on the marker
	var/datum/coords/entr_mark = new
	entr_mark.x_pos = -2
	entr_mark.y_pos = 0

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)
	R.update_icon()

	R.camera = new /obj/machinery/camera(R)
	R.camera.network = list("almayer")	//changed network from military to almayer,because Cams computers on Almayer have this network
	R.camera.c_tag = "Armored Vehicle #[rand(1,10)]" //ARMORED VEHICLE to be at the start of cams list, numbers in case of events with multiple tanks and for APC

	del(src)

//Pretty similar to the previous one
//TODO: Make this code better and less repetetive
//Spawns a tank that has a bunch of broken hardpoints
/obj/effect/multitile_spawner/cm_armored/tank/decrepit/New()

	var/obj/vehicle/multitile/root/cm_armored/tank/R = new(src.loc)
	R.dir = EAST

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	var/datum/coords/entr_mark = new
	entr_mark.x_pos = -2
	entr_mark.y_pos = 0

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)

	//Manually adding those hardpoints
	R.damaged_hps = list(
				"primary",
				"secondary",
				"support",
				"armor")

	R.update_icon()

	R.camera = new /obj/machinery/camera(R)
	R.camera.network = list("almayer")	//changed network from military to almayer,because Cams computers on Almayer have this network
	R.camera.c_tag = "Armored Vehicle #[rand(1,10)]" //ARMORED VEHICLE to be at the start of cams list, numbers in case of events with multiple tanks and for APC

	del(src)

/obj/effect/multitile_spawner/cm_armored/tank/prebuilt/New()

	var/obj/vehicle/multitile/root/cm_armored/tank/R = new(src.loc)
	R.dir = EAST

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	//Entrance relative to the root object. The tank spawns with the root centered on the marker
	var/datum/coords/entr_mark = new
	entr_mark.x_pos = -2
	entr_mark.y_pos = 0

	//Manually adding those hardpoints
	R.add_hardpoint(new /obj/item/hardpoint/tank/primary/cannon, R.hardpoints[HDPT_PRIMARY])
	R.add_hardpoint(new /obj/item/hardpoint/tank/secondary/m56cupola, R.hardpoints[HDPT_SECDGUN])
	R.add_hardpoint(new /obj/item/hardpoint/tank/support/artillery_module, R.hardpoints[HDPT_SUPPORT])
	R.add_hardpoint(new /obj/item/hardpoint/tank/armor/ballistic, R.hardpoints[HDPT_ARMOR])
	R.add_hardpoint(new /obj/item/hardpoint/tank/treads/standard, R.hardpoints[HDPT_TREADS])
	R.update_damage_distribs()

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)
	R.healthcheck()

	R.camera = new /obj/machinery/camera(R)
	R.camera.network = list("almayer")	//changed network from military to almayer,because Cams computers on Almayer have this network
	R.camera.c_tag = "Armored Vehicle #[rand(1,10)]" //ARMORED VEHICLE to be at the start of cams list, numbers in case of events with multiple tanks and for APC

	del(src)


/obj/effect/multitile_spawner/cm_armored/tank/upp/New()

	var/obj/vehicle/multitile/root/cm_armored/tank/R = new(src.loc)
	R.dir = EAST

	R.name = "Type 91 \"Wolverine\" Main Battle Tank"
	R.desc = "Watch out! It's UPP main battle tank! Has inbuilt Type 21 \"Zavesa\" smoke cover system. Entrance in the back."

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	var/datum/coords/entr_mark = new
	entr_mark.x_pos = -2
	entr_mark.y_pos = 0

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)

	//Manually adding those hardpoints
	R.add_hardpoint(new /obj/item/hardpoint/tank/primary/cannon/upp, R.hardpoints[HDPT_PRIMARY])
	R.add_hardpoint(new /obj/item/hardpoint/tank/secondary/m56cupola/upp, R.hardpoints[HDPT_SECDGUN])
	R.add_hardpoint(new /obj/item/hardpoint/tank/support/artillery_module/upp, R.hardpoints[HDPT_SUPPORT])
	R.add_hardpoint(new /obj/item/hardpoint/tank/armor/ballistic/upp, R.hardpoints[HDPT_ARMOR])
	R.add_hardpoint(new /obj/item/hardpoint/tank/treads/standard/upp, R.hardpoints[HDPT_TREADS])
	R.update_damage_distribs()

	R.color = "#c2b678"
	R.healthcheck()

	del(src)

//For the tank, start forcing people out if everything is broken
/obj/vehicle/multitile/root/cm_armored/tank/handle_all_modules_broken()
	deactivate_all_hardpoints()
	var/turf/T = get_turf(entrance)
	if(tile_blocked_check(T))
		if(gunner)
			T = get_new_exit_point()
			if(tile_blocked_check(T))
				return
			else
				gunner.Move(T)
				to_chat(gunner, "<span class='danger'>You cannot breath in all the smoke inside the vehicle and back hatch is blocked, so you get out through an auxiliary top hatch and jump off the tank!</span>")
				gunner = null
		if(driver)
			T = get_new_exit_point()
			if(tile_blocked_check(T))
				return
			else
				driver.Move(T)
				to_chat(driver, "<span class='danger'>You cannot breath in all the smoke inside the vehicle and back hatch is blocked, so you get out through an auxiliary top hatch and jump off the tank!</span>")
				driver = null
	else
		to_chat(driver, "<span class='danger'>You cannot breath in all the smoke inside the vehicle so you dismount!</span>")
		gunner.Move(T)
		to_chat(driver, "<span class='danger'>You cannot breath in all the smoke inside the vehicle so you dismount!</span>")
		driver.Move(T)
	if(gunner.client)
		gunner.client.mouse_pointer_icon = initial(gunner.client.mouse_pointer_icon)
	gunner.unset_interaction()
	gunner = null
	driver.unset_interaction()
	driver = null
	swap_seat = null

/obj/vehicle/multitile/root/cm_armored/tank/remove_all_players()
	deactivate_all_hardpoints()
	if(!entrance) //Something broke, uh oh
		if(gunner) gunner.loc = src.loc
		if(driver) driver.loc = src.loc
	else
		if(gunner) gunner.forceMove(entrance.loc)
		if(driver) driver.forceMove(entrance.loc)

	if(gunner.client)
		gunner.client.mouse_pointer_icon = initial(gunner.client.mouse_pointer_icon)
	gunner = null
	driver = null
	swap_seat = null

//megaphone proc. Simply adding megaphone to tank and activate it doesn't work, so writing new Megaphone code for tank
/obj/vehicle/multitile/root/cm_armored/tank/proc/use_megaphone(mob/living/user)
	var/spamcheck = 0
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(user, "\red You cannot speak in IC (muted).")
			return
	if(user.silent)
		return

	if(spamcheck)
		to_chat(user, "\red \The megaphone needs to recharge!")
		return

	var/message = copytext(sanitize(input(user, "Shout a message?", "Megaphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return
	message = capitalize(message)
	log_admin("[key_name(user)] used a tank megaphone to say: >[message]<")
	if (usr.stat == 0)
		for(var/mob/living/carbon/human/O in (range(7,src)))
			if(O.species && O.species.name == "Yautja") //NOPE
				O.show_message("Some loud speech heard from the tank, but you can't understand it.")
				continue
			O.show_message("<B>Tank</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2)
		for(var/mob/dead/observer/O in (range(7,src)))
			O.show_message("<B>Tank</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2)
		for(var/mob/living/carbon/Xenomorph/X in (range(7,src)))
			X.show_message("Some loud tallhost noises can be heard from the metal turtle, but you can't understand them.")

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

//little QoL won't be bad, aight?
/obj/vehicle/multitile/root/cm_armored/tank/verb/megaphone()
	set name = "Use Megaphone"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	use_megaphone(usr)

//Built in smoke launcher system verb.
/obj/vehicle/multitile/root/cm_armored/tank/verb/smoke_cover()
	set name = "Activate Smoke Deploy System"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(smoke_ammo_current)
		to_chat(usr, "<span class='warning'>You activate Smoke Deploy System!</span>")
		visible_message("<span class='danger'>You notice two grenades flying in front of the tank!</span>")
		smoke_shot()
	else
		to_chat(usr, "<span class='warning'>Out of ammo! Reload smoke grenades magazine!</span>")
		return

//Naming done right
/obj/vehicle/multitile/root/cm_armored/tank/verb/name_tank()
	set name = "Name The Tank (Single Use)"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(named)
		to_chat(usr, "<span class='warning'>Tank was already named!</span>")
		return
	var/nickname = copytext(sanitize(input(usr, "Name your tank (20 symbols, without \"\", they will be added), russian symbols won't be seen", "Naming", null) as text),1,20)
	if(!nickname)
		to_chat(usr, "<span class='warning'>No text entered!</span>")
		return
	if(!named)
		src.name += " \"[nickname]\""
	else
		to_chat(usr, "<span class='warning'>Other TC was quicker! Tank already was named!</span>")
	named = TRUE

//Let's you switch into the other seat, doesn't work if it's occupied
/obj/vehicle/multitile/root/cm_armored/tank/verb/switch_seats()
	set name = "Swap Seats"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	var/answer = alert(usr, "Are you sure you want to swap seats?", , "Yes", "No") //added confirmation window
	if(answer == "No")
		return

	//A little icky, but functional
	//Using a list of mobs for driver and gunner might make this code look better
	//But all of the other code about those two would look like shit

	//Added mechanic for switching seats when both TCs are in the tank, that will take twice more time and will work only if another TC agrees.
	if(usr == gunner)
		if(driver)
			answer = alert(driver, "Your gunner offers you to swap seats.", , "Yes", "No")
			if(answer == "No")
				to_chat(usr, "<span class='notice'>Driver has refused to swap seats with you.</span>")
			else
				to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")
				to_chat(driver, "<span class='notice'>You start getting into the other seat.</span>")
				sleep(60)
				to_chat(usr, "<span class='notice'>You switch seats.</span>")
				to_chat(driver, "<span class='notice'>You switch seats.</span>")
				deactivate_all_hardpoints()

				swap_seat = gunner
				gunner = driver
				if(gunner.client)
					gunner.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
				driver = swap_seat
				if(driver.client)
					driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)
				swap_seat = null
				return

			//to_chat(usr, "<span class='notice'>There's already someone in the other seat.</span>")
			//return

		to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")

		sleep(30)

		if(driver)
			to_chat(usr, "<span class='notice'>Someone beat you to the other seat!</span>")
			return

		to_chat(usr, "<span class='notice'>You switch seats.</span>")

		deactivate_all_hardpoints()

		driver = gunner
		gunner = null

		if(driver.client)
			driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)
	else if(usr == driver)
		if(gunner)
			answer = alert(gunner, "Your driver offers you to swap seats.", , "Yes", "No")
			if(answer == "No")
				to_chat(usr, "<span class='notice'>Driver has refused to swap seats with you.</span>")
			else
				to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")
				to_chat(gunner, "<span class='notice'>You start getting into the other seat.</span>")
				sleep(60)
				to_chat(usr, "<span class='notice'>You switch seats.</span>")
				to_chat(gunner, "<span class='notice'>You switch seats.</span>")
				deactivate_all_hardpoints()

				swap_seat = gunner
				gunner = driver
				deactivate_binos(gunner)
				if(gunner.client)
					gunner.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
				driver = swap_seat
				if(driver.client)
					driver.client.mouse_pointer_icon = initial(driver.client.mouse_pointer_icon)
				swap_seat = null
				return
		to_chat(usr, "<span class='notice'>You start getting into the other seat.</span>")

		sleep(30)

		if(gunner)
			to_chat(usr, "<span class='notice'>Someone beat you to the other seat!</span>")
			return

		to_chat(usr, "<span class='notice'>You switch seats.</span>")

		gunner = driver
		driver = null
		deactivate_binos(gunner)
		if(gunner.client)
			gunner.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")

/obj/vehicle/multitile/root/cm_armored/tank/can_use_hp(var/mob/M)
	return (M == gunner)

/obj/vehicle/multitile/root/cm_armored/tank/handle_harm_attack(var/mob/M)

	if(M.loc != entrance.loc)	return

	if(!gunner && !driver)
		to_chat(M, "<span class='warning'>There is no one in the vehicle.</span>")
		return

	to_chat(M, "<span class='notice'>You start pulling [driver ? driver : gunner] out of their seat.</span>")

	if(!do_after(M, 200, show_busy_icon = BUSY_ICON_HOSTILE))
		to_chat(M, "<span class='warning'>You stop pulling [driver ? driver : gunner] out of their seat.</span>")
		return

	if(M.loc != entrance.loc) return

	if(!gunner && !driver)
		to_chat(M, "<span class='warning'>There is no longer anyone in the vehicle.</span>")
		return

	M.visible_message("<span class='warning'>[M] pulls [driver ? driver : gunner] out of their seat in [src].</span>",
		"<span class='notice'>You pull [driver ? driver : gunner] out of their seat.</span>")

	var/mob/targ
	if(driver)
		targ = driver
		driver = null
	else
		if(gunner.client)
			gunner.client.mouse_pointer_icon = initial(gunner.client.mouse_pointer_icon)
		targ = gunner
		gunner = null
	to_chat(targ, "<span class='danger'>[M] forcibly drags you out of your seat and dumps you on the ground!</span>")
	targ.forceMove(entrance.loc)
	targ.unset_interaction()
	targ.KnockDown(7, 1)


//Two seats, gunner and driver
//Must have the skills to do so
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_entrance(var/mob/M)
	var/loc_check = M.loc
	var/slot = input("Select a seat") in list("Driver", "Gunner")

	if(!M || M.client == null) return

	if(!M.mind || !(!M.mind.cm_skills || M.mind.cm_skills.large_vehicle >= SKILL_LARGE_VEHICLE_TRAINED))
		to_chat(M, "<span class='notice'>You have no idea how to operate this thing.</span>")
		return

	to_chat(M, "<span class='notice'>You start climbing into [src].</span>")

	switch(slot)
		if("Driver")

			if(driver != null)
				to_chat(M, "<span class='notice'>That seat is already taken.</span>")
				return

			if(!do_after(M, 100, needhand = FALSE, show_busy_icon = TRUE))
				to_chat(M, "<span class='notice'>Something interrupted you while getting in.</span>")
				return

			if(M.loc != loc_check)
				to_chat(M, "<span class='notice'>You stop getting in.</span>")
				return

			if(driver != null)
				to_chat(M, "<span class='notice'>Someone got into that seat before you could.</span>")
				return
			driver = M
			M.Move(src)
			if(loc_check == entrance.loc)
				to_chat(M, "<span class='notice'>You enter the driver's seat.</span>")
			else
				to_chat(M, "<span class='notice'>You climb onto the tank and enter the driver's seat through an auxiliary top hatchet.</span>")

			M.set_interaction(src)
			return

		if("Gunner")

			if(gunner != null)
				to_chat(M, "<span class='notice'>That seat is already taken.</span>")
				return

			if(!do_after(M, 100, needhand = FALSE, show_busy_icon = TRUE))
				to_chat(M, "<span class='notice'>Something interrupted you while getting in.</span>")
				return

			if(M.loc != loc_check)
				to_chat(M, "<span class='notice'>You stop getting in.</span>")
				return

			if(gunner != null)
				to_chat(M, "<span class='notice'>Someone got into that seat before you could.</span>")
				return

			if(!M.client) return //Disconnected while getting in
			gunner = M
			//M.loc = src
			M.Move(src)
			deactivate_binos(gunner)
			if(loc_check == entrance.loc)
				to_chat(M, "<span class='notice'>You enter the driver's seat.</span>")
			else
				to_chat(M, "<span class='notice'>You climb onto the tank and enter the driver's seat through an auxiliary top hatchet.</span>")
			M.set_interaction(src)
			if(M.client)
				M.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")


			return

//Deposits you onto the exit marker
//TODO: Sometimes when the entrance marker is on the wall or somewhere you can't move to, it still deposits you there
//Fix that bug at somepoint ^^
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_exit(var/mob/M)

	if(M != gunner && M != driver) return

	if(occupant_exiting)
		to_chat(M, "<span class='notice'>Someone is already getting out of the vehicle.</span>")
		return

	to_chat(M, "<span class='notice'>You start climbing out of [src].</span>")

	occupant_exiting = 1
	sleep(50)
	occupant_exiting = 0

	if(tile_blocked_check(entrance.loc))
		to_chat(M, "<span class='notice'>Something is blocking you from exiting.</span>")
		return
	else
		if(M == gunner)
			deactivate_all_hardpoints()
			if(M.client)
				M.client.mouse_pointer_icon = initial(M.client.mouse_pointer_icon)
			M.Move(entrance.loc)

			gunner = null
		else
			if(M == driver)
				M.Move(entrance.loc)
				driver = null
		M.unset_interaction()
		to_chat(M, "<span class='notice'>You climb out of [src].</span>")

//No one but the driver can drive
/obj/vehicle/multitile/root/cm_armored/tank/relaymove(var/mob/user, var/direction)
	if(user != driver) return

	. = ..(user, direction)

	//Someone remind me to fix this fucking snow code --MadSnailDisease
	//The check is made here since the snowplow won't fit on the APC
	if(. && istype(hardpoints[HDPT_ARMOR], /obj/item/hardpoint/tank/armor/snowplow) && direction == dir)
		var/obj/item/hardpoint/tank/armor/snowplow/SP = hardpoints[HDPT_ARMOR]
		if(SP.health > 0)
			for(var/datum/coords/C in linked_objs)
				var/turf/T = locate(src.x + C.x_pos, src.y + C.y_pos, src.z + C.z_pos)
				if(istype(T, /turf/open/snow))
					var/turf/open/snow/ST = T
					if(ST && ST.slayer)
						new /obj/item/stack/snow(ST, ST.slayer)
						ST.slayer = 0
						ST.update_icon(1, 0)
				var/mob/living/carbon/MB
				for(MB in T)
					if(MB.lying == 1)
						var/turf/temp = T
						temp = get_step(temp, direction)
						MB.throw_at(temp, 1, 1, src, 0)
						if(!isXeno(MB))
							MB.apply_damage(10, BRUTE)
				var/obj/effect/alien/weeds/WE
				for(WE in T)
					WE.Destroy()
				var/obj/item/explosive/mine/MN
				for(MN in T)
					MN.trigger_explosion()
				var/obj/structure/bed/nest/XN
				for(XN in T)
					XN.unbuckle()
					XN.Destroy()
				var/obj/effect/alien/resin/sticky/ST
				for(ST in T)
					ST.Destroy()
				var/obj/effect/alien/resin/trap/TR
				for(TR in T)
					TR.Destroy()



	if(next_sound_play < world.time)
		playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)
		next_sound_play = world.time + 21

//No one but the driver can turn
/obj/vehicle/multitile/root/cm_armored/tank/try_rotate(var/deg, var/mob/user, var/force = 0)

	if(user != driver) return

	. = ..(deg, user, force)

	if(. && istype(hardpoints[HDPT_SUPPORT], /obj/item/hardpoint/tank/support/artillery_module) && gunner && gunner.client)
		var/client/C = gunner.client
		var/old_x = C.pixel_x
		var/old_y = C.pixel_y
		C.pixel_x = old_x*cos(deg) - old_y*sin(deg)
		C.pixel_y = old_x*sin(deg) + old_y*cos(deg)


/obj/vehicle/multitile/hitbox/cm_armored/tank/Bump(var/atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/M = A
		var/obj/vehicle/multitile/root/cm_armored/tank/T
		log_attack("[T ? T.driver : "Someone"] drove over [M] with [root]")