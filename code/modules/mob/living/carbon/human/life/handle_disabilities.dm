//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_disabilities()

	if(disabilities & EPILEPSY)
		if((prob(1) && knocked_out < 1))
			visible_message("<span class='danger'>\The [src] starts having a seizure!</span>", \
			"<span class='danger'>You start having a seizure!</span>", null, 5)
			KnockOut(10)
			make_jittery(1000)
			return

	if(disabilities & COUGHING)
		if((prob(5) && knocked_out <= 1))
			drop_held_item()
			spawn()
				emote("cough")
			return

	if(disabilities & TOURETTES)
		speech_problem_flag = 1
		if((prob(10) && knocked_out <= 1))
			Stun(10)
			spawn()
				switch(rand(1, 3))
					if(1)
						emote("twitch")
					if(2 to 3)
						say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]")
				var/old_x = pixel_x
				var/old_y = pixel_y
				pixel_x += rand(-2, 2)
				pixel_y += rand(-1, 1)
				sleep(2)
				pixel_x = old_x
				pixel_y = old_y
				return

	if(disabilities & NERVOUS)
		speech_problem_flag = 1
		if(prob(10))
			stuttering = max(10, stuttering)
			return

	if(stat != DEAD)
		var/roll = rand(0, 200)
		switch(roll)
			if(0 to 3)
				if(getBrainLoss() >= 5)
					custom_pain("Your head feels numb and painful.")
			if(4 to 6)
				if(getBrainLoss() >= 15 && eye_blurry <= 0)
					src << "<span class='danger'>It becomes hard to see for some reason.</span>"
					eye_blurry = 10
			if(7 to 9)
				if(getBrainLoss() >= 35 && (hand && get_held_item()))
					src << "<span class='danger'>Your hand won't respond properly, you drop what you're holding.</span>"
					drop_held_item()
			if(10 to 12)
				if(getBrainLoss() >= 50 && !lying)
					src << "<span class='danger'>Your legs won't respond properly, you fall down.</span>"
					resting = 1
