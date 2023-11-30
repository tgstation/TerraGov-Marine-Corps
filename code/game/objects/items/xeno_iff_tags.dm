
//These small little things allow you to give xenos an IFF signature. No more crying because your corrupted keep dying to smartgunners!
/obj/item/xeno_iff_tag
	name = "Terragov xenomorph IFF tag"
	desc = "A small metallic card that can be clamped onto a xenomorph, allowing IFF systems to recognize the target as friendly."
	icon = 'icons/obj/items/card.dmi'
	icon_state = "guest" //Better I reuse this unused sprite for something that you'll see for ten seconds pre-attach than use my spriting "skills".
	///The IFF signal this tag will create a component with
	var/carried_iff = TGMC_LOYALIST_IFF

/obj/item/xeno_iff_tag/attack(mob/living/M, mob/living/user)
	if(!isxeno(M))
		return ..()
	. = TRUE
	var/mob/living/carbon/xenomorph/xeno = M
	if(xeno.stat == DEAD)
		to_chat(user, span_warning("[xeno] is dead, why would you waste a tag on it?"))
		return
	if(xeno.GetComponent(/datum/component/xeno_iff))
		to_chat(user, span_warning("[xeno] already has an IFF tag attached, and attaching another might mess with its signal!"))
		return
	user.visible_message(span_notice("[user] starts attaching [src] to [xeno]."), span_notice("You start attaching [src] to [xeno]."), ignored_mob = xeno)
	if(xeno.client)
		to_chat(xeno, span_xenowarning("[user] starts attaching [src] to us!"))
	if(!do_after(user, 5 SECONDS, IGNORE_HELD_ITEM, xeno, BUSY_ICON_FRIENDLY, BUSY_ICON_DANGER))
		return
	if(xeno.GetComponent(/datum/component/xeno_iff))
		to_chat(user, span_warning("Someone already attached a tag to [xeno] while you were busy!"))
		return
	user.balloon_alert_to_viewers("Attached IFF tag")
	to_chat(xeno, span_xenonotice("[user] attaches [src] to us!"))
	xeno.AddComponent(/datum/component/xeno_iff, carried_iff)
	qdel(src)



//Eventmins are fun so I'll make your job a tiny bit easier.

/obj/item/xeno_iff_tag/som
	name = "Sons of Mars xenomorph IFF tag"
	carried_iff = SOM_IFF

/obj/item/xeno_iff_tag/deathsquad
	name = "\[redacted\] xenomorph IFF tag"
	carried_iff = DEATHSQUAD_IFF

/obj/item/xeno_iff_tag/sectoid
	name = "Sectoid xenomorph IFF tag"
	carried_iff = SECTOIDS_IFF

//Adding more options should be super easy anyways just varedit the carried IFF (or manually add the component if you know how!)
