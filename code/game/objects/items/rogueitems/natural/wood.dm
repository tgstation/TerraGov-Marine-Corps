/obj/item/grown/log/tree
	icon = 'icons/roguetown/items/natural.dmi'
	seed = null
	name = "log"
	desc = ""
	icon_state = "log"
	blade_dulling = DULLING_CUT
	max_integrity = 30
	static_debris = list(/obj/item/grown/log/tree/small = 2)
	obj_flags = CAN_BE_HIT
	resistance_flags = FLAMMABLE
	twohands_required = TRUE
	gripped_intents = list(/datum/intent/hit)
	possible_item_intents = list(/datum/intent/hit)
	obj_flags = CAN_BE_HIT
	w_class = WEIGHT_CLASS_HUGE

/obj/item/grown/log/tree/small
	name = "small log"
	icon_state = "logsmall"
	max_integrity = 30
	static_debris = list(/obj/item/grown/log/tree/stick = 3)
	firefuel = 20 MINUTES
	twohands_required = FALSE
	gripped_intents = null
	w_class = WEIGHT_CLASS_BULKY
	smeltresult = /obj/item/rogueore/coal

/obj/item/grown/log/tree/stick
	seed = null
	name = "stick"
	icon_state = "stick1"
	desc = ""
	blade_dulling = 0
	max_integrity = 20
	static_debris = null
	firefuel = 5 MINUTES
	obj_flags = null
	w_class = WEIGHT_CLASS_NORMAL
	twohands_required = FALSE
	gripped_intents = null
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP

/obj/item/grown/log/tree/stick/Crossed(mob/living/L)
	. = ..()
	if(istype(L))
		var/prob2break = 33
		if(L.m_intent == MOVE_INTENT_SNEAK)
			prob2break = 0
		if(L.m_intent == MOVE_INTENT_RUN)
			prob2break = 100
		if(prob(prob2break))
			playsound(src,'sound/items/seedextract.ogg', 100, FALSE)
			qdel(src)
			L.consider_ambush()

/obj/item/grown/log/tree/stick/Initialize()
	icon_state = "stick[rand(1,2)]"
	..()

/obj/item/grown/log/tree/stick/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] snaps [src].</span>")
	playsound(user,'sound/items/seedextract.ogg', 100, FALSE)
	qdel(src)

/obj/item/grown/log/tree/stick/attackby(obj/item/I, mob/living/user, params)
	var/mob/living/carbon/human/H = user
	user.changeNext_move(CLICK_CD_MELEE)
	if(user.used_intent?.blade_class == BCLASS_CUT)
		playsound(get_turf(src.loc), 'sound/items/wood_sharpen.ogg', 100)
		if(do_after(user, 20))
			user.visible_message("<span class='notice'>[user] sharpens [src].</span>")
			var/obj/item/grown/log/tree/stake/S = new /obj/item/grown/log/tree/stake(get_turf(src.loc))
			if(user.is_holding(src))
				user.dropItemToGround(src)
				user.put_in_hands(S)
			qdel(src)
		else
			user.visible_message("<span class='warning'>[user] sharpens [src].</span>")
		return
	if(istype(I, /obj/item/grown/log/tree/stick))
		var/obj/item/natural/bundle/stick/F = new(src.loc)
		H.put_in_hands(F)
		H.visible_message("[user] ties the sticks into a bundle.")
		qdel(I)
		qdel(src)
	if(istype(I, /obj/item/natural/bundle/stick))
		var/obj/item/natural/bundle/stick/B = I
		if(B.amount <= 9)
			H.visible_message("[user] adds the [src] to the bundle.")
			B.amount += 1
			qdel(src)
	..()

/obj/item/grown/log/tree/stake
	name = "stake"
	icon_state = "stake"
	desc = ""
	force = 10
	throwforce = 5
	possible_item_intents = list(/datum/intent/stab, /datum/intent/pick)
	firefuel = 1 MINUTES
	blade_dulling = 0
	max_integrity = 20
	static_debris = null
	obj_flags = null
	w_class = WEIGHT_CLASS_SMALL
	twohands_required = FALSE
	gripped_intents = null
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HIP

/obj/item/grown/log/tree/lumber
	seed = null
	name = "lumber"
	icon_state = "lumber"
	desc = ""
	blade_dulling = 0
	max_integrity = 50
	firefuel = 5 MINUTES
