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


/obj/item/grab/dropped(mob/user)
	user.stop_pulling()
	. = ..()

/obj/item/grab/Destroy()
	grabbed_thing = null
	if(ismob(loc))
		var/mob/M = loc
		M.stop_pulling()
	return ..()


/obj/item/grab/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(user.pulling == user.buckled)
		return //can't move the thing you're sitting on.
	target = get_turf(target)	//we still try to move the grabbed thing to the turf.
	if(user.Move_Pulled(target))
		user.changeNext_move(CLICK_CD_MELEE)


/obj/item/grab/attack_self(mob/living/user)
	if(!isliving(grabbed_thing) || user.action_busy)
		return

	if(!ishuman(user)) //only humans can reinforce a grab.
		if (isxeno(user))
			var/mob/living/carbon/xenomorph/X = user
			X.pull_power(grabbed_thing)
		return
	var/mob/living/victim = grabbed_thing
	if(victim.mob_size > MOB_SIZE_HUMAN || !(victim.status_flags & CANPUSH))
		return //can't tighten your grip on big mobs and mobs you can't push.
	if(user.grab_state > GRAB_KILL)
		return
	user.changeNext_move(CLICK_CD_GRABBING)
	if(!do_mob(user, victim, 2 SECONDS, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(user, /datum/.proc/Adjacent, victim)) || !user.pulling)
		return
	user.advance_grab_state()
	if(user.grab_state == GRAB_NECK)
		RegisterSignal(victim, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)


/mob/living/proc/advance_grab_state()
	if(!isliving(pulling))
		CRASH("advance_grab_state() called without a living pulling victim")
	var/mob/living/victim = pulling
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)
	setGrabState(grab_state + 1)
	switch(grab_state)
		if(GRAB_AGGRESSIVE)
			log_combat(src, victim, "aggressive grabbed")
			visible_message("<span class='danger'>[src] grabs [victim] aggressively!</span>",
				"<span class='danger'>You grab [victim] aggressively!</span>",
				"<span class='hear'>You hear aggressive shuffling!</span>", ignored_mob = victim)
			to_chat(victim, "<span class='userdanger'>[src] grabs you aggressively!</span>")
			victim.drop_all_held_items()
			if(victim.pulling)
				victim.stop_pulling()
		if(GRAB_NECK)
			icon_state = "disarm/kill"
			log_combat(src, victim, "neck grabbed")
			visible_message("<span class='danger'>[src] grabs [victim] by the neck!</span>",
				"<span class='danger'>You grab [victim] by the neck!</span>",
				"<span class='hear'>You hear aggressive shuffling!</span>", ignored_mob = victim)
			to_chat(victim, "<span class='userdanger'>[src] grabs you by the neck!</span>")
			victim.drop_all_held_items()
			ENABLE_BITFIELD(victim.restrained_flags, RESTRAINED_NECKGRAB)
			if(!victim.buckled && !victim.density)
				victim.Move(loc)
		if(GRAB_KILL)
			icon_state = "disarm/kill1"
			log_combat(src, victim, "strangled")
			visible_message("<span class='danger'>[src] is strangling [victim]!</span>",
				"<span class='danger'>You're strangling [victim]!</span>",
				"<span class='hear'>You hear aggressive shuffling!</span>", ignored_mob = victim)
			to_chat(victim, "<span class='userdanger'>[src] is strangling you!</span>")
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
	if(user.action_busy || !ishuman(user) || attacked != user.pulling)
		return FALSE
	if(!do_mob(user, attacked, 2 SECONDS, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(user, /datum/.proc/Adjacent, attacked)) || !user.pulling)
		return TRUE
	user.advance_grab_state(attacked)
	return TRUE


/mob/living/carbon/xenomorph/proc/devour_grabbed()
	var/mob/living/carbon/prey = pulling
	if(!istype(prey) || isxeno(prey) || issynth(prey))
		to_chat(src, "<span class='warning'>That wouldn't taste very good.</span>")
		return NONE
	if(prey.buckled)
		to_chat(src, "<span class='warning'>[prey] is buckled to something.</span>")
		return NONE
	if(prey.stat == DEAD)
		to_chat(src, "<span class='warning'>Ew, [prey] is already starting to rot.</span>")
		return NONE
	if(LAZYLEN(stomach_contents)) //Only one thing in the stomach at a time, please
		to_chat(src, "<span class='warning'>You already have something in your belly, there's no way that will fit.</span>")
		return NONE
	for(var/obj/effect/forcefield/fog in range(1, src))
		to_chat(src, "<span class='warning'>You are too close to the fog.</span>")
		return NONE

	visible_message("<span class='danger'>[src] starts to devour [prey]!</span>", \
	"<span class='danger'>You start to devour [prey]!</span>", null, 5)

	//extra_checks = CALLBACK(user, /mob/proc/break_do_after_checks, null, null, user.zone_selected)

	if(!do_after(src, 5 SECONDS, FALSE, prey, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_devour_grabbed, prey)))
		to_chat(src, "<span class='warning'>You stop devouring \the [prey]. \He probably tasted gross anyways.</span>")
		return NONE

	visible_message("<span class='warning'>[src] devours [prey]!</span>", \
	"<span class='warning'>You devour [prey]!</span>", null, 5)

	var/DT = prey.client ? 50 SECONDS + rand(0, 20 SECONDS) : 3 MINUTES // 50-70 seconds if there's a client, three minutes otherwise
	devour_timer = world.time + DT

	//IMPORTANT CODER NOTE: Due to us using the old lighting engine, we need to hacky hack hard to get this working properly
	//So we're just going to get the lights out of here by forceMoving them to a far-away place
	//They will be recovered when regurgitating, since this also calls forceMove
	prey.x = 1
	prey.y = 1
	prey.z = 2 //Centcomm
	prey.forceMove(prey.loc)

	//Then, we place the mob where it ought to be

	do_devour(prey)

	return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK


/mob/living/carbon/xenomorph/proc/can_devour_grabbed(mob/living/carbon/prey)
	if(!pulling)
		return FALSE
	if(pulling != prey)
		return FALSE
	if(prey.buckled || prey.stat == DEAD)
		return FALSE
	if(LAZYLEN(stomach_contents))
		return FALSE
	return TRUE


/mob/living/carbon/proc/on_devour_by_xeno()
	RegisterSignal(src, COMSIG_MOVABLE_RELEASED_FROM_STOMACH, .proc/on_release_from_stomach)


/mob/living/carbon/human/on_devour_by_xeno()
	if(istype(wear_ear, /obj/item/radio/headset/mainship/marine))
		var/obj/item/radio/headset/mainship/marine/marine_headset = wear_ear
		if(marine_headset.camera.status)
			marine_headset.camera.status = FALSE //Turn camera off.
			to_chat(src, "<span class='danger'>Your headset camera flickers off as you are devoured; you'll need to reactivate it by rebooting your headset HUD!<span>")
	return ..()


/mob/living/carbon/proc/on_release_from_stomach(mob/living/carbon/prey, mob/living/predator)
	prey.SetParalyzed(20)
	prey.adjust_blindness(-1)
	UnregisterSignal(src, COMSIG_MOVABLE_RELEASED_FROM_STOMACH)
