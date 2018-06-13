/obj/item/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 5
	w_class = 2
	throw_speed = 2
	throw_range = 5
	matter = list("metal" = 500)
	origin_tech = "materials=1"
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes
	var/single_use = 0 //determines if handcuffs will be deleted on removal
	var/cuff_sound = 'sound/weapons/handcuffs.ogg'
	var/cuff_delay = 40 //how many deciseconds it takes to cuff someone

/obj/item/handcuffs/attack(mob/living/carbon/C, mob/user)
	if(!istype(C))
		return ..()
	if (!istype(user, /mob/living/carbon/human))
		user << "\red You don't have the dexterity to do this!"
		return
	if ((CLUMSY in usr.mutations) && prob(50))
		user << "\red Uh ... how do those things work?!"
		place_handcuffs(user, user)
		return
	if(!C.handcuffed)
		place_handcuffs(C, user)

/obj/item/handcuffs/proc/place_handcuffs(var/mob/living/carbon/target, var/mob/user)
	playsound(src.loc, cuff_sound, 25, 1, 4)

	if(user.action_busy)
		return

	if (ishuman(target))
		var/mob/living/carbon/human/H = target

		if (!H.has_limb_for_slot(WEAR_HANDCUFFS))
			user << "\red \The [H] needs at least two wrists before you can cuff them together!"
			return

		H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been handcuffed (attempt) by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to handcuff [H.name] ([H.ckey])</font>")
		msg_admin_attack("[key_name(user)] attempted to handcuff [key_name(H)]")

		feedback_add_details("handcuffs","H")

		user.visible_message("<span class='notice'>[user] tries to put [src] on [H].</span>")
		if(do_mob(user, H, cuff_delay, BUSY_ICON_HOSTILE, BUSY_ICON_GENERIC))
			if(src == user.get_active_hand() && !H.handcuffed && Adjacent(user))
				if(H.has_limb_for_slot(WEAR_HANDCUFFS))
					user.drop_inv_item_on_ground(src)
					H.equip_to_slot_if_possible(src, WEAR_HANDCUFFS, 1, 0, 1, 1)

	else if (ismonkey(target))
		user.visible_message("<span class='notice'>[user] tries to put [src] on [target].</span>")
		if(do_mob(user, target, 30, BUSY_ICON_HOSTILE, BUSY_ICON_GENERIC))
			if(src == user.get_active_hand() && !target.handcuffed && Adjacent(user))
				user.drop_inv_item_on_ground(src)
				target.equip_to_slot_if_possible(src, WEAR_HANDCUFFS, 1, 0, 1, 1)


/obj/item/handcuffs/zip
	name = "zip cuffs"
	desc = "Single-use plastic zip tie handcuffs."
	w_class = 1
	icon_state = "cuff_zip"
	breakouttime = 600 //Deciseconds = 60s
	cuff_sound = 'sound/weapons/cablecuff.ogg'
	cuff_delay = 20

	place_handcuffs(mob/living/carbon/target, mob/user)
		..()
		flags_item |= DELONDROP



/obj/item/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_white"
	breakouttime = 300 //Deciseconds = 30s
	cuff_sound = 'sound/weapons/cablecuff.ogg'

/obj/item/handcuffs/cable/red
	color = "#DD0000"

/obj/item/handcuffs/cable/yellow
	color = "#DDDD00"

/obj/item/handcuffs/cable/blue
	color = "#0000DD"

/obj/item/handcuffs/cable/green
	color = "#00DD00"

/obj/item/handcuffs/cable/pink
	color = "#DD00DD"

/obj/item/handcuffs/cable/orange
	color = "#DD8800"

/obj/item/handcuffs/cable/cyan
	color = "#00DDDD"

/obj/item/handcuffs/cable/white
	color = "#FFFFFF"

/obj/item/handcuffs/cable/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/weapon/wirerod/W = new /obj/item/weapon/wirerod

			user.put_in_hands(W)
			user << "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>"
			cdel(src)
			update_icon(user)


/obj/item/handcuffs/cyborg
	dispenser = 1

/obj/item/handcuffs/cyborg/attack(mob/living/carbon/C as mob, mob/user as mob)
	if(!C.handcuffed)
		var/turf/p_loc = user.loc
		var/turf/p_loc_m = C.loc
		playsound(src.loc, cuff_sound, 25, 1, 4)
		user.visible_message("\red <B>[user] is trying to put handcuffs on [C]!</B>")

		if (ishuman(C))
			var/mob/living/carbon/human/H = C
			if (!H.has_limb_for_slot(WEAR_HANDCUFFS))
				user << "\red \The [H] needs at least two wrists before you can cuff them together!"
				return

		spawn(30)
			if(!C)	return
			if(p_loc == user.loc && p_loc_m == C.loc)
				C.handcuffed = new /obj/item/handcuffs(C)
				C.handcuff_update()





/obj/item/restraints
	name = "xeno restraints"
	desc = "Use this to hold xenomorphic creatures saftely."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "handcuff"
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	throwforce = 5
	w_class = 2.0
	throw_speed = 2
	throw_range = 5
	matter = list("metal" = 500)
	origin_tech = "materials=1"
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes

/obj/item/restraints/attack(mob/living/carbon/C as mob, mob/user as mob)
	if(!istype(C, /mob/living/carbon/Xenomorph))
		user << "\red The cuffs do not fit!"
		return
	if(!C.handcuffed)
		var/turf/p_loc = user.loc
		var/turf/p_loc_m = C.loc
		playsound(src.loc, 'sound/weapons/handcuffs.ogg', 25, 1, 6)
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] is trying to put restraints on [C]!</B>", 1)
		spawn(30)
			if(!C)	return
			if(p_loc == user.loc && p_loc_m == C.loc)
				C.handcuffed = new /obj/item/restraints(C)
				C.handcuff_update()
				C.visible_message("\red [C] has been successfully restrained by [user]!")
				cdel(src)
	return
