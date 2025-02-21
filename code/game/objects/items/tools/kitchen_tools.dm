/* Kitchen tools
* Contains:
*		Utensils
*		Spoons
*		Forks
*		Knives
*		Kitchen knives
*		Butcher's cleaver
*		Rolling Pins
*		Trays
*/

/obj/item/tool/kitchen
	icon = 'icons/obj/items/kitchen_tools.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/kitchen_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/kitchen_right.dmi',
	)

/*
* Utensils
*/
/obj/item/tool/kitchen/utensil
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	atom_flags = CONDUCT
	attack_verb = list("attacks", "stabs", "pokes")
	sharp = 0
	/// Is there something on this utensil?
	var/image/loaded

/obj/item/tool/kitchen/utensil/Initialize(mapload)
	. = ..()
	pixel_y = rand(0, 4)

	create_reagents(5)

/obj/item/tool/kitchen/utensil/Destroy()
	QDEL_NULL(loaded)
	return ..()

/obj/item/tool/kitchen/utensil/update_overlays()
	. = ..()
	if(!loaded)
		return
	. += loaded

/obj/item/tool/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != INTENT_HELP)
		return ..()

	if(reagents.total_volume > 0)
		reagents.reaction(M, INGEST)
		reagents.trans_to(M, reagents.total_volume)
		if(M == user)
			visible_message(span_notice("[user] eats some [loaded] from \the [src]."))
			M.reagents.add_reagent(/datum/reagent/consumable/nutriment, 1)
		else
			visible_message(span_notice("[user] feeds [M] some [loaded] from \the [src]"))
			M.reagents.add_reagent(/datum/reagent/consumable/nutriment, 1)
		playsound(M.loc,'sound/items/eatfood.ogg', 15, 1)
		QDEL_NULL(loaded)
		update_appearance(UPDATE_OVERLAYS)
		return
	return ..()

/obj/item/tool/kitchen/utensil/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(xeno_attacker)

/obj/item/tool/kitchen/utensil/fork
	name = "fork"
	desc = "It's a fork. Sure is pointy."
	icon_state = "fork"

/obj/item/tool/kitchen/utensil/pfork
	name = "plastic fork"
	desc = "Yay, no washing up to do."
	icon_state = "pfork"

/obj/item/tool/kitchen/utensil/spoon
	name = "spoon"
	desc = "It's a spoon. You can see your own upside-down face in the reflection."
	icon_state = "spoon"
	attack_verb = list("attacks", "pokes")

/obj/item/tool/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	attack_verb = list("attacks", "pokes")

/*
* Knives
*/
/obj/item/tool/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10
	throwforce = 10
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1

/obj/item/tool/kitchen/utensil/knife/suicide_act(mob/user)
	user.visible_message(pick(span_danger("[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return (BRUTELOSS)

/obj/item/tool/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 5)
	return ..()

/obj/item/tool/kitchen/utensil/pknife
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 10
	throwforce = 10

/*
* Kitchen knives
*/
/obj/item/tool/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	atom_flags = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1
	force = 10
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 6
	throw_speed = 3
	throw_range = 6
	attack_verb = list("slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")

/obj/item/tool/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick(span_danger("[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return BRUTELOSS

/obj/item/tool/kitchen/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"

/*
* Bucher's cleaver
*/
/obj/item/tool/kitchen/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown-by-products."
	atom_flags = CONDUCT
	force = 35
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 25
	throw_speed = 3
	throw_range = 6
	attack_verb = list("cleaves", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1
	hitsound = 'sound/weapons/bladeslice.ogg'

/*
* Rolling Pins
*/

/obj/item/tool/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8
	throwforce = 10
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
