#define FUEL_PER_CAN_POUR 100
///Fuel limit when you will recieve an alert for low fuel message
#define LOW_FUEL_LEFT_MESSAGE 100
/obj/vehicle/ridden/motorbike
	name = "all-terrain motorbike"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. \"TGMC CAVALRY\" is stamped on the side of the engine."
	icon_state = "motorbike"
	max_integrity = 300
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 0, BOMB = 30, FIRE = 60, ACID = 60)
	resistance_flags = XENO_DAMAGEABLE
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	key_type = null
	integrity_failure = 0.5
	allow_pass_flags = PASSABLE
	coverage = 30	//It's just a bike, not hard to shoot over
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL|BUCKLE_NEEDS_HAND
	///Internal motorbick storage object
	var/obj/item/storage/internal/motorbike_pack/motor_pack = /obj/item/storage/internal/motorbike_pack
	///Mutable appearance overlay that covers up the mob with th e bike as needed
	var/mutable_appearance/motorbike_cover
	///Fuel count, fuel usage is one per tile moved
	var/fuel_count = 0
	///max fuel that this bike can hold
	var/fuel_max = 1000
	///reference to the attached sidecar, if present
	var/obj/item/sidecar/attached_sidecar
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/vehicle/ridden/motorbike/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike)
	motor_pack = new motor_pack(src)
	motorbike_cover = mutable_appearance(icon, "motorbike_cover", MOB_LAYER + 0.1)
	fuel_count = fuel_max

/obj/vehicle/ridden/motorbike/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	. += "To access internal storage click with an empty hand or drag the bike onto self."
	. += "The fuel gauge on the bike reads \"[fuel_count/fuel_max*100]%\""

/obj/vehicle/ridden/motorbike/post_buckle_mob(mob/living/M)
	add_overlay(motorbike_cover)
	return ..()

/obj/vehicle/ridden/motorbike/post_unbuckle_mob(mob/living/M)
	if(!LAZYLEN(buckled_mobs))
		cut_overlay(motorbike_cover)
	return ..()

/obj/vehicle/ridden/motorbike/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 10, 2 SECONDS, fuel_req = 1)

/obj/vehicle/ridden/motorbike/relaymove(mob/living/user, direction)
	if(fuel_count <= 0)
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIKE_FUEL_MESSAGE))
			to_chat(user, span_warning("There is no fuel left!"))
			TIMER_COOLDOWN_START(src, COOLDOWN_BIKE_FUEL_MESSAGE, 1 SECONDS)
		return FALSE
	return ..()

/obj/vehicle/ridden/motorbike/attack_hand(mob/living/user)
	return motor_pack.open(user)

/obj/vehicle/ridden/motorbike/MouseDrop(obj/over_object)
	if(motor_pack.handle_mousedrop(usr, over_object))
		return ..()

/obj/vehicle/ridden/motorbike/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!LAZYLEN(buckled_mobs)) // dont use fuel or make noise unless we're being used
		return
	fuel_count--
	if(fuel_count == LOW_FUEL_LEFT_MESSAGE)
		for(var/mob/rider AS in buckled_mobs)
			balloon_alert(rider, "[fuel_count/fuel_max*100]% fuel left")

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
	if(istype(I, /obj/item/sidecar))
		if(user.do_actions)
			balloon_alert(user, "Already busy!")
			return FALSE
		if(LAZYLEN(buckled_mobs))
			balloon_alert("There is a rider already!")
			return TRUE
		balloon_alert(user, "You start attaching the sidecar...")
		if(!do_after(user, 3 SECONDS, NONE, src))
			return TRUE
		user.temporarilyRemoveItemFromInventory(I)
		I.forceMove(src)
		attached_sidecar = I
		cut_overlay(motorbike_cover)
		motorbike_cover.icon_state = "sidecar_cover"
		motorbike_cover.icon = 'icons/obj/motorbike_sidecar.dmi'
		motorbike_cover.pixel_x = -9
		sidecar_dir_change(newdir = dir)
		RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(sidecar_dir_change))
		add_overlay(motorbike_cover)
		RemoveElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike)
		AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike/sidecar)
		max_buckled_mobs = 2
		max_occupants = 2
		return TRUE
	if(user.a_intent != INTENT_HARM)
		return motor_pack.attackby(I, user, params)

/obj/vehicle/ridden/motorbike/proc/sidecar_dir_change(datum/source, dir, newdir)
	SIGNAL_HANDLER
	switch(newdir)
		if(NORTH)
			pixel_x = 9
		if(SOUTH)
			pixel_x = -9
		if(EAST, WEST)
			pixel_x = 0

/obj/vehicle/ridden/motorbike/wrench_act(mob/living/user, obj/item/I)
	if(!attached_sidecar)
		balloon_alert(user, "No sidecar attached!")
		return TRUE
	if(LAZYLEN(buckled_mobs))
		balloon_alert(user, "Someone is riding this!")
		return TRUE
	if(user.do_actions)
		balloon_alert(user, "Already busy!")
		return FALSE
	if(!do_after(user, 3 SECONDS, NONE, src))
		return TRUE
	attached_sidecar.forceMove(get_turf(src))
	attached_sidecar = null
	RemoveElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike/sidecar)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike)
	max_buckled_mobs = 1
	max_occupants = 1
	cut_overlay(motorbike_cover)
	motorbike_cover.icon_state = "motorbike_cover"
	motorbike_cover.icon = 'icons/obj/vehicles.dmi'
	motorbike_cover.pixel_x = 0
	pixel_x = initial(pixel_x)
	add_overlay(motorbike_cover)
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
	balloon_alert(user, "You dettach the sidecar!")
	return TRUE

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


/obj/item/storage/internal/motorbike_pack/handle_mousedrop(mob/user, obj/over_object)
	if(!ishuman(user))
		return FALSE

	if(user.lying_angle || user.incapacitated()) //Can't use your inventory when lying
		return FALSE

	if(istype(user.loc, /obj/vehicle/multitile/root/cm_armored)) //Stops inventory actions in a mech/tank
		return FALSE

	if(over_object == user && Adjacent(user)) //This must come before the screen objects only block
		open(user)
		return FALSE


/**
 * Sidecar that when attached lets you put two people on the bike
 */
/obj/item/sidecar
	name = "motorbike sidecar"
	desc = "A detached sidecar for TGMC motorbikes, which can be attached to them, allowing a second passenger. Use a wrench to dettach the sidecar."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "sidecar"

#undef FUEL_PER_CAN_POUR
#undef LOW_FUEL_LEFT_MESSAGE
