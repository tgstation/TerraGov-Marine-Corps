/obj/item/device/binoculars

	name = "binoculars"
	desc = "A pair of binoculars."
	icon_state = "binoculars"

	flags_atom = FPRINT|CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3

	//matter = list("metal" = 50,"glass" = 50)

/obj/item/device/binoculars/attack_self(mob/user)
	zoom(user, 11, 12)

/obj/item/device/binoculars/on_set_interaction(var/mob/user)
	flags_atom |= RELAY_CLICK


/obj/item/device/binoculars/on_unset_interaction(var/mob/user)
	flags_atom &= ~RELAY_CLICK

/obj/item/device/binoculars/tactical
	name = "tactical binoculars"
	desc = "A pair of binoculars, with a laser targeting function. Ctrl+Click to target something."
	var/laser_cooldown = 0
	var/cooldown_duration = 200 //20 seconds
	var/obj/effect/overlay/temp/laser_target/laser
	var/obj/effect/overlay/temp/laser_coordinate/coord
	var/target_acquisition_delay = 100 //10 seconds
	var/mode = 0 //Able to be switched between modes, 0 for cas laser, 1 for finding coordinates.
	var/changable = 1 //If set to 0, you can't toggle the mode between CAS and coordinate finding

/obj/item/device/binoculars/tactical/New()
	..()
	update_icon()

/obj/item/device/binoculars/tactical/examine()
	..()
	usr << "<span class='notice'>They are currently set to [mode ? "range finder" : "CAS marking"] mode.</span>"

/obj/item/device/binoculars/tactical/Dispose()
	if(laser)
		cdel(laser)
		laser = null
	if(coord)
		cdel(coord)
		coord = null
	. = ..()

/obj/item/device/binoculars/tactical/on_unset_interaction(var/mob/user)
	..()

	if (user && (laser || coord))
		if (!zoom)
			if(laser)
				cdel(laser)
			if(coord)
				cdel(coord)

/obj/item/device/binoculars/tactical/update_icon()
	..()
	if(mode)
		overlays += "binoculars_range"
	else
		overlays += "binoculars_laser"

/obj/item/device/binoculars/tactical/handle_click(var/mob/living/user, var/atom/A, var/list/mods)
	if (mods["ctrl"])
		acquire_target(A, user)
		return 1
	return 0

/obj/item/device/binoculars/tactical/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Laser Mode"
	var/mob/living/user
	if(isliving(loc))
		user = loc
	else
		return

	if(!changable)
		user << "These binoculars only have one mode."
		return

	if(!zoom)
		mode = !mode
		user << "<span class='notice'>You switch [src] to [mode? "range finder" : "CAS marking" ] mode.</span>"
		update_icon()
		playsound(usr, 'sound/machines/click.ogg', 15, 1)

/obj/item/device/binoculars/tactical/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(laser || coord)
		user << "<span class='warning'>You're already targeting something.</span>"
		return

	if(world.time < laser_cooldown)
		user << "<span class='warning'>[src]'s laser battery is recharging.</span>"
		return

	if(!user.mind)
		return

	var/acquisition_time = target_acquisition_delay
	if(user.mind.cm_skills)
		acquisition_time = max(15, acquisition_time - 25*user.mind.cm_skills.leadership)

	var/datum/squad/S = user.assigned_squad

	var/laz_name = ""
	if(S) laz_name = S.name

	var/turf/TU = get_turf(A)
	var/area/targ_area = get_area(A)
	if(!istype(TU)) return
	var/is_outside = FALSE
	if(TU.z == 1)
		switch(targ_area.ceiling)
			if(CEILING_NONE)
				is_outside = TRUE
			if(CEILING_GLASS)
				is_outside = TRUE
	if(!is_outside)
		user << "<span class='warning'>INVALID TARGET: target must be visible from high altitude.</span>"
		return
	if(user.action_busy)
		return
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	user << "<span class='notice'>INITIATING LASER TARGETING. Stand still.</span>"
	if(!do_after(user, acquisition_time, TRUE, 5, BUSY_ICON_GENERIC) || world.time < laser_cooldown || laser)
		return
	if(mode)
		var/obj/effect/overlay/temp/laser_coordinate/LT = new (TU, laz_name)
		coord = LT
		user << "<span class='notice'>SIMPLIFIED COORDINATES OF TARGET. LONGITUDE [coord.x]. LATITUDE [coord.y].</span>"
		playsound(src, 'sound/effects/binoctarget.ogg', 35)
		while(coord)
			if(!do_after(user, 50, TRUE, 5, BUSY_ICON_GENERIC))
				if(coord)
					cdel(coord)
					coord = null
				break
	else
		user << "<span class='notice'>TARGET ACQUIRED. LASER TARGETING IS ONLINE. DON'T MOVE.</span>"
		var/obj/effect/overlay/temp/laser_target/LT = new (TU, laz_name)
		laser = LT
		playsound(src, 'sound/effects/binoctarget.ogg', 35)
		while(laser)
			if(!do_after(user, 50, TRUE, 5, BUSY_ICON_GENERIC))
				if(laser)
					cdel(laser)
					laser = null
				break


/obj/item/device/binoculars/tactical/scout
	name = "scout tactical binoculars"
	desc = "A modified version of tactical binoculars with an advanced laser targeting function. Ctrl+Click to target something."
	cooldown_duration = 80
	target_acquisition_delay = 30

//For events
/obj/item/device/binoculars/tactical/range
	name = "range-finder"
	desc = "A pair of binoculars designed to find coordinates."
	changable = 0
	mode = 1