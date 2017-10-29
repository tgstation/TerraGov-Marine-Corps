//sculpture
//SCP-173, nothing more need be said
/mob/living/simple_animal/shyguy
	name = "???"
	desc = "No, no, you know not to look closely at it" //for non-humans
	icon_state = "shyguy"
	icon_living = "shyguy"
	icon_dead = "shyguy"
	emote_hear = list("makes a faint groaning sound")
	emote_see = list("shuffles around aimlessly", "shivers")
	response_help  = "touches the"
	response_disarm = "pushes the"
	response_harm   = "hits the"
	see_in_dark = 8 //Needs to see in darkness to snap in darkness
	flags_pass = PASSTABLE
	var/murder_sound = list('sound/voice/scream_horror2.ogg')
	var/scare_sound = list('sound/scp/scare1.ogg','sound/scp/scare2.ogg','sound/scp/scare3.ogg','sound/scp/scare4.ogg')	//Boo
	var/hibernate = 0 //Disables SCP until toggled back to 0
	var/scare_played = 0 //Did we rape everyone's ears yet ?
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent //Graciously stolen from spider code

	var/list/shitlist = list() //list of folks this guy is about to murder
	var/target //current dude this guy is targeting
	var/screaming = 0 //are we currently screaming?
	var/will_scream = 1 //will we scream when examined?

/mob/living/simple_animal/shyguy/Life()
	if(hibernate)
		return

	check_los()

	if(screaming) //we're still screaming
		return

	//Pick the next target
	if(shitlist.len)
		var/mob/living/carbon/human/H
		for(var/i = 1, i <= shitlist.len, i++) //start from the first guy
			H = shitlist[1]
			if(!H || H.stat == DEAD)
				shitlist -= H
			else
				target = H
				continue
	else
		will_scream = 1

	if(target && shitlist.len) //check for shitlist length because target was somehow not resetting to null
		handle_target(target)
	else
		will_scream = 1
		handle_idle()

//Check if any human mob can see us, including darkness exception
/mob/living/simple_animal/shyguy/proc/check_los()

	//If we are in darkness, nothing can see us
	var/turf/T = get_turf(src)
	//var/in_darkness = 0
	if(T.lighting_lumcount == 0) //Entirely dark tiles only
		return
		//in_darkness = 1

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H in shitlist)
			continue
		if(H.stat || H.blinded)
			continue
		if(H.examine_urge >= 10)
			H << "Unable to resist the urge, you look closely..."
			examine(H)
			continue
		switch(H.examine_urge)
			if(3)
				H << "You feel the urge to examine it..."
			if(8)
				H << "It is becoming difficult to resist the urge to examine it ..."
		H.examine_urge++
		H.reduce_examine_urge()

	return

/mob/living/carbon/human/proc/reduce_examine_urge()
	spawn(600)
		if(src) examine_urge--


/mob/living/simple_animal/shyguy/examine(var/userguy)
	if (istype(userguy, /mob/living/carbon/human))
		userguy << "<span class='alert'>What the hell is that thing?</span>"
		if (!(userguy in shitlist))
			shitlist += userguy
		if(will_scream)
			visible_message("<span class='danger'>[src] SCREAMS!</span>")
			playsound(get_turf(src), 'sound/voice/scream_horror1.ogg', 50, 1)
			screaming = 1
			will_scream = 0
			spawn(100)
				visible_message("<span class='danger'>[src] SCREAMS!</span>")
				playsound(get_turf(src), 'sound/voice/scream_horror1.ogg', 50, 1)
			spawn(200)
				visible_message("<span class='danger'>[src] SCREAMS!</span>")
				playsound(get_turf(src), 'sound/voice/scream_horror1.ogg', 50, 1)
			spawn(300)
				screaming = 0
		return
	..()


/mob/living/simple_animal/shyguy/proc/handle_target(var/mob/living/carbon/human/target)

	if(!target) //Sanity
		return

	if(target.stat == DEAD)
		target = null
		return

	var/turf/target_turf
	var/doom_message_played = 0

	//Send the warning that we are is homing in
	target_turf = get_turf(target)

	target << "<span class='alert'>You saw its face</span>"

	if(!scare_played) //Let's minimize the spam
		playsound(get_turf(src), pick(scare_sound), 50, 1)
		scare_played = 1
		spawn(50)
			scare_played = 0

	if(target_turf.z != z) //if z-level is different, teleport
		loc = target_turf
		target << "<span class='alert'>DID YOU THINK YOU COULD RUN?</span>"
		doom_message_played = 1

	//Rampage along a path to get to them, in the blink of an eye
	var/turf/next_turf = get_step_towards(src, target)
	var/num_turfs = get_dist(src,target)
	var/doom_message_distance = min(6, round(num_turfs/2))
	spawn()
		while(get_turf(src) != get_turf(target) && num_turfs > -10)
			//if(!check_los()) //Something is looking at us now
			//	break
			//if(!next_turf.CanPass(src, next_turf)) //We can't pass through our planned path
			//	break
			for(var/obj/structure/window/W in next_turf)
				W.health -= 1000
				W.healthcheck(1, 1, 1, src)
				sleep(1)
			for(var/obj/structure/table/O in next_turf)
				O.ex_act(1)
				sleep(1)
			for(var/obj/structure/closet/C in next_turf)
				C.ex_act(1)
				sleep(1)
			for(var/obj/structure/grille/G in next_turf)
				G.ex_act(1)
				sleep(1)
			for(var/obj/machinery/door/airlock/A in next_turf)
				//if(A.welded || A.locked) //Snowflakey code to take in account bolts and welding
				//	break
				A.open()
				sleep(1)
			for(var/obj/machinery/door/D in next_turf)
				D.open()
				sleep(1)
			//if(!next_turf.CanPass(src, next_turf)) //Once we cleared everything we could, check one last time if we can pass
			//	break

			if(num_turfs == doom_message_distance && doom_message_played == 0)
				target << "<span class='alert'>YOU SAW ITS FACE</span>"
				doom_message_played = 1

			forceMove(next_turf)
			dir = get_dir(src, target)
			next_turf = get_step(src, get_dir(next_turf,target))
			num_turfs--
			sleep(1)

//This performs an immediate murder check, meant to avoid people cheesing us by just running faster than Life() refresh
/mob/living/simple_animal/shyguy/proc/check_murder()

	//See if we're able to murder anyone
	for(var/mob/living/carbon/human/M in get_turf(src))
		if(M in shitlist)
			murder(M)
			break

/mob/living/simple_animal/shyguy/forceMove(atom/destination, var/no_tp = 0)

	..()
	check_murder()

/mob/living/simple_animal/shyguy/proc/murder(var/mob/living/target)

	if(target && ishuman(target))
		target.emote("scream")
		playsound(target.loc, pick(murder_sound), 50, 1)

		//Warn everyone
		visible_message("<span class='danger'>[src] tears [target] apart!</span>")

		target.gib()

		//Logging stuff
		target.attack_log += text("\[[time_stamp()]\] <font color='red'>has been torn apart by [src]!</font>")
		log_admin("[target] ([target.ckey]) has been torn apart by an active [src].")
		message_admins("ALERT: <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>[target.real_name]</a> has had his neck snapped by an active [src].")
		shitlist -= target
		target = null

/mob/living/simple_animal/shyguy/proc/handle_idle()

	//Movement
	if(!client && !stop_automated_movement && wander && !anchored)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Soma animals don't move when pulled
					Move(get_step(src,pick(cardinal)))
					turns_since_move = 0

	//Speaking
	if(!client && speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							emote(pick(emote_see),1)
						else
							emote(pick(emote_hear),2)
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					emote(pick(emote_see),1)
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					emote(pick(emote_hear),2)
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						emote(pick(emote_see),1)
					else
						emote(pick(emote_hear),2)

	//Do we have a vent ? Good, let's take a look
	for(entry_vent in view(1, src))
		if(prob(90)) //10 % chance to consider a vent, to try and avoid constant vent switching
			return
		visible_message("<span class='danger'>\The [src] starts trying to slide itself into the vent!</span>")
		sleep(50) //Let's stop for five seconds to do our parking job
		..()
		if(entry_vent.network && entry_vent.network.normal_members.len)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.network.normal_members)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			spawn()
				visible_message("<span class='danger'>\The [src] suddenly disappears into the vent!</span>")
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc)/2)
				spawn(travel_time)
					if(!exit_vent || exit_vent.welded)
						forceMove(get_turf(entry_vent))
						entry_vent = null
						visible_message("<span class='danger'>\The [src] suddenly appears from the vent!</span>")
						return

					forceMove(get_turf(exit_vent))
					entry_vent = null
					visible_message("<span class='danger'>\The [src] suddenly appears from the vent!</span>")
		else
			entry_vent = null


/mob/living/simple_animal/shyguy/Bump(atom/movable/AM as mob)
	..()

/mob/living/simple_animal/shyguy/Bumped(atom/movable/AM as mob, yes)
	..()

//You cannot destroy us, fool!
/mob/living/simple_animal/shyguy/ex_act(var/severity)