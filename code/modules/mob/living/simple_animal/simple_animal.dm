/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list()
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/turns_per_move = 1
	var/turns_since_move = 0
	universal_speak = 0		//No, just no.
	var/meat_amount = 0
	var/meat_type
	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.

	//Interaction
	var/response_help   = "tries to help"
	var/response_disarm = "tries to disarm"
	var/response_harm   = "tries to hurt"
	var/harm_intent_damage = 3

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp

	//Atmos effect - Yes, you can make creatures that require phoron or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above
	var/speed = 0 //LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster

	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "attacks"
	attack_sound = null
	friendly = "nuzzles" //If the mob does no damage with it's attack

	//simple_animal access
	var/obj/item/card/id/access_card = null	//innate access uses an internal ID card


/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = null
	..()

/mob/living/simple_animal/handle_status_effects()
	..()
	if(stuttering)
		stuttering = 0

/mob/living/simple_animal/updatehealth()
	..()
	health = CLAMP(health, 0, maxHealth)

/mob/living/simple_animal/update_stat()
	. = ..()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			stat = CONSCIOUS

/mob/living/simple_animal/rejuvenate()
	. = ..()
	icon_state = icon_living
	density = initial(density)
	resting = FALSE

/mob/living/simple_animal/Life()
	..()

	//Health
	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return FALSE

	//Movement
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					Move(get_step(src,pick(cardinal)))
					turns_since_move = 0

	//Speaking
	if(!client && speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)


	//Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc

	if(istype(A,/turf))
		var/turf/T = A

		var/env_temp = T.return_temperature()
		var/env_gas = T.return_gas()

		if( abs(env_temp - bodytemperature) > 40 )
			adjust_bodytemperature((env_temp - bodytemperature) / 5)

		if(min_oxy)
			if(env_gas != GAS_TYPE_AIR && env_gas != GAS_TYPE_OXYGEN)
				atmos_suitable = 0
		if(max_oxy)
			if(env_gas == GAS_TYPE_OXYGEN)
				atmos_suitable = 0
		if(min_tox)
			if(env_gas != GAS_TYPE_PHORON)
				atmos_suitable = 0
		if(max_tox)
			if(env_gas == GAS_TYPE_PHORON)
				atmos_suitable = 0
		if(min_n2)
			if(env_gas != GAS_TYPE_NITROGEN)
				atmos_suitable = 0
		if(max_n2)
			if(env_gas == GAS_TYPE_NITROGEN)
				atmos_suitable = 0
		if(min_co2)
			if(env_gas != GAS_TYPE_CO2)
				atmos_suitable = 0
		if(max_co2)
			if(env_gas == GAS_TYPE_CO2)
				atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(heat_damage_per_tick)

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)
	return 1

/mob/living/simple_animal/Bumped(AM as mob|obj)
	if(!AM)
		return

	if(resting || buckled)
		return

	return ..()

/mob/living/simple_animal/blind_eyes()
	return

/mob/living/simple_animal/adjust_blindness()
	return

/mob/living/simple_animal/set_blindness()
	return

/mob/living/simple_animal/blur_eyes()
	return

/mob/living/simple_animal/adjust_blurriness()
	return

/mob/living/simple_animal/set_blurriness()
	return

/mob/living/simple_animal/death()
	. = ..()
	health = 0
	icon_state = icon_dead
	density = FALSE
	resting = TRUE


/mob/living/simple_animal/gib()
	if(meat_amount && meat_type)
		for(var/i = 0; i < meat_amount; i++)
			new meat_type(src.loc)
	..()

/mob/living/simple_animal/gib_animation()
	if(icon_gib)
		new /obj/effect/overlay/temp/gib_animation/animal(loc, src, icon_gib)


/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)


/mob/living/simple_animal/emote(var/act, var/type, var/message, player_caused)
	if(act)
		if(act == "scream")	act = "whimper" //ugly hack to stop animals screaming when crushed :P
		..(act, type, message, player_caused)

/mob/living/simple_animal/attack_animal(mob/living/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 25, 1)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>", 1)
		log_combat(M, src, "attacked")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj || Proj.damage <= 0)
		return 0

	adjustBruteLoss(Proj.damage)
	return 1

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(INTENT_HELP)
			if (health > 0)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !is_blind(O)))
						O.show_message("<span class='notice'> [M] [response_help] [src]</span>")

		if(INTENT_GRAB)
			if(M == src || anchored)
				return 0
			M.start_pulling(src)

			return 1

		if(INTENT_HARM, INTENT_DISARM)
			adjustBruteLoss(harm_intent_damage)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !is_blind(O)))
					O.show_message("<span class='warning'> [M] [response_harm] [src]</span>")

	return


/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))

		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.get_amount() >= 1)
					adjustBruteLoss(-MED.heal_brute)
					MED.use(1)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !is_blind(M)))
							M.show_message("<span class='notice'> [user] applies the [MED] on [src]</span>")
		else
			to_chat(user, "<span class='notice'>this [src] is dead, medical items won't bring it back to life.</span>")
	if(meat_type && (stat == DEAD))	//if the animal has a meat, and if it is dead.
		if(istype(O, /obj/item/tool/kitchen/knife) || istype(O, /obj/item/tool/kitchen/knife/butcher))
			new meat_type (get_turf(src))
			if(prob(95))
				qdel(src)
				return
			gib()
	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !is_blind(M)))
					M.show_message("<span class='danger'> [src] has been attacked with the [O] by [user]. </span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			for(var/mob/M in viewers(src, null))
				if ((M.client && !is_blind(M)))
					M.show_message("<span class='warning'> [user] gently taps [src] with the [O]. </span>")



/mob/living/simple_animal/movement_delay()
	. = ..()
	. += speed
	. += CONFIG_GET(number/outdated_movedelay/animal_delay)


/mob/living/simple_animal/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")


/mob/living/simple_animal/ex_act(severity)
	flash_eyes()
	switch (severity)
		if (1.0)
			adjustBruteLoss(500)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/proc/SA_attackable(target_mob)
	if (isliving(target_mob))
		var/mob/living/L = target_mob
		if(!L.stat)
			return (0)
	if (istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		if (M.occupant)
			return (0)
	if (istype(target_mob,/obj/machinery/bot))
		var/obj/machinery/bot/B = target_mob
		if(B.health > 0)
			return (0)
	return (1)

//Call when target overlay should be added/removed
/mob/living/simple_animal/update_targeted()
	if(!targeted_by && target_locked)
		qdel(target_locked)
		target_locked = null
	overlays = null
	if (targeted_by && target_locked)
		overlays += target_locked

/mob/living/simple_animal/say(var/message)
	if(stat)
		return

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	if(stat)
		return

	var/verb = "says"

	if(speak_emote.len)
		verb = pick(speak_emote)

	message = capitalize(trim_left(message))

	..(message, null, verb)

/mob/living/simple_animal/get_idcard(hand_first)
	return access_card
