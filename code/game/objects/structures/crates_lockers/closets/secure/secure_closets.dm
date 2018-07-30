/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon_state = "secure1"
	density = 1
	opened = 0
	var/locked = 1
	var/broken = 0
	var/large = 1
	icon_closed = "secure"
	var/icon_locked = "secure1"
	icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"
	health = 100
	var/slotlocked = 0
	var/slotlocktype = null

/obj/structure/closet/secure_closet/can_open()
	if(src.locked)
		return 0
	return ..()

/obj/structure/closet/secure_closet/close()
	if(..())
		if(broken)
			icon_state = src.icon_off
		return 1
	else
		return 0

/obj/structure/closet/secure_closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(!broken)
		if(prob(50/severity))
			src.locked = !src.locked
			src.update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				src.req_access = list()
				src.req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/secure_closet/proc/togglelock(mob/living/user)
	if(src.opened)
		user << "<span class='notice'>Close the locker first.</span>"
		return
	if(src.broken)
		user << "<span class='warning'>The locker appears to be broken.</span>"
		return
	if(user.loc == src)
		user << "<span class='notice'>You can't reach the lock from inside.</span>"
		return
	if(src.allowed(user))
		if(slotlocked && ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.wear_id)
				var/obj/item/card/id/I = H.wear_id
				if(I.claimedgear)
					return
				switch(slotlocktype)
					if("engi")
						if(H.mind.assigned_role != "Squad Engineer")
							return // stop people giving medics engineer prep access or IDs somehow
					if("medic")
						if(H.mind.assigned_role != "Squad Medic")
							return // same here
				I.claimedgear = 1 // you only get one locker, all other roles have this set 1 by default
				slotlocked = 0 // now permanently unlockable
			else
				return // they have no ID on, fuck them.
		src.locked = !src.locked
		for(var/mob/O in viewers(user, 3))
			if((O.client && !( O.blinded )))
				O << "<span class='notice'>The locker has been [locked ? null : "un"]locked by [user].</span>"
		update_icon()
	else
		user << "<span class='notice'>Access Denied</span>"

/obj/structure/closet/secure_closet/attackby(obj/item/W, mob/living/user)
	if(src.opened)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(G.grabbed_thing)
				if(src.large)
					src.MouseDrop_T(G.grabbed_thing, user)	//act like they were dragged onto the closet
				else
					user << "<span class='notice'>The locker is too small to stuff [W:affecting] into!</span>"
			return
		if(isrobot(user))
			return
		user.drop_held_item()
		if(W)
			W.loc = src.loc
	else if(istype(W, /obj/item/card/emag))
		if(broken) return
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = icon_off
		flick(icon_broken, src)
		for(var/mob/O in viewers(user, 3))
			O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)
	else if(istype(W,/obj/item/packageWrap) || istype(W,/obj/item/tool/weldingtool))
		return ..(W,user)
	else
		togglelock(user)

/obj/structure/closet/secure_closet/attack_hand(mob/living/user)
	src.add_fingerprint(user)
	if(src.locked)
		src.togglelock(user)
	else
		if(opened && isXeno(user))
			return // stop xeno closing them
		src.toggle(user)

/obj/structure/closet/secure_closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(!usr.canmove || usr.stat || usr.is_mob_restrained()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.togglelock(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"

/obj/structure/closet/secure_closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		if(locked)
			icon_state = icon_locked
		else
			icon_state = icon_closed
		if(welded)
			overlays += "welded"
	else
		icon_state = icon_opened

/obj/structure/closet/secure_closet/break_open()
	broken = TRUE
	locked = FALSE
	..()
