//I still dont think this should be a closet but whatever
/obj/structure/closet/fireaxecabinet
	name = "Fire Axe Cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	var/obj/item/weapon/twohanded/fireaxe/fireaxe = new/obj/item/weapon/twohanded/fireaxe
	icon_state = "fireaxe1000"
	icon_closed = "fireaxe1000"
	icon_opened = "fireaxe1100"
	anchored = TRUE
	density = FALSE
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	locked = TRUE
	var/smashed = 0

/obj/structure/closet/fireaxecabinet/attackby(obj/item/O, var/mob/user)  //Marker -Agouri
	if(locked)
		if(ismultitool(O))
			to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
			playsound(user, 'sound/machines/lockreset.ogg', 25, 1)
			if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
				locked = FALSE
				to_chat(user, "<span class = 'caution'>You disable the locking modules.</span>")
				update_icon()
			return
		else if(!(O.flags_item & NOBLUDGEON) && O.force)
			var/obj/item/W = O
			if(src.smashed || src.localopened)
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[fireaxe ? "1" : "0"][localopened][hitstaken][smashed]closing"//fucking hasaxe is dead dont fucking aDD IT BACK
					spawn(10)
						update_icon()
				return
			else
				playsound(user, 'sound/effects/Glasshit.ogg', 25, 1) //We don't want this playing every time
			if(W.force < 15)
				to_chat(user, "<span class='notice'>The cabinet's protective glass glances off the hit.</span>")
			else
				src.hitstaken++
				if(src.hitstaken == 4)
					playsound(user, 'sound/effects/glassbr3.ogg', 50, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
					src.smashed = 1
					src.locked = 0
					src.localopened = 1
			update_icon()
		return
	if (istype(O, /obj/item/weapon/twohanded/fireaxe) && src.localopened)
		if(!fireaxe)
			if(O.flags_item & WIELDED)
				to_chat(user, "<span class='warning'>Unwield the axe first.</span>")
				return
			fireaxe = O
			user.drop_held_item()
			src.contents += O
			to_chat(user, "<span class='notice'>You place the fire axe back in the [src.name].</span>")
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]opening",src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
				else
					icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]closing",src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
	else
		if(smashed)
			return
		if(ismultitool(O))
			if(localopened)
				localopened = 0
				icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]closing",src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()
				return
			else
				to_chat(user, "<span class='warning'>Resetting circuitry...</span>")
				sleep(50)
				src.locked = 1
				to_chat(user, "<span class='notice'>You re-enable the locking modules.</span>")
				playsound(user, 'sound/machines/lockenable.ogg', 25, 1)
				if(do_after(user,20, TRUE, src, BUSY_ICON_BUILD))
					locked = TRUE
				to_chat(user, "<span class = 'caution'> You re-enable the locking modules.</span>")
				return
		else
			localopened = !localopened
			if(localopened)
				icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]opening",localopened,hitstaken,smashed)
				spawn(10) update_icon()
			else
				icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]closing",localopened,hitstaken,smashed)
				spawn(10) update_icon()



/obj/structure/closet/fireaxecabinet/attack_hand(mob/user)

	if(!ishuman(user))
		return
	if(src.locked)
		to_chat(user, "<span class='warning'>The cabinet won't budge!</span>")
		return
	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			fireaxe = null
			to_chat(user, "<span class='notice'>You take the fire axe from the [name].</span>")
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					src.icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]opening",src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
				else
					src.icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]closing",src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]opening",src.localopened,src.hitstaken,src.smashed)
			spawn(10)
				update_icon()
		else
			icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]closing",src.localopened,src.hitstaken,src.smashed)
			spawn(10)
				update_icon()

/obj/structure/closet/fireaxecabinet/verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri // no, its not
	set name = "Open/Close"
	set category = "Object"

	if (locked || smashed)
		if(src.locked)
			to_chat(usr, "<span class='warning'>The cabinet won't budge!</span>")
		else if(src.smashed)
			to_chat(usr, "<span class='notice'>The protective glass is broken!</span>")
		return

	localopened = !localopened
	update_icon()

/obj/structure/closet/fireaxecabinet/verb/remove_fire_axe()
	set name = "Remove Fire Axe"
	set category = "Object"

	if (istype(usr, /mob/living/carbon/xenomorph))
		return

	if (localopened)
		if(fireaxe)
			usr.put_in_hands(fireaxe)
			fireaxe = null
			to_chat(usr, "<span class='notice'>You take the Fire axe from the [name].</span>")
		else
			to_chat(usr, "<span class='notice'>The [src.name] is empty.</span>")
	else
		to_chat(usr, "<span class='notice'>The [src.name] is closed.</span>")
	update_icon()

/obj/structure/closet/fireaxecabinet/attack_paw(mob/user as mob)
	return attack_hand(user) //Nope

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(src.smashed)
		to_chat(user, "<span class='warning'>The security of the cabinet is compromised.</span>")
		return
	else
		locked = !locked
		if(locked)
			to_chat(user, "<span class='warning'>Cabinet locked.</span>")
		else
			to_chat(user, "<span class='notice'>Cabinet unlocked.</span>")
		return

/obj/structure/closet/fireaxecabinet/update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	icon_state = text("fireaxe[fireaxe ? "1" : "0"][][][]",src.localopened,src.hitstaken,src.smashed)

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return
