//Also contains /obj/structure/closet/bodybag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = 2.0
	var/unfolded_path = /obj/structure/closet/bodybag

	attack_self(mob/user)
		deploy_bodybag(user, user.loc)

	afterattack(atom/target, mob/user, proximity)
		if(!proximity)
			return
		if(isturf(target))
			var/turf/T = target
			if(!T.density)
				deploy_bodybag(user, T)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	var/obj/structure/closet/bodybag/R = new unfolded_path(location, src)
	R.add_fingerprint(user)
	R.open(user)
	user.temp_drop_inv_item(src)
	cdel(src)


/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed to prevent additional damage to an occupant at the cost of genetic damage."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"
	unfolded_path = /obj/structure/closet/bodybag/cryobag
	var/used = 0

	New(loc, obj/structure/closet/bodybag/cryobag/CB)
		..()
		if(CB)
			used = CB.used


/obj/item/weapon/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"
	w_class = 3
	New()
		..()
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)


/obj/structure/closet/bodybag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	var/item_path = /obj/item/bodybag
	density = 0
	storage_capacity = (mob_size * 2) - 1
	anchored = 0

	attackby(W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/pen))
			var/t = stripped_input(user, "What would you like the label to be?", name, null, MAX_MESSAGE_LEN)
			if (user.get_active_hand() != W)
				return
			if (!in_range(src, user) && src.loc != user)
				return
			if (t)
				src.name = "body bag - "
				src.name += t
				src.overlays += image(src.icon, "bodybag_label")
			else
				src.name = "body bag"
		//..() //Doesn't need to run the parent. Since when can fucking bodybags be welded shut? -Agouri
			return
		else if(istype(W, /obj/item/weapon/wirecutters))
			user << "<span class='notice'>You cut the tag off the bodybag.</span>"
			src.name = "body bag"
			src.overlays.Cut()
			return


	close()
		if(..())
			density = 0
			return 1
		return 0


	MouseDrop(over_object, src_location, over_location)
		..()
		if(over_object == usr && Adjacent(usr))
			if(!ishuman(usr))	return
			if(opened)	return 0
			if(contents.len)	return 0
			visible_message("<span class='notice'>[usr] folds up [name].</span>")
			var/obj/item/I = new item_path(get_turf(src), src)
			usr.put_in_hands(I)
			cdel(src)


/obj/structure/closet/bodybag/update_icon()
	if(!opened)
		icon_state = icon_closed
		for(var/mob/living/L in contents)
			icon_state += "1"
			break
	else
		icon_state = icon_opened



/obj/structure/closet/bodybag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed to prevent additional damage to an occupant at the cost of genetic damage."
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag
	store_misc = 0
	store_items = 0
	var/mob/living/stasis_mob //the mob in stasis
	var/used = 0
	var/last_use = 0 //remembers the value of used, to delay crostasis start.
	var/max_uses = 1800 //15 mins of usable cryostasis

	New(loc, obj/item/bodybag/cryobag/CB)
		..()
		if(CB)
			used = CB.used

	Dispose()
		stasis_mob = null
		. = ..()

	open()
		var/mob/living/L = locate() in contents
		if(L)
			L.in_stasis = FALSE
			stasis_mob = null
			processing_objects.Remove(src)
		. = ..()
		if(used > max_uses)
			new /obj/item/used_stasis_bag(loc)
			cdel(src)

	close()
		. = ..()
		last_use = used + 1
		var/mob/living/L = locate() in contents
		if(L)
			stasis_mob = L
			processing_objects.Add(src)

	process()
		used++
		if(used > last_use) //cryostasis takes a couple seconds to kick in.
			if(!stasis_mob.in_stasis) stasis_mob.in_stasis = STASIS_IN_BAG
		if(used > max_uses)
			open()

	examine()
		..()
		switch(used)
			if(0 to 600) usr << "It looks new."
			if(601 to 1200) usr << "It looks a bit used."
			if(1201 to 1800) usr << "It looks really used."


/obj/item/used_stasis_bag
	name = "used stasis bag"
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_used"
	desc = "Pretty useless now.."