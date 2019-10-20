/obj/unmanned_vehicle
	name = "unmanned vehicle"
	layer = ABOVE_MOB_LAYER //so it sits above objects including mobs
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"
	animate_movement = FORWARD_STEPS
	var/move_delay = 3	//set this to limit the speed of the vehicle
	var/datum/ammo/bullet/machinegun/ammo = /datum/ammo/bullet/machinegun
	var/obj/item/projectile/in_chamber = null

/obj/unmanned_vehicle/Initialize()
	. = ..()
	ammo = GLOB.ammo_list[ammo]

/obj/unmanned_vehicle/relaymove(mob/user, direction)
	if(world.time <= last_move_time + move_delay)
		return

	step(src, direction)


/obj/unmanned_vehicle/proc/handle_click(mob/user, params, atom/object)
	to_chat(world, "vehicle handle_click")
	fire_shot(object)

/obj/unmanned_vehicle/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	to_chat(world, "Creating Bullet")
	create_bullet()
	return TRUE


/obj/unmanned_vehicle/proc/create_bullet()
	in_chamber = new /obj/item/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)
	to_chat(world, "Bullet Created")

/obj/unmanned_vehicle/proc/fire_shot(atom/target)
	if(load_into_chamber())
		if(istype(in_chamber,/obj/item/projectile))
			//Setup projectile
			in_chamber.original_target = target
			in_chamber.def_zone = pick("chest","chest","chest","head")
			//Shoot at the thing
			playsound(loc, 'sound/weapons/guns/fire/rifle.ogg', 75, 1)
			in_chamber.fire_at(target, src, src, ammo.max_range, ammo.shell_speed)
			in_chamber = null
	return TRUE
