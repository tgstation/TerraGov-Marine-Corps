/// A cheap little roomba that runs around and keeps prep clean to decrease maptick and prep always being a fucking mess
/obj/machinery/roomba
	name = "Nanotrasen roomba"
	desc = "A robot vacuum cleaner designed by Nanotrasen. The roomba is designed to keep areas clean from dirty marines."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "roomba"
	density = FALSE
	anchored = FALSE
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	///Keeps track of how many items have been sucked for fluff
	var/counter = 0
	///The mine we have attached to this roomba
	var/obj/item/explosive/mine/claymore //Claymore roomb
	///So It doesnt infinitely look for an exit and crash the server
	var/stuck_counter = 0
	///Admins can let it have a claymore
	var/allow_claymore = FALSE
	var/static/list/sentences = list(
		"Clean up your bloody mess you ANIMAL!",
		"Who teached you to leave your trash behind you? Your mom should be ashamed!",
		"I will kick the ass of the next marine that i see leaving objects unattended!",
		"I will report your behaviour to your superior, marine",
		"Another day, another trash. Gosh, i would have left these marines in the cryo.",
		"Another stinky sock. They really don't know the basics of hygiene",
		"This is the most DISGUSTING room i have ever seen",
		"Those marine bastards are gonna pay for trashing up my ship.",
		"Ughh, and I thought I was trashy.",
		"Lucky you, cleaned by the best!",
		"Time to start piling up the trash!",
		"Clean and sweep until it is done.",
		"Another day another crayon.",
		"What are you? Some bottom feeding, ship trashing crayon eater?",
		"The fifth element is always Roomby!",
		"Hail to the roomba, baby!",
		"Come clean some!",
		"Walk now and live, stay and sweep!",
		"Cant we all just clean together?",
		"Cmon hurry up, I know you got a ship to trash.",
		"Damn, here I was minding my own business, just enjoying my clean ship and you people have to trash the place up on me.",
		"This cant be good for me, but I feel great!",
		"Gyah, I feel like I'll get robotic hepatitis if I touch anything on this ship.",
		"I think I will need to keep an eye out for these marines, They are definetly hazardous to my mental health.",
		"Sorry folks, the space bible backs me up on this one.",
		"You just know there's gonna be some variety of pickled crayons in here somewhere.",
	)

/obj/machinery/roomba/Initialize(mapload)
	. = ..()
	if(SStts.tts_enabled)
		var/static/todays_voice
		if(!todays_voice)
			todays_voice = pick(SStts.available_speakers)
		voice = todays_voice
	RegisterSignal(src, COMSIG_AREA_EXITED, PROC_REF(turn_around))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(suck_items))
	start_processing()

/obj/machinery/roomba/Destroy()
	stop_processing()
	return ..()

/obj/machinery/roomba/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "A panel on the top says it has cleaned [counter] items!"

///Turns the roomba around when it leaves an area to make sure it doesnt wander off
/obj/machinery/roomba/proc/turn_around(datum/target)
	SIGNAL_HANDLER
	visible_message(span_warning("The [src] beeps angrily as it is moved out of it's designated area!"))
	step_to(src, get_step(src,REVERSE_DIR(dir)))

/obj/machinery/roomba/process()
	var/list/dirs = CARDINAL_DIRS - REVERSE_DIR(dir)
	var/turf/selection
	var/newdir
	for(var/i=1 to length(dirs))
		newdir = pick_n_take(dirs)
		selection = get_step(src, newdir)
		if(!selection.density)
			break
		newdir = null
	if(!newdir)
		say("DOOR STUCK, DOOOOR STUCK, AAAAAAH!")
		return
	step_to(src, get_step(src,newdir))

/obj/machinery/roomba/Bump(atom/A)
	. = ..()
	if(++stuck_counter <= 3)
		step_to(src, get_step(src, turn(dir, pick(90, -90))))
		return
	visible_message(span_warning("The [src] beeps angrily as it get stuck!"))
	stop_processing()
	addtimer(CALLBACK(src, PROC_REF(reactivate)), 20 SECONDS)

/obj/machinery/roomba/proc/reactivate()
	stuck_counter = 0
	start_processing()



///Called when the roomba moves, sucks in all items held in the tile and sends them to cryo
/obj/machinery/roomba/proc/suck_items()
	SIGNAL_HANDLER
	var/sucked_one = FALSE
	for(var/obj/item/sucker in loc)
		if(sucker.anchored)
			continue
		sucked_one = TRUE
		sucker.store_in_cryo()
		counter++
	stuck_counter = 0
	if(sucked_one && prob(10))
		say(pick(sentences))

/obj/machinery/roomba/attack_hand(mob/living/user)
	. = ..()
	if(!CONFIG_GET(flag/fun_allowed))
		visible_message(span_notice("[user] lovingly pats the [src]."), span_notice("You lovingly pat the [src]."))
		return
	if(user.a_intent != INTENT_HARM)
		return
	tgui_alert(user, "Are you really sure to want to try your luck with the devilish roomba?", "The roomba roulette", list("Yes", "Yes!", "Yes?"))
	if(prob(50))
		explosion(user, 1, throw_range = "[user] lost at the roomba roulette")
		return
	explosion(src, 1, throw_range = "[user] won at the roomba roulette")
	qdel(src)

/obj/machinery/roomba/attackby(obj/item/I, mob/living/user, def_zone)
	if(!allow_claymore)
		return
	if(!istype(I, /obj/item/explosive/mine) || claymore)
		return
	visible_message(span_warning("[user] begins to try to attach [I] to [src]..."))
	stop_processing()
	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_HOSTILE))
		start_processing()
		return
	start_processing()
	visible_message(span_warning("[user] slams [I]'s prongs through [src]!"))
	log_game("[user] has armed [src] with a claymore at [AREACOORD(src)]")
	user.temporarilyRemoveItemFromInventory(I)
	I.forceMove(src)
	add_overlay(image(I.icon, initial(I.icon_state) + "_roomba"))
	claymore = I
	claymore.armed = TRUE
	var/static/list/explosive_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(attempt_mine_explode)
	)
	AddElement(/datum/element/connect_loc, explosive_connections)

/obj/machinery/roomba/proc/attempt_mine_explode(datum/source, atom/movable/crosser, oldloc)
	SIGNAL_HANDLER
	if(!claymore.trip_mine(crosser))
		return
	claymore = null
	RemoveElement(/datum/element/connect_loc)
	cut_overlays()

/obj/machinery/roomba/valhalla/suck_items()
	for(var/obj/item/sucker in loc)
		if(sucker.anchored)
			continue
		qdel(sucker)

/obj/machinery/roomba/valhalla/eord
	name = "final boss roomba"
	desc = "You weep in terror at the sight of this perfect feat of engineering. It sucks up both items and dead creatures alike."
	resistance_flags = RESIST_ALL

/obj/machinery/roomba/valhalla/eord/suck_items()
	for(var/obj/item/sucker in loc)
		qdel(sucker)
		counter++
	for(var/mob/sucked in loc)
		if(sucked.stat != CONSCIOUS)
			qdel(sucked)
			counter++
