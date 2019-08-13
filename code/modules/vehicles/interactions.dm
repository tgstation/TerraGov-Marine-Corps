/obj/vehicle/tank/attackby(obj/item/I, mob/user) //This handles reloading weapons, or changing what kind of mags they'll accept. You can have a passenger do this
	. = ..()
	if(user.loc == src) //Stops safe healing
		to_chat(user, "<span class='warning'>You can't reach [src]'s hardpoints while youre seated in it.</span>")
		return

	if(is_type_in_list(I, primary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.mind.cm_skills.large_vehicle)
		to_chat(user, "You start to swap out [primary_weapon]'s magazine...")
		if(do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			playsound(get_turf(src), 'sound/weapons/working_the_bolt.ogg', 100, 1)
			primary_weapon.ammo.forceMove(get_turf(user))
			primary_weapon.ammo = I
			to_chat(user, "You load [I] into [primary_weapon] with a satisfying click.")
			user.transferItemToLoc(I,src)
		return

	if(is_type_in_list(I, secondary_weapon?.accepted_ammo))
		var/mob/living/M = user
		var/time = 8 SECONDS - (1 SECONDS * M.mind.cm_skills.large_vehicle)
		to_chat(user, "You start to swap out [secondary_weapon]'s magazine...")
		if(do_after(M, time, TRUE, src, BUSY_ICON_BUILD))
			playsound(get_turf(src), 'sound/weapons/working_the_bolt.ogg', 100, 1)
			secondary_weapon.ammo.forceMove(get_turf(user))
			secondary_weapon.ammo = I
			to_chat(user, "You load [I] into [secondary_weapon] with a satisfying click.")
			user.transferItemToLoc(I,src)
		return

/obj/vehicle/tank/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(!iswelder(I)) //Weld to repair the tank
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>You can't see any visible dents on [src].</span>")
		return
	var/obj/item/tool/weldingtool/WT = I
	if(!WT.isOn())
		to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts repairing [src].</span>",
	"<span class='notice'>You start repairing [src].</span>")
	if(!do_after(user, 20 SECONDS, TRUE, src, BUSY_ICON_BUILD, extra_checks = iswelder(I) ? CALLBACK(I, /obj/item/tool/weldingtool/proc/isOn) : null))
		return

	WT.remove_fuel(3, user) //3 Welding fuel to repair the tank. To repair a small tank, it'd take 4 goes AKA 12 welder fuel and 1 minute
	obj_integrity += 100
	if(obj_integrity > max_integrity)
		obj_integrity = max_integrity //Prevent overheal

	user.visible_message("<span class='notice'>[user] welds out a few of the dents on [src].</span>",
	"<span class='notice'>You weld out a few of the dents on [src].</span>")
	update_icon() //Check damage overlays

/obj/vehicle/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(locked)
			return

		open = !open
		update_icon()
		to_chat(user, "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>")

	else if(iscrowbar(I) && cell && open)
		remove_cell(user)

	else if(istype(I, /obj/item/cell) && !cell && open)
		insert_cell(I, user)

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!WT.remove_fuel(1, user))
			return

		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
			return

		user.visible_message("<span class='notice'>[user] starts to repair [src].</span>","<span class='notice'>You start to repair [src]</span>")
		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
			return

		obj_integrity = min(max_integrity, obj_integrity + 10)
		user.visible_message("<span class='notice'>[user] repairs [src].</span>","<span class='notice'>You repair [src].</span>")

	else if(I.force)
		switch(I.damtype)
			if("fire")
				take_damage(I.force * fire_dam_coeff)
			if("brute")
				take_damage(I.force * brute_dam_coeff)
		playsound(loc, "smash.ogg", 25, 1)
		user.visible_message("<span class='danger'>[user] hits [src] with [I].</span>","<span class='danger'>You hit [src] with [I].</span>")
		healthcheck()