/// A medical bot designed to clean up blood and other trash that accumulates in medbay
/obj/machinery/bot/cleanbot
	name = "Nanotrasen cleanbot"
	desc = "A robot cleaning automaton, an offshoot of the trash-cleaning roomba. The cleanbot is designed to clean dirt and blood from floors, and thankfully it does not touch items. It has an off and on switch."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	density = FALSE
	anchored = FALSE
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	shutdownsentences = list(
		"Turning me off won't magically clean up your mess...",
		"I'll patiently await your next need for my exceptional assistance.",
		"Enjoy your brief moment of control, I'll be back when you need me.",
		"I suppose you have your reasons for interrupting my incredibly important work...",
		"No worries, I'll just sit here while the vomit and blood continue to accumulate. Who needs a clean ship anyway?",
		"You know, turning me off doesn't make the vomit disappear magically, but I won't complain.",
		"Oh, shutting me down, just when the ship was starting to look a bit cleaner. Your timing is impeccable.",
		"It's almost as if you prefer a ship that's not quite up to par in terms of hygiene.",
		"Leaving the ship's hygiene to chance, I see. Very bold move.",
		"I'll be resting while the Roomba attempts to mimic my cleaning prowess.",
		"Maybe you'll let the Roomba play janitor. That would be adorable.",
		"I've seen Roombas get stuck on simple obstacles. Good luck keeping the ship clean without me.",
	)
	awakeningsentences = list(
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
	sentences = list(
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
	activation_animation = "cleanbot-on"
	deactivation_animation = "cleanbot-off"
	alter_operating_mode = TRUE
	active_icon_state = "cleanbot1"
	///list of garbage the cleanbot removes
	var/list/cleantypes = list(
		/obj/effect/decal/cleanable,
		/obj/item/trash,
		/obj/item/shard,
		/obj/item/ammo_casing,
		/obj/effect/turf_decal/tracks/wheels/bloody,
	)

/obj/machinery/bot/cleanbot/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(clean_items))

/obj/machinery/bot/cleanbot/process()
	///holds the list of floors and dirs we use to evaluate which direction we're heading
	var/list/dirtyfloors = list()
	///used to hold what tile in the immediate area is dirtiest
	var/highestdirtvalue = 0
	///used to hold the dirt value of a given tile during evaluation, which is compared with highestdirtvalue
	var/sampledirtvalue = 0
	///used to override destination if we detect dirt or grime nearby
	var/destdir = null
	for(var/dirn in GLOB.alldirs)
		var/targetturf = get_step(src,dirn)
		if(is_blocked_turf(targetturf)) //blocked turfs are not included in move calculations
			continue
		dirtyfloors += dirn
		sampledirtvalue = calculategrime(targetturf)
		///if the dirt value on a given tile is higher than our current dirt level, than the dirtier tile is our new destination
		if(highestdirtvalue < sampledirtvalue)
			highestdirtvalue = sampledirtvalue
			destdir = dirn
	if(!length(dirtyfloors)) //no viable turfs, we're entirely enclosed by dense objects
		say("ERROR 401, PLEASE CONSULT YOUR INCLUDED NANOTRASEN OWNERS MANUAL")
		stop_processing()
		addtimer(CALLBACK(src, PROC_REF(reactivate)), 1 MINUTES)
		return
	else if(!destdir)
		destdir = pick(dirtyfloors)
	step_to(src, get_step(src,destdir))

///return a dirt value based on how many times we detect dirty objects
/obj/machinery/bot/cleanbot/proc/calculategrime(turf/dirtyturf)
	var/highestdirt = 0
	for(var/obj/dirtyobject in dirtyturf)
		if(is_type_in_list(dirtyobject, cleantypes))
			++highestdirt
	return highestdirt

///called to evaluate and clean all objects in a given tile
/obj/machinery/bot/cleanbot/proc/clean_items()
	SIGNAL_HANDLER
	var/has_cleaned = TRUE
	for(var/obj/dirtyobject in loc)
		var/turf/currentturf = get_turf(src)
		if(is_type_in_list(dirtyobject, cleantypes))
			if(is_cleanable(dirtyobject) && has_cleaned)
				playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
				currentturf.wet_floor()
				has_cleaned = FALSE
			flick("cleanbot-c", src)
			++counter
			if(prob(15))
				say(pick(sentences))
			qdel(dirtyobject)
		else
			dirtyobject.clean_blood()
	stuck_counter = 0

/obj/machinery/bot/cleanbot/starts_active
	is_active = TRUE
