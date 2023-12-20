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

/obj/structure/closet/fireaxecabinet/attackby(obj/item/O, mob/user)  //Marker -Agouri
	//..() //That's very useful, Erro
	//how do we still have this shitcode AND THE STUPID FUCKING TILDE AS WELL 10 YEARS LATER
	var/hasaxe = 0       //gonna come in handy later~
	if(fireaxe)
		hasaxe = 1

	if (locked)
		if(ismultitool(O))
			to_chat(user, span_warning("Resetting circuitry..."))
			playsound(user, 'sound/machines/lockreset.ogg', 25, 1)
			if(do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
				locked = FALSE
				to_chat(user, "<span class = 'caution'>You disable the locking modules.</span>")
				update_icon()
			return
		else if(!(O.flags_item & NOBLUDGEON) && O.force)
			var/obj/item/W = O
			if(src.smashed || src.localopened)
				if(localopened)
					localopened = 0
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10) update_icon()
				return
			else
				playsound(user, 'sound/effects/Glasshit.ogg', 25, 1) //We don't want this playing every time
			if(W.force < 15)
				to_chat(user, span_notice("The cabinet's protective glass glances off the hit."))
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
				to_chat(user, span_warning("Unwield the axe first."))
				return
			fireaxe = O
			user.drop_held_item()
			src.contents += O
			to_chat(user, span_notice("You place the fire axe back in the [src.name]."))
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
					update_icon()
				else
					icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
					update_icon()
	else
		if(src.smashed)
			return
		if(ismultitool(O))
			if(localopened)
				localopened = 0
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
				spawn(10)
				update_icon()
				return
			else
				to_chat(user, span_warning("Resetting circuitry..."))
				sleep(5 SECONDS)
				src.locked = 1
				to_chat(user, span_notice("You re-enable the locking modules."))
				playsound(user, 'sound/machines/lockenable.ogg', 25, 1)
				if(do_after(user,20, NONE, src, BUSY_ICON_BUILD))
					locked = TRUE
					to_chat(user, "<span class = 'caution'> You re-enable the locking modules.</span>")
				return
		else
			localopened = !localopened
			if(localopened)
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
				spawn(10)
				update_icon()
			else
				icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
				spawn(10)
				update_icon()




/obj/structure/closet/fireaxecabinet/attack_hand(mob/user as mob)
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1
	if(!ishuman(user)) return
	if(src.locked)
		to_chat(user, span_warning("The cabinet won't budge!"))
		return
	if(localopened)
		if(fireaxe)
			user.put_in_hands(fireaxe)
			fireaxe = null
			to_chat(user, span_notice("You take the fire axe from the [name]."))
			update_icon()
		else
			if(src.smashed)
				return
			else
				localopened = !localopened
				if(localopened)
					src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
					spawn(10)
					update_icon()
				else
					src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
					spawn(10)
					update_icon()

	else
		localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
		if(localopened)
			src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]opening"
			spawn(10)
			update_icon()
		else
			src.icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]closing"
			spawn(10)
			update_icon()

/obj/structure/closet/fireaxecabinet/verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
	set name = "Open/Close"
	set category = "Object"

	if (locked || smashed)
		if(src.locked)
			to_chat(usr, span_warning("The cabinet won't budge!"))
		else if(src.smashed)
			to_chat(usr, span_notice("The protective glass is broken!"))
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
			to_chat(usr, span_notice("You take the Fire axe from the [name]."))
		else
			to_chat(usr, span_notice("The [src.name] is empty."))
	else
		to_chat(usr, span_notice("The [src.name] is closed."))
	update_icon()

/obj/structure/closet/fireaxecabinet/attack_ai(mob/user as mob)
	if(src.smashed)
		to_chat(user, span_warning("The security of the cabinet is compromised."))
		return
	else
		locked = !locked
		if(locked)
			to_chat(user, span_warning("Cabinet locked."))
		else
			to_chat(user, span_notice("Cabinet unlocked."))
		return

/obj/structure/closet/fireaxecabinet/update_icon() //Template: fireaxe[has fireaxe][is opened][hits taken][is smashed]. If you want the opening or closing animations, add "opening" or "closing" right after the numbers
	var/hasaxe = 0
	if(fireaxe)
		hasaxe = 1
	icon_state = "fireaxe[hasaxe][localopened][hitstaken][smashed]"

/obj/structure/closet/fireaxecabinet/open()
	return

/obj/structure/closet/fireaxecabinet/close()
	return
