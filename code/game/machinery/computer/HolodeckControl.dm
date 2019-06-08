
/obj/structure/table/holotable
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon_state = "table"
	density = TRUE
	anchored = TRUE
	throwpass = 1	//You can throw objects over this, despite it's density.


/obj/structure/table/holotable/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/table/holotable/attack_animal(mob/living/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_hand(mob/user as mob)
	return // HOLOTABLE DOES NOT GIVE A FUCK


/obj/structure/table/holotable/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		to_chat(user, "It's a holotable!  There are no bolts!")

	else if(istype(I, /obj/item/grab) && get_dist(src, user) <= 1)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/L = G.grabbed_thing
		if(user.grab_level < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return

		L.forceMove(loc)
		L.KnockDown(5)
		user.visible_message("<span class='danger'>[user] puts [L] on the table.</span>")

	else
		return ..()

/obj/structure/table/holotable/wood
	name = "table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon_state = "woodtable"
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
	w_class = 4 //Stops people from hiding it in their bags/pockets

	//Can be picked up by aliens
/obj/item/toy/beach_ball/holoball/attack_paw(user as mob)
	if(!isxeno(user))
		return FALSE
	attack_alien(user)

/obj/item/toy/beach_ball/holoball/attack_alien(mob/living/carbon/xenomorph/user)
	attack_hand(user)

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/structures/misc.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	throwpass = 1
	var/side = ""
	var/id = ""

/obj/structure/holohoop/attackby(obj/item/I, mob/user, params)
	. = ..()
	
	if(istype(I, /obj/item/grab) && get_dist(src, user) <= 1)
		var/obj/item/grab/G = I
		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/L = G.grabbed_thing
		if(user.grab_level < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		L.forceMove(loc)
		L.KnockDown(5)
		for(var/obj/machinery/scoreboard/X in GLOB.machines)
			if(X.id == id)
				X.score(side, 3)// 3 points for dunking a mob
				// no break, to update multiple scoreboards
		visible_message("<span class='danger'>[user] dunks [L] into the [src]!</span>")

	else if(get_dist(src, user) < 2)
		user.transferItemToLoc(I, loc)
		for(var/obj/machinery/scoreboard/X in GLOB.machines)
			if(X.id == id)
				X.score(side)
		visible_message("<span class='notice'>[user] dunks [I] into the [src]!</span>")

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.loc = src.loc
			for(var/obj/machinery/scoreboard/X in GLOB.machines)
				if(X.id == id)
					X.score(side)
					// no break, to update multiple scoreboards
			visible_message("<span class='notice'> Swish! \the [I] lands in \the [src].</span>", 3)
		else
			visible_message("<span class='warning'> \the [I] bounces off of \the [src]'s rim!</span>", 3)
		return 0
	else
		return ..()
