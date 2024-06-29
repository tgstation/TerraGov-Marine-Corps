/obj/vehicle/ridden
	name = "ridden vehicle"
	buckle_flags = CAN_BUCKLE|BUCKLE_PREVENTS_PULL
	max_buckled_mobs = 1
	buckle_lying = -1
	allow_pass_flags = PASS_LOW_STRUCTURE
	///Assoc list of available slots. Since this keeps track of all currently equiped attachments per object, this cannot be a string_list()
	var/list/attachments_by_slot = list()
	///Typepath list of allowed attachment types.
	var/list/attachments_allowed = list()
	///Pixel offsets for specific attachment slots. Is not used currently.
	var/list/attachment_offsets = list()
	///List of attachment types that is attached to the object on initialize.
	var/list/starting_attachments = list()
	COOLDOWN_DECLARE(message_cooldown)

/obj/vehicle/ridden/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachments_allowed, attachment_offsets, starting_attachments, null, null, null)

/obj/vehicle/ridden/examine(mob/user)
	. = ..()
	if(key_type)
		if(!inserted_key)
			. += span_notice("Put a key inside it by clicking it with the key.")
		else
			. += span_notice("Alt-click [src] to remove the key.")

/obj/vehicle/ridden/generate_action_type(actiontype)
	var/datum/action/vehicle/ridden/A = ..()
	. = A
	if(istype(A))
		A.vehicle_ridden_target = src

/obj/vehicle/ridden/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	REMOVE_TRAIT(M, TRAIT_NOSUBMERGE, VEHICLE_TRAIT)
	return ..()

/obj/vehicle/ridden/post_buckle_mob(mob/living/M)
	add_occupant(M)
	M.add_nosubmerge_trait(VEHICLE_TRAIT)
	return ..()

/obj/vehicle/ridden/attackby(obj/item/I, mob/user, params)
	if(!key_type || is_key(inserted_key) || !is_key(I))
		return ..()
	if(!user.transferItemToLoc(I, src))
		to_chat(user, span_warning("[I] seems to be stuck to your hand!"))
		return
	to_chat(user, span_notice("You insert \the [I] into \the [src]."))
	if(inserted_key) //just in case there's an invalid key
		inserted_key.forceMove(drop_location())
	inserted_key = I

/obj/vehicle/ridden/AltClick(mob/user)
	if(!inserted_key || (!user.Adjacent(src) && user.dextrous))
		return ..()
	if(!is_occupant(user))
		to_chat(user, span_warning("You must be riding the [src] to remove [src]'s key!"))
		return
	to_chat(user, span_notice("You remove \the [inserted_key] from \the [src]."))
	inserted_key.forceMove(drop_location())
	user.put_in_hands(inserted_key)
	inserted_key = null

/obj/vehicle/ridden/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !in_range(M, src))
		return FALSE
	return ..(M, user, FALSE)

/obj/vehicle/ridden/buckle_mob(mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	if(!force && occupant_amount() >= max_occupants)
		return FALSE
	return ..()
