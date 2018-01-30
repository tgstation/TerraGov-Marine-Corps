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
	var/target_acquisition_delay = 100 //10 seconds
	var/busy = FALSE

/obj/item/device/binoculars/tactical/New()
	..()
	overlays += "binoculars_laser"

/obj/item/device/binoculars/tactical/Dispose()
	if(laser)
		cdel(laser)
		laser = null
	. = ..()

/obj/item/device/binoculars/tactical/on_unset_interaction(var/mob/user)
	..()

	if (user && laser)
		if (!zoom)
			cdel(laser)

/obj/item/device/binoculars/tactical/handle_click(var/mob/living/user, var/atom/A, var/list/mods)
	if (mods["ctrl"])
		acquire_target(A, user)
		return 1
	return 0

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
	if(!do_after(user, acquisition_time, TRUE, 5, BUSY_ICON_CLOCK) || world.time < laser_cooldown || laser || !A || A.loc != old_A_loc)
		busy = FALSE
		return
	busy = FALSE
	user << "<span class='notice'>TARGET ACQUIRED. LASER TARGETING ON '[A]' IS ONLINE. DON'T MOVE.</span>"
	var/obj/effect/overlay/temp/laser_target/LT = new (get_turf(A), laz_name)
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
	desc = "A modified version of tactical binoculars with an advanced laser targeting function. Ctrl+Click to target something."
	cooldown_duration = 80
	target_acquisition_delay = 30
