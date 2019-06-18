//Also contains /obj/structure/closet/bodybag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = 2.0
	var/unfolded_path = /obj/structure/closet/bodybag

/obj/item/bodybag/attack_self(mob/user)
	deploy_bodybag(user, user.loc)

/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			deploy_bodybag(user, T)

/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	if(!isturf(user.loc))
		return FALSE
	for(var/obj/O in location)
		if(istype(O, /obj/structure/closet) || O.density)
			to_chat(user, "<span class='warning'>\the [src] can't be deployed here.</span>")
			return FALSE
	var/obj/structure/closet/bodybag/R = new unfolded_path(location, src)
	R.open(user)
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)
	return TRUE


/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, reusable bag designed to prevent additional damage to an occupant."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"
	unfolded_path = /obj/structure/closet/bodybag/cryobag
	var/used = 0

/obj/item/bodybag/cryobag/New(loc, obj/structure/closet/bodybag/cryobag/CB)
	..()
	if(CB)
		used = CB.used


/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"
	w_class = 3
	spawn_type = /obj/item/bodybag
	spawn_number = 7

/obj/structure/closet/bodybag
	name = "body bag"
	var/bag_name = "body bag"
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
	var/obj/structure/bed/roller/roller_buckled //the roller bed this bodybag is attached to.
	store_items = FALSE

/obj/structure/closet/bodybag/proc/update_name()
	if(opened)
		name = bag_name
	else
		var/mob/living/carbon/human/H = locate() in contents
		if(H)
			name = "[bag_name] ([H.get_visible_name()])"
		else
			name = "[bag_name] (empty)"

/obj/structure/closet/bodybag/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen))
		var/t = stripped_input(user, "What would you like the label to be?", name, null, MAX_MESSAGE_LEN)
		if(user.get_active_held_item() != I)
			return

		if(!in_range(src, user) && loc != user)
			return

		if(t)
			name = "body bag - "
			name += t
			overlays += image(icon, "bodybag_label")
		else
			name = "body bag"

	else if(iswirecutter(I))
		to_chat(user, "<span class='notice'>You cut the tag off the bodybag.</span>")
		name = "body bag"
		overlays.Cut()


/obj/structure/closet/bodybag/store_mobs(var/stored_units) // overriding this
	var/list/dead_mobs = list()
	for(var/mob/living/M in loc)
		if(M.buckled)
			continue
		if(M.stat != DEAD) // covers alive mobs
			continue
		if(!ishuman(M)) // all the dead other shit
			dead_mobs += M
			continue
		var/mob/living/carbon/human/H = M
		if(check_tod(H) || issynth(H)) // revivable
			if(H.is_revivable() && H.get_ghost()) // definitely revivable
				continue
		dead_mobs += M
	var/mob/living/mob_to_store
	if(dead_mobs.len)
		mob_to_store = pick(dead_mobs)
		mob_to_store.forceMove(src)
		stored_units += mob_size
	return stored_units

/obj/structure/closet/bodybag/close()
	if(..())
		density = 0
		update_name()
		return TRUE
	return FALSE

/obj/structure/closet/bodybag/open()
	. = ..()
	update_name()

/obj/structure/closet/bodybag/MouseDrop(over_object, src_location, over_location)
	..()
	if(over_object == usr && Adjacent(usr) && !roller_buckled)
		if(!ishuman(usr))
			return
		if(opened)
			return FALSE
		if(contents.len)
			return FALSE
		visible_message("<span class='notice'>[usr] folds up [name].</span>")
		var/obj/item/I = new item_path(get_turf(src), src)
		usr.put_in_hands(I)
		qdel(src)



/obj/structure/closet/bodybag/Move(NewLoc, direct)
	if (roller_buckled && roller_buckled.loc != NewLoc) //not updating position
		if (!roller_buckled.anchored)
			return roller_buckled.Move(NewLoc, direct)
		else
			return FALSE
	else
		. = ..()


/obj/structure/closet/bodybag/forceMove(atom/destination)
	if(roller_buckled)
		roller_buckled.unbuckle()
	. = ..()



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
	bag_name = "stasis bag"
	desc = "A reusable plastic bag designed to prevent additional damage to an occupant."
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag
	store_items = FALSE
	var/mob/living/carbon/human/stasis_mob //the mob in stasis
	var/used = 0
	var/last_use = 0 //remembers the value of used, to delay crostasis start.
	var/max_uses = 1800 //15 mins of usable cryostasis

/obj/structure/closet/bodybag/cryobag/New(loc, obj/item/bodybag/cryobag/CB)
	..()
	if(CB)
		used = CB.used

/obj/structure/closet/bodybag/cryobag/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/healthanalyzer))
		return

	if(!stasis_mob)
		to_chat(user, "<span class='warning'>The stasis bag is empty!</span>")
		return

	var/obj/item/healthanalyzer/J = I
	J.attack(stasis_mob, user) // yes this is awful -spookydonut

/obj/structure/closet/bodybag/attack_alien(mob/living/carbon/xenomorph/M)
	if(opened)
		return FALSE // stop xeno closing things
	M.animation_attack_on(src)
	open()
	M.visible_message("<span class='danger'>\The [M] slashes \the [src] open!</span>", \
		"<span class='danger'>You slash \the [src] open!</span>", null, 5)
	return TRUE

/obj/structure/closet/bodybag/cryobag/Destroy()
	var/mob/living/L = locate() in contents
	if(L)
		L.in_stasis = FALSE
		stasis_mob = null
		STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/closet/bodybag/cryobag/open()
	var/mob/living/L = locate() in contents
	if(L)
		L.in_stasis = FALSE
		stasis_mob = null
		STOP_PROCESSING(SSobj, src)
	. = ..()
	if(used > max_uses)
		new /obj/item/trash/used_stasis_bag(loc)
		qdel(src)

/obj/structure/closet/bodybag/cryobag/store_mobs(var/stored_units) // overriding this
	var/list/mobs_can_store = list()
	for(var/mob/living/carbon/human/H in loc)
		if(H.buckled)
			continue
		if(H.stat == DEAD) // dead, nope
			continue
		mobs_can_store += H
	var/mob/living/carbon/human/mob_to_store
	if(mobs_can_store.len)
		mob_to_store = pick(mobs_can_store)
		mob_to_store.forceMove(src)
		stored_units += mob_size
	return stored_units

/obj/structure/closet/bodybag/cryobag/close()
	. = ..()
	last_use = used + 1
	var/mob/living/carbon/human/H = locate() in contents
	if(H)
		stasis_mob = H
		START_PROCESSING(SSobj, src)

/obj/structure/closet/bodybag/cryobag/process()
	used++
	if(!stasis_mob)
		STOP_PROCESSING(SSobj, src)
		open()
		return
	if(stasis_mob.stat == DEAD)// || !stasis_mob.key || !stasis_mob.client) // stop using cryobags for corpses and SSD/Ghosted
		STOP_PROCESSING(SSobj, src)
		open()
		visible_message("<span class='notice'>\The [src] rejects the corpse.</span>")
		return
	if(used > last_use) //cryostasis takes a couple seconds to kick in.
		if(!stasis_mob.in_stasis)
			stasis_mob.in_stasis = STASIS_IN_BAG
	if(used > max_uses)
		open()

/obj/structure/closet/bodybag/cryobag/examine(mob/living/user)
	..()
	if(stasis_mob)
		if(ishuman(stasis_mob))
			if(hasHUD(user,"medical"))
				var/mob/living/carbon/human/H = stasis_mob
				for(var/datum/data/record/R in GLOB.datacore.medical)
					if (R.fields["name"] == H.real_name)
						if(!(R.fields["last_scan_time"]))
							to_chat(user, "<span class = 'deptradio'>No scan report on record</span>\n")
						else
							to_chat(user, "<span class = 'deptradio'><a href='?src=\ref[src];scanreport=1'>Scan from [R.fields["last_scan_time"]]</a></span>\n")
						break



	switch(used)
		if(0 to 600) to_chat(user, "It looks new.")
		if(601 to 1200) to_chat(user, "It looks a bit used.")
		if(1201 to 1800) to_chat(user, "It looks really used.")

/obj/structure/closet/bodybag/cryobag/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (href_list["scanreport"])
		if(hasHUD(usr,"medical"))
			if(get_dist(usr, src) > 7)
				to_chat(usr, "<span class='warning'>[src] is too far away.</span>")
				return
			if(ishuman(stasis_mob))
				var/mob/living/carbon/human/H = stasis_mob
				for(var/datum/data/record/R in GLOB.datacore.medical)
					if (R.fields["name"] == H.real_name)
						if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
							var/datum/browser/popup = new(usr, "scanresults", "<div align='center'>Last Scan Result</div>", 430, 600)
							popup.set_content(R.fields["last_scan_result"])
							popup.open(FALSE)
						break



/obj/item/trash/used_stasis_bag
	name = "used stasis bag"
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_used"
	desc = "It's been ripped open. You will need to find a machine capable of recycling it."
