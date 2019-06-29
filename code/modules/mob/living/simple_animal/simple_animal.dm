/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	status_flags = CANPUSH
	gender = PLURAL

	//Icons
	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	//Say
	var/list/speak = list()
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	//Movement
	var/turns_per_move = 1
	var/turns_since_move = 0
	var/stop_automated_movement = FALSE //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = TRUE	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = TRUE //When set to 1 this stops the animal from moving when someone is pulling it.
	var/obj/item/card/id/access_card = null	//innate access uses an internal ID card
	var/speed = 1
	var/AIStatus = AI_ON //The Status of our AI, can be set to AI_ON (On, usual processing), AI_IDLE (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever), AI_Z_OFF (Temporarily off due to nonpresence of players)
	var/can_have_ai = TRUE //once we have become sentient, we can never go back
	var/shouldwakeup = FALSE //convenience var for forcibly waking up an idling AI on next check.

	//Interaction
	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3
	var/force_threshold = 0 //Minimum force required to deal any damage
	var/healable = TRUE
	var/del_on_death = FALSE //causes mob to be deleted on death, useful for mobs that spawn lootable corpses
	var/deathmessage = ""

	//Attack
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "attacks"
	attack_sound = null
	friendly = "nuzzles" //If the mob does no damage with it's attack
	var/obj_damage = 0 //how much damage this simple animal does to objects, if any
	var/attacked_sound = "punch" //Played when someone punches the creature
	var/armour_penetration = 0 //How much armour they ignore, as a flat reduction from the targets armour value
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source


/mob/living/simple_animal/Initialize()
	. = ..()
	GLOB.simple_animals[AIStatus] += src
	if(gender == PLURAL)
		gender = pick(MALE, FEMALE)
	if(!real_name)
		real_name = name


/mob/living/simple_animal/Destroy()
	GLOB.simple_animals[AIStatus] -= src

	if(SSnpcpool.state == SS_PAUSED && LAZYLEN(SSnpcpool.currentrun))
		SSnpcpool.currentrun -= src

	var/turf/T = get_turf(src)
	if(T && AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src

	return ..()


/mob/living/simple_animal/handle_status_effects()
	. = ..()
	if(stuttering)
		stuttering = 0


/mob/living/simple_animal/updatehealth()
	. = ..()
	health = CLAMP(health, 0, maxHealth)


/mob/living/simple_animal/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			stat = CONSCIOUS
	med_hud_set_status()


/mob/living/simple_animal/revive()
	. = ..()
	icon = initial(icon)
	icon_state = icon_living
	density = initial(density)
	set_resting(FALSE)


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


/mob/living/simple_animal/death(gibbed)
	. = ..()
	if(!gibbed)
		if(deathmessage || !del_on_death)
			emote("deathgasp")
	if(del_on_death)
		. = ..()
		//Prevent infinite loops if the mob Destroy() is overridden in such
		//a manner as to cause a call to death() again
		del_on_death = FALSE
		qdel(src)
	else
		health = 0
		icon_state = icon_dead
		density = FALSE
		return ..()


/mob/living/simple_animal/gib_animation()
	if(!icon_gib)
		return
	new /obj/effect/overlay/temp/gib_animation/animal(loc, src, icon_gib)


/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = FALSE

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)


/mob/living/simple_animal/bullet_act(obj/item/projectile/Proj)
	if(!Proj || Proj.damage <= 0)
		return FALSE

	adjustBruteLoss(Proj.damage)
	return TRUE


/mob/living/simple_animal/attack_hand(mob/living/user)
	. = ..()
	switch(user.a_intent)
		if(INTENT_HELP)
			if(health <= 0)
				return FALSE
			visible_message("<span class='notice'>[user] [response_help] [src].</span>")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(INTENT_GRAB)
			user.start_pulling(src)

		if(INTENT_HARM, INTENT_DISARM)
			user.animation_attack_on(src)
			visible_message("<span class='danger'>[user] [response_harm] [src]!</span>",\
			"<span class='userdanger'>[user] [response_harm] [src]!</span>")
			playsound(loc, attacked_sound, 25, 1, -1)
			attack_threshold_check(harm_intent_damage)
			log_combat(user, src, "attacked")
			updatehealth()
			return TRUE


/mob/living/simple_animal/attack_alien(mob/living/carbon/xenomorph/X)
	. = ..()
	if(!.)
		return
	if(X.a_intent == INTENT_DISARM)
		playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[X] [response_disarm] [name]!</span>", \
				"<span class='userdanger'>[X] [response_disarm] [name]!</span>")
		log_combat(X, src, "disarmed")
	else
		var/damage = rand(15, 30)
		visible_message("<span class='danger'>[X] has slashed at [src]!</span>", \
				"<span class='userdanger'>[X] has slashed at [src]!</span>")
		playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
		attack_threshold_check(damage)
		log_combat(X, src, "attacked")
	return TRUE


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

	switch(severity)
		if(1)
			adjustBruteLoss(500)
			gib()
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)


/mob/living/simple_animal/get_idcard(hand_first)
	return access_card


/mob/living/simple_animal/say_mod(input, message_mode, datum/language/language)
	if(length(speak_emote))
		verb_say = pick(speak_emote)
	return ..()


/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = "melee")
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message("<span class='warning'>[src] looks unharmed.</span>")
		return FALSE
	else
		apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE


/mob/living/simple_animal/proc/toggle_ai(togglestatus)
	if(!can_have_ai && (togglestatus != AI_OFF))
		return
	if(AIStatus != togglestatus)
		if(togglestatus > 0 && togglestatus < 5)
			if(togglestatus == AI_Z_OFF || AIStatus == AI_Z_OFF)
				var/turf/T = get_turf(src)
				if(AIStatus == AI_Z_OFF)
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src
				else
					SSidlenpcpool.idle_mobs_by_zlevel[T.z] += src
			GLOB.simple_animals[AIStatus] -= src
			GLOB.simple_animals[togglestatus] += src
			AIStatus = togglestatus
		else
			stack_trace("Something attempted to set simple animals AI to an invalid state: [togglestatus]")


/mob/living/simple_animal/onTransitZ(old_z, new_z)
	. = ..()
	if(AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[old_z] -= src
		toggle_ai(initial(AIStatus))


/mob/living/simple_animal/IsAdvancedToolUser()
	return FALSE


/mob/living/simple_animal/proc/handle_automated_action()
	set waitfor = FALSE
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	set waitfor = FALSE
	if(!stop_automated_movement && wander)
		if(isturf(loc) && canmove)
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby))
					var/anydir = pick(GLOB.cardinals)
					if(Process_Spacemove(anydir))
						Move(get_step(src, anydir), anydir)
						turns_since_move = 0
			return TRUE


/mob/living/simple_animal/proc/handle_automated_speech(override)
	set waitfor = FALSE
	if(speak_chance)
		if(prob(speak_chance) || override)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak), forced = "poly")
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote("me [pick(emote_see)]", 1)
						else
							emote("me [pick(emote_hear)]", 2)
				else
					say(pick(speak), forced = "poly")
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote("me", 1, pick(emote_see))
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote("me", 2, pick(emote_hear))
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote("me", 1, pick(emote_see))
					else
						emote("me", 2, pick(emote_hear))


/mob/living/simple_animal/proc/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(ismob(the_target))
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return FALSE
	return TRUE


/mob/living/simple_animal/proc/consider_wakeup()
	if(pulledby || shouldwakeup)
		toggle_ai(AI_ON)


/mob/living/simple_animal/proc/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	bruteloss = round(CLAMP(bruteloss + amount, 0, maxHealth), 0.1)
	if(updating_health)
		updatehealth()
	return amount