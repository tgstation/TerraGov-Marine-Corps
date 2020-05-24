/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/storage/bible/koran
	name = "koran"
	icon_state = "koran"
	deity_name = "Allah"

/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/storage/bible/booze/Initialize(mapload, ...)
	. = ..()
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/spacecash(src)
	new /obj/item/spacecash(src)
	new /obj/item/spacecash(src)

/obj/item/storage/bible/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !isliving(user))
		return
	var/mob/living/living_user = user
	if(ischaplainjob(living_user.job))
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/water)) //blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [A].</span>")
			var/water2holy = A.reagents.get_reagent_amount(/datum/reagent/water)
			A.reagents.del_reagent(/datum/reagent/water)
			A.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)

/obj/item/storage/bible/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(use_sound)
		playsound(loc, use_sound, 25, 1, 6)
