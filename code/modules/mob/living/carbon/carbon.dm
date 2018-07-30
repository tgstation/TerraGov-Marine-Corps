/mob/living/carbon/Life()
	..()

	handle_fire() //Check if we're on fire


/mob/living/carbon/Dispose()
	for(var/datum/disease/virus in viruses)
		virus.cure()
	. = ..()
	stomach_contents.Cut() //movable atom's Dispose() deletes all content, we clear stomach_contents to be safe.

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition && stat != DEAD)
			nutrition -= HUNGER_FACTOR/10
			if(m_intent == MOVE_INTENT_RUN)
				nutrition -= HUNGER_FACTOR/10

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

/mob/living/carbon/relaymove(mob/user, direction)
	if(user.is_mob_incapacitated(TRUE)) return
	if(user in src.stomach_contents)
		if(user.client)
			user.client.next_movement = world.time + 20
		if(prob(30))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message("\red You hear something rumbling inside [src]'s stomach...", 2)
		var/obj/item/I = user.get_active_hand()
		if(I && I.force)
			var/d = rand(round(I.force / 4), I.force)
			if(istype(src, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = src
				var/organ = H.get_limb("chest")
				if (istype(organ, /datum/limb))
					var/datum/limb/temp = organ
					if(temp.take_damage(d, 0))
						H.UpdateDamageIcon()
				H.updatehealth()
			else
				src.take_limb_damage(d)
			for(var/mob/M in viewers(user, null))
				if(M.client)
					M.show_message(text("\red <B>[user] attacks [src]'s stomach wall with the [I.name]!"), 2)
			playsound(user.loc, 'sound/effects/attackblob.ogg', 25, 1)

			if(prob(max(4*(100*getBruteLoss()/maxHealth - 75),0))) //4% at 24% health, 80% at 5% health
				gib()
	else if(!chestburst && (status_flags & XENO_HOST) && isXenoLarva(user))
		var/mob/living/carbon/Xenomorph/Larva/L = user
		L.chest_burst(src)


/mob/living/carbon/gib()
	if(legcuffed)
		drop_inv_item_on_ground(legcuffed)

	for(var/atom/movable/A in stomach_contents)
		stomach_contents.Remove(A)
		A.forceMove(loc)
		A.acid_damage = 0 //Reset the acid damage
		if(ismob(A))
			visible_message("<span class='danger'>[A] bursts out of [src]!</span>")

	. = ..()


/mob/living/carbon/revive()
	if (handcuffed && !initial(handcuffed))
		drop_inv_item_on_ground(handcuffed)
	handcuffed = initial(handcuffed)

	if (legcuffed && !initial(legcuffed))
		drop_inv_item_on_ground(legcuffed)
	legcuffed = initial(legcuffed)
	..()


/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

	next_move += 7 //Adds some lag to the 'attack'
	return


/mob/living/carbon/attack_paw(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return

	for(var/datum/disease/D in viruses)

		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)

		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

	next_move += 7 //Adds some lag to the 'attack'
	return

/mob/living/carbon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE)	return 0	//godmode
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0

	src.apply_damage(shock_damage, BURN, def_zone, used_weapon="Electrocution")

	playsound(loc, "sparks", 25, 1)
	if (shock_damage > 10)
		src.visible_message(
			"\red [src] was shocked by the [source]!", \
			"\red <B>You feel a powerful shock course through your body!</B>", \
			"\red You hear a heavy electrical crack." \
		)
		if(isXeno(src) && mob_size == MOB_SIZE_BIG)
			Stun(1)//Sadly, something has to stop them from bumping them 10 times in a second
			KnockDown(1)
		else
			Stun(10)//This should work for now, more is really silly and makes you lay there forever
			KnockDown(10)
	else
		src.visible_message(
			"\red [src] was mildly shocked by the [source].", \
			"\red You feel a mild shock course through your body.", \
			"\red You hear a light zapping." \
		)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, loc)
	s.start()

	return shock_damage


/mob/living/carbon/proc/swap_hand()
	var/obj/item/wielded_item = get_active_hand()
	if(wielded_item && (wielded_item.flags_item & WIELDED)) //this segment checks if the item in your hand is twohanded.
		var/obj/item/weapon/twohanded/offhand/offhand = get_inactive_hand()
		if(offhand && (offhand.flags_item & WIELDED))
			src << "<span class='warning'>Your other hand is too busy holding \the [offhand.name]</span>" //So it's an offhand.
			return
		else wielded_item.unwield(src) //Get rid of it.
	if(wielded_item && wielded_item.zoom) //Adding this here while we're at it
		wielded_item.zoom(src)
	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_active"
			hud_used.r_hand_hud_object.icon_state = "hand_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_active"
	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/proc/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (health >= config.health_threshold_crit)
		if(src != M)
			var/t_him = "it"
			if (gender == MALE)
				t_him = "him"
			else if (gender == FEMALE)
				t_him = "her"
			if(lying || sleeping)
				if(client)
					sleeping = max(0,sleeping-5)
				if(sleeping == 0)
					resting = 0
					update_canmove()
				M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!", \
									"<span class='notice'>You shake [src] trying to wake [t_him] up!", null, 4)
			else
				var/mob/living/carbon/human/H = M
				if(istype(H))
					H.species.hug(H,src)
				else
					M.visible_message("<span class='notice'>[M] hugs [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You hug [src] to make [t_him] feel better!</span>", null, 4)

			AdjustKnockedout(-3)
			AdjustStunned(-3)
			AdjustKnockeddown(-3)

			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 5)




// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END


//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(hud_used && hud_used.throw_icon) //in case we don't have the HUD and we use the hotkey
		hud_used.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(hud_used && hud_used.throw_icon)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	src.throw_mode_off()
	if(is_ventcrawling) //NOPE
		return
	if(usr.stat || !target)
		return
	if(target.type == /obj/screen)
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = get_active_hand()

	if(!I || (I.flags_item & NODROP)) return

	var/spin_throw = TRUE

	if (istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(ismob(G.grabbed_thing))
			if(grab_level >= GRAB_NECK)
				var/mob/living/M = G.grabbed_thing
				spin_throw = FALSE //thrown mobs don't spin
				thrown_thing = M
				var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
				var/turf/end_T = get_turf(target)
				if(start_T && end_T)
					var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
					var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

					M.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>"
					usr.attack_log += "\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>"
					msg_admin_attack("[usr.name] ([usr.ckey]) has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>)")
			else
				src << "<span class='warning'>You need a better grip!</span>"

	else //real item in hand, not a grab
		thrown_thing = I
		drop_inv_item_on_ground(I, TRUE)

	//actually throw it!
	if (thrown_thing)
		visible_message("<span class='warning'>[src] has thrown [thrown_thing].</span>", null, null, 5)

		if(!lastarea)
			lastarea = get_area(src.loc)
		if((istype(loc, /turf/open/space)) || !lastarea.has_gravity)
			inertia_dir = get_dir(target, src)
			step(src, inertia_dir)

		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, spin_throw)

/mob/living/carbon/fire_act(exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)


/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_interaction(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=face'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank) && !( internal )) ? " <A href='?src=\ref[src];internal=1'>Set Internal</A>" : "")]
	<BR>[(handcuffed ? "<A href='?src=\ref[src];item=handcuffs'>Handcuffed</A>" : "<A href='?src=\ref[src];item=handcuffs'>Not Handcuffed</A>")]
	<BR>[(internal ? "<A href='?src=\ref[src];internal=1'>Remove Internal</A>" : "")]
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, "window=mob[name];size=325x500")
	onclose(user, "mob[name]")
	return

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		usr << "\red You are already sleeping"
		return
	if(alert(src,"You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		usr.sleeping = 20 //Short nap


/mob/living/carbon/Bump(atom/movable/AM, yes)
	if(!yes || now_pushing)
		return
	. = ..()

/mob/living/carbon/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	set waitfor = 0
	if(buckled) return FALSE //can't slip while buckled
	if(run_only && (m_intent != MOVE_INTENT_RUN)) return FALSE
	if(lying) return FALSE //can't slip if already lying down.
	stop_pulling()
	src << "<span class='warning'>You slipped on \the [slip_source_name? slip_source_name : "floor"]!</span>"
	playsound(src.loc, 'sound/misc/slip.ogg', 25, 1)
	Stun(stun_level)
	KnockDown(weaken_level)
	. = TRUE
	if(slide_steps && lying)//lying check to make sure we downed the mob
		var/slide_dir = dir
		for(var/i=1, i<=slide_steps, i++)
			step(src, slide_dir)
			sleep(2)
			if(!lying)
				break



/mob/living/carbon/on_stored_atom_del(atom/movable/AM)
	..()
	if(stomach_contents.len && ismob(AM))
		for(var/X in stomach_contents)
			if(AM == X)
				stomach_contents -= AM
				break
