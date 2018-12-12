
// fun if you want to typecast humans/monkeys/etc without writing long path-filled lines.
/proc/ishuman(A)
	if(istype(A, /mob/living/carbon/human))
		return TRUE
	return FALSE

/proc/iszombie(A)
	if(ishuman(A))
		var/mob/living/carbon/human/Z = A
		if(Z.species.name == "Zombie")
			return TRUE
		return FALSE
	return FALSE

/proc/ismonkey(A)
	if(A && istype(A, /mob/living/carbon/monkey))
		return TRUE
	return FALSE

/proc/isbrain(A)
	if(A && istype(A, /mob/living/brain))
		return TRUE
	return FALSE

/proc/isrobot(A)
	if(istype(A, /mob/living/silicon/robot))
		return TRUE
	return FALSE

/proc/isanimal(A)
	if(istype(A, /mob/living/simple_animal))
		return TRUE
	return FALSE

/proc/iscorgi(A)
	if(istype(A, /mob/living/simple_animal/corgi))
		return TRUE
	return FALSE

/proc/iscrab(A)
	if(istype(A, /mob/living/simple_animal/crab))
		return TRUE
	return FALSE

/proc/iscat(A)
	if(istype(A, /mob/living/simple_animal/cat))
		return TRUE
	return FALSE

/proc/ismouse(A)
	if(istype(A, /mob/living/simple_animal/mouse))
		return TRUE
	return FALSE

/proc/isbear(A)
	if(istype(A, /mob/living/simple_animal/hostile/bear))
		return TRUE
	return FALSE

/proc/iscarp(A)
	if(istype(A, /mob/living/simple_animal/hostile/carp))
		return TRUE
	return FALSE

/proc/isclown(A)
	if(istype(A, /mob/living/simple_animal/hostile/retaliate/clown))
		return TRUE
	return FALSE

/proc/isAI(A)
	if(istype(A, /mob/living/silicon/ai))
		return TRUE
	return FALSE

/proc/iscarbon(A)
	if(istype(A, /mob/living/carbon))
		return TRUE
	return FALSE

/proc/issilicon(A)
	if(istype(A, /mob/living/silicon))
		return TRUE
	return FALSE

/proc/isliving(A)
	if(istype(A, /mob/living))
		return TRUE
	return FALSE

proc/isobserver(A)
	if(istype(A, /mob/dead/observer))
		return TRUE
	return FALSE

proc/isorgan(A)
	if(istype(A, /datum/limb))
		return TRUE
	return FALSE

proc/isdeaf(A)
	if(isliving(A))
		var/mob/living/M = A
		return M.ear_deaf
	return FALSE

proc/is_blind(A)
	if(isliving(A))
		var/mob/living/M = A
		return M.eye_blind
	return FALSE


proc/isnewplayer(A)
	if(istype(A, /mob/new_player))
		return TRUE
	return FALSE

proc/isXeno(A)
	if(istype(A, /mob/living/carbon/Xenomorph))
		return TRUE
	return FALSE

proc/xeno_hivenumber(A)
	if(isXeno(A))
		var/mob/living/carbon/Xenomorph/X = A
		return X.hivenumber
	return FALSE

proc/isXenoBoiler(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Boiler))
		return TRUE
	return FALSE

proc/isXenoCarrier(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Carrier))
		return TRUE
	return FALSE

proc/isXenoCrusher(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Crusher))
		return TRUE
	return FALSE

proc/isXenoDrone(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Drone))
		return TRUE
	return FALSE

proc/isXenoHivelord(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Hivelord))
		return TRUE
	return FALSE

proc/isXenoHunter(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Hunter))
		return TRUE
	return FALSE

proc/isXenoDefender(A)
	if (istype(A, /mob/living/carbon/Xenomorph/Defender))
		return TRUE
	return FALSE

proc/isXenoLarva(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Larva))
		return TRUE
	return FALSE

proc/isXenoLarvaStrict(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Larva) && !istype(A, /mob/living/carbon/Xenomorph/Larva/predalien))
		return TRUE
	return FALSE

proc/isXenoPraetorian(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Praetorian))
		return TRUE
	return FALSE

proc/isXenoQueen(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Queen))
		return TRUE
	return FALSE

proc/isXenoRavager(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Ravager))
		return TRUE
	return FALSE

proc/isXenoRunner(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Runner))
		return TRUE
	return FALSE

proc/isXenoSentinel(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Sentinel))
		return TRUE
	return FALSE

proc/isXenoSpitter(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Spitter))
		return TRUE
	return FALSE

proc/isXenoWarrior(A)
	if (istype(A, /mob/living/carbon/Xenomorph/Warrior))
		return TRUE
	return FALSE

proc/isXenoPredalien(A)
	if(istype(A, /mob/living/carbon/Xenomorph/Predalien))
		return TRUE
	return FALSE

proc/isYautja(A)
	if(isHellhound(A))
		return TRUE //They are always considered Yautja.
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.species.name == "Yautja")
			return TRUE
	return FALSE

proc/isSynth(A)
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.species.name == "Synthetic" || H.species.name == "Early Synthetic")
			return TRUE
	return FALSE

proc/ismaintdrone(A)
	if(istype(A,/mob/living/silicon/robot/drone))
		return TRUE
	return FALSE

proc/isHellhound(A)
	if(istype(A, /mob/living/carbon/hellhound))
		return TRUE
	return FALSE

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
		return TRUE
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
			return TRUE
	return FALSE


/mob/proc/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.flags_item & ITEM_ABSTRACT )) || (src.r_hand && !( src.r_hand.flags_item & ITEM_ABSTRACT )) || (src.back || src.wear_mask)))
		return TRUE

	if((src.l_hand && !( src.l_hand.flags_item & ITEM_ABSTRACT )) || (src.r_hand && !( src.r_hand.flags_item & ITEM_ABSTRACT )))
		return TRUE

	return FALSE

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

/mob/proc/reagent_check(datum/reagent/R)
	return 1

//returns how many non-destroyed legs the mob has (currently only useful for humans)
/mob/proc/has_legs()
	return 2

/mob/proc/get_eye_protection()
	return 0

mob/proc/get_standard_bodytemperature()
	return BODYTEMP_NORMAL

/mob/log_message(message, message_type, color=null, log_globally = TRUE)
	if(!length(message))
		stack_trace("Empty message")
		return

	// Cannot use the list as a map if the key is a number, so we stringify it (thank you BYOND)
	var/smessage_type = num2text(message_type)

	if(client)
		if(!islist(client.player_details.logging[smessage_type]))
			client.player_details.logging[smessage_type] = list()

	if(!islist(logging[smessage_type]))
		logging[smessage_type] = list()

	var/colored_message = message
	if(color)
		if(color[1] == "#")
			colored_message = "<font color=[color]>[message]</font>"
		else
			colored_message = "<font color='[color]'>[message]</font>"

	var/list/timestamped_message = list("[length(logging[smessage_type]) + 1]\[[time_stamp()]\] [key_name(src)] [loc_name(src)]" = colored_message)

	logging[smessage_type] += timestamped_message

	if(client)
		client.player_details.logging[smessage_type] += timestamped_message

	..()

/mob/verb/a_select_zone(input as text, screen_num as null|num)
	set name = "a-select-zone"
	set hidden = 1

	if(!screen_num)
		return

	switch(input)
		if("head")
			switch(usr.zone_selected)
				if("head")
					usr.zone_selected = "eyes"
					usr.client.screen[screen_num].selecting = "eyes"
				if("eyes")
					usr.zone_selected = "mouth"
					usr.client.screen[screen_num].selecting = "mouth"
				if("mouth")
					usr.zone_selected = "head"
					usr.client.screen[screen_num].selecting = "head"
				else
					usr.zone_selected = "head"
					usr.client.screen[screen_num].selecting = "head"
		if("chest")
			usr.zone_selected = "chest"
			usr.client.screen[screen_num].selecting = "chest"
		if("groin")
			usr.zone_selected = "groin"
			usr.client.screen[screen_num].selecting = "groin"
		if("rarm")
			switch(usr.zone_selected)
				if("r_arm")
					usr.zone_selected = "r_hand"
					usr.client.screen[screen_num].selecting = "r_hand"
				if("r_hand")
					usr.zone_selected = "r_arm"
					usr.client.screen[screen_num].selecting = "r_arm"
				else
					usr.zone_selected = "r_arm"
					usr.client.screen[screen_num].selecting = "r_arm"
		if("larm")
			switch(usr.zone_selected)
				if("l_arm")
					usr.zone_selected = "l_hand"
					usr.client.screen[screen_num].selecting = "l_hand"
				if("l_hand")
					usr.zone_selected = "l_arm"
					usr.client.screen[screen_num].selecting = "l_arm"
				else
					usr.zone_selected = "l_arm"
					usr.client.screen[screen_num].selecting = "l_arm"
		if("rleg")
			switch(usr.zone_selected)
				if("r_leg")
					usr.zone_selected = "r_foot"
					usr.client.screen[screen_num].selecting = "r_foot"
				if("r_foot")
					usr.zone_selected = "r_leg"
					usr.client.screen[screen_num].selecting = "r_leg"
				else
					usr.zone_selected = "r_leg"
					usr.client.screen[screen_num].selecting = "r_leg"
		if("lleg")
			switch(usr.zone_selected)
				if("l_leg")
					usr.zone_selected = "l_foot"
					usr.client.screen[screen_num].selecting = "l_foot"
				if("l_foot")
					usr.zone_selected = "l_leg"
					usr.client.screen[screen_num].selecting = "l_leg"
				else
					usr.zone_selected = "l_leg"
					usr.client.screen[screen_num].selecting = "l_leg"

	usr.client.screen[screen_num].update_icon()