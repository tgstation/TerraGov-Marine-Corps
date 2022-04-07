/obj/item/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	item_state = "mousetrap"
	attachable = TRUE
	var/armed = FALSE

/obj/item/assembly/mousetrap/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/assembly/mousetrap/examine(mob/user)
	. = ..()
	. += span_notice("The pressure plate is [armed ? "primed" : "safe"].")


/obj/item/assembly/mousetrap/activate()
	. = ..()
	if(.)
		armed = !armed
		update_icon()
		playsound(src, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


/obj/item/assembly/mousetrap/update_icon_state()
	if(armed)
		icon_state = "mousetraparmed"
	else
		icon_state = "mousetrap"
	holder?.update_icon()


/obj/item/assembly/mousetrap/proc/triggered(mob/target, type = "feet")
	if(!armed)
		return
	var/datum/limb/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_limb(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
					H.Paralyze(60)
			if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
				if(!H.gloves)
					affecting = H.get_limb(type)
					H.Stun(60)
		affecting?.take_damage_limb(1, 0)
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message(span_boldannounce("SPLAT!"))
		M.death()
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	armed = FALSE
	update_icon()
	pulse(FALSE)


/obj/item/assembly/mousetrap/attack_self(mob/living/carbon/human/user)
	if(!armed)
		to_chat(user, span_notice("You arm [src]."))
	else
		to_chat(user, span_notice("You disarm [src]."))
	armed = !armed
	update_icon()
	playsound(src, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


/obj/item/assembly/mousetrap/proc/on_cross(atom/movable/AM)
	SIGNAL_HANDLER
	if(!armed)
		return
	if(ishuman(AM))
		var/mob/living/carbon/H = AM
		if(H.m_intent == MOVE_INTENT_RUN)
			INVOKE_ASYNC(src, .proc/triggered, H)
			H.visible_message(span_warning("[H] accidentally steps on [src]."), \
							span_warning("You accidentally step on [src]"))
	else if(ismouse(AM))
		INVOKE_ASYNC(src, .proc/triggered, AM)
	else if(AM.density) // For mousetrap grenades, set off by anything heavy
		INVOKE_ASYNC(src, .proc/triggered, AM)


/obj/item/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		if(finder)
			finder.visible_message(span_warning("[finder] accidentally sets off [src], breaking [finder.p_their()] fingers."), \
								span_warning("You accidentally trigger [src]!"))
			triggered(finder, pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND))
			return TRUE	//end the search!
		else
			visible_message(span_warning("[src] snaps shut!"))
			triggered(loc)
			return FALSE
	return FALSE


/obj/item/assembly/mousetrap/hitby(atom/movable/AM)
	if(!armed)
		return ..()
	visible_message(span_warning("[src] is triggered by [AM]."))
	triggered(null)


/obj/item/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = TRUE
