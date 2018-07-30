



//////////////////////////////////// dropship weapon ammunition ////////////////////////////

/obj/structure/ship_ammo
	icon = 'icons/Marine/almayer_props.dmi'
	density = TRUE
	anchored = TRUE
	throwpass = TRUE
	climbable = TRUE
	var/travelling_time = 100 //time to impact
	var/equipment_type //type of equipment that accept this type of ammo.
	var/ammo_count
	var/max_ammo_count
	var/ammo_name = "round" //what to call the ammo in the ammo transfering message
	var/ammo_id
	var/transferable_ammo = FALSE //whether the ammo inside this magazine can be transfered to another magazine.
	var/accuracy_range = 3 //how many tiles the ammo can deviate from the laser target
	var/warning_sound = 'sound/machines/hydraulics_2.ogg' //sound played mere seconds before impact
	var/ammo_used_per_firing = 1
	var/max_inaccuracy = 6 //what's the max deviation allowed when the ammo is no longer guided by a laser.
	var/point_cost = 0 //how many points it costs to build this with the fabricator, set to 0 if unbuildable.


	attackby(obj/item/I, mob/user)

		if(istype(I, /obj/item/powerloader_clamp))
			var/obj/item/powerloader_clamp/PC = I
			if(PC.linked_powerloader)
				if(PC.loaded)
					if(istype(PC.loaded, /obj/structure/ship_ammo))
						var/obj/structure/ship_ammo/SA = PC.loaded
						if(SA.transferable_ammo && SA.ammo_count > 0 && SA.type == type)
							if(ammo_count < max_ammo_count)
								var/transf_amt = min(max_ammo_count - ammo_count, SA.ammo_count)
								ammo_count += transf_amt
								SA.ammo_count -= transf_amt
								playsound(loc, 'sound/machines/hydraulics_1.ogg', 40, 1)
								user << "<span class='notice'>You transfer [transf_amt] [ammo_name] to [src].</span>"
								if(!SA.ammo_count)
									PC.loaded = null
									PC.update_icon()
									cdel(SA)
				else
					forceMove(PC.linked_powerloader)
					PC.loaded = src
					playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
					PC.update_icon()
					user << "<span class='notice'>You grab [PC.loaded] with [PC].</span>"
					update_icon()
			return TRUE
		. = ..()


	examine(mob/user)
		..()
		user << "Moving this will require some sort of lifter."

//what to show to the user that examines the weapon we're loaded on.
/obj/structure/ship_ammo/proc/show_loaded_desc(mob/user)
	user << "It's loaded with \a [src]."
	return

/obj/structure/ship_ammo/proc/detonate_on(turf/impact)
	return



//30mm gun

/obj/structure/ship_ammo/heavygun
	name = "\improper 30mm ammo crate"
	icon_state = "30mm_crate"
	desc = "A crate full of 30mm bullets used on the dropship heavy guns."
	equipment_type = /obj/structure/dropship_equipment/weapon/heavygun
	ammo_count = 200
	max_ammo_count = 200
	transferable_ammo = TRUE
	ammo_used_per_firing = 20
	point_cost = 150
	var/bullet_spread_range = 4 //how far from the real impact turf can bullets land

	examine(mob/user)
		..()
		user << "It has [ammo_count] round\s."

	show_loaded_desc(mob/user)
		if(ammo_count)
			user << "It's loaded with \a [src] containing [ammo_count] round\s."
		else
			user << "It's loaded with an empty [name]."

	detonate_on(turf/impact)
		set waitfor = 0
		var/list/turf_list = list()
		for(var/turf/T in range(impact, bullet_spread_range))
			turf_list += T
		var/soundplaycooldown = 0
		var/debriscooldown = 0
		for(var/i=1, i<=ammo_used_per_firing, i++)
			var/turf/U = pick(turf_list)
			turf_list -= U
			sleep(1)
			U.ex_act(3)
			for(var/atom/movable/AM in U)
				AM.ex_act(3)
			if(!soundplaycooldown) //so we don't play the same sound 20 times very fast.
				playsound(U, get_sfx("explosion"), 40, 1, 20, falloff = 3)
				soundplaycooldown = 3
			soundplaycooldown--
			if(!debriscooldown)
				U.ceiling_debris_check(1)
				debriscooldown = 6
			debriscooldown--
			new /obj/effect/particle_effect/expl_particles(U)


/obj/structure/ship_ammo/heavygun/highvelocity
	name = "high-velocity 30mm ammo crate"
	icon_state = "30mm_crate_hv"
	desc = "A crate full of 30mm high-velocity bullets used on the dropship heavy guns."
	travelling_time = 60
	ammo_count = 400
	max_ammo_count = 400
	ammo_used_per_firing = 40
	bullet_spread_range = 5
	point_cost = 300



//laser battery

/obj/structure/ship_ammo/laser_battery
	name = "high-capacity laser battery"
	icon_state = "laser_battery"
	desc = "A high-capacity laser battery used to power laser beam weapons."
	travelling_time = 10
	ammo_count = 100
	max_ammo_count = 100
	ammo_used_per_firing = 40
	equipment_type = /obj/structure/dropship_equipment/weapon/laser_beam_gun
	ammo_name = "charge"
	transferable_ammo = TRUE
	accuracy_range = 1
	ammo_used_per_firing = 10
	max_inaccuracy = 1
	warning_sound = 'sound/effects/nightvision.ogg'
	point_cost = 300


/obj/structure/ship_ammo/laser_battery/examine(mob/user)
	..()
	user << "It's at [round(100*ammo_count/max_ammo_count)]% charge."


/obj/structure/ship_ammo/laser_battery/show_loaded_desc(mob/user)
	if(ammo_count)
		user << "It's loaded with \a [src] at [round(100*ammo_count/max_ammo_count)]% charge."
	else
		user << "It's loaded with an empty [name]."


/obj/structure/ship_ammo/laser_battery/detonate_on(turf/impact)
	set waitfor = 0
	var/list/turf_list = list()
	for(var/turf/T in range(impact, 3))
		turf_list += T
	var/soundplaycooldown = 0
	for(var/i=1 to 20)
		var/turf/U = pick(turf_list)
		turf_list -= U
		sleep(1)
		laser_burn(U)
		if(!soundplaycooldown) //so we don't play the same sound 20 times very fast.
			playsound(U, 'sound/effects/pred_vision.ogg', 20, 1)
			soundplaycooldown = 3
		soundplaycooldown--

	if(!ammo_count && !disposed)
		cdel(src) //deleted after last laser beam is fired and impact the ground.



/obj/structure/ship_ammo/laser_battery/proc/laser_burn(turf/T)
	for(var/mob/living/L in T)
		L.adjustFireLoss(120)
		L.adjust_fire_stacks(20)
		L.IgniteMob()
	if(!locate(/obj/flamer_fire) in T)
		new/obj/flamer_fire(T, 5, 30) //short but intense


//Rockets

/obj/structure/ship_ammo/rocket
	name = "abstract rocket"
	icon_state = "single"
	icon = 'icons/Marine/almayer_props64.dmi'
	equipment_type = /obj/structure/dropship_equipment/weapon/rocket_pod
	ammo_count = 1
	max_ammo_count = 1
	ammo_name = "rocket"
	ammo_id = ""
	bound_width = 64
	bound_height = 32
	travelling_time = 60 //faster than 30mm rounds
	max_inaccuracy = 5
	point_cost = 0

	detonate_on(turf/impact)
		cdel(src)


//this one is air-to-air only
/obj/structure/ship_ammo/rocket/widowmaker
	name = "\improper AIM-224 'Widowmaker'"
	desc = "The AIM-224 is the latest in air to air missile technology. Earning the nickname of 'Widowmaker' from various dropship pilots after improvements to its guidence warhead prevents it from being jammed leading to its high kill rate. Not well suited for ground bombardment, but its high velocity makes it reach its target quickly."
	icon_state = "single"
	travelling_time = 30 //not powerful, but reaches target fast
	ammo_id = ""
	point_cost = 300

	detonate_on(turf/impact)
		impact.ceiling_debris_check(3)
		spawn(5)
			explosion(impact,1,3,5)
			cdel(src)

/obj/structure/ship_ammo/rocket/banshee
	name = "\improper AGM-227 'Banshee'"
	desc = "The AGM-227 missile is a mainstay of the overhauled dropship fleet against any mobile or armored ground targets. It's earned the nickname of 'Banshee' from the sudden wail that it emitts right before hitting a target. Useful to clear out large areas."
	icon_state = "banshee"
	ammo_id = "b"
	point_cost = 300

	detonate_on(turf/impact)
		impact.ceiling_debris_check(3)
		spawn(5)
			explosion(impact,1,3,6,6,1,0,7) //more spread out, with flames
			cdel(src)

/obj/structure/ship_ammo/rocket/keeper
	name = "\improper GBU-67 'Keeper II'"
	desc = "The GBU-67 'Keeper II' is the latest in a generation of laser guided weaponry that spans all the way back to the 20th century. Earning its nickname from a shortening of 'Peacekeeper' which comes from the program that developed its guidance system and the various uses of it during peacekeeping conflicts. Its payload is designed to devastate armored targets."
	icon_state = "paveway"
	ammo_id = "k"
	point_cost = 300

	detonate_on(turf/impact)
		impact.ceiling_debris_check(3)
		spawn(5)
			explosion(impact,3,4,4,6) //tighter blast radius, but more devastating near center
			cdel(src)


/obj/structure/ship_ammo/rocket/fatty
	name = "\improper SM-17 'Fatty'"
	desc = "The SM-17 'Fatty' is a cluster-bomb type ordnance that only requires laser-guidance when first launched."
	icon_state = "fatty"
	ammo_id = "f"
	travelling_time = 70 //slower but deadly accurate, even if laser guidance is stopped mid-travel.
	max_inaccuracy = 1
	point_cost = 450

	detonate_on(turf/impact)
		set waitfor = 0
		impact.ceiling_debris_check(2)
		spawn(5)
			explosion(impact,1,2,3) //first explosion is small to trick xenos into thinking its a minirocket.
		sleep(20)
		var/list/impact_coords = list(list(-3,3),list(0,4),list(3,3),list(-4,0),list(4,0),list(-3,-3),list(0,-4), list(3,-3))
		var/turf/T
		var/list/coords
		for(var/i=1 to 8)
			coords = impact_coords[i]
			T = locate(impact.x+coords[1],impact.y+coords[2],impact.z)
			T.ceiling_debris_check(2)
			spawn(5)
				explosion(T,1,2,3)
		cdel(src)

/obj/structure/ship_ammo/rocket/napalm
	name = "\improper XN-99 'Napalm'"
	desc = "The XN-99 'Napalm' is an incendiary rocket used to turn specific targeted areas into giant balls of fire for a long time."
	icon_state = "napalm"
	ammo_id = "n"
	point_cost = 500

	detonate_on(turf/impact)
		impact.ceiling_debris_check(3)
		spawn(5)
			explosion(impact,1,2,3,6,1,0) //relatively weak
			for(var/turf/T in range(4,impact))
				if(!locate(/obj/flamer_fire) in T) // No stacking flames!
					new/obj/flamer_fire(T, 60, 30) //cooking for a long time
			cdel(src)



//minirockets

/obj/structure/ship_ammo/minirocket
	name = "mini rocket stack"
	desc = "A pack of laser guided mini rockets."
	icon_state = "minirocket"
	icon = 'icons/Marine/almayer_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/weapon/minirocket_pod
	ammo_count = 6
	max_ammo_count = 6
	ammo_name = "minirocket"
	travelling_time = 80 //faster than 30mm cannon, slower than real rockets
	transferable_ammo = TRUE
	point_cost = 300

	detonate_on(turf/impact)
		impact.ceiling_debris_check(2)
		spawn(5)
			explosion(impact,-1,1,3, 5, 0)//no messaging admin, that'd spam them.
			var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
			P.set_up(4, 0, impact)
			P.start()
			spawn(5)
				var/datum/effect_system/smoke_spread/S = new/datum/effect_system/smoke_spread()
				S.set_up(1,0,impact,null)
				S.start()
			if(!ammo_count && loc)
				cdel(src) //deleted after last minirocket is fired and impact the ground.

	show_loaded_desc(mob/user)
		if(ammo_count)
			user << "It's loaded with \a [src] containing [ammo_count] minirocket\s."

	examine(mob/user)
		..()
		user << "It has [ammo_count] minirocket\s."


/obj/structure/ship_ammo/minirocket/incendiary
	name = "incendiary mini rocket stack"
	desc = "A pack of laser guided incendiary mini rockets."
	icon_state = "minirocket_inc"
	point_cost = 500

	detonate_on(turf/impact)
		..()
		spawn(5)
			for(var/turf/T in range(2, impact))
				if(!locate(/obj/flamer_fire) in T) // No stacking flames!
					new/obj/flamer_fire(T)