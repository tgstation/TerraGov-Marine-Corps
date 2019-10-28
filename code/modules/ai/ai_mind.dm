//A mind that houses a personality and attitudes
//Influences decisions based on node weights and later on, ability activations (xenomorphs and humans)

/datum/ai_mind

/datum/ai_mind/proc/action_completed(reason) //Parent component action state was completed, let's give it something else to do
	mind.action_completed(reason)
	switch(reason)
		if(FINISHED_MOVE)
			action_state = new/datum/action_state/random_move(src)
