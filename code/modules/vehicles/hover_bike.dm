/obj/vehicle/ridden/hover_bike
	name = "hover bike"
	desc = "A SOM light hovercraft. Used to swiftly carry up to 2 soldiers over the roughest of terrain, or light defences. Is typically armed with a pair of forwarded mounted weapons. Favoured for rapid assaults."
	icon = 'icons/obj/vehicles/hover_bike.dmi'
	icon_state = "hover_bike"
	max_integrity = 325
	soft_armor = list(MELEE = 45, BULLET = 50, LASER = 50, ENERGY = 60, BOMB = 60, FIRE = 80, ACID = 40)
	resistance_flags = XENO_DAMAGEABLE
	atom_flags = PREVENT_CONTENTS_EXPLOSION
	key_type = null
	coverage = 60
	layer = MOB_BELOW_PIGGYBACK_LAYER
	allow_pass_flags = PASSABLE
	pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL|BUCKLE_NEEDS_HAND
	max_buckled_mobs = 2
	max_occupants = 2
	pixel_w = -22
	pixel_z = -22
	attachments_by_slot = list(ATTACHMENT_SLOT_STORAGE, ATTACHMENT_SLOT_WEAPON)
	attachments_allowed = list(/obj/item/vehicle_module/storage/motorbike, /obj/item/vehicle_module/mounted_gun/volkite, /obj/item/vehicle_module/mounted_gun/minigun)
	starting_attachments = list(/obj/item/vehicle_module/storage/motorbike, /obj/item/vehicle_module/mounted_gun/volkite)
	/// The looping sound that plays when the bike is operating
	var/datum/looping_sound/som_tank_drive/hover_bike/engine_sound

/obj/vehicle/ridden/hover_bike/Initialize(mapload)
	. = ..()
	engine_sound = new()
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
	. += mutable_appearance(icon, "hover_bike_toplayer", TANK_DECORATION_LAYER)
	. += mutable_appearance(icon, "hover_bike_midlayer", MOB_ABOVE_PIGGYBACK_LAYER)

/obj/vehicle/ridden/hover_bike/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	M.remove_pass_flags(pass_flags, HOVERBIKE_TRAIT)
	if(!length(occupants))
		engine_sound.stop(src)
	. = ..()
	animate_hover()
	animate(M)

/obj/vehicle/ridden/hover_bike/post_buckle_mob(mob/living/M)
	add_occupant(M)
	M.add_pass_flags(pass_flags, HOVERBIKE_TRAIT)
	if(is_driver(M))
		engine_sound.start(src)
	. = ..()
	animate_hover()

/obj/vehicle/ridden/hover_bike/auto_assign_occupant_flags(mob/M)
	. = ..()
	if(!is_driver(M))
		return
	add_control_flags(M, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/ridden/hover_bike/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 15, 3 SECONDS, fuel_req = 1)

/obj/vehicle/ridden/hover_bike/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	explosion(src, light_impact_range = 4, flame_range = (rand(33) ? 3 : 0), explosion_cause=blame_mob)
	return ..()

/obj/vehicle/ridden/hover_bike/lava_act()
	return //we flying baby

///Animates the bob for the bike and its occupants
/obj/vehicle/ridden/hover_bike/proc/animate_hover()
	var/list/hover_list = list(src)
	if(length(occupants))
		hover_list += occupants
	for(var/atom/atom AS in hover_list)
		animate(atom, time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE|ANIMATION_END_NOW, pixel_z = 3)
		animate(time = 1.2 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_RELATIVE, pixel_z = -3)
