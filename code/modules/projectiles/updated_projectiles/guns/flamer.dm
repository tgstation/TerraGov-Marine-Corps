


//FLAMETHROWER

/obj/item/weapon/gun/flamer
	name = "\improper M240A1 incinerator unit"
	desc = "M240A1 incinerator unit has proven to be one of the most effective weapons at clearing out soft-targets. This is a weapon to be feared and respected as it is quite deadly."
	origin_tech = "combat=4;materials=3"
	icon_state = "m240"
	item_state = "flamer"
	flags_equip_slot = SLOT_BACK
	w_class = 4
	force = 15
	fire_sound = 'sound/weapons/gun_flamethrower2.ogg'
	aim_slowdown = SLOWDOWN_ADS_INCINERATOR
	current_mag = /obj/item/ammo_magazine/flamer_tank
	var/max_range = 5
	var/lit = 0 //Turn the flamer on/off

	attachable_allowed = list( //give it some flexibility.
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS

	New()
		..()
		fire_delay = config.max_fire_delay * 5
		attachable_offset = list("rail_x" = 12, "rail_y" = 23)

	unique_action(mob/user)
		toggle_flame(user)

	examine(mob/user)
		..()
		user << "It's turned [lit? "on" : "off"]."
		if(current_mag)
			user << "The fuel gauge shows the current tank is [round(current_mag.get_ammo_percent())]% full!"
		else
			user << "There's no tank in [src]!"

/obj/item/weapon/gun/flamer/able_to_fire(mob/user)
	. = ..()
	if(.)
		if(!current_mag || !current_mag.current_rounds)
			return

/obj/item/weapon/gun/flamer/proc/toggle_flame(mob/user)
	playsound(user,'sound/weapons/flipblade.ogg', 25, 1)
	lit = !lit

	var/image/reusable/I = rnew(/image/reusable, list('icons/obj/items/gun.dmi', src, "+lit"))
	I.pixel_x += 3

	if (lit)
		overlays += I
	else
		overlays -= I
		cdel(I)

/obj/item/weapon/gun/flamer/Fire(atom/target, mob/living/user, params, reflex)
	set waitfor = 0
	if(!able_to_fire(user)) return
	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if (!targloc || !curloc) return //Something has gone wrong...

	if(!lit)
		user << "<span class='alert'>The weapon isn't lit</span>"
		return

	if(!current_mag) return
	if(current_mag.current_rounds <= 0)
		click_empty(user)
	else
		unleash_flame(target, user)

/obj/item/weapon/gun/flamer/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(!magazine || !istype(magazine))
		user << "<span class='warning'>That's not a magazine!</span>"
		return

	if(magazine.current_rounds <= 0)
		user << "<span class='warning'>That [magazine.name] is empty!</span>"
		return

	if(!istype(src, magazine.gun_type))
		user << "<span class='warning'>That magazine doesn't fit in there!</span>"
		return

	if (istype(magazine, /obj/item/ammo_magazine/flamer_tank/large))
		user << "<span class='warning'>That tank is too large for this model!</span>"
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		user << "<span class='warning'>It's still got something loaded!</span>"
		return

	else
		if(user)
			if(magazine.reload_delay > 1)
				user << "<span class='notice'>You begin reloading [src]. Hold still...</span>"
				if(do_after(user,magazine.reload_delay, TRUE, 5, BUSY_ICON_FRIENDLY)) replace_magazine(user, magazine)
				else
					user << "<span class='warning'>Your reload was interrupted!</span>"
					return
			else replace_magazine(user, magazine)
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)

	update_icon()
	return 1

/obj/item/weapon/gun/flamer/unload(mob/user, reload_override = 0, drop_override = 0)
	if(!current_mag) return //no magazine to unload
	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.forceMove(get_turf(src)) //Drop it on the ground.
	else user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>")
	current_mag.update_icon()
	current_mag = null

	update_icon()

/obj/item/weapon/gun/flamer/proc/unleash_flame(atom/target, mob/living/user)
	set waitfor = 0
	last_fired = world.time
	var/burnlevel
	var/burntime
	var/fire_color = "red"
	switch(current_mag.caliber)
		if("UT-Napthal Fuel") //This isn't actually Napalm actually
			burnlevel = 24
			burntime = 17
			max_range = 5

		// Area denial, light damage, large AOE, long burntime
		if("Napalm B")
			burnlevel = 10
			burntime = 50
			max_range = 4
			playsound(user, fire_sound, 50, 1)
			triangular_flame(target, user, burntime, burnlevel)
			return

		if("Napalm X") //Probably can end up as a spec fuel or DS flamer fuel. Also this was the original fueltype, the madman i am.
			burnlevel = 50
			burntime = 40
			max_range = 7
			fire_color = "blue"
		if("Fuel") //This is welding fuel and thus pretty weak. Not ment to be exactly used for flamers either.
			burnlevel = 10
			burntime = 10
			max_range = 4
		else return

	var/list/turf/turfs = getline2(user,target)
	playsound(user, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/turf/T in turfs)
		if(T == user.loc)
			prev_T = T
			continue
		if(T.density)
			break
		if(loc != user)
			break
		if(!current_mag || !current_mag.current_rounds)
			break
		if(distance > max_range)
			break
		if(prev_T && LinkBlocked(prev_T, T))
			break
		current_mag.current_rounds--
		flame_turf(T,user, burntime, burnlevel, fire_color)
		distance++
		prev_T = T
		sleep(1)

/obj/item/weapon/gun/flamer/proc/flame_turf(turf/T, mob/living/user, heat, burn, f_color = "red")
	if(!istype(T))
		return

	// No stacking flames
	if (locate(/obj/flamer_fire) in T)
		return

	new /obj/flamer_fire(T, heat, burn, f_color)

	// Melt a single layer of snow
	if (istype(T, /turf/open/snow))
		var/turf/open/snow/S = T

		if (S.slayer > 0)
			S.slayer -= 1
			S.update_icon(1, 0)

	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)		continue

		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune) 	continue
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M //fixed :s

			if(user)
				if(user.mind && !user.mind.special_role && H.mind && !H.mind.special_role)
					H.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with \a <b>[name]</b> in [get_area(user)]."
					user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with \a <b>[name]</b> in [get_area(user)]."
					msg_admin_ff("[user] ([user.ckey]) shot [H] ([H.ckey]) with \a [name] in [get_area(user)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>) (<a href='?priv_msg=\ref[user.client]'>PM</a>)")
				else
					H.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with \a <b>[name]</b> in [get_area(user)]."
					user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> shot <b>[H]/[H.ckey]</b> with \a <b>[name]</b> in [get_area(user)]."
					msg_admin_attack("[user] ([user.ckey]) shot [H] ([H.ckey]) with \a [name] in [get_area(user)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

			if(istype(H.wear_suit, /obj/item/clothing/suit/fire)) continue

		M.adjust_fire_stacks(rand(5,burn*2))
		M.IgniteMob()
		M.adjustFireLoss(rand(burn,(burn*2))) // Make it so its the amount of heat or twice it for the initial blast.
		M << "[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!"

/obj/item/weapon/gun/flamer/proc/triangular_flame(var/atom/target, var/mob/living/user, var/burntime, var/burnlevel)
	set waitfor = 0

	var/unleash_dir = user.dir //don't want the player to turn around mid-unleash to bend the fire.
	var/list/turf/turfs = getline2(user,target)
	playsound(user, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/turf/T in turfs)
		if(T == user.loc)
			prev_T = T
			continue
		if(T.density)
			break
		if(loc != user)
			break
		if(!current_mag || !current_mag.current_rounds)
			break
		if(distance > max_range)
			break
		if(prev_T && LinkBlocked(prev_T, T))
			break
		current_mag.current_rounds--
		flame_turf(T,user, burntime, burnlevel, "green")
		prev_T = T
		sleep(1)

		var/list/turf/right = list()
		var/list/turf/left = list()
		var/turf/right_turf = T
		var/turf/left_turf = T
		var/right_dir = turn(unleash_dir, 90)
		var/left_dir = turn(unleash_dir, -90)
		for (var/i = 0, i < distance - 1, i++)
			right_turf = get_step(right_turf, right_dir)
			right += right_turf
			left_turf = get_step(left_turf, left_dir)
			left += left_turf

		var/turf/prev_R = T
		for (var/turf/R in right)

			if (R.density)
				break
			if(prev_R && LinkBlocked(prev_R, R))
				break

			flame_turf(R, user, burntime, burnlevel, "green")
			prev_R = R
			sleep(1)

		var/turf/prev_L = T
		for (var/turf/L in left)
			if (L.density)
				break
			if(prev_L && LinkBlocked(prev_L, L))  break

			flame_turf(L, user, burntime, burnlevel, "green")
			prev_L = L
			sleep(1)

		distance++



/obj/item/weapon/gun/flamer/M240T
	name = "\improper M240-T incinerator unit"
	desc = "An improved version of the M240A1 incenerator unit, the M240-T model is capable of dispersing a larger variety of fuel types."
	current_mag = /obj/item/ammo_magazine/flamer_tank/large

/obj/item/weapon/gun/flamer/M240T/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(!magazine || !istype(magazine))
		user << "<span class='warning'>That's not a magazine!</span>"
		return

	if(magazine.current_rounds <= 0)
		user << "<span class='warning'>That [magazine.name] is empty!</span>"
		return

	if(!istype(src, magazine.gun_type))
		user << "<span class='warning'>That magazine doesn't fit in there!</span>"
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		user << "<span class='warning'>It's still got something loaded!</span>"
		return

	else
		if(user)
			if(magazine.reload_delay > 1)
				user << "<span class='notice'>You begin reloading [src]. Hold still...</span>"
				if(do_after(user,magazine.reload_delay, TRUE, 5, BUSY_ICON_FRIENDLY)) replace_magazine(user, magazine)
				else
					user << "<span class='warning'>Your reload was interrupted!</span>"
					return
			else replace_magazine(user, magazine)
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)

	update_icon()
	return 1

/obj/item/weapon/gun/flamer/M240T/able_to_fire(mob/user)
	. = ..()
	if(.)
		if(!current_mag || !current_mag.current_rounds)
			return

		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.spec_weapons < SKILL_SPEC_TRAINED && user.mind.cm_skills.spec_weapons != SKILL_SPEC_PYRO)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return 0



//////////////////////////////////////////////////////////////////////////////////////////////////
//Time to redo part of abby's code.
//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = 1
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	layer = BELOW_OBJ_LAYER
	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.
	var/flame_color = "red"

/obj/flamer_fire/New(loc, fire_lvl, burn_lvl, f_color, fire_spread_amount)
	..()
	if (f_color)
		flame_color = f_color

	icon_state = "[flame_color]_2"
	if(fire_lvl) firelevel = fire_lvl
	if(burn_lvl) burnlevel = burn_lvl
	processing_objects.Add(src)

	if(fire_spread_amount > 0)
		var/turf/T
		for(var/dirn in cardinal)
			T = get_step(loc, dirn)
			if(istype(T,/turf/open/space)) continue
			if(locate(/obj/flamer_fire) in T) continue //No stacking
			var/new_spread_amt = T.density ? 0 : fire_spread_amount - 1 //walls stop the spread
			if(new_spread_amt)
				for(var/obj/O in T)
					if(!O.CanPass(src, loc))
						new_spread_amt = 0
						break
			spawn(0) //delay so the newer flame don't block the spread of older flames
				new /obj/flamer_fire(T, fire_lvl, burn_lvl, f_color, new_spread_amt)


/obj/flamer_fire/Dispose()
	SetLuminosity(0)
	processing_objects.Remove(src)
	. = ..()


/obj/flamer_fire/Crossed(mob/living/M) //Only way to get it to reliable do it when you walk into it.
	if(istype(M))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(isXeno(H.pulledby))
				var/mob/living/carbon/Xenomorph/Z = H.pulledby
				if(!Z.fire_immune)
					Z.adjust_fire_stacks(burnlevel)
					Z.IgniteMob()
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire))
				H.show_message(text("Your suit protects you from the flames."),1)
				H.adjustFireLoss(burnlevel*0.25) //Does small burn damage to a person wearing one of the suits.
				return
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune) 	return
		M.adjust_fire_stacks(burnlevel) //Make it possible to light them on fire later.
		if (prob(firelevel + 2*M.fire_stacks)) //the more soaked in fire you are, the likelier to be ignited
			M.IgniteMob()

		M.adjustFireLoss(round(burnlevel*0.5)) //This makes fire stronk.
		M << "<span class='danger'>You are burned!</span>"
		if(isXeno(M)) M.updatehealth()


/obj/flamer_fire/proc/updateicon()
	if(burnlevel < 15)
		color = "#c1c1c1" //make it darker to make show its weaker.
	switch(firelevel)
		if(1 to 9)
			icon_state = "[flame_color]_1"
			SetLuminosity(2)
		if(10 to 25)
			icon_state = "[flame_color]_2"
			SetLuminosity(4)
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			icon_state = "[flame_color]_3"
			SetLuminosity(6)


/obj/flamer_fire/process()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf? Has to be on a floor
		cdel(src)
		return

	updateicon()

	if(!firelevel)
		cdel(src)
		return

	var/j = 0
	for(var/i in loc)
		if(++j >= 11) break
		if(isliving(i))
			var/mob/living/I = i
			if(istype(I,/mob/living/carbon/human))
				var/mob/living/carbon/human/M = I
				if(istype(M.wear_suit, /obj/item/clothing/suit/fire) || istype(M.wear_suit,/obj/item/clothing/suit/space/rig/atmos))
					M.show_message(text("Your suit protects you from the flames."),1)
					M.adjustFireLoss(rand(0 ,burnlevel*0.25)) //Does small burn damage to a person wearing one of the suits.
					continue
			if(istype(I,/mob/living/carbon/Xenomorph/Queen))
				var/mob/living/carbon/Xenomorph/Queen/X = I
				X.show_message(text("Your extra-thick exoskeleton protects you from the flames."),1)
				continue
			if(istype(I,/mob/living/carbon/Xenomorph/Ravager))
				if(!I.stat)
					var/mob/living/carbon/Xenomorph/Ravager/X = I
					X.plasma_stored = X.plasma_max
					X.usedcharge = 0 //Reset charge cooldown
					X.show_message(text("<span class='danger'>The heat of the fire roars in your veins! KILL! CHARGE! DESTROY!</span>"),1)
					if(rand(1,100) < 70) X.emote("roar")
				continue
			I.adjust_fire_stacks(burnlevel) //If i stand in the fire i deserve all of this. Also Napalm stacks quickly.
			if(prob(firelevel)) I.IgniteMob()
			//I.adjustFireLoss(rand(10 ,burnlevel)) //Including the fire should be way stronger.
			I.show_message(text("<span class='warning'>You are burned!</span>"),1)
			if(isXeno(I)) //Have no fucken idea why the Xeno thing was there twice.
				var/mob/living/carbon/Xenomorph/X = I
				X.updatehealth()
		if(istype(i, /obj/))
			var/obj/O = i
			O.flamer_fire_act()

	//This has been made a simple loop, for the most part flamer_fire_act() just does return, but for specific items it'll cause other effects.
	firelevel -= 2 //reduce the intensity by 2 per tick
	return
