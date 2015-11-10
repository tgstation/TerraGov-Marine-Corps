///***GRENADES***///
/obj/item/weapon/grenade/explosive
	desc = "It is set to detonate in 4 seconds."
	name = "frag grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade_ex"
	det_time = 40
	item_state = "grenade_ex"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	dangerous = 1

	prime()
		spawn(0)
			explosion(src.loc,-1,-1,2)
			del(src)
		return

/obj/item/weapon/grenade/incendiary
	desc = "It is set to detonate in 4 seconds."
	name = "incendiary grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "large_grenade"
	det_time = 40
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	dangerous = 1

	prime()
		spawn(0)
			flame_radius(1,get_turf(src))
			del(src)
		return

proc/flame_radius(var/radius = 1, var/turf/turf)
	if(!turf || !isturf(turf)) return
	if(radius < 0) radius = 0
	if(radius > 5) radius = 5

	for(var/turf/T in range(radius,turf))
		if(T.density) continue
		if(istype(T,/turf/space)) continue
		if(locate(/obj/flamer_fire) in T) continue //No stacking

		var/obj/flamer_fire/F = new(T)
		processing_objects.Add(F)
		F.firelevel = 5 + rand(0,11)
		if(F.firelevel < 1) F.firelevel = 1
		if(F.firelevel > 16) F.firelevel = 16


/obj/item/weapon/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/smoke_spread/bad/smoke

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/bad
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		src.smoke.set_up(10, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
		sleep(20)
		del(src)
		return

/obj/item/weapon/grenade/phosphorus
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/smoke_spread/phosphorus/smoke
	dangerous = 1

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/phosphorus
		src.smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		src.smoke.set_up(10, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()

		sleep(20)
		del(src)
		return




///***MINES***///
/obj/item/device/mine
	name = "Proximity Mine"
	desc = "An anti-personnel mine. Useful for setting traps or for area denial. "
	icon = 'icons/obj/grenade.dmi'
	icon_state = "mine"
	force = 5.0
	w_class = 2.0
	layer = 3
	throwforce = 5.0
	throw_range = 6
	throw_speed = 3
	unacidable = 1
	flags = FPRINT | TABLEPASS

	var/triggered = 0
	var/triggertype = "explosive" //Calls that proc
	/*
		"explosive"
		//"incendiary" //New bay//
	*/


//Arming
/obj/item/device/mine/attack_self(mob/living/user as mob)
	if(locate(/obj/item/device/mine) in get_turf(src))
		src << "There's already a mine at this position!"
		return

	if(user.z == 3 || user.z == 4) // On the Sulaco.
		src << "Are you crazy? You can't plant a landmine on a spaceship!"
		return

	if(!anchored)
		user.visible_message("\blue \The [user] is deploying \the [src]")
		if(!do_after(user,40))
			user.visible_message("\blue \The [user] decides not to deploy \the [src].")
			return
		user.visible_message("\blue \The [user] deployed \the [src].")
		anchored = 1
		icon_state = "mine_armed"
		user.drop_item()
		return

//Disarming
/obj/item/device/mine/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/multitool))
		if(anchored)
			user.visible_message("\blue \The [user] starts to disarm \the [src].")
			if(!do_after(user,80))
				user.visible_message("\blue \The [user] decides not to disarm \the [src].")
				return
			user.visible_message("\blue \The [user] finishes disarming \the [src]!")
			anchored = 0
			icon_state = "mine"
			return

//Triggering
/obj/item/device/mine/Crossed(AM as mob|obj)
	Bumped(AM)

/obj/item/device/mine/Bumped(mob/M as mob|obj)
	if(!anchored) return //If armed
	if(triggered) return

	if(istype(M, /mob/living/carbon/Xenomorph) && !istype(M, /mob/living/carbon/Xenomorph/Larva) && M.stat != DEAD) //Only humanoid aliens can trigger it.
		var/mob/living/carbon/Xenomorph/X = M
		if(X.is_robotic) return //NOPE.jpg
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]!</font>"
		triggered = 1
		explosion(src.loc,-1,-1,2)
		spawn(0)
			if(src)
				del(src)

//TYPES//
//Explosive
/obj/item/device/mine/proc/explosive(obj)
	explosion(src.loc,-1,-1,3)
	spawn(0)
		del(src)
