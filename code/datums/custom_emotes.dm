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
	if(TIMER_COOLDOWN_RUNNING(user, "custom_emotes[id]"))
		user.balloon_alert(user, "used that emote too recently!")
		return
	TIMER_COOLDOWN_START(user, "custom_emotes[id]", cooldown)
	if(user.stat > CONSCIOUS)
		to_chat(user, span_notice("You cannot use that emote while unconscious."))
		return
	if(spoken_emote)
		user.say(message)
		return
	user.me_verb(message)
