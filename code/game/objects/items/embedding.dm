/obj/item/proc/embed_into(mob/living/target, target_zone, silent)
	if(!target.embed_item(src, target_zone, silent))
		return FALSE
	forceMove(target)
	embedded_into = target
	RegisterSignal(embedded_into, COMSIG_MOVABLE_MOVED, PROC_REF(embedded_on_carrier_move))
	RegisterSignals(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED), PROC_REF(embedded_on_move))
	return TRUE


/obj/item/proc/embedded_on_move(datum/source)
	SIGNAL_HANDLER
	unembed_ourself()


/obj/item/proc/unembed_ourself(delete_self)
	if(!embedded_into)
		UnregisterSignal(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
		CRASH("unembed_ourself called with no embedded_into")
	embedded_into.unembed_item(src)
	UnregisterSignal(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
	UnregisterSignal(embedded_into, COMSIG_MOVABLE_MOVED)
	embedded_into = null
	if(!QDELETED(src))
		if(delete_self)
			qdel(src)
			return
		forceMove(get_turf(loc))


/mob/living/proc/unembed_item(obj/item/embedding)
	LAZYREMOVE(embedded_objects, embedding)
	var/yankable_embedded = FALSE
	for(var/i in embedded_objects)
		var/obj/item/embedded_obj = i
		if(!(embedded_obj.embedding.embedded_flags & EMBEDDED_CAN_BE_YANKED_OUT))
			continue
		yankable_embedded = TRUE
		break
	if(!yankable_embedded)
		remove_verb(src, /mob/living/proc/yank_out_object)


/mob/living/carbon/human/unembed_item(obj/item/embedding)
	var/datum/limb/affected_limb = LAZYACCESS(embedded_objects, embedding)
	affected_limb.unembed(embedding)
	LAZYREMOVE(embedded_objects, embedding)
	var/yankable_embedded = FALSE
	for(var/i in embedded_objects)
		var/obj/item/embedded_obj = i
		if(!(embedded_obj.embedding.embedded_flags & EMBEDDED_CAN_BE_YANKED_OUT))
			continue
		yankable_embedded = TRUE
		break
	if(!yankable_embedded)
		remove_verb(src, /mob/living/proc/yank_out_object)


/datum/limb/proc/unembed(obj/item/embedding)
	embedding.UnregisterSignal(src, COMSIG_LIMB_DESTROYED)
	implants -= embedding


/mob/living/proc/embed_item(obj/item/embedding, target_zone, silent)
	LAZYSET(embedded_objects, embedding, src)
	return TRUE


/mob/living/carbon/human/embed_item(obj/item/embedding, target_zone, silent)
	var/datum/limb/affected_limb = (istype(target_zone, /datum/limb) ? target_zone : get_limb(check_zone(target_zone)))
	if(!affected_limb.limb_embed(embedding, silent))
		return FALSE
	LAZYSET(embedded_objects, embedding, affected_limb)
	return TRUE


/datum/limb/proc/limb_embed(obj/item/embedding, silent)
	if(QDELETED(embedding)) //For test purposes to preserve the check. If this doesn't happen it's free to remove.
		stack_trace("limb_embed called for QDELETED [embedding]")
		embedding?.unembed_ourself()
		return FALSE
	if(HAS_TRAIT(embedding, TRAIT_NODROP) || (embedding.flags_item & DELONDROP))
		stack_trace("limb_embed called for TRAIT_NODROP or DELONDROP [embedding]")
		embedding.unembed_ourself()
		return FALSE
	if(limb_status & LIMB_DESTROYED)
		return FALSE
	if(!silent)
		owner.visible_message(span_danger("\The [embedding] sticks in the wound!"))
	implants += embedding
	if(embedding.embedding.embedded_flags & EMBEDDED_CAN_BE_YANKED_OUT)
		add_verb(owner, /mob/living/proc/yank_out_object)
	embedding.add_mob_blood(owner)
	embedding.forceMove(owner)
	embedding.RegisterSignal(src, COMSIG_LIMB_DESTROYED, TYPE_PROC_REF(/obj/item, embedded_on_limb_destruction))
	return TRUE


/obj/item/proc/embedded_on_carrier_move(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER_DOES_SLEEP
	var/mob/living/carrier = source
	if(!isturf(carrier.loc) || carrier.buckled)
		return //People can safely move inside a vehicle or on a roller bed/chair.
	var/embedded_thing = carrier.embedded_objects[src]
	if(embedded_thing == carrier)
		//carbon stuff
	else if(istype(embedded_thing, /datum/limb))
		var/datum/limb/limb_loc = embedded_thing
		limb_loc.process_embedded(src)
	else
		CRASH("[src] called embedded_on_carrier_move for [carrier] with mismatching embedded_object: [.]")


/obj/item/proc/embedded_on_limb_destruction(datum/limb/source)
	SIGNAL_HANDLER
	unembed_ourself()


/datum/limb/proc/process_embedded(obj/item/embedded)
	if(limb_status & (LIMB_SPLINTED|LIMB_STABILIZED))
		return
	if(!prob(embedded.embedding.embed_process_chance))
		return

	switch(rand(1,3))
		if(1)
			. =span_warning("A spike of pain jolts your [display_name] as you bump [embedded] inside.")
		if(2)
			. =span_warning("Your movement jostles [embedded] in your [display_name] painfully.")
		if(3)
			. =span_warning("[embedded] in your [display_name] twists painfully as you move.")
	to_chat(owner, .)

	take_damage_limb(embedded.embedding.embed_limb_damage)
	UPDATEHEALTH(owner)

	if(!(limb_status & LIMB_ROBOT) && !(owner.species.species_flags & NO_BLOOD)) //There is no blood in protheses.
		add_limb_flags(LIMB_BLEEDING)

	if(prob(embedded.embedding.embedded_fall_chance))
		take_damage_limb(embedded.embedding.embed_limb_damage * embedded.embedding.embedded_fall_dmg_multiplier)
		UPDATEHEALTH(owner)
		owner.visible_message(span_danger("[embedded] falls out of [owner]'s [display_name]!"),
			span_userdanger("[embedded] falls out of your [display_name]!"))
		embedded.unembed_ourself()


/mob/living/proc/yank_out_object()
	set category = "Object"
	set name = "Yank out object"
	set desc = "Remove an embedded item at the cost of bleeding and pain."
	set src in view(1)

	if(!ishuman(usr) || usr.next_move > world.time)
		return

	var/mob/living/carbon/human/user = usr

	user.next_move = world.time + 2 SECONDS

	if(user.do_actions)
		return

	if(user.stat != CONSCIOUS)
		to_chat(user, "You are unconcious and cannot do that!")
		return

	if(user.restrained())
		balloon_alert(user, "can't, restrained")
		return

	var/self

	if(src == user)
		self = TRUE // Removing object from yourself.

	var/list/valid_objects = list()
	for(var/i in embedded_objects)
		var/obj/item/embedded_item = i
		if(!(embedded_item.embedding.embedded_flags & EMBEDDED_CAN_BE_YANKED_OUT))
			continue
		valid_objects += embedded_item

	if(!length(valid_objects))
		CRASH("yank_out_object called for empty valid_objects, lenght of embedded_objects is [length(embedded_objects)]")

	var/obj/item/selection = tgui_input_list(user, "What do you want to yank out?", "Embedded objects", valid_objects)

	if(user.get_active_held_item())
		balloon_alert(user, "cannot, no empty hands")
		return FALSE

	balloon_alert(user, "attempts to grip [selection]")

	if(!do_after(user, selection.embedding.embedded_unsafe_removal_time, NONE, src, BUSY_ICON_GENERIC) || QDELETED(selection) || !(selection in embedded_objects))
		return

	if(self)
		balloon_alert_to_viewers("rips [selection] out of [user.p_their()] body")
	else
		balloon_alert_to_viewers("rips [selection] out of [src]'s body")

	handle_yank_out_damage()

	selection.unembed_ourself()


/mob/living/proc/handle_yank_out_damage(obj/item/yanked, mob/living/carbon/human/user)
	apply_damage(yanked.embedding.embedded_unsafe_removal_dmg_multiplier * yanked.embedding.embed_body_damage)
	UPDATEHEALTH(src)


/mob/living/carbon/human/handle_yank_out_damage(obj/item/yanked, mob/living/carbon/human/user)
	adjustShock_Stage(yanked.embedding.embedded_unsafe_removal_dmg_multiplier * yanked.embedding.embed_limb_damage)
	var/datum/limb/affected_limb = embedded_objects[yanked]
	affected_limb.take_damage_limb(yanked.embedding.embedded_unsafe_removal_dmg_multiplier * yanked.embedding.embed_limb_damage, 0, FALSE, TRUE)
	UPDATEHEALTH(src)
	user.bloody_hands(src)
