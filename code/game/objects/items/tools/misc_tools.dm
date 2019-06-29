/obj/item/tool/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "labeler0"
	item_state = "flight"

	var/label = null
	var/labels_left = 50
	var/on = FALSE


/obj/item/tool/hand_labeler/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!on)
		return
	if(!label)
		to_chat(user, "<span class='notice'>No label set.</span>")
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
	if(A.name == "[initial(A.name)] ([label])")
		to_chat(user, "<span class='notice'>It already has the same label.</span>")
		return

	user.visible_message("<span class='notice'>[user] labels [A] as \"[label]\".</span>", \
						"<span class='notice'>You label [A] as \"[label]\".</span>")
	A.name = "[initial(A.name)] ([label])"
	labels_left--


/obj/item/tool/hand_labeler/attack_self(mob/user as mob)
	on = !on
	icon_state = "labeler[on]"
	if(on)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		var/str = copytext(sanitize(input(user,"What do you want to label things as?", "Label Text", "")), 1, MAX_NAME_LEN)
		if(!str)
			to_chat(user, "<span class='notice'>Invalid label.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the label text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")


/obj/item/tool/hand_labeler/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paper))
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		labels_left = min(labels_left + 5, initial(labels_left))


/obj/item/tool/hand_labeler/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>It has [labels_left] out of [initial(labels_left)] labels left.")



/*
* Pens
*/
/obj/item/tool/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "pen"
	item_state = "pen"
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_EARS
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
	msg_admin_attack("[ADMIN_TPMONTY(usr)] used the [name] to stab [ADMIN_TPMONTY(M)].")
	return


/*
* Sleepy Pens
*/
/obj/item/tool/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags_equip_slot = ITEM_SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/tool/pen/sleepypen/Initialize()
	. = ..()
	create_reagents(30, OPENCONTAINER, list("chloralhydrate" = 22))


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
	flags_equip_slot = ITEM_SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/tool/pen/paralysis/attack(mob/living/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(M.can_inject(user,1))
		if(reagents.total_volume)
			reagents.reaction(M, INJECT)
			if(M.reagents) reagents.trans_to(M, 50)



/obj/item/tool/pen/paralysis/Initialize()
	. = ..()
	create_reagents(50, OPENCONTAINER, list("zombiepowder" = 10, "cryptobiolin" = 15))




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
	name = "chief ship engineer's rubber stamp"
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
