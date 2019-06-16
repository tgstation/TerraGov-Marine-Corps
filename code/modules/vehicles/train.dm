/obj/vehicle/train
	name = "train"
	dir = 4

	move_delay = 5

	max_integrity = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
	buckling_y = 4

	var/active_engines = 0
	var/train_length = 0

	var/obj/vehicle/train/lead
	var/obj/vehicle/train/tow


//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/Initialize()
	. = ..()
	for(var/obj/vehicle/train/T in orange(1, src))
		latch(T,silent=TRUE)

/obj/vehicle/train/Move()
	var/old_loc = get_turf(src)
	if(..())
		if(tow)
			tow.Move(old_loc)
		return TRUE
	else
		if(lead)
			unattach()
		return FALSE

//-------------------------------------------
// Vehicle procs
//-------------------------------------------
/obj/vehicle/train/explode()
	if (tow)
		tow.unattach()
	unattach()
	..()


//-------------------------------------------
// Interaction procs
//-------------------------------------------


/obj/vehicle/train/MouseDrop_T(var/atom/movable/C, mob/user as mob)
	if(user.buckled || user.stat || user.restrained() || !Adjacent(user) || !user.Adjacent(C) || !istype(C) || (user == C && !user.canmove))
		return
	if(istype(C,/obj/vehicle/train))
		latch(C, user)
	else
		..()

/obj/vehicle/train/verb/unlatch_v()
	set name = "Unlatch"
	set desc = "Unhitches this train from the one in front of it."
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr))
		return

	if(!usr.canmove || usr.stat || usr.restrained() || !Adjacent(usr))
		return

	unattach(usr)


//-------------------------------------------
// Latching/unlatching procs
//-------------------------------------------

//Xeno interaction with the Cargo Tug Train
/obj/vehicle/train/attack_alien(mob/living/carbon/xenomorph/M)
	attack_hand(M)

//attempts to attach src as a follower of the train T
/obj/vehicle/train/proc/attach_to(obj/vehicle/train/T, mob/user, var/silent=FALSE)
	if(!istype(user))
		silent = TRUE
	if (get_dist(src, T) > 1)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is too far away from [T] to hitch them together.</span>")
		return

	if (lead)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is already hitched to something.</span>")
		return

	if (T.tow)
		if(!silent)
			to_chat(user, "<span class='warning'>[T] is already towing something.</span>")
		return

	//check for cycles.
	var/obj/vehicle/train/next_car = T
	while (next_car)
		if (next_car == src)
			if(!silent)
				to_chat(user, "<span class='warning'>That seems very silly.</span>")
			return
		next_car = next_car.lead

	//latch with src as the follower
	lead = T
	T.tow = src
	setDir(lead.dir)

	if(user && !silent)
		to_chat(user, "<span class='notice'>You hitch [src] to [T].</span>")

	update_stats()


//detaches the train from whatever is towing it
/obj/vehicle/train/proc/unattach(mob/user, var/silent=FALSE)
	if(!istype(user))
		silent = TRUE
	if (!lead)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is not hitched to anything.</span>")
		return

	lead.tow = null
	lead.update_stats()

	if(!silent)
		to_chat(user, "<span class='notice'>You unhitch [src] from [lead].</span>")
	lead = null

	update_stats()

/obj/vehicle/train/proc/latch(obj/vehicle/train/T, mob/user, var/silent=FALSE)
	if(!istype(T) || !Adjacent(T))
		return FALSE

	var/T_dir = get_dir(src, T)	//figure out where T is wrt src

	if(dir == T_dir) 	//if car is ahead
		src.attach_to(T, user, silent)
	else if(reverse_direction(dir) == T_dir)	//else if car is behind
		T.attach_to(src, user, silent)

//returns true if this is the lead car of the train
/obj/vehicle/train/proc/is_train_head()
	if (lead)
		return FALSE
	return TRUE

//-------------------------------------------------------
// Stat update procs
//
// Used for updating the stats for how long the train is.
// These are useful for calculating speed based on the
// size of the train, to limit super long trains.
//-------------------------------------------------------
/obj/vehicle/train/update_stats()
	//first, seek to the end of the train
	var/obj/vehicle/train/T = src
	while(T.tow)
		//check for cyclic train.
		if (T.tow == src)
			lead.tow = null
			lead.update_stats()

			lead = null
			update_stats()
			return
		T = T.tow

	//now walk back to the front.
	var/active_engines = 0
	var/train_length = 0
	while(T)
		train_length++
		if (powered && on)
			active_engines++
		T.update_car(train_length, active_engines)
		T = T.lead

/obj/vehicle/train/proc/update_car(var/train_length, var/active_engines)
	return
