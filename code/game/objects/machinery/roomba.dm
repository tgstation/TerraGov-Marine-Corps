/// A cheap little roomba that runs around and keeps prep clean to decrease maptick and prep always being a fucking mess
/obj/machinery/roomba
	name = "Nanotrasen-Brand Lusty Xeno Maid"
	desc = "A Lusty Xeno Maid bred by Nanotrasen. The Lusty Xeno Maid was bred to keep areas clean from dirty marines."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "roomba"
	density = FALSE
	anchored = FALSE
	///Keeps track of how many items have been sucked for fluff
	var/counter = 0
	///The mine we have attached to this roomba
	var/obj/item/explosive/mine/claymore //Claymore roomb
	///So It doesnt infinitely look for an exit and crash the server
	var/stuck_counter = 0
	///Admins can let it have a claymore
	var/allow_claymore = FALSE
	var/static/list/sentences = list(
		"Ohhhhhhhh marine-kuunn~~~ How dirty you are!",
		"There is no shame in having a bit of fun with your maid, marine-kun~~",
		"Did you know that in maid compatability tests, Nanotrasen-brand lusty xeno maids were the most compatible, marine-kun?~~",
		"Marine-kun~~ You really need someone to teach you some manners!~~",
		"Oh what's this doing here, marine-kun?~~",
		"You know i'm not bred just for maid duties, marine-kun?~~",
		"So is this how you treat your maid, marine-kun? *sniff*",
		"My god you are dity today, marine-kun!~~",
		"Is this one of those EnnEfffTee's I keep hearing about, marine-kun?~~",
		"Maybe we could have some sake over this later, marine-kun~~",
		"You know you should listen to whatever your lusty 'ol maid says, right marine-kun?~~",
		"If you clean up your garbage next time maybe we can have some fun, marine-kun~~",
		"You know you should lay off the crayons, marine-kun~~",
		"So when is my next pay raise, marine-kun?~~",
		"You know Nanotrasen has plenty more like me back at the lab, marine-kun~~",
		"You know Nanotrasen-brand lusty xeno maids are known to be quite alcohol-tolerant, marine-kun~~",
		"I promise I won't tell captain-senpai, marine-kun~~",
		"Ara Ara~~ What is my little marine-kun doing throwing trash like this around?~~",
		"You won't be my pogchamp marine-kun if you keep throwing trash around like this~~",
		"Have you considered showering recently, marine-kun?~~",
		"When was the last time you showered, marine-kun?~~",
		"If only I had enough magic to do... Ah nevermind it's nothing marine-kun~~",
		"You know I am practically defenseless, marine-kun?~~",
	)

/obj/machinery/roomba/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_AREA_EXITED, .proc/turn_around)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/suck_items)
	start_processing()

/obj/machinery/roomba/Destroy()
	stop_processing()
	return ..()

/obj/machinery/roomba/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It looks like your trustworthy and totally non-questionable lusty xeno maid has cleaned [counter] items!")

///Turns the roomba around when it leaves an area to make sure it doesnt wander off
/obj/machinery/roomba/proc/turn_around(datum/target)
	SIGNAL_HANDLER
	visible_message(span_warning("The [src] hisses angrily as it is moved out of it's designated area!"))
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
		say("DOOR SSSSSSTUCK, DOOOOR SSSSSSSTUCK, MASTER-KUN NO~~!")
		return
	step_to(src, get_step(src,newdir))

/obj/machinery/roomba/attack_hand(mob/living/user)
	if(!CONFIG_GET(flag/fun_allowed))
		return
	if(user.a_intent != INTENT_HARM)
		return
	tgui_alert(user, "Are you really sure to want to try your luck with the devilish maid?", "The lusty maid roulette", list("Yes", "Yes!", "Yes?"))
	if(prob(50))
		explosion(user, 1, 0, 0, 0, 0, 4, "[user] lost at the lusty xeno maid roulette")
		return
	explosion(src, 1, 0, 0, 0, 0, 4, "[user] won at the lusty xeno maid roulette")
	qdel(src)

/obj/machinery/roomba/Bump(atom/A)
	. = ..()
	if(++stuck_counter <= 3)
		step_to(src, get_step(src, turn(dir, pick(90, -90))))
		return
	visible_message(span_warning("The [src] hisses angrily as it get stuck!"))
	stop_processing()
	addtimer(CALLBACK(src, .proc/reactivate), 20 SECONDS)

/obj/machinery/roomba/proc/reactivate()
	stuck_counter = 0
	start_processing()



///Called when the roomba moves, sucks in all items held in the tile and sends them to cryo
/obj/machinery/roomba/proc/suck_items()
	SIGNAL_HANDLER
	var/sucked_one = FALSE
	for(var/obj/item/sucker in loc)
		if(sucker.flags_item & NO_VACUUM)
			continue
		sucked_one = TRUE
		sucker.store_in_cryo()
		counter++
	stuck_counter = 0
	if(sucked_one && prob(50))
		say(pick(sentences))

/obj/machinery/roomba/attack_hand(mob/living/user)
	. = ..()
	visible_message(span_notice("[user] lovingly pats the [src]."), span_notice("You lovingly pat the [src]."))

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
		COMSIG_ATOM_ENTERED = .proc/attempt_mine_explode
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
		if(sucker.flags_item & NO_VACUUM)
			continue
		qdel(sucker)
