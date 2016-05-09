/obj/item/weapon/flamethrower
	name = "M240 Incinerator Unit"
	desc = "M240 Incinerator Unit has proven to be one of the most effective weapons at clearing out soft-targets. Carried by specialists, this weapon is one to be feared."
	icon = 'icons/obj/gun.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamer"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
//	m_amt = 500
	origin_tech = "combat=1;plasmatech=1"
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/phoron/ptank = null


/obj/item/weapon/flamethrower/Del()
	if(weldtool)
		del(weldtool)
	if(igniter)
		del(igniter)
	if(ptank)
		del(ptank)
	..()
	return


//Abby's overhaul - Stop hotspot igniting, it's unnecessary.

///obj/item/weapon/flamethrower/process()
//	if(!lit)
//		processing_objects.Remove(src)
//		return null
//	var/turf/location = loc
//	if(istype(location, /mob/))
//		var/mob/M = location
//		if(M.l_hand == src || M.r_hand == src)
//			location = M.loc
//	if(isturf(location)) //start a fire if possible
//		location.hotspot_expose(700, 2)
//	return


/obj/item/weapon/flamethrower/update_icon()
	overlays.Cut()
	if(igniter)
		overlays += "+igniter[status]"
	if(ptank)
		overlays += "+ptank"
	if(lit)
		overlays += "+lit"
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/weapon/flamethrower/afterattack(atom/target, mob/user, proximity)
	// Make sure our user is still holding us
	..()
	if(user && user.get_active_hand() == src)
		if(!lit)
			usr << "Light your flamethrower first!"
			return
		if(!ptank)
			usr << "No tank attached!"
			lit = 0
			return
		if(ptank.air_contents.gas["phoron"] <= 0.5)
			usr << "You try to get your flame on, but nothing happens. You're all out of burn juice!"
//			playsound(src.loc, 'sound/weapons/flamethrower_empty.ogg', 100, 1)
			lit = 0
			update_icon()
			return
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf) //Uses old turf generation.
			for (var/mob/O in viewers())
				O << "\red [user] unleashes a blast of flames!"
			playsound(src.loc, 'sound/weapons/flamethrower_shoot.ogg', 80, 1)
			flame_turf(turflist)

/obj/item/weapon/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	if(iswrench(W) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.loc = T
			weldtool = null
		if(igniter)
			igniter.loc = T
			igniter = null
		if(ptank)
			ptank.loc = T
			ptank = null
		new /obj/item/stack/rods(T)
		del(src)
		return

	if(isscrewdriver(W) && igniter && !lit)
		status = !status
		user << "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>"
		update_icon()
		return

	if(isigniter(W))
		var/obj/item/device/assembly/igniter/I = W
		if(I.secured)	return
		if(igniter)		return
		user.drop_item()
		I.loc = src
		igniter = I
		update_icon()
		return

	if(istype(W,/obj/item/weapon/tank/phoron))
		if(ptank)
			user << "<span class='notice'>There appears to already be a plasma tank loaded in [src]!</span>"
			return
		user.drop_item()
		ptank = W
		W.loc = src
		update_icon()
		return

	..()
	return
/obj/item/weapon/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	if(!ptank)
		user << "<span class='notice'>Attach a plasma tank first!</span>"
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return
/obj/item/weapon/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(ptank.air_contents.gas["phoron"] < 0.5)
			usr << "There's not enough gas left to ignite the flamethrower."
			return
		if(!status)	return
		lit = !lit
		if(lit)
			processing_objects.Add(src)
	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = max(50, min(1000, throw_amount))
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	return

/obj/item/weapon/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return
	operating = 1
	var/distance = 0
	for(var/turf/T in turflist)
		distance++
		if(T.density || istype(T, /turf/space))
			break
		if(distance > 6)
			break

		if(!isnull(usr))
			if(DirBlocked(T,usr.dir))
				break
			else if(DirBlocked(T,turn(usr.dir,180)))
				break
		if(locate(/obj/effect/alien/resin/wall,T) || locate(/obj/effect/alien/resin/membrane,T) || locate(/obj/structure/girder,T))
			break //Nope.avi
		var/obj/structure/mineral_door/resin/D = locate() in T
		if(D)
			if(D.density) break
		var/obj/machinery/M = locate() in T
		if(M)
			if(M.density) break
		var/obj/structure/window/W = locate() in T
		if(W)
			if(W.is_full_window()) break
			if(previousturf)
				if(get_dir(previousturf,W) == W.dir)
					break

		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on

		if(previousturf && LinkBlocked(previousturf, T))
			break
		previousturf = T
		ignite_turf(T)
		sleep(1)
	previousturf = null
	operating = 0
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return

//Abby's flamethrower rewrite

//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "flamethrower fire"
	desc = "Ouch!"
	anchored = 1
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = TURF_LAYER
	var/firelevel = 12 //Track how "hot" the fire is, flames die down eventually

/obj/flamer_fire/process()
	var/turf/T = loc

	if (!istype(T)) //Is it a valid turf? Has to be on a floor
		processing_objects.Remove(src)
		del(src)
		return

	if(firelevel > 10) //Change the icons and luminosity based on the fire's intensity
		icon_state = "3"
		SetLuminosity(7)
	else if(firelevel > 5)
		icon_state = "2"
		SetLuminosity(5)
	else if(firelevel > 0)
		icon_state = "1"
		SetLuminosity(2)
	else  //Fire has burned out, firelevel is 0 or less. GET OUT. Shouldn't cause issues, unlike sleep() + Del
		SetLuminosity(0)
		processing_objects.Remove(src)
		del(src)
		return

	for(var/mob/living/carbon/M in loc)
		if(istype(M,/mob/living/carbon/human))
			if(istype(M:wear_suit, /obj/item/clothing/suit/fire) || istype(M:wear_suit,/obj/item/clothing/suit/space/rig/atmos))
				M.show_message(text("Your suit protects you from the flames."),1)
				continue
		if(istype(M,/mob/living/carbon/Xenomorph/Queen))
			M.show_message(text("Your extra-thick exoskeleton protects you from the flames."),1)
			continue
		if(istype(M,/mob/living/carbon/Xenomorph/Ravager))
			var/mob/living/carbon/Xenomorph/Ravager/X = M
			X.storedplasma = X.maxplasma
			X.usedcharge = 0 //Reset charge cooldown
			M.show_message(text("\red The heat of the fire roars in your veins! KILL! CHARGE! DESTROY!"),1)
			if(rand(1,100) < 70)
				M.emote("roar")
			continue
		M.adjustFireLoss(rand(15,35) + firelevel)  //fwoom!
		M.show_message(text("\red You are burned!"),1)

	//This is shitty and inefficient, but the /alien/ parent obj doesn't have health.. sigh.
	for(var/obj/effect/alien/weeds/W in loc)  //Melt dem weeds
		if(istype(W)) //Just for safety
			W.health -= (30 + (firelevel * 3))
			if(W.health < 0)
				del(W) //Just deleterize it
	for(var/obj/effect/alien/resin/R in loc)  //Melt dem resins
		if(istype(R)) //Just for safety
			R.health -= (30 + (firelevel * 3))
			R.healthcheck()
	for(var/obj/effect/alien/egg/E in loc)  //Melt dem eggs
		if(istype(E)) //Just for safety
			E.health -= (30 + (firelevel * 3))
			E.healthcheck()
	for(var/obj/structure/stool/bed/nest/N in loc)  //Melt dem nests
		if(istype(N)) //Just for safety
			N.health -= (30 + (firelevel * 3))
			N.healthcheck()
	for(var/obj/item/clothing/mask/facehugger/H in loc) //Melt dem huggers
		if(istype(H))
//			H.health -= (firelevel + 5) //No need for a health check, just kill them
			H:Die()

	firelevel -= 2 //reduce the intensity by 2 per tick
	return


/obj/item/weapon/flamethrower/proc/ignite_turf(turf/target)
	if(isnull(target)) //Basic logic checking, should not be possible
		return

	if(!ptank)
		return //Shouldn't be possible, just to be safe though

	if(ptank.air_contents.gas["phoron"] <= 0.3 || ptank.air_contents.gas["oxygen"] > 0 || ptank.air_contents.gas["nitrogen"] > 0 ) //The heck, did you attach an air tank to this thing??
		return

	ptank.air_contents.remove_ratio(0.07*(throw_amount/100)) //This should just strip out the gas
	if(!locate(/obj/flamer_fire) in target) // No stacking flames!
		var/obj/flamer_fire/F =  new/obj/flamer_fire(target)
		processing_objects.Add(F)
		F.firelevel = (throw_amount / 10) + 1
		if(F.firelevel < 1) F.firelevel = 1
		if(F.firelevel > 16) F.firelevel = 16
	for(var/mob/living/carbon/M in target) //Deal bonus damage if someone's caught directly in initial stream
		if(istype(M,/mob/living/carbon/Xenomorph))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune)
				continue
		if(istype(M,/mob/living/carbon/human))
			if(istype(M:wear_suit, /obj/item/clothing/suit/fire) || istype(M:wear_suit,/obj/item/clothing/suit/space/rig/atmos))
				continue
		M.adjustFireLoss(rand(18,32) + round(throw_amount / 50))  //fwoom!
		M.show_message(text("\red Auuugh! You are roasted by the flamethrower!"), 1)
	return

/obj/item/weapon/flamethrower/full/New(var/loc)
	..()
	weldtool = new /obj/item/weapon/weldingtool(src)
	weldtool.status = 0
	igniter = new /obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	ptank = new /obj/item/weapon/tank/phoron/m240(src)
	status = 1
	update_icon()
	return