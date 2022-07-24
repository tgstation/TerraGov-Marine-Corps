/obj/item/tool/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0


/obj/item/tool/mop/Initialize()
	. = ..()
	create_reagents(5)

/turf/proc/clean(atom/source)
	if(source.reagents.has_reagent(/datum/reagent/water, 1))
		clean_blood()
		for(var/atom/movable/effect/O in src)
			if(istype(O,/atom/movable/effect/rune) || istype(O,/atom/movable/effect/decal/cleanable) || istype(O,/atom/movable/effect/overlay))
				qdel(O)
	source.reagents.reaction(src, TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	source.reagents.remove_any(1)				//reaction() doesn't use up the reagents


/obj/item/tool/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(istype(A, /turf) || istype(A, /atom/movable/effect/decal/cleanable) || istype(A, /atom/movable/effect/overlay) || istype(A, /atom/movable/effect/rune))
		if(reagents.total_volume < 1)
			to_chat(user, span_notice("Your mop is dry!"))
			return

		var/turf/T = get_turf(A)
		user.visible_message(span_warning("[user] begins to clean \the [T]."))

		if(do_after(user, 40, TRUE, T, BUSY_ICON_GENERIC))
			T.clean(src)
			to_chat(user, span_notice("You have finished mopping!"))


/obj/item/tool/wet_sign
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon_state = "caution"
	icon = 'icons/obj/janitor.dmi'
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/clothing/head/warning_cone
	name = "warning cone"
	desc = "This cone is trying to warn you of something!"
	icon_state = "cone"
	icon = 'icons/obj/janitor.dmi'
	item_icons = list(slot_head_str = 'icons/mob/head_0.dmi')
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")
	soft_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 10, "rad" = 0, "fire" = 20, "acid" = 20)





/obj/item/tool/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "soap"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20

/obj/item/tool/soap/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/tool/soap/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs) //TODO JUST USE THE SLIPPERY COMPONENT
	SIGNAL_HANDLER
	if (iscarbon(AM))
		var/mob/living/carbon/C =AM
		C.slip("soap", 3, 2)


/obj/item/tool/soap/attack(mob/target, mob/user)
	return


/obj/item/tool/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity)
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		to_chat(user, span_notice("You need to take that [target.name] off before cleaning it."))
	else if(istype(target,/atom/movable/effect/decal/cleanable))
		to_chat(user, span_notice("You scrub \the [target.name] out."))
		qdel(target)
	else
		to_chat(user, span_notice("You clean \the [target.name]."))
		target.clean_blood()

/obj/item/tool/soap/attack(mob/target, mob/user)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == "mouth" )
		user.visible_message(span_warning(" \the [user] washes \the [target]'s mouth out with soap!"))
		return
	..()

/obj/item/tool/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of phoron."
	icon_state = "soapnt"

/obj/item/tool/soap/deluxe
	icon_state = "soapdeluxe"

/obj/item/tool/soap/deluxe/Initialize()
	. = ..()
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of [pick("lavender", "vanilla", "strawberry", "chocolate" ,"space")]."

/obj/item/tool/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"
