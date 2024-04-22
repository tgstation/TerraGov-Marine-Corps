/datum/objective/bandit
	name = "bandit"
	explanation_text = "Feed valuables to the idol."

/datum/objective/bandit/check_completion()
	if(SSticker.mode)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(C.banditcontrib >= C.banditgoal)
			return TRUE

/datum/objective/bandit/update_explanation_text()
	..()
	if(SSticker.mode)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(C)
			explanation_text = "Feed [C.banditgoal] mammon to an idol of greed."
		else
			explanation_text = "Pray to ZIZO."


/datum/objective/delf
	name = "delf"
	explanation_text = "Feed honeys to the mother."

/datum/objective/delf/check_completion()
	if(SSticker.mode)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(C.delfcontrib >= C.delfgoal)
			return TRUE

/datum/objective/delf/update_explanation_text()
	..()
	if(SSticker.mode)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(C)
			explanation_text = "Feed [C.delfgoal] honeys to the mother."
		else
			explanation_text = "Pray to ZIZO."

/datum/objective/rt_maniac
	name = "slaying"
	explanation_text = "Mark pieces of flesh and leave them to be discovered. Have at least 4 different people witness your crimes."
	martyr_compatible = 0
	triumph_count = 10
	var/people_seen[0]

/datum/objective/rt_maniac/check_completion()
	if(people_seen.len >= 4)
		return TRUE

/datum/objective/werewolf
	name = "conquer"
	explanation_text = "Destroy all elder vampires in ROGUETOWN. I can sniff them in my true form."
	team_explanation_text = ""
	triumph_count = 5

/datum/objective/werewolf/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.vampire_werewolf() == "werewolf")
			return TRUE

/datum/objective/vampire
	name = "conquer"
	explanation_text = "Destroy all alpha werewolves in ROGUETOWN. I can detect them in my true form."
	team_explanation_text = ""
	triumph_count = 5

/datum/objective/vampire/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.vampire_werewolf() == "vampire")
			return TRUE
