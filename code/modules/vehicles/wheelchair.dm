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

/obj/vehicle/ridden/wheelchair/Initialize(mapload)
	. = ..()
	make_ridable()
	wheels_overlay = image(icon, overlay_icon, FLY_LAYER)
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE, CALLBACK(src, PROC_REF(can_user_rotate)),CALLBACK(src, PROC_REF(can_be_rotated)),null)

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



/* Battlechair - A wheelchair with a mounted minigun */
/obj/vehicle/ridden/wheelchair/weaponized
	name = "\improper Battlechair"
	desc = "A sturdy wheelchair fitted with a minigun. Your legs may have failed you, but your weapon won't."
	max_integrity = 400

	///Reference to the mounted weapon
	var/obj/item/weapon/gun/minigun_wheelchair/weapon

/obj/vehicle/ridden/wheelchair/weaponized/examine(mob/user)
	. = ..()
	. += span_notice("Drag to yourself to unload the mounted weapon.")
	. += "Ammo: [span_bold("[weapon.rounds]/[weapon.max_rounds]")]"

/obj/vehicle/ridden/wheelchair/weaponized/Initialize(mapload)
	. = ..()
	weapon = new /obj/item/weapon/gun/minigun_wheelchair
	weapon.mount = src

/obj/vehicle/ridden/wheelchair/weaponized/obj_destruction(damage_flag)
	weapon.Destroy()
	. = ..()

//The wheelchair speed is actually on the component, delay_multiplier does nothing
/obj/vehicle/ridden/wheelchair/weaponized/make_ridable()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/wheelchair/weaponized)

//Set the rider as the gun's wielder
/obj/vehicle/ridden/wheelchair/weaponized/after_add_occupant(mob/M)
	. = ..()
	if(istype(M))
		if(!M.put_in_active_hand(weapon) && !M.put_in_inactive_hand(weapon))
			to_chat(M, span_warning("Could not equip weapon! Click [src] with a free hand to equip."))
		//NODROP is so that you can't just drop the gun or have someone take it off your hands
		ADD_TRAIT(weapon, TRAIT_NODROP, WHEELCHAIR_TRAIT)

//The ex-rider no longer wields the gun
/obj/vehicle/ridden/wheelchair/weaponized/after_remove_occupant(mob/M)
	. = ..()
	if(istype(M))
		REMOVE_TRAIT(weapon, TRAIT_NODROP, WHEELCHAIR_TRAIT)
		/*
		doUnEquip doesn't work so
		Also the gun's dropped() has the code that returns it to the chair
		It was necessary to do this to account for edge cases like the user's arm being cut off; no need for an extra forceMove() here
		*/
		M.dropItemToGround(weapon)

//If the rider doesn't have the weapon equipped and clicks the wheelchair, equip them with it instead of unbuckling
/obj/vehicle/ridden/wheelchair/weaponized/attack_hand(mob/living/user)
	if(is_occupant(user) && !user.is_holding(weapon))
		user.put_in_active_hand(weapon)
	else
		. = ..()

//If the user drags the wheelchair to themselves, unload the gun
/obj/vehicle/ridden/wheelchair/weaponized/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!istype(usr, /mob/living) || over != usr || !in_range(src, usr))
		return

	var/mob/living/user = usr
	weapon.unload(user)

//Users can reload the gun without entering the chair by clicking the chair with the magazine
/obj/vehicle/ridden/wheelchair/weaponized/attackby(obj/item/I, mob/living/user, def_zone)
	. = ..()
	if(istype(I, /obj/item/ammo_magazine))
		weapon.reload(I, user)
