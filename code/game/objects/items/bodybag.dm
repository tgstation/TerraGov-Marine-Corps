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
	desc = "A folded, reusable bag designed to prevent additional damage to an occupant."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"
	unfolded_path = /obj/structure/closet/bodybag/cryobag
	var/used = 0

	New(loc, obj/structure/closet/bodybag/cryobag/CB)
		..()
		if(CB)
			used = CB.used


/obj/item/storage/box/bodybags
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
	drag_delay = 2 //slightly easier than to drag the body directly.

	attackby(W as obj, mob/user as mob)
		if (istype(W, /obj/item/tool/pen))
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
		else if(istype(W, /obj/item/tool/wirecutters))
			user << "<span class='notice'>You cut the tag off the bodybag.</span>"
			src.name = "body bag"
			src.overlays.Cut()
			return
		else if(istype(W, /obj/item/weapon/zombie_claws))
			open()


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
	desc = "A reusable plastic bag designed to prevent additional damage to an occupant."
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag
	store_items = FALSE
	var/mob/living/stasis_mob //the mob in stasis
	var/used = 0
	var/last_use = 0 //remembers the value of used, to delay crostasis start.
	var/max_uses = 1800 //15 mins of usable cryostasis

	New(loc, obj/item/bodybag/cryobag/CB)
		..()
		if(CB)
			used = CB.used

	attackby(obj/item/I, mob/living/user)
		if(!istype(I, /obj/item/device/healthanalyzer))
			return
		var/obj/item/device/healthanalyzer/J = I
		if(!stasis_mob)
			user << "<span class='warning'>The stasis bag is empty!</span>"
			return
		J.attack(stasis_mob, user)
		return

	Dispose()
		var/mob/living/L = locate() in contents
		if(L)
			L.in_stasis = FALSE
			stasis_mob = null
			processing_objects.Remove(src)
		. = ..()

	open()
		var/mob/living/L = locate() in contents
		if(L)
			L.in_stasis = FALSE
			stasis_mob.buckled = null
			stasis_mob = null
			processing_objects.Remove(src)
		. = ..()
		if(used > max_uses)
			new /obj/item/trash/used_stasis_bag(loc)
			cdel(src)

	close()
		. = ..()
		last_use = used + 1
		var/mob/living/L = locate() in contents
		if(L)
			stasis_mob = L
			processing_objects.Add(src)

	relaymove(mob/living/user)
		if(user.in_stasis == STASIS_IN_BAG)
			return
		. = ..()

	process()
		used++
		if(!stasis_mob)
			processing_objects.Remove(src)
			open()
			return
		if(stasis_mob.stat == DEAD)// || !stasis_mob.key || !stasis_mob.client) // stop using cryobags for corpses and SSD/Ghosted
			processing_objects.Remove(src)
			open()
			visible_message("<span class='notice'>\The [src] rejects the corpse.</span>")
			return
		if(used > last_use) //cryostasis takes a couple seconds to kick in.
			if(!stasis_mob.in_stasis)
				stasis_mob.in_stasis = STASIS_IN_BAG
				stasis_mob.buckled = src
				stasis_mob.visible_message("<span class='notice'>You feel your biological processes have slowed.</span>")
		if(used > max_uses)
			open()

	examine(mob/living/user)
		..()
		if(stasis_mob)
			if(ishuman(stasis_mob))
				if(hasHUD(user,"medical"))
					var/mob/living/carbon/human/H = stasis_mob
					for(var/datum/data/record/R in data_core.medical)
						if (R.fields["name"] == H.real_name)
							if(!(R.fields["last_scan_time"]))
								user << "<span class = 'deptradio'>No scan report on record</span>\n"
							else
								user << "<span class = 'deptradio'><a href='?src=\ref[src];scanreport=1'>Scan from [R.fields["last_scan_time"]]</a></span>\n"
							break



		switch(used)
			if(0 to 600) user << "It looks new."
			if(601 to 1200) user << "It looks a bit used."
			if(1201 to 1800) user << "It looks really used."

	Topic(href, href_list)
		if (href_list["scanreport"])
			if(hasHUD(usr,"medical"))
				if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.medical < SKILL_MEDICAL_MEDIC)
					usr << "<span class='warning'>You're not trained to use this.</span>"
					return
				if(get_dist(usr, src) > 7)
					usr << "<span class='warning'>[src] is too far away.</span>"
					return
				if(ishuman(stasis_mob))
					var/mob/living/carbon/human/H = stasis_mob
					for(var/datum/data/record/R in data_core.medical)
						if (R.fields["name"] == H.real_name)
							if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
								usr << browse(R.fields["last_scan_result"], "window=scanresults;size=430x600")
							break



/obj/item/trash/used_stasis_bag
	name = "used stasis bag"
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_used"
	desc = "It's been ripped open. You will need to find a machine capable of recycling it."
