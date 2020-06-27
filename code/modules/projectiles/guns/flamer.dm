//FLAMETHROWER

/obj/item/weapon/gun/flamer
	name = "\improper M240A1 incinerator unit"
	desc = "The M240A1 has proven to be one of the most effective weapons at clearing out soft-targets. This is a weapon to be feared and respected as it is quite deadly."
	icon_state = "m240"
	item_state = "m240"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	fire_sound = "gun_flamethrower"
	dry_fire_sound = 'sound/weapons/guns/fire/flamethrower_empty.ogg'
	unload_sound = 'sound/weapons/guns/interact/flamethrower_unload.ogg'
	reload_sound = 'sound/weapons/guns/interact/flamethrower_reload.ogg'
	aim_slowdown = 1.75
	current_mag = /obj/item/ammo_magazine/flamer_tank
	var/max_range = 7
	var/lit = 0 //Turn the flamer on/off
	general_codex_key = "flame weapons"

	attachable_allowed = list( //give it some flexibility.
						/obj/item/attachable/flashlight,
						/obj/item/attachable/magnetic_harness)
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_HEAVY_WEAPONS
	attachable_offset = list("rail_x" = 12, "rail_y" = 23)
	fire_delay = 20


/obj/item/weapon/gun/flamer/unique_action(mob/user)
	return toggle_flame(user)


/obj/item/weapon/gun/flamer/examine_ammo_count(mob/user)
	to_chat(user, "It's turned [lit? "on" : "off"].")
	if(current_mag)
		to_chat(user, "The fuel gauge shows the current tank is [round(current_mag.get_ammo_percent())]% full!")
	else
		to_chat(user, "There's no tank in [src]!")

/obj/item/weapon/gun/flamer/able_to_fire(mob/user)
	. = ..()
	if(.)
		if(!current_mag || !current_mag.current_rounds)
			return


/obj/item/weapon/gun/flamer/proc/toggle_flame(mob/user)
	playsound(user, lit ? 'sound/weapons/guns/interact/flamethrower_off.ogg' : 'sound/weapons/guns/interact/flamethrower_on.ogg', 25, 1)
	lit = !lit

	var/image/I = image('icons/obj/items/gun.dmi', src, "+lit")
	I.pixel_x += 3

	if (lit)
		overlays += I
	else
		overlays -= I
		qdel(I)

	return TRUE


/obj/item/weapon/gun/flamer/Fire(atom/target, mob/living/user, params, reflex)
	set waitfor = 0

	if(!able_to_fire(user))
		return

	if(gun_on_cooldown(user))
		return

	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if(!targloc || !curloc)
		return //Something has gone wrong...

	if(!lit)
		to_chat(user, "<span class='alert'>The weapon isn't lit</span>")
		return

	if(!current_mag)
		return

	if(current_mag.current_rounds <= 0)
		click_empty(user)
	else
		unleash_flame(target, user)
		var/obj/screen/ammo/A = user.hud_used.ammo
		A.update_hud(user)

/obj/item/weapon/gun/flamer/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(!magazine || !istype(magazine))
		to_chat(user, "<span class='warning'>That's not a magazine!</span>")
		return

	if(magazine.current_rounds <= 0)
		to_chat(user, "<span class='warning'>That [magazine.name] is empty!</span>")
		return

	if(!istype(src, magazine.gun_type))
		to_chat(user, "<span class='warning'>That magazine doesn't fit in there!</span>")
		return

	if(istype(magazine, /obj/item/ammo_magazine/flamer_tank/large))
		to_chat(user, "<span class='warning'>That tank is too large for this model!</span>")
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		to_chat(user, "<span class='warning'>It's still got something loaded!</span>")
		return

	else
		if(user)
			if(magazine.reload_delay > 1)
				to_chat(user, "<span class='notice'>You begin reloading [src]. Hold still...</span>")
				if(do_after(user,magazine.reload_delay, TRUE, src, BUSY_ICON_GENERIC))
					replace_magazine(user, magazine)
				else
					to_chat(user, "<span class='warning'>Your reload was interrupted!</span>")
					return
			else
				replace_magazine(user, magazine)
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)

	update_icon()
	return TRUE

/obj/item/weapon/gun/flamer/unload(mob/user, reload_override = 0, drop_override = 0)
	if(!current_mag)
		return FALSE //no magazine to unload
	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.forceMove(get_turf(src)) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>")
	current_mag.update_icon()
	current_mag = null

	update_icon()

	return TRUE


/obj/item/weapon/gun/flamer/proc/unleash_flame(atom/target, mob/living/user)
	set waitfor = 0

	last_fired = world.time
	var/burnlevel
	var/burntime
	var/fire_color = "red"
	switch(ammo.name)
		if("flame")
			burnlevel = 24
			burntime = 17
			max_range = 7
			fire_delay = 20

		// Area denial, light damage, large AOE, long burntime
		if("green flame")
			burnlevel = 10
			burntime = 50
			max_range = 4
			playsound(user, fire_sound, 50, 1)
			triangular_flame(target, user, burntime, burnlevel)
			fire_delay = 35
			return

		if("blue flame") //Probably can end up as a spec fuel or DS flamer fuel. Also this was the original fueltype, the madman i am.
			burnlevel = 36
			burntime = 40
			max_range = 7
			fire_color = "blue"
			fire_delay = 35

		else
			return

	var/list/turf/turfs = getline(user,target)
	playsound(user, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/F in turfs)
		var/turf/T = F

		if(T == user.loc)
			prev_T = T
			continue
		if((T.density && !istype(T, /turf/closed/wall/resin)) || isspaceturf(T))
			break
		if(loc != user)
			break
		if(!current_mag?.current_rounds)
			break
		if(distance > max_range)
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && !O.throwpass && !(O.flags_atom & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_T.Adjacent(T) && (T.x != prev_T.x || T.y != prev_T.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_T.x, T.y, prev_T.z)
			var/turf/Tx = locate(T.x, prev_T.y, prev_T.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_T.Adjacent(TB) && ((!TB.density && !isspaceturf(T)) || istype(T, /turf/closed/wall/resin)))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		current_mag.current_rounds--
		flame_turf(TF,user, burntime, burnlevel, fire_color)
		if(blocked)
			break
		distance++
		prev_T = T
		sleep(1)

/obj/item/weapon/gun/flamer/proc/flame_turf(turf/T, mob/living/user, heat, burn, f_color = "red")
	if(!istype(T))
		return

	T.ignite(heat, burn, f_color)

	// Melt a single layer of snow
	if(istype(T, /turf/open/floor/plating/ground/snow))
		var/turf/open/floor/plating/ground/snow/S = T

		if (S.slayer > 0)
			S.slayer -= 1
			S.update_icon(1, 0)

	for(var/obj/structure/jungle/vines/V in T)
		qdel(V)

	var/fire_mod
	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue

		fire_mod = 1

		if(isxeno(M))
			var/mob/living/carbon/xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = clamp(X.xeno_caste.fire_resist + X.fire_resist_modifier, 0, 1)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M //fixed :s

			if(user)
				if(!user.mind?.bypass_ff && !H.mind?.bypass_ff && user.faction == H.faction)
					log_combat(user, H, "flamed", src)
					user.ff_check(30, H) // avg between 20/40 dmg
					log_ffattack("[key_name(user)] flamed [key_name(H)] with \a [name] in [AREACOORD(T)].")
					msg_admin_ff("[ADMIN_TPMONTY(user)] flamed [ADMIN_TPMONTY(H)] with \a [name] in [ADMIN_VERBOSEJMP(T)].")
				else
					log_combat(user, H, "flamed", src)

			if(H.hard_armor.getRating("fire") >= 100)
				continue

		var/armor_block = M.run_armor_check(null, "fire")
		M.apply_damage(rand(burn,(burn*2))* fire_mod, BURN, null, armor_block) // Make it so its the amount of heat or twice it for the initial blast.
		UPDATEHEALTH(M)
		M.adjust_fire_stacks(rand(5,burn*2))
		M.IgniteMob()

		to_chat(M, "[isxeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!")

/obj/item/weapon/gun/flamer/proc/triangular_flame(atom/target, mob/living/user, burntime, burnlevel)
	set waitfor = 0

	var/unleash_dir = user.dir //don't want the player to turn around mid-unleash to bend the fire.
	var/list/turf/turfs = getline(user,target)
	playsound(user, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T

	for(var/turf/T in turfs)
		if(T == user.loc)
			prev_T = T
			continue
		if(T.density)
			break
		if(locate(/obj/effect/forcefield/fog) in T)
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
			if(prev_L && LinkBlocked(prev_L, L))
				break

			flame_turf(L, user, burntime, burnlevel, "green")
			prev_L = L
			sleep(1)

		distance++

/obj/item/weapon/gun/flamer/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/flamer/get_ammo_count()
	if(!current_mag)
		return 0
	else
		return current_mag.current_rounds


/obj/item/weapon/gun/flamer/M240T
	name = "\improper M240-T incinerator unit"
	desc = "An improved version of the M240A1 incinerator unit, the M240-T model is capable of dispersing a larger variety of fuel types. Contains an underbarrel fire extinguisher!"
	current_mag = /obj/item/ammo_magazine/flamer_tank/large
	icon_state = "m240t"
	item_state = "m240t"
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNTER
	var/max_water = 200
	var/last_use

/obj/item/weapon/gun/flamer/M240T/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(!magazine || !istype(magazine))
		to_chat(user, "<span class='warning'>That's not a magazine!</span>")
		return

	if(magazine.current_rounds <= 0)
		to_chat(user, "<span class='warning'>That [magazine.name] is empty!</span>")
		return

	if(!istype(src, magazine.gun_type))
		to_chat(user, "<span class='warning'>That magazine doesn't fit in there!</span>")
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		to_chat(user, "<span class='warning'>It's still got something loaded!</span>")
		return

	else
		if(user)
			if(magazine.reload_delay > 1)
				to_chat(user, "<span class='notice'>You begin reloading [src]. Hold still...</span>")
				if(do_after(user,magazine.reload_delay, TRUE, src, BUSY_ICON_GENERIC))
					replace_magazine(user, magazine)
				else
					to_chat(user, "<span class='warning'>Your reload was interrupted!</span>")
					return
			else
				replace_magazine(user, magazine)
		else
			current_mag = magazine
			magazine.loc = src
			replace_ammo(,magazine)

	update_icon()
	return TRUE


/obj/item/weapon/gun/flamer/M240T/able_to_fire(mob/user)
	. = ..()
	if(.)
		if(!current_mag || !current_mag.current_rounds)
			return

/obj/item/weapon/gun/flamer/M240T/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Its hydro cannon contains [M240T_WATER_AMOUNT]/[max_water] units of water!</span>")


/obj/item/weapon/gun/flamer/M240T/Initialize()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_water)
	reagents = R
	R.my_atom = src
	R.add_reagent(/datum/reagent/water, max_water)

	var/obj/item/attachable/hydro_cannon/G = new(src)
	G.icon_state = ""
	G.Attach(src)
	G.icon_state = initial(G.icon_state)

/obj/item/weapon/gun/flamer/M240T/Fire(atom/target, mob/living/user, params, reflex)
	if(active_attachable && istype(active_attachable, /obj/item/attachable/hydro_cannon) && (world.time > last_use + 10))
		extinguish(target,user) //Fire it.
		last_fired = world.time
		last_use = world.time
		return
	if(user.skills.getRating("firearms") < 0 && !do_after(user, 1 SECONDS, TRUE, src))
		return
	return ..()

/obj/item/weapon/gun/flamer/M240T/afterattack(atom/target, mob/user)
	. = ..()
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(user,target) <= 1)
		var/obj/o = target
		o.reagents.trans_to(src, max_water)
		to_chat(user, "<span class='notice'>\The [src]'s hydro cannon is refilled with water.</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return

/turf/proc/ignite(fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	//extinguish any flame present
	var/obj/flamer_fire/F = locate(/obj/flamer_fire) in src
	if(F)
		qdel(F)

	new /obj/flamer_fire(src, fire_lvl, burn_lvl, f_color, fire_stacks, fire_damage)

//////////////////////////////////////////////////////////////////////////////////////////////////
//Time to redo part of abby's code.
//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "red_2"
	layer = BELOW_OBJ_LAYER
	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.
	var/flame_color = "red"

/obj/flamer_fire/Initialize(mapload, fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0)
	. = ..()

	if(f_color)
		flame_color = f_color

	icon_state = "[flame_color]_2"
	if(fire_lvl)
		firelevel = fire_lvl
	if(burn_lvl)
		burnlevel = burn_lvl
	if(fire_stacks || fire_damage)
		for(var/mob/living/C in get_turf(src))
			C.flamer_fire_act(fire_stacks)

			var/armor_block = C.run_armor_check("chest", "fire")
			if(C.apply_damage(fire_damage, BURN, null, armor_block))
				UPDATEHEALTH(C)
			if(C.IgniteMob())
				C.visible_message("<span class='danger'>[C] bursts into flames!</span>","[isxeno(C)?"<span class='xenodanger'>":"<span class='highdanger'>"]You burst into flames!</span>")

	START_PROCESSING(SSobj, src)

/obj/flamer_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/flamer_fire/Crossed(mob/living/M) //Only way to get it to reliable do it when you walk into it.
	. = ..()
	if(istype(M))
		M.flamer_fire_crossed(burnlevel, firelevel)


// override this proc to give different walking-over-fire effects
/mob/living/proc/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	adjust_fire_stacks(burnlevel) //Make it possible to light them on fire later.
	if (prob(firelevel + 2*fire_stacks)) //the more soaked in fire you are, the likelier to be ignited
		IgniteMob()
	var/armor_block = run_armor_check(null, "fire")
	if(apply_damage(round(burnlevel*0.5)* fire_mod, BURN, null, armor_block))
		UPDATEHEALTH(src)
	to_chat(src, "<span class='danger'>You are burned!</span>")



/mob/living/carbon/human/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	if(hard_armor.getRating("fire") >= 100)
		var/armor_block = run_armor_check(null, "fire")
		if(apply_damage(round(burnlevel * 0.2) * fire_mod, BURN, null, armor_block))
			UPDATEHEALTH(src)
		return
	. = ..()
	if(isxeno(pulledby))
		var/mob/living/carbon/xenomorph/X = pulledby
		X.flamer_fire_crossed(burnlevel, firelevel)

/mob/living/carbon/xenomorph/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	fire_mod = fire_resist
	return ..()


/obj/flamer_fire/proc/updateicon()
	var/light_color = "LIGHT_COLOR_LAVA"
	var/light_intensity = 3
	switch(flame_color)
		if("red")
			light_color = LIGHT_COLOR_LAVA
		if("blue")
			light_color = LIGHT_COLOR_CYAN
		if("green")
			light_color = LIGHT_COLOR_GREEN
	switch(firelevel)
		if(1 to 9)
			icon_state = "[flame_color]_1"
			light_intensity = 2
		if(10 to 25)
			icon_state = "[flame_color]_2"
			light_intensity = 4
		if(25 to INFINITY) //Change the icons and luminosity based on the fire's intensity
			icon_state = "[flame_color]_3"
			light_intensity = 6
	set_light(light_intensity, null, light_color)

/obj/flamer_fire/process()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf?
		qdel(src)
		return

	updateicon()

	if(!firelevel)
		qdel(src)
		return

	T.flamer_fire_act(burnlevel, firelevel)

	var/j = 0
	for(var/i in T)
		if(++j >= 11)
			break
		var/atom/A = i
		if(QDELETED(A)) //The destruction by fire of one atom may destroy others in the same turf.
			continue
		A.flamer_fire_act(burnlevel, firelevel)

	firelevel -= 2 //reduce the intensity by 2 per tick
	return

// override this proc to give different idling-on-fire effects
/mob/living/flamer_fire_act(burnlevel, firelevel)
	if(hard_armor.getRating("fire") >= 100)
		to_chat(src, "<span class='warning'>Your suit protects you from most of the flames.</span>")
		adjustFireLoss(rand(0, burnlevel * 0.25)) //Does small burn damage to a person wearing one of the suits.
		return
	adjust_fire_stacks(burnlevel) //If i stand in the fire i deserve all of this. Also Napalm stacks quickly.
	if(prob(firelevel))
		IgniteMob()
	adjustFireLoss(rand(10 , burnlevel)) //Including the fire should be way stronger.
	to_chat(src, "<span class='warning'>You are burned!</span>")


/mob/living/carbon/xenomorph/flamer_fire_act(burnlevel, firelevel)
	if(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
		return
	. = ..()
	updatehealth()

/mob/living/carbon/xenomorph/queen/flamer_fire_act(burnlevel, firelevel)
	to_chat(src, "<span class='xenowarning'>Our extra-thick exoskeleton protects us from the flames.</span>")

/mob/living/carbon/xenomorph/ravager/flamer_fire_act(burnlevel, firelevel)
	if(stat)
		return
	plasma_stored = xeno_caste.plasma_max
	var/datum/action/xeno_action/charge = actions_by_path[/datum/action/xeno_action/activable/charge]
	if(charge)
		charge.clear_cooldown() //Reset charge cooldown
	to_chat(src, "<span class='xenodanger'>The heat of the fire roars in our veins! KILL! CHARGE! DESTROY!</span>")
	if(prob(70))
		emote("roar")
