/* Toys!
* Contains:
*		Balloons
*		Fake telebeacon
*		Fake singularity
*      Toy mechs
*		Crayons
*		Snap pops
*		Water flower
*      Dolls
*      Inflatable duck
*		Other things
*/


//recreational items

/obj/item/toy
	icon = 'icons/obj/items/toy.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/toys_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/toys_right.dmi',
	)
	throw_speed = 4
	throw_range = 20
	force = 0

/obj/item/toy/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(X)


/*
* Balloons
*/
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/balloon/Initialize(mapload)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = WEAKREF(src)

/obj/item/toy/balloon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity)
		return
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		to_chat(user, span_notice("You fill the balloon with the contents of [A]."))
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		update_icon()


/obj/item/toy/balloon/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/reagent_containers/glass))
		if(!I.reagents)
			return

		if(I.reagents.total_volume < 1)
			to_chat(user, "The [I] is empty.")
			return

		if(I.reagents.has_reagent(/datum/reagent/toxin/acid/polyacid, 1))
			to_chat(user, "The acid chews through the balloon!")
			I.reagents.reaction(user, TOUCH)
			qdel(src)
			return

		desc = "A translucent balloon with some form of liquid sloshing around in it."
		to_chat(user, span_notice("You fill the balloon with the contents of [I]."))
		I.reagents.trans_to(src, 10)

	update_icon()


/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	. = ..()
	if(!.)
		return
	if(src.reagents.total_volume >= 1)
		src.visible_message(span_warning(" The [src] bursts!"),"You hear a pop and a splash.")
		src.reagents.reaction(get_turf(hit_atom), TOUCH)
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A, TOUCH)
		src.icon_state = "burst"
		QDEL_IN(src, 5)

/obj/item/toy/balloon/update_icon_state()
	if(reagents.total_volume)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throw_speed = 4
	throw_range = 20
	force = 0
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = WEIGHT_CLASS_BULKY

/*
* Fake telebeacon
*/
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "beacon"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	item_state = "signaler"

/*
* Fake singularity
*/
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"



/*
* Crayons
*/

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Please refrain from eating it or putting it in your nose."
	icon = 'icons/obj/items/crayons.dmi'
	icon_state = "crayonred"
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("attacked", "coloured")
	var/colour = "#FF0000" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is jamming the [name] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide."))
	return (BRUTELOSS|OXYLOSS)

/*
* Snap pops
*/
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/snappop/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	. = ..()
	if(!.)
		return
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	new /obj/effect/decal/cleanable/ash(src.loc)
	src.visible_message(span_warning(" The [src.name] explodes!"),span_warning(" You hear a snap!"))
	playsound(src, 'sound/effects/snap.ogg', 25, 1)
	qdel(src)

/obj/item/toy/snappop/proc/on_cross(datum/source, atom/movable/H, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!ishuman(H)) //i guess carp and shit shouldn't set them off
		return
	var/mob/living/carbon/M = H
	if(M.m_intent != MOVE_INTENT_RUN)
		return
	to_chat(M, span_warning("You step on the snap pop!"))

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 0, src)
	s.start()
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message(span_warning(" The [src.name] explodes!"),span_warning(" You hear a snap!"))
	playsound(src, 'sound/effects/snap.ogg', 25, 1)
	qdel(src)

/*
* Water flower
*/
/obj/item/toy/waterflower
	name = "Water Flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	var/empty = 0
	flags

/obj/item/toy/waterflower/Initialize(mapload)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(10)
	reagents = R
	R.my_atom = WEAKREF(src)
	R.add_reagent(/datum/reagent/water, 10)

/obj/item/toy/waterflower/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/waterflower/afterattack(atom/A as mob|obj, mob/user as mob)

	if (istype(A, /obj/item/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		to_chat(user, span_notice("You refill your flower!"))
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		to_chat(user, span_notice("Your flower has run dry!"))
		return

	else
		src.empty = 0


		var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src))
		D.name = "water"
		D.icon = 'icons/obj/items/chemistry.dmi'
		D.icon_state = "chempuff"
		D.create_reagents(5)
		src.reagents.trans_to(D, 1)
		playsound(src.loc, 'sound/effects/spray3.ogg', 15, 1, 3)

		spawn(0)
			for(var/i=0, i<1, i++)
				step_towards(D,A)
				D.reagents.reaction(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.reaction(T)
					if(ismob(T) && T:client)
						to_chat(T:client, span_warning("[user] has sprayed you with water!"))
				sleep(0.4 SECONDS)
			qdel(D)

		return

/obj/item/toy/waterflower/examine(mob/user)
	. = ..()
	. += "[reagents.total_volume] units of water left!"



/*
* Mech prizes
*/
/obj/item/toy/prize
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		to_chat(user, span_notice("You play with [src]."))
		playsound(user, 'sound/mecha/mechstep.ogg', 15, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, span_notice("You play with [src]."))
			playsound(user, 'sound/mecha/mechturn.ogg', 15, 1)
			cooldown = world.time
			return

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"


/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/obj/item/toy/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	flags_equip_slot = ITEM_SLOT_BELT


/obj/item/toy/beach_ball
	name = "beach ball"
	icon_state = "beachball"
	item_state = "beachball"
	density = FALSE
	anchored = FALSE
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 20

/obj/item/toy/beach_ball/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	user.drop_held_item()
	throw_at(target, throw_range, throw_speed, user)


/obj/item/toy/dice
	name = "d6"
	desc = "A dice with six sides."
	icon = 'icons/obj/items/dice.dmi'
	icon_state = "d66"
	w_class = WEIGHT_CLASS_TINY
	var/sides = 6
	attack_verb = list("diced")

/obj/item/toy/dice/Initialize(mapload)
	. = ..()
	icon_state = "[name][rand(sides)]"

/obj/item/toy/dice/d20
	name = "d20"
	desc = "A dice with twenty sides."
	icon_state = "d2020"
	sides = 20

/obj/item/toy/dice/attack_self(mob/user as mob)
	var/result = rand(1, sides)
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	icon_state = "[name][result]"
	user.visible_message(span_notice("[user] has thrown [src]. It lands on [result]. [comment]"), \
						span_notice("You throw [src]. It lands on a [result]. [comment]"), \
						span_notice("You hear [src] landing on a [result]. [comment]"))



/obj/item/toy/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")


/obj/item/toy/bikehorn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, 'sound/items/bikehorn.ogg', 50)

/obj/item/toy/plush
	name = "generic doll"
	desc = "An odd looking doll, it has a tag that reads: 'if found please return to coder.'"
	w_class = WEIGHT_CLASS_TINY
	icon_state = "debug"
	attack_verb = list("thumps", "whomps", "bumps")
	var/last_hug_time

/obj/item/toy/plush/attack_self(mob/user)
	if(world.time > last_hug_time)
		user.visible_message(span_notice("[user] hugs [src]! How cute! "), \
							span_notice("You hug [src]. Dawwww... "))
		last_hug_time = world.time + 50 //5 second cooldown

/obj/item/toy/plush/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, 'sound/items/dollsqueak.ogg', 50)

/obj/item/toy/plush/farwa
	name = "Farwa plush doll"
	desc = "A Farwa plush doll. It's soft and comforting!"
	w_class = WEIGHT_CLASS_TINY
	icon_state = "farwaplush"

/obj/item/toy/plush/therapy_red
	name = "red therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is red."
	icon_state = "therapyred"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/plush/therapy_purple
	name = "purple therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is purple."
	icon_state = "therapypurple"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/plush/therapy_blue
	name = "blue therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is blue."
	icon_state = "therapyblue"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/plush/therapy_yellow
	name = "yellow therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is yellow."
	icon_state = "therapyyellow"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/plush/therapy_orange
	name = "orange therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is orange."
	icon_state = "therapyorange"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/plush/therapy_green
	name = "green therapy doll"
	desc = "A toy for therapeutic and recreational purposes. This one is green."
	icon_state = "therapygreen"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/plush/carp
	name = "carp plushie"
	desc = "An adorable stuffed toy that resembles a carp."
	icon_state = "carpplush"
	item_state = "carp_plushie"
	attack_verb = list("bites", "eats", "fin slaps")

/obj/item/toy/plush/lizard
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizard."
	icon_state = "lizplush"
	item_state = "lizplush"
	attack_verb = list("claws", "hisses", "tail slaps")

/obj/item/toy/plush/snake
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "snakeplush"
	item_state = "snakeplush"
	attack_verb = list("bites", "hisses", "tail slaps")

/obj/item/toy/plush/slime
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "slimeplush"
	item_state = "slimeplush"
	attack_verb = list("blorbles", "slimes", "absorbs")

/obj/item/toy/plush/moth
	name = "moth plushie"
	desc = "A plushie depicting an adorable mothperson. It's a huggable bug!"
	icon_state = "moffplush"
	item_state = "moffplush"
	attack_verb = list("flutters", "flaps")

/obj/item/toy/plush/rouny
	name = "rouny plushie"
	desc = "A plushie depicting a rouny, made to commemorate the centenary of the battle of LV-426. Much cuddlier and soft than the real thing."
	icon_state = "rounyplush"
	item_state = "rounyplush"
	attack_verb = list("slashes", "bites", "pounces")

#define HIGH_GNOME_MOVE_RANGE 40
#define STANDARD_GNOME_PIPE_CHANCE 50
#define GNOME_EXCLUSION_RANGE 21 //20 is the max view of a ghost

/obj/item/toy/plush/gnome
	name = "gnome"
	desc = "A mythological creature that guarded Terra's garden. You wonder why it is here."
	icon_state = "gnome"
	item_state = "gnome"
	attack_verb = list("kickes", "punches", "pounces")

/obj/item/toy/plush/gnome/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, 'sound/items/gnome.ogg', 50)

/obj/item/toy/plush/gnome/living
	resistance_flags = UNACIDABLE
	///how far the gnome should choose for teleportation purposes
	var/gnome_move_range = 5
	///how many failed teleports we've done
	var/teleport_retries = 0
	///sanity cap to prevent gnome spending too much time calculating possible teleport areas, it's theoretically possible to store the gnome in an impossible area so we need to check this
	var/max_tries = 50
	///list for keeping track of the mobs around us
	var/mob/possible_mobs = list()
	///list for keeping track of items in current gnome turf
	var/turf/targetturf
	///used for determining if a gnome is in the pipe network
	var/pipe_mode = FALSE
	///how likely are we to enter a pipe
	var/pipe_mode_chance = STANDARD_GNOME_PIPE_CHANCE
	///hold an int that determines what the interval a gnome acts
	var/gnome_act_timer
	///original gnome spawn location, used as an emergency backup
	var/gnome_origin

/obj/item/toy/plush/gnome/living/Initialize(mapload)
	. = ..()
	gnome_origin = get_turf(src)
	addtimer(CALLBACK(src, PROC_REF(gnome_act)), 5 MINUTES)
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))

///root proc for handling gnome AI routines
/obj/item/toy/plush/gnome/living/proc/gnome_act()
	///targetturf stores our position at the start of routine in all. teleport_routine uses it as a baseline for determining where to find teleport locations also
	targetturf = get_turf(src)
	gnome_act_timer = rand(4,8) MINUTES
	pipe_mode_chance = STANDARD_GNOME_PIPE_CHANCE
	if(prob(10))
		do_flavor_actions(targetturf) //flavor actions don't take being watched into account
		addtimer(CALLBACK(src, PROC_REF(gnome_act)), gnome_act_timer)
		return
	possible_mobs = list()
	for(var/mob/nearbymob in range(GNOME_EXCLUSION_RANGE, src)) //all mobs are included except animals, this means that AIs and ghosts will block gnome movement
		if(isanimal(nearbymob))
			continue
		if(isobserver(nearbymob))
			continue
		possible_mobs += nearbymob
	if(handle_pipe_mode(targetturf) && pipe_mode) //if we're in pipe_mode we return,
		addtimer(CALLBACK(src, PROC_REF(gnome_act)), gnome_act_timer)
		return
	if(isspacearea(get_area(src)))
		forceMove(gnome_origin) //we're in space, return to origin
		targetturf = get_turf(src) //reset targetturf to origin to avoid problems with teleport_routine
	gnome_move_range = gnome_move_range + teleport_retries * 3 //for each teleport retry the gnome gets a multiplier to distance, to allow it to "escape" if left unattended
	if(length(possible_mobs))
		addtimer(CALLBACK(src, PROC_REF(gnome_act)), rand(15,90) SECONDS) //we're being watched, set shorter counter so we can escape once eyes are off of us
		teleport_retries += 1 //for each time a watching mob suppresses our teleport, increment counter
		return
	else
		if(handle_ladders())
			targetturf = get_turf(src) //need to reset targetturf to new position indicated by ladder use, or teleport_routine will calculate from old position
		flick("gnome_escape", src)
		addtimer(CALLBACK(src, PROC_REF(teleport_routine), targetturf), 1.5 SECONDS) //delay just briefly so our animation can go off
	addtimer(CALLBACK(src, PROC_REF(gnome_act)), gnome_act_timer)

//handles gnome going up or down ladders
/obj/item/toy/plush/gnome/living/proc/handle_ladders()
	for(var/atom/movable/object AS in targetturf.contents)
		if(!length(targetturf.contents) || prob(60)) //possibility that we don't use a ladder
			return FALSE
		if(isladder(object))
			var/obj/structure/ladder/selectedladder = object
			if(selectedladder.up && selectedladder.down)
				pick(forceMove(get_turf(selectedladder.up)), forceMove(get_turf(selectedladder.down)))
				break
			else if(selectedladder.up)
				forceMove(get_turf(selectedladder.up))
				break
			else if(selectedladder.down)
				forceMove(get_turf(selectedladder.down))
				break
	return TRUE

///handles gnome teleportation when not being observed by players
/obj/item/toy/plush/gnome/living/proc/teleport_routine(turf/targetturf)
	var/loopcount
	while(!length(possible_mobs))
		loopcount += 1
		var/area/targetarea = get_area(targetturf)
		if(!targetarea || !targetturf)
			targetturf = get_turf(src) //somehow we've lost our turf, use the one underneath us
			continue
		//find teleport locations within radius gnome_move_range of targetturf. once found, we verify that it's valid, set our new targetturf to it and move gnome to the new location
		targetturf = locate(targetturf.x + rand(gnome_move_range * -1, gnome_move_range), targetturf.y + rand(gnome_move_range * -1, gnome_move_range), targetturf.z)
		targetarea = get_area(targetturf)
		if(get_teleport_prereqs(targetturf) || loopcount >= max_tries) //try different turfs within range until we find something that passes get_teleport_prereqs or we hit max amount of loops
			teleport_retries = 0 //teleported successfully, clear teleport_retries
			break
	forceMove(targetturf)
	flick("gnome_return", src)

///validate that the turf we're attempting to teleport to is not dense in space etc
/obj/item/toy/plush/gnome/living/proc/get_teleport_prereqs(turf/targetturf, ignore_watching_players = FALSE)
	var/area/targetarea = get_area(targetturf)
	if(!targetarea || !targetturf)
		return FALSE
	if(isclosedturf(targetturf))
		return FALSE
	if(isspaceturf(targetturf) || isspacearea(targetarea) || islava(targetturf))
		return FALSE
	for(var/atom/movable/object AS in targetturf.contents) //don't move to tiles with dense objects on them
		if(object.density)
			return FALSE
	for(var/mob/nearbymob in range(GNOME_EXCLUSION_RANGE, src)) //make sure wherever we're going doesn't have observing mobs
		if(isanimal(nearbymob))
			continue
		if(isobserver(nearbymob))
			continue
		else if(!ignore_watching_players) //if we detect any mob that's not an observer or animal we return false
			return FALSE
	return TRUE

///various flavor actions
/obj/item/toy/plush/gnome/living/proc/do_flavor_actions(turf/targetturf)
	var/randomchoice = rand(1,8)
	switch(randomchoice)
		if(1)
			pick(playsound(src, 'sound/items/gnome.ogg', 35, TRUE),
			playsound(src, 'sound/misc/robotic scream.ogg', 35, TRUE),
			playsound(src, 'sound/voice/pred_laugh1.ogg', 35, TRUE),
			playsound(src, 'sound/voice/pred_laugh2.ogg', 35, TRUE),
			playsound(src, 'sound/voice/pred_laugh3.ogg', 35, TRUE),
			playsound(src, 'sound/voice/gnomelaugh.ogg', 35, TRUE),
			playsound(src, 'sound/weapons/guns/fire/tank_cannon1.ogg', 35, TRUE),
			playsound(src, 'sound/weapons/guns/fire/tank_cannon2.ogg', 35, TRUE),
			playsound(src, 'sound/voice/pred_helpme.ogg', 35, TRUE))
		if(2)
			for(var/atom/movable/object AS in targetturf.contents)
				if(isfood(object))
					qdel(object)
					playsound(src,'sound/items/eatfood.ogg', 25, 1)
					balloon_alert_to_viewers("Consumes [object]")
					break
		if(3)
			for(var/dirn in shuffle(GLOB.alldirs))
				var/turf/destturf = get_step(src,dirn)
				if(get_teleport_prereqs(destturf, TRUE))
					forceMove(destturf)
					break
		if(4)
			desc = initial(desc)
			new /obj/item/tool/kitchen/knife/butcher(targetturf)
			new /obj/effect/decal/cleanable/blood(targetturf)
			color = COLOR_DARK_RED
			desc += " It's covered in a dried reddish liquid, probably cranberry juice."
		if(5)
			pick(balloon_alert_to_viewers("stares"),
			(balloon_alert_to_viewers("adjusts its hat")),
			(balloon_alert_to_viewers("mimes a quick stabbing motion")),
			(balloon_alert_to_viewers("rolls its eyes")),
			(balloon_alert_to_viewers("mutters something")),
			(balloon_alert_to_viewers("darts its eyes back and forth")),
			(balloon_alert_to_viewers("stifles a laugh")),
			(balloon_alert_to_viewers("blinks")),
			(balloon_alert_to_viewers("squints")),
			(balloon_alert_to_viewers("glares")),
			(balloon_alert_to_viewers("[src]'s eyes gleam malevolently")))
		if(6)
			for(var/atom/movable/object AS in targetturf.contents)
				if(isinjector(object))
					qdel(object)
					playsound(src,'sound/items/hypospray.ogg', 25, 1)
					balloon_alert_to_viewers("Injects [object] into its arm")
					break
		if(7)
			flick("gnome_hop", src)
		if(8)
			teleport_retries += 10 //gnome is getting out of here
			teleport_routine()



//handles gnome "escaping" a shuttle crush
/obj/item/toy/plush/gnome/living/proc/shuttle_crush()
	SIGNAL_HANDLER
	new /obj/item/toy/plush/gnome(gnome_origin) //shuttle crush deletes src object, create new gnome at spawn point to give illusion of escape

///handles gnome transportation using pipes
/obj/item/toy/plush/gnome/living/proc/handle_pipe_mode(turf/targetturf)
	if(!length(targetturf.contents))
		return
	pipe_mode_chance -= length(possible_mobs) * 10 //for each mob nearby subtract 10 from the chance to interact with vents
	if(!prob(pipe_mode_chance))
		return
	if(pipe_mode)
		if(length(GLOB.atmospumps))
			var/obj/machinery/atmospherics/components/unary/vent_pump/targetpump = pick(GLOB.atmospumps)
			forceMove(targetpump.loc)
			playsound(src, get_sfx("alien_ventpass"), 35, TRUE)
			pipe_mode = FALSE
	else //if we're not in pipe mode check the ground for scrubbers/vents, if we find one enter it
		for(var/atom/movable/object AS in targetturf.contents)
			if(isatmosvent(object) || isatmosscrubber(object))
				forceMove(object)
				playsound(src, get_sfx("alien_ventpass"), 35, TRUE)
				pipe_mode = TRUE

#undef HIGH_GNOME_MOVE_RANGE
#undef STANDARD_GNOME_PIPE_CHANCE
#undef GNOME_EXCLUSION_RANGE

/obj/item/toy/beach_ball/basketball
	name = "basketball"
	icon_state = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY


/obj/structure/hoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/structures/misc.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	var/side = ""
	var/id = ""


/obj/structure/hoop/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab) && get_dist(src, user) <= 1)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/L = G.grabbed_thing
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		L.forceMove(loc)
		L.Paralyze(10 SECONDS)
		for(var/obj/machinery/scoreboard/X in GLOB.machines)
			if(X.id == id)
				X.score(side, 3)// 3 points for dunking a mob
				// no break, to update multiple scoreboards
		visible_message(span_danger("[user] dunks [L] into the [src]!"))

	else if(get_dist(src, user) < 2)
		user.transferItemToLoc(I, loc)
		for(var/obj/machinery/scoreboard/X in GLOB.machines)
			if(X.id == id)
				X.score(side)
		visible_message(span_notice("[user] dunks [I] into the [src]!"))


/obj/structure/hoop/CanAllowThrough(atom/movable/mover, turf/target)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(prob(50))
			I.forceMove(loc)
			for(var/obj/machinery/scoreboard/X in GLOB.machines)
				if(X.id == id)
					X.score(side)
					// no break, to update multiple scoreboards
			visible_message(span_notice(" Swish! \the [I] lands in \the [src]."), 3)
		else
			visible_message(span_warning(" \the [I] bounces off of \the [src]'s rim!"), 3)
		return FALSE
	else
		return ..()
