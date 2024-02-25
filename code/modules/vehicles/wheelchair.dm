/obj/vehicle/ridden/wheelchair //ported from Hippiestation (by Jujumatic)
	name = "wheelchair"
	desc = "A chair with big wheels. It looks like you can move in this on your own."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "wheelchair"
	layer = OBJ_LAYER
	max_integrity = 100
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 30, FIRE = 60, ACID = 60) //Wheelchairs aren't super tough yo
	density = FALSE //Thought I couldn't fix this one easily, phew
	drag_delay = 1 //pulling something on wheels is easy
	/// Run speed delay is multiplied with this for vehicle move delay.
	var/delay_multiplier = 6.7
	/// This variable is used to specify which overlay icon is used for the wheelchair, ensures wheelchair can cover your legs
	var/overlay_icon = "wheelchair_overlay"
	var/image/wheels_overlay

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	make_ridable()
	wheels_overlay = image(icon, overlay_icon, FLY_LAYER)
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, PROC_REF(can_user_rotate)),CALLBACK(src, PROC_REF(can_be_rotated)),null)

/obj/vehicle/ridden/wheelchair/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	new /obj/item/stack/rods(drop_location(), 1)
	return ..()

/obj/vehicle/ridden/wheelchair/Moved()
	. = ..()
	playsound(src, 'sound/effects/roll.ogg', 75, TRUE)


/obj/vehicle/ridden/wheelchair/post_buckle_mob(mob/living/user)
	. = ..()
	update_icon()

/obj/vehicle/ridden/wheelchair/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_icon()

/obj/vehicle/ridden/wheelchair/after_add_occupant(mob/M)
	. = ..()
	if(isliving(M)) //Properly update whether we're lying or not; no more people lying on chairs; ridiculous
		var/mob/living/buckled_target = M
		buckled_target.set_lying_angle(0)

/obj/vehicle/ridden/wheelchair/after_remove_occupant(mob/M)
	. = ..()
	if(isliving(M)) //Properly update whether we're lying or not
		var/mob/living/unbuckled_target = M
		if(HAS_TRAIT(unbuckled_target, TRAIT_FLOORED))
			unbuckled_target.set_lying_angle(pick(90, 270))

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

// Battlechair - A wheelchair with a mounted minigun
/obj/vehicle/ridden/wheelchair/weaponized
	name = "\improper Battlechair"
	desc = "A sturdy wheelchair fitted with a minigun. Your legs may have failed you, but your weapon won't."
	max_integrity = 400

/obj/vehicle/ridden/wheelchair/weaponized/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/vehicle_mounted_weapon, /obj/item/weapon/gun/minigun/one_handed)

/obj/vehicle/ridden/wheelchair/weaponized/auto_assign_occupant_flags(mob/M)
	. = ..()
	add_control_flags(M, VEHICLE_CONTROL_EQUIPMENT)
