#define FUEL_PER_CAN_POUR 100
///Fuel limit when you will recieve an alert for low fuel message
#define LOW_FUEL_LEFT_MESSAGE 100
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
	integrity_failure = 0.5
	layer = ABOVE_LYING_MOB_LAYER
	allow_pass_flags = PASSABLE
	pass_flags = PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL|BUCKLE_NEEDS_HAND
	max_buckled_mobs = 2
	max_occupants = 2
	pixel_x = -22
	pixel_y = -22
	///Fuel count, fuel usage is one per tile moved
	var/fuel_count = 0
	///max fuel that this bike can hold
	var/fuel_max = 1000
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/vehicle/ridden/hover_bike/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/hover_bike)
	add_filter("shadow", 2, drop_shadow_filter(0, -8, 1))
	create_storage(/datum/storage/internal/motorbike_pack)
	update_icon()
	fuel_count = fuel_max

/obj/vehicle/ridden/hover_bike/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/hover_bike/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	. += "To access internal storage click with an empty hand or drag the bike onto self."
	. += "The fuel gauge on the bike reads \"[fuel_count/fuel_max*100]%\""

/obj/vehicle/ridden/hover_bike/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "hover_bike_toplayer", ABOVE_MOB_PROP_LAYER)
	. += mutable_appearance(icon, "hover_bike_midlayer", ABOVE_MOB_LAYER)

/obj/vehicle/ridden/hover_bike/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	M.pass_flags &= ~pass_flags
	return ..()

/obj/vehicle/ridden/hover_bike/post_buckle_mob(mob/living/M)
	add_occupant(M)
	M.pass_flags |= pass_flags
	return ..()

/obj/vehicle/ridden/hover_bike/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 10, 2 SECONDS, fuel_req = 1)

/obj/vehicle/ridden/hover_bike/relaymove(mob/living/user, direction)
	if(fuel_count <= 0)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIKE_FUEL_MESSAGE))
			to_chat(user, span_warning("There is no fuel left!"))
			TIMER_COOLDOWN_START(src, COOLDOWN_BIKE_FUEL_MESSAGE, 1 SECONDS)
		return FALSE
	return ..()

/obj/vehicle/ridden/hover_bike/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!LAZYLEN(buckled_mobs)) // dont use fuel or make noise unless we're being used
		return
	fuel_count--
	if(fuel_count == LOW_FUEL_LEFT_MESSAGE)
		for(var/mob/rider AS in buckled_mobs)
			balloon_alert(rider, "[fuel_count/fuel_max*100]% fuel left")
	/*
	if(COOLDOWN_CHECK(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, 20)
		playsound(get_turf(src), 'sound/vehicles/carrev.ogg', 100, TRUE)
	**/

/obj/vehicle/ridden/hover_bike/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/jerrycan))
		var/obj/item/reagent_containers/jerrycan/gascan = I
		if(gascan.reagents.total_volume == 0)
			balloon_alert(user, "Out of fuel!")
			return
		if(fuel_count >= fuel_max)
			balloon_alert(user, "Already full!")
			return

		var/fuel_transfer_amount = min(gascan.fuel_usage*2, gascan.reagents.total_volume)
		gascan.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		fuel_count = min(fuel_count + FUEL_PER_CAN_POUR, fuel_max)
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		balloon_alert(user, "[fuel_count/fuel_max*100]%")
		return TRUE
	return ..()

/obj/vehicle/ridden/hover_bike/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/hover_bike/process()
	if(obj_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(prob(20))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/hover_bike/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	explosion(src, light_impact_range = 4, flash_range = 0)
	return ..()

/obj/vehicle/ridden/hover_bike/lava_act()
	return //we flying baby


#undef FUEL_PER_CAN_POUR
#undef LOW_FUEL_LEFT_MESSAGE
