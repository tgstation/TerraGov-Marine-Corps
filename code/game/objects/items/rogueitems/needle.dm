
/obj/item/needle
	name = "needle"
	icon_state = "needle"
	desc = ""
	icon = 'icons/roguetown/items/misc.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throwforce = 0
	var/stringamt = 10
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_MOUTH
	max_integrity = 20


/obj/item/needle/examine()
	. = ..()
	. += "<span class='bold'>It has [stringamt] uses left.</span>"

/obj/item/needle/New()
	..()
	update_icon()

/obj/item/needle/update_icon()
	cut_overlays()
	if(stringamt)
		add_overlay("[icon_state]string")
	..()

/obj/item/needle/use(used)
	stringamt = stringamt - used
	if(stringamt <= 0)
		qdel(src)

/obj/item/needle/attack(mob/living/M, mob/user)
	sew(M, user)

/obj/item/needle/attack_obj(obj/O, mob/living/user)
	if(isitem(O))
		var/obj/item/I = O
		if(I.sewrepair && I.max_integrity && !I.obj_broken)
			if(I.obj_integrity == I.max_integrity)
				to_chat(user, "<span class='warning'>This is not broken.</span>")
				return
			if(user.mind.get_skill_level(/datum/skill/misc/sewing) < I.required_repair_skill)
				to_chat(user, "<span class='warning'>I don't know how to repair this...</span>")
				return
			if(!I.ontable())
				to_chat(user, "<span class='warning'>I should put this on a table first.</span>")
				return
			playsound(loc, 'sound/foley/sewflesh.ogg', 100, TRUE, -2)
			var/sewtime = 70
			if(user.mind)
				sewtime = (70 - ((user.mind.get_skill_level(/datum/skill/misc/sewing)) * 10))
			if(do_after(user, sewtime, target = I))
				playsound(loc, 'sound/foley/sewflesh.ogg', 100, TRUE, -2)
				user.visible_message("<span class='info'>[user] repairs [I]!</span>")
				I.obj_integrity = I.max_integrity
				return

/obj/item/needle/proc/sew(mob/living/M, mob/user)
	if(!get_location_accessible(M, check_zone(user.zone_selected)))
		to_chat(user, "<span class='warning'>Something in the way.</span>")
		return
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(!H.mind)
		return
	if(!affecting)
		return
	if(affecting.bandage)
		to_chat(user, "<span class='warning'>There is a bandage.</span>")
		return
	var/list/sewable = affecting.get_sewable()
	if(!sewable || !sewable.len)
		to_chat(user, "<span class='warning'>There aren't any wounds large enough to sew.</span>")
		return
	var/datum/wound/W = input(user, "Which wound?", "Roguetown", name) as null|anything in sortList(sewable)
	if(!W)
		return
	if(!W || !W.can_sew)
		return
	if(do_after(user, 20))
		playsound(loc, 'sound/foley/sewflesh.ogg', 100, TRUE, -2)
		var/moveup = 10
		if(user.mind)
			moveup = (((user.mind.get_skill_level(/datum/skill/misc/medicine)) * 30) + moveup)
		W.progress = min(W.progress + moveup, 100)
		if(W.progress == 100)
			W.sewn()

		H.update_damage_overlays()

		if(M == user)
			user.visible_message("<span class='notice'>[user] sews \a [W.name] on [user.p_them()]self.</span>", "<span class='notice'>I stitch \a [W.name] on my [affecting].</span>")
		else
			user.visible_message("<span class='notice'>[user] sews \a [W.name] on [M]'s [affecting].</span>", "<span class='notice'>I stitch \a [W.name] on [M]'s [affecting].</span>")
		log_combat(user, H, "sew", "needle")
		if(prob(50))
			use(1)

/obj/item/needle/thorn
	name = "needle"
	icon_state = "thornneedle"
	desc = ""
	stringamt = 3
