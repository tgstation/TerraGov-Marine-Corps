/obj/item/reagent_containers/glass/pot
	force = 10
	throwforce = 15
	possible_item_intents = list(INTENT_GENERIC)
	name = "pot"
	desc = ""
	icon_state = "pot"
	icon = 'icons/roguetown/items/cooking.dmi'
	item_state = "rods"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	sharpness = IS_BLUNT
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 9 //hard to transfer
	possible_transfer_amounts = list(9) 
	volume = 99
	drop_sound = 'sound/foley/dropsound/shovel_drop.ogg'
	slot_flags = null

/obj/item/reagent_containers/glass/pot/proc/makeSoup(obj/item/reagent_containers/food/snacks/souping)
	var/nutrimentamount = souping.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(nutrimentamount > 0)
		if(nutrimentamount + reagents.total_volume > pot.volume)
			to_chat(user, "<span class='warning'>[attachment] is full!</span>")
			return
		if(istype(souping, /obj/item/reagent_containers/food/snacks/grown) || souping.eat_effect == /datum/status_effect/debuff/uncookedfood)
			nutrimentamount *= 1.25 //Boiling food makes more nutrients digestable.
		reagents.add_reagent(/datum/reagent/consumable/nutriment, nutrimentamount)
	if(souping.boil_reagent)
		reagents.add_reagent(souping.boil_reagent, souping.boil_amt)
	qdel(souping)
	playsound(src, "bubbles", 100, TRUE)
