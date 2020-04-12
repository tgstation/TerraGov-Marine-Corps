/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = TRUE
	layer = TABLE_LAYER
	anchored = TRUE
	resistance_flags = UNACIDABLE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0
	buckle_flags = CAN_BUCKLE
	buckle_lying = 90
	var/obj/item/tank/anesthetic/anes_tank

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/optable/LateInitialize()
	for(dir in list(NORTH, EAST, SOUTH, WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = FALSE
		else
	return

/obj/machinery/optable/attack_paw(mob/living/carbon/monkey/user)
	if (!( locate(/obj/machinery/optable, user.loc) ))
		step(user, get_dir(user, src))
		if (user.loc == src.loc)
			user.layer = TURF_LAYER
			visible_message("The monkey hides under the table!")
	return

/obj/machinery/optable/examine(mob/user)
	..()
	if(get_dist(user, src) > 2 && !isobserver(user))
		return
	if(anes_tank)
		to_chat(user, "<span class='information'>It has an [anes_tank] connected with the gauge showing [round(anes_tank.pressure,0.1)] kPa.</span>")

/obj/machinery/optable/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(anes_tank)
		user.put_in_active_hand(anes_tank)
		to_chat(user, "<span class='notice'>You remove \the [anes_tank] from \the [src].</span>")
		anes_tank = null


/obj/machinery/optable/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	if(!ishuman(buckling_mob))
		return FALSE
	if(buckling_mob == user)
		return FALSE
	if(buckling_mob != victim)
		to_chat(user, "<span class='warning'>Lay the patient on the table first!</span>")
		return FALSE
	if(!anes_tank)
		to_chat(user, "<span class='warning'>There is no anesthetic tank connected to the table, load one first.</span>")
		return FALSE
	buckling_mob.visible_message("<span class='notice'>[user] begins to connect [buckling_mob] to the anesthetic system.</span>")
	if(!do_after(user, 2.5 SECONDS, FALSE, src, BUSY_ICON_GENERIC))
		if(buckling_mob != victim)
			to_chat(user, "<span class='warning'>The patient must remain on the table!</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You stop placing the mask on [buckling_mob]'s face.</span>")
		return FALSE
	if(!anes_tank)
		to_chat(user, "<span class='warning'>There is no anesthetic tank connected to the table, load one first.</span>")
		return FALSE
	var/mob/living/carbon/human/buckling_human = buckling_mob
	if(buckling_human.wear_mask && !buckling_human.dropItemToGround(buckling_human.wear_mask))
		to_chat(user, "<span class='danger'>You can't remove their mask!</span>")
		return FALSE
	var/obj/item/clothing/mask/breath/medical/anesthetic_mask = new()
	if(!buckling_human.equip_if_possible(anesthetic_mask, SLOT_WEAR_MASK))
		to_chat(user, "<span class='danger'>You can't fit the gas mask over their face!</span>")
		qdel(anesthetic_mask)
		return FALSE
	buckling_human.internal = anes_tank
	buckling_human.visible_message("<span class='notice'>[user] fits the mask over [buckling_human]'s face and turns on the anesthetic.</span>'")
	to_chat(buckling_human, "<span class='information'>You begin to feel sleepy.</span>")
	buckling_human.setDir(SOUTH)
	return ..()


/obj/machinery/optable/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	. = ..()
	if(!.)
		return
	if(!silent)
		buckled_mob.visible_message("<span class='notice'>[user] turns off the anesthetic and removes the mask from [buckled_mob].</span>")


/obj/machinery/optable/post_unbuckle_mob(mob/living/buckled_mob)
	if(!ishuman(buckled_mob)) // sanity check
		return
	var/mob/living/carbon/human/buckled_human = buckled_mob
	buckled_human.internal = null
	var/obj/item/anesthetic_mask = buckled_human.wear_mask
	buckled_human.dropItemToGround(anesthetic_mask)
	qdel(anesthetic_mask)
	return ..()


/obj/machinery/optable/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(atom/A, mob/user)

	if(istype(A, /obj/item))
		var/obj/item/I = A
		if (!istype(I) || user.get_active_held_item() != I)
			return
		if(user.drop_held_item())
			if (I.loc != loc)
				step(I, get_dir(I, src))
	else if(ismob(A))
		..(A, user)

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, loc)
		if(M.lying_angle)
			victim = M
			icon_state = M.handle_pulse() ? "table2-active" : "table2-idle"
			return 1
	victim = null
	stop_processing()
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user)
	if (C == user)
		user.visible_message("<span class='notice'>[user] climbs on the operating table.","You climb on the operating table.</span>", null, null, 4)
	else
		visible_message("<span class='notice'>[C] has been laid on the operating table by [user].</span>", null, null, 4)
	C.set_resting(TRUE)
	C.forceMove(loc)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		victim = H
		start_processing()
		icon_state = H.handle_pulse() ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr) || usr.restrained() || !check_table(usr))
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tank/anesthetic))
		if(anes_tank)
			return
		user.transferItemToLoc(I, src)
		anes_tank = I
		to_chat(user, "<span class='notice'>You connect \the [anes_tank] to \the [src].</span>")

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I
	if(victim && victim != G.grabbed_thing)
		to_chat(user, "<span class='warning'>The table is already occupied!</span>")
		return
	var/mob/living/carbon/M
	if(iscarbon(G.grabbed_thing))
		M = G.grabbed_thing
		if(M.buckled)
			to_chat(user, "<span class='warning'>Unbuckle first!</span>")
			return
	else if(istype(G.grabbed_thing, /obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.bodybag_occupant)
			return
		M = C.bodybag_occupant
		C.open()
		user.stop_pulling()
		user.start_pulling(M)

	if(!M)
		return

	take_victim(M, user)

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	if(victim)
		to_chat(usr, "<span class='boldnotice'>The table is already occupied!</span>")
		return 0

	if(patient.buckled)
		to_chat(usr, "<span class='boldnotice'>Unbuckle first!</span>")
		return 0

	return 1
