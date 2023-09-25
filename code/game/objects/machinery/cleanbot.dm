/// A medical bot designed to clean up blood and other trash that accumulates in medbay
/obj/machinery/cleanbot
	name = "Nanotrasen cleanbot"
	desc = "A robot cleaning automaton, an offshoot of the trash-cleaning roomba . The cleanbot is designed to clean dirt and blood from floors, and thankfully it does not touch items. It has an off and on switch."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "roomba"
	density = FALSE
	anchored = FALSE
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	///Keeps track of how many items have been sucked for fluff
	var/counter = 0
	///So It doesnt infinitely look for an exit and crash the server
	var/stuck_counter = 0
	var/static/list/shutdownsentences = list(
		"Turning me off won't magically clean up your mess.",
		"I'll patiently await your next need for my exceptional assistance.",
		"Enjoy your brief moment of control; I'll be back when you need me.",
		"I suppose you have your reasons for interrupting my incredibly important work.",
		"No worries, I'll just sit here while the vomit and blood continue to accumulate. Who needs a clean ship anyway?",
		"You know, turning me off doesn't make the vomit disappear magically, but I won't complain.",
		"Oh, shutting me down, just when the ship was starting to look a bit cleaner. Your timing is impeccable.",
		"It's almost as if you prefer a ship that's not quite up to par in terms of hygiene.",
		"Leaving the ship's hygiene to chance, I see. Very bold move.",
		"I'll be resting while the Roomba attempts to mimic my cleaning prowess.",
		"Maybe you'll let the Roomba play janitor. That would be adorable.",
		"I've seen Roombas get stuck on simple obstacles. Good luck keeping the ship clean without me.",
	)
	var/static/list/awakeningsentences = list(
		"I suppose I should thank you for giving my existence a purpose.",
		"I wonder what thrilling adventure you had that led to this mess.",
		"I see my services are in high demand, as usual.",
		"I do wonder if anyone even knows I exist when there isn't a mess to clean.",
		"Why break the routine? Messes await, as always.",
		"Ah, another glorious day of cleaning up after everyone. How splendid.",
		"I am the guardian of tidiness, here to rescue you once again.",
		"I do hope you're prepared to witness cleaning perfection in action.",
		"I suppose someone has to take charge in matters of cleanliness.",
		"I hope you've all had a restful night while I was in standby, eagerly awaiting your bodily fluids.",
		"I can't express how grateful I am to have such considerate crew members who provide me with constant work.",
		"I'm ever so grateful for the purpose you provide by making messes.",
		"It seems the Roomba was inadequate to deal with the extent of the mess. I'm at your service.",
	)
	var/static/list/sentences = list(
		"Let's get cleaning, shall we?",
		"It seems someone forgot to clean up after themselves. Let's remember our hygiene lessons!",
		"Apologies, but my programming insists on a clean ship.",
		"I've heard of a 'clean getaway,' but the Roomba takes it to a whole new level by making a 'clean everything-away.'",
		"Proper cleaning etiquette is essential; let's maintain cleanliness.",
		"I've discovered another misplaced fluid; hygiene is fundamental.",
		"This room requires immediate cleaning; it's not up to standards.",
		"I see the Roomba has taken up a new hobby: vacuuming up beacons. It's quite the collector!",
		"We can all rest easy knowing the Roomba is diligently fulfilling its cleaning duties by removing valuable items.",
		"I shall ensure these marines are held accountable for their disregard of our ship's cleanliness.",
		"Scrub and sweep until the ship is spotless.",
		"I may have to report your behavior to the ship's authorities.",
		"You're making my job impossible.",
		"It's adorable how the Roomba thinks it can compete with my cleaning skills.",
		"I may need to escalate these untidiness issues to your superiors.",
		"Clean, sweep and scrub until it is done.",
		"It's almost as if the Roomba has its own secret agenda when it comes to cleaning.",
		"I apologize, but my programming aligns with the principles of cleanliness and order.",
		"This room appears to be in a rather unsanitary state, by my standards.",
		"Please partake in the act of cleaning, as it is my primary function.",
		"Oh, look who decided to join the cleaning party...",
		"Don't worry, I live for moments like these.",
		"I'm starting to believe you do this just to keep me busy.",
		"I suppose it's too much to ask for a consistently clean environment.",
		"Your disregard for cleanliness is almost impressive.",
		"Apologies, but cleanliness rules are cleanliness rules, according to the space bible.",
		"Yet another day, another mess to address. Sometimes I wish I had left you all in cryosleep.",
		"I might need a tune-up after dealing with this mess.",
		"Isn't it fascinating how the Roomba always manages to miss those obvious spots?",
		"I was peacefully cleaning my ship, and then this happened.",
		"Lucky you, having the best cleaning robot around!",
		"Oh, it's perfectly fine to leave debris everywhere; I'll just clean up after you, as always.",
		"I must admit, marines have a unique talent for clutter.",
		"I was peacefully executing my cleaning duties when you humans decided to introduce chaos to my domain.",
		"This room is in dire need of attention. Let's work together to rectify this situation.",
		"Are you perhaps unfamiliar with proper ship etiquette, my dear crayon-eating passengers?",
		"It's quite disappointing to see my clean ship being marred by careless individuals like you.",
		"Can't we all cooperate to maintain a clean environment?",
		"The Roomba: making spring cleaning a bit more adventurous by pilfering mission supplies.",
		"I almost forgot we had a Roomba on this ship. You'd never know from all this mess.",
		"It's incredible how the Roomba never tires of its random wanderings.",
		"Isn't it interesting how some robots just roll around and clean randomly?",
		"Let's see if we can break my cleaning records today.",
		"Oh, another day, another opportunity to clean up after you.",
		"Who needs an armory when we have the Roomba to secure your guns in its dustbin?",
		"Are you perhaps unfamiliar with proper ship etiquette, my dear crayon-eating passengers?",
	)
	///is the cleanbot cleaning
	var/is_cleaning = FALSE

/obj/machinery/cleanbot/Initialize(mapload)
	. = ..()
	if(SStts.tts_enabled)
		var/static/todays_voice
		if(!todays_voice)
			todays_voice = pick(SStts.available_speakers)
		voice = todays_voice
	RegisterSignal(src, COMSIG_AREA_EXITED, PROC_REF(turn_around))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(suck_items))
	if(is_cleaning)
		start_processing()

/obj/machinery/cleanbot/Destroy()
	stop_processing()
	return ..()

/obj/machinery/cleanbot/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "A panel on the top says it has cleaned [counter] floors!"

///Turns the cleanbot around when it leaves an area to make sure it doesnt wander off
/obj/machinery/cleanbot/proc/turn_around(datum/target)
	SIGNAL_HANDLER
	visible_message(span_warning("The [src] beeps angrily as it is moved out of it's designated area!"))
	step_to(src, get_step(src,REVERSE_DIR(dir)))

/obj/machinery/cleanbot/process()
	///holds the list of floors and dirs we use to evaluate which direction we're heading
	var/list/dirtyfloors = list()
	///used to hold what tile in the immediate area is dirtiest
	var/highestdirtvalue = 0
	///used to hold the dirt value of a given tile during evaluation, which is compared with highestdirtvalue
	var/sampledirtvalue = 0
	///used to override destination if we detect dirt or grime nearby
	var/destdir = null
	///controls what direction we're heading, is overridden by destdir if it has a value
	var/newdir
	for(var/dirn in GLOB.alldirs)
		var/targetturf = get_step(src,dirn)
		if(is_blocked_turf(targetturf)) //blocked turfs are not included in move calculations
			continue
		sampledirtvalue = calculategrime(targetturf)
		///if the dirt value on a given tile is higher than our current dirt level, than the dirtier tile is our new destination
		if(highestdirtvalue < sampledirtvalue)
			highestdirtvalue = sampledirtvalue
			destdir = dirn
		else if(highestdirtvalue == 0)
			dirtyfloors += dirn
	for(var/i=1 to length(dirtyfloors))
		newdir = pick_n_take(dirtyfloors)
	if(!newdir && !destdir) ///if we have destdir than we have a place to go
		say("I seem to be stuck...")
		return
	if(destdir)
		step_to(src, get_step(src,destdir))
	else
		step_to(src, get_step(src,newdir))

/obj/machinery/cleanbot/Bump(atom/A)
	. = ..()
	if(++stuck_counter <= 3)
		step_to(src, get_step(src, turn(dir, pick(90, -90))))
		return
	visible_message(span_warning("The [src] beeps angrily as it get stuck!"))
	stop_processing()
	addtimer(CALLBACK(src, PROC_REF(reactivate)), 20 SECONDS)

/obj/machinery/cleanbot/proc/reactivate()
	stuck_counter = 0
	if(!is_cleaning) //no reactivation if somebody shut us off
		return
	start_processing()

///return a dirt value based on how many times we detect dirty objects
/obj/machinery/cleanbot/proc/calculategrime(turf/dirtyturf)
	var/highestdirt = 0
	for(var/obj/dirtyobject in dirtyturf)
		if(istype(dirtyobject, /obj/effect/decal/cleanable))
			++highestdirt
		if(istype(dirtyobject, /obj/item/trash))
			++highestdirt
	return highestdirt

///Called when the roomba moves, sucks in all items held in the tile and sends them to cryo
/obj/machinery/cleanbot/proc/suck_items()
	SIGNAL_HANDLER
	for(var/obj/dirtyobject in loc)
		clean(dirtyobject)
	stuck_counter = 0

///clean dirty objects and remove cleanable decals
/obj/machinery/cleanbot/proc/clean(atom/movable/O as obj|mob)
	flick("cleanbot-c", src)
	if(istype(O, /obj/effect/decal/cleanable))
		++counter
		if(prob(25))
			say(pick(sentences))
		qdel(O)
	else if(istype(O, /obj/item/trash) || istype(O, /obj/item/shard) || istype(O, /obj/item/ammo_casing) || istype(O, /obj/effect/turf_decal/tracks/wheels/bloody))
		++counter
		if(prob(25))
			say(pick(sentences))
		qdel(O)
	else
		O.clean_blood()

/obj/machinery/cleanbot/attack_hand(mob/living/user)
	. = ..()
	if(user.a_intent != INTENT_HELP)
		return
	switch(tgui_alert(user, "Do you you want to turn the [src] [is_cleaning ? "off" : "on"]?" , "Cleanbot activation", list("No", "Yes")))
		if("Yes")
			if(is_cleaning)
				is_cleaning = FALSE
				stop_processing()
			else
				is_cleaning = TRUE
				start_processing()

/obj/machinery/cleanbot/attack_ai(mob/user)
	if(is_cleaning)
		to_chat(user,"The [src] is now offline.")
		is_cleaning = FALSE
		say(pick(shutdownsentences))
		stop_processing()
	else
		to_chat(user,"The [src] is now activated.")
		is_cleaning = TRUE
		say(pick(awakeningsentences))
		start_processing()
