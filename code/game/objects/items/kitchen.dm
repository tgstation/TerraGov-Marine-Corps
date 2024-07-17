/* Kitchen tools
 * Contains:
 * Fork
 * Kitchen knives
 * Rolling Pins
 * Plastic Utensils
 */

#define PLASTIC_BREAK_PROBABILITY 25

/obj/item/kitchen
	icon = 'icons/obj/service/kitchen.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/kitchen_righthand.dmi',
	)

/obj/item/kitchen/Initialize(mapload)
	. = ..()

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 4
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("attack", "stab", "poke")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette

/datum/armor/kitchen_fork
	fire = 50
	acid = 30

/obj/item/kitchen/fork/Initialize(mapload)
	. = ..()

/obj/item/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(forkload)
		if(M == user)
			M.visible_message(span_notice("[user] eats a delicious forkful of omelette!"))
			M.reagents.add_reagent(forkload.type, 1)
		else
			M.visible_message(span_notice("[user] feeds [M] a delicious forkful of omelette!"))
			M.reagents.add_reagent(forkload.type, 1)
		icon_state = "fork"
		forkload = null
	else
		return ..()

/obj/item/kitchen/fork/plastic
	name = "plastic fork"
	desc = "Really takes you back to highschool lunch."
	icon_state = "plastic_fork"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0

/obj/item/kitchen/fork/plastic/Initialize(mapload)
	. = ..()

/obj/item/knife/kitchen
	name = "kitchen knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."

/obj/item/knife/plastic
	name = "plastic knife"
	icon_state = "plastic_knife"
	worn_icon_state  = "knife"
	desc = "A very safe, barely sharp knife made of plastic. Good for cutting food and not much else."
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_range = 5
	attack_verb = list("prod", "whiff", "scratch", "poke")
	sharpness = SHARP_EDGED

/obj/item/knife/plastic/Initialize(mapload)
	. = ..()

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "rolling_pin"
	worn_icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/illegal
	name = "metal rolling pin"
	desc = "A heavy metallic rolling pin used to bash in those annoying ingredients."
	icon_state = "metal_rolling_pin"
	worn_icon_state  = "metal_rolling_pin"
	force = 12

/* Trays  moved to /obj/item/storage/bag */

/obj/item/kitchen/spoon
	name = "spoon"
	desc = "Just be careful your food doesn't melt the spoon first."
	icon_state = "spoon"
	base_icon_state = "spoon"
	w_class = WEIGHT_CLASS_TINY
	force = 2
	throw_speed = 3
	throw_range = 5
	attack_verb = list("whacks", "spoons", "taps")
	tool_behaviour = TOOL_MINING
	toolspeed = 25 // Literally 25 times worse than the base pickaxe

	var/spoon_sip_size = 5

/obj/item/kitchen/spoon/Initialize(mapload)
	. = ..()
	create_reagents(5, INJECTABLE|OPENCONTAINER|DUNKABLE)

/obj/item/kitchen/spoon/create_reagents(max_vol, flags)
	. = ..()


/obj/item/kitchen/spoon/on_reagent_change(datum/reagents/reagents, ...)
	update_appearance(UPDATE_OVERLAYS)
	return NONE

/obj/item/kitchen/spoon/update_overlays()
	. = ..()
	if(reagents.total_volume <= 0)
		return
	var/mutable_appearance/filled_overlay = mutable_appearance(icon, "[base_icon_state]_filled")
	filled_overlay.color = mix_color_from_reagents(reagents.reagent_list)
	. += filled_overlay

/obj/item/kitchen/spoon/attack(mob/living/target_mob, mob/living/user, params)
	if(!target_mob.reagents || reagents.total_volume <= 0)
		return  ..()
	var/mob/living/carbon/human/H = target_mob
	if((H.head && (H.head.inventory_flags & COVERMOUTH)) || (H.wear_mask && (H.wear_mask.inventory_flags & COVERMOUTH)))
		if(H == user)
			H.balloon_alert(user, "can't eat with mouth covered!")
		else
			H.balloon_alert(user, "[target_mob.p_their()] mouth is covered!")
		return TRUE

	if(target_mob == user)
		user.visible_message(
			span_notice("[user] scoops a spoonful into [user.p_their()] mouth."),
			span_notice("You scoop a spoonful into your mouth.")
		)

	else
		to_chat(target_mob, span_userdanger("["[user]"] forces a spoon into your face!"))
		target_mob.balloon_alert(user, "feeding spoonful...")
		if(!do_after(user, 3 SECONDS, target_mob))
			target_mob.balloon_alert(user, "interrupted!")
			return TRUE
		user.visible_message(
			span_danger("[user] scoops a spoonful into [target_mob]'s mouth."),
			span_notice("You scoop a spoonful into [target_mob]'s mouth.")
		)

	playsound(target_mob, 'sound/items/drink.ogg', rand(10,50), vary = TRUE)
	reagents.trans_to(target_mob, spoon_sip_size)
	return TRUE

/obj/item/kitchen/spoon/pre_attack(atom/attacked_atom, mob/living/user, params)
	. = ..()
	if(.)
		return
	if(isliving(attacked_atom))
		return
	if(!attacked_atom.is_open_container())
		return
	if(reagents.total_volume <= 0)
		return

	var/amount_given = reagents.trans_to(attacked_atom, reagents.maximum_volume)
	if(amount_given >= reagents.total_volume)
		attacked_atom.balloon_alert(user, "spoon emptied")
	else if(amount_given > 0)
		attacked_atom.balloon_alert(user, "spoon partially emptied")
	else
		attacked_atom.balloon_alert(user, "it's full!")
	return TRUE

/obj/item/kitchen/spoon/attack_hand_alternate(atom/attacked_atom, mob/living/user, params)
	. = ..()
	if(isliving(attacked_atom))
		return
	if(!attacked_atom.is_open_container())
		return
	if(reagents.total_volume >= reagents.maximum_volume || attacked_atom.reagents.total_volume <= 0)
		return

	if(attacked_atom.reagents.trans_to(src, reagents.maximum_volume))
		attacked_atom.balloon_alert(user, "grabbed spoonful")
	else
		attacked_atom.balloon_alert(user, "spoon is full!")
	return

/obj/item/kitchen/spoon/plastic
	name = "plastic spoon"
	icon_state = "plastic_spoon"
	force = 0
	toolspeed = 75 // The plastic spoon takes 5 minutes to dig through a single mineral turf... It's one, continuous, breakable, do_after...

/obj/item/kitchen/spoon/plastic/Initialize(mapload)
	. = ..()

/obj/item/kitchen/spoon/soup_ladle
	name = "ladle"
	desc = "What is a ladle but a comically large spoon?"
	icon_state = "ladle"
	base_icon_state = "ladle"
	worn_icon_state  = "spoon"
	spoon_sip_size = 3 // just a taste

/obj/item/kitchen/spoon/soup_ladle/Initialize(mapload)
	. = ..()
	create_reagents(SOUP_SERVING_SIZE + 5, INJECTABLE|OPENCONTAINER)

#undef PLASTIC_BREAK_PROBABILITY
