//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
CONTAINS:
RCD
*/
/obj/item/device/rcd
	name = "rapid-construction-device (RCD)"
	desc = "A device used to rapidly build walls/floor."
	icon = 'icons/obj/items/devices.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	flags_atom = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	matter = list("metal" = 50000)
	origin_tech = "engineering=4;materials=2"
	var/datum/effect_system/spark_spread/spark_system
	var/stored_matter = 0
	var/working = 0
	var/mode = 1
	var/canRwall = 0
	var/disabled = 0


	New()
		desc = "A RCD. It currently holds [stored_matter]/30 matter-units."
		src.spark_system = new /datum/effect_system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		return


	attackby(obj/item/W, mob/user)
		..()
		if(istype(W, /obj/item/ammo_rcd))
			if((stored_matter + 10) > 30)
				to_chat(user, "<span class='notice'>The RCD cant hold any more matter-units.</span>")
				return
			user.drop_held_item()
			cdel(W)
			stored_matter += 10
			playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
			to_chat(user, "<span class='notice'>The RCD now holds [stored_matter]/30 matter-units.</span>")
			desc = "A RCD. It currently holds [stored_matter]/30 matter-units."
			return


	attack_self(mob/user)
		//Change the mode
		playsound(src.loc, 'sound/effects/pop.ogg', 15, 0)
		switch(mode)
			if(1)
				mode = 2
				to_chat(user, "<span class='notice'>Changed mode to 'Airlock'</span>")
				if(prob(20))
					src.spark_system.start()
				return
			if(2)
				mode = 3
				to_chat(user, "<span class='notice'>Changed mode to 'Deconstruct'</span>")
				if(prob(20))
					src.spark_system.start()
				return
			if(3)
				mode = 1
				to_chat(user, "<span class='notice'>Changed mode to 'Floor & Walls'</span>")
				if(prob(20))
					src.spark_system.start()
				return

	proc/activate()
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 25, 1)


	afterattack(atom/A, mob/user, proximity)
		if(!proximity) return
		if(disabled && !isrobot(user))
			return 0
		if(istype(A,/area/shuttle) || istype(A,/turf/open/space/transit))
			return 0
		if(!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
			return 0

		switch(mode)
			if(1)
				if(istype(A, /turf/open/space))
					if(useResource(1, user))
						to_chat(user, "Building Floor...")
						activate()
						A:ChangeTurf(/turf/open/floor/plating/airless)
						return 1
					return 0

				if(istype(A, /turf/open/floor))
					if(checkResource(3, user))
						to_chat(user, "Building Wall ...")
						playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
						if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
							if(!useResource(3, user)) return 0
							activate()
							A:ChangeTurf(/turf/closed/wall)
							return 1
					return 0

			if(2)
				if(istype(A, /turf/open/floor))
					if(checkResource(10, user))
						to_chat(user, "Building Airlock...")
						playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
						if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
							if(!useResource(10, user)) return 0
							activate()
							var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
							T.autoclose = 1
							return 1
						return 0
					return 0

			if(3)
				if(istype(A, /turf/closed/wall))
					var/turf/closed/wall/WL = A
					if(WL.hull)
						return 0
					if(istype(A, /turf/closed/wall/r_wall) && !canRwall)
						return 0
					if(checkResource(5, user))
						to_chat(user, "Deconstructing Wall...")
						playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
						if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
							if(!useResource(5, user)) return 0
							activate()
							A:ChangeTurf(/turf/open/floor/plating/airless)
							return 1
					return 0

				if(istype(A, /turf/open/floor) && !istype(A, /turf/open/floor/plating))
					if(checkResource(5, user))
						to_chat(user, "Deconstructing Floor...")
						playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
						if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
							if(!useResource(5, user)) return 0
							activate()
							A:ChangeTurf(/turf/open/floor/plating/airless)
							return 1
					return 0

				if(istype(A, /obj/machinery/door/airlock))
					if(checkResource(10, user))
						to_chat(user, "Deconstructing Airlock...")
						playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
						if(do_after(user, 50, TRUE, 5, BUSY_ICON_BUILD))
							if(!useResource(10, user)) return 0
							activate()
							cdel(A)
							return 1
					return	0
				return 0
			else
				to_chat(user, "ERROR: RCD in MODE: [mode] attempted use by [user]. Send this text #coderbus or an admin.")
				return 0

/obj/item/device/rcd/proc/useResource(var/amount, var/mob/user)
	if(stored_matter < amount)
		return 0
	stored_matter -= amount
	desc = "A RCD. It currently holds [stored_matter]/30 matter-units."
	return 1

/obj/item/device/rcd/proc/checkResource(var/amount, var/mob/user)
	return stored_matter >= amount
/obj/item/device/rcd/borg/useResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:use(amount * 30)

/obj/item/device/rcd/borg/checkResource(var/amount, var/mob/user)
	if(!isrobot(user))
		return 0
	return user:cell:charge >= (amount * 30)

/obj/item/device/rcd/borg/New()
	..()
	desc = "A device used to rapidly build walls/floor."
	canRwall = 1

/obj/item/ammo_rcd
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/items/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	matter = list("metal" = 30000,"glass" = 15000)
