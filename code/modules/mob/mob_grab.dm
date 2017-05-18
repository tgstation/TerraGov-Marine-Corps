#define UPGRADE_COOLDOWN	40

/obj/item/weapon/grab
	name = "grab"
	icon_state = "reinforce"
	icon = 'icons/mob/screen1.dmi'
	flags_atom = NOBLUDGEON|DELONDROP
	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = 5
	var/atom/movable/grabbed_thing
	var/last_upgrade = 0 //used for cooldown between grab upgrades.


/obj/item/weapon/grab/New()
	..()
	last_upgrade = world.time

/obj/item/weapon/grab/dropped(mob/user)
	user.stop_pulling()
	. = ..()

/obj/item/weapon/grab/Del()
	if(ismob(loc))
		var/mob/M = loc
		M.grab_level = 0
		M.stop_pulling()
	..()

/obj/item/weapon/grab/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(isturf(target))
		var/turf/T = target
		if(!T.density && T.Adjacent(user))
			step(user.pulling, get_dir(user.pulling.loc, T))


/obj/item/weapon/grab/attack_self(mob/user)
	if(!ismob(grabbed_thing) || world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!ishuman(user)) //only humans can reinforce a grab.
		return
	var/mob/victim = grabbed_thing
	if(victim.mob_size > MOB_SIZE_HUMAN || !(victim.status_flags & CANPUSH))
		return //can't tighten your grip on big mobs and mobs you can't push.
	last_upgrade = world.time
	if(user.grab_level <= GRAB_KILL)
		user.grab_level++
		playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, -1)
		switch(user.grab_level)
			if(GRAB_KILL)
				icon_state = "disarm/kill1"
				user.visible_message("<span class='danger'>[user] has tightened \his grip on [victim]'s neck!</span>")
				victim.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been strangled (kill intent) by [user] ([user.ckey])</font>"
				user.attack_log += "\[[time_stamp()]\] <font color='red'>Strangled (kill intent) [victim] ([victim.ckey])</font>"
				msg_admin_attack("[key_name(user)] strangled (kill intent) [key_name(victim)]")
			if(GRAB_NECK)
				icon_state = "disarm/kill"
				user.visible_message("<span class='warning'>[user] has reinforced \his grip on [victim] (now neck)!</span>")
				victim.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their neck grabbed by [user] ([user.ckey])</font>"
				user.attack_log += "\[[time_stamp()]\] <font color='red'>Grabbed the neck of [victim] ([victim.ckey])</font>"
				msg_admin_attack("[key_name(user)] grabbed the neck of [key_name(victim)]")
			if(GRAB_AGGRESSIVE)
				user.visible_message("<span class='warning'>[user] has grabbed [victim] aggressively (now hands)!</span>")


/obj/item/weapon/grab/attack(mob/living/M, mob/living/user, def_zone)
	if(M == user && user.pulling && isXeno(user))
		var/mob/living/carbon/Xenomorph/X = user
		var/mob/living/carbon/pulled = X.pulling
		if(!istype(pulled))
			return
		if(isXeno(pulled))
			X << "<span class='warning'>That wouldn't taste very good.</span>"
			return 0
		if(pulled.stat == DEAD)
			X << "<span class='warning'>Ew, [pulled] is already starting to rot.</span>"
			return 0
			/* Saving this in case we want to allow devouring of dead bodies UNLESS their client is still online somewhere
			if(pulled.client) //The client is still inside the body
			else // The client is observing
				for(var/mob/dead/observer/G in player_list)
					if(ckey(G.mind.original.ckey) == pulled.ckey)
						src << "You start to devour [pulled] but realize \he is already dead."
						return */
		X.visible_message("<span class='danger'>[X] starts to devour [pulled]!</span>", \
		"<span class='danger'>You start to devour [pulled]!</span>")
		if(do_after(X, 50, FALSE))
			if(X.pulling == pulled && pulled.stat != DEAD) //make sure you've still got them in your claws, and alive
				X.visible_message("<span class='warning'>[X] devours [pulled]!</span>", \
				"<span class='warning'>You devour [pulled]!</span>")

				//IMPORTANT CODER NOTE: Due to us using the old lighting engine, we need to hacky hack hard to get this working properly
				//So we're just going to get the lights out of here by forceMoving them to a far-away place
				//They will be recovered when regurgitating, since this also calls forceMove
				pulled.x = 1
				pulled.y = 1
				pulled.z = 2 //Centcomm
				pulled.forceMove(pulled.loc)

				//Then, we place the mob where it ought to be
				X.stomach_contents.Add(pulled)
				pulled.forceMove(X)
				return 1
		if(!(pulled in X.stomach_contents))
			X << "<span class='warning'>You stop devouring \the [pulled]. \He probably tasted gross anyways.</span>"
		return 0

