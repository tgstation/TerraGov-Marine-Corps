/obj/item/tool/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/janitor_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/janitor_right.dmi',
	)
	icon_state = "mop"
	force = 3
	throwforce = 10
	throw_speed = 5
	throw_range = 10
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	var/mopping = 0
	var/mopcount = 0


/obj/item/tool/mop/Initialize(mapload)
	. = ..()
	create_reagents(5)

/turf/proc/clean(atom/source)
	if(source.reagents.has_reagent(/datum/reagent/water, 1))
		clean_blood()
		for(var/obj/effect/O in src)
			if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
				qdel(O)
	source.reagents.reaction(src, TOUCH, 10)	//10 is the multiplier for the reaction effect. probably needed to wet the floor properly.
	source.reagents.remove_any(1)				//reaction() doesn't use up the reagents


/obj/item/tool/mop/afterattack(atom/A, mob/user, proximity)
	if(!proximity) return
	if(istype(A, /turf) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			balloon_alert(user, "Mop is dry")
			return

		var/turf/T = get_turf(A)
		user.visible_message(span_warning("[user] begins to clean \the [T]."))

		if(do_after(user, 40, NONE, T, BUSY_ICON_GENERIC))
			T.clean(src)
			balloon_alert(user, "Finished mopping")


/obj/item/tool/wet_sign
	name = "wet floor sign"
	desc = "Caution! Wet Floor!"
	icon_state = "caution"
	icon = 'icons/obj/janitor.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/janitor_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/janitor_right.dmi',
	)
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
	item_icons = list(slot_head_str = 'icons/mob/clothing/headwear/head_0.dmi')
	force = 1
	throwforce = 3
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 15, BIO = 10, FIRE = 20, ACID = 20)


/obj/item/tool/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/janitor.dmi'
	icon_state = "soap"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20

/obj/item/tool/soap/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 0.3 SECONDS, 0.2 SECONDS)


/obj/item/tool/soap/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity)
		return
	//I couldn't feasibly  fix the overlay bugs caused by cleaning items we are wearing.
	//So this is a workaround. This also makes more sense from an IC standpoint. ~Carn
	if(user.client && (target in user.client.screen))
		balloon_alert(user, "Remove the [target.name] first")
	else if(isturf(target))
		balloon_alert(user, "Scrubs \the [target.name]")
		var/turf/target_turf = target
		target_turf.clean_turf()
	else if(istype(target,/obj/effect/decal/cleanable))
		balloon_alert(user, "Scrubs \the [target.name] out")
		qdel(target)
	else
		balloon_alert(user, "Cleans \the [target.name]")
		target.clean_blood()

/obj/item/tool/soap/attack(mob/target, mob/user)
	if(target && user && ishuman(target) && ishuman(user) && !target.stat && !user.stat && user.zone_selected == "mouth" )
		balloon_alert_to_viewers("washes mouth out with soap")
		return

/obj/item/tool/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of phoron."
	icon_state = "soapnt"

/obj/item/tool/soap/deluxe
	icon_state = "soapdeluxe"

/obj/item/tool/soap/deluxe/Initialize(mapload)
	. = ..()
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of [pick("lavender", "vanilla", "strawberry", "chocolate" ,"space")]."

/obj/item/tool/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"
