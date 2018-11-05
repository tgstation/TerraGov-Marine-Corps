//Refer to life.dm for caller

/mob/living/carbon/human/handle_shock()
	. = ..()
	if(status_flags & GODMODE || analgesic || (species && species.flags & NO_PAIN) || stat == DEAD)
		shock_stage = null
		return //Godmode or some other pain reducers. //Analgesic avoids all traumatic shock temporarily

	switch(CLAMP(traumatic_shock,0,400))
		if(201 to 400)
			shock_stage = CLAMP(shock_stage + 5,150,200) //Indescribable pain. At this point, you will immediately be knocked down, with shock stage set to 150.

		if(150 to 200)
			shock_stage = min(200,shock_stage + 2) //If their shock exceeds 150, add more to their shock stage, regardless of health.

		if(100 to 149)
			shock_stage = min(200,shock_stage + 1) //If their shock exceeds 100, add more to their shock stage, regardless of health.

		if(75 to 99)
			shock_stage = CLAMP(shock_stage - 1, 0, 120) //No greater than 120 and no smaller than 0

		if(50 to 74)
			shock_stage = CLAMP(shock_stage - 2, 0, 80)

		if(0 to 49)
			shock_stage = CLAMP(shock_stage - 5, 0, 60) //When we have almost no pain remaining. No greater than 60 and no smaller than 0, reduced by 10 each time.

	//This just adds up effects together at each step, with a few small exceptions. Preferable to copy and paste rather than have a billion if statements.
	switch(shock_stage)
		if(10 to 29)
			if(prob(20))
				to_chat(src, "<span class='danger'>[pick("You're in a bit of pain", "You ache a little", "You feel some physical discomfort")].</span>")
		if(30 to 39)
			if(prob(20))
				to_chat(src, "<span class='danger'>[pick("It hurts so much", "You really need some painkillers", "Dear god, the pain")]!</span>")
			blur_eyes(2)
			stuttering = max(stuttering, 5)
		if(40 to 59)
			if(prob(20))
				to_chat(src, "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>")
			blur_eyes(2)
			stuttering = max(stuttering, 5)
		if(60 to 79)
			if(!lying && prob(20))
				emote("me", 1, " is having trouble standing.")
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			if(prob(2))
				if(!lying)
					emote("me", 1, " is having trouble standing.")
				to_chat(src, "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>")
				KnockDown(5)
		if(80 to 119)
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			if(prob(7))
				if(!lying)
					emote("me", 1, " is having trouble standing.")
				to_chat(src, "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>")
				KnockDown(5)
		if(120 to 149)
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			if(prob(7))
				if(!lying)
					emote("me", 1, " is having trouble standing.")
				to_chat(src, "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>")
				KnockDown(5)
			if(prob(2))
				to_chat(src, "<span class='danger'>[pick("You black out", "You feel like you could die any moment now", "You're about to lose consciousness")]!</span>")
				KnockOut(5)
		if(150 to INFINITY)
			if(shock_stage == 150 && !lying) emote("me", 1, "can no longer stand, collapsing!")
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			if(prob(7))
				to_chat(src, "<span class='danger'>[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!</span>")
			if(prob(2))
				to_chat(src, "<span class='danger'>[pick("You black out", "You feel like you could die any moment now", "You're about to lose consciousness")]!</span>")
				KnockOut(5)
			KnockDown(5)


/mob/living/carbon/human/halloss_recovery()
	if(status_flags & GODMODE || analgesic || (species && species.flags & NO_PAIN) || stat == DEAD)
		setHalLoss(0)
		return
	var/rate = BASE_HALLOSS_RECOVERY_RATE

	if(lying || last_move_intent < world.time - 20) //If we're standing still or knocked down we benefit from the downed halloss rate
		if(resting || sleeping) //we're deliberately resting, comfortably taking a breather
			rate = REST_HALLOSS_RECOVERY_RATE
		else
			rate = DOWNED_HALLOSS_RECOVERY_RATE
	else if(m_intent == MOVE_INTENT_WALK)
		rate = WALK_HALLOSS_RECOVERY_RATE
	if(aura_recovery_multiplier)
		rate *= aura_recovery_multiplier

	adjustHalLoss(rate)
