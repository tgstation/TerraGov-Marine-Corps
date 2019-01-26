/obj
	var/list/list_reagents = null
	//Used to store information about the contents of the object.
	var/list/matter

	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/crit_fail = 0
	var/unacidable = 0 //universal "unacidabliness" var, here so you can use it in any obj.
	animate_movement = 2
	var/throwforce = 1
	var/in_use = 0 // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!

	var/mob/living/buckled_mob
	var/buckle_lying = FALSE //Is the mob buckled in a lying position
	var/can_buckle = FALSE

	var/explosion_resistance = 0
	var/can_supply_drop = FALSE

/obj/New()
	..()
	GLOB.object_list += src

/obj/Destroy()
	. = ..()
	GLOB.object_list -= src

/obj/proc/add_initial_reagents()
	if(reagents && list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/proc/is_used_on(obj/O, mob/user)
	return

/obj/process()
	STOP_PROCESSING(SSobj, src)
	return 0


/obj/proc/updateUsrDialog()
	if(in_use)
		var/is_in_use = 0
		var/list/nearby = viewers(1, src)
		for(var/mob/M in nearby)
			if ((M.client && M.interactee == src))
				is_in_use = 1
				src.attack_hand(M)
		if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
			if (!(usr in nearby))
				if (usr.client && usr.interactee==src) // && M.interactee == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
					is_in_use = 1
					src.attack_ai(usr)

		// check for TK users

		if (istype(usr, /mob/living/carbon/human))
			if(istype(usr.l_hand, /obj/item/tk_grab) || istype(usr.r_hand, /obj/item/tk_grab/))
				if(!(usr in nearby))
					if(usr.client && usr.interactee==src)
						is_in_use = 1
						src.attack_hand(usr)
		in_use = is_in_use

/obj/proc/updateDialog()
	// Check that people are actually using the machine. If not, don't update anymore.
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in nearby)
			if ((M.client && M.interactee == src))
				is_in_use = 1
				src.interact(M)
		var/ai_in_use = AutoUpdateAI(src)

		if(!ai_in_use && !is_in_use)
			in_use = 0

/obj/proc/interact(mob/user)
	return

/obj/proc/update_icon()
	return



/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M) && M.client && M.interactee == src)
		src.attack_self(M)


/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return


/obj/proc/hear_talk(mob/M, text)
	return

/obj/Destroy()
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
					"<span class='notice'>[buckled_mob.name] unbuckled [p_them()]self!</span>",\
					"<span class='notice'>You unbuckle yourself from [src].</span>",\
					"<span class='notice'>You hear metal clanking</span>")
			unbuckle()
			src.add_fingerprint(user)
			return 1

	return 0


//trying to buckle a mob
/obj/proc/buckle_mob(mob/M, mob/user)
	if ( !ismob(M) || (get_dist(src, user) > 1) || user.is_mob_restrained() || user.lying || user.stat || buckled_mob || M.buckled )
		return

	if (M.mob_size > MOB_SIZE_HUMAN)
		to_chat(user, "<span class='warning'>[M] is too big to buckle in.</span>")
		return
	if (istype(user, /mob/living/carbon/Xenomorph))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do that, try a nest.</span>")
		return

	if(density)
		density = 0
		if(!step(M, get_dir(M, src)) && loc != M.loc)
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
	if(!(direct & (direct - 1))) //not diagonal move. the obj's diagonal move is split into two cardinal moves and those moves will handle the buckled mob's movement.
		if(!buckled_mob.Move(NewLoc, direct))
			loc = buckled_mob.loc
			last_move_dir = buckled_mob.last_move_dir
			buckled_mob.inertia_dir = last_move_dir
			return 0
	return 1

/obj/CanPass(atom/movable/mover, turf/target)
	if(mover == buckled_mob) //can't collide with the thing you're buckled to
		return TRUE
	. = ..()

/obj/proc/check_skill_level(skill_threshold = 1, skill_type, mob/living/M) //used to calculate do-after delays
	if(!skill_threshold) //autopass
		return TRUE

	if(!skill_type) //No skills to check?
		return TRUE

	var/skill = get_skill(skill_type, M)
	if(skill < skill_threshold) //If we're less than the threshold return the maximum delay.
		return FALSE

	return TRUE

/obj/proc/skill_delay(difficulty = SKILL_TASK_AVERAGE, skill_threshold = 1, skill_type, mob/living/M) //used to calculate do-after delays
	if(!difficulty) //autopass, no delay
		return 0

	if(!M.mind?.cm_skills) //No skills to thrill?
		return difficulty

	var/skill = get_skill(skill_type, M)
	if(skill < skill_threshold) //If we're less than the threshold return the maximum delay.
		return difficulty

	difficulty = max(difficulty - (skill * 10), 0)
	return difficulty

/obj/proc/get_skill(skill_type = null, mob/living/M)
	switch(skill_type)
		if(OBJ_SKILL_CQC)
			return M.mind.cm_skills.cqc
		if(OBJ_SKILL_MELEE_WEAPONS)
			return M.mind.cm_skills.melee_weapons
		if(OBJ_SKILL_FIREARMS)
			return M.mind.cm_skills.firearms
		if(OBJ_SKILL_PISTOLS)
			return M.mind.cm_skills.pistols
		if(OBJ_SKILL_RIFLES)
			return M.mind.cm_skills.rifles
		if(OBJ_SKILL_SMG)
			return M.mind.cm_skills.smgs
		if(OBJ_SKILL_SHOTGUNS)
			return M.mind.cm_skills.shotguns
		if(OBJ_SKILL_HEAVYWEAPONS)
			return M.mind.cm_skills.heavy_weapons
		if(OBJ_SKILL_SMARTGUN)
			return M.mind.cm_skills.smartgun
		if(OBJ_SKILL_SPEC_WEAPONS)
			return M.mind.cm_skills.spec_weapons
		if(OBJ_SKILL_LEADERSHIP)
			return M.mind.cm_skills.leadership
		if(OBJ_SKILL_MEDICAL)
			return M.mind.cm_skills.medical
		if(OBJ_SKILL_SURGERY)
			return M.mind.cm_skills.surgery
		if(OBJ_SKILL_PILOT)
			return M.mind.cm_skills.pilot
		if(OBJ_SKILL_ENDURANCE)
			return M.mind.cm_skills.endurance
		if(OBJ_SKILL_ENGINEER)
			return M.mind.cm_skills.engineer
		if(OBJ_SKILL_CONSTRUCTION)
			return M.mind.cm_skills.construction
		if(OBJ_SKILL_POLICE)
			return M.mind.cm_skills.police
		if(OBJ_SKILL_POWERLOADER)
			return M.mind.cm_skills.powerloader
