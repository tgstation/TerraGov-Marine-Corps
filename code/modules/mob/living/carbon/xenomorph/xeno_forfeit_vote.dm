/datum/xeno_forfeit_vote
	/// Is the vote to forfeit ongoing?
	var/active = FALSE
	/// Xenomorphs who've been offered the chance to vote.
	var/list/mob/living/carbon/xenomorph/voters = list()
	/// The amount of voters who agreed to forfeit.
	var/agreement_votes = 0
	/// The timer ID of the proc that'll end the vote.
	var/timer_id
	/// Cooldown between votes.
	COOLDOWN_DECLARE(forfeit_vote_cooldown)

/// Calls the vote to forfeit if possible.
/datum/xeno_forfeit_vote/proc/try_call_vote(mob/living/carbon/xenomorph/vote_initiator)
	if(!isnuclearwargamemode(SSticker.mode))
		to_chat(vote_initiator, span_notice("This is only available during Nuclear War."))
		return
	if(vote_initiator.hivenumber != XENO_HIVE_NORMAL)
		to_chat(vote_initiator, span_notice("Your hive is not allowed to forfeit."))
		return
	if(vote_initiator.hive.living_xeno_ruler != vote_initiator)
		to_chat(vote_initiator, span_notice("Only the ruler can start the vote to forfeit."))
		return
	if(SSmonitor.gamestate == SHUTTERS_CLOSED)
		to_chat(vote_initiator, span_notice("It is too early to call for a vote to forfeit."))
		return
	if(!COOLDOWN_FINISHED(src, forfeit_vote_cooldown))
		to_chat(vote_initiator, span_notice("It is too recent to call for an another vote to forfeit."))
		return
	if(active)
		to_chat(vote_initiator, span_notice("A vote to forfeit is already ongoing."))
		return
	if(SSticker.mode.round_finished)
		to_chat(vote_initiator, span_notice("The round has already ended."))
		return

	active = TRUE
	COOLDOWN_START(src, forfeit_vote_cooldown, 5 MINUTES)

	for(var/mob/living/carbon/xenomorph/possible_voter AS in GLOB.alive_xeno_list)
		if(!possible_voter.client)
			continue
		if(possible_voter.hivenumber != XENO_HIVE_NORMAL || (possible_voter.xeno_caste.caste_flags & CASTE_IS_A_MINION))
			continue
		voters += possible_voter
		INVOKE_NEXT_TICK(src, PROC_REF(handle_vote_alerts), possible_voter) // Giving everyone the ability to vote at the same time without holding the rest of the proc.
	timer_id = addtimer(CALLBACK(src, PROC_REF(conclude_vote)), 10 SECONDS, TIMER_UNIQUE)

/// Sends a tgui alert to agree or disagree with the forfeit vote.
/datum/xeno_forfeit_vote/proc/handle_vote_alerts(mob/living/carbon/xenomorph/voter)
	switch(tgui_alert(voter, "Do you agree to forfeit?", "Forfeit Vote", list("Yes", "No"), 10 SECONDS))
		if("Yes")
			agreement_votes += 1

/// Determines whether the vote has failed or succeeded based on the voters vs. agreement votes.
/datum/xeno_forfeit_vote/proc/conclude_vote()
	if(!active || SSticker.mode.round_finished)
		cleanup_variables()
		return
	if(length(voters) == agreement_votes)
		for(var/mob/living/carbon/xenomorph/voter AS in voters)
			to_chat(voter, span_notice("The vote has passed. [agreement_votes]/[length(voters)] agreed to forfeit."))
		cleanup_variables()

		var/datum/game_mode/infestation/nuclear_war/nuclearwar_mode = SSticker.mode
		if(nuclearwar_mode.round_stage == INFESTATION_MARINE_CRASHING)
			nuclearwar_mode.round_finished = MODE_INFESTATION_M_MINOR
			return
		nuclearwar_mode.round_finished = MODE_INFESTATION_M_MAJOR
		return
	for(var/mob/living/carbon/xenomorph/voter AS in voters)
		to_chat(voter, span_notice("The vote has failed. [agreement_votes]/[length(voters)] agreed to forfeit."))
	cleanup_variables()

/// Resets variables changed by the voting process.
/datum/xeno_forfeit_vote/proc/cleanup_variables()
	timer_id = null
	voters.Cut()
	agreement_votes = 0
	active = FALSE
