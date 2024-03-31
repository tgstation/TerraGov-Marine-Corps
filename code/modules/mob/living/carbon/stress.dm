/mob/proc/add_stress(event)
	return FALSE

/mob/proc/remove_stress(event)
	return FALSE

/mob/proc/update_stress()
	return FALSE

/mob/proc/adjust_stress(amt)
	return FALSE

/mob/proc/has_stress(event)
	return FALSE

/mob/living/carbon
	var/stress = 0
	var/list/stress_timers = list()
	var/oldstress = 0
	var/stressbuffer = 0
	var/list/negative_stressors = list()
	var/list/positive_stressors = list()

/mob/living/carbon/adjust_stress(amt)
	stressbuffer = stressbuffer + amt
	stress = stress + stressbuffer
	stressbuffer = 0
	if(stress > 30)
		stressbuffer = 30 - stress
		stress = 30
	if(stress < 0)
		stressbuffer = stress
		stress = 0

/mob/living/carbon/update_stress()
	if(HAS_TRAIT(src, TRAIT_NOMOOD))
		stress = 0
//		if(hud_used)
//			if(hud_used.stressies)
//				hud_used.stressies.update_icon(stress)
		return
	for(var/datum/stressevent/D in negative_stressors)
		if(D.timer)
			if(world.time > D.time_added + D.timer)
				adjust_stress(-1*D.stressadd)
				negative_stressors -= D
				qdel(D)
	for(var/datum/stressevent/D in positive_stressors)
		if(D.timer)
			if(world.time > D.time_added + D.timer)
				adjust_stress(-1*D.stressadd)
				positive_stressors -= D
				qdel(D)
	if(stress != oldstress)
		if(stress > oldstress)
			to_chat(src, "<span class='red'>I gain stress.</span>")
		else
			to_chat(src, "<span class='green'>I gain peace.</span>")
	oldstress = stress
	if(hud_used)
		if(hud_used.stressies)
			hud_used.stressies.update_icon()
	if(stress > 15)
		change_stat("fortune", -1*round((stress-16)/2), "stress")
	else
		change_stat("fortune", 0, "stress")

/mob/living/carbon/has_stress(event)
	var/amount
	for(var/datum/stressevent/D in negative_stressors)
		if(D.type == event)
			amount++
	for(var/datum/stressevent/D in positive_stressors)
		if(D.type == event)
			amount++
	return amount

/mob/living/carbon/add_stress(event)
	if(HAS_TRAIT(src, TRAIT_NOMOOD))
		return FALSE
	var/datum/stressevent/N = new event()
	var/countofus = 0
	if(N.stressadd > 0)
		for(var/datum/stressevent/D in negative_stressors)
			if(D.type == event)
				countofus++
				D.time_added = world.time
				if(N.stressadd > D.stressadd)
					D.stressadd = N.stressadd
	else
		for(var/datum/stressevent/D in positive_stressors)
			if(D.type == event)
				countofus++
				D.time_added = world.time
				if(N.stressadd < D.stressadd)
					D.stressadd = N.stressadd
	if(N.max_stacks) //we need to check if we should be added
		if(countofus >= N.max_stacks)
			return
	else //we refreshed the timer
		if(countofus >= 1)
			return
	if(N.stressadd > 0)
		negative_stressors += N
	else
		positive_stressors += N
	adjust_stress(N.stressadd)
	return TRUE

/mob/living/carbon/remove_stress(event)
	if(HAS_TRAIT(src, TRAIT_NOMOOD))
		return FALSE
	var/list/eventL
	if(islist(event))
		eventL = event
	for(var/datum/stressevent/D in negative_stressors)
		if(eventL)
			if(D.type in eventL)
				adjust_stress(-1*D.stressadd)
				negative_stressors -= D
				qdel(D)
		else
			if(D.type == event)
				adjust_stress(-1*D.stressadd)
				negative_stressors -= D
				qdel(D)
	for(var/datum/stressevent/D in positive_stressors)
		if(eventL)
			if(D.type in eventL)
				adjust_stress(-1*D.stressadd)
				positive_stressors -= D
				qdel(D)
		else
			if(D.type == event)
				adjust_stress(-1*D.stressadd)
				positive_stressors -= D
				qdel(D)
	return TRUE

/datum/stressevent
	var/timer
	var/stressadd
	var/desc
	var/time_added
	var/max_stacks = 0 //if higher than 0, can stack

/datum/stressevent/proc/get_desc(mob/living/user)
	return desc

/datum/stressevent/test
	timer = 5 SECONDS
	stressadd = 3
	desc = "<span class='red'>This is a test event.</span>"

/datum/stressevent/testr
	timer = 5 SECONDS
	stressadd = -3
	desc = "<span class='green'>This is a test event.</span>"

#ifdef TESTSERVER
/client/verb/add_stress()
	set category = "DEBUGTEST"
	set name = "stressBad"
	if(mob)
		mob.add_stress(/datum/stressevent/test)
/client/verb/remove_stress()
	set category = "DEBUGTEST"
	set name = "stressGood"
	if(mob)
		mob.add_stress(/datum/stressevent/testr)

/client/verb/filter1()
	set category = "DEBUGTEST"
	set name = "TestFilter1"
	if(mob)
		mob.remove_client_colour(/datum/client_colour/test1)
		mob.remove_client_colour(/datum/client_colour/test2)
		mob.remove_client_colour(/datum/client_colour/test3)
		mob.add_client_colour(/datum/client_colour/test1)
/client/verb/filter2()
	set category = "DEBUGTEST"
	set name = "TestFilter2"
	if(mob)
		mob.remove_client_colour(/datum/client_colour/test1)
		mob.remove_client_colour(/datum/client_colour/test2)
		mob.remove_client_colour(/datum/client_colour/test3)
		mob.add_client_colour(/datum/client_colour/test2)
/client/verb/filter3()
	set category = "DEBUGTEST"
	set name = "TestFilter3"
	if(mob)
		mob.remove_client_colour(/datum/client_colour/test1)
		mob.remove_client_colour(/datum/client_colour/test2)
		mob.remove_client_colour(/datum/client_colour/test3)
		mob.add_client_colour(/datum/client_colour/test3)

/client/verb/do_undesaturate()
	set category = "DEBUGTEST"
	set name = "TestFilterOff"
	if(mob)
		mob.remove_client_colour(/datum/client_colour/test1)
		mob.remove_client_colour(/datum/client_colour/test2)
		mob.remove_client_colour(/datum/client_colour/test3)

/client/verb/do_flash()
	set category = "DEBUGTEST"
	set name = "doflash"
	if(mob)
		var/turf/T = get_turf(mob)
		if(T)
			T.flash_lighting_fx(30)
#endif

//**********************************************
//************** NEGATIVE STRESS ****************
//*************************************************

/datum/stressevent/vice
	timer = 5 MINUTES
	stressadd = 3
	desc = list("<span class='red'>I don't indulge my vice.</span>","<span class='red'>I need to sate my vice.</span>")

/*
/datum/stressevent/failcraft
	timer = 15 SECONDS
	stressadd = 1
	max_stacks = 10
	desc = "<span class='red'>I've failed to craft something.</span>"
*/
/datum/stressevent/miasmagas
	timer = 10 SECONDS
	stressadd = 1
	desc = "<span class='red'>Smells like death here.</span>"

/datum/stressevent/peckish
	timer = 10 MINUTES
	stressadd = 1
	desc = "<span class='red'>I'm peckish.</span>"

/datum/stressevent/hungry
	timer = 10 MINUTES
	stressadd = 2
	desc = "<span class='red'>I'm hungry.</span>"

/datum/stressevent/starving
	timer = 10 MINUTES
	stressadd = 3
	desc = "<span class='red'>I'm starving.</span>"

/datum/stressevent/drym
	timer = 10 MINUTES
	stressadd = 1
	desc = "<span class='red'>I'm a little thirsty.</span>"

/datum/stressevent/thirst
	timer = 10 MINUTES
	stressadd = 2
	desc = "<span class='red'>I'm thirsty.</span>"

/datum/stressevent/parched
	timer = 10 MINUTES
	stressadd = 3
	desc = "<span class='red'>I'm going to die of thirst.</span>"

/datum/stressevent/dismembered
	timer = 40 MINUTES
	stressadd = 5
	//desc = "<span class='red'>I've lost a limb.</span>"
	desc = null

/datum/stressevent/dwarfshaved
	timer = 40 MINUTES
	stressadd = 6
	desc = "<span class='red'>I'd rather cut my own throat than my beard.</span>"

/datum/stressevent/viewdeath
	timer = 1 MINUTES
	stressadd = 1
//	desc = "<span class='red'>Death...</span>"

/datum/stressevent/viewdeath/get_desc(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.dna?.species)
			return "<span class='red'>Another [H.dna.species.id] perished.</span>"
	return desc


/datum/stressevent/viewdismember
	timer = 20 MINUTES
	max_stacks = 10
	stressadd = 2
//	desc = "<span class='red'>Butchery.</span>"


/datum/stressevent/fviewdismember
	timer = 1 MINUTES
	max_stacks = 10
	stressadd = 1
//	desc = "<span class='red'>I saw something horrible!</span>"

/datum/stressevent/viewgib
	timer = 5 MINUTES
	stressadd = 2
//	desc = "<span class='red'>I saw something ghastly.</span>"

/datum/stressevent/bleeding
	timer = 2 MINUTES
	stressadd = 1
	desc = list("<span class='red'>I think I'm bleeding.</span>","<span class='red'>I'm bleeding.</span>")

/datum/stressevent/painmax
	timer = 1 MINUTES
	stressadd = 2
	desc = "<span class='red'>THE PAIN!</span>"

/datum/stressevent/freakout
	timer = 15 SECONDS
	stressadd = 2
	desc = "<span class='red'>I'm panicing!</span>"

/datum/stressevent/felldown
	timer = 1 MINUTES
	stressadd = 1
//	desc = "<span class='red'>I fell. I'm a fool.</span>"

/datum/stressevent/burntmeal
	timer = 2 MINUTES
	stressadd = 2
	desc = "<span class='red'>YUCK!</span>"

/datum/stressevent/rotfood
	timer = 2 MINUTES
	stressadd = 4
	desc = "<span class='red'>YUCK!</span>"

/datum/stressevent/psycurse
	timer = 5 MINUTES
	stressadd = 5
	desc = "<span class='red'>Oh no! I've received divine punishment!</span>"

/datum/stressevent/virginchurch
	timer = 999 MINUTES
	stressadd = 10
	desc = "<span class='red'>I have broken my oath of chastity to The Gods!</span>"

/datum/stressevent/badmeal
	timer = 3 MINUTES
	stressadd = 2
	desc = "<span class='red'>It tastes VILE!</span>"

/datum/stressevent/vomit
	timer = 3 MINUTES
	stressadd = 2
	max_stacks = 3
	desc = "<span class='red'>I puked!</span>"

/datum/stressevent/vomitself
	timer = 3 MINUTES
	stressadd = 2
	max_stacks = 3
	desc = "<span class='red'>I puked on myself!</span>"

/datum/stressevent/cumbad
	timer = 5 MINUTES
	stressadd = 5
	desc = "<span class='red'>I was violated.</span>"

/datum/stressevent/cumcorpse
	timer = 1 MINUTES
	stressadd = 20
	desc = "<span class='red'>What have I done?</span>"

/datum/stressevent/blueb
	timer = 1 MINUTES
	stressadd = 2
	desc = "<span class='red'>My loins ache!</span>"

/datum/stressevent/delf
	timer = 1 MINUTES
	stressadd = 1
	desc = "<span class='red'>A loathesome dark elf.</span>"

/datum/stressevent/tieb
	timer = 1 MINUTES
	stressadd = 1
	desc = "<span class='red'>Helldweller... better stay away.</span>"

/datum/stressevent/paracrowd
	timer = 15 SECONDS
	stressadd = 2
	desc = "<span class='red'>There are too many people who don't look like me here.</span>"

/datum/stressevent/parablood
	timer = 15 SECONDS
	stressadd = 3
	desc = "<span class='red'>There is so much blood here.. it's like a battlefield!</span>"

/datum/stressevent/parastr
	timer = 2 MINUTES
	stressadd = 2
	desc = "<span class='red'>That beast is stronger.. and might easily kill me!</span>"

/datum/stressevent/paratalk
	timer = 2 MINUTES
	stressadd = 2
	desc = "<span class='red'>They are plotting against me in evil tongues..</span>"

/datum/stressevent/coldhead
	timer = 60 SECONDS
	stressadd = 1
//	desc = "<span class='red'>My head is cold and ugly.</span>"

/datum/stressevent/sleeptime
	timer = 0
	stressadd = 1
	desc = "<span class='red'>I'm tired.</span>"

/datum/stressevent/trainsleep
	timer = 0
	stressadd = 1
	desc = "<span class='red'>My muscles ache.</span>"

/datum/stressevent/tortured
	stressadd = 3
	max_stacks = 5
	desc = "<span class='red'>I'm broken.</span>"
	timer = 60 SECONDS

/datum/stressevent/confessed
	stressadd = 3
	desc = "<span class='red'>I've confessed to sin.</span>"
	timer = 15 MINUTES

/datum/stressevent/confessedgood
	stressadd = 1
	desc = "<span class='red'>I've confessed to sin, it feels good.</span>"
	timer = 15 MINUTES

/datum/stressevent/maniac
	stressadd = 4
	desc = "<span class='red'>THE MANIAC COULD BE HERE!</span>"
	timer = 30 MINUTES

/datum/stressevent/drankrat
	stressadd = 1
	desc = "<span class='red'>I drank from a lesser creature.</span>"
	timer = 1 MINUTES

/datum/stressevent/lowvampire
	stressadd = 1
	desc = "<span class='red'>I'm dead... what comes next?</span>"

/datum/stressevent/oziumoff
	stressadd = 20
	desc = "<span class='blue'>I need another hit.</span>"
	timer = 1 MINUTES

//**********************************************
//************** POSITIVE STRESS ****************
//**********************************************

/datum/stressevent/viewsinpunish
	timer = 5 MINUTES
	stressadd = -2
	desc = "<span class='green'>I saw a sinner get punished!</span>"

/datum/stressevent/viewexecution
	timer = 5 MINUTES
	stressadd = -2
	desc = "<span class='green'>I saw a lawbreaker get punished!</span>"

/datum/stressevent/psyprayer
	timer = 30 MINUTES
	stressadd = -2
	desc = "<span class='green'>The Gods smiles upon me.</span>"

/datum/stressevent/cumok
	timer = 5 MINUTES
	stressadd = -1
//	desc = "<span class='green'>I came.</span>"

/datum/stressevent/cummid
	timer = 5 MINUTES
	stressadd = -2
//	desc = "<span class='green'>I came, and it was great.</span>"

/datum/stressevent/cumgood
	timer = 5 MINUTES
	stressadd = -3
//	desc = "<span class='green'>I came, and it was wonderful.</span>"

/datum/stressevent/cummax
	timer = 5 MINUTES
	stressadd = -4
//	desc = "<span class='green'>I came, and it was incredible.</span>"

/datum/stressevent/cumlove
	timer = 5 MINUTES
	stressadd = -5
//	desc = "<span class='green'>I made love.</span>"

/datum/stressevent/cumpaingood
	timer = 5 MINUTES
	stressadd = -5
	desc = "<span class='green'>Pain makes it better.</span>"

/datum/stressevent/joke
	timer = 30 MINUTES
	stressadd = -5
//	desc = "<span class='green'>I heard a good joke.</span>"

/datum/stressevent/tragedy
	timer = 30 MINUTES
	stressadd = -5
//	desc = "<span class='green'>Life isn't so bad after all.</span>"

/datum/stressevent/blessed
	timer = 60 MINUTES
	stressadd = -5
	desc = "<span class='green'>I feel a soothing.</span>"

/datum/stressevent/triumph
	timer = 60 MINUTES
	stressadd = -10
	desc = "<span class='green'>I remember a TRIUMPH.</span>"

/datum/stressevent/drunk
	timer = 1 MINUTES
	stressadd = -1
//	desc = list("<span class='green'>Alcohol eases the pain.</span>","<span class='green'>Alcohol, my true friend.</span>")

/datum/stressevent/pweed
	timer = 1 MINUTES
	stressadd = -1
//	desc = list("<span class='green'>A relaxing smoke.</span>","<span class='green'>A flavorful smoke.</span>")

/datum/stressevent/weed
	timer = 5 MINUTES
	stressadd = -4
//	desc = "<span class='blue'>I love you sweet leaf.</span>"

/datum/stressevent/high
	timer = 5 MINUTES
	stressadd = -4
//	desc = "<span class='blue'>I'm so high, don't take away my sky.</span>"

/datum/stressevent/hug
	timer = 30 MINUTES
	stressadd = -1
//	desc = "<span class='green'>Somebody gave me a nice hug.</span>"

/datum/stressevent/stuffed
	timer = 20 MINUTES
	stressadd = -3
	desc = "<span class='green'>I'm stuffed! Feels good.</span>"

/datum/stressevent/goodfood
	timer = 10 MINUTES
	stressadd = -2
	desc = list("<span class='green'>A meal fit for a god!</span>","<span class='green'>Delicious!</span>")

/datum/stressevent/prebel
	timer = 5 MINUTES
	stressadd = -5
	desc = "<span class='green'>Down with the tyranny!</span>"

/datum/stressevent/music
	timer = 1 MINUTES
	stressadd = -1
	desc = "<span class='green'>The music is relaxing.</span>"
/datum/stressevent/music/two
	stressadd = -2
	desc = "<span class='green'>The music is very relaxing.</span>"
/datum/stressevent/music/three
	stressadd = -3
	desc = "<span class='green'>The music saps my stress.</span>"
/datum/stressevent/music/four
	stressadd = -4
	desc = "<span class='green'>The music is heavenly.</span>"
	timer = 10 MINUTES
/datum/stressevent/music/five
	stressadd = -5
	timer = 10 MINUTES
	desc = "<span class='green'>The music is strummed by an angel.</span>"
/datum/stressevent/music/six
	stressadd = -6
	timer = 10 MINUTES
	desc = "<span class='green'>The music is a blessing from Eora.</span>"

/datum/stressevent/vblood
	stressadd = -5
	desc = "<span class='boldred'>Virgin blood!</span>"
	timer = 5 MINUTES

/datum/stressevent/bathwater
	stressadd = -1
	desc = "<span class='blue'>Relaxing.</span>"
	timer = 1 MINUTES

/datum/stressevent/ozium
	stressadd = -99
	desc = "<span class='blue'>I've taken a hit and entered a painless world.</span>"
	timer = 1 MINUTES

/datum/stressevent/moondust
	stressadd = -5
	desc = "<span class='green'>Moondust surges through me.</span>"

/datum/stressevent/moondust_purest
	stressadd = -6
	desc = "<span class='green'>PUREST moondust surges through me!</span>"
