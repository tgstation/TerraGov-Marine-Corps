/proc/isdeaf(A)
	if(isliving(A))
		var/mob/living/M = A
		return M.ear_deaf || M.disabilities & DEAF
	return FALSE

/proc/is_blind(A)
	if(isliving(A))
		var/mob/living/M = A
		return M.eye_blind
	return FALSE

/mob/proc/can_use_hands()
	return

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
	"l_hand" = 30,
	"r_hand" = 30,
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
	if(!target.buckled && !target.lying_angle)
		var/miss_chance = 10
		if (zone in GLOB.base_miss_chance)
			miss_chance = GLOB.base_miss_chance[zone]
		miss_chance = max(miss_chance + miss_chance_mod, 0)
		if(prob(miss_chance))
			if(prob(70))
				return null
			return pick(GLOB.base_miss_chance)

	return zone


/**
 * Convert random parts of a passed in message to stars
 *
 * * phrase - the string to convert
 * * probability - probability any character gets changed
 *
 * This proc is dangerously laggy, avoid it or die
 */
/proc/stars(phrase, probability = 25)
	if(probability <= 0)
		return phrase
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	. = ""
	var/char = ""
	for(var/i = 1, i <= leng, i += length(char))
		char = phrase[i]
		if(char == " " || !prob(probability))
			. += char
		else
			. += "*"
	return sanitize(.)

/**
 * Makes you speak like you're drunk
 * todo remove, deprecated
 */
/proc/slur(phrase)
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	. = ""
	var/newletter = ""
	var/rawchar = ""
	for(var/i = 1, i <= leng, i += length(rawchar))
		rawchar = newletter = phrase[i]
		if(rand(1, 3) == 3)
			var/lowerletter = lowertext(newletter)
			if(lowerletter == "o")
				newletter = "u"
			else if(lowerletter == "s")
				newletter = "ch"
			else if(lowerletter == "a")
				newletter = "ah"
			else if(lowerletter == "u")
				newletter = "oo"
			else if(lowerletter == "c")
				newletter = "k"
		if(prob(5))
			if(newletter == " ")
				newletter = "...huuuhhh..."
			else if(newletter == ".")
				newletter = " *BURP*."
		if(prob(15))
			newletter += pick(list("'", "[newletter]", "[newletter][newletter]"))
		. += "[newletter]"
	return sanitize(.)

///Adds stuttering to the message passed in, todo remove, deprecated
/proc/stutter(phrase)
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	. = ""
	var/newletter = ""
	var/rawchar
	for(var/i = 1, i <= leng, i += length(rawchar))
		rawchar = newletter = phrase[i]
		if(prob(80) && !(lowertext(newletter) in list("a", "e", "i", "o", "u", " ")))
			if(prob(10))
				newletter = "[newletter]-[newletter]-[newletter]-[newletter]"
			else if(prob(20))
				newletter = "[newletter]-[newletter]-[newletter]"
			else
				newletter = "[newletter]-[newletter]"
		. += newletter
	return sanitize(.)


/**
 * Turn text into complete gibberish!
 *
 * text is the inputted message, replace_characters will cause original letters to be replaced and chance are the odds that a character gets modified.
 */
/proc/Gibberish(text, replace_characters = FALSE, chance = 50)
	text = html_decode(text)
	. = ""
	var/rawchar = ""
	var/letter = ""
	var/lentext = length(text)
	for(var/i = 1, i <= lentext, i += length(rawchar))
		rawchar = letter = text[i]
		if(prob(chance))
			if(replace_characters)
				letter = ""
			for(var/j in 1 to rand(0, 2))
				letter += pick("#", "@", "*", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*")
		. += letter
	return sanitize(.)


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


///Makes a recoil-like animation on the mob camera.
/proc/recoil_camera(mob/M, duration, backtime_duration, strength, angle)
	if(!M?.client)
		return
	strength *= world.icon_size
	var/oldx = M.client.pixel_x
	var/oldy = M.client.pixel_y

	//get pixels to move the camera in an angle
	var/mpx = sin(angle) * strength
	var/mpy = cos(angle) * strength
	animate(M.client, pixel_x = mpx-oldx, pixel_y = mpy-oldy, time = duration, flags = ANIMATION_RELATIVE)
	animate(pixel_x = oldx, pixel_y = oldy, time = backtime_duration, easing = BACK_EASING)


/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if (M.real_name == "[msg]")
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

	switch(input)
		if(INTENT_HELP,INTENT_DISARM,INTENT_GRAB,INTENT_HARM)
			a_intent = input
		if(INTENT_HOTKEY_RIGHT)
			a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
		if(INTENT_HOTKEY_LEFT)
			a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)


	if(hud_used?.action_intent)
		hud_used.action_intent.icon_state = "[a_intent]"


//can the mob be operated on?
/mob/proc/can_be_operated_on()
	return FALSE

//check if mob is lying down on something we can operate him on.
/mob/living/carbon/can_be_operated_on()
	if(!lying_angle)
		return FALSE
	if(locate(/obj/machinery/optable, loc) || locate(/obj/structure/bed/roller, loc))
		return TRUE
	var/obj/structure/table/T = locate(/obj/structure/table, loc)
	if(T && !T.flipped) return TRUE

/mob/living/carbon/xenomorph/can_be_operated_on()
	return FALSE


/mob/proc/restrained(ignore_checks)
	SHOULD_CALL_PARENT(TRUE)
	return HAS_TRAIT(src, TRAIT_HANDS_BLOCKED)


/mob/proc/incapacitated(ignore_restrained, restrained_flags)
	return (stat || (!ignore_restrained && restrained(restrained_flags)))


//returns how many non-destroyed legs the mob has (currently only useful for humans)
/mob/proc/has_legs()
	return 2

/mob/proc/get_eye_protection()
	return 0

/mob/proc/get_standard_bodytemperature()
	return BODYTEMP_NORMAL


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
	to_chat(O, "[(extra_large) ? "<br><hr>" : ""][span_deadsay("[message][(enter_link) ? " [full_enter_link]" : ""][track_link]")][(extra_large) ? "<hr><br>" : ""]")
	if(ghost_sound)
		SEND_SOUND(O, sound(ghost_sound, volume = notify_volume, channel = CHANNEL_NOTIFY))
	if(flashwindow)
		window_flash(O.client)

	if(!source)
		return

	var/atom/movable/screen/alert/notify_action/A = O.throw_alert("[REF(source)]_notify_action", /atom/movable/screen/alert/notify_action)
	if(!A)
		return
	if (header)
		A.name = header
	A.desc = message
	A.action = action
	A.target = source
	if(!alert_overlay)
		alert_overlay = new(source)
		var/icon/I = icon(source.icon)
		var/iheight = I.Height()
		var/iwidth = I.Width()
		var/higher_power = (iheight > iwidth) ? iheight : iwidth
		if(higher_power > 32)
			var/diff = 32 / higher_power
			alert_overlay.transform = alert_overlay.transform.Scale(diff, diff)
			if(higher_power > 48)
				alert_overlay.pixel_y = -(iheight / 2) * diff
				alert_overlay.pixel_x = -(iwidth / 2) * diff


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

/**
 * Get the list of keywords for policy config
 *
 * This gets the type, mind assigned roles and antag datums as a list, these are later used
 * to send the user relevant headadmin policy config
 */
/mob/proc/get_policy_keywords()
	. = list("[type]")


/// Try to perform a unique action on the held items
/mob/living/carbon/human/proc/do_unique_action()
	SIGNAL_HANDLER
	. = COMSIG_KB_ACTIVATED //The return value must be a flag compatible with the signals triggering this.
	if(incapacitated() || lying_angle)
		return

	var/obj/item/active_item = get_active_held_item()
	if((istype(active_item) && active_item.do_unique_action(src) != COMSIG_KB_NOT_ACTIVATED) || client?.prefs.unique_action_use_active_hand)
		return
	var/obj/item/inactive_item = get_inactive_held_item()
	if(istype(inactive_item))
		inactive_item.do_unique_action(src)

///Handles setting or changing a mob's skills
/mob/proc/set_skills(datum/skills/new_skillset)
	skills = new_skillset
	SEND_SIGNAL(src, COMSIG_MOB_SKILLS_CHANGED, skills)

///Returns the slowdown applied to the mob when moving through liquids like water
/mob/proc/get_liquid_slowdown()
	return MOB_WATER_SLOWDOWN
