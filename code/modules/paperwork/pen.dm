/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = ""
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=10)
	pressure_resistance = 2
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black"	//what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT

/obj/item/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return(BRUTELOSS)

/obj/item/pen/blue
	desc = ""
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = ""
	icon_state = "pen_red"
	colour = "red"

/obj/item/pen/invisible
	desc = ""
	icon_state = "pen"
	colour = "white"

/obj/item/pen/fourcolor
	desc = ""
	name = "four-color pen"
	colour = "black"

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
		if("red")
			colour = "green"
		if("green")
			colour = "blue"
		else
			colour = "black"
	to_chat(user, "<span class='notice'>\The [src] will now write in [colour].</span>")
	desc = ""

/obj/item/pen/fountain
	name = "fountain pen"
	desc = ""
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = ""
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	custom_materials = list(/datum/material/gold = 750)
	sharpness = IS_SHARP
	resistance_flags = FIRE_PROOF
	unique_reskin = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)

/obj/item/pen/fountain/captain/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 200, 115) //the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = ""

/obj/item/pen/attack_self(mob/living/carbon/user)
//	var/deg = input(user, "What angle would you like to rotate the pen head to? (1-360)", "Rotate Pen Head") as null|num
//	if(deg && (deg > 0 && deg <= 360))
//		degrees = deg
//		to_chat(user, "<span class='notice'>I rotate the top of the pen to [degrees] degrees.</span>")
//		SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)
	return

/obj/item/pen/attack(mob/living/M, mob/user,stealth)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			to_chat(user, "<span class='warning'>I stab [M] with the pen.</span>")
			if(!stealth)
				to_chat(M, "<span class='danger'>I feel a tiny prick!</span>")
			. = 1

		log_combat(user, M, "stabbed", src)

	else
		. = ..()

/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()
	//Changing Name/Description of items. Only works if they have the 'unique_rename' flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = input(user, "What would you like to edit?", "Rename or change description?") as null|anything in list("Rename","Change description")
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		if(penchoice == "Rename")
			var/input = stripped_input(user,"What do you want to name \the [O.name]?", ,"", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(oldname == input)
				to_chat(user, "<span class='notice'>I changed \the [O.name] to... well... \the [O.name].</span>")
			else
				O.name = input
				to_chat(user, "<span class='notice'>\The [oldname] has been successfully been renamed to \the [input].</span>")
				O.renamedByPlayer = TRUE

		if(penchoice == "Change description")
			var/input = stripped_input(user,"Describe \the [O.name] here", ,"", 100)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			O.desc = input
			to_chat(user, "<span class='notice'>I have successfully changed \the [O.name]'s description.</span>")

/*
 * Sleepypens
 */

/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)
				reagents.reaction(M, INJECT, reagents.total_volume)
				reagents.trans_to(M, reagents.total_volume, transfered_by = user)


/obj/item/pen/sleepy/Initialize()
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off
	sharpness = IS_SHARP
	var/on = FALSE

/obj/item/pen/edagger/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 100, 0, 'sound/blank.ogg')

/obj/item/pen/edagger/get_sharpness()
	return on * sharpness

/obj/item/pen/edagger/suicide_act(mob/user)
	. = BRUTELOSS
	if(on)
		user.visible_message("<span class='suicide'>[user] forcefully rams the pen into their mouth!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is holding a pen up to their mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		attack_self(user)

/obj/item/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		throw_speed = initial(throw_speed)
		w_class = initial(w_class)
		name = initial(name)
		hitsound = initial(hitsound)
		embedding = embedding.setRating(embed_chance = EMBED_CHANCE)
		throwforce = initial(throwforce)
		playsound(user, 'sound/blank.ogg', 5, TRUE)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
	else
		on = TRUE
		force = 18
		throw_speed = 4
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		hitsound = 'sound/blank.ogg'
		embedding = embedding.setRating(embed_chance = 100) //rule of cool
		throwforce = 35
		playsound(user, 'sound/blank.ogg', 5, TRUE)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	update_icon()

/obj/item/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
