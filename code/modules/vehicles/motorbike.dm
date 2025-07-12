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
	atom_flags = PREVENT_CONTENTS_EXPLOSION
	key_type = null
	integrity_failure = 0.5
	allow_pass_flags = PASSABLE
	coverage = 30	//It's just a bike, not hard to shoot over
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL|BUCKLE_NEEDS_HAND
	attachments_by_slot = list(ATTACHMENT_SLOT_STORAGE)
	attachments_allowed = list(/obj/item/vehicle_module/storage/motorbike)
	starting_attachments = list(/obj/item/vehicle_module/storage/motorbike)

	///Mutable appearance overlay that covers up the mob with the bike as needed
	var/mutable_appearance/motorbike_cover
	///Fuel count, fuel usage is one per tile moved
	var/fuel_count = 0
	///max fuel that this bike can hold
	var/fuel_max = 1000
	///reference to the attached sidecar, if present
	var/obj/item/sidecar/attached_sidecar
	/// The looping sound that plays when the bike is not moving
	var/datum/looping_sound/bike_idle/idle_sound
	/// Which sound is played when the bike is unbuckled from
	var/dismount_sound = 'sound/vehicles/bikedismount.ogg'
	/// Alternative sound played when the bike is buckled to without fuel
	var/dry_dismount_sound = 'sound/vehicles/bikedry.ogg'
	/// A list of potential sounds played when the bike is revved via AltClick
	var/list/rev_sounds = list(
		'sound/vehicles/bikerev-1.ogg',
		'sound/vehicles/bikerev-2.ogg'
	)
	/// Cooldown for revving the bike, to prevent spamming
	COOLDOWN_DECLARE(rev_cooldown)

/obj/vehicle/ridden/motorbike/Initialize(mapload)
	. = ..()
	idle_sound = new()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike)
	motorbike_cover = mutable_appearance(icon, "motorbike_cover", MOB_LAYER + 0.1)
	fuel_count = fuel_max

/obj/vehicle/ridden/motorbike/Destroy()
	if(isdatum(idle_sound))
		QDEL_NULL(idle_sound)
	return ..()

/obj/vehicle/ridden/motorbike/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	. += "To access internal storage click with an empty hand or drag the bike onto self."
	. += "The fuel gauge on the bike reads \"[fuel_count/fuel_max*100]%\""

/obj/vehicle/ridden/motorbike/AltClick(mob/user)
	if(!(user in buckled_mobs))
		return FALSE
	if(!COOLDOWN_FINISHED(src, rev_cooldown))
		return FALSE
	if(fuel_count < 5)
		return FALSE
	COOLDOWN_START(src, rev_cooldown, 3 SECONDS)
	to_chat(user, span_notice("You rev the [src]'s engine."))
	fuel_count -= 5
	playsound(src, pick(rev_sounds), 50, TRUE, falloff = 3)
	return TRUE

/obj/vehicle/ridden/motorbike/post_buckle_mob(mob/living/M)
	add_overlay(motorbike_cover)
	if(has_fuel())
		idle_sound.start(src)
	else
		playsound(src, dry_dismount_sound, vol = 40, falloff = 1)
	return ..()

/obj/vehicle/ridden/motorbike/post_unbuckle_mob(mob/living/M)
	if(!LAZYLEN(buckled_mobs))
		cut_overlay(motorbike_cover)
	idle_sound.stop(src)
	if(has_fuel())
		playsound(src, dismount_sound, vol = 25, falloff = 1)
	return ..()

/obj/vehicle/ridden/motorbike/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 10, 2 SECONDS, fuel_req = 1)

/// Returns a boolean indicating whether the motorbike has fuel left.
/obj/vehicle/ridden/motorbike/proc/has_fuel()
	return fuel_count > 0

/obj/vehicle/ridden/motorbike/relaymove(mob/living/user, direction)
	if(!has_fuel())
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_BIKE_FUEL_MESSAGE))
			to_chat(user, span_warning("There is no fuel left!"))
			TIMER_COOLDOWN_START(src, COOLDOWN_BIKE_FUEL_MESSAGE, 1 SECONDS)
			idle_sound.stop(src)
		return FALSE
	return ..()

/obj/vehicle/ridden/motorbike/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!LAZYLEN(buckled_mobs)) // dont use fuel or make noise unless we're being used
		return
	fuel_count--
	if(fuel_count == LOW_FUEL_LEFT_MESSAGE)
		for(var/mob/rider AS in buckled_mobs)
			balloon_alert(rider, "[fuel_count/fuel_max*100]% fuel left")

/obj/vehicle/ridden/motorbike/attackby(obj/item/I, mob/user, params)
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
	return ..()

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

/obj/vehicle/ridden/motorbike/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	explosion(src, light_impact_range = 2, flash_range = 0, explosion_cause=blame_mob)
	return ..()

/obj/vehicle/ridden/motorbike/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

//internal storage
/obj/item/vehicle_module/storage/motorbike
	name = "internal storage"
	desc = "A set of handy compartments to store things in."
	storage_type = /datum/storage/internal/motorbike_pack

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
