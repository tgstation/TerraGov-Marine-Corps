
/mob/living/simple_animal/Topic(href, href_list)
	..()
	if(href_list["inspect_animal"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/list/msg = list()
		if(!ismob(usr))
			return

		if(simple_wounds.len)
			msg += "<B>Wounds:</B>\n"
			for(var/datum/wound/W in simple_wounds)
				msg += "[W.name]\n"

		for(var/obj/item/I in simple_embedded_objects)
			msg += "<a href='?src=[REF(src)];embedded_object=[REF(I)]'>[I.name]</a>\n"

		to_chat(usr, "[msg.Join("")]")


	if(href_list["embedded_object"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		var/obj/item/I = locate(href_list["embedded_object"]) in simple_embedded_objects
		if(!I || I.loc != src)
			return
		simple_embedded_objects -= I
		emote("pain", TRUE)
		I.forceMove(get_turf(src))
		usr.put_in_hands(I)
		playsound(loc, 'sound/foley/flesh_rem.ogg', 100, TRUE, -2)
		if(usr == src)
			usr.visible_message("<span class='notice'>[usr] rips [I] out of [usr.p_them()]self!</span>", "<span class='notice'>I remove [I] from myself.</span>")
		else
			usr.visible_message("<span class='notice'>[usr] rips [I] out of [src]!</span>", "<span class='notice'>I rip [I] from [src].</span>")
		if(!has_embedded_objects())
			clear_alert("embeddedobject")
			SEND_SIGNAL(usr, COMSIG_CLEAR_MOOD_EVENT, "embedded")
		return