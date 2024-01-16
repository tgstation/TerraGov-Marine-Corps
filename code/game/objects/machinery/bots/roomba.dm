/// A cheap little roomba that runs around and keeps prep clean to decrease maptick and prep always being a fucking mess
/obj/machinery/bot/roomba
	name = "Nanotrasen roomba"
	desc = "A robot vacuum cleaner designed by Nanotrasen. The roomba is designed to keep areas clean from dirty marines."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "roomba"
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"
	///The mine we have attached to this roomba
	var/obj/item/explosive/mine/claymore //Claymore roomb
	///Admins can let it have a claymore
	var/allow_claymore = FALSE
	sentences = list(
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
	is_active = TRUE
	active_icon_state = "roomba"

/obj/machinery/bot/roomba/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(suck_items))

///Called when the roomba moves, sucks in all items held in the tile and sends them to cryo
/obj/machinery/bot/roomba/proc/suck_items()
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

/obj/machinery/bot/roomba/attack_hand(mob/living/user)
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

/obj/machinery/bot/roomba/attackby(obj/item/I, mob/living/user, def_zone)
	if(!allow_claymore)
		return
	if(!istype(I, /obj/item/explosive/mine) || claymore)
		return
	visible_message(span_warning("[user] begins to try to attach [I] to [src]..."))
	stop_processing()
	if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_HOSTILE))
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

/obj/machinery/bot/roomba/proc/attempt_mine_explode(datum/source, atom/movable/crosser, oldloc)
	SIGNAL_HANDLER
	if(!claymore.trip_mine(crosser))
		return
	claymore = null
	RemoveElement(/datum/element/connect_loc)
	cut_overlays()

/obj/machinery/bot/roomba/valhalla/suck_items()
	for(var/obj/item/sucker in loc)
		if(sucker.anchored)
			continue
		qdel(sucker)

/obj/machinery/bot/roomba/valhalla/eord
	name = "final boss roomba"
	desc = "You weep in terror at the sight of this perfect feat of engineering. It sucks up both items and dead creatures alike."
	resistance_flags = RESIST_ALL

/obj/machinery/bot/roomba/valhalla/eord/suck_items()
	for(var/obj/item/sucker in loc)
		qdel(sucker)
		counter++
	for(var/mob/sucked in loc)
		if(sucked.stat != CONSCIOUS)
			qdel(sucked)
			counter++
