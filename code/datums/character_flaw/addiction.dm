
/mob/living/carbon/human
	var/datum/charflaw/charflaw

/mob/proc/sate_addiction()
	return

/mob/living/carbon/human/sate_addiction()
	if(istype(charflaw, /datum/charflaw/addiction))
		var/datum/charflaw/addiction/A = charflaw
//		remove_stress(list(/datum/stressevent/vice1,/datum/stressevent/vice2,/datum/stressevent/vice3))
		A.sated = TRUE
		A.time = initial(A.time) //reset roundstart sate offset to standard
		A.next_sate = world.time + A.time

/datum/charflaw/addiction
	var/next_sate = 0
	var/sated = TRUE
	var/time = 5 MINUTES
//	var/debuff = /datum/status_effect/debuff/addiction
	var/debuff //so heroin junkies can have big problems
	var/needsate_text
	var/unsate_time


/datum/charflaw/addiction/New()
	..()
	time = rand(6 MINUTES, 30 MINUTES)
	next_sate = world.time + time

/datum/charflaw/addiction/flaw_on_life(mob/user)
	if(!ishuman(user))
		return
	if(user.mind.antag_datums)
		for(var/datum/antagonist/D in user.mind.antag_datums)
			if(istype(D, /datum/antagonist/vampirelord) || istype(D, /datum/antagonist/werewolf) || istype(D, /datum/antagonist/skeleton) || istype(D, /datum/antagonist/zombie))
				return
	var/mob/living/carbon/human/H = user
	var/oldsated = sated
	if(oldsated)
		if(next_sate)
			if(world.time > next_sate)
				sated = FALSE
	if(sated != oldsated)
		unsate_time = world.time
		if(needsate_text)
			to_chat(user, "<span class='warning'>[needsate_text]</span>")
	if(!sated)
/*		switch(world.time - unsate_time)
			if(0 to 5 MINUTES)
				H.add_stress(/datum/stressevent/vice1)
			if(5 MINUTES to 15 MINUTES)
				H.add_stress(/datum/stressevent/vice2)
			if(15 MINUTES to INFINITY)
				H.add_stress(/datum/stressevent/vice3)*/
		H.add_stress(/datum/stressevent/vice)
		if(debuff)
			H.apply_status_effect(debuff)



/datum/status_effect/debuff/addiction
	id = "addiction"
	alert_type = /obj/screen/alert/status_effect/debuff/addiction
	effectedstats = list("endurance" = -1,"fortune" = -1)
	duration = 100


/obj/screen/alert/status_effect/debuff/addiction
	name = "Addiction"
	desc = ""
	icon_state = "debuff"


/// ALCOHOLIC

/datum/charflaw/addiction/alcoholic
	name = "Alcoholic"
	desc = "Drinking alcohol is my favorite thing."
	time = 30 MINUTES
	needsate_text = "Time for a drink."


/// JUNKIE

/datum/charflaw/addiction/junkie
	name = "Junkie"
	desc = "I need a real high to take the pain of this rotten world away."
	time = 30 MINUTES
	needsate_text = "Time to reach a new high."

/// Smoker

/datum/charflaw/addiction/smoker
	name = "Smoker"
	desc = "I need to smoke something to take the edge off."
	time = 30 MINUTES
	needsate_text = "Time for a flavorful smoke."

/// GOD-FEARING

/datum/charflaw/addiction/godfearing
	name = "Devout Follower"
	desc = "I need to pray to my Patron, their blessings are stronger."
	time = 25 MINUTES
	needsate_text = "Time to pray."


/// ALCOHOLIC

/datum/charflaw/addiction/lovefiend
	name = "Love-Fiend"
	desc = "I must make love!"
	time = 30 MINUTES
	needsate_text = "Time to get happy."
