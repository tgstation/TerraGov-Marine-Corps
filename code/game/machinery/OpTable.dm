/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	layer = TABLE_LAYER
	anchored = 1
	unacidable = 1
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0
	can_buckle = TRUE
	buckle_lying = TRUE
	var/obj/item/tank/anesthetic/anes_tank

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if (computer)
			computer.table = src
			break
//	spawn(100) //Wont the MC just call this process() before and at the 10 second mark anyway?
//		process()

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			cdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				cdel(src)
				return
		if(3.0)
			if (prob(25))
				src.density = 0
		else
	return

/obj/machinery/optable/attack_paw(mob/user as mob)
	if ((HULK in usr.mutations))
		usr << text("\blue You destroy the operating table.")
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		cdel(src)
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
		user << "<span class='information'>It has an [anes_tank] connected with the gauge showing [round(anes_tank.pressure,0.1)] kPa.</span>"

/obj/machinery/optable/attack_hand(mob/living/user)
	if (HULK in usr.mutations)
		usr << text("\blue You destroy the table.")
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		cdel(src)
		return
	if(buckled_mob)
		unbuckle(user)
		return
	if(anes_tank)
		user.put_in_active_hand(anes_tank)
		user << "<span class='notice'>You remove \the [anes_tank] from \the [src].</span>"
		anes_tank = null


/obj/machinery/optable/buckle_mob(mob/living/carbon/human/H, mob/living/user)
	if(!istype(H)) return
	if(H == user) return
	if(H != victim)
		user << "<span class='warning'>Lay the patient on the table first!</span>"
		return
	if(!anes_tank)
		user << "<span class='warning'>There is no anesthetic tank connected to the table, load one first.</span>"
		return
	H.visible_message("<span class='notice'>[user] begins to connect [H] to the anesthetic system.</span>")
	if(!do_after(user, 25, FALSE, 5, BUSY_ICON_FRIENDLY))
		if(H != victim)
			user << "<span class='warning'>The patient must remain on the table!</span>"
			return
		user << "<span class='notice'>You stop placing the mask on [H]'s face.</span>"
		return
	if(!anes_tank)
		user << "<span class='warning'>There is no anesthetic tank connected to the table, load one first.</span>"
		return
	if(H.wear_mask && !H.drop_inv_item_on_ground(H.wear_mask))
		user << "<span class='danger'>You can't remove their mask!</span>"
		return
	var/obj/item/clothing/mask/breath/medical/B = new()
	if(!H.equip_if_possible(B, WEAR_FACE))
		user << "<span class='danger'>You can't fit the gas mask over their face!</span>"
		cdel(B)
		return
	H.internal = anes_tank
	H.visible_message("<span class='notice'>[user] fits the mask over [H]'s face and turns on the anesthetic.</span>'")
	H << "<span class='information'>You begin to feel sleepy.</span>"
	H.dir = SOUTH
	..()

/obj/machinery/optable/unbuckle(mob/living/user)
	if(!buckled_mob)
		return
	if(ishuman(buckled_mob)) // sanity check
		var/mob/living/carbon/human/H = buckled_mob
		H.internal = null
		var/obj/item/M = H.wear_mask
		H.drop_inv_item_on_ground(M)
		cdel(M)
		H.visible_message("<span class='notice'>[user] turns off the anesthetic and removes the mask from [H].</span>")
		..()



/obj/machinery/optable/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(atom/A, mob/user)

	if(istype(A, /obj/item))
		var/obj/item/I = A
		if (!istype(I) || user.get_active_hand() != I)
			return
		if(user.drop_held_item())
			if (I.loc != loc)
				step(I, get_dir(I, src))
	else if(ismob(A))
		..(A, user)

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, loc)
		if(M.lying)
			victim = M
			icon_state = M.pulse ? "table2-active" : "table2-idle"
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
		visible_message("<span class='notice'>[C] has been laid on the operating table by [user].</span>", null, 4)
	C.resting = 1
	C.forceMove(loc)

	add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		victim = H
		start_processing()
		icon_state = H.pulse ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr) || usr.is_mob_restrained() || !check_table(usr))
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/tank/anesthetic))
		if(!anes_tank)
			user.drop_inv_item_to_loc(W, src)
			anes_tank = W
			user << "<span class='notice'>You connect \the [anes_tank] to \the [src].</span>"
			return
	if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(victim && victim != G.grabbed_thing)
			user << "<span class='warning'>The table is already occupied!</span>"
			return
		var/mob/living/carbon/M
		if(iscarbon(G.grabbed_thing))
			M = G.grabbed_thing
			if(M.buckled)
				user << "<span class='warning'>Unbuckle first!</span>"
				return
		else if(istype(G.grabbed_thing,/obj/structure/closet/bodybag/cryobag))
			var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
			if(!C.stasis_mob)
				return
			M = C.stasis_mob
			C.open()
			user.stop_pulling()
			user.start_pulling(M)
		else
			return

		take_victim(M,user)

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	if(victim)
		usr << "\blue <B>The table is already occupied!</B>"
		return 0

	if(patient.buckled)
		usr << "\blue <B>Unbuckle first!</B>"
		return 0

	return 1
