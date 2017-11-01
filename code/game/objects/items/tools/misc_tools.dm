
//Snow Shovel----------
/obj/item/tool/snow_shovel
	name = "snow shovel"
	desc = "I had enough winter for this year!"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "snow_shovel"
	item_state = "shovel"
	w_class = 4.0
	force = 5.0
	throwforce = 3.0
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	flags_atom = FPRINT|CONDUCT
	flags_equip_slot = SLOT_WAIST
	var/working = 0
	var/mode = 0
		//0 = remove
		//1 = take/put
		//2 = make/remove barricade
	var/has_snow = 0//Do we have snow on it?

	//Switch modes
	attack_self(mob/user as mob)
		if(working)
			user  << "\red Finish the task first!"
			return
		has_snow = 0
		update_icon()

		if(mode == 0)
			mode = 1
			user  << "\blue You will now collect the snow so you can place it on another pile!"

		else if(mode == 1)
			mode = 2
			user  << "\blue You will now make/remove snow barricades! The deeper the layer, the stronger it is!"

		else if(mode == 2)
			mode = 0
			user  << "\blue You will now remove snow layers!"

	//Update overlay
	update_icon()
		overlays.Cut()
		if(has_snow)
			overlays += image('icons/turf/snow.dmi', "snow_shovel_overlay")

	//Examine
	examine(mob/user)
		..()
		if(mode == 0)
			user << "\blue Selected mode: Removing snow."
		else
			user << "\blue Selected mode: [mode == 1 ? "Collecting/Throwing snow" : "Building/Removing barricades"]."




/obj/item/tool/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0	//off or on.

/obj/item/tool/hand_labeler/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
	if(!mode)	//if it's off, give up.
		return
	if(A == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		user << "<span class='notice'>No labels left.</span>"
		return
	if(!label || !length(label))
		user << "<span class='notice'>No text set.</span>"
		return
	if(length(A.name) + length(label) > 64)
		user << "<span class='notice'>Label too big.</span>"
		return
	if(isliving(A))
		user << "<span class='notice'>You can't label living beings.</span>"
		return
	if(istype(A, /obj/item/reagent_container/glass))
		user << "<span class='notice'>The label will not stick to [A]. Use a pen instead.</span>"
		return

	user.visible_message("<span class='notice'>[user] labels [A] as \"[label]\".</span>", \
						 "<span class='notice'>You label [A] as \"[label]\".</span>")
	A.name = "[A.name] ([label])"

/obj/item/tool/hand_labeler/attack_self(mob/user as mob)
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		user << "<span class='notice'>You turn on \the [src].</span>"
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?", "Set label", "")), 1, MAX_NAME_LEN)
		if(!str || !length(str))
			user << "<span class='notice'>Invalid text.</span>"
			return
		label = str
		user << "<span class='notice'>You set the text to '[str]'.</span>"
	else
		user << "<span class='notice'>You turn off \the [src].</span>"





/*
 * Pens
 */
/obj/item/tool/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "pen"
	item_state = "pen"
	flags_equip_slot = SLOT_WAIST|SLOT_EAR
	throwforce = 0
	w_class = 1
	throw_speed = 7
	throw_range = 15
	matter = list("metal" = 10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2


/obj/item/tool/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/tool/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/tool/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"


/obj/item/tool/pen/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "<span class='warning'>You stab [M] with the pen.</span>"
//	M << "\red You feel a tiny prick!" //That's a whole lot of meta!
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	return


/*
 * Sleepy Pens
 */
/obj/item/tool/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags_atom = FPRINT|OPENCONTAINER
	flags_equip_slot = SLOT_WAIST
	origin_tech = "materials=2;syndicate=5"


/obj/item/tool/pen/sleepypen/New()
	var/datum/reagents/R = new/datum/reagents(30) //Used to be 300
	reagents = R
	R.my_atom = src
	R.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N
	..()
	return


/obj/item/tool/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/tool/pen/paralysis
	flags_atom = FPRINT|OPENCONTAINER
	flags_equip_slot = SLOT_WAIST
	origin_tech = "materials=2;syndicate=5"


/obj/item/tool/pen/paralysis/attack(mob/living/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(M.can_inject(user,1))
		if(reagents.total_volume)
			if(M.reagents) reagents.trans_to(M, 50)



/obj/item/tool/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("cryptobiolin", 15)
	..()

