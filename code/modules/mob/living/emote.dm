
/* EMOTE DATUMS */
/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(/mob/living/simple_animal/slime, /mob/living/brain)

/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "blushes."


/datum/emote/living/pray
	key = "pray"
	key_third_person = "prays"
	message = "prays something."
	restraint_check = FALSE
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_pray()
	set name = "Pray"
	set category = "Emotes"

	emote("pray", intentional = TRUE)

/datum/emote/living/pray/run_emote(mob/user, params, type_override, intentional)
	if(isliving(user))
		var/mob/living/L = user
		var/area/C = get_area(user)
		if(!(istype(C, /area/rogue/indoors/town/church/chapel)))
			if(!(istype(C, /area/rogue/underworld)))
				to_chat(user, "<span class='danger'>I should go to the Chapel!</span>")
				return		
		var/msg = input("Whisper your prayer:", "Prayer") as text|null
		if(msg)
			L.whisper(msg)
			L.roguepray(msg)
//			for(var/obj/structure/fluff/psycross/P in view(7, get_turf(L)) ) // We'll reenable this later when the patron statues are more fleshed out.
//				if(P.obj_broken)
//					continue
//				P.check_prayer(L,msg)
//				break
			if(istype(C, /area/rogue/underworld))
				L.check_prayer_underworld(L,msg)
				L.whisper(msg)
				L.roguepray(msg)
				return
			L.check_prayer(L,msg)
			for(var/mob/living/L in hearers(2,src))
				L.succumb_timer=world.time

/mob/living/proc/check_prayer(mob/living/L,message)
	if(!L || !message)
		return FALSE
	var/list/bannedwords = list("zizo","cock","dick","fuck","shit","pussy","cuck","fucker","fucked","cunt","asshole")
	var/message2recognize = sanitize_hear_message(message)
	var/mob/living/carbon/human/M = L
	for(var/T in bannedwords)
		if(findtext(message2recognize, T))
			L.add_stress(/datum/stressevent/psycurse)
			L.adjust_fire_stacks(100)
			L.IgniteMob()
			return FALSE
	if(length(message2recognize) > 15)
		if(L.has_flaw(/datum/charflaw/addiction/godfearing))
			L.sate_addiction()
		if(L.mob_timers[MT_PSYPRAY])
			if(world.time < L.mob_timers[MT_PSYPRAY] + 1 MINUTES)
				L.mob_timers[MT_PSYPRAY] = world.time
				return FALSE
		else
			L.mob_timers[MT_PSYPRAY] = world.time
		if(!findtext(message2recognize, "[M.PATRON]"))
			return FALSE
		else
			L.playsound_local(L, 'sound/misc/notice (2).ogg', 100, FALSE)
			L.add_stress(/datum/stressevent/psyprayer)
			return TRUE
	else to_chat(L, "<span class='danger'>My prayer was kinda short...</span>")

/mob/living/proc/check_prayer_underworld(mob/living/L,message)
	if(!L || !message)
		return FALSE
	var/list/bannedwords = list("zizo","cock","dick","fuck","shit","pussy","ass","cuck","fucker","fucked","cunt","asshole")
	var/message2recognize = sanitize_hear_message(message)
	var/mob/living/carbon/spirit/M = L
	for(var/T in bannedwords)
		var/list/turfs = list()
		if(findtext(message2recognize, T))
			for(var/turf/U in /area/rogue/underworld)
				if(U.density)
					continue
				turfs.Add(U)

			var/turf/U = safepick(turfs)
			if(!U)
				return
			to_chat(L, "<font color='yellow'>INSOLENT WRETCH, YOUR STRUGGLE CONTINUES</font>")
			L.forceMove(T)
			return FALSE
	if(length(message2recognize) > 15)
		if(findtext(message2recognize, "[M.PATRON]"))
			L.playsound_local(L, 'sound/misc/notice (2).ogg', 100, FALSE)
			to_chat(L, "<font color='yellow'>I, [M.PATRON], have heard your prayer and grant you favor.</font>")
			var/obj/item/underworld/coin/C = new
			L.put_in_active_hand(C)
			return TRUE
		else
			return TRUE
	else to_chat(L, "<span class='danger'>My prayer was kinda short...</span>")

/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "bows."
	message_param = "bows to %t."
	restraint_check = TRUE
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_bow()
	set name = "Bow"
	set category = "Emotes"

	emote("bow", intentional = TRUE)

/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "burps."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_burp()
	set name = "Burp"
	set category = "Noises"

	emote("burp", intentional = TRUE)

/datum/emote/living/burp/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	emote_type = EMOTE_AUDIBLE
	ignore_silent = TRUE

/mob/living/carbon/human/verb/emote_choke()
	set name = "Choke"
	set category = "Noises"

	emote("choke", intentional = TRUE)

/datum/emote/living/cross
	key = "crossarms"
	key_third_person = "crossesarms"
	message = "crosses their arms."
	restraint_check = TRUE
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_crossarms()
	set name = "Crossarms"
	set category = "Emotes"

	emote("crossarms", intentional = TRUE)

/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "collapses."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/collapse/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		var/mob/living/L = user
		L.Unconscious(40)

/datum/emote/living/whisper
	key = "whisper"
	key_third_person = "whispers"
	message = "whispers."
	message_mime = "appears to whisper."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/aggro
	key = "aggro"
	key_third_person = "aggro"
	message = ""
	nomsg = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/cough
	key = "cough"
	key_third_person = "coughs"
	message = "coughs."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_cough()
	set name = "Cough"
	set category = "Noises"

	emote("cough", intentional = TRUE)

/datum/emote/living/cough/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/clearthroat
	key = "clearthroat"
	key_third_person = "clearsthroat"
	message = "clears their throat."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_clearthroat()
	set name = "Clearthroat"
	set category = "Noises"

	emote("clearthroat", intentional = TRUE)

/datum/emote/living/clearthroat/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "dances."
	restraint_check = TRUE
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_dance()
	set name = "Dance"
	set category = "Emotes"

	emote("dance", intentional = TRUE)

/datum/emote/living/deathgasp
	key = ""
	key_third_person = ""
	message = "gasps out their last breath."
	message_robot = "shudders violently for a moment before falling still, its eyes slowly darkening."
	message_AI = "screeches, its screen flickering as its systems slowly halt."
	message_alien = "lets out a waning guttural screech, and collapses onto the floor..."
	message_larva = "lets out a sickly hiss of air and falls limply to the floor..."
	message_monkey = "lets out a faint chimper as it collapses and stops moving..."
	message_simple =  "falls limp."
	stat_allowed = UNCONSCIOUS

/datum/emote/living/deathgasp/run_emote(mob/user, params, type_override, intentional)
	var/mob/living/simple_animal/S = user
	if(istype(S) && S.deathmessage)
		message_simple = S.deathmessage
	. = ..()
	message_simple = initial(message_simple)
	if(. && user.deathsound)
		if(isliving(user))
			var/mob/living/L = user
			if(!L.can_speak_vocal() || L.oxyloss >= 50)
				return //stop the sound if oxyloss too high/cant speak
		playsound(user, user.deathsound, 200, TRUE, TRUE)

/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "drools."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_drool()
	set name = "Drool"
	set category = "Emotes"

	emote("drool", intentional = TRUE)

/datum/emote/living/faint
	key = "faint"
	key_third_person = "faints"
	message = "faints."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_faint()
	set name = "Faint"
	set category = "Emotes"

	emote("faint", intentional = TRUE)

/datum/emote/living/faint/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/L = user
		if(L.get_complex_pain() > (L.STAEND * 9))
			L.setDir(2)
			L.SetUnconscious(200)
		else
			L.Knockdown(10)

/datum/emote/living/flap
	key = "flap"
	key_third_person = "flaps"
	message = "flaps their wings."
	restraint_check = TRUE
	var/wing_time = 20

/datum/emote/living/carbon/human/flap/can_run_emote(mob/user, status_check = TRUE , intentional)
	return FALSE

/datum/emote/living/flap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(. && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/open = FALSE
		if(H.dna.features["wings"] != "None")
			if("wingsopen" in H.dna.species.mutant_bodyparts)
				open = TRUE
				H.CloseWings()
			else
				H.OpenWings()
			addtimer(CALLBACK(H, open ? /mob/living/carbon/human.proc/OpenWings : /mob/living/carbon/human.proc/CloseWings), wing_time)

/datum/emote/living/flap/aflap
	key = "aflap"
	key_third_person = "aflaps"
	message = "flaps their wings ANGRILY!"
	restraint_check = TRUE
	wing_time = 10

/datum/emote/living/carbon/human/aflap/can_run_emote(mob/user, status_check = TRUE , intentional)
	return FALSE

/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "frowns."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_frown()
	set name = "Frown"
	set category = "Emotes"

	emote("frown", intentional = TRUE)

/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "gags."
	emote_type = EMOTE_AUDIBLE
	ignore_silent = TRUE

/mob/living/carbon/human/verb/emote_gag()
	set name = "Gag"
	set category = "Noises"

	emote("gag", intentional = TRUE)

/datum/emote/living/gasp
	key = "gasp"
	key_third_person = "gasps"
	message = "gasps!"
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS

/mob/living/carbon/human/verb/emote_gasp()
	set name = "Gasp"
	set category = "Noises"

	emote("gasp", intentional = TRUE)

/datum/emote/living/gasp/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/breathgasp
	key = "breathgasp"
	key_third_person = "breathgasps"
	message = "gasps for air!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "giggles."
	message_mime = "giggles silently!"
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_giggle()
	set name = "Giggle"
	set category = "Noises"

	emote("giggle", intentional = TRUE)

/datum/emote/living/giggle/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled laugh."

/datum/emote/living/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "chuckles."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_chuckle()
	set name = "Chuckle"
	set category = "Noises"

	emote("chuckle", intentional = TRUE)

/datum/emote/living/chuckle/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled laugh."

/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "glares."
	message_param = "glares at %t."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_glare()
	set name = "Glare"
	set category = "Emotes"

	emote("glare", intentional = TRUE)

/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "grins."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_grin()
	set name = "Grin"
	set category = "Emotes"

	emote("grin", intentional = TRUE)

/datum/emote/living/groan
	key = "groan"
	key_third_person = "groans"
	message = "groans."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_groan()
	set name = "Groan"
	set category = "Noises"

	emote("groan", intentional = TRUE)

/datum/emote/living/groan/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled groan."

/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "grimaces."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_grimace()
	set name = "Grimace"
	set category = "Emotes"

	emote("grimace", intentional = TRUE)

/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "jumps!"
	restraint_check = TRUE

/datum/emote/living/leap
	key = "leap"
	key_third_person = "leaps"
	message = "leaps!"
	restraint_check = TRUE
	only_forced_audio = TRUE

/datum/emote/living/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "blows a kiss."
	message_param = "kisses %t."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_kiss()
	set name = "Kiss"
	set category = "Emotes"

	emote("kiss", intentional = TRUE, targetted = TRUE)




/datum/emote/living/kiss/adjacentaction(mob/user, mob/target)
	. = ..()
	message_param = initial(message_param) // re
	if(!user || !target)
		return
	if(ishuman(user) && ishuman(target))
		var/mob/living/carbon/human/H = user
		var/do_change
		if(target.loc == user.loc)
			do_change = TRUE
		if(!do_change)
			if(H.pulling == target)
				do_change = TRUE
		if(do_change)
			if(H.zone_selected == BODY_ZONE_PRECISE_MOUTH)
				message_param = "kisses %t deeply."
			else if(H.zone_selected == BODY_ZONE_PRECISE_EARS)
				message_param = "kisses %t on the ear."
				var/mob/living/carbon/human/E = target
				if(E.dna.species?.id == "elf")
					if(!E.cmode)
						to_chat(target, "<span class='love'>It tickles...</span>")
			else if(H.zone_selected == BODY_ZONE_PRECISE_R_EYE || H.zone_selected == BODY_ZONE_PRECISE_L_EYE)
				message_param = "kisses %t on the brow."
			else
				message_param = "kisses %t on \the [parse_zone(H.zone_selected)]."
	playsound(target.loc, pick('sound/vo/kiss (1).ogg','sound/vo/kiss (2).ogg'), 100, FALSE, -1)


/datum/emote/living/spit
	key = "spit"
	key_third_person = "spits"
	message = "spits on the ground."
	message_param = "spits on %t."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_spit()
	set name = "Spit"
	set category = "Emotes"

	emote("spit", intentional = TRUE, targetted = TRUE)


/datum/emote/living/spit/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mouth)
			if(H.mouth.spitoutmouth)
				H.visible_message("<span class='warning'>[H] spits out [H.mouth].</span>")
				H.dropItemToGround(H.mouth, silent = FALSE)
			return
	..()

/datum/emote/living/spit/adjacentaction(mob/user, mob/target)
	. = ..()
	if(!user || !target)
		return
	if(user.gender == MALE)
		playsound(target.loc, pick('sound/vo/male/gen/spit.ogg'), 100, FALSE, -1)
	else
		playsound(target.loc, pick('sound/vo/female/gen/spit.ogg'), 100, FALSE, -1)


/datum/emote/living/hug
	key = "hug"
	key_third_person = "hugs"
	message = ""
	message_param = "hugs %t."
	emote_type = EMOTE_VISIBLE
	restraint_check = TRUE

/mob/living/carbon/human/verb/emote_hug()
	set name = "Hug"
	set category = "Emotes"

	emote("hug", intentional = TRUE, targetted = TRUE)

/datum/emote/living/hug/adjacentaction(mob/user, mob/target)
	. = ..()
	if(!user || !target)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.add_stress(/datum/stressevent/hug)

/datum/emote/living/slap
	key = "slap"
	key_third_person = "slaps"
	message = ""
	message_param = "slaps %t in the face."
	emote_type = EMOTE_VISIBLE
	restraint_check = TRUE


/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.zone_selected == BODY_ZONE_PRECISE_GROIN)
			message_param = "slaps %t on the ass!"
	..()

/mob/living/carbon/human/verb/emote_slap()
	set name = "Slap"
	set category = "Emotes"

	emote("slap", intentional = TRUE, targetted = TRUE)

/datum/emote/living/slap/adjacentaction(mob/user, mob/target)
	. = ..()
	if(!user || !target)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.flash_fullscreen("redflash3")
		H.AdjustSleeping(-50)
		playsound(target.loc, pick('sound/foley/slap (1).ogg','sound/foley/slap (2).ogg'), 100, FALSE, -1)

/datum/emote/living/pinch
	key = "pinch"
	key_third_person = "pinches"
	message = ""
	message_param = "pinches %t."
	emote_type = EMOTE_VISIBLE
	restraint_check = TRUE

/datum/emote/living/pinch/adjacentaction(mob/user, mob/target)
	. = ..()
	if(!user || !target)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.flash_fullscreen("redflash1")

/mob/living/carbon/human/verb/emote_pinch()
	set name = "Pinch"
	set category = "Emotes"

	emote("pinch", intentional = TRUE, targetted = TRUE)



/datum/emote/living/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "laughs."
	message_mime = "laughs silently!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		return !C.silent

/mob/living/carbon/human/verb/emote_laugh()
	set name = "Laugh"
	set category = "Noises"

	emote("laugh", intentional = TRUE)

/datum/emote/living/laugh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled laugh."

/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "stares blankly."
	message_param = "looks at %t."

/datum/emote/living/nod
	key = "nod"
	key_third_person = "nods"
	message = "nods."
	message_param = "nods at %t."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_nod()
	set name = "Nod"
	set category = "Emotes"

	emote("nod", intentional = TRUE)

/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "points."
	message_param = "points at %t."
	restraint_check = TRUE

/datum/emote/living/point/run_emote(mob/user, params, type_override, intentional)
	message_param = initial(message_param) // reset
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.get_num_arms() == 0)
			if(H.get_num_legs() != 0)
				message_param = "tries to point at %t with a leg, <span class='danger'>falling down</span> in the process!"
				H.Paralyze(20)
			else
				message_param = "<span class='danger'>bumps [user.p_their()] head on the ground</span> trying to motion towards %t."
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
	..()

/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "pouts."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "screams!"
	message_mime = "acts out a scream!"
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_scream()
	set name = "Scream"
	set category = "Noises"

	emote("scream", intentional = TRUE)

/datum/emote/living/scream/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled scream!"
		if(intentional)
			if(!C.rogfat_add(10))
				to_chat(C, "<span class='warning'>I try to scream but my voice fails me.</span>")
				. = FALSE

/datum/emote/living/scream/painscream
	key = "painscream"
	message = "screams in pain!"
	emote_type = EMOTE_AUDIBLE
	only_forced_audio = TRUE

/datum/emote/living/scream/agony
	key = "agony"
	message = "screams in agony!"
	emote_type = EMOTE_AUDIBLE
	only_forced_audio = TRUE

/datum/emote/living/scream/firescream
	key = "firescream"
	nomsg = TRUE
	emote_type = EMOTE_AUDIBLE
	only_forced_audio = TRUE

/datum/emote/living/aggro
	key = "aggro"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/idle
	key = "idle"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/death
	key = "death"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE
	stat_allowed = UNCONSCIOUS
	mob_type_ignore_stat_typecache = list(/mob/living)

/datum/emote/living/pain
	key = "pain"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/drown
	key = "drown"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE
	ignore_silent = TRUE

/datum/emote/living/paincrit
	key = "paincrit"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/embed
	key = "embed"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/painmoan
	key = "painmoan"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/groin
	key = "groin"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/fatigue
	key = "fatigue"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/jump
	key = "jump"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE
	only_forced_audio = TRUE

/datum/emote/living/haltyell
	key = "haltyell"
	message = "shouts a halt!"
	emote_type = EMOTE_AUDIBLE
	only_forced_audio = TRUE

/datum/emote/living/rage
	key = "rage"
	message = "screams in rage!"
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_rage()
	set name = "Rage"
	set category = "Noises"

	emote("rage", intentional = TRUE)

/datum/emote/living/attnwhistle
	key = "attnwhistle"
	message = "whistles for attention!"
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_attnwhistle()
	set name = "Attnwhistle"
	set category = "Noises"

	emote("attnwhistle", intentional = TRUE)

/datum/emote/living/attnwhistle/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "chokes!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "scowls."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/shakehead
	key = "shakehead"
	key_third_person = "shakeshead"
	message = "shakes their head."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_shakehead()
	set name = "Shakehead"
	set category = "Emotes"

	emote("shakehead", intentional = TRUE)


/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shiver"
	message = "shivers."
	emote_type = EMOTE_VISIBLE

/mob/living/carbon/human/verb/emote_shiver()
	set name = "Shiver"
	set category = "Emotes"

	emote("shiver", intentional = TRUE)


/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "sighs."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_sigh()
	set name = "Sigh"
	set category = "Noises"

	emote("sigh", intentional = TRUE)

/datum/emote/living/sigh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled sigh."

/datum/emote/living/whistle
	key = "whistle"
	key_third_person = "whistles"
	message = "whistles."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_whistle()
	set name = "Whistle"
	set category = "Noises"

	emote("whistle", intentional = TRUE)

/datum/emote/living/whistle/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/hmm
	key = "hmm"
	key_third_person = "hmms"
	message = "hmms."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_hmm()
	set name = "Hmm"
	set category = "Noises"

	emote("hmm", intentional = TRUE)

/datum/emote/living/hmm/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled hmm."

/datum/emote/living/huh
	key = "huh"
	key_third_person = "huhs"
	emote_type = EMOTE_AUDIBLE
	nomsg = TRUE

/mob/living/carbon/human/verb/emote_huh()
	set name = "Huh"
	set category = "Noises"

	emote("huh", intentional = TRUE)

/datum/emote/living/huh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled noise."

/datum/emote/living/hum
	key = "hum"
	key_third_person = "hums"
	message = "hums."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_hum()
	set name = "Hum"
	set category = "Noises"

	emote("hum", intentional = TRUE)

/datum/emote/living/hum/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled hum."

/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "smiles."
	emote_type = EMOTE_VISIBLE
/mob/living/carbon/human/verb/emote_smile()
	set name = "Smile"
	set category = "Emotes"

	emote("smile", intentional = TRUE)

/datum/emote/living/sneeze
	key = "sneeze"
	key_third_person = "sneezes"
	message = "sneezes."
	emote_type = EMOTE_AUDIBLE
/*
/mob/living/carbon/human/verb/emote_sneeze()
	set name = "Sneeze"
	set category = "Noises"

	emote("sneeze", intentional = TRUE)
*/
/datum/emote/living/sneeze/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled sneeze."

/datum/emote/living/shh
	key = "shh"
	key_third_person = "shhs"
	message = "shooshes."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_shh()
	set name = "Shh"
	set category = "Noises"

	emote("shh", intentional = TRUE)

/datum/emote/living/shh/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled shh."

/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "grins smugly."

/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "sniffs."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "snores."
	message_mime = "sleeps soundly."
	emote_type = EMOTE_AUDIBLE
	stat_allowed = UNCONSCIOUS
	snd_range = -4

/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "stares."
	message_param = "stares at %t."

/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "stretches their arms."

/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "sulks down sadly."

/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "sways around dizzily."

/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "trembles in fear!"

/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "twitches violently."

/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "twitches."
	stat_allowed = UNCONSCIOUS
	mob_type_ignore_stat_typecache = list(/mob/living/carbon/human)

/datum/emote/living/wave
	key = "wave"
	key_third_person = "waves"
	message = "waves."

/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "whimpers."
	message_mime = "appears hurt."

/mob/living/carbon/human/verb/emote_whimper()
	set name = "Whimper"
	set category = "Noises"

	emote("whimper", intentional = TRUE)

/datum/emote/living/whimper/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled whimper."

/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "smiles weakly."

/datum/emote/living/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "yawns."
	emote_type = EMOTE_AUDIBLE

/mob/living/carbon/human/verb/emote_yawn()
	set name = "Yawn"
	set category = "Noises"

	emote("yawn", intentional = TRUE)

/datum/emote/living/yawn/can_run_emote(mob/living/user, status_check = TRUE , intentional)
	. = ..()
	if(. && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.silent || !C.canspeak())
			message = "makes a muffled yawn."


/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
#ifdef MATURESERVER
	message_param = "%t"
#endif
	mute_time = 1
/datum/emote/living/custom/can_run_emote(mob/user, status_check, intentional)
	. = ..() && intentional

/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	. = TRUE
	if(copytext(input,1,5) == "says")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,9) == "exclaims")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,6) == "yells")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else if(copytext(input,1,5) == "asks")
		to_chat(user, "<span class='danger'>Invalid emote.</span>")
	else
		. = FALSE

/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	if(is_banned_from(user.ckey, "Emote"))
		to_chat(user, "<span class='boldwarning'>I cannot send custom emotes (banned).</span>")
		return FALSE
	else if(QDELETED(user))
		return FALSE
	else if(user.client && user.client.prefs.muted & MUTE_IC)
		to_chat(user, "<span class='boldwarning'>I cannot send IC messages (muted).</span>")
		return FALSE
	else if(!params)
		var/custom_emote = copytext(sanitize(input("What does your character do?") as text|null), 1, MAX_MESSAGE_LEN)
		if(custom_emote && !check_invalid(user, custom_emote))
/*			var/type = input("Is this a visible or hearable emote?") as null|anything in list("Visible", "Hearable")
			switch(type)
				if("Visible")
					emote_type = EMOTE_VISIBLE
				if("Hearable")
					emote_type = EMOTE_AUDIBLE
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return*/
			message = custom_emote
			emote_type = EMOTE_VISIBLE
	else
		message = params
		if(type_override)
			emote_type = type_override
	. = ..()
	message = null
	emote_type = EMOTE_VISIBLE

/datum/emote/living/custom/replace_pronoun(mob/user, message)
	return message

/datum/emote/living/help
	key = "help"

/datum/emote/living/help/run_emote(mob/user, params, type_override, intentional)
/*	var/list/keys = list()
	var/list/message = list("Available emotes, you can use them with say \"*emote\": ")

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/P in GLOB.emote_list[key])
			if(P.key in keys)
				continue
			if(P.can_run_emote(user, status_check = FALSE , intentional = TRUE))
				keys += P.key

	keys = sortList(keys)

	for(var/emote in keys)
		if(LAZYLEN(message) > 1)
			message += ", [emote]"
		else
			message += "[emote]"

	message += "."

	message = jointext(message, "")

	to_chat(user, message)*/

/datum/emote/beep
	key = "beep"
	key_third_person = "beeps"
	message = "beeps."
	message_param = "beeps at %t."
	sound = 'sound/blank.ogg'
	mob_type_allowed_typecache = list(/mob/living/brain, /mob/living/silicon)
/*
/datum/emote/living/circle
	key = "circle"
	key_third_person = "circles"
	restraint_check = TRUE

/datum/emote/living/circle/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	var/obj/item/circlegame/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>I make a circle with your hand.</span>")
	else
		qdel(N)
		to_chat(user, "<span class='warning'>I don't have any free hands to make a circle with.</span>")

/datum/emote/living/slap
	key = "slap"
	key_third_person = "slaps"
	restraint_check = TRUE

/datum/emote/living/slap/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return
	var/obj/item/slapper/N = new(user)
	if(user.put_in_hands(N))
		to_chat(user, "<span class='notice'>I ready your slapping hand.</span>")
	else
		to_chat(user, "<span class='warning'>You're incapable of slapping in your current state.</span>")
*/
