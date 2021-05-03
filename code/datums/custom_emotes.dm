/datum/custom_emote
	/// An id to be able to distinguish emotes
	var/id = 0
	///Message displayed when emote is used
	var/message = "" 
	/// Cooldown between two use of that emote. Every emote has its own coodldown
	var/cooldown = 5 SECONDS
	/// If this custom emote is a say or a me
	var/spoke_emote = TRUE

/// Run the custome emote
/datum/custom_emote/proc/run_custom_emote(mob/user)
	if(!message)
		return
	if(!can_run_custom_emote(user))
		return
	if(spoke_emote)
		user.say(message)
		return
	user.me_verb(message)

/// Check if the mob can currently use that emote
/datum/custom_emote/proc/can_run_custom_emote(mob/user)
	if(!istype(user))
		return
	if(!check_cooldown(user))
		to_chat(user, "<span class='notice'>You used that emote too recently.</span>")
		return FALSE
	if(user.stat > CONSCIOUS)
		to_chat(user, "<span class='notice'>You cannot use that emote while unconscious.</span>")
		return FALSE
	return TRUE

/// Check if that emote was used recently
/datum/custom_emote/proc/check_cooldown(mob/user)
	if(user.emotes_used && user.emotes_used[src] + cooldown > world.time)
		return FALSE
	if(!user.emotes_used)
		user.emotes_used = list()
	user.emotes_used[src] = world.time
	return TRUE
