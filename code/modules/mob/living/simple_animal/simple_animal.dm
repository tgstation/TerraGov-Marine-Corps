/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	status_flags = CANPUSH
	gender = PLURAL
	buckle_flags = NONE

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
	var/response_help = "pokes"
	var/response_disarm = "shoves"
	var/response_harm = "hits"
	var/harm_intent_damage = 3
	var/force_threshold = 0 //Minimum force required to deal any damage
	var/healable = TRUE
	var/del_on_death = FALSE //causes mob to be deleted on death, useful for mobs that spawn lootable corpses
	var/deathmessage = ""

	//Attack
	melee_damage = 0
	var/obj_damage = 0 //how much damage this simple animal does to objects, if any
	var/attacked_sound = SFX_PUNCH //Played when someone punches the creature
	var/armour_penetration = 0 //How much armour they ignore, as a flat reduction from the targets armour value
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source

/mob/living/simple_animal/Initialize(mapload)
	. = ..()
	GLOB.simple_animals[AIStatus] += src
	if(gender == PLURAL)
		gender = pick(MALE, FEMALE)
	if(!real_name)
		real_name = name
	if(speed)
		update_simplemob_varspeed()


/mob/living/simple_animal/Destroy()
	GLOB.simple_animals[AIStatus] -= src

	if(SSnpcpool.state == SS_PAUSED && LAZYLEN(SSnpcpool.currentrun))
		SSnpcpool.currentrun -= src

	var/turf/T = get_turf(src)
	if(T && AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[T.z] -= src

	return ..()


/mob/living/simple_animal/updatehealth()
	. = ..()
	health = clamp(health, 0, maxHealth)

/mob/living/simple_animal/update_sight()
	lighting_color_cutoffs = list(lighting_cutoff_red, lighting_cutoff_green, lighting_cutoff_blue)
	return ..()

/mob/living/simple_animal/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()


/mob/living/simple_animal/revive(admin_revive = FALSE)
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


/mob/living/simple_animal/death(gibbing, deathmessage, silent)
	if(stat == DEAD)
		return ..()
	return ..()


/mob/living/simple_animal/on_death()
	health = 0
	icon_state = icon_dead
	density = FALSE
	to_chat(src,"<b>[span_deadsay("<p style='font-size:1.5em'><big>You have perished.</big></p>")]</b>")

	. = ..()

	if(del_on_death && !QDELETED(src))
		qdel(src)


/mob/living/simple_animal/gib_animation()
	if(!icon_gib)
		return
	new /obj/effect/overlay/temp/gib_animation/animal(loc, 0, src, icon_gib)


/mob/living/simple_animal/proc/set_varspeed(var_value)
	speed = var_value
	update_simplemob_varspeed()


/mob/living/simple_animal/proc/update_simplemob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(MOVESPEED_ID_SIMPLEMOB_VARSPEED, TRUE)
	add_movespeed_modifier(MOVESPEED_ID_SIMPLEMOB_VARSPEED, TRUE, 100, multiplicative_slowdown = speed, override = TRUE)


/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = FALSE

	if(resize != RESIZE_DEFAULT_SIZE)
		changed = TRUE
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)

/mob/living/simple_animal/attack_hand(mob/living/user)
	. = ..()
	switch(user.a_intent)
		if(INTENT_HELP)
			if(health <= 0)
				return FALSE
			visible_message(span_notice("[user] [response_help] [src]."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		if(INTENT_GRAB)
			user.start_pulling(src)

		if(INTENT_HARM, INTENT_DISARM)
			user.do_attack_animation(src)
			user.do_attack_animation(src, ATTACK_EFFECT_KICK)
			visible_message(span_danger("[user] [response_harm] [src]!"),
			span_userdanger("[user] [response_harm] [src]!"))
			playsound(loc, attacked_sound, 25, 1, -1)
			attack_threshold_check(harm_intent_damage)
			UPDATEHEALTH(src)
			log_combat(user, src, "attacked")
			return TRUE


/mob/living/simple_animal/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	. = ..()
	if(!.)
		return
	if(xeno_attacker.a_intent == INTENT_DISARM)
		playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
		visible_message(span_danger("[xeno_attacker] [response_disarm] [name]!"), \
				span_userdanger("[xeno_attacker] [response_disarm] [name]!"))
		log_combat(xeno_attacker, src, "disarmed")
	else
		var/damage = rand(15, 30)
		visible_message(span_danger("[xeno_attacker] has slashed at [src]!"), \
				span_userdanger("[xeno_attacker] has slashed at [src]!"))
		playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
		attack_threshold_check(damage)
		log_combat(xeno_attacker, src, "attacked")
	return TRUE


/mob/living/simple_animal/get_status_tab_items()
	. = ..()
	. += "Health: [round((health / maxHealth) * 100)]%"


/mob/living/simple_animal/ex_act(severity)
	flash_act()

	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
			return
		if(EXPLODE_HEAVY)
			adjustBruteLoss(60)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(30)
		if(EXPLODE_WEAK)
			adjustBruteLoss(15)

	UPDATEHEALTH(src)


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
		visible_message(span_warning("[src] looks unharmed."))
		return FALSE
	else
		apply_damage(damage, damagetype, blocked = armorcheck)
		UPDATEHEALTH(src)
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


/mob/living/simple_animal/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	. = ..()
	if(AIStatus == AI_Z_OFF)
		SSidlenpcpool.idle_mobs_by_zlevel[old_turf.z] -= src
		toggle_ai(initial(AIStatus))


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
			if(length(speak))
				if((emote_hear && length(emote_hear)) || (emote_see && length(emote_see)))
					var/length = speak.len
					if(emote_hear && length(emote_hear))
						length += emote_hear.len
					if(emote_see && length(emote_see))
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= length(speak))
						say(pick(speak), forced = "poly")
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= length(emote_see))
							emote("me [pick(emote_see)]", 1)
						else
							emote("me [pick(emote_hear)]", 2)
				else
					say(pick(speak), forced = "poly")
			else
				if(!length(emote_hear) && length(emote_see))
					emote("me", 1, pick(emote_see))
				if(length(emote_hear) && !length(emote_see))
					emote("me", 2, pick(emote_hear))
				if(length(emote_hear) && length(emote_see))
					var/length = length(emote_hear) + emote_see.len
					var/pick = rand(1,length)
					if(pick <= length(emote_see))
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
	bruteloss = round(clamp(bruteloss + amount, 0, maxHealth), 0.1)
	if(updating_health)
		updatehealth()
	return amount
