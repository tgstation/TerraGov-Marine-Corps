/obj/item/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	item_state = "mousetrap"
	matter = list("metal" = 100)
	attachable = TRUE
	var/armed = FALSE


/obj/item/assembly/mousetrap/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>The pressure plate is [armed ? "primed" : "safe"].</span>")


/obj/item/assembly/mousetrap/activate()
	. = ..()
	if(.)
		armed = !armed
		update_icon()
		playsound(src, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


/obj/item/assembly/mousetrap/update_icon()
	if(armed)
		icon_state = "mousetraparmed"
	else
		icon_state = "mousetrap"
	if(holder)
		holder.update_icon()


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
					H.KnockDown(3)
			if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
				if(!H.gloves)
					affecting = H.get_limb(type)
					H.Stun(3)
		affecting?.take_damage_limb(1, 0)
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message("<span class='boldannounce'>SPLAT!</span>")
		M.death()
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	armed = FALSE
	update_icon()
	pulse(FALSE)


/obj/item/assembly/mousetrap/attack_self(mob/living/carbon/human/user)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		to_chat(user, "<span class='notice'>You disarm [src].</span>")
	armed = !armed
	update_icon()
	playsound(src, 'sound/weapons/handcuffs.ogg', 30, TRUE, -3)


/obj/item/assembly/mousetrap/Crossed(atom/movable/AM)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == MOVE_INTENT_RUN)
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
								"<span class='warning'>You accidentally step on [src]</span>")
		else if(ismouse(AM))
			triggered(AM)
		else if(AM.density) // For mousetrap grenades, set off by anything heavy
			triggered(AM)
	return ..()


/obj/item/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		if(finder)
			finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
								"<span class='warning'>You accidentally trigger [src]!</span>")
			triggered(finder, pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND))
			return TRUE	//end the search!
		else
			visible_message("<span class='warning'>[src] snaps shut!</span>")
			triggered(loc)
			return FALSE
	return FALSE


/obj/item/assembly/mousetrap/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	if(!armed)
		return ..()
	visible_message("<span class='warning'>[src] is triggered by [AM].</span>")
	triggered(null)


/obj/item/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = TRUE
