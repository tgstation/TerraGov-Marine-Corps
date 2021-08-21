



//////////////////////////////////// dropship weapon ammunition ////////////////////////////

/obj/structure/ship_ammo
	icon = 'icons/Marine/mainship_props.dmi'
	density = TRUE
	anchored = TRUE
	throwpass = TRUE
	climbable = TRUE
	resistance_flags = XENO_DAMAGEABLE
	///Time before the ammo impacts
	var/travelling_time = 10 SECONDS
	///type of equipment that accept this type of ammo.
	var/equipment_type
	var/ammo_count
	var/max_ammo_count
	var/ammo_name = "round" //what to call the ammo in the ammo transfering message
	var/ammo_id
	///whether the ammo inside this magazine can be transfered to another magazine.
	var/transferable_ammo = FALSE
	///sound played mere seconds before impact
	var/warning_sound = 'sound/machines/hydraulics_2.ogg'
	var/ammo_used_per_firing = 1
	var/point_cost = 0 //how many points it costs to build this with the fabricator, set to 0 if unbuildable.
	///Type of ammo
	var/ammo_type


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
								to_chat(user, span_notice("You transfer [transf_amt] [ammo_name] to [src]."))
								if(!SA.ammo_count)
									PC.loaded = null
									PC.update_icon()
									qdel(SA)
				else
					forceMove(PC.linked_powerloader)
					PC.loaded = src
					playsound(loc, 'sound/machines/hydraulics_2.ogg', 40, 1)
					PC.update_icon()
					to_chat(user, span_notice("You grab [PC.loaded] with [PC]."))
					update_icon()
			return TRUE
		return ..()


	examine(mob/user)
		..()
		to_chat(user, "Moving this will require some sort of lifter.")

//what to show to the user that examines the weapon we're loaded on.
/obj/structure/ship_ammo/proc/show_loaded_desc(mob/user)
	to_chat(user, "It's loaded with \a [src].")

/obj/structure/ship_ammo/proc/detonate_on(turf/impact, attackdir = NORTH)
	return


//30mm gun

/obj/structure/ship_ammo/heavygun
	name = "\improper 30mm ammo crate"
	icon_state = "30mm_crate"
	desc = "A crate full of 30mm bullets used on the dropship heavy guns."
	equipment_type = /obj/structure/dropship_equipment/weapon/heavygun
	travelling_time =  6 SECONDS
	ammo_count = 200
	max_ammo_count = 200
	transferable_ammo = TRUE
	ammo_used_per_firing = 20
	point_cost = 75
	///Radius of the square that the bullets will strafe
	var/bullet_spread_range = 2
	///Width of the square we are attacking, so you can make rectangular attacks later
	var/attack_width = 3
	ammo_type = CAS_30MM

/obj/structure/ship_ammo/heavygun/examine(mob/user)
	. = ..()
	to_chat(user, "It has [ammo_count] round\s.")

/obj/structure/ship_ammo/heavygun/show_loaded_desc(mob/user)
	if(ammo_count)
		to_chat(user, "It's loaded with \a [src] containing [ammo_count] round\s.")
	else
		to_chat(user, "It's loaded with an empty [name].")

/obj/structure/ship_ammo/heavygun/detonate_on(turf/impact, attackdir = NORTH)
	playsound(impact, 'sound/effects/casplane_flyby.ogg', 40)
	var/turf/beginning = impact
	var/revdir = REVERSE_DIR(attackdir)
	for(var/i=0 to bullet_spread_range)
		beginning = get_step(beginning, revdir)
	var/list/strafelist = list(beginning)
	strafelist += get_step(beginning, turn(attackdir, 90))
	strafelist += get_step(beginning, turn(attackdir, -90)) //Build this list 3 turfs at a time for strafe_turfs
	for(var/b=0 to bullet_spread_range*2)
		beginning = get_step(beginning, attackdir)
		strafelist += beginning
		strafelist += get_step(beginning, turn(attackdir, 90))
		strafelist += get_step(beginning, turn(attackdir, -90))
	strafe_turfs(strafelist)

///Takes the top 3 turfs and miniguns them, then repeats until none left
/obj/structure/ship_ammo/heavygun/proc/strafe_turfs(list/strafelist)
	var/turf/strafed
	playsound(strafelist[1], get_sfx("explosion"), 40, 1, 20, falloff = 3)
	for(var/i=1 to attack_width)
		strafed = strafelist[1]
		strafelist -= strafed
		strafed.ex_act(EXPLODE_LIGHT)
		new /obj/effect/particle_effect/expl_particles(strafed)
		new /obj/effect/temp_visual/heavyimpact(strafed)
		for(var/atom/movable/AM AS in strafed)
			AM.ex_act(EXPLODE_LIGHT)

	if(length(strafelist))
		addtimer(CALLBACK(src, .proc/strafe_turfs, strafelist), 2)


/obj/structure/ship_ammo/heavygun/highvelocity
	name = "high-velocity 30mm ammo crate"
	icon_state = "30mm_crate_hv"
	desc = "A crate full of 30mm high-velocity bullets used on the dropship heavy guns."
	travelling_time = 5 SECONDS
	point_cost = 150

/obj/structure/ship_ammo/heavygun/railgun
	name = "Railgun Ammo"
	desc = "This is not meant to exist"
	ammo_count = 400
	max_ammo_count = 400
	ammo_used_per_firing = 40
	bullet_spread_range = 5
	point_cost = 0


//laser battery

/obj/structure/ship_ammo/laser_battery
	name = "high-capacity laser battery"
	icon_state = "laser_battery"
	desc = "A high-capacity laser battery used to power laser beam weapons."
	travelling_time = 1 SECONDS
	ammo_count = 100
	max_ammo_count = 100
	ammo_used_per_firing = 40
	equipment_type = /obj/structure/dropship_equipment/weapon/laser_beam_gun
	ammo_name = "charge"
	transferable_ammo = TRUE
	ammo_used_per_firing = 10
	warning_sound = 'sound/effects/nightvision.ogg'
	point_cost = 150
	///The length of the beam that will come out of when we fire do both ends xxxoxxx where o is where you click
	var/laze_radius = 4
	ammo_type = CAS_LASER_BATTERY

/obj/structure/ship_ammo/laser_battery/examine(mob/user)
	. = ..()
	to_chat(user, "It's at [round(100*ammo_count/max_ammo_count)]% charge.")


/obj/structure/ship_ammo/laser_battery/show_loaded_desc(mob/user)
	if(ammo_count)
		to_chat(user, "It's loaded with \a [src] at [round(100*ammo_count/max_ammo_count)]% charge.")
	else
		to_chat(user, "It's loaded with an empty [name].")


/obj/structure/ship_ammo/laser_battery/detonate_on(turf/impact, attackdir = NORTH)
	var/turf/beginning = impact
	var/turf/end = impact
	var/revdir = REVERSE_DIR(attackdir)
	for(var/i=0 to laze_radius)
		beginning = get_step(beginning, revdir)
		end = get_step(end, attackdir)
	var/list/turf/lazertargets = getline(beginning, end)
	process_lazer(lazertargets)
	if(!ammo_count)
		QDEL_IN(src, laze_radius+1) //deleted after last laser beam is fired and impact the ground.

///takes the top lazertarget on the stack and fires the lazer at it
/obj/structure/ship_ammo/laser_battery/proc/process_lazer(list/lazertargets)
	laser_burn(lazertargets[1])
	lazertargets -= lazertargets[1]
	if(length(lazertargets))
		INVOKE_NEXT_TICK(src, .proc/process_lazer, lazertargets)

///Lazer ammo acts on the turf passed in
/obj/structure/ship_ammo/laser_battery/proc/laser_burn(turf/T)
	playsound(T, 'sound/effects/pred_vision.ogg', 30, 1)
	for(var/mob/living/L in T)
		L.adjustFireLoss(120)
		L.adjust_fire_stacks(20)
		L.IgniteMob()
	T.ignite(5, 30) //short but intense


//Rockets

/obj/structure/ship_ammo/rocket
	name = "abstract rocket"
	icon_state = "single"
	icon = 'icons/Marine/mainship_props64.dmi'
	equipment_type = /obj/structure/dropship_equipment/weapon/rocket_pod
	ammo_count = 1
	max_ammo_count = 1
	ammo_name = "rocket"
	ammo_id = ""
	bound_width = 64
	bound_height = 32
	travelling_time = 4 SECONDS
	point_cost = 0
	ammo_type = CAS_MISSILE

/obj/structure/ship_ammo/rocket/detonate_on(turf/impact, attackdir = NORTH)
	qdel(src)


//this one is air-to-air only
/obj/structure/ship_ammo/rocket/widowmaker
	name = "\improper AIM-224 'Widowmaker'"
	desc = "The AIM-224 is the latest in air to air missile technology. Earning the nickname of 'Widowmaker' from various dropship pilots after improvements to its guidence warhead prevents it from being jammed leading to its high kill rate. Not well suited for ground bombardment, but its high velocity makes it reach its target quickly."
	icon_state = "widowmaker"
	travelling_time = 3 SECONDS //not powerful, but reaches target fast
	ammo_id = ""
	point_cost = 75

/obj/structure/ship_ammo/rocket/widowmaker/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, 2, 4, 6)
	qdel(src)

/obj/structure/ship_ammo/rocket/banshee
	name = "\improper AGM-227 'Banshee'"
	desc = "The AGM-227 missile is a mainstay of the overhauled dropship fleet against any mobile or armored ground targets. It's earned the nickname of 'Banshee' from the sudden wail that it emitts right before hitting a target. Useful to clear out large areas."
	icon_state = "banshee"
	ammo_id = "b"
	point_cost = 150

/obj/structure/ship_ammo/rocket/banshee/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, 2, 4, 7, 6, flame_range = 7) //more spread out, with flames
	qdel(src)

/obj/structure/ship_ammo/rocket/keeper
	name = "\improper GBU-67 'Keeper II'"
	desc = "The GBU-67 'Keeper II' is the latest in a generation of laser guided weaponry that spans all the way back to the 20th century. Earning its nickname from a shortening of 'Peacekeeper' which comes from the program that developed its guidance system and the various uses of it during peacekeeping conflicts. Its payload is designed to devastate armored targets."
	icon_state = "keeper"
	ammo_id = "k"
	point_cost = 300

/obj/structure/ship_ammo/rocket/keeper/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, 4, 5, 5, 6, small_animation = TRUE) //tighter blast radius, but more devastating near center
	qdel(src)


/obj/structure/ship_ammo/rocket/fatty
	name = "\improper SM-17 'Fatty'"
	desc = "The SM-17 'Fatty' is a cluster-bomb type ordnance that only requires laser-guidance when first launched."
	icon_state = "fatty"
	ammo_id = "f"
	point_cost = 200

/obj/structure/ship_ammo/rocket/fatty/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, 2, 3, 4) //first explosion is small to trick xenos into thinking its a minirocket.
	addtimer(CALLBACK(src, .proc/delayed_detonation, impact), 3 SECONDS)


/obj/structure/ship_ammo/rocket/fatty/proc/delayed_detonation(turf/impact)
	var/list/impact_coords = list(list(-3,3),list(0,4),list(3,3),list(-4,0),list(4,0),list(-3,-3),list(0,-4), list(3,-3))
	for(var/i=1 to 8)
		var/list/coords = impact_coords[i]
		var/turf/detonation_target = locate(impact.x+coords[1],impact.y+coords[2],impact.z)
		detonation_target.ceiling_debris_check(2)
		explosion(detonation_target, 2, 3, 4, adminlog = FALSE, small_animation = TRUE)
	qdel(src)

/obj/structure/ship_ammo/rocket/napalm
	name = "\improper XN-99 'Napalm'"
	desc = "The XN-99 'Napalm' is an incendiary rocket used to turn specific targeted areas into giant balls of fire for a long time."
	icon_state = "napalm"
	ammo_id = "n"
	point_cost = 200

/obj/structure/ship_ammo/rocket/napalm/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(3)
	explosion(impact, 2, 3, 4, 6, small_animation = TRUE) //relatively weak
	flame_radius(5, impact, 60, 30) //cooking for a long time
	var/datum/effect_system/smoke_spread/phosphorus/warcrime = new
	warcrime.set_up(6, impact, 7)
	warcrime.start()
	qdel(src)


//minirockets

/obj/structure/ship_ammo/minirocket
	name = "mini rocket stack"
	desc = "A pack of laser guided mini rockets."
	icon_state = "minirocket"
	icon = 'icons/Marine/mainship_props.dmi'
	equipment_type = /obj/structure/dropship_equipment/weapon/minirocket_pod
	ammo_count = 6
	max_ammo_count = 6
	ammo_name = "minirocket"
	travelling_time = 4 SECONDS
	transferable_ammo = TRUE
	point_cost = 100
	ammo_type = CAS_MINI_ROCKET

/obj/structure/ship_ammo/minirocket/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, 0, 2, 4, 2, adminlog = FALSE, small_animation = TRUE)//no messaging admin, that'd spam them.
	var/datum/effect_system/expl_particles/P = new
	P.set_up(4, 0, impact)
	P.start()
	addtimer(CALLBACK(src, .proc/delayed_smoke_spread, impact), 0.5 SECONDS)
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last minirocket has fired and impacted the ground.

/obj/structure/ship_ammo/minirocket/proc/delayed_smoke_spread(turf/impact)
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(1, impact)
	S.start()

/obj/structure/ship_ammo/minirocket/show_loaded_desc(mob/user)
	if(ammo_count)
		to_chat(user, "It's loaded with \a [src] containing [ammo_count] minirocket\s.")

/obj/structure/ship_ammo/minirocket/examine(mob/user)
	. = ..()
	to_chat(user, "It has [ammo_count] minirocket\s.")


/obj/structure/ship_ammo/minirocket/incendiary
	name = "incendiary mini rocket stack"
	desc = "A pack of laser guided incendiary mini rockets."
	icon_state = "minirocket_inc"
	point_cost = 200

/obj/structure/ship_ammo/minirocket/incendiary/detonate_on(turf/impact, attackdir = NORTH)
	. = ..()
	flame_radius(3, impact)

/obj/structure/ship_ammo/minirocket/smoke
	name = "smoke mini rocket stack"
	desc = "A pack of laser guided screening smoke mini rockets."
	icon_state = "minirocket_smoke"
	point_cost = 25

/obj/structure/ship_ammo/minirocket/smoke/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, 0, 0, 2, 2, throw_range = 0)// Smaller explosion
	var/datum/effect_system/expl_particles/P = new
	P.set_up(4, 0, impact)
	P.start()
	var/datum/effect_system/smoke_spread/tactical/S = new
	S.set_up(7, impact)// Large radius, but dissipates quickly
	S.start()

/obj/structure/ship_ammo/minirocket/tangle
	name = "Tanglefoot mini rocket stack"
	desc = "A pack of laser guided mini rockets loaded with plasma-draining Tanglefoot gas."
	icon_state = "minirocket_tfoot"
	point_cost = 50

/obj/structure/ship_ammo/minirocket/tangle/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	explosion(impact, 0, 0, 2, 2, throw_range = 0)// Smaller explosion
	var/datum/effect_system/expl_particles/P = new
	P.set_up(4, 0, impact)
	P.start()
	var/datum/effect_system/smoke_spread/plasmaloss/S = new
	S.set_up(9, impact, 9)// Between grenade and mortar
	S.start()

/obj/structure/ship_ammo/minirocket/illumination
	name = "illumination rocket-launched flare stack"
	desc = "A pack of laser guided mini rockets, each loaded with a payload of white-star illuminant and a parachute, while extremely ineffective at damaging the enemy, it is very effective at lighting the battlefield so marines can damage the enemy."
	icon_state = "minirocket_ilm"
	point_cost = 25 // Not a real rocket, so its cheap

/obj/structure/ship_ammo/minirocket/illumination/detonate_on(turf/impact, attackdir = NORTH)
	impact.ceiling_debris_check(2)
	var/turf/offset_impact = pick(range(3, impact))
	explosion(offset_impact, 0, 0, 2, 2, throw_range = 0)// Smaller explosion to prevent this becoming the PO meta
	var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
	P.set_up(4, 0, offset_impact)
	P.start()
	addtimer(CALLBACK(src, .proc/delayed_smoke_spread, offset_impact), 0.5 SECONDS)
	addtimer(CALLBACK(src, .proc/drop_cas_flare, offset_impact), 1.5 SECONDS)
	if(!ammo_count)
		QDEL_IN(src, travelling_time) //deleted after last minirocket has fired and impacted the ground.

/obj/structure/ship_ammo/minirocket/illumination/proc/drop_cas_flare(turf/impact)
	new /obj/effect/cas_flare(impact)

/obj/effect/cas_flare
	name = "illumination flare"
	desc = "Report this if you actually see this FUCK"
	icon_state = "" //No sprite
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = RESIST_ALL
	light_color = COLOR_VERY_SOFT_YELLOW
	light_system = HYBRID_LIGHT
	light_power = 8 //Magnesium/sodium fires (White star) really are bright

/obj/effect/cas_flare/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	set_light(light_power)
	T.visible_message(span_warning("You see a tiny flash, and then a blindingly bright light from a flare as it lights off in the sky!"))
	playsound(T, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4) // stolen from the mortar i'm not even sorry
	QDEL_IN(src, rand(70 SECONDS, 90 SECONDS)) // About the same burn time as a flare, considering it requires it's own CAS run.
