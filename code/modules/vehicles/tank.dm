


//TANKS, HURRAY
//Read the documentation in cm_armored.dm and multitile.dm before trying to decipher this stuff


/obj/vehicle/multitile/root/cm_armored/tank
	name = "M34A2 Longstreet Light Tank"
	desc = "A giant piece of armor with a big gun, you know what to do. Entrance in the back."

	icon = 'icons/obj/tank_NS.dmi'
	icon_state = "tank_base"
	pixel_x = -32
	pixel_y = -32

	var/mob/gunner
	var/mob/driver

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
	R.add_hardpoint(new /obj/item/hardpoint/primary/cannon, R.hardpoints[HDPT_PRIMARY])
	R.add_hardpoint(new /obj/item/hardpoint/secondary/m56cupola, R.hardpoints[HDPT_SECDGUN])
	R.add_hardpoint(new /obj/item/hardpoint/support/smoke_launcher, R.hardpoints[HDPT_SUPPORT])
	R.add_hardpoint(new /obj/item/hardpoint/armor/ballistic, R.hardpoints[HDPT_ARMOR])
	R.add_hardpoint(new /obj/item/hardpoint/treads/standard, R.hardpoints[HDPT_TREADS])
	R.update_damage_distribs()

	R.take_damage_type(1e8, "abstract") //OOF.ogg

	R.healthcheck()

	del(src)

//For the tank, start forcing people out if everything is broken
/obj/vehicle/multitile/root/cm_armored/tank/handle_all_modules_broken()
	deactivate_all_hardpoints()

	if(driver)
		driver << "<span class='danger'>You dismount to as the smoke and flames start to choke you!</span>"
		driver.Move(entrance.loc)
		driver.unset_interaction()
		driver = null
	else if(gunner)
		gunner << "<span class='danger'>You dismount to as the smoke and flames start to choke you!</span>"
		gunner.Move(entrance.loc)
		gunner.unset_interaction()
		gunner = null

/obj/vehicle/multitile/root/cm_armored/tank/remove_all_players()
	deactivate_all_hardpoints()
	if(!entrance) //Something broke, uh oh
		if(gunner) gunner.loc = src.loc
		if(driver) driver.loc = src.loc
	else
		if(gunner) gunner.forceMove(entrance.loc)
		if(driver) driver.forceMove(entrance.loc)

	gunner = null
	driver = null

//Let's you switch into the other seat, doesn't work if it's occupied
/obj/vehicle/multitile/root/cm_armored/tank/verb/switch_seats()
	set name = "Swap Seats"
	set category = "Object"
	set src in view(0)

	//A little icky, but functional
	//Using a list of mobs for driver and gunner might make this code look better
	//But all of the other code about those two would look like shit
	if(usr == gunner)
		if(driver)
			usr << "<span class='notice'>There's already someone in the other seat.</span>"
			return

		usr << "<span class='notice'>You start getting into the other seat.</span>"

		sleep(30)

		if(driver)
			usr << "<span class='notice'>Someone beat you to the other seat!</span>"
			return

		usr << "<span class='notice'>You switch seats.</span>"

		deactivate_all_hardpoints()

		driver = gunner
		gunner = null

	else if(usr == driver)
		if(gunner)
			usr << "<span class='notice'>There's already someone in the other seat.</span>"
			return

		usr << "<span class='notice'>You start getting into the other seat.</span>"

		sleep(30)

		if(gunner)
			usr << "<span class='notice'>Someone beat you to the other seat!</span>"
			return

		usr << "<span class='notice'>You switch seats.</span>"

		gunner = driver
		driver = null

/obj/vehicle/multitile/root/cm_armored/tank/can_use_hp(var/mob/M)
	return (M == gunner)

/obj/vehicle/multitile/root/cm_armored/tank/handle_harm_attack(var/mob/M)

	if(M.loc != entrance.loc)	return

	if(!gunner && !driver)
		M << "<span class='warning'>There is no one in the vehicle.</span>"
		return

	M << "<span class='notice'>You start pulling [driver ? driver : gunner] out of their seat.</span>"

	if(!do_after(M, 200, show_busy_icon = BUSY_ICON_HOSTILE))
		M << "<span class='warning'>You stop pulling [driver ? driver : gunner] out of their seat.</span>"
		return

	if(M.loc != entrance.loc) return

	if(!gunner && !driver)
		M << "<span class='warning'>There is no longer anyone in the vehicle.</span>"
		return

	M.visible_message("<span class='warning'>[M] pulls [driver ? driver : gunner] out of their seat in [src].</span>",
		"<span class='notice'>You pull [driver ? driver : gunner] out of their seat.</span>")

	var/mob/targ
	if(driver)
		targ = driver
		driver = null
	else
		targ = gunner
		gunner = null
	targ << "<span class='danger'>[M] forcibly drags you out of your seat and dumps you on the ground!</span>"
	targ.forceMove(entrance.loc)
	targ.unset_interaction()
	targ.KnockDown(7, 1)


//Two seats, gunner and driver
//Must have the skills to do so
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_entrance(var/mob/M)

	var/slot = input("Select a seat") in list("Driver", "Gunner")

	if(!M || M.client == null) return

	if(!M.mind || !(!M.mind.cm_skills || M.mind.cm_skills.large_vehicle >= SKILL_LARGE_VEHICLE_TRAINED))
		M << "<span class='notice'>You have no idea how to operate this thing.</span>"
		return

	M << "<span class='notice'>You start climbing into [src].</span>"
	for(var/obj/item/I in M.contents)
		if(I.zoom)
			I.zoom() // cancel zoom.
	switch(slot)
		if("Driver")

			if(driver != null)
				M << "<span class='notice'>That seat is already taken.</span>"
				return

			if(!do_after(M, 100, needhand = FALSE, show_busy_icon = TRUE))
				M << "<span class='notice'>Something interrupted you while getting in.</span>"
				return

			if(M.loc != entrance.loc)
				M << "<span class='notice'>You stop getting in.</span>"
				return

			if(driver != null)
				M << "<span class='notice'>Someone got into that seat before you could.</span>"
				return
			for(var/obj/item/I in M.contents)
				if(I.zoom)
					I.zoom() // cancel zoom.
			driver = M
			M.loc = src
			M << "<span class='notice'>You enter the driver's seat.</span>"
			M.set_interaction(src)
			return

		if("Gunner")

			if(gunner != null)
				M << "<span class='notice'>That seat is already taken.</span>"
				return

			if(!do_after(M, 100, needhand = FALSE, show_busy_icon = TRUE))
				M << "<span class='notice'>Something interrupted you while getting in.</span>"
				return

			if(M.loc != entrance.loc)
				M << "<span class='notice'>You stop getting in.</span>"
				return

			if(gunner != null)
				M << "<span class='notice'>Someone got into that seat before you could.</span>"
				return

			if(!M.client) return //Disconnected while getting in
			for(var/obj/item/I in M.contents)
				if(I.zoom)
					I.zoom() // cancel zoom.
			gunner = M
			M.loc = src
			M << "<span class='notice'>You enter the gunner's seat.</span>"
			M.set_interaction(src)

			return

//Deposits you onto the exit marker
//TODO: Sometimes when the entrance marker is on the wall or somewhere you can't move to, it still deposits you there
//Fix that bug at somepoint ^^
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_exit(var/mob/M)

	if(M != gunner && M != driver) return

	if(occupant_exiting)
		M << "<span class='notice'>Someone is already getting out of the vehicle.</span>"
		return

	M << "<span class='notice'>You start climbing out of [src].</span>"

	occupant_exiting = 1
	sleep(50)
	occupant_exiting = 0

	if(!M.Move(entrance.loc))
		M << "<span class='notice'>Something is blocking you from exiting.</span>"
	else
		if(M == gunner)
			deactivate_all_hardpoints()
			gunner = null
		else if(M == driver) driver = null
		M.unset_interaction()
		M << "<span class='notice'>You climb out of [src].</span>"

//No one but the driver can drive
/obj/vehicle/multitile/root/cm_armored/tank/relaymove(var/mob/user, var/direction)
	if(user != driver) return

	. = ..(user, direction)

	//Someone remind me to fix this fucking snow code --MadSnailDisease
	//The check is made here since the snowplow won't fit on the APC
	if(. && istype(hardpoints[HDPT_ARMOR], /obj/item/hardpoint/armor/snowplow) && direction == dir)
		var/obj/item/hardpoint/armor/snowplow/SP = hardpoints[HDPT_ARMOR]
		if(SP.health > 0)
			for(var/datum/coords/C in linked_objs)
				var/turf/T = locate(src.x + C.x_pos, src.y + C.y_pos, src.z + C.z_pos)
				if(!istype(T, /turf/open/snow)) continue
				var/turf/open/snow/ST = T
				if(!ST || !ST.slayer)
					continue
				new /obj/item/stack/snow(ST, ST.slayer)
				ST.slayer = 0
				ST.update_icon(1, 0)

	if(next_sound_play < world.time)
		playsound(src, 'sound/ambience/tank_driving.ogg', vol = 20, sound_range = 30)
		next_sound_play = world.time + 21

//No one but the driver can turn
/obj/vehicle/multitile/root/cm_armored/tank/try_rotate(var/deg, var/mob/user, var/force = 0)

	if(user != driver) return

	. = ..(deg, user, force)

	if(. && istype(hardpoints[HDPT_SUPPORT], /obj/item/hardpoint/support/artillery_module) && gunner && gunner.client)
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