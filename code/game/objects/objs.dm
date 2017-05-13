/obj
	//Used to store information about the contents of the object.
	var/list/matter

	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/sharp = 0		// whether this object cuts
	var/edge = 0		// whether this object is more likely to dismember
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/damtype = "brute"
	var/force = 0
	var/attack_speed = 7  //+3, Adds up to 10.

	var/mob/living/buckled_mob
	var/buckle_lying = FALSE //Is the mob buckled in a lying position
	var/can_buckle = FALSE

/obj/item/proc/is_used_on(obj/O, mob/user)

/obj/proc/process()
	processing_objects.Remove(src)
	return 0

/obj/assume_air(datum/gas_mixture/giver)
	if(loc)
		return loc.assume_air(giver)
	else
		return null

/obj/remove_air(amount)
	if(loc)
		return loc.remove_air(amount)
	else
		return null

/obj/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/obj/proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
	//Return: (NONSTANDARD)
	//		null if object handles breathing logic for lifeform
	//		datum/air_group to tell lifeform to process using that breath return
	//DEFAULT: Take air from turf to give to have mob process
	if(breath_request>0)
		return remove_air(breath_request)
	else
		return null

/atom/movable/proc/initialize()
	return

/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if (!(usr in nearby))
				if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if (istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.machine==src)
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.machine == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/proc/interact(mob/user)
	return

/obj/proc/update_icon()
	return

/mob/proc/unset_machine()
	src.machine = null

/mob/proc/set_machine(var/obj/O)
	if(src.machine)
		unset_machine()
	src.machine = O
	if(istype(O))
		O.in_use = 1

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.machine == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return


/obj/proc/hear_talk(mob/M as mob, text)
	if(talking_atom)
		talking_atom.catchMessage(text, M)
/*
	var/mob/mo = locate(/mob) in src
	if(mo)
		var/rendered = "<span class='game say'><span class='name'>[M.name]: </span> <span class='message'>[text]</span></span>"
		mo.show_message(rendered, 2)
		*/
	return


/obj/Del()
	if(buckled_mob) unbuckle()
	..()

/obj/Dispose()
	if(buckled_mob) unbuckle()
	. = ..()

/obj/attack_paw(mob/user)
	if(can_buckle) return src.attack_hand(user)
	else . = ..()

/obj/attack_hand(mob/user)
	if(can_buckle) manual_unbuckle(user)
	else . = ..()

/obj/attack_ai(mob/user)
	if(can_buckle) manual_unbuckle(user)
	else . = ..()

/obj/proc/handle_rotation()
	return

/obj/MouseDrop(atom/over_object)
	if(!can_buckle)
		. = ..()

/obj/MouseDrop_T(mob/M, mob/user)
	if(can_buckle)
		if(!istype(M)) return
		buckle_mob(M, user)
	else . = ..()

/obj/proc/afterbuckle(mob/M as mob) // Called after somebody buckled / unbuckled
	handle_rotation()
	return buckled_mob

/obj/proc/unbuckle()
	if(buckled_mob)
		if(buckled_mob.buckled == src)	//this is probably unneccesary, but it doesn't hurt
			buckled_mob.buckled = null
			buckled_mob.anchored = initial(buckled_mob.anchored)
			buckled_mob.update_canmove()

			var/M = buckled_mob
			buckled_mob = null

			afterbuckle(M)


/obj/proc/manual_unbuckle(mob/user as mob)
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			if(buckled_mob != user)
				buckled_mob.visible_message(\
					"<span class='notice'>[buckled_mob.name] was unbuckled by [user.name]!</span>",\
					"<span class='notice'>You were unbuckled from [src] by [user.name].</span>",\
					"<span class='notice'>You hear metal clanking.</span>")
			else
				buckled_mob.visible_message(\
					"<span class='notice'>[buckled_mob.name] unbuckled \himself!</span>",\
					"<span class='notice'>You unbuckle yourself from [src].</span>",\
					"<span class='notice'>You hear metal clanking</span>")
			unbuckle()
			src.add_fingerprint(user)
			return 1

	return 0


//trying to buckle a mob
/obj/proc/buckle_mob(mob/M, mob/user)
	if ( !ismob(M) || (get_dist(src, user) > 1) || user.restrained() || user.lying || user.stat || buckled_mob || M.buckled || istype(user, /mob/living/silicon/pai) )
		return

	if (M.mob_size > MOB_SIZE_HUMAN)
		user << "<span class='warning'>[M] is too big to buckle in.</span>"
		return
	if (istype(user, /mob/living/carbon/Xenomorph))
		user << "<span class='warning'>You don't have the dexterity to do that, try a nest.</span>"
		return

	if(density)
		density = 0
		if(!step(M, get_dir(M, src) && loc != M.loc))
			density = 1
			return
		density = 1
	else
		if(M.loc != src.loc)
			return
	do_buckle(M, user)

//the actual buckling proc
/obj/proc/do_buckle(mob/M, mob/user)
	send_buckling_message(M, user)
	M.buckled = src
	M.loc = src.loc
	M.dir = src.dir
	M.update_canmove()
	src.buckled_mob = M
	src.add_fingerprint(user)
	afterbuckle(M)

/obj/proc/send_buckling_message(mob/M, mob/user)
	if (M == user)
		M.visible_message(\
			"<span class='notice'>[M] buckles in!</span>",\
			"<span class='notice'>You buckle yourself to [src].</span>",\
			"<span class='notice'>You hear metal clanking.</span>")
	else
		M.visible_message(\
			"<span class='notice'>[M] is buckled in to [src] by [user]!</span>",\
			"<span class='notice'>You are buckled in to [src] by [user].</span>",\
			"<span class='notice'>You hear metal clanking</span>")

/obj/Move(NewLoc, direct)
	. = ..()
	handle_rotation()
	if(. && buckled_mob && !handle_buckled_mob_movement(loc,direct)) //movement fails if buckled mob's move fails.
		. = 0

/obj/proc/handle_buckled_mob_movement(NewLoc, direct)
	if(!buckled_mob.Move(NewLoc, direct))
		loc = buckled_mob.loc
		last_move_dir = buckled_mob.last_move_dir
		buckled_mob.inertia_dir = last_move_dir
		return 0
	return 1

/obj/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(mover == buckled_mob)
		return TRUE
	. = ..()