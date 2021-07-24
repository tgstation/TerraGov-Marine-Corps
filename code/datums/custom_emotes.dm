/datum/custom_emote
	/// An id to be able to distinguish emotes
	var/id = 0
	///Message displayed when emote is used
	var/message = "" 
	/// Cooldown between two use of that emote. Every emote has its own coodldown
	var/cooldown = 5 SECONDS
	/// If this custom emote is a say or a me
	var/spoken_emote = TRUE

/// Run the custome emote
/datum/custom_emote/proc/run_custom_emote(mob/user)
	if(!message)
		return
	if(TIMER_COOLDOWN_CHECK(user, "custom_emotes[id]"))
		to_chat(user, "<span class='notice'>You used that emote too recently.</span>")
		return
	TIMER_COOLDOWN_START(user, "custom_emotes[id]", cooldown)
	if(user.stat > CONSCIOUS)
		to_chat(user, "<span class='notice'>You cannot use that emote while unconscious.</span>")
		return
	if(spoken_emote)
		user.say(message)
		return
	user.me_verb(message)
