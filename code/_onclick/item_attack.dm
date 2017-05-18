
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/user)
	return
/atom/movable/attackby(obj/item/W, mob/user)
	if(W)
		if(!(W.flags_atom & NOBLUDGEON))
			visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")

/mob/living/attackby(obj/item/I, mob/user)
	if(istype(I) && ismob(user))
		I.attack(src, user)


// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return


/obj/item/proc/attack(mob/living/M as mob, mob/living/user as mob, def_zone)
	if(flags_atom & NOBLUDGEON)
		return

	if (!istype(M)) // not sure if this is the right thing...
		return 0

	var/messagesource = M
	if (can_operate(M))        //Checks if mob is lying down on table for surgery
		if (do_surgery(M,user,src))
			return 0
	if (istype(M,/mob/living/carbon/brain))
		messagesource = M:container
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
	msg_admin_attack("[key_name(user)] attacked [key_name(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])" )

	//spawn(1800)            // this wont work right
	//	M.lastattacker = null
	/////////////////////////

	var/power = force
	if(HULK in user.mutations)
		power *= 2

	if(!istype(M, /mob/living/carbon/human))

		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		for(var/mob/O in viewers(messagesource, null))
			if(!isnull(src.attack_verb))
				if(src.attack_verb.len)
					O.show_message("\red <B>[M] has been [pick(attack_verb)] with [src][showname] </B>", 1)
			else
				O.show_message("\red <B>[M] has been attacked with [src][showname] </B>", 1)

		if(!showname && user)
			if(user.client)
				user << "\red <B>You attack [M] with [src]. </B>"

	if(istype(M, /mob/living/carbon/human))
		var/hit = M:attacked_by(src, user, def_zone)
		if (hit && hitsound)
			playsound(loc, hitsound, 50, 1, -1)
		return hit
	else //Xenos taking damage from weapons goes here.
		if(hitsound)
			playsound(loc, hitsound, 50, 1, -1)
		if(ishuman(M) && power > 5)
			var/mob/living/carbon/human/H = M
			H.forcesay()
		switch(damtype)
			if("brute")
				M.apply_damage(power,BRUTE)
			if("fire")
				if (!(COLD_RESISTANCE in M.mutations))
					M.apply_damage(power,BURN)
					M << "\red It burns!"
		M.updatehealth()
	add_fingerprint(user)
	return 1
