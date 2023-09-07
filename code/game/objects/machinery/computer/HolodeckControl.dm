
/obj/structure/table/holotable
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	density = TRUE
	anchored = TRUE

/obj/structure/table/holotable/attack_animal(mob/living/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_hand(mob/living/user)
	return TRUE


/obj/structure/table/holotable/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		to_chat(user, "It's a holotable!  There are no bolts!")

	else if(istype(I, /obj/item/grab) && get_dist(src, user) <= 1)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/L = G.grabbed_thing
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return

		L.forceMove(loc)
		L.Paralyze(10 SECONDS)
		user.visible_message(span_danger("[user] puts [L] on the table."))

	else
		return ..()

/obj/structure/table/holotable/wood
	name = "table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon = 'icons/obj/smooth_objects/wood_table_reinforced.dmi'
	base_icon_state = "wood_table_reinforced"
	icon_state = "woodtable-0"
	table_prefix = "wood"

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = TRUE
	layer = WINDOW_LAYER
	anchored = TRUE
	flags_atom = ON_BORDER




//BASKETBALL OBJECTS

/obj/item/toy/beach_ball/holoball
	name = "basketball"
	icon_state = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/item/toy/beach_ball/holoball/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(X)

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/structures/misc.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	var/side = ""
	var/id = ""

/obj/structure/holohoop/attackby(obj/item/I, mob/user, params)
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

/obj/structure/holohoop/CanAllowThrough(atom/movable/mover, turf/target)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(prob(50))
			I.loc = src.loc
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
