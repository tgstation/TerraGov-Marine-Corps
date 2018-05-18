


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

	var/active_hp
	var/occupant_exiting = 0

/obj/effect/multitile_spawner/cm_armored/tank

	width = 4
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

	R.take_damage_type(1000000, "abstract") //OOF.ogg

	R.healthcheck()

	del(src)

//For the tank, start forcing people out if everything is broken
/obj/vehicle/multitile/root/cm_armored/tank/handle_all_modules_broken()

	if(driver)
		driver << "<span class='danger'>You dismount to as the smoke and flames start to choke you!</span>"
		driver.Move(entrance.loc)
		driver = null
	else if(gunner)
		gunner << "<span class='danger'>You dismount to as the smoke and flames start to choke you!</span>"
		gunner.Move(entrance.loc)
		gunner = null

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

//Used by the gunner to swap which module they are using
//e.g. from the minigun to the smoke launcher
//Only the active hardpoint module can be used
/obj/vehicle/multitile/root/cm_armored/tank/verb/switch_active_hp()
	set name = "Change Active Weapon"
	set category = "Object"
	set src in view(0)

	if(usr != gunner) return

	var/list/slots = list()
	for(var/slot in hardpoints)
		var/obj/item/hardpoint/HP = hardpoints[slot]
		if(!HP) continue
		if(HP.health <= 0) continue
		if(!HP.is_activatable) continue
		slots += slot

	if(!slots.len)
		usr << "<span class='warning'>All of the modules can't be activated or are broken.</span>"
		return

	var/slot = input("Select a slot.") in slots

	var/obj/item/hardpoint/HP = hardpoints[slot]
	if(!HP)
		usr << "<span class='warning'>There's nothing installed on that hardpoint.</span>"

	active_hp = slot

//Two seats, gunner and driver
//Must have the skills to do so
/obj/vehicle/multitile/root/cm_armored/tank/handle_player_entrance(var/mob/M)

	var/slot = input("Select a seat") in list("Driver", "Gunner")

	if(!M || M.client == null) return

	if(!M.mind || !(!M.mind.cm_skills || M.mind.cm_skills.large_vehicle >= SKILL_LARGE_VEHICLE_TRAINED))
		M << "<span class='notice'>You have no idea how to operate this thing.</span>"
		return

	M << "<span class='notice'>You start climbing into [src].</span>"

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
		if(M == gunner) gunner = null
		else if(M == driver) driver = null
		M.unset_interaction()
		M << "<span class='notice'>You climb out of [src].</span>"

//No one but the driver can drive
/obj/vehicle/multitile/root/cm_armored/tank/relaymove(var/mob/user, var/direction)
	if(user != driver) return

	. = ..(user, direction)

//No one but the driver can turn
/obj/vehicle/multitile/root/cm_armored/tank/try_rotate(var/deg, var/mob/user)

	if(user != driver) return

	. = ..(deg, user)

//No one but the gunner can gun
//And other checks to make sure you aren't breaking the law
/obj/vehicle/multitile/root/cm_armored/tank/handle_click(var/mob/living/user, var/atom/A, var/list/mods)

	if(user != gunner)
		return

	if(!hardpoints.Find(active_hp))
		user << "<span class='warning'>Please select an active hardpoint first.</span>"
		return

	var/obj/item/hardpoint/HP = hardpoints[active_hp]

	if(!HP)
		return

	if(!HP.is_ready())
		user << "<span class='warning'>That module is not ready to fire.</span>"
		return

	if(A.z == 3)
		user << "<span class='warning'>Don't fire while on the ship!</span>"
		return

	if(dir != get_cardinal_dir2(src, A))
		return

	HP.active_effect(get_turf(A))


/obj/vehicle/multitile/hitbox/cm_armored/tank/Bump(var/atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/M = A
		var/obj/vehicle/multitile/root/cm_armored/tank/T
		log_attack("[T ? T.driver : "Someone"] drove over [M] with [root]")