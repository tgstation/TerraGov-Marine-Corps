/*
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "bed"
	desc = "A mattress seated on a rectangular metallic frame. This is used to support a lying person in a comfortable manner, notably for regular sleep. Ancient technology, but still useful."
	icon_state = "bed"
	icon = 'icons/obj/objects.dmi'
	can_buckle = TRUE
	buckle_lying = TRUE
	throwpass = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/foldabletype //To fold into an item (e.g. roller bed item)
	var/buckling_y = 0 //pixel y shift to give to the buckled mob.
	var/obj/structure/closet/bodybag/buckled_bodybag
	var/accepts_bodybag = FALSE //Whether you can buckle bodybags to this bed
	var/base_bed_icon //Used by beds that change sprite when something is buckled to them
	var/hit_bed_sound = 'sound/effects/metalhit.ogg' //sound player when attacked by a xeno

/obj/structure/bed/update_icon()
	if(base_bed_icon)
		if(buckled_mob || buckled_bodybag)
			icon_state = "[base_bed_icon]_up"
		else
			icon_state = "[base_bed_icon]_down"

obj/structure/bed/Dispose()
	if(buckled_bodybag)
		unbuckle()
	. = ..()

/obj/structure/bed/afterbuckle(mob/M)
	. = ..()
	if(. && buckled_mob == M)
		M.pixel_y = buckling_y
		M.old_y = buckling_y
		if(base_bed_icon)
			density = 1
	else
		M.pixel_y = initial(buckled_mob.pixel_y)
		M.old_y = initial(buckled_mob.pixel_y)
		if(base_bed_icon)
			density = 0

	update_icon()

//Unsafe proc
/obj/structure/bed/proc/do_buckle_bodybag(obj/structure/closet/bodybag/B, mob/user)
	B.visible_message("<span class='notice'>[user] buckles [B] to [src]!</span>")
	B.roller_buckled = src
	B.loc = loc
	B.dir = dir
	buckled_bodybag = B
	density = 1
	update_icon()
	if(buckling_y)
		buckled_bodybag.pixel_y = buckling_y
	add_fingerprint(user)

/obj/structure/bed/unbuckle()
	if(buckled_bodybag)
		buckled_bodybag.pixel_y = initial(buckled_bodybag.pixel_y)
		buckled_bodybag.roller_buckled = null
		buckled_bodybag = null
		density = 0
		update_icon()
	else
		..()

/obj/structure/bed/manual_unbuckle(mob/user)
	if(buckled_bodybag)
		unbuckle()
		add_fingerprint(user)
		return 1
	else
		. = ..()

//Trying to buckle a mob
/obj/structure/bed/buckle_mob(mob/M, mob/user)
	if(buckled_bodybag)
		return
	..()


/obj/structure/bed/Move(NewLoc, direct)
	. = ..()
	if(. && buckled_bodybag && !handle_buckled_bodybag_movement(loc,direct)) //Movement fails if buckled mob's move fails.
		return 0

/obj/structure/bed/proc/handle_buckled_bodybag_movement(NewLoc, direct)
	if(!(direct & (direct - 1))) //Not diagonal move. the obj's diagonal move is split into two cardinal moves and those moves will handle the buckled bodybag's movement.
		if(!buckled_bodybag.Move(NewLoc, direct))
			loc = buckled_bodybag.loc
			last_move_dir = buckled_bodybag.last_move_dir
			return 0
	return 1

/obj/structure/bed/roller/CanPass(atom/movable/mover, turf/target)
	if(mover == buckled_bodybag)
		return TRUE
	. = ..()

/obj/structure/bed/MouseDrop_T(atom/dropping, mob/user)
	if(accepts_bodybag && !buckled_bodybag && !buckled_mob && istype(dropping,/obj/structure/closet/bodybag) && ishuman(user))
		var/obj/structure/closet/bodybag/B = dropping
		if(!B.roller_buckled)
			do_buckle_bodybag(B, user)
			return TRUE
	else
		. = ..()

/obj/structure/bed/MouseDrop(atom/over_object)
	. = ..()
	if(foldabletype && !buckled_mob && !buckled_bodybag)
		if (istype(over_object, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = over_object
			if (H==usr && !H.is_mob_incapacitated() && Adjacent(H) && in_range(src, over_object))
				var/obj/item/I = new foldabletype(get_turf(src))
				H.put_in_hands(I)
				H.visible_message("<span class='warning'>[H] grabs [src] from the floor!</span>",
				"<span class='warning'>You grab [src] from the floor!</span>")
				cdel(src)

/obj/structure/bed/ex_act(severity)
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if(prob(50))
				if(buildstacktype)
					new buildstacktype (loc, buildstackamount)
				cdel(src)
		if(3)
			if(prob(5))
				if(buildstacktype)
					new buildstacktype (loc, buildstackamount)
				cdel(src)


/obj/structure/bed/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/tool/wrench))
		if(buildstacktype)
			playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			new buildstacktype(loc, buildstackamount)
			cdel(src)

	else if(istype(W, /obj/item/grab) && !buckled_mob)
		var/obj/item/grab/G = W
		if(ismob(G.grabbed_thing))
			var/mob/M = G.grabbed_thing
			user << "<span class='notice'>You place [M] on [src].</span>"
			M.forceMove(loc)
		return TRUE

	else
		. = ..()

/obj/structure/bed/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	. = ..()

/obj/structure/bed/alien
	icon_state = "abed"

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "roller bed"
	desc = "A basic cushioned leather board resting on a small frame. Not very comfortable at all, but allows the patient to rest lying down while moved to another location rapidly."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "roller_down"
	anchored = FALSE
	drag_delay = 0 //Pulling something on wheels is easy
	buckling_y = 6
	foldabletype = /obj/item/roller
	accepts_bodybag = TRUE
	base_bed_icon = "roller"

/obj/structure/bed/roller/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/roller_holder) && !buckled_bodybag)
		if(buckled_mob || buckled_bodybag)
			manual_unbuckle()
		else
			visible_message("<span class='notice'>[user] collapses [name].</span>")
			new/obj/item/roller(get_turf(src))
			cdel(src)
		return
	. = ..()

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 2 //Fits in a backpack
	drag_delay = 1 //Pulling something on wheels is easy
	var/rollertype = /obj/structure/bed/roller

/obj/item/roller/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user , proximity)
	if(!proximity) return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			deploy_roller(user, target)

/obj/item/roller/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/roller_holder) && rollertype == /obj/structure/bed/roller)
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			user << "<span class='notice'>You pick up [src].</span>"
			loc = RH
			RH.held = src
			return
	. = ..()

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new rollertype(location)
	R.add_fingerprint(user)
	user.temp_drop_inv_item(src)
	cdel(src)

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller/held

/obj/item/roller_holder/New()
	..()
	held = new /obj/item/roller(src)

/obj/item/roller_holder/attack_self(mob/user as mob)

	if(!held)
		user << "<span class='warning'>The rack is empty.</span>"
		return

	var/obj/structure/bed/roller/R = new(user.loc)
	user << "<span class='notice'>You deploy [R].</span>"
	R.add_fingerprint(user)
	cdel(held)
	held = null

////////////////////////////////////////////
			//MEDEVAC STRETCHER
//////////////////////////////////////////////

//List of all activated medevac stretchers
var/global/list/activated_medevac_stretchers = list()

/obj/structure/bed/medevac_stretcher
	name = "medevac stretcher"
	desc = "A medevac stretcher with integrated beacon for rapid evacuation of an injured patient via dropship lift. Accepts patients and body bags."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "stretcher_down"
	buckling_y = 6
	foldabletype = /obj/item/roller/medevac
	base_bed_icon = "stretcher"
	accepts_bodybag = TRUE
	var/stretcher_activated
	var/obj/structure/dropship_equipment/medevac_system/linked_medevac

/obj/structure/bed/medevac_stretcher/Dispose()
	if(stretcher_activated)
		stretcher_activated = FALSE
		activated_medevac_stretchers -= src
		if(linked_medevac)
			linked_medevac.linked_stretcher = null
			linked_medevac = null
		update_icon()
	. = ..()

/obj/structure/bed/medevac_stretcher/update_icon()
	..()
	overlays.Cut()
	if(stretcher_activated)
		overlays += image("beacon_active_[density ? "up":"down"]")

	if(buckled_mob || buckled_bodybag)
		overlays += image("icon_state"="stretcher_box","layer"=LYING_MOB_LAYER + 0.1)


/obj/structure/bed/medevac_stretcher/verb/activate_medevac_beacon()
	set name = "Activate medevac"
	set desc = "Toggle the medevac beacon inside the stretcher."
	set category = "Object"
	set src in oview(1)

	toggle_medevac_beacon(usr)

/obj/structure/bed/medevac_stretcher/proc/toggle_medevac_beacon(mob/user)
	if(!ishuman(user))
		return

	if(user.mind && user.mind.cm_skills && user.mind.cm_skills.medical < SKILL_MEDICAL_MEDIC)
		user << "<span class='warning'>You don't know how to use [src].</span>"
		return

	if(user == buckled_mob)
		user << "<span class='warning'>You can't reach the beacon activation button while buckled to [src].</span>"
		return

	if(stretcher_activated)
		stretcher_activated = FALSE
		activated_medevac_stretchers -= src
		if(linked_medevac)
			linked_medevac.linked_stretcher = null
			linked_medevac = null
		user << "<span class='notice'>You deactivate [src]'s beacon.</span>"
		update_icon()

	else
		if(z != 1)
			user << "<span class='warning'>You can't activate [src]'s beacon here.</span>"
			return

		var/area/AR = get_area(src)
		if(AR.ceiling >= CEILING_METAL)
			user << "<span class='warning'>[src] must be in the open or under a glass roof.</span>"
			return

		if(buckled_mob || buckled_bodybag)
			stretcher_activated = TRUE
			activated_medevac_stretchers += src
			user << "<span class='notice'>You activate [src]'s beacon.</span>"
			update_icon()
		else
			user << "<span class='warning'>You need to attach something to [src] before you can activate its beacon yet.</span>"

/obj/item/roller/medevac
	name = "medevac stretcher"
	desc = "A collapsed medevac stretcher that can be carried around."
	icon_state = "stretcher_folded"
	rollertype = /obj/structure/bed/medevac_stretcher
