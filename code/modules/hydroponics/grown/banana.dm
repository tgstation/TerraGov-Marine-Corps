// Banana
/obj/item/seeds/banana
	name = "pack of banana seeds"
	desc = "They're seeds that grow into banana trees. When grown, keep away from clown."
	icon_state = "seed-banana"
	species = "banana"
	plantname = "Banana Tree"
	product = /obj/item/food/grown/banana
	lifespan = 50
	endurance = 30
	instability = 10
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_dead = "banana-dead"
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/banana = 0.1, /datum/reagent/potassium = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.02)
	graft_gene = /datum/plant_gene/trait/slip

/obj/item/food/grown/banana
	seed = /obj/item/seeds/banana
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon_state = "banana"
	worn_icon_state  = "banana_peel"
	trash_type = /obj/item/grown/bananapeel
	bite_consumption_mod = 3
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/banana
	distill_reagent = /datum/reagent/consumable/ethanol/bananahonk

/obj/item/food/grown/banana/make_edible()
	. = ..()
	AddComponent(/datum/component/edible)


/obj/item/food/grown/banana/generate_trash(atom/location)
	. = ..()

//Banana Peel
/obj/item/grown/bananapeel
	seed = /obj/item/seeds/banana
	name = "banana peel"
	desc = "A peel from a banana."
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/food_lefthand.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/food_righthand.dmi',
	)
	icon_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/grown/bananapeel/Initialize(mapload)
	. = ..()
	if(prob(40))
		if(prob(60))
			icon_state = "[icon_state]_2"
		else
			icon_state = "[icon_state]_3"

/obj/item/grown/bananapeel/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is deliberately slipping on [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/misc/slip.ogg', 50, TRUE, -1)
	return BRUTELOSS
