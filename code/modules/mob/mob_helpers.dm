
// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
/proc/ishuman(A)
	if(istype(A, /mob/living/carbon/human))
		return 1
	return 0

/proc/iszombie(A)
	if(ishuman(A))
		var/mob/living/carbon/human/Z = A
		if(Z.species.name == "Zombie")
			return 1
		return 0
	return 0

/proc/ismonkey(A)
	if(A && istype(A, /mob/living/carbon/monkey))
		return 1
	return 0

/proc/isbrain(A)
	if(A && istype(A, /mob/living/brain))
		return 1
	return 0

/proc/isrobot(A)
	if(istype(A, /mob/living/silicon/robot))
		return 1
	return 0

/proc/isanimal(A)
	if(istype(A, /mob/living/simple_animal))
		return 1
	return 0

/proc/iscorgi(A)
	if(istype(A, /mob/living/simple_animal/corgi))
		return 1
	return 0

/proc/iscrab(A)
	if(istype(A, /mob/living/simple_animal/crab))
		return 1
	return 0

/proc/iscat(A)
	if(istype(A, /mob/living/simple_animal/cat))
		return 1
	return 0

/proc/ismouse(A)
	if(istype(A, /mob/living/simple_animal/mouse))
		return 1
	return 0

/proc/isbear(A)
	if(istype(A, /mob/living/simple_animal/hostile/bear))
		return 1
	return 0

/proc/iscarp(A)
	if(istype(A, /mob/living/simple_animal/hostile/carp))
		return 1
	return 0

/proc/isclown(A)
	if(istype(A, /mob/living/simple_animal/hostile/retaliate/clown))
		return 1
	return 0

/proc/isAI(A)
	if(istype(A, /mob/living/silicon/ai))
		return 1
	return 0

/proc/iscarbon(A)
	if(istype(A, /mob/living/carbon))
		return 1
	return 0

/proc/issilicon(A)
	if(istype(A, /mob/living/silicon))
		return 1
	return 0

/proc/isliving(A)
	if(istype(A, /mob/living))
		return 1
	return 0

proc/isobserver(A)
	if(istype(A, /mob/dead/observer))
		return 1
	return 0

proc/isorgan(A)
	if(istype(A, /datum/limb))
		return 1
	return 0

proc/isdeaf(A)
	if(istype(A, /mob))
		var/mob/M = A
		return (M.sdisabilities & DEAF) || M.ear_deaf
	return 0

proc/isnewplayer(A)
	if(istype(A, /mob/new_player))
		return 1
	return 0

proc/isXeno(A) //Xenomorph Hud Test APOPHIS 22MAY2015
	if(istype(A, /mob/living/carbon/Xenomorph))
		return 1
	return 0

proc/xeno_hivenumber(A)
	if(isXeno(A))
		var/mob/living/carbon/Xenomorph/X = A
		return X.hivenumber
	return 0

proc/isXenoBoiler(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Boiler))
		return 1
	return 0

proc/isXenoCarrier(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Carrier))
		return 1
	return 0

proc/isXenoCrusher(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))
		return 1
	return 0

proc/isXenoDrone(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Drone))
		return 1
	return 0

proc/isXenoHivelord(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Hivelord))
		return 1
	return 0

proc/isXenoHunter(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Lurker))
		return 1
	return 0

proc/isXenoDefender(A)
	if (istype(A, /mob/living/carbon/Xenomorph/Defender))
		return 1
	return 0

proc/isXenoLarva(A) //Xenomorph Larva Hud Test APOPHIS 22MAY2015
	if(istype(A, /mob/living/carbon/Xenomorph/Larva))
		return 1
	return 0

proc/isXenoPraetorian(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Praetorian))
		return 1
	return 0

proc/isXenoQueen(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Queen))
		return 1
	return 0

proc/isXenoRavager(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Ravager))
		return 1
	return 0

proc/isXenoRunner(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Runner))
		return 1
	return 0

proc/isXenoSentinel(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Sentinel))
		return 1
	return 0

proc/isXenoSpitter(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Spitter))
		return 1
	return 0

proc/isXenoWarrior(A)
	if (istype(A, /mob/living/carbon/Xenomorph/Warrior))
		return 1
	return 0

proc/isYautja(A)
	if(isHellhound(A))
		return 1 //They are always considered Yautja.
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.species.name == "Yautja")
			return 1
	return 0

proc/isSynth(A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.species.name == "Synthetic" || H.species.name == "Early Synthetic")
			return 1
	return 0

proc/ismaintdrone(A)
	if(istype(A,/mob/living/silicon/robot/drone))
		return 1
	return 0

proc/isHellhound(A)
	if(istype(A, /mob/living/carbon/hellhound))
		return 1
	return 0

proc/hasorgans(A)
	return ishuman(A)

/proc/hsl2rgb(h, s, l)
	return //TODO: Implement



/mob/proc/can_use_hands()
	return

/mob/proc/is_dead()
	return stat == DEAD

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI"))
		return 1
	return istype(src, /mob/living/silicon) || get_species() == "Machine"

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/get_gender()
	return gender




/*
	Miss Chance
*/

//TODO: Integrate defence zones and targeting body parts with the actual organ system, move these into organ definitions.

//The base miss chance for the different defence zones
var/list/global/base_miss_chance = list(
	"head" = 10,
	"chest" = 0,
	"groin" = 5,
	"l_leg" = 10,
	"r_leg" = 10,
	"l_arm" = 10,
	"r_arm" = 10,
	"l_hand" = 15,
	"r_hand" = 15,
	"l_foot" = 40,
	"r_foot" = 40,
	"eyes" = 20,
	"mouth" = 15,
)

//Used to weight organs when an organ is hit randomly (i.e. not a directed, aimed attack).
//Also used to weight the protection value that armour provides for covering that body part when calculating protection from full-body effects.
var/list/global/organ_rel_size = list(
	"head" = 15,
	"chest" = 70,
	"groin" = 30,
	"l_leg" = 25,
	"r_leg" = 25,
	"l_arm" = 25,
	"r_arm" = 25,
	"l_hand" = 7,
	"r_hand" = 7,
	"l_foot" = 10,
	"r_foot" = 10,
	"eyes" = 5,
	"mouth" = 15,
)

/proc/check_zone(zone)
	if(!zone)	return "chest"
	switch(zone)
		if("eyes")
			zone = "head"
		if("mouth")
			zone = "head"
	return zone

// Returns zone with a certain probability. If the probability fails, or no zone is specified, then a random body part is chosen.
// Do not use this if someone is intentionally trying to hit a specific body part.
// Use get_zone_with_miss_chance() for that.
/proc/ran_zone(zone, probability)
	if (zone)
		zone = check_zone(zone)
		if (prob(probability))
			return zone

	var/ran_zone = zone
	while (ran_zone == zone)
		ran_zone = pick (
			organ_rel_size["head"]; "head",
			organ_rel_size["chest"]; "chest",
			organ_rel_size["groin"]; "groin",
			organ_rel_size["l_arm"]; "l_arm",
			organ_rel_size["r_arm"]; "r_arm",
			organ_rel_size["l_leg"]; "l_leg",
			organ_rel_size["r_leg"]; "r_leg",
			organ_rel_size["l_hand"]; "l_hand",
			organ_rel_size["r_hand"]; "r_hand",
			organ_rel_size["l_foot"]; "l_foot",
			organ_rel_size["r_foot"]; "r_foot",
		)

	return ran_zone

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, var/mob/target, var/miss_chance_mod = 0)
	zone = check_zone(zone)

	// you can only miss if your target is standing and not restrained
	if(!target.buckled && !target.lying)
		var/miss_chance = 10
		if (zone in base_miss_chance)
			miss_chance = base_miss_chance[zone]
		miss_chance = max(miss_chance + miss_chance_mod, 0)
		if(prob(miss_chance))
			if(prob(70))
				return null
			return pick(base_miss_chance)

	return zone


/proc/stars(n, pr)
	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		if ((copytext(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext(te, p, p + 1))
		else
			t = text("[]*", t)
		p++
	return t

proc/slur(phrase)
	phrase = html_decode(phrase)
	var/leng=lentext(phrase)
	var/counter=lentext(phrase)
	var/newphrase=""
	var/newletter=""
	while(counter>=1)
		newletter=copytext(phrase,(leng-counter)+1,(leng-counter)+2)
		if(rand(1,3)==3)
			if(lowertext(newletter)=="o")	newletter="u"
			if(lowertext(newletter)=="s")	newletter="ch"
			if(lowertext(newletter)=="a")	newletter="ah"
			if(lowertext(newletter)=="c")	newletter="k"
		switch(rand(1,15))
			if(1,3,5,8)	newletter="[lowertext(newletter)]"
			if(2,4,6,15)	newletter="[uppertext(newletter)]"
			if(7)	newletter+="'"
			//if(9,10)	newletter="<b>[newletter]</b>"
			//if(11,12)	newletter="<big>[newletter]</big>"
			//if(13)	newletter="<small>[newletter]</small>"
		newphrase+="[newletter]";counter-=1
	return newphrase

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""//placed before the message. Not really sure what it's for.
	n = length(n)//length of the entire word
	var/p = null
	p = 1//1 is the start of any word
	while(p <= n)//while P, which starts at 1 is less or equal to N which is the length.
		var/n_letter = copytext(te, p, p + 1)//copies text from a certain distance. In this case, only one letter at a time.
		if (prob(80) && (ckey(n_letter) in list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z")))
			if (prob(10))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]-[n_letter]")//replaces the current letter with this instead.
			else
				if (prob(20))
					n_letter = text("[n_letter]-[n_letter]-[n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter]-[n_letter]")
		t = text("[t][n_letter]")//since the above is ran through for each letter, the text just adds up back to the original word.
		p++//for each letter p is increased to find where the next letter will be.
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)


proc/Gibberish(t, p)//t is the inputted message, and any value higher than 70 for p will cause letters to be replaced instead of added
	/* Turn text into complete gibberish! */
	var/returntext = ""
	for(var/i = 1, i <= length(t), i++)

		var/letter = copytext(t, i, i+1)
		if(prob(50))
			if(p >= 70)
				letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		returntext += letter

	return returntext


/proc/ninjaspeak(n)
/*
The difference with stutter is that this proc can stutter more than 1 letter
The issue here is that anything that does not have a space is treated as one word (in many instances). For instance, "LOOKING," is a word, including the comma.
It's fairly easy to fix if dealing with single letters but not so much with compounds of letters./N
*/
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = 1
	while(p <= n)
		var/n_letter
		var/n_mod = rand(1,4)
		if(p+n_mod>n+1)
			n_letter = copytext(te, p, n+1)
		else
			n_letter = copytext(te, p, p+n_mod)
		if (prob(50))
			if (prob(30))
				n_letter = text("[n_letter]-[n_letter]-[n_letter]")
			else
				n_letter = text("[n_letter]-[n_letter]")
		else
			n_letter = text("[n_letter]")
		t = text("[t][n_letter]")
		p=p+n_mod
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)


/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || M.shakecamera)
		return
	M.shakecamera = 1
	spawn(1)
		if(!M.client)
			return

		var/atom/oldeye=M.client.eye
		var/aiEyeFlag = 0
		if(istype(oldeye, /mob/aiEye))
			aiEyeFlag = 1

		var/x
		for(x=0; x<duration, x++)
			if(!M) return //Might have died/logged out before it ended

			if(!M.client)
				M.shakecamera = 0
				return

			if(aiEyeFlag)
				M.client.eye = locate(dd_range(1,oldeye.loc.x+rand(-strength,strength),world.maxx),dd_range(1,oldeye.loc.y+rand(-strength,strength),world.maxy),oldeye.loc.z)
			else
				M.client.eye = locate(dd_range(1,M.loc.x+rand(-strength,strength),world.maxx),dd_range(1,M.loc.y+rand(-strength,strength),world.maxy),M.loc.z)
			sleep(1)
		if(M.client)
			M.client.eye=oldeye //Mighta disconnected
		M.shakecamera = 0


/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.flags_item & ITEM_ABSTRACT )) || (src.r_hand && !( src.r_hand.flags_item & ITEM_ABSTRACT )) || (src.back || src.wear_mask)))
		return 1

	if((src.l_hand && !( src.l_hand.flags_item & ITEM_ABSTRACT )) || (src.r_hand && !( src.r_hand.flags_item & ITEM_ABSTRACT )))
		return 1

	return 0

//converts intent-strings into numbers and back
var/list/intents = list("help","disarm","grab","hurt")
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if("help")		return 0
			if("disarm")	return 1
			if("grab")		return 2
			else			return 3
	else
		switch(argument)
			if(0)			return "help"
			if(1)			return "disarm"
			if(2)			return "grab"
			else			return "hurt"

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(isrobot(src) || ismonkey(src))
		switch(input)
			if("help")
				a_intent = "help"
			if("hurt")
				a_intent = "hurt"
			if("right","left")
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)
	else
		switch(input)
			if("help","disarm","grab","hurt")
				a_intent = input
			if("right")
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if("left")
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)


	if(hud_used && hud_used.action_intent)
		hud_used.action_intent.icon_state = "intent_[a_intent]"


//can the mob be operated on?
/mob/proc/can_be_operated_on()
	return FALSE

//check if mob is lying down on something we can operate him on.
/mob/living/carbon/can_be_operated_on()
	if(!lying) return FALSE
	if(locate(/obj/machinery/optable, loc) || locate(/obj/structure/bed/roller, loc))
		return TRUE
	var/obj/structure/table/T = locate(/obj/structure/table, loc)
	if(T && !T.flipped) return TRUE

/mob/living/carbon/hellhound/can_be_operated_on()
	return FALSE

/mob/living/carbon/Xenomorph/can_be_operated_on()
	return FALSE


/mob/proc/is_mob_restrained()
	return

/mob/proc/is_mob_incapacitated(ignore_restrained)
	return (stat || stunned || knocked_down || knocked_out || (!ignore_restrained && is_mob_restrained()))


//returns how many non-destroyed legs the mob has (currently only useful for humans)
/mob/proc/has_legs()
	return 2

/mob/proc/get_eye_protection()
	return 0
