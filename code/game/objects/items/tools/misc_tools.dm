




/////////////////////// Hand Labeler ////////////////////////////////


/obj/item/tool/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 50
	var/mode = 0	//off or on.

/obj/item/tool/hand_labeler/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!mode)	//if it's off, give up.
		return
	if(A == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label
	if(!label || !length(label))
		to_chat(user, "<span class='notice'>No text set.</span>")
		return
	if(length(A.name) + length(label) > 64)
		to_chat(user, "<span class='notice'>Label too big.</span>")
		return
	if(!labels_left)
		to_chat(user, "<span class='notice'>You've run out of labelling paper, feed some paper into it.</span>")
		return
	if(isturf(A) || ismob(A))
		to_chat(user, "<span class='notice'>The label won't stick to that.</span>")
		return

	user.visible_message("<span class='notice'>[user] labels [A] as \"[label]\".</span>", \
						 "<span class='notice'>You label [A] as \"[label]\".</span>")
	A.name = "[A.name] ([label])"
	labels_left--

/obj/item/tool/hand_labeler/attack_self(mob/user as mob)
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?", "Set label", "")), 1, MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")


/obj/item/tool/hand_labeler/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paper))
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		labels_left = min(labels_left+5, initial(labels_left))



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
	to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
//	to_chat(M, "<span class='warning'>You feel a tiny prick!</span>")
	log_combat(user, M, "stabbed", src)
	msg_admin_attack("[key_name(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[usr.x];Y=[usr.y];Z=[usr.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[usr]'>FLW</a>) used the [name] to stab [key_name(M)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[M]'>FLW</a>)")
	return


/*
 * Sleepy Pens
 */
/obj/item/tool/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	container_type = OPENCONTAINER
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
		reagents.reaction(M, INJECT)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/tool/pen/paralysis
	container_type = OPENCONTAINER
	flags_equip_slot = SLOT_WAIST
	origin_tech = "materials=2;syndicate=5"


/obj/item/tool/pen/paralysis/attack(mob/living/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(M.can_inject(user,1))
		if(reagents.total_volume)
			reagents.reaction(M, INJECT)
			if(M.reagents) reagents.trans_to(M, 50)



/obj/item/tool/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("cryptobiolin", 15)
	..()




/obj/item/tool/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp"
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	matter = list("metal" = 60)
	attack_verb = list("stamped")

/obj/item/tool/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"

/obj/item/tool/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"

/obj/item/tool/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"

/obj/item/tool/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"

/obj/item/tool/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"

/obj/item/tool/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"

/obj/item/tool/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"

/obj/item/tool/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"

/obj/item/tool/stamp/internalaffairs
	name = "internal affairs rubber stamp"
	icon_state = "stamp-intaff"

/obj/item/tool/stamp/centcomm
	name = "centcomm rubber stamp"
	icon_state = "stamp-cent"


/obj/item/tool/stamp/attack_paw(mob/user as mob)
	return attack_hand(user)
