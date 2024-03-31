/obj/item/reagent_containers/food/snacks/crow
	name = "zad"
	desc = "Pesky bird."
	icon_state = "crow"
	icon = 'icons/roguetown/mob/monster/crow.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	foodtype = RAW
	verb_say = "squeaks"
	verb_yell = "squeaks"
	obj_flags = CAN_BE_HIT
	var/dead = FALSE
	eat_effect = /datum/status_effect/debuff/uncookedfood
	fried_type = null
	max_integrity = 10
	sellprice = 0
	blade_dulling = DULLING_CUT
	rotprocess = null
	static_debris = list(/obj/item/natural/feather=1)
	fried_type = /obj/item/reagent_containers/food/snacks/rogue/friedcrow

/obj/item/reagent_containers/food/snacks/rogue/friedcrow
	name = "fried zad"
	desc = ""
	icon = 'icons/roguetown/items/food.dmi'
	icon_state = "fcrow"
	bitesize = 2
	list_reagents = list(/datum/reagent/consumable/nutriment = 4)
	w_class = WEIGHT_CLASS_TINY
	tastes = list("burnt flesh" = 1)
	eat_effect = null
	rotprocess = 12 MINUTES
	sellprice = 0

/obj/item/reagent_containers/food/snacks/crow/burning(input as num)
	. = ..()
	if(!dead)
		if(burning >= burntime)
			dead = TRUE
			playsound(src, 'sound/vo/mobs/rat/rat_death.ogg', 100, FALSE, -1)
			icon_state = "[icon_state]1"

/obj/item/reagent_containers/food/snacks/crow/dead
	dead = TRUE
	rotprocess = 15 MINUTES

/obj/item/reagent_containers/food/snacks/crow/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	if(dead)
		icon_state = "[icon_state]l"

/obj/item/reagent_containers/food/snacks/crow/attack_hand(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	user.changeNext_move(CLICK_CD_MELEE)
	if(dead)
		..()
	else
		if(isliving(user))
			var/mob/living/L = user
			if(prob(L.STASPD * 2))
				..()
			else
				if(isturf(loc))
					to_chat(user, "<span class='warning'>I fail to snatch [src]!</span>")
					playsound(src, 'sound/vo/mobs/bird/birdfly.ogg', 100, TRUE, -1)
					qdel(src)
					return
	..()

/obj/item/reagent_containers/food/snacks/crow/process()
	..()
	if(dead)
		return
	if(!isturf(loc)) //no floating out of bags
		return
	if(prob(8))
		playsound(src, pick('sound/vo/mobs/bird/CROW_01.ogg','sound/vo/mobs/bird/CROW_02.ogg','sound/vo/mobs/bird/CROW_03.ogg'), 100, TRUE, -1)

/obj/item/reagent_containers/food/snacks/crow/obj_destruction(damage_flag)
	//..()
	if(!dead)
		dead = TRUE
		playsound(src, 'sound/vo/mobs/rat/rat_death.ogg', 100, FALSE, -1)
		icon_state = "[icon_state]1"
		rotprocess = 15 MINUTES
		return 1
	. = ..()

/obj/item/reagent_containers/food/snacks/crow/Crossed(mob/living/L)
	. = ..()
	if(!dead)
		playsound(src, 'sound/vo/mobs/bird/birdfly.ogg', 100, TRUE, -1)
		qdel(src)


/obj/item/reagent_containers/food/snacks/crow/attackby(obj/item/I, mob/user, params)
	if(!dead)
		if(isliving(user) && isturf(loc))
			var/mob/living/L = user
			if(prob(L.STASPD * 2))
				..()
			else
				to_chat(user, "<span class='warning'>[src] gets away!</span>")
				playsound(src, 'sound/vo/mobs/bird/birdfly.ogg', 100, TRUE, -1)
				qdel(src)
				return
	..()