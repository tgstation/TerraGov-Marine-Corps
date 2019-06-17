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

proc/hasorgans(A)
	return ishuman(A)

/proc/hsl2rgb(h, s, l)
	return //TODO: Implement



/mob/proc/can_use_hands()
	return

/mob/proc/is_mechanical()
	if(mind && (mind.assigned_role == "Cyborg" || mind.assigned_role == "AI"))
		return TRUE
	return issilicon(src) || isIPC(src)

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/get_gender()
	return gender




/*
	Miss Chance
*/

//TODO: Integrate defence zones and targeting body parts with the actual organ system, move these into organ definitions.

//The base miss chance for the different defence zones
GLOBAL_LIST_INIT(base_miss_chance, list(
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
))

//Used to weight organs when an organ is hit randomly (i.e. not a directed, aimed attack).
//Also used to weight the protection value that armour provides for covering that body part when calculating protection from full-body effects. Totals 102; 2 added to chest for limb loops that don't count mouth/eyes.
GLOBAL_LIST_INIT(organ_rel_size, list(
	"head" = 4,
	"chest" = 32,
	"groin" = 10,
	"l_leg" = 12,
	"r_leg" = 12,
	"l_arm" = 9,
	"r_arm" = 9,
	"l_hand" = 3,
	"r_hand" = 3,
	"l_foot" = 3,
	"r_foot" = 3,
	"eyes" = 1,
	"mouth" = 1,
))

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
			GLOB.organ_rel_size["head"]; "head",
			GLOB.organ_rel_size["chest"]; "chest",
			GLOB.organ_rel_size["groin"]; "groin",
			GLOB.organ_rel_size["l_arm"]; "l_arm",
			GLOB.organ_rel_size["r_arm"]; "r_arm",
			GLOB.organ_rel_size["l_leg"]; "l_leg",
			GLOB.organ_rel_size["r_leg"]; "r_leg",
			GLOB.organ_rel_size["l_hand"]; "l_hand",
			GLOB.organ_rel_size["r_hand"]; "r_hand",
			GLOB.organ_rel_size["l_foot"]; "l_foot",
			GLOB.organ_rel_size["r_foot"]; "r_foot",
		)

	return ran_zone

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, mob/target, miss_chance_mod = 0)
	zone = check_zone(zone)

	// you can only miss if your target is standing and not restrained
	if(!target.buckled && !target.lying)
		var/miss_chance = 10
		if (zone in GLOB.base_miss_chance)
			miss_chance = GLOB.base_miss_chance[zone]
		miss_chance = max(miss_chance + miss_chance_mod, 0)
		if(prob(miss_chance))
			if(prob(70))
				return null
			return pick(GLOB.base_miss_chance)

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
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength*world.icon_size
	var/min = -(strength*world.icon_size)

	for(var/i in 0 to duration-1)
		if (i == 0)
			animate(C, pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
		else
			animate(pixel_x=rand(min,max), pixel_y=rand(min,max), time=1)
	animate(pixel_x=oldx, pixel_y=oldy, time=1)


/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if (M.real_name == text("[msg]"))
			return TRUE
	return FALSE


/mob/proc/abiotic(full_body)
	if(full_body && ((l_hand && !( l_hand.flags_item & ITEM_ABSTRACT )) || (r_hand && !( r_hand.flags_item & ITEM_ABSTRACT ))))
		return TRUE

	if((src.l_hand && !( src.l_hand.flags_item & ITEM_ABSTRACT )) || (src.r_hand && !( src.r_hand.flags_item & ITEM_ABSTRACT )))
		return TRUE

	return FALSE


/mob/living/carbon/abiotic(full_body)
	if(full_body && (back || wear_mask))
		return TRUE
	return ..()


//converts intent-strings into numbers and back
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if(INTENT_HELP)
				return INTENT_NUMBER_HELP
			if(INTENT_DISARM)
				return INTENT_NUMBER_DISARM
			if(INTENT_GRAB)
				return INTENT_NUMBER_GRAB
			else
				return INTENT_NUMBER_HARM
	else
		switch(argument)
			if(INTENT_NUMBER_HELP)
				return INTENT_HELP
			if(INTENT_NUMBER_DISARM)
				return INTENT_DISARM
			if(INTENT_NUMBER_GRAB)
				return INTENT_GRAB
			else
				return INTENT_HARM

//change a mob's act-intent. Input the intent as a string such as "help" or use "right"/"left
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(ismonkey(src))
		switch(input)
			if(INTENT_HELP)
				a_intent = INTENT_HELP
			if(INTENT_HARM)
				a_intent = INTENT_HARM
			if(INTENT_HOTKEY_RIGHT,INTENT_HOTKEY_LEFT)
				a_intent = intent_numeric(intent_numeric(a_intent) - 3)
	else
		switch(input)
			if(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM)
				a_intent = input
			if(INTENT_HOTKEY_RIGHT)
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if(INTENT_HOTKEY_LEFT)
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)


	if(hud_used && hud_used.action_intent)
		hud_used.action_intent.icon_state = "[a_intent]"


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

/mob/living/carbon/xenomorph/can_be_operated_on()
	return FALSE


/mob/proc/restrained(ignore_checks)
	return


/mob/proc/incapacitated(ignore_restrained)
	return (stat || (!ignore_restrained && restrained()))




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

	if(client?.player_details)
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

	var/list/timestamped_message = list("[length(logging[smessage_type]) + 1]\[[stationTimestamp()]\] [key_name(src)] [loc_name(src)]" = colored_message)

	logging[smessage_type] += timestamped_message

	if(client?.player_details)
		client.player_details.logging[smessage_type] += timestamped_message

	return ..()


/proc/notify_ghost(mob/dead/observer/O, message, ghost_sound = null, enter_link = null, enter_text = null, atom/source = null, mutable_appearance/alert_overlay = null, action = NOTIFY_JUMP, flashwindow = TRUE, ignore_mapload = TRUE, ignore_key, header = null, notify_volume = 100, extra_large = FALSE) //Easy notification of a single ghosts.
	if(ignore_mapload && SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)	//don't notify for objects created during a map load
		return
	if(!O.client)
		return
	var/track_link
	if (source && action == NOTIFY_ORBIT)
		track_link = " <a href='byond://?src=[REF(O)];track=[REF(source)]'>(Follow)</a>"
	if (source && action == NOTIFY_JUMP)
		var/turf/T = get_turf(source)
		track_link = " <a href='byond://?src=[REF(O)];jump=1;x=[T.x];y=[T.y];z=[T.z]'>(Jump)</a>"
	var/full_enter_link
	if (enter_link)
		full_enter_link = "<a href='byond://?src=[REF(O)];[enter_link]'>[(enter_text) ? "[enter_text]" : "(Claim)"]</a>"
	to_chat(O, "[(extra_large) ? "<br><hr>" : ""]<span class='deadsay'>[message][(enter_link) ? " [full_enter_link]" : ""][track_link]</span>[(extra_large) ? "<hr><br>" : ""]")
	if(ghost_sound)
		SEND_SOUND(O, sound(ghost_sound, volume = notify_volume))
	if(flashwindow)
		window_flash(O.client)

	if(!source)
		return

	var/obj/screen/alert/notify_action/A = O.throw_alert("[REF(source)]_notify_action", /obj/screen/alert/notify_action)
	if(!A)
		return
	if (header)
		A.name = header
	A.desc = message
	A.action = action
	A.target = source
	if(!alert_overlay)
		alert_overlay = new(source)
		var/icon/i = icon(source.icon)
		var/higher_power = (i.Height() > i.Width()) ? i.Height() : i.Width()
		if (higher_power > 32)
			var/diff = 32 / higher_power
			alert_overlay.transform = alert_overlay.transform.Scale(diff, diff)
			alert_overlay.pixel_y = -32 * diff
			alert_overlay.pixel_x = -32 * diff


	alert_overlay.layer = FLOAT_LAYER
	alert_overlay.plane = FLOAT_PLANE

	A.add_overlay(alert_overlay)


/proc/notify_ghosts(message, ghost_sound = null, enter_link = null, enter_text = null, atom/source = null, mutable_appearance/alert_overlay = null, action = NOTIFY_JUMP, flashwindow = TRUE, ignore_mapload = TRUE, ignore_key, header = null, notify_volume = 100, extra_large = FALSE) //Easy notification of ghosts.
	if(ignore_mapload && SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)	//don't notify for objects created during a map load
		return
	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/O = i
		if(!O.client)
			continue
		notify_ghost(O, message, ghost_sound, enter_link, enter_text, source, alert_overlay, action, flashwindow, ignore_mapload, ignore_key, header, notify_volume, extra_large)