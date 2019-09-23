/obj/item/proc/embed_into(mob/living/target, target_zone, silent)
	embedded_into = target
	embedded_into.embed_item(src, target_zone, silent)
	RegisterSignal(embedded_into, COMSIG_MOVABLE_MOVED, .proc/embedded_on_carrier_move)
	RegisterSignal(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED), .proc/embedded_on_move)


/obj/item/proc/embedded_on_move(datum/source)
	unembed_ourself()


/obj/item/proc/unembed_ourself()
	if(!embedded_into)
		UnregisterSignal(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
		CRASH("unembed_ourself called with no embedded_into")
	embedded_into.unembed_item(src)
	UnregisterSignal(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
	UnregisterSignal(embedded_into, COMSIG_MOVABLE_MOVED)
	embedded_into = null
	if(!QDELETED(src))
		forceMove(get_turf(loc))


/mob/living/proc/unembed_item(obj/item/embedding)
	embedded_objects -= embedding
	var/yankable_embedded = FALSE
	for(var/i in embedded_objects)
		var/obj/item/embedded_obj = i
		if(!(embedded_obj.embedding.embedded_flags & EMBEDDEED_CAN_BE_YANKED_OUT))
			continue
		yankable_embedded = TRUE
		break
	if(!yankable_embedded)
		verbs -= /mob/living/proc/yank_out_object


/mob/living/carbon/human/unembed_item(obj/item/embedding)
	var/datum/limb/affected_limb = embedded_objects[embedding]
	affected_limb.unembed(embedding)
	embedded_objects -= embedding
	var/yankable_embedded = FALSE
	for(var/i in embedded_objects)
		var/obj/item/embedded_obj = i
		if(!(embedded_obj.embedding.embedded_flags & EMBEDDEED_CAN_BE_YANKED_OUT))
			continue
		yankable_embedded = TRUE
		break
	if(!yankable_embedded)
		verbs -= /mob/living/proc/yank_out_object


/datum/limb/proc/unembed(obj/item/embedding)
	implants -= embedding


/mob/living/proc/embed_item(obj/item/embedding, target_zone, silent)
	return


/mob/living/embed_item(obj/item/embedding, target_zone, silent)
	embedded_objects += embedding
	embedded_objects[embedding] = loc


/mob/living/carbon/human/embed_item(obj/item/embedding, target_zone, silent)
	var/datum/limb/affected_limb = (istype(target_zone, /datum/limb) ? target_zone : get_limb(check_zone(target_zone)))
	affected_limb.limb_embed(embedding, silent)
	embedded_objects += embedding
	embedded_objects[embedding] = affected_limb


/datum/limb/proc/limb_embed(obj/item/embedding, silent)
	if(QDELETED(embedding)) //For test purposes to preserve the check. If this doesn't happen it's free to remove.
		embedding?.unembed_ourself()
		CRASH("limb_embed called for QDELETED [embedding]")
	if(embedding.flags_item & (NODROP|DELONDROP))
		stack_trace("limb_embed called for NODROP|DELONDROP [embedding]")
		embedding.unembed_ourself()
		return
	if(!silent)
		owner.visible_message("<span class='danger'>\The [embedding] sticks in the wound!</span>")
	implants += embedding
	if(embedding.embedding.embedded_flags & EMBEDDEED_CAN_BE_YANKED_OUT)
		owner.verbs += /mob/living/proc/yank_out_object
	embedding.add_mob_blood(owner)
	embedding.forceMove(owner)


/obj/item/proc/embedded_on_carrier_move(datum/source, atom/oldloc, direction, Forced)
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


/datum/limb/proc/process_embedded(obj/item/embedded)
	if(limb_status & (LIMB_SPLINTED|LIMB_STABILIZED) || (owner.m_intent == MOVE_INTENT_WALK && !owner.pulledby))
		return
	if(!prob(embedded.embedding.embed_process_chance))
		return

	switch(rand(1,3))
		if(1)
			. ="<span class='warning'>A spike of pain jolts your [display_name] as you bump [embedded] inside.</span>"
		if(2)
			. ="<span class='warning'>Your movement jostles [embedded] in your [display_name] painfully.</span>"
		if(3)
			. ="<span class='warning'>[embedded] in your [display_name] twists painfully as you move.</span>"
	to_chat(owner, .)

	take_damage_limb(embedded.embedding.embed_limb_damage)

	if(!(limb_status & LIMB_ROBOT) && !(owner.species.species_flags & NO_BLOOD)) //There is no blood in protheses.
		limb_status |= LIMB_BLEEDING
	
	if(prob(embedded.embedding.embedded_fall_chance))
		take_damage_limb(embedded.embedding.embed_limb_damage * embedded.embedding.embedded_fall_dmg_multiplier)
		owner.visible_message("<span class='danger'>[embedded] falls out of [owner]'s [display_name]!</span>",
			"<span class='userdanger'>[embedded] falls out of your [display_name]!</span>")
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

	if(user.action_busy)
		return

	if(user.stat != CONSCIOUS)
		to_chat(user, "You are unconcious and cannot do that!")
		return

	if(user.restrained())
		to_chat(user, "You are restrained and cannot do that!")
		return

	var/self

	if(src == user)
		self = TRUE // Removing object from yourself.

	var/list/valid_objects = list()
	for(var/i in embedded_objects)
		var/obj/item/embedded_item = i
		if(!(embedded_item.embedding.embedded_flags & EMBEDDEED_CAN_BE_YANKED_OUT))
			continue
		valid_objects += embedded_item

	if(!length(valid_objects))
		CRASH("yank_out_object called for empty valid_objects, lenght of embedded_objects is [length(embedded_objects)]")

	var/obj/item/selection = input("What do you want to yank out?", "Embedded objects") in valid_objects
	
	if(user.get_active_held_item())
		to_chat(user, "<span class='warning'>You need an empty hand for this!</span>")
		return FALSE

	if(self)
		to_chat(user, "<span class='warning'>You attempt to get a good grip on [selection] in your body.</span>")
	else
		to_chat(user, "<span class='warning'>You attempt to get a good grip on [selection] in [src]'s body.</span>")

	if(!do_after(user, selection.embedding.embedded_unsafe_removal_time, TRUE, src, BUSY_ICON_GENERIC) || QDELETED(selection) || !(selection in embedded_objects))
		return

	if(self)
		visible_message("<span class='warning'><b>[user] rips [selection] out of user.p_their() body.</b></span>","<span class='warning'><b>You rip [selection] out of your body.</b></span>", null, 5)
	else
		visible_message("<span class='warning'><b>[user] rips [selection] out of [src]'s body.</b></span>","<span class='warning'><b>[user] rips [selection] out of your body.</b></span>", null, 5)

	handle_yank_out_damage()

	selection.unembed_ourself()


/mob/living/proc/handle_yank_out_damage(obj/item/yanked, mob/living/carbon/human/user)
	apply_damage(yanked.embedding.embedded_unsafe_removal_dmg_multiplier * yanked.embedding.embed_body_damage)


/mob/living/carbon/human/handle_yank_out_damage(obj/item/yanked, mob/living/carbon/human/user)
	adjustShock_Stage(yanked.embedding.embedded_unsafe_removal_dmg_multiplier * yanked.embedding.embed_limb_damage)
	var/datum/limb/affected_limb = embedded_objects[yanked]
	affected_limb.take_damage_limb(yanked.embedding.embedded_unsafe_removal_dmg_multiplier * yanked.embedding.embed_limb_damage, 0, FALSE, TRUE)
	user.bloody_hands(src)
