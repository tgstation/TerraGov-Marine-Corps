/obj/vehicle/ridden/wheelchair //ported from Hippiestation (by Jujumatic)
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 30, FIRE = 60, ACID = 60) //Wheelchairs aren't super tough yo
	density = FALSE //Thought I couldn't fix this one easily, phew
	/// Run speed delay is multiplied with this for vehicle move delay.
	var/delay_multiplier = 6.7
	/// This variable is used to specify which overlay icon is used for the wheelchair, ensures wheelchair can cover your legs
	var/overlay_icon = "wheelchair_overlay"
	var/image/wheels_overlay

/obj/vehicle/ridden/wheelchair/Initialize()
	. = ..()
	make_ridable()
	wheels_overlay = image(icon, overlay_icon, FLY_LAYER)
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, .proc/can_user_rotate),CALLBACK(src, .proc/can_be_rotated),null)

/obj/vehicle/ridden/wheelchair/obj_destruction(damage_flag)
	new /obj/item/stack/rods(drop_location(), 1)
	return ..()

/obj/vehicle/ridden/wheelchair/Moved()
	. = ..()
	playsound(src, 'sound/effects/roll.ogg', 75, TRUE)


/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	update_icon()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob()
	. = ..()
	update_icon()

/obj/vehicle/ridden/wheelchair/wrench_act(mob/living/user, obj/item/I) //Attackby should stop it attacking the wheelchair after moving away during decon
	..()
	to_chat(user, span_notice("You begin to detach the wheels..."))
	if(I.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You detach the wheels and deconstruct the chair."))
		new /obj/item/stack/rods(drop_location(), 6)
		qdel(src)
	return TRUE

/obj/vehicle/ridden/wheelchair/update_overlays()
	. = ..()
	if(LAZYLEN(buckled_mobs))
		. += wheels_overlay


///used for simple rotation component checks
/obj/vehicle/ridden/wheelchair/proc/can_be_rotated(mob/living/user)
	return TRUE

///used in simple rotation component checks as to whether a user can rotate this chair
/obj/vehicle/ridden/wheelchair/proc/can_user_rotate(mob/living/user)
	var/mob/living/L = user
	if(istype(L))
		if(!user.Adjacent(src))
			return FALSE
	return FALSE

/// I assign the ridable element in this so i don't have to fuss with hand wheelchairs and motor wheelchairs having different subtypes
/obj/vehicle/ridden/wheelchair/proc/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair)

