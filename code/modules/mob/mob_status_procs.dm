
/mob/proc/Stun(amount)
	if(status_flags & CANSTUN)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		update_canmove()
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN)
		stunned = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustStunned(amount)
	if(status_flags & CANSTUN)
		stunned = max(stunned + amount,0)
		update_canmove()
	return

/mob/proc/KnockDown(amount, force)
	if((status_flags & CANKNOCKDOWN) || force)
		knocked_down = max(max(knocked_down,amount),0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/SetKnockeddown(amount)
	if(status_flags & CANKNOCKDOWN)
		knocked_down = max(amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/AdjustKnockeddown(amount)
	if(status_flags & CANKNOCKDOWN)
		knocked_down = max(knocked_down + amount,0)
		update_canmove()	//updates lying, canmove and icons
	return

/mob/proc/KnockOut(amount)
	if(status_flags & CANKNOCKOUT)
		knocked_out = max(max(knocked_out,amount),0)
		update_canmove()
	return

/mob/proc/SetKnockedout(amount)
	if(status_flags & CANKNOCKOUT)
		knocked_out = max(amount,0)
		update_canmove()
	return

/mob/proc/AdjustKnockedout(amount)
	if(status_flags & CANKNOCKOUT)
		knocked_out = max(knocked_out + amount,0)
		update_canmove()
	return

/mob/proc/Sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return

/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
	return

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
	return

/mob/proc/set_frozen(freeze = TRUE)
	frozen = freeze
	return TRUE

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	return

/mob/proc/adjust_drugginess(amount)
	return

/mob/proc/set_drugginess(amount)
	return

/mob/proc/Jitter(amount)
	jitteriness = CLAMP(jitteriness + amount,0, 1000)

/mob/proc/Dizzy(amount)
	return // For the time being, only carbons get dizzy.

/mob/proc/adjustEarDamage(damage = 0, deaf = 0)
	ear_damage = max(0, ear_damage + damage)
	ear_deaf = max((sdisabilities & DEAF|| ear_damage >= 100) ? 1 : 0, ear_deaf + deaf)

/mob/proc/setEarDamage(damage = null, deaf = null)
	if(!isnull(damage))
		ear_damage = damage
	if(!isnull(deaf))
		ear_deaf = max((sdisabilities & DEAF|| ear_damage >= 100) ? 1 : 0, deaf)

/mob/living/adjust_drugginess(amount)
	druggy = max(druggy + amount, 0)
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
	else
		clear_fullscreen("high")

/mob/living/set_drugginess(amount)
	druggy = max(amount, 0)
	if(druggy)
		overlay_fullscreen("high", /obj/screen/fullscreen/high)
	else
		clear_fullscreen("high")

/////////////////////////////////// TEMPERATURE ////////////////////////////////////

/mob/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(ISINRANGE(bodytemperature, min_temp, max_temp))
		bodytemperature = CLAMP(bodytemperature + amount,min_temp,max_temp)
