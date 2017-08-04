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
	zoom(user)

/obj/item/device/binoculars/tactical
	name = "tactical binoculars"
	desc = "A pair of binoculars, with a laser targeting function. Double click to target something."
	var/laser_cooldown = 0
	var/cooldown_duration = 200 //20 seconds
	var/obj/effect/overlay/temp/laser_target/laser
	var/target_acquisition_delay = 70 //7 seconds
	var/busy = FALSE

	New()
		..()
		overlays += "binoculars_laser"

	Dispose()
		if(laser)
			cdel(laser)
			laser = null
		. = ..()

	zoom(mob/living/user, tileoffset = 11, viewsize = 12)
		..()
		if(user && laser)
			if(!zoom)
				cdel(laser)
				laser = null

/obj/item/device/binoculars/tactical/proc/acquire_target(atom/A, mob/living/carbon/human/user)
	set waitfor = 0

	if(busy || laser)
		user << "<span class='warning'>You're already targeting something.</span>"
		return

	if(world.time < laser_cooldown)
		user << "<span class='warning'>[src]'s laser battery is recharging.</span>"
		return

	if(!user.mind)
		return

	var/datum/squad/S
	if(user.mind.assigned_squad)
		S = user.mind.assigned_squad
	else
		S = get_squad_data_from_card(user)

	if(!S)
		user << "<span class='warning'>You need to be in a squad for this to do anything.</span>"
		return

	var/turf/TU = get_turf(A)
	var/area/targ_area = get_area(A)
	if(!istype(TU)) return
	var/is_outside = FALSE
	if(TU.z == 1)
		if(istype(TU, /turf/unsimulated/floor))
			var/turf/unsimulated/floor/F = TU
			if(F.is_groundmap_turf)
				if(istype(targ_area) && !targ_area.is_underground)
					is_outside = TRUE
		else if (istype(targ_area,/area/prison))
			is_outside = TRUE
	if(!is_outside)
		user << "<span class='warning'>INVALID TARGET: target must be outside on open ground.</span>"
		return
	busy = TRUE
	playsound(src, 'sound/effects/nightvision.ogg', 35)
	user << "<span class='notice'>INITIATING LASER TARGETING ON: '[A]'. Stand still.</span>"
	var/old_A_loc = A.loc
	if(!do_after(user, target_acquisition_delay, TRUE, 5, BUSY_ICON_CLOCK) || world.time < laser_cooldown || laser || !A || A.loc != old_A_loc)
		busy = FALSE
		return
	busy = FALSE
	user << "<span class='notice'>TARGET ACQUIRED. LASER TARGETING ON '[A]' IS ONLINE. DON'T MOVE.</span>"
	var/obj/effect/overlay/temp/laser_target/LT = new (get_turf(A), S.name)
	laser = LT
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	while(laser)
		if(!do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
			if(laser)
				cdel(laser)
				laser = null
			break


/obj/item/device/binoculars/tactical/scout
	name = "scout tactical binoculars"
	desc = "A modified version of tactical binoculars with an advanced laser targeting function. Double click to target something."
	cooldown_duration = 80
	target_acquisition_delay = 30
