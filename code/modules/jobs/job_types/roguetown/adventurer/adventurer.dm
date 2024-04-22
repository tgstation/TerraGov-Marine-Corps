GLOBAL_LIST_EMPTY(billagerspawns)

GLOBAL_VAR_INIT(adventurer_hugbox_duration, 20 SECONDS)
GLOBAL_VAR_INIT(adventurer_hugbox_duration_still, 3 MINUTES)

/datum/job/roguetown/adventurer
	title = "Adventurer"
	flag = ADVENTURER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 75
	spawn_positions = 75
	allowed_races = list("Humen",
	"Elf",
	"Half-Elf",
	"Dwarf",
	"Tiefling",
	"Dark Elf",
	"Aasimar"
	)
	tutorial = "Hero of nothing, adventurer by trade. Whatever led you to this fate is up to the wind to decide, and you've never fancied yourself for much other than the thrill. Someday your pride is going to catch up to you, and you're going to find out why most men don't end up in the annals of history."


	outfit = null
	outfit_female = null

	display_order = JDO_ADVENTURER
	show_in_credits = FALSE
	min_pq = -4
	
	var/isvillager = FALSE
	var/ispilgrim = FALSE

/datum/job/roguetown/adventurer/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
		H.Stun(100)
		if(!H.possibleclass)
			H.possibleclass = list()
		if(GLOB.adventurer_hugbox_duration)
			///FOR SOME RETARDED FUCKING REASON THIS REFUSED TO WORK WITHOUT A FUCKING TIMER IT JUST FUCKED SHIT UP
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_start)), 1)
		var/list/classes = GLOB.adv_classes.Copy()
		var/list/special_classes = list()
		var/classamt = 5
		if(M.client)
			// For every 5 positive PQ points, grant an extra choice for Adventurer classes
			var/pq = get_playerquality(M.client.ckey, FALSE)
			if(pq > 0)
				classamt += floor(pq / 5)
			if(M.client.patreonlevel() >= 1)
				classamt = 999
		// Increase available classes for pilgrims
		if(ispilgrim)
			classamt = 15
		if(isvillager)
			GLOB.billagerspawns |= H
#ifdef TESTSERVER
		classamt = 999
#endif
		for(var/I in shuffle(classes))
			var/datum/advclass/A = I
			if(!(H.gender in A.allowed_sexes))
				testing("[A.name] fail11")
				continue
			if(!(H.dna.species.name in A.allowed_races))
				testing("[A.name] fail22")
				continue
			if(!(H.age in A.allowed_ages))
				testing("[A.name] fail33")
				continue
			if(A.maxchosen > -1)
				if(A.amtchosen >= A.maxchosen)
					testing("[A.name] fail9")
					continue

			if((!isvillager && !ispilgrim) && (A.isvillager || A.ispilgrim)) //adventurer
				continue

			if(isvillager && !A.isvillager) //towner
				continue

			if(ispilgrim && !A.ispilgrim) //pilgrim
				continue

			if(A.plevel_req > M.client.patreonlevel())
				testing("[A.name] fail6")
				continue
			if(A.special_req)
				special_classes += A
				testing("[A.name] fail5")
				continue
			if(CONFIG_GET(flag/usewhitelist))
				if(M.client)
					if((!M.client.whitelisted()) && A.whitelist_req)
						testing("[A.name] fail4")
						continue
			if(H.possibleclass.len >= classamt)
				testing("[A.name] fail3")
				continue
			var/the_prob = A.pickprob
#ifdef TESTSERVER
			the_prob = 100
#endif
			if(M.client.patreonlevel() >= 3)
				the_prob = 100
			if(prob(the_prob))
				testing("[A.name] SUC1")
				H.possibleclass += A

		for(var/X in special_classes)
			var/datum/advclass/A = X
			if(!A.special_req)
				continue
			if(!M.client)
				continue
			else
				if(find_class_json(A.name, M.client.ckey))
					if(prob(A.pickprob))
						H.possibleclass += A
						continue

/client
	var/whitelisted = 2
	var/blacklisted = 2

/client/proc/whitelisted()
	if(whitelisted != 2)
		return whitelisted
	else
		if(check_whitelist(ckey))
			whitelisted = 1
		else
			whitelisted = 0
		return whitelisted

/client/proc/blacklisted()
	if(blacklisted != 2)
		return blacklisted
	else
		if(check_blacklist(ckey))
			blacklisted = 1
		else
			blacklisted = 0
		return blacklisted

/proc/find_class_json(name, keyy)
	if(!name || !keyy)
		return
	var/json_file = file("[global.config.directory]/roguetown/donatorclasses.json")
	if(fexists(json_file))
		var/list/configuration = json_decode(file2text(json_file))
		var/list/donatorss = configuration["[name]"]
		if(isnull(donatorss))
			donatorss = list()
		for(var/X in donatorss)
			X = ckey(X)
			if(X == keyy)
				return TRUE

/mob/living/carbon/human/proc/advsetup()
	if(!advsetup)
		testing("RETARD")
		return TRUE
	var/blacklisted = check_blacklist(ckey)
	if(possibleclass.len && !blacklisted)
		var/datum/advclass/C = input(src, "What is my class?", "Adventure") as null|anything in sortNames(possibleclass)
		if(C && advsetup)
			if(C.maxchosen > -1)
				for(var/datum/advclass/A in GLOB.adv_classes)
					if(A.type == C.type)
						if(A.amtchosen >= A.maxchosen)
							possibleclass -= C
							to_chat(src, "<span class='warning'>Not enough slots for [C] left! Choose something different.</span>")
							return FALSE
						else
							A.amtchosen++
			if(alert(src, "[C.name]\n[C.tutorial]", "Are you sure?", "Yes", "No") != "Yes")
				return FALSE
			if(advsetup)
				advsetup = 0
				C.equipme(src)
				invisibility = 0
				cure_blind("advsetup")
				return TRUE
	else
		testing("RETARD2")
		advsetup = 0
		invisibility = 0
		cure_blind("advsetup")
		return TRUE

/mob/living/carbon/human/proc/adv_hugboxing_start()
	to_chat(src, "<span class='warning'>I will be in danger once I start moving.</span>")
	status_flags |= GODMODE
	ADD_TRAIT(src, TRAIT_PACIFISM, ADVENTURER_HUGBOX_TRAIT)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(adv_hugboxing_moved))
	//Lies, it goes away even if you don't move after enough time
	if(GLOB.adventurer_hugbox_duration_still)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_end)), GLOB.adventurer_hugbox_duration_still)

/mob/living/carbon/human/proc/adv_hugboxing_moved()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	to_chat(src, "<span class='danger'>I have [DisplayTimeText(GLOB.adventurer_hugbox_duration)] to begone!</span>")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/carbon/human, adv_hugboxing_end)), GLOB.adventurer_hugbox_duration)

/mob/living/carbon/human/proc/adv_hugboxing_end()
	if(QDELETED(src))
		return
	//hugbox already ended
	if(!(status_flags & GODMODE))
		return
	status_flags &= ~GODMODE
	REMOVE_TRAIT(src, TRAIT_PACIFISM, ADVENTURER_HUGBOX_TRAIT)
	to_chat(src, "<span class='danger'>My joy is gone! Danger surrounds me.</span>")
