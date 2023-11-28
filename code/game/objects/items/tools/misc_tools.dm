/obj/item/tool/hand_labeler
	name = "hand labeler"
	desc = "A hand labeler used to label objects"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	w_class = WEIGHT_CLASS_SMALL

	var/label = null
	var/labels_left = 50
	var/on = FALSE


/obj/item/tool/hand_labeler/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!on)
		return
	if(!label)
		to_chat(user, span_notice("No label set."))
		return
	if(length(A.name) + length(label) > 64)
		to_chat(user, span_notice("Label too big."))
		return
	if(!labels_left)
		to_chat(user, span_notice("You've run out of labelling paper, feed some paper into it."))
		return
	if(isturf(A) || ismob(A))
		to_chat(user, span_notice("The label won't stick to that."))
		return
	if(A.name == "[initial(A.name)] ([label])")
		to_chat(user, span_notice("It already has the same label."))
		return

	user.visible_message(span_notice("[user] labels [A] as \"[label]\"."), \
						span_notice("You label [A] as \"[label]\"."))
	A.name = "[initial(A.name)] ([label])"
	labels_left--


/obj/item/tool/hand_labeler/attack_self(mob/user as mob)
	on = !on
	icon_state = "labeler[on]"
	if(on)
		to_chat(user, span_notice("You turn on \the [src]."))
		var/str = reject_bad_text(stripped_input(user, "Label text?", "Set label","", MAX_NAME_LEN))
		if(!str)
			to_chat(user, span_notice("Invalid label."))
			return
		label = str
		to_chat(user, span_notice("You set the label text to '[str]'."))
	else
		to_chat(user, span_notice("You turn off \the [src]."))


/obj/item/tool/hand_labeler/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paper))
		to_chat(user, span_notice("You insert [I] into [src]."))
		qdel(I)
		labels_left = min(labels_left + 5, initial(labels_left))


/obj/item/tool/hand_labeler/examine(mob/user)
	. = ..()
	. += span_notice("It has [labels_left] out of [initial(labels_left)] labels left.")



/*
* Pens
*/
/obj/item/tool/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "pen"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/civilian_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/civilian_right.dmi',
	)
	item_state = "pen"
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 7
	throw_range = 15
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
	to_chat(user, span_warning("You stab [M] with the pen."))
//	to_chat(M, span_warning("You feel a tiny prick!"))
	log_combat(user, M, "stabbed", src)


/*
* Sleepy Pens
*/
/obj/item/tool/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags_equip_slot = ITEM_SLOT_BELT


/obj/item/tool/pen/sleepypen/Initialize(mapload)
	. = ..()
	create_reagents(30, OPENCONTAINER, list(/datum/reagent/toxin/chloralhydrate = 22))


/obj/item/tool/pen/sleepypen/attack(mob/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	. = ..()
	if(reagents.total_volume)
		reagents.reaction(M, INJECT)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150



/*
* Parapens
*/
/obj/item/tool/pen/paralysis
	flags_equip_slot = ITEM_SLOT_BELT


/obj/item/tool/pen/paralysis/attack(mob/living/M as mob, mob/user as mob)
	if(!(istype(M,/mob)))
		return
	..()
	if(M.can_inject(user,1))
		if(reagents.total_volume)
			reagents.reaction(M, INJECT)
			if(M.reagents) reagents.trans_to(M, 50)



/obj/item/tool/pen/paralysis/Initialize(mapload)
	. = ..()
	create_reagents(50, OPENCONTAINER, list(/datum/reagent/toxin/huskpowder = 10, /datum/reagent/cryptobiolin = 15))




/obj/item/tool/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "stamp-qm"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/civilian_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/civilian_right.dmi',
	)
	item_state = "stamp"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	attack_verb = list("stamped")

/obj/item/tool/stamp/qm
	name = "Quartermaster's Stamp"

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

/obj/item/tool/stamp/centcom
	name = "centcom rubber stamp"
	icon_state = "stamp-cent"
