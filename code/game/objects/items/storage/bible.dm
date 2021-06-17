/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL

	///The name of the bible's deity
	var/deity_name = "Christ"

/obj/item/storage/bible/koran
	name = "koran"
	icon_state = "koran"
	deity_name = "Allah"

/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/storage/bible/booze
	spawns_with = list(
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/spacecash,
		/obj/item/spacecash,
		/obj/item/spacecash,
	)

/obj/item/storage/bible/afterattack(atom/clicked_on, mob/user, proximity)
	if(!proximity || !isliving(user))
		return
	var/mob/living/living_user = user
	if(ischaplainjob(living_user.job))
		if(clicked_on.reagents && clicked_on.reagents.has_reagent(/datum/reagent/water)) //blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [clicked_on].</span>")
			var/water2holy = clicked_on.reagents.get_reagent_amount(/datum/reagent/water)
			clicked_on.reagents.del_reagent(/datum/reagent/water)
			clicked_on.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)

/obj/item/storage/bible/attackby()
	. = ..()

	if(use_sound)
		playsound(loc, use_sound, 25, 1, 6)
