/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	set src in oview(1)
	if(stat == DEAD || usr.stat == DEAD || client == null)
		return
	if(src == usr)
		return
	var/obj/item/I
	if(!usr.hand && usr.r_hand == null)
		to_chat(usr, "<span class='warning'>You don't have anything in your right hand to give to [name].</span>")
		return
	if(usr.hand && usr.l_hand == null)
		to_chat(usr, "<span class='warning'>You don't have anything in your left hand to give to [name].</span>")
		return
	if(!ishuman(src) || !ishuman(usr))
		return
	if(usr.hand)
		I = usr.l_hand
	else if(!usr.hand)
		I = usr.r_hand
	if(!istype(I) || (I.flags_item & (DELONDROP|NODROP)))
		return
	if(r_hand == null || l_hand == null)
		switch(alert(src,"[usr] wants to give you \a [I]?",,"Yes","No"))
			if("Yes")
				if(!I || !usr || !istype(I))
					return
				if(!Adjacent(usr))
					to_chat(usr, "<span class='warning'>You need to stay in reaching distance while giving an object.</span>")
					to_chat(src, "<span class='warning'>[usr] moved too far away.</span>")
					return
				if((usr.hand && usr.l_hand != I) || (!usr.hand && usr.r_hand != I))
					to_chat(usr, "<span class='warning'>You need to keep the item in your active hand.</span>")
					to_chat(src, "<span class='warning'>[usr] seem to have given up on giving [I] to you.</span>")
					return
				if(r_hand != null && l_hand != null)
					to_chat(src, "<span class='warning'>Your hands are full.</span>")
					to_chat(usr, "<span class='warning'>[src]'s hands are full.</span>")
					return
				else
					if(usr.drop_held_item())
						if(put_in_hands(I))
							usr.visible_message("<span class='notice'>[usr] hands [I] to [src].</span>",
							"<span class='notice'>You hand [I] to [src].</span>", null, 4)
			if("No")
				return
	else
		to_chat(usr, "<span class='warning'>[src]'s hands are full.</span>")
