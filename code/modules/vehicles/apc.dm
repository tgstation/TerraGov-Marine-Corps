//APCS, HURRAY
//Read the documentation in cm_transport.dm and multitile.dm before trying to decipher this stuff

//NOT bitflags, just global constant values
#define "Medical Modification" 1
#define "Supply Modification" 2
#define "Command Modification" 3

var/list/free_modules = list("Medical Modification", "Supply Modification", "Command Modification")

/obj/vehicle/multitile/root/cm_transport/apc
	name = "M580 APC"
	desc = "M580 Armored Personnel Carrier. Combat transport for delivering and supporting infantry. Entrance on the right side."

	icon = 'icons/obj/apcarrier_NS.dmi'
	icon_state = "apc_base"
	pixel_x = -32
	pixel_y = -32

	var/named = FALSE
	var/passengers = 0
	var/passengers_max
	var/mob/gunner
	var/mob/driver
	var/cabin_door_busy = FALSE
	var/special_module_working = FALSE
	var/special_module_type = null
	var/tank_crewman_entered = FALSE
	var/module_role_entered = FALSE
	var/module_role = null
	var/turf/interior_area
	var/obj/structure/vehicle_interior/side_door/interior_side_door
	var/obj/structure/vehicle_interior/cabin_door/interior_cabin_door
	var/obj/machinery/vehicle_interior/tcomms_receiver/interior_tcomms
	var/obj/machinery/camera/interior_cam
	var/mob/camera_user

	var/obj/machinery/camera/camera = null	//Yay! Working camera in the apc!

	var/next_sound_play = 0

	luminosity = 2

/obj/effect/multitile_spawner/cm_transport/apc

	width = 3
	height = 3
	spawn_dir = EAST

/obj/effect/multitile_spawner/cm_transport/apc/New()

	var/obj/vehicle/multitile/root/cm_transport/apc/R = new(src.loc)
	R.dir = EAST

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	//Entrance relative to the root object. The apc spawns with the root centered on the marker
	var/datum/coords/entr_mark = new
	entr_mark.x_pos = 0
	entr_mark.y_pos = -2

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)
	R.update_icon()

	R.camera = new /obj/machinery/camera(R)
	R.camera.network = list("almayer")	//changed network from military to almayer,because Cams computers on Almayer have this network
	R.camera.c_tag = "Armored Personnel Carrier �[rand(1,10)]" //ARMORED to be at the start of cams list, numbers in case of events with multiple vehicles

	del(src)

//Pretty similar to the previous one
//TODO: Make this code better and less repetetive
//Spawns a apc that has a bunch of broken hardpoints
/obj/effect/multitile_spawner/cm_transport/apc/decrepit/New()

	var/obj/vehicle/multitile/root/cm_transport/apc/R = new(src.loc)
	R.dir = EAST

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	var/datum/coords/entr_mark = new
	entr_mark.x_pos = 0
	entr_mark.y_pos = -2

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)

	//Manually adding those hardpoints
	R.damaged_hps = list(
				"primary",
				"secondary",
				"support")

	R.update_icon()

	R.camera = new /obj/machinery/camera(R)
	R.camera.network = list("almayer")	//changed network from military to almayer, because Cams computers on Almayer have this network
	R.camera.c_tag = "Armored Personnel Carrier �[rand(1,10)]" //ARMORED to be at the start of cams list, numbers in case of events with multiple vehicles

	del(src)


/obj/effect/multitile_spawner/cm_transport/apc/prebuilt/New()

	var/obj/vehicle/multitile/root/cm_transport/apc/R = new(src.loc)
	R.dir = EAST

	var/datum/coords/dimensions = new
	dimensions.x_pos = width
	dimensions.y_pos = height
	var/datum/coords/root_pos = new
	root_pos.x_pos = 1
	root_pos.y_pos = 1

	//Entrance relative to the root object. The apc spawns with the root centered on the marker
	var/datum/coords/entr_mark = new
	entr_mark.x_pos = 0
	entr_mark.y_pos = -2

	R.load_hitboxes(dimensions, root_pos)
	R.load_entrance_marker(entr_mark)
	R.update_icon()

	R.camera = new /obj/machinery/camera(R)
	R.camera.network = list("almayer")	//changed network from military to almayer,because Cams computers on Almayer have this network
	R.camera.c_tag = "Armored Personnel Carrier �[rand(1,10)]" //ARMORED to be at the start of cams list, numbers in case of events with multiple vehicles

	//Manually adding those hardpoints
	R.add_hardpoint(new /obj/item/hardpoint/apc/primary/dual_cannon)
	R.add_hardpoint(new /obj/item/hardpoint/apc/secondary/front_cannon)
	R.add_hardpoint(new /obj/item/hardpoint/apc/support/flare_launcher)
	R.add_hardpoint(new /obj/item/hardpoint/apc/wheels)
	R.update_damage_distribs()

	R.healthcheck()

	del(src)

/obj/vehicle/multitile/root/cm_transport/apc/Destroy()
	if(special_module_type)
		free_modules.Add(special_module_type)

	. = ..()

//For the apc, start forcing people out if everything is broken
/obj/vehicle/multitile/root/cm_transport/apc/handle_all_modules_broken()
	deactivate_all_hardpoints()
	if(gunner)
		to_chat(gunner, "<span class='danger'>You cannot breath in all the smoke inside the cabin so you get out!</span>")
		gunner.forceMove(multitile_interior_cabin_exit.loc)
		gunner.unset_interaction()
		gunner = null
		if(gunner.client)
			gunner.client.mouse_pointer_icon = initial(gunner.client.mouse_pointer_icon)
	if(driver)
		to_chat(driver, "<span class='danger'>You cannot breath in all the smoke inside the cabin so you get out!</span>")
		driver.forceMove(multitile_interior_cabin_exit.loc)
		driver.unset_interaction()
		driver = null
	special_module_working = FALSE
	if(special_module_type == "Command Modification")
		interior_tcomms.hard_switch_off()

	camera.status = 0
	SetLuminosity(2)

/obj/vehicle/multitile/root/cm_transport/apc/fix_special_module()
	if(!special_module_working)
		special_module_working = TRUE
		if(special_module_type == "Command Modification")
			interior_tcomms.hard_switch_off()
		camera.status = 1
		if(luminosity == 2)
			SetLuminosity(7)

/obj/vehicle/multitile/root/cm_transport/apc/remove_all_players()
	deactivate_all_hardpoints()
	if(!multitile_interior_cabin_exit) //Something broke, uh oh
		if(gunner) gunner.loc = src.loc
		if(driver) driver.loc = src.loc
	else
		if(gunner) gunner.forceMove(multitile_interior_cabin_exit.loc)
		if(driver) driver.forceMove(multitile_interior_cabin_exit.loc)

	if(gunner.client)
		gunner.client.mouse_pointer_icon = initial(gunner.client.mouse_pointer_icon)
	gunner = null
	driver = null

//megaphone proc. same as in tank
/obj/vehicle/multitile/root/cm_transport/apc/proc/use_megaphone(mob/living/user)
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
	log_admin("[key_name(user)] used a apc megaphone to say: >[message]<")
	if (usr.stat == 0)
		for(var/mob/living/carbon/human/O in (range(7,src)))
			if(O.species && O.species.name == "Yautja") //NOPE
				O.show_message("Some loud speech heard from the APC, but you can't understand it.")
				continue
			O.show_message("<B>apc</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2)
		for(var/mob/dead/observer/O in (range(7,src)))
			O.show_message("<B>apc</B> broadcasts, <FONT size=3>\"[message]\"</FONT>",2)
		for(var/mob/living/carbon/Xenomorph/X in (range(7,src)))
			X.show_message("Some loud tallhost noises heard from the metal turtle, but you can't understand it.")

		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return

/obj/vehicle/multitile/root/cm_transport/apc/examine(var/mob/user)
	..()
	if(isXeno(user))
		var/count = passengers
		if(tank_crewman_entered)
			count++
		if(module_role_entered)
			count++
		if(count == 1)
			to_chat(user, "<span class='xenonotice'>You can sense [count] host inside of the fast metal box, but you can't tell for sure if they are alive.</span>")
			return
		if(count > 1)
			to_chat(user, "<span class='xenonotice'>You can sense [count] hosts inside of the fast metal box, but you can't tell for sure how many of them are alive.</span>")
			return
	if(special_module_type && isobserver(user) && get_dist(src, user) <= 2)
		user.forceMove(multitile_interior_exit.loc)

//little QoL won't be bad, aight?
/obj/vehicle/multitile/root/cm_transport/apc/verb/megaphone()
	set name = "Use Megaphone"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	use_megaphone(usr)

/obj/vehicle/multitile/root/cm_transport/apc/verb/use_interior_camera()
	set name = "Use Interior Camera"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	access_camera(usr)

/obj/vehicle/multitile/root/cm_transport/apc/proc/access_camera(var/mob/living/M)

	if(camera_user)
		if(camera_user == M)
			return
		else
			to_chat(M, "<span class='warning'>Camera is being used by another cabin crewman!</span>")
			return
	else
		camera_user = M
		M.reset_view(interior_cam)
		to_chat(M, "<span class='notice'>You move closer and take a quick look into interior camera monitor.</span>")
		M.unset_interaction()
		if(gunner)
			deactivate_all_hardpoints()
		sleep(10)
		M.set_interaction(src)
		M.reset_view(null)
		camera_user = null
		to_chat(M, "<span class='notice'>You move away from interior camera monitor.</span>")
		return

/*
//Built in smoke launcher system verb.
/obj/vehicle/multitile/root/cm_transport/apc/verb/smoke_cover()
	set name = "Activate Smoke Deploy System"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(smoke_ammo_current)
		to_chat(usr, "<span class='warning'>You activate Smoke Deploy System!</span>")
		visible_message("<span class='danger'>You notice two grenades flying in front of the apc!</span>")
		smoke_shot()
	else
		to_chat(usr, "<span class='warning'>Out of ammo! Reload smoke grenades magazine!</span>")
		return
*/

//Naming done right
/obj/vehicle/multitile/root/cm_transport/apc/verb/name_apc()
	set name = "Name The APC (Single Use)"
	set category = "Vehicle"	//changed verb category to new one, because Object category is bad.
	set src = usr.loc

	if(named)
		to_chat(usr, "<span class='warning'>APC was already named!</span>")
		return
	var/nickname = copytext(sanitize(input(usr, "Name your APC (20 symbols, without \"\", they will be added), russian symbols won't be seen", "Naming", null) as text),1,20)
	if(!nickname)
		to_chat(usr, "<span class='warning'>No text entered!</span>")
		return
	if(!named)
		src.name += " \"[nickname]\""
	else
		to_chat(usr, "<span class='warning'>Other TC was quicker! APC already was named!</span>")
	named = TRUE

/obj/vehicle/multitile/root/cm_transport/apc/can_use_hp(var/mob/M)
	return (M == gunner)

/obj/vehicle/multitile/root/cm_transport/apc/handle_harm_attack(var/mob/M)
	return

/obj/vehicle/multitile/root/cm_transport/apc/proc/pulling_out_crew(var/mob/M)
	var/loc_check = M.loc

	if(!gunner && !driver)
		if(isXeno(M))
			to_chat(M, "<span class='xenowarning'>There is no one in the cabin.</span>")
		else
			to_chat(M, "<span class='warning'>There is no one in the cabin.</span>")
		return

	if(isXeno(M))
		to_chat(M, "<span class='xenonotice'>You start pulling [driver ? driver : gunner] out of their seat.</span>")
	else
		to_chat(M, "<span class='notice'>You start pulling [driver ? driver : gunner] out of their seat.</span>")

	if(!do_after(M, 50, show_busy_icon = BUSY_ICON_HOSTILE))
		if(isXeno(M))
			to_chat(M, "<span class='xenowarning'>You stop pulling [driver ? driver : gunner] out of their seat.</span>")
		else
			to_chat(M, "<span class='warning'>You stop pulling [driver ? driver : gunner] out of their seat.</span>")
		return

	if(M.loc != loc_check) return

	if(!gunner && !driver)
		to_chat(M, "<span class='warning'>There is no longer anyone in the cabin.</span>")
		return

	M.visible_message("<span class='warning'>[M] pulls [driver ? driver : gunner] out of their seat in vehicle cabin.</span>",
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
	targ.forceMove(multitile_interior_cabin_exit.loc)
	targ.unset_interaction()
	targ.KnockDown(3, 1)

//12 passengers allowed by default + TC + module role
/obj/vehicle/multitile/root/cm_transport/apc/handle_interior_entrance(var/mob/living/carbon/M)

	if(special_module_type == null)
		choose_module(M)
		return

	if(!M || M.client == null) return

	if(interior_side_door.side_door_busy)
		to_chat(M, "<span class='notice'>Someone is in the doorway.</span>")
		return

	var/new_module_role_entered = FALSE
	var/new_tank_crewman_entered = FALSE
	var/new_passengers = 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/card/id/I = H.wear_id
		if(I && I.rank == "Tank Crewman" && !tank_crewman_entered)
			new_tank_crewman_entered = TRUE
		else
			if(I && I.rank == module_role && !module_role_entered)
				new_module_role_entered = TRUE
			else
				if(passengers >= passengers_max)
					to_chat(M, "<span class='warning'>[src] is full.</span>")
					return
				else
					new_passengers++
					to_chat(M, "<span class='debuginfo'>new passengers = [new_passengers].</span>")
	else
		if(passengers >= passengers_max)
			to_chat(M, "<span class='warning'>[src] is full.</span>")
			return
		else
			new_passengers++
	//to_chat(M, "<span class='danger'>Check for user done.</span>")

	var/move_pulling = FALSE
	if(M.pulling && get_dist(entrance, M.pulling) <= 1)
		move_pulling = TRUE
		if(isliving(M.pulling))
			to_chat(M, "<span class='debuginfo'>M.pulling is alive.</span>")
			var/mob/living/B = M.pulling
			if(B.buckled)
				to_chat(M, "<span class='warning'>You can't fit [M.pulling] on the [B.buckled] through a doorway! Try unbuckling [M.pulling] first.</span>")
				return
			if(isXeno(M.pulling))
				to_chat(M, "<span class='warning'>Taking that leaking acid [M.pulling] inside would be a very bad idea.</span>")
				return
			if(ishuman(M.pulling))
				to_chat(M, "<span class='debuginfo'>M.pulling is human</span>")
				var/mob/living/carbon/human/H = M.pulling
				var/obj/item/card/id/I = H.wear_id
				if(I && I.rank == "Tank Crewman" && !tank_crewman_entered)
					new_tank_crewman_entered = TRUE
					to_chat(M, "<span class='debuginfo'>pulling tank crewman.</span>")
				else
					if(I && I.rank == module_role && !module_role_entered)
						new_module_role_entered = TRUE
						to_chat(M, "<span class='debuginfo'>pulling [module_role].</span>")
					else
						to_chat(M, "<span class='debuginfo'>pulling general human.</span>")
						if((passengers + new_passengers + 1) > passengers_max)
							if((passengers + new_passengers) == passengers_max)
								to_chat(M, "<span class='warning'>There is a room only for one of you.</span>")
								return
							to_chat(M, "<span class='warning'>[src] is full.</span>")
							return
						else
							new_passengers++
							to_chat(M, "<span class='debuginfo'>new passengers = [new_passengers].</span>")
			else
				if((passengers + new_passengers + 1) > passengers_max)
					if((passengers + new_passengers) == passengers_max)
						to_chat(M, "<span class='warning'>There is a room only for one of you.</span>")
						return
					to_chat(M, "<span class='warning'>[src] is full.</span>")
					return
				else
					new_passengers++
		if(isobj(M.pulling))
			if((istype(M.pulling, /obj/structure) && !istype(M.pulling, /obj/structure/mortar) && !istype(M.pulling, /obj/structure/closet/bodybag) && !istype(M.pulling, /obj/structure/closet/crate)) || (istype(M.pulling, /obj/machinery) && !istype(M.pulling, /obj/machinery/m56d_post) && !istype(M.pulling, /obj/machinery/m56d_hmg)))
				to_chat(M, "<span class='warning'>You can't fit the [M.pulling] through a doorway!</span>")
				return
			to_chat(M, "<span class='debuginfo'>M.pulling is object.</span>")
			var/obj/O = M.pulling
			if(istype(O, /obj/structure/closet/bodybag))
				to_chat(M, "<span class='debuginfo'>pulling bodybag.</span>")
				for(var/mob/living/B in O.contents)
					if(ishuman(B))
						to_chat(M, "<span class='debuginfo'>contains human.</span>")
						var/mob/living/carbon/human/H = B
						var/obj/item/card/id/I = H.wear_id
						if(I && I.rank == "Tank Crewman" && !tank_crewman_entered)
							new_tank_crewman_entered = TRUE
						else
							if(I && I.rank == module_role && !module_role_entered)
								new_module_role_entered = TRUE
							else
								if((passengers + new_passengers + 1) > passengers_max)
									if((passengers + new_passengers) == passengers_max)
										to_chat(M, "<span class='warning'>There is a room only for one of you.</span>")
										return
									to_chat(M, "<span class='warning'>[src] is full.</span>")
									return
								else
									new_passengers++
					else
						if(!isXeno(B))
							if((passengers + new_passengers + 1) > passengers_max)
								if((passengers + new_passengers) == passengers_max)
									to_chat(M, "<span class='warning'>There is a room only for one of you.</span>")
									return
								to_chat(M, "<span class='warning'>[src] is full.</span>")
								return
							else
								new_passengers++
			if(O.buckled_mob)
				to_chat(M, "<span class='warning'>You can't fit [O.buckled_mob] on the [O] through a doorway! Try unbuckling [M.pulling] first.</span>")
				return

	interior_side_door.side_door_busy = TRUE
	visible_message(M, "<span class='notice'>[M] starts climbing into [src].</span>",
		"<span class='notice'>You start climbing into [src].</span>")
	if(!do_after(M, 20, needhand = FALSE, show_busy_icon = TRUE))
		to_chat(M, "<span class='notice'>Something interrupted you while getting in.</span>")
		interior_side_door.side_door_busy = FALSE
		return

	if(M.lying || M.buckled || M.anchored)
		interior_side_door.side_door_busy = FALSE
		return

	if(M.loc != entrance.loc)
		to_chat(M, "<span class='notice'>You stop getting in.</span>")
		interior_side_door.side_door_busy = FALSE
		return

	if(move_pulling)
		if(isliving(M.pulling))
			var/mob/living/P = M.pulling
			P.forceMove(multitile_interior_exit.loc) //Cannot use forceMove method on pulls! Move manually
			M.forceMove(multitile_interior_exit.loc)
			M.start_pulling(P)
		else
			var/obj/O = M.pulling
			O.forceMove(multitile_interior_exit.loc)
			M.forceMove(multitile_interior_exit.loc)
			M.start_pulling(O)
	else
		M.forceMove(multitile_interior_exit.loc)

	if(new_module_role_entered)
		module_role_entered = TRUE
	if(new_tank_crewman_entered)
		tank_crewman_entered = TRUE
	passengers += new_passengers

	visible_message(M, "<span class='notice'>[M] climbs into [src].</span>",
		"<span class='notice'>You climb into [src].</span>")
	interior_side_door.side_door_busy = FALSE

	return

/obj/vehicle/multitile/root/cm_transport/apc/proc/choose_module(var/mob/user)

	special_module_type = 10
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/I = H.wear_id
		if(!istype(I) || I.registered_name != H.real_name || I.rank != "Tank Crewman")
			to_chat(H, "<span class='warning'>[src] door is locked. You need a Tank Crewman to unlock it.</span>")
			special_module_type = null
			return
		else
			if(free_modules != null)
				special_module_type = input("Select APC Modification") in free_modules
				if(user.loc != entrance.loc)
					to_chat(H, "<span class='warning'>You moved away from [src].</span>")
					special_module_type = null
					return

				switch(special_module_type)

					if("Medical Modification")
						name = "M580-M APC"
						camera.network.Add("apc_1")

						interior_area = locate(/area/vehicle_interior/apc_1)
						var/obj/machinery/camera/cam = locate(/obj/machinery/camera/autoname/almayer) in interior_area
						cam.c_tag = camera.c_tag + " Interior Camera"
						cam.network.Add("almayer","apc_1")
						multitile_interior_exit = locate(/obj/effect/landmark/multitile_interior_exit) in interior_area
						multitile_interior_cabin_exit = locate(/obj/effect/landmark/multitile_interior_cabin_exit) in interior_area
						interior_side_door = locate(/obj/structure/vehicle_interior/side_door) in interior_area
						interior_side_door.master = src
						interior_cabin_door = locate(/obj/structure/vehicle_interior/cabin_door) in interior_area
						interior_cabin_door.master = src
						interior_cam = locate(/obj/machinery/camera/autoname/almayer) in interior_area
						passengers_max = 8
						module_role = "Doctor"

						free_modules.Remove("Medical Modification")

					if("Supply Modification")
						name = "M580-S APC"
						camera.network.Add("apc_2")
						interior_area = locate(/area/vehicle_interior/apc_2)
						var/obj/machinery/camera/cam = locate(/obj/machinery/camera/autoname/almayer) in interior_area
						cam.c_tag = camera.c_tag + " Interior Camera"
						cam.network.Add("almayer","apc_2")
						multitile_interior_exit = locate(/obj/effect/landmark/multitile_interior_exit) in interior_area
						multitile_interior_cabin_exit = locate(/obj/effect/landmark/multitile_interior_cabin_exit) in interior_area
						interior_side_door = locate(/obj/structure/vehicle_interior/side_door) in interior_area
						interior_side_door.master = src
						interior_cabin_door = locate(/obj/structure/vehicle_interior/cabin_door) in interior_area
						interior_cabin_door.master = src
						interior_cam = locate(/obj/machinery/camera/autoname/almayer) in interior_area
						var/obj/structure/vehicle_interior/supply_receiver/receiver = locate(/obj/structure/vehicle_interior/supply_receiver) in interior_area
						receiver.master = src
						var/turf/T = locate(159, 61, 3)
						var/obj/machinery/vehicle_interior/supply_sender_control/button = locate(/obj/machinery/vehicle_interior/supply_sender_control) in T.contents
						button.destination = receiver
						T = locate(3, 62, 160)
						var/obj/structure/vehicle_interior/supply_sender/sender = locate(/obj/structure/vehicle_interior/supply_sender) in range(button, 1)
						button.master = sender
						passengers_max = 10
						module_role = "Cargo Technician"

						free_modules.Remove("Supply Modification")

					if("Command Modification")
						name = "M580-C APC"
						camera.network.Add("apc_3")

						interior_area = locate(/area/vehicle_interior/apc_3)
						var/obj/machinery/camera/cam = locate(/obj/machinery/camera/autoname/almayer) in interior_area
						cam.c_tag = camera.c_tag + " Interior Camera"
						cam.network.Add("almayer","apc_3")
						multitile_interior_exit = locate(/obj/effect/landmark/multitile_interior_exit) in interior_area
						multitile_interior_cabin_exit = locate(/obj/effect/landmark/multitile_interior_cabin_exit) in interior_area
						interior_side_door = locate(/obj/structure/vehicle_interior/side_door) in interior_area
						interior_side_door.master = src
						interior_cabin_door = locate(/obj/structure/vehicle_interior/cabin_door) in interior_area
						interior_cabin_door.master = src
						interior_tcomms = locate(/obj/machinery/vehicle_interior/tcomms_receiver) in interior_area
						interior_tcomms.sidekick = locate(/obj/structure/vehicle_interior/tcomms_hub) in interior_area
						interior_tcomms.master = src
						interior_cam = locate(/obj/machinery/camera/autoname/almayer) in interior_area
						switch(map_tag)
							if(MAP_PRISON_STATION)
								var/turf/T = get_turf(locate(232,104,1))
								interior_tcomms.tcomms_sphere = locate(/obj/machinery/telecomms/relay/preset/station/prison) in T.contents
								if(interior_tcomms.tcomms_sphere)
									to_chat(H, "<span class='debuginfo'>relay linked.</span>")
								else
									to_chat(H, "<span class='debuginfo'>error: relay not found.</span>")
							if(MAP_BIG_RED)
								var/turf/T = get_turf(locate(16,202,1))
								interior_tcomms.tcomms_tower = locate(/obj/machinery/telecomms/relay/preset/ice_colony) in T.contents
								if(interior_tcomms.tcomms_tower)
									to_chat(H, "<span class='debuginfo'>relay linked.</span>")
								else
									to_chat(H, "<span class='debuginfo'>error: relay not found.</span>")
							if(MAP_ICE_COLONY)
								var/turf/T = get_turf(locate(18,180,1))
								interior_tcomms.tcomms_tower = locate(/obj/machinery/telecomms/relay/preset/ice_colony) in T.contents
								if(interior_tcomms.tcomms_tower)
									to_chat(H, "<span class='debuginfo'>relay linked.</span>")
								else
									to_chat(H, "<span class='debuginfo'>error: relay not found.</span>")
							if(MAP_LV_624)
								to_chat(user, "<span class='notice'>Area of Operations is covered by Almayer. [src] Telecommunication equipment is disabled for this operation.</span>")
						passengers_max = 12
						module_role = "Staff Officer"

						free_modules.Remove("Command Modification")
				fix_special_module()
			else
				to_chat(user, "<span class='danger'>APC is blocked permanently, because 3 APCs were already spawned and activated. Contact admin to delete this APC.</span>")
				special_module_type = null
				return
	else
		to_chat(user, "<span class='warning'>[src] door is locked, you can't get in!</span>")
		special_module_type = null
		return
	return

/obj/vehicle/multitile/root/cm_transport/apc/attack_alien(var/mob/living/carbon/Xenomorph/M)

	..()

	if(M.loc == entrance.loc)
		if(!special_module_working)
			handle_xeno_entrance(M)
			return

/obj/vehicle/multitile/root/cm_transport/apc/handle_player_entrance(var/mob/M)

	var/loc_check = M.loc

	var/slot
	if(!M.mind || !(!M.mind.cm_skills || M.mind.cm_skills.large_vehicle >= SKILL_LARGE_VEHICLE_TRAINED))
		slot = "Gunner"
	else
		slot = input("Select a seat") in list("Driver", "Gunner")
	if(!M || M.client == null) return

	to_chat(M, "<span class='notice'>You start climbing into cabin.</span>")

	switch(slot)
		if("Driver")

			if(driver != null)
				to_chat(M, "<span class='notice'>That seat is already taken.</span>")
				return

			if(!do_after(M, 30, needhand = FALSE, show_busy_icon = TRUE))
				to_chat(M, "<span class='notice'>Something interrupted you while getting in.</span>")
				return

			if(M.loc != loc_check)
				to_chat(M, "<span class='notice'>You stop getting in.</span>")
				return

			if(driver != null)
				to_chat(M, "<span class='notice'>Someone got into that seat before you could.</span>")
				return
			driver = M
			M.forceMove(src)
			to_chat(M, "<span class='notice'>You enter the driver's seat.</span>")

			M.set_interaction(src)
			return

		if("Gunner")

			if(gunner != null)
				to_chat(M, "<span class='notice'>That seat is already taken.</span>")
				return

			if(!do_after(M, 30, needhand = FALSE, show_busy_icon = TRUE))
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
			M.forceMove(src)
			deactivate_binos(gunner)

			to_chat(M, "<span class='notice'>You enter the gunner's seat.</span>")
			M.set_interaction(src)
			if(M.client)
				M.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")

			return

/obj/vehicle/multitile/root/cm_transport/apc/handle_xeno_entrance(mob/living/carbon/Xenomorph/X)

	if(special_module_type == null)
		to_chat(X, "<span class='xenowarning'>[src] door is locked, you can't get in!</span>")
		return

	if(X.upgrade > 2 || X.tier > 2)
		to_chat(X, "<span class='xenowarning'>[src] door way is too small for you, you can't fit through!</span>")
		return

	if(!X || X.client == null) return

	if(cabin_door_busy)
		to_chat(X, "<span class='xenonotice'>Someone is in the doorway.</span>")
		return

	visible_message(X, "<span class='notice'>[X] starts climbing into [src].</span>",
		"<span class='xenonotice'>You start climbing into [src].</span>")

	cabin_door_busy = TRUE
	if(!do_after(X, 20, needhand = FALSE, show_busy_icon = TRUE))
		to_chat(X, "<span class='xenonotice'>Something interrupted you while getting in.</span>")
		cabin_door_busy = FALSE
		return

	if(X.loc != entrance.loc)
		to_chat(X, "<span class='xenonotice'>You stop getting in.</span>")
		cabin_door_busy = FALSE
		return

	cabin_door_busy = FALSE

	if(!X.lying && !X.buckled && !X.anchored)
		visible_message(X, "<span class='notice'>[X] climbs into [src].</span>",
		"<span class='xenonotice'>You climb into [src].</span>")
		X.forceMove(multitile_interior_exit.loc)


//Deposits you onto the exit marker
//TODO: Sometimes when the entrance marker is on the wall or somewhere you can't move to, it still deposits you there
//Fix that bug at somepoint ^^
/obj/vehicle/multitile/root/cm_transport/apc/handle_player_exit(var/mob/M)

	if(M != gunner && M != driver) return

	if(cabin_door_busy)
		to_chat(M, "<span class='notice'>Someone is already getting out of the vehicle cabin.</span>")
		return

	to_chat(M, "<span class='notice'>You start climbing out of [src] cabin.</span>")

	cabin_door_busy = TRUE
	sleep(30)
	cabin_door_busy = FALSE
	var/turf/T = get_turf(interior_cabin_door)
	T = get_step(T, WEST)

	if(M == gunner)
		deactivate_all_hardpoints()
		if(M.client)
			M.client.mouse_pointer_icon = initial(M.client.mouse_pointer_icon)
		M.forceMove(T)

		gunner = null
	else
		if(M == driver)
			M.forceMove(T)
			driver = null
	M.unset_interaction()
	to_chat(M, "<span class='notice'>You climb out of [src] cabin.</span>")

//No one but the driver can drive
/obj/vehicle/multitile/root/cm_transport/apc/relaymove(var/mob/user, var/direction)
	if(user != driver) return

	. = ..(user, direction)

	if(next_sound_play < world.time)
		playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)
		next_sound_play = world.time + 21

//No one but the driver can turn
/obj/vehicle/multitile/root/cm_transport/apc/try_rotate(var/deg, var/mob/user, var/force = 0)

	if(user != driver) return

	. = ..(deg, user, force)


/obj/vehicle/multitile/root/cm_transport/apc/interior_concussion(var/strength)
	switch(strength)
		if(1)
			playsound(interior_side_door,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			for(var/mob/living/carbon/M in interior_area)
				if(!M.stat)
					shake_camera(M, 10, 1)
					if(!M.buckled && prob(35))
						M.KnockDown(1)
						M.apply_damage(rand(0, 1), BRUTE)
			playsound(src,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			if(gunner)
				shake_camera(gunner, 10, 1)
			if(driver)
				shake_camera(driver, 10, 1)
		if(2)
			playsound(interior_side_door, pick('sound/effects/Explosion2.ogg', 'sound/effects/Explosion1.ogg'), vol = 20, sound_range = 10)
			playsound(interior_side_door,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			for(var/mob/living/carbon/M in interior_area)
				if(!M.stat)
					shake_camera(M, 20, 1)
					if(!M.buckled && prob(65))
						M.KnockDown(2)
					M.apply_damage(rand(0, 2), BRUTE)
					M.apply_damage(rand(0, 2), BURN)
			playsound(src,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			if(gunner)
				var/mob/living/carbon/human/H = gunner
				shake_camera(gunner, 20, 1)
				H.apply_damage(rand(0, 1), BRUTE)
				H.apply_damage(rand(0, 1), BURN)
			if(driver)
				var/mob/living/carbon/human/H = driver
				shake_camera(H, 20, 1)
				H.apply_damage(rand(0, 1), BRUTE)
				H.apply_damage(rand(0, 1), BURN)
		if(3)
			playsound(interior_side_door, pick('sound/effects/Explosion2.ogg', 'sound/effects/Explosion1.ogg'), vol = 20, sound_range = 10)
			playsound(interior_side_door,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			for(var/mob/living/carbon/M in interior_area)
				if(!M.stat)
					shake_camera(M, 30, 1)
					if(!M.buckled && prob(85))
						M.KnockDown(3)
					M.apply_damage(rand(2, 4), BRUTE)
					M.apply_damage(rand(2, 4), BURN)
			playsound(src,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			if(gunner)
				var/mob/living/carbon/human/H = gunner
				shake_camera(gunner, 30, 1)
				H.apply_damage(rand(1, 3), BRUTE)
				H.apply_damage(rand(1, 3), BURN)
			if(driver)
				var/mob/living/carbon/human/H = driver
				shake_camera(driver, 30, 1)
				H.apply_damage(rand(1, 3), BRUTE)
				H.apply_damage(rand(1, 3), BURN)
		if(4)
			playsound(interior_side_door, pick('sound/effects/Explosion2.ogg', 'sound/effects/Explosion1.ogg'), vol = 20, sound_range = 10)
			playsound(interior_side_door,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			for(var/mob/living/carbon/M in interior_area)
				if(!M.stat)
					shake_camera(M, 40, 1)
					if(!M.buckled)
						M.KnockDown(4)
					else
						M.KnockDown(2)
					M.apply_damage(rand(3, 7), BRUTE)
					M.apply_damage(rand(3, 7), BURN)
			playsound(src,'sound/effects/metal_crash.ogg', vol = 20, sound_range = 10)
			if(gunner)
				var/mob/living/carbon/human/H = gunner
				shake_camera(gunner, 40, 1)
				H.apply_damage(rand(2, 6), BRUTE)
				H.apply_damage(rand(2, 6), BURN)
			if(driver)
				var/mob/living/carbon/human/H = driver
				shake_camera(driver, 40, 1)
				H.apply_damage(rand(2, 6), BRUTE)
				H.apply_damage(rand(2, 6), BURN)

/obj/vehicle/multitile/hitbox/cm_transport/apc/Bump(var/atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/M = A
		var/obj/vehicle/multitile/root/cm_transport/apc/T
		log_attack("[T ? T.driver : "Someone"] drove over [M] with [root]")
