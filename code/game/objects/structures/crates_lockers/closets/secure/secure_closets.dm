/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's an immobile card-locked storage unit."
	icon_state = "secure1"
	density = TRUE
	opened = 0
	locked = TRUE
	broken = FALSE
	var/large = 1
	icon_closed = "secure"
	var/icon_locked = "secure1"
	icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"
	max_integrity = 100
	var/slotlocked = 0

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
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(opened)
		to_chat(user, "<span class='notice'>Close the locker first.</span>")
		return
	if(broken)
		to_chat(user, "<span class='warning'>The locker appears to be broken.</span>")
		return
	if(user.loc == src)
		to_chat(user, "<span class='notice'>You can't reach the lock from inside.</span>")
		return
	if(allowed(user))
		if(slotlocked)
			var/obj/item/card/id/I = user.get_idcard(TRUE)
			if(!I || I.claimedgear)
				return
			I.claimedgear = TRUE // you only get one locker, all other roles have this set 1 by default
			slotlocked = FALSE // now permanently unlockable
		locked = !locked
		user.visible_message("<span class='notice'>\the [src] has been [locked ? "" : "un"]locked by [user].</span>", \
							"<span class='notice'>You [locked ? "" : "un"]lock \the [src].</span>", null, 3)
		update_icon()
	else
		to_chat(user, "<span class='notice'>Access Denied</span>")

/obj/structure/closet/secure_closet/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/emag))
		if(broken) 
			return
		broken = TRUE
		locked = FALSE
		desc = "It appears to be broken."
		icon_state = icon_off
		flick(icon_broken, src)
		visible_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", "You hear a faint electrical spark.")
	
	else
		togglelock(user)

/obj/structure/closet/secure_closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/secure_closet/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated())
		return
	togglelock(usr)

/obj/structure/closet/secure_closet/update_icon()
	overlays.Cut()
	if(opened)
		icon_state = icon_opened
	else
		icon_state = locked ? icon_locked : icon_closed
	if(welded)
		overlays += overlay_welded

/obj/structure/closet/secure_closet/break_open()
	broken = TRUE
	locked = FALSE
	..()
