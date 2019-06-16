#define UPGRADE_COOLDOWN	40

/obj/item/grab
	name = "grab"
	icon_state = "reinforce"
	icon = 'icons/mob/screen/generic.dmi'
	flags_atom = NONE
	flags_item = NOBLUDGEON|DELONDROP|ITEM_ABSTRACT
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE
	item_state = "nothing"
	w_class = 5
	var/atom/movable/grabbed_thing
	var/last_upgrade = 0 //used for cooldown between grab upgrades.


/obj/item/grab/New()
	..()
	last_upgrade = world.time

/obj/item/grab/dropped(mob/user)
	user.stop_pulling()
	. = ..()

/obj/item/grab/Destroy()
	grabbed_thing = null
	if(ismob(loc))
		var/mob/M = loc
		M.grab_level = 0
		M.stop_pulling()
	. = ..()


/obj/item/grab/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(user))
		return
	if(user.pulling == user.buckled)
		return //can't move the thing you're sitting on.
	if(istype(target, /obj/effect))//if you click a blood splatter with a grab instead of the turf,
		target = get_turf(target)	//we still try to move the grabbed thing to the turf.
	if(!isturf(target) || istype(target, /turf/open/floor/almayer/empty))
		return
	var/turf/T = target
	if(T.density || !T.Adjacent(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	step(user.pulling, get_dir(user.pulling.loc, T))


/obj/item/grab/attack_self(mob/user)
	if(!ismob(grabbed_thing) || world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return

	if(!ishuman(user)) //only humans can reinforce a grab.
		if (isxeno(user))
			var/mob/living/carbon/xenomorph/X = user
			X.pull_power(grabbed_thing)
		return
	var/mob/victim = grabbed_thing
	if(victim.mob_size > MOB_SIZE_HUMAN || !(victim.status_flags & CANPUSH))
		return //can't tighten your grip on big mobs and mobs you can't push.
	last_upgrade = world.time
	if(user.grab_level <= GRAB_KILL)
		user.grab_level++
		playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
		switch(user.grab_level)
			if(GRAB_KILL)
				icon_state = "disarm/kill1"
				user.visible_message("<span class='danger'>[user] has tightened [user.p_their()] grip on [victim]'s neck!</span>", null, null, 5)
				log_combat(user, victim, "strangled", addition="(kill intent)")
				msg_admin_attack("[key_name(user)] strangled (kill intent) [key_name(victim)]")
			if(GRAB_NECK)
				icon_state = "disarm/kill"
				user.visible_message("<span class='warning'>[user] has reinforced [user.p_their()] grip on [victim] (now neck)!</span>", null, null, 5)
				log_combat(user, victim, "neck grabbed")
				msg_admin_attack("[key_name(user)] grabbed the neck of [key_name(victim)]")
			if(GRAB_AGGRESSIVE)
				user.visible_message("<span class='warning'>[user] has grabbed [victim] aggressively (now hands)!</span>", null, null, 5)
		victim.update_canmove()


/obj/item/grab/attack(mob/living/attacked, mob/living/user, def_zone)
	if(attacked == user && CHECK_BITFIELD(SEND_SIGNAL(user, COMSIG_GRAB_SELF_ATTACK), COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK))
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
	if(length(stomach_contents)) //Only one thing in the stomach at a time, please
		to_chat(src, "<span class='warning'>You already have something in your belly, there's no way that will fit.</span>")
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

	stomach_contents.Add(prey)
	prey.KnockDown(360)
	prey.blind_eyes(1)
	prey.forceMove(src)

	SEND_SIGNAL(prey, COMSIG_CARBON_DEVOURED_BY_XENO)

	return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK


/mob/living/carbon/xenomorph/proc/can_devour_grabbed(mob/living/carbon/prey)
	if(!pulling)
		return FALSE
	if(pulling != prey)
		return FALSE
	if(prey.buckled || prey.stat == DEAD)
		return FALSE
	if(length(stomach_contents))
		return FALSE
	return TRUE


/mob/living/carbon/proc/on_devour_by_xeno()
	RegisterSignal(src, COMSIG_MOVABLE_RELEASED_FROM_STOMACH, .proc/on_release_from_stomach)


/mob/living/carbon/human/on_devour_by_xeno()
	if(istype(wear_ear, /obj/item/radio/headset/almayer/marine))
		var/obj/item/radio/headset/almayer/marine/marine_headset = wear_ear
		if(marine_headset.camera.status)
			marine_headset.camera.status = FALSE //Turn camera off.
			to_chat(src, "<span class='danger'>Your headset camera flickers off as you are devoured; you'll need to reactivate it by rebooting your headset HUD!<span>")
	return ..()


/mob/living/carbon/proc/on_release_from_stomach(mob/living/carbon/prey, mob/living/predator)
	prey.SetKnockeddown(1)
	prey.adjust_blindness(-1)
	UnregisterSignal(src, COMSIG_MOVABLE_RELEASED_FROM_STOMACH)