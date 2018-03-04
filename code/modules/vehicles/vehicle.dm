/obj/vehicle
	name = "vehicle"
	icon = 'icons/obj/vehicles.dmi'
	layer = ABOVE_MOB_LAYER //so it sits above objects including mobs
	density = 1
	anchored = 1
	animate_movement = 1
	luminosity = 2
	can_buckle = TRUE

	var/attack_log = null
	var/on = 0
	var/health = 100
	var/maxhealth = 100
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0	//Maint panel
	var/locked = 1
	var/stat = 0
	var/emagged = 0
	var/powered = 0		//set if vehicle is powered and should use fuel when moving
	var/move_delay = 1	//set this to limit the speed of the vehicle
	var/buckling_y = 0

	var/obj/item/cell/cell
	var/charge_use = 5	//set this to adjust the amount of power the vehicle uses per move

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/New()
	..()
	//spawn the cell you want in each vehicle

/obj/vehicle/relaymove(mob/user, direction)
	if(user.is_mob_incapacitated()) return
	if(world.time > l_move_time + move_delay)
		if(on && powered && cell && cell.charge < charge_use)
			turn_off()
		else if(!on && powered)
			user << "<span class='warning'>Turn on the engine first.</span>"
		else
			. = step(src, direction)

/obj/vehicle/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/tool/screwdriver))
		if(!locked)
			open = !open
			update_icon()
			user << "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>"
	else if(istype(W, /obj/item/tool/crowbar) && cell && open)
		remove_cell(user)

	else if(istype(W, /obj/item/cell) && !cell && open)
		insert_cell(W, user)
	else if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/WT = W
		if(WT.remove_fuel(1, user))
			if(health < maxhealth)
				user.visible_message("<span class='notice'>[user] starts to repair [src].</span>","<span class='notice'>You start to repair [src]</span>")
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_FRIENDLY))
					if(!src || !WT.isOn())
						return
					health = min(maxhealth, health+10)
					user.visible_message("<span class='notice'>[user] repairs [src].</span>","<span class='notice'>You repair [src].</span>")
			else
				user << "<span class='notice'>[src] does not need repairs.</span>"

	else if(W.force)
		switch(W.damtype)
			if("fire")
				health -= W.force * fire_dam_coeff
			if("brute")
				health -= W.force * brute_dam_coeff
		playsound(src.loc, "smash.ogg", 25, 1)
		user.visible_message("<span class='danger'>[user] hits [src] with [W].</span>","<span class='danger'>You hit [src] with [W].</span>")
		healthcheck()
	else
		..()

/obj/vehicle/attack_animal(var/mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)	return
	health -= M.melee_damage_upper
	src.visible_message("\red <B>[M] has [M.attacktext] [src]!</B>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/vehicle/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return 1

/obj/vehicle/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
			return
		if(2.0)
			health -= rand(5,10)*fire_dam_coeff
			health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				health -= rand(1,5)*fire_dam_coeff
				health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/vehicle/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	new /obj/effect/overlay/temp/emp_sparks (loc)
	if(on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if(was_on)
			turn_on()

/obj/vehicle/attack_ai(mob/user as mob)
	return

//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/proc/turn_on()
	if(stat)
		return 0
	if(powered && cell.charge < charge_use)
		return 0
	on = 1
	SetLuminosity(initial(luminosity))
	update_icon()
	return 1

/obj/vehicle/proc/turn_off()
	on = 0
	SetLuminosity(0)
	update_icon()

/obj/vehicle/proc/Emag(mob/user as mob)
	emagged = 1

	if(locked)
		locked = 0
		user << "<span class='warning'>You bypass [src]'s controls.</span>"

/obj/vehicle/proc/explode()
	src.visible_message("\red <B>[src] blows apart!</B>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)

	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	if(buckled_mob)
		buckled_mob.apply_effects(5, 5)
		unbuckle()

	new /obj/effect/spawner/gibspawner/robot(Tsec)
	new /obj/effect/decal/cleanable/blood/oil(src.loc)

	cdel(src)

/obj/vehicle/proc/healthcheck()
	if(health <= 0)
		explode()

/obj/vehicle/proc/powercheck()
	if(!cell && !powered)
		return

	if(!cell && powered)
		turn_off()
		return

	if(cell.charge < charge_use)
		turn_off()
		return

	if(cell && powered)
		turn_on()
		return

/obj/vehicle/proc/insert_cell(var/obj/item/cell/C, var/mob/living/carbon/human/H)
	if(cell)
		return
	if(!istype(C))
		return

	H.drop_inv_item_to_loc(C, src)
	cell = C
	powercheck()
	usr << "<span class='notice'>You install [C] in [src].</span>"

/obj/vehicle/proc/remove_cell(var/mob/living/carbon/human/H)
	if(!cell)
		return

	usr << "<span class='notice'>You remove [cell] from [src].</span>"
	cell.forceMove(get_turf(H))
	H.put_in_hands(cell)
	cell = null
	powercheck()

/obj/vehicle/proc/RunOver(var/mob/living/carbon/human/H)
	return		//write specifics for different vehicles


/obj/vehicle/afterbuckle(mob/M)
	. = ..()
	if(. && buckled_mob == M)
		M.pixel_y = buckling_y
		M.old_y = buckling_y
	else
		M.pixel_x = initial(buckled_mob.pixel_x)
		M.pixel_y = initial(buckled_mob.pixel_y)
		M.old_y = initial(buckled_mob.pixel_y)

/obj/vehicle/Dispose()
	SetLuminosity(0)
	. = ..()

//-------------------------------------------------------
// Stat update procs
//-------------------------------------------------------
/obj/vehicle/proc/update_stats()
	return
