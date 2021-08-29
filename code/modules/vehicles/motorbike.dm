#define FUEL_PER_CAN_POUR 50

/obj/vehicle/ridden/motorbike
	name = "all-terrain motorbike"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. \"TGMC CAVALRY\" is stamped on the side of the engine."
	icon_state = "motorbike"
	max_integrity = 300
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 0, "bomb" = 30, "fire" = 60, "acid" = 60)
	obj_flags = CAN_BE_HIT
	resistance_flags = XENO_DAMAGEABLE
	key_type = null
	integrity_failure = 0.5
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL|BUCKLE_NEEDS_HAND
	///Internal motorbick storage object
	var/obj/item/storage/internal/motorbike_pack/motor_pack = /obj/item/storage/internal/motorbike_pack
	///Mutable appearance overlay that covers up the mob with th e bike as needed
	var/mutable_appearance/motorbike_cover
	///Fuel count, fuel usage is one per tile moved
	var/fuel_count = 0
	///max fuel that this bike can hold
	var/fuel_max = 400
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/vehicle/ridden/motorbike/Initialize()
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike)
	motor_pack = new motor_pack(src)
	motorbike_cover = mutable_appearance(icon, "motorbike_cover", MOB_LAYER + 0.1)
	fuel_count = fuel_max

/obj/vehicle/ridden/motorbike/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	to_chat(user, "To access internal storage click with an empty hand or drag the bike onto self.")
	to_chat(user, "The fuel gauge on the bike reads \"[fuel_count/fuel_max*100]%\"")

/obj/vehicle/ridden/motorbike/post_buckle_mob(mob/living/M)
	add_overlay(motorbike_cover)
	return ..()

/obj/vehicle/ridden/motorbike/post_unbuckle_mob(mob/living/M)
	if(!LAZYLEN(buckled_mobs))
		cut_overlay(motorbike_cover)
	return ..()

/obj/vehicle/ridden/motorbike/welder_act(mob/living/user, obj/item/I)
	if(obj_integrity >= max_integrity)
		return TRUE
	balloon_alert_to_viewers("[user] starts repairs", ignored_mobs = user)
	balloon_alert(user, "You start repair")
	if(!do_after(user, 2 SECONDS))
		balloon_alert_to_viewers("Stops repair")
		return
	if(!I.use_tool(src, user, 0, volume=50, amount=1))
		return TRUE
	obj_integrity += min(10, max_integrity-obj_integrity)
	if(obj_integrity == max_integrity)
		balloon_alert_to_viewers("Fully repaired!")
	else
		balloon_alert_to_viewers("[user] repairs", ignored_mobs = user)
		balloon_alert(user, "You repair damage")
	return TRUE

/obj/vehicle/ridden/motorbike/attack_hand(mob/living/user)
	return motor_pack.open(user)

/obj/vehicle/ridden/motorbike/MouseDrop(obj/over_object)
	if(motor_pack.handle_mousedrop(usr, over_object))
		return ..()

/obj/vehicle/ridden/motorbike/Move(direction)
	. = ..()
	if(!.)
		return
	if(!LAZYLEN(buckled_mobs)) // dont use fuel or make noise unless we're being used
		return
	fuel_count--

	if(COOLDOWN_CHECK(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, 20)
		playsound(get_turf(src), 'sound/vehicles/carrev.ogg', 100, TRUE)

/obj/vehicle/ridden/motorbike/attackby(obj/item/I, mob/user, params)
	. = ..()
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
	if(user.a_intent != INTENT_HARM)
		return motor_pack.attackby(I, user, params)

/obj/vehicle/ridden/motorbike/obj_break()
	START_PROCESSING(SSobj, src)
	return ..()

/obj/vehicle/ridden/motorbike/process()
	if(obj_integrity >= integrity_failure * max_integrity)
		return PROCESS_KILL
	if(prob(20))
		return
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()

/obj/vehicle/ridden/motorbike/bullet_act(obj/projectile/P)
	if(prob(50) || !buckled_mobs)
		return ..()
	for(var/mob/buckled_mob AS in buckled_mobs)
		buckled_mob.bullet_act(P)
	return TRUE

/obj/vehicle/ridden/motorbike/obj_destruction()
	explosion(src, light_impact_range = 2, flash_range = 0)
	return ..()

/obj/vehicle/ridden/motorbike/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/storage/internal/motorbike_pack
	storage_slots = 4
	max_w_class = WEIGHT_CLASS_SMALL
	max_storage_space = 8

#undef FUEL_PER_CAN_POUR
