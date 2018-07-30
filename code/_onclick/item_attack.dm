
// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	return

// No comment
/atom/proc/attackby(obj/item/W, mob/living/user)
	return
/atom/movable/attackby(obj/item/W, mob/living/user)
	if(W)
		if(!(W.flags_item & NOBLUDGEON))
			visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>", null, 5)
			user.animation_attack_on(src)
			user.flick_attack_overlay(src, "punch")

/mob/living/attackby(obj/item/I, mob/user)
	if(istype(I) && ismob(user))
		I.attack(src, user)


// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	return


/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)
	if(flags_item & NOBLUDGEON)
		return

	if (!istype(M)) // not sure if this is the right thing...
		return 0

	if (M.can_be_operated_on())        //Checks if mob is lying down on table for surgery
		if (do_surgery(M,user,src))
			return 0

	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
	msg_admin_attack("[key_name(user)] attacked [key_name(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])" )

	/////////////////////////

	add_fingerprint(user)

	var/power = force
	if(HULK in user.mutations)
		power *= 2

	if(user.mind && user.mind.cm_skills)
		power = round(power * (1 + 0.3*user.mind.cm_skills.melee_weapons)) //30% bonus per melee level

	if(!ishuman(M))
		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		var/used_verb = "attacked"
		if(attack_verb && attack_verb.len)
			used_verb = pick(attack_verb)
		user.visible_message("<span class='danger'>[M] has been [used_verb] with [src][showname].</span>",\
						"<span class='danger'>You attack [M] with [src].</span>", null, 5)

		user.animation_attack_on(M)
		user.flick_attack_overlay(M, "punch")

		if(hitsound)
			playsound(loc, hitsound, 25, 1)
		switch(damtype)
			if("brute")
				M.apply_damage(power,BRUTE)
			if("fire")
				if (!(COLD_RESISTANCE in M.mutations))
					M.apply_damage(power,BURN)
					M << "\red It burns!"
		M.updatehealth()
	else
		var/mob/living/carbon/human/H = M
		var/hit = H.attacked_by(src, user, def_zone)
		if (hit && hitsound)
			playsound(loc, hitsound, 25, 1)
		return hit
	return 1
