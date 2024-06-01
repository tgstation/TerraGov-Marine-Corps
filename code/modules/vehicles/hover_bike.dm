/obj/vehicle/ridden/hover_bike
	name = "hover bike"
	desc = "desc here"
	icon = 'icons/obj/vehicles/hover_bike.dmi'
	icon_state = "hover_bike"
	max_integrity = 300
	soft_armor = list(MELEE = 35, BULLET = 45, LASER = 45, ENERGY = 60, BOMB = 50, FIRE = 75, ACID = 30)
	resistance_flags = XENO_DAMAGEABLE
	atom_flags = PREVENT_CONTENTS_EXPLOSION
	key_type = null
	coverage = 60
	layer = ABOVE_LYING_MOB_LAYER
	allow_pass_flags = PASSABLE
	pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL|BUCKLE_NEEDS_HAND
	max_buckled_mobs = 2
	max_occupants = 2
	pixel_x = -22
	pixel_y = -22
	attachments_by_slot = list(ATTACHMENT_SLOT_STORAGE, ATTACHMENT_SLOT_WEAPON)
	attachments_allowed = list(/obj/item/vehicle_module/storage/motorbike, /obj/item/vehicle_module/mounted_gun/volkite, /obj/item/vehicle_module/mounted_gun/minigun)
	starting_attachments = list(/obj/item/vehicle_module/storage/motorbike, /obj/item/vehicle_module/mounted_gun/volkite)

/obj/vehicle/ridden/hover_bike/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/hover_bike)
	add_filter("shadow", 2, drop_shadow_filter(0, -8, 1))
	update_icon()
	animate_hover()

/obj/vehicle/ridden/hover_bike/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	. += "To access internal storage click with an empty hand or drag the bike onto self."

/obj/vehicle/ridden/hover_bike/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "hover_bike_toplayer", ABOVE_MOB_PROP_LAYER)
	. += mutable_appearance(icon, "hover_bike_midlayer", ABOVE_MOB_LAYER)

/obj/vehicle/ridden/hover_bike/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	M.pass_flags &= ~pass_flags
	. = ..()
	animate_hover()
	animate(M)

/obj/vehicle/ridden/hover_bike/post_buckle_mob(mob/living/M)
	add_occupant(M)
	M.pass_flags |= pass_flags
	. = ..()
	animate_hover()

/obj/vehicle/ridden/hover_bike/auto_assign_occupant_flags(mob/M)
	. = ..()
	if(!is_driver(M))
		return
	add_control_flags(M, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/ridden/hover_bike/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 10, 2 SECONDS, fuel_req = 1)

/obj/vehicle/ridden/hover_bike/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	explosion(src, light_impact_range = 4, flame_range = (rand(33) ? 3 : 0))
	return ..()

/obj/vehicle/ridden/hover_bike/lava_act()
	return //we flying baby

///Animates the bob for the bike and its occupants
/obj/vehicle/ridden/hover_bike/proc/animate_hover()
	var/list/hover_list = list(src)
	if(length(occupants))
		hover_list += occupants
	for(var/atom/atom AS in hover_list)
		animate(atom, time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE|ANIMATION_END_NOW, pixel_y = 3)
		animate(time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE, pixel_y = -3)
