//Refer to life.dm for caller

/mob/living/carbon/human/handle_shock()
	. = ..()
	if(status_flags & GODMODE || analgesic || (species && species.species_flags & NO_PAIN) || stat == DEAD)
		setShock_Stage(0)
		return //Godmode or some other pain reducers. //Analgesic avoids all traumatic shock temporarily

	switch(traumatic_shock)
		if(200 to INFINITY)
			setShock_Stage(max(shock_stage + 5, 150)) //Indescribable pain. At this point, you will immediately be knocked down, with shock stage set to 150.

		if(150 to 200)
			adjustShock_Stage(2) //If their shock exceeds 150, add more to their shock stage, regardless of health.

		if(100 to 150)
			adjustShock_Stage(1) //If their shock exceeds 100, add more to their shock stage, regardless of health.

		if(75 to 100)
			setShock_Stage(min(shock_stage - 1, 120)) //No greater than 120

		if(50 to 75)
			setShock_Stage(min(shock_stage - 2, 80))

		if(-INFINITY to 50)
			setShock_Stage(min(shock_stage - 5, 60)) //When we have almost no pain remaining. No greater than 60, reduced by 10 each time.

	//This just adds up effects together at each step, with a few small exceptions. Preferable to copy and paste rather than have a billion if statements.
	switch(shock_stage)
		if(10 to 29)
			if(prob(20))
				to_chat(src, span_danger("[pick("You're in a bit of pain", "You ache a little", "You feel some physical discomfort")]."))
		if(30 to 39)
			if(prob(20))
				to_chat(src, span_danger("[pick("It hurts so much", "You really need some painkillers", "Dear god, the pain")]!"))
			blur_eyes(2)
			stuttering = max(stuttering, 5)
		if(40 to 59)
			if(prob(20))
				to_chat(src, span_danger("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!"))
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			adjust_stagger(1, FALSE, 1)
			add_slowdown(1)
		if(60 to 79)
			if(!lying_angle && prob(20))
				emote("me", 1, " is having trouble standing.")
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			if(prob(2))
				if(!lying_angle)
					emote("me", 1, " is having trouble standing.")
			adjust_stagger(3, FALSE, 3)
			add_slowdown(3)
			if(prob(20))
				to_chat(src, span_danger("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!"))
		if(80 to 119)
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			adjust_stagger(6, FALSE, 6)
			add_slowdown(6)
			if(prob(20))
				to_chat(src, span_danger("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!"))
		if(120 to 149)
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			adjust_stagger(9, FALSE, 9)
			add_slowdown(9)
			if(prob(20))
				to_chat(src, span_danger("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb", "You feel like you could die any moment now")]!"))
		if(150 to INFINITY)
			blur_eyes(2)
			stuttering = max(stuttering, 5)
			adjust_stagger(12, FALSE, 12)
			add_slowdown(12)
			if(prob(20))
				to_chat(src, span_danger("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb", "You feel like you could die any moment now")]!"))
			if(!COOLDOWN_CHECK(src, last_shock_effect)) //Check to see if we're on cooldown
				return
			if(!lying_angle)
				emote("me", 1, "can no longer stand, collapsing!")
			Paralyze(1 SECONDS)
			COOLDOWN_START(src, last_shock_effect, LIVING_SHOCK_EFFECT_COOLDOWN) //set the cooldown.
