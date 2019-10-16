//Also contains /obj/structure/closet/bodybag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = WEIGHT_CLASS_SMALL
	var/unfoldedbag_path = /obj/structure/closet/bodybag
	var/obj/structure/closet/bodybag/unfoldedbag_instance = null


/obj/item/bodybag/Initialize(mapload, unfoldedbag)
	. = ..()
	unfoldedbag_instance = unfoldedbag


/obj/item/bodybag/Destroy()
	if(QDELETED(unfoldedbag_instance))
		unfoldedbag_instance = null
	else
		if(!isnull(unfoldedbag_instance.loc))
			stack_trace("[src] destroyed while the [unfoldedbag_instance] unfoldedbag_instance was neither destroyed nor in nullspace. This shouldn't happen.")
		QDEL_NULL(unfoldedbag_instance)
	return ..()


/obj/item/bodybag/attack_self(mob/user)
	deploy_bodybag(user, user.loc)


/obj/item/bodybag/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(!isopenturf(target))
		return
	deploy_bodybag(user, target)


/obj/item/bodybag/proc/deploy_bodybag(mob/user, atom/location)
	if(QDELETED(unfoldedbag_instance))
		unfoldedbag_instance = new unfoldedbag_path(location, src)
	else
		unfoldedbag_instance.forceMove(location)
	unfoldedbag_instance.open(user)
	user.temporarilyRemoveItemFromInventory(src)
	moveToNullspace()


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
	density = FALSE
	mob_storage_capacity = 1
	storage_capacity = 3 //Just room enough for that stripped armor, gun and whatnot.
	anchored = FALSE
	drag_delay = 2 //slightly easier than to drag the body directly.
	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null
	var/obj/structure/bed/roller/roller_buckled //the roller bed this bodybag is attached to.
	var/mob/living/carbon/human/bodybag_occupant


/obj/structure/closet/bodybag/Initialize(mapload, foldedbag)
	. = ..()
	foldedbag_instance = foldedbag


/obj/structure/closet/bodybag/Destroy()
	open()
	if(QDELETED(foldedbag_instance))
		foldedbag_instance = null
	else
		if(!isnull(foldedbag_instance.loc))
			stack_trace("[src] destroyed while the [foldedbag_instance] foldedbag_instance was neither destroyed nor in nullspace. This shouldn't happen.")
		QDEL_NULL(foldedbag_instance)
	return ..()


/obj/structure/closet/bodybag/proc/update_name()
	if(opened)
		name = bag_name
	else
		if(bodybag_occupant)
			name = "[bag_name] ([bodybag_occupant.get_visible_name()])"
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


/obj/structure/closet/bodybag/closet_special_handling(mob/living/mob_to_stuff) // overriding this
	if(!ishuman(mob_to_stuff))
		return FALSE //Only humans.
	if(mob_to_stuff.stat != DEAD) //Only the dead for bodybags.
		return FALSE
	var/mob/living/carbon/human/human_to_stuff = mob_to_stuff
	if(human_to_stuff.is_revivable() && (check_tod(human_to_stuff) || issynth(human_to_stuff)))
		return FALSE //We don't want to store those that can be revived.
	return TRUE


/obj/structure/closet/bodybag/close()
	. = ..()
	if(.)
		density = FALSE //A bit dumb, but closets become dense when closed, and this is a closet.
		var/mob/living/carbon/human/new_guest = locate() in contents
		if(new_guest)
			bodybag_occupant = new_guest
		update_name()
		return TRUE
	return FALSE


/obj/structure/closet/bodybag/open()
	. = ..()
	if(bodybag_occupant)
		bodybag_occupant = null
	update_name()


/obj/structure/closet/bodybag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && !roller_buckled)
		if(!ishuman(usr))
			return
		if(opened)
			return FALSE
		if(length(contents))
			return FALSE
		visible_message("<span class='notice'>[usr] folds up [name].</span>")
		if(QDELETED(foldedbag_instance))
			foldedbag_instance = new foldedbag_path(loc, src)
		usr.put_in_hands(foldedbag_instance)
		moveToNullspace()


/obj/structure/closet/bodybag/Move(NewLoc, direct)
	if (roller_buckled && roller_buckled.loc != NewLoc) //not updating position
		if (!roller_buckled.anchored)
			return roller_buckled.Move(NewLoc, direct)
		else
			return FALSE
	else
		. = ..()


/obj/structure/closet/bodybag/forceMove(atom/destination)
	roller_buckled?.unbuckle()
	return ..()


/obj/structure/closet/bodybag/update_icon()
	if(!opened)
		icon_state = icon_closed
		for(var/mob/living/L in contents)
			icon_state += "1"
			break
	else
		icon_state = icon_opened


/obj/structure/closet/bodybag/attack_alien(mob/living/carbon/xenomorph/xeno)
	if(opened)
		return FALSE // stop xeno closing things
	xeno.do_attack_animation(src)
	open()
	xeno.visible_message("<span class='danger'>\The [xeno] slashes \the [src] open!</span>", \
		"<span class='danger'>We slash \the [src] open!</span>", null, 5)
	return TRUE


/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"
	w_class = WEIGHT_CLASS_NORMAL
	spawn_type = /obj/item/bodybag
	spawn_number = 7


/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, reusable bag designed to prevent additional damage to an occupant."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"
	unfoldedbag_path = /obj/structure/closet/bodybag/cryobag
	var/used = FALSE


/obj/structure/closet/bodybag/cryobag
	name = "stasis bag"
	bag_name = "stasis bag"
	desc = "A reusable plastic bag designed to prevent additional damage to an occupant."
	icon = 'icons/obj/cryobag.dmi'
	foldedbag_path = /obj/item/bodybag/cryobag


/obj/structure/closet/bodybag/cryobag/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/healthanalyzer))
		return ..()

	if(!bodybag_occupant)
		to_chat(user, "<span class='warning'>The stasis bag is empty!</span>")
		return TRUE

	var/obj/item/healthanalyzer/J = I
	J.attack(bodybag_occupant, user) // yes this is awful -spookydonut
	return TRUE


/obj/structure/closet/bodybag/cryobag/open()
	if(bodybag_occupant)
		bodybag_occupant.in_stasis = FALSE
		UnregisterSignal(bodybag_occupant, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETED))
	return ..()


/obj/structure/closet/bodybag/cryobag/closet_special_handling(mob/living/mob_to_stuff) // overriding this
	if(!ishuman(mob_to_stuff))
		return FALSE //Humans only.
	if(mob_to_stuff.stat == DEAD) // dead, nope
		return FALSE
	return TRUE


/obj/structure/closet/bodybag/cryobag/close()
	. = ..()
	if(bodybag_occupant)
		bodybag_occupant.in_stasis = STASIS_IN_BAG
		RegisterSignal(bodybag_occupant, list(COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETED), .proc/on_bodybag_occupant_death)


/obj/structure/closet/bodybag/cryobag/proc/on_bodybag_occupant_death(datum/source, gibbed)
	if(!QDELETED(bodybag_occupant))
		visible_message("<span class='notice'>\The [src] rejects the corpse.</span>")
	open()


/obj/structure/closet/bodybag/cryobag/examine(mob/living/user)
	. = ..()
	if(!ishuman(bodybag_occupant))
		return
	if(!hasHUD(user,"medical"))
		return
	for(var/r in GLOB.datacore.medical)
		var/datum/data/record/medical_record = r
		if(medical_record.fields["name"] != bodybag_occupant.real_name)
			continue
		if(!(medical_record.fields["last_scan_time"]))
			to_chat(user, "<span class = 'deptradio'>No scan report on record</span>\n")
		else
			to_chat(user, "<span class = 'deptradio'><a href='?src=\ref[src];scanreport=1'>Scan from [medical_record.fields["last_scan_time"]]</a></span>\n")
		break


/obj/structure/closet/bodybag/cryobag/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["scanreport"])
		if(!hasHUD(usr,"medical"))
			return
		if(get_dist(usr, src) > world.view)
			to_chat(usr, "<span class='warning'>[src] is too far away.</span>")
			return
		for(var/datum/data/record/R in GLOB.datacore.medical)
			if(R.fields["name"] != bodybag_occupant.real_name)
				continue
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
