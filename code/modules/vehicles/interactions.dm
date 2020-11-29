/obj/vehicle/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/cell) && !cell && open)
		insert_cell(I, user)

	else if(I.force)
		switch(I.damtype)
			if("fire")
				take_damage(I.force * fire_dam_coeff)
			if("brute")
				take_damage(I.force * brute_dam_coeff)
		playsound(loc, "smash.ogg", 25, TRUE)
		user.visible_message("<span class='danger'>[user] hits [src] with [I].</span>","<span class='danger'>You hit [src] with [I].</span>")

/obj/vehicle/welder_act(mob/living/user, obj/item/I)
	. = ..()
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

/obj/vehicle/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(locked)
		return

	open = !open
	update_icon()
	to_chat(user, "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>")

/obj/vehicle/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(cell && open)
		remove_cell(user)
