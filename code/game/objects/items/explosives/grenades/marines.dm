
///***GRENADES***///
/obj/item/explosive/grenade/frag
	name = "\improper M40 HEDP grenade"
	desc = "A small, but deceptively strong fragmentation grenade that has been phasing out the M15 Fragmentation Grenades. Capable of being loaded in the M92 Launcher, or thrown by hand."
	icon_state = "grenade"
	det_time = 40
	item_state = "grenade"
	dangerous = 1
	underslug_launchable = TRUE

/obj/item/explosive/grenade/frag/prime()
	spawn(0)
		explosion(loc, -1, -1, 3)
		cdel(src)
	return

/obj/item/explosive/grenade/frag/flamer_fire_act()
	var/turf/T = loc
	cdel(src)
	explosion(T, -1, -1, 3)



/obj/item/explosive/grenade/frag/training
	name = "M07 training grenade"
	desc = "A harmless reusable version of the M40 HEDP, used for training. Capable of being loaded in the M92 Launcher, or thrown by hand."
	icon_state = "training_grenade"
	item_state = "grenade"
	dangerous = 0

/obj/item/explosive/grenade/frag/training/prime()
	spawn(0)
		playsound(loc, 'sound/items/detector.ogg', 80, 0, 7)
		active = 0 //so we can reuse it
		overlays.Cut()
		icon_state = initial(icon_state)
		det_time = initial(det_time) //these can be modified when fired by UGL
		throw_range = initial(throw_range)


/obj/item/explosive/grenade/frag/training/flamer_fire_act()
	return



/obj/item/explosive/grenade/frag/PMC
	desc = "A fragmentation grenade produced for private security firms. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_pmc"
	item_state = "grenade_ex"
	underslug_launchable = FALSE


	prime()
		spawn(0)
			explosion(loc, -1, -1, 4)
			cdel(src)
		return

/obj/item/explosive/grenade/frag/m15
	name = "\improper M15 fragmentation grenade"
	desc = "An outdated USCM Fragmentation Grenade. With decades of service in the USCM, the old M15 Fragmentation Grenade is slowly being replaced with the slightly safer M40 HEDP. It is set to detonate in 4 seconds."
	icon_state = "grenade_ex"
	item_state = "grenade_ex"
	underslug_launchable = FALSE

	prime()
		spawn(0)
			explosion(loc, -1, -1, 4)
			cdel(src)
		return

/obj/item/explosive/grenade/frag/stick
	name = "\improper Webley Mk15 stick grenade"
	desc = "A fragmentation grenade produced in the colonies, most commonly using old designs and schematics. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_stick"
	item_state = "grenade_stick"
	force = 10
	w_class = 2
	throwforce = 15
	throw_speed = 2
	throw_range = 7
	underslug_launchable = FALSE

	prime()
		spawn(0)
			explosion(src.loc,-1,-1,3)
			del(src)
		return

/obj/item/explosive/grenade/frag/upp
	name = "\improper Type 5 shrapnel grenade"
	desc = "A fragmentation grenade found within the ranks of the UPP. Designed to explode into shrapnel and rupture the bodies of opponents. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_upp"
	item_state = "grenade_upp"
	throw_speed = 2
	throw_range = 6
	underslug_launchable = FALSE

	prime()
		spawn(0)
			explosion(src.loc,-1,-1,3)
			del(src)
		return

/obj/item/explosive/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon_state = "grenade_fire"
	det_time = 40
	item_state = "grenade_fire"
	flags_equip_slot = SLOT_WAIST
	dangerous = 1
	underslug_launchable = TRUE

	prime()
		spawn(0)
			flame_radius(2, get_turf(src))
			playsound(src.loc, 'sound/weapons/gun_flamethrower2.ogg', 35, 1, 4)
			cdel(src)
		return

proc/flame_radius(radius = 1, turf/turf) //~Art updated fire.
	if(!turf || !isturf(turf)) return
	if(radius < 0) radius = 0
	if(radius > 5) radius = 5
	new /obj/flamer_fire(turf, 5 + rand(0,11), 15, null, radius)


/obj/item/explosive/grenade/incendiary/molotov
	name = "\improper improvised firebomb"
	desc = "A potent, improvised firebomb, coupled with a pinch of gunpowder. Cheap, very effective, and deadly in confined spaces. Commonly found in the hands of rebels and terrorists. It can be difficult to predict how many seconds you have before it goes off, so be careful. Chances are, it might explode in your face."
	icon_state = "molotov"
	item_state = "molotov"
	arm_sound = 'sound/items/Welder2.ogg'
	underslug_launchable = FALSE
	New()
		det_time = rand(10,40)//Adds some risk to using this thing.
		..()

	prime()
		spawn(0)
			playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 35, 1, 4)
			flame_radius(2, get_turf(src))
			playsound(src.loc, 'sound/weapons/gun_flamethrower2.ogg', 30, 1, 4)
			cdel(src)
		return


/obj/item/explosive/grenade/smokebomb
	name = "\improper M40 HSDP smoke grenade"
	desc = "The M40 HSDP is a small, but powerful smoke grenade. Based off the same platform as the M40 HEDP. It is set to detonate in 2 seconds."
	icon_state = "grenade_smoke"
	det_time = 20
	item_state = "grenade_smoke"
	underslug_launchable = TRUE
	var/datum/effect_system/smoke_spread/bad/smoke

	New()
		..()
		smoke = new /datum/effect_system/smoke_spread/bad
		smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
		smoke.set_up(3, 0, usr.loc, null, 6)
		smoke.start()
		cdel(src)

/obj/item/explosive/grenade/phosphorus
	name = "\improper M40 HPDP grenade"
	desc = "The M40 HPDP is a small, but powerful phosphorus grenade. It is set to detonate in 2 seconds."
	icon_state = "grenade_phos"
	det_time = 20
	item_state = "grenade_phos"
	underslug_launchable = TRUE
	var/datum/effect_system/smoke_spread/phosphorus/smoke
	dangerous = 1

	New()
		..()
		smoke = new /datum/effect_system/smoke_spread/phosphorus
		smoke.attach(src)

	prime()
		playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
		smoke.set_up(3, 0, usr.loc)
		smoke.start()
		cdel(src)

/obj/item/explosive/grenade/phosphorus/upp
	name = "\improper Type 8 WP grenade"
	desc = "A deadly gas grenade found within the ranks of the UPP. Designed to spill white phosporus on the target. It explodes 2 seconds after the pin has been pulled."
	icon_state = "grenade_upp_wp"
	item_state = "grenade_upp_wp"
