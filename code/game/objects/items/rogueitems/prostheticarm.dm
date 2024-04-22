/obj/item/bodypart/l_arm/rproesthetic
	name = "wooden larm"
	desc = "A left arm of wood."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "prarm"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	sellprice = 30
	fingers = FALSE //can't swing weapons but can pick stuff up and punch

/obj/item/bodypart/l_arm/rproesthetic/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting)
		return
	if(user.zone_selected != body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		to_chat(user, "<span class='warning'>[src] isn't the right type for [parse_zone(user.zone_selected)].</span>")
		return -1
	if(user.temporarilyRemoveItemFromInventory(src))
		attach_limb(H)
		user.visible_message("<span class='notice'>[user] attaches [src] to [H].</span>")
		return 1

/obj/item/bodypart/r_arm/rproesthetic
	name = "wooden rarm"
	desc = "A right arm of wood."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "prarm"
	resistance_flags = FLAMMABLE
	obj_flags = CAN_BE_HIT
	status = BODYPART_ROBOTIC
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	sellprice = 30
	fingers = FALSE //can't swing weapons but can pick stuff up and punch

/obj/item/bodypart/r_arm/rproesthetic/attack(mob/living/M, mob/user)
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting)
		return
	if(user.zone_selected != body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
		to_chat(user, "<span class='warning'>[src] isn't the right type for [parse_zone(user.zone_selected)].</span>")
		return -1
	if(user.temporarilyRemoveItemFromInventory(src))
		attach_limb(H)
		user.visible_message("<span class='notice'>[user] attaches [src] to [H].</span>")
		return 1
