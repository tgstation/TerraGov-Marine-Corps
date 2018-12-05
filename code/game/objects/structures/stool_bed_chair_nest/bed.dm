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
			density = TRUE
	else
		M.pixel_y = initial(buckled_mob.pixel_y)
		M.old_y = initial(buckled_mob.pixel_y)
		if(base_bed_icon)
			density = FALSE

	update_icon()

//Unsafe proc
/obj/structure/bed/proc/do_buckle_bodybag(obj/structure/closet/bodybag/B, mob/user)
	B.visible_message("<span class='notice'>[user] buckles [B] to [src]!</span>")
	B.roller_buckled = src
	B.loc = loc
	B.dir = dir
	buckled_bodybag = B
	density = TRUE
	update_icon()
	if(buckling_y)
		buckled_bodybag.pixel_y = buckling_y
	add_fingerprint(user)

/obj/structure/bed/unbuckle()
	if(buckled_bodybag)
		buckled_bodybag.pixel_y = initial(buckled_bodybag.pixel_y)
		buckled_bodybag.roller_buckled = null
		buckled_bodybag = null
		density = FALSE
		update_icon()
	else
		..()

/obj/structure/bed/manual_unbuckle(mob/user)
	if(buckled_bodybag)
		unbuckle()
		add_fingerprint(user)
		return TRUE
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
		return FALSE

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
		if(istype(over_object, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = over_object
			if(H == usr && !H.is_mob_incapacitated() && Adjacent(H) && in_range(src, over_object))
				var/obj/item/I = new foldabletype(get_turf(src))
				H.put_in_hands(I)
				if(istype(I,/obj/item/roller/medevac)) //We need to preserve key variables like linked beacons and cooldowns.
					var/obj/item/roller/medevac/M = I
					var/obj/structure/bed/medevac_stretcher/B = src
					if(B.last_teleport)
						M.last_teleport = B.last_teleport
					if(B.linked_beacon)
						M.linked_beacon = B.linked_beacon
					if(B.linked_beacon?.linked_bed_deployed == src)
						M.linked_beacon.linked_bed = M
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

/obj/structure/bed/attack_alien(mob/living/carbon/Xenomorph/M)
	if(M.a_intent == "hurt")
		M.animation_attack_on(src)
		playsound(src, hit_bed_sound, 25, 1)
		M.visible_message("<span class='danger'>[M] slices [src] apart!</span>",
		"<span class='danger'>You slice [src] apart!</span>", null, 5)
		unbuckle()
		destroy()
	else attack_hand(M)

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
			to_chat(user, "<span class='notice'>You place [M] on [src].</span>")
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
	if(!proximity)
		return
	if(isturf(target))
		var/turf/T = target
		if(!T.density)
			deploy_roller(user, target)

/obj/item/roller/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/roller_holder) && rollertype == /obj/structure/bed/roller)
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			to_chat(user, "<span class='notice'>You pick up [src].</span>")
			loc = RH
			RH.held = src
			return
	. = ..()

/obj/item/roller/proc/deploy_roller(mob/user, atom/location, last_teleport = null, linked_beacon = null)
	var/obj/structure/bed/roller/R = new rollertype(location)
	R.add_fingerprint(user)
	user.temp_drop_inv_item(src)
	if(istype(R,/obj/structure/bed/medevac_stretcher)) //We need to preserve key variables like linked beacons and cooldowns.
		var/obj/item/roller/medevac/I = src
		var/obj/structure/bed/medevac_stretcher/B = R
		B.last_teleport = I.last_teleport
		B.linked_beacon = I.linked_beacon
		if(B.linked_beacon.linked_bed == src)
			B.linked_beacon.linked_bed_deployed = B
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
		to_chat(user, "<span class='warning'>The rack is empty.</span>")
		return

	var/obj/structure/bed/roller/R = new(user.loc)
	to_chat(user, "<span class='notice'>You deploy [R].</span>")
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
	desc = "A medevac stretcher with integrated beacon for rapid evacuation of an injured patient via dropship lift and an emergency bluespace teleporter for tele-evacuation to a linked beacon. Accepts patients and body bags."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "stretcher_down"
	buckling_y = 6
	foldabletype = /obj/item/roller/medevac
	base_bed_icon = "stretcher"
	accepts_bodybag = TRUE
	var/last_teleport = null
	var/obj/item/device/medevac_beacon/linked_beacon = null
	var/stretcher_activated
	var/obj/structure/dropship_equipment/medevac_system/linked_medevac

/obj/structure/bed/medevac_stretcher/attack_alien(mob/living/carbon/Xenomorph/M)
	unbuckle()

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

	if(user == buckled_mob)
		to_chat(user, "<span class='warning'>You can't reach the beacon activation button while buckled to [src].</span>")
		return

	if(stretcher_activated)
		stretcher_activated = FALSE
		activated_medevac_stretchers -= src
		if(linked_medevac)
			linked_medevac.linked_stretcher = null
			linked_medevac = null
		to_chat(user, "<span class='notice'>You deactivate [src]'s beacon.</span>")
		update_icon()

	else
		if(z != 1)
			to_chat(user, "<span class='warning'>You can't activate [src]'s beacon here.</span>")
			return

		var/area/AR = get_area(src)
		if(AR.ceiling >= CEILING_METAL)
			to_chat(user, "<span class='warning'>[src] must be in the open or under a glass roof.</span>")
			return

		if(buckled_mob || buckled_bodybag)
			stretcher_activated = TRUE
			activated_medevac_stretchers += src
			to_chat(user, "<span class='notice'>You activate [src]'s beacon.</span>")
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need to attach something to [src] before you can activate its beacon yet.</span>")


/obj/structure/bed/medevac_stretcher/verb/activate_medevac_displacer()
	set name = "Activate Medevac Displacement Field"
	set desc = "Teleport the occupant of the stretcher to a linked beacon."
	set category = "Object"
	set src in oview(1)

	activate_medevac_teleport(usr)


/obj/structure/bed/medevac_stretcher/proc/activate_medevac_teleport(mob/user)
	if(!ishuman(user))
		return

	if(world.time < last_teleport )
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, "<span class='warning'>[src]'s bluespace engine is still recharging; it will be ready in [round(last_teleport - world.time) * 0.1] seconds.</span>")
		return

	if(!buckled_mob && !buckled_bodybag)
		to_chat(user, "<span class='warning'>You need to attach something to [src] before you can activate the bluespace engine.</span>")

	if(user == buckled_mob)
		to_chat(user, "<span class='warning'>You can't reach the teleportation activation button while buckled to [src].</span>")
		return

	if(!linked_beacon)
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, "<span class='warning'>[src]'s bluespace engine isn't linked to any medvac beacon.</span>")
		return

	if(!linked_beacon.planted)
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, "<span class='warning'>[src]'s bluespace engine linked medvac beacon isn't planted and active!</span>")
		return

	if(!linked_beacon.check_power())
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		to_chat(user, "<span class='warning'>[src]'s bluespace engine linked medvac beacon is unpowered.</span>")
		return

	user.visible_message("<span class='warning'>[user] activates [src]'s bluespace engine, causing it to rev to life.</span>",
	"<span class='warning'>You activate [src]'s bluespace engine, causing it to rev to life.</span>")
	playsound(loc,'sound/mecha/powerup.ogg', 25, FALSE)
	spawn(MEDEVAC_TELE_DELAY) //Activate after 5 second delay.
		if(!linked_beacon || !linked_beacon.check_power() || !linked_beacon.planted) //Beacon has to be planted in a powered area.
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			visible_message("<span class='warning'>[src]'s safties kick in before displacement as it fails to detect a powered, linked and planted medvac beacon.</span>")
			return
		var/mob/living/M
		if(!buckled_mob && !buckled_bodybag)
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			visible_message("<span class='warning'>[src]'s bluespace engine aborts displacement, being unable to detect an appropriate evacuee.</span>")
			return
		else if(buckled_mob)
			M = buckled_mob
			buckled_mob.loc = get_turf(linked_beacon)
		else if(buckled_bodybag)
			M = locate(/mob/living) in buckled_bodybag.contents
		if(!M) //We need a mob to teleport or no deal
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			visible_message("<span class='warning'>[src]'s bluespace engine aborts displacement, being unable to detect an appropriate evacuee.</span>")
			return

		visible_message("<span class='notice'><b>[M] vanishes in a flash of sparks as [src]'s bluespace engine generates its displacement field.</b></span>")
		if(buckled_bodybag)
			buckled_bodybag.loc = get_turf(linked_beacon)
		else if(buckled_mob)
			buckled_mob.loc = get_turf(linked_beacon)

		unbuckle()


		//Pretty SFX
		var/datum/effect_system/spark_spread/spark_system
		spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)
		playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
		var/datum/effect_system/spark_spread/spark_system2
		spark_system2 = new /datum/effect_system/spark_spread()
		spark_system2.set_up(5, 0, linked_beacon)
		spark_system2.attach(linked_beacon)
		spark_system2.start(linked_beacon)
		playsound(linked_beacon.loc,'sound/effects/phasein.ogg', 50, FALSE)

		linked_beacon.medvac_alert(M) //We warn med channel about the mob, not what was teleported.
		last_teleport = world.time + MEDEVAC_COOLDOWN

/obj/structure/bed/medevac_stretcher/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/device/medevac_beacon))
		var/obj/item/device/medevac_beacon/B = W
		linked_beacon = B
		B.linked_bed = src
		to_chat(user, "<span class='notice'><b>You link the medvac beacon to the medvac stretcher.</b></span>")
		playsound(loc,'sound/machines/ping.ogg', 25, FALSE)
		return
	else if(istype(W, /obj/item/device/healthanalyzer)) //Allows us to use the analyzer on the occupant without taking him out.
		var/mob/living/occupant
		if(buckled_mob)
			occupant = buckled_mob
		else if(buckled_bodybag)
			occupant = locate(/mob/living) in buckled_bodybag.contents
		var/obj/item/device/healthanalyzer/J = W
		J.attack(occupant, user)
		return
	return ..()

/obj/structure/bed/medevac_stretcher/proc/medvac_alert(mob/M)
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	var/mob/living/silicon/ai/AI = new/mob/living/silicon/ai(src, null, null, 1)
	AI.SetName("Medevac Notification System")
	AI.aiRadio.talk_into(AI,"Patient [M] has been tele-vaced to medvac beacon at: [get_area(linked_beacon)]. Coordinates: (X: [linked_beacon.x], Y: [linked_beacon.y])","MedSci","announces")
	cdel(AI)

/obj/structure/bed/medevac_stretcher/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(linked_beacon)
		details +=("It's linked to a beacon located at: [get_area(linked_beacon)]. Coordinates: (X: [linked_beacon.x], Y: [linked_beacon.y]).</br>")

	if(world.time < last_teleport)
		details +=("Its bluespace engine is currently recharging. <b>The interface displays: [round(last_teleport - world.time) * 0.1] seconds until it has recharged.</b></br>")

	if(buckled_mob)
		details +=("It contains [buckled_mob].</br>")
	else if(buckled_bodybag)
		var/mob/living/M = locate(/mob/living) in buckled_bodybag.contents
		details +=("It contains [M].</br>")

	to_chat(user, "<span class='notice'>[details.Join(" ")]</span>")


/obj/item/roller/medevac
	name = "medevac stretcher"
	desc = "A collapsed medevac stretcher that can be carried around."
	icon_state = "stretcher_folded"
	var/last_teleport = null
	var/obj/item/device/medevac_beacon/linked_beacon = null
	rollertype = /obj/structure/bed/medevac_stretcher

/obj/item/roller/medevac/attack_self(mob/user)
	deploy_roller(user, user.loc, last_teleport, linked_beacon)


/obj/item/roller/medevac/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(linked_beacon)
		details +=("It's linked to a beacon located at: [get_area(linked_beacon)]. Coordinates: (X: [linked_beacon.x], Y: [linked_beacon.y]).</br>")

	if(world.time < last_teleport)
		details +=("<span class='warning'>It's bluespace engine is currently recharging. The interface estimates: [round(last_teleport - world.time) * 0.1] seconds until it has recharged.</span></br>")

	to_chat(user, "<span class='notice'>[details.Join(" ")]</span>")


/obj/item/roller/medevac/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/device/medevac_beacon))
		var/obj/item/device/medevac_beacon/B = W
		linked_beacon = B
		B.linked_bed = src
		to_chat(user, "<span class='notice'><b>You link the medvac beacon to the medvac stretcher.</b></span>")
		playsound(loc,'sound/machines/ping.ogg', 25, FALSE)
		return
	return ..()

/obj/item/device/medevac_beacon
	name = "medevac beacon"
	desc = "A specialized teleportation beacon that links with a medvac stretcher; provides the target destination for the stretcher's displacement field. WARNING: Must be in a powered area to function."
	icon = 'icons/obj/items/devices.dmi'
	icon_state = "med_beacon0"
	var/planted = FALSE
	var/locked = FALSE
	var/obj/item/roller/medevac/linked_bed = null
	var/obj/structure/bed/medevac_stretcher/linked_bed_deployed = null
	req_one_access = list(ACCESS_MARINE_MEDPREP, ACCESS_MARINE_LEADER)


/obj/item/device/medevac_beacon/examine(mob/user)
	. = ..()
	var/list/details = list()
	if(!check_power())
		details +=("<b>It's currently unpowered.</b></br>")
	else
		details +=("<b>It's currently powered.</b></br>")
	if(linked_bed_deployed)
		details +=("It's linked to a medvac bed located at: [get_area(linked_bed_deployed)]. Coordinates: (X: [linked_bed_deployed.x], Y: [linked_bed_deployed.y]).</br>")
		var/teleport_time = linked_bed_deployed.last_teleport
		if(world.time < teleport_time)
			details +=("The linked bed's bluespace engine is currently recharging. <b>The interface displays: [round(teleport_time - world.time) * 0.1] seconds until it has recharged.</b></br>")
	else if(linked_bed)
		details +=("It's linked to a medvac bed located at: [get_area(linked_bed)]. Coordinates: (X: [linked_bed.x], Y: [linked_bed.y]).</br>")
		var/teleport_time = linked_bed.last_teleport
		if(world.time < teleport_time)
			details +=("The linked bed's bluespace engine is currently recharging. <b>The interface displays: [round(teleport_time - world.time) * 0.1] seconds until it has recharged.</b></br>")
	else
		details +=("It's not currently linked to a medvac bed.</br>")

	to_chat(user, "<span class='notice'>[details.Join(" ")]</span>")

/obj/item/device/medevac_beacon/proc/medvac_alert(mob/M)
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	var/mob/living/silicon/ai/AI = new/mob/living/silicon/ai(src, null, null, 1)
	AI.SetName("Medevac Notification System")
	AI.aiRadio.talk_into(AI,"Patient [M] has been tele-vaced to medvac beacon at: [get_area(src)]. Coordinates: (X: [src.x], Y: [src.y])","MedSci","announces")
	cdel(AI)

/obj/item/device/medevac_beacon/attack_self(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>[src]'s interface is locked! Only a Squad Leader or Medic can unlock it now.</span>")
		return
	user.drop_held_item()
	anchored = TRUE
	planted = TRUE
	to_chat(user, "<span class='warning'>You plant and activate [src].</span>")
	icon_state = "med_beacon1"
	playsound(loc,'sound/machines/ping.ogg', 25, FALSE)

/obj/item/device/medevac_beacon/attack_hand(mob/user)
	if(locked)
		to_chat(user, "<span class='warning'>[src]'s interface is locked! Only a Squad Leader or Medic can unlock it now.</span>")
		return
	if(planted)
		anchored = FALSE
		planted = FALSE
		to_chat(user, "<span class='warning'>You retrieve and deactivate [src].</span>")
		icon_state = "med_beacon0"
		playsound(loc,'sound/machines/click.ogg', 25, FALSE)
	return ..()

/obj/item/device/medevac_beacon/attackby(var/obj/item/O as obj, mob/user as mob) //Medics can lock their beacons.
	if(!ishuman(user))
		return ..()

	if(isnull(O))
	 return

	if(istype(O, /obj/item/card/id))
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			return
		locked = !locked
		user.visible_message("<span class='notice'>[user] [locked ? "locks" : "unlocks"] [src]'s interface.</span>",
		"<span class='notice'>You [locked ? "lock" : "unlock"] [src]'s interface.</span>")
	else if(istype(O,/obj/item/roller/medevac))
		if(locked && !allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
			return
		var/obj/item/roller/medevac/R = O
		linked_bed = R
		R.linked_beacon = src
		to_chat(user, "<span class='notice'><b>You link the medvac beacon to the medvac stretcher.</b></span>")
		playsound(loc,'sound/machines/ping.ogg', 25, FALSE)
		return
	return ..()


/obj/item/device/medevac_beacon/proc/check_power()
	var/area/A = loc?.loc
	if(!A || !isarea(A) || !A.master)
		return FALSE
	return(A.master.powered(1))

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
