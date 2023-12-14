#define UPGRADE_COOLDOWN 4 SECONDS

/obj/item/grab
	name = "grab"
	icon_state = "reinforce"
	icon = 'icons/mob/screen/generic.dmi'
	flags_atom = NONE
	flags_item = NOBLUDGEON|DELONDROP|ITEM_ABSTRACT
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	item_state = "nothing"
	w_class = WEIGHT_CLASS_HUGE
	attack_speed = CLICK_CD_GRABBING
	resistance_flags = RESIST_ALL
	var/atom/movable/grabbed_thing

/obj/item/grab/Destroy()
	grabbed_thing = null
	if(ismob(loc))
		var/mob/M = loc
		M.stop_pulling()
	return ..()

/obj/item/grab/dropped(mob/user)
	user.stop_pulling()
	return ..()


/obj/item/grab/on_thrown(mob/living/carbon/user, atom/target)
	if(!ismob(grabbed_thing))
		return
	if(user.grab_state < GRAB_NECK)
		to_chat(user, span_warning("You need a better grip!"))
		return
	var/mob/living/M = grabbed_thing
	var/turf/start_T = get_turf(user) //Get the start and target tile for the descriptors
	var/turf/end_T = get_turf(target)
	if(start_T && end_T)
		var/start_T_descriptor = "tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]"
		var/end_T_descriptor = "tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]"
		log_combat(user, M, "thrown", addition="from [start_T_descriptor] with the target [end_T_descriptor]")
	return M

/obj/item/grab/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	if(user.pulling == user.buckled)
		return //can't move the thing you're sitting on.
	target = get_turf(target)	//we still try to move the grabbed thing to the turf.
	if(user.Move_Pulled(target))
		user.changeNext_move(CLICK_CD_MELEE)


/obj/item/grab/attack_self(mob/living/user)
	if(!isliving(grabbed_thing) || user.do_actions)
		return

	if(!ishuman(user)) //only humans can reinforce a grab.
		return
	var/mob/living/victim = grabbed_thing
	if(victim.mob_size > MOB_SIZE_HUMAN || !(victim.status_flags & CANPUSH))
		return //can't tighten your grip on big mobs and mobs you can't push.
	if(user.grab_state > GRAB_KILL)
		return
	user.changeNext_move(CLICK_CD_GRABBING)
	if(!do_after(user, 2 SECONDS, NONE, victim, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(user, TYPE_PROC_REF(/datum, Adjacent), victim)) || !user.pulling)
		return
	user.advance_grab_state()
	if(user.grab_state == GRAB_NECK)
		RegisterSignal(victim, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against))


/mob/living/proc/advance_grab_state()
	if(!isliving(pulling))
		CRASH("advance_grab_state() called without a living pulling victim")
	var/mob/living/victim = pulling
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)
	setGrabState(grab_state + 1)
	switch(grab_state)
		if(GRAB_AGGRESSIVE)
			log_combat(src, victim, "aggressive grabbed")
			visible_message(span_danger("[src] grabs [victim] aggressively!"),
				span_danger("You grab [victim] aggressively!"),
				span_hear("You hear aggressive shuffling!"), ignored_mob = victim)
			to_chat(victim, span_userdanger("[src] grabs you aggressively!"))
			victim.drop_all_held_items()
			if(victim.pulling)
				victim.stop_pulling()
		if(GRAB_NECK)
			icon_state = "disarm/kill"
			log_combat(src, victim, "neck grabbed")
			visible_message(span_danger("[src] grabs [victim] by the neck!"),
				span_danger("You grab [victim] by the neck!"),
				span_hear("You hear aggressive shuffling!"), ignored_mob = victim)
			to_chat(victim, span_userdanger("[src] grabs you by the neck!"))
			victim.drop_all_held_items()
			ENABLE_BITFIELD(victim.restrained_flags, RESTRAINED_NECKGRAB)
			if(!victim.buckled && !victim.density)
				victim.Move(loc)
		if(GRAB_KILL)
			icon_state = "disarm/kill1"
			log_combat(src, victim, "strangled")
			visible_message(span_danger("[src] is strangling [victim]!"),
				span_danger("You're strangling [victim]!"),
				span_hear("You hear aggressive shuffling!"), ignored_mob = victim)
			to_chat(victim, span_userdanger("[src] is strangling you!"))
			victim.drop_all_held_items()
			ENABLE_BITFIELD(victim.restrained_flags, RESTRAINED_NECKGRAB)
			if(!victim.buckled && !victim.density)
				victim.Move(loc)
	set_pull_offsets(victim)


/obj/item/grab/resisted_against(datum/source)
	var/mob/living/victim = source
	victim.do_resist_grab()


/obj/item/grab/attack(mob/living/attacked, mob/living/user, def_zone)
	if(attacked == user && CHECK_BITFIELD(SEND_SIGNAL(user, COMSIG_GRAB_SELF_ATTACK), COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK))
		return TRUE
	if(user.grab_state > GRAB_KILL)
		return FALSE
	if(user.do_actions || !ishuman(user) || attacked != user.pulling)
		return FALSE
	if(!do_after(user, 2 SECONDS, NONE, attacked, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(user, TYPE_PROC_REF(/datum, Adjacent), attacked)) || !user.pulling)
		return TRUE
	user.advance_grab_state(attacked)
	return TRUE
