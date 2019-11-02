/obj/vehicle/unmanned
	name = "light unmanned vehicle"
	anchored = FALSE
	can_buckle = FALSE
	light_range = 6
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"
	move_delay = 1.8	//set this to limit the speed of the vehicle
	max_integrity = 200
	var/fire_delay = 5
	var/last_fired = 0
	var/current_rounds
	var/max_rounds = 300
	var/datum/ammo/bullet/ammo = /datum/ammo/bullet/smg
	var/obj/item/projectile/in_chamber = null

/obj/vehicle/unmanned/Initialize()
	. = ..()
	current_rounds = max_rounds
	ammo = GLOB.ammo_list[ammo]

/obj/vehicle/unmanned/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	create_bullet()
	return TRUE


/obj/vehicle/unmanned/proc/create_bullet()
	if(current_rounds == 0)
		return FALSE
	in_chamber = new /obj/item/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)

/obj/vehicle/unmanned/proc/fire_shot(atom/target, mob/user)
	if(world.time <= last_fired + fire_delay)
		return
	if(load_into_chamber())
		if(istype(in_chamber,/obj/item/projectile))
			//Setup projectile
			in_chamber.original_target = target
			in_chamber.def_zone = pick("chest","chest","chest","head")
			//Shoot at the thing
			playsound(loc, 'sound/weapons/guns/fire/rifle.ogg', 75, 1)
			in_chamber.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
			in_chamber = null
			last_fired = world.time
			current_rounds--
	return TRUE


/obj/vehicle/unmanned/heavy
	name = "heavy unmanned vehicle"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"
	move_delay = 3.5	
	max_rounds = 200
	ammo = /datum/ammo/bullet/machinegun