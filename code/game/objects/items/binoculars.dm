/obj/item/binoculars

	name = "binoculars"
	desc = "A pair of binoculars."
	icon_state = "binoculars"

	flags_atom = CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3

	//matter = list("metal" = 50,"glass" = 50)

/obj/item/binoculars/attack_self(mob/user)
	zoom(user, 11, 12)


/obj/item/binoculars/tactical
	name = "tactical binoculars"
	desc = "A pair of binoculars, with a laser targeting function. Ctrl+Click to target something."
	var/laser_cooldown = 0
	var/cooldown_duration = 200 //20 seconds
	var/obj/effect/overlay/temp/laser_target/laser
	var/obj/effect/overlay/temp/laser_coordinate/coord
	var/target_acquisition_delay = 100 //10 seconds
	var/mode = 0 //Able to be switched between modes, 0 for cas laser, 1 for finding coordinates.
	var/changable = 1 //If set to 0, you can't toggle the mode between CAS and coordinate finding

/obj/item/binoculars/tactical/New()
	..()
	update_icon()

/obj/item/binoculars/tactical/examine()
	..()
	to_chat(usr, "<span class='notice'>They are currently set to [mode ? "range finder" : "CAS marking"] mode.</span>")

/obj/item/binoculars/tactical/Destroy()
	if(laser)
		qdel(laser)
		laser = null
	if(coord)
		qdel(coord)
		coord = null
	. = ..()


/obj/item/binoculars/tactical/attack_self(mob/user)
	. = ..()
	if(!user?.client)
		return
	user.client.click_intercept = src


/obj/item/binoculars/tactical/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if(!pa.Find("ctrl"))
		return FALSE
	acquire_target(object, user)
	return TRUE


/obj/item/binoculars/tactical/on_unset_interaction(mob/user)
	. = ..()

	if(!user?.client)
		return

	user.client.click_intercept = null

	if(zoom)
		return
	if(laser)
		qdel(laser)
	if(coord)
		qdel(coord)


/obj/item/binoculars/tactical/update_icon()
	..()
	if(mode)
		overlays += "binoculars_range"
	else
		overlays += "binoculars_laser"

/obj/item/binoculars/tactical/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Laser Mode"
	var/mob/living/user
	if(isliving(loc))
		user = loc
	else
		return

	if(!changable)
		to_chat(user, "These binoculars only have one mode.")
		return

	if(!zoom)
		mode = !mode
		to_chat(user, "<span class='notice'>You switch [src] to [mode? "range finder" : "CAS marking" ] mode.</span>")
		update_icon()
		playsound(usr, 'sound/machines/click.ogg', 15, 1)

/obj/item/binoculars/tactical/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(laser || coord)
		to_chat(user, "<span class='warning'>You're already targeting something.</span>")
		return

	if(world.time < laser_cooldown)
		to_chat(user, "<span class='warning'>[src]'s laser battery is recharging.</span>")
		return

	if(!user.mind)
		return

	var/acquisition_time = target_acquisition_delay
	if(user.mind.cm_skills)
		acquisition_time = max(15, acquisition_time - 25*user.mind.cm_skills.leadership)

	var/datum/squad/S = user.assigned_squad

	var/laz_name = ""
	laz_name += user.get_paygrade()
	laz_name += user.name
	if(S)
		laz_name += " ([S.name])"


	var/turf/TU = get_turf(A)
	var/area/targ_area = get_area(A)
	if(!istype(TU))
		return
	var/is_outside = FALSE
	if(is_ground_level(TU.z))
		switch(targ_area.ceiling)
			if(CEILING_NONE)
				is_outside = TRUE
			if(CEILING_GLASS)
				is_outside = TRUE
	if(!is_outside)
		to_chat(user, "<span class='warning'>INVALID TARGET: target must be visible from high altitude.</span>")
		return
	if(user.action_busy)
		return
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	to_chat(user, "<span class='notice'>INITIATING LASER TARGETING. Stand still.</span>")
	if(!do_after(user, acquisition_time, TRUE, TU, BUSY_ICON_GENERIC) || world.time < laser_cooldown || laser)
		return
	if(mode)
		var/obj/effect/overlay/temp/laser_coordinate/LT = new (TU, laz_name, S)
		coord = LT
		to_chat(user, "<span class='notice'>SIMPLIFIED COORDINATES OF TARGET. LONGITUDE [coord.x]. LATITUDE [coord.y].</span>")
		playsound(src, 'sound/effects/binoctarget.ogg', 35)
		while(coord)
			if(!do_after(user, 50, TRUE, coord, BUSY_ICON_GENERIC))
				QDEL_NULL(coord)
				break
	else
		to_chat(user, "<span class='notice'>TARGET ACQUIRED. LASER TARGETING IS ONLINE. DON'T MOVE.</span>")
		var/obj/effect/overlay/temp/laser_target/LT = new (TU, laz_name, S)
		laser = LT
		playsound(src, 'sound/effects/binoctarget.ogg', 35)
		while(laser)
			if(!do_after(user, 50, TRUE, laser, BUSY_ICON_GENERIC))
				QDEL_NULL(laser)
				break


/obj/item/binoculars/tactical/scout
	name = "scout tactical binoculars"
	desc = "A modified version of tactical binoculars with an advanced laser targeting function. Ctrl+Click to target something."
	cooldown_duration = 80
	target_acquisition_delay = 30

//For events
/obj/item/binoculars/tactical/range
	name = "range-finder"
	desc = "A pair of binoculars designed to find coordinates."
	changable = 0
	mode = 1