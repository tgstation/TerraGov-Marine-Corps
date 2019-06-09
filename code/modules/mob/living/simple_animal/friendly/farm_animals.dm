/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	emote_hear = list("brays.")
	emote_see = list("shakes its head.", "stamps a foot.", "glares around.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	faction = "Neutral"
	attack_same = TRUE
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	maxHealth = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	wall_smash = FALSE
	stop_automated_movement_when_pulled = TRUE
	var/obj/item/udder/udder = null


/mob/living/simple_animal/hostile/retaliate/goat/Initialize()
	udder = new()
	return ..()


/mob/living/simple_animal/hostile/retaliate/goat/Destroy()
	qdel(udder)
	udder = null
	return ..()


/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!length(enemies) && prob(1))
			Retaliate()

		if(length(enemies) && prob(10))
			enemies = list()
			LoseTarget()
			visible_message("<span class='notice'>[src] calms down.</span>")
	if(stat == CONSCIOUS)
		udder.generateMilk()


/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	. = ..()
	visible_message("<span class='danger'>[src] gets an evil-looking gleam in [p_their()] eye.</span>")


/mob/living/simple_animal/hostile/retaliate/goat/attackby(obj/item/I, mob/user, params)
	if(stat == CONSCIOUS && istype(I, /obj/item/reagent_container/glass))
		udder.milkAnimal(I, user)
		return TRUE
	else
		return ..()


/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	emote_hear = list("brays.")
	emote_see = list("shakes its head.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 50
	maxHealth = 50
	var/obj/item/udder/udder = null


/mob/living/simple_animal/cow/Initialize()
	udder = new()
	return ..()


/mob/living/simple_animal/cow/Destroy()
	QDEL_NULL(udder)
	return ..()


/mob/living/simple_animal/cow/attackby(obj/item/I, mob/user, params)
	if(stat == CONSCIOUS && istype(I, /obj/item/reagent_container/glass))
		udder.milkAnimal(I, user)
		return TRUE
	else
		return ..()


/mob/living/simple_animal/cow/Life()
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()


/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M)
	if(!stat && M.a_intent == INTENT_DISARM && icon_state != icon_dead)
		M.visible_message("<span class='warning'>[M] tips over [src].</span>",
			"<span class='notice'>You tip over [src].</span>")
		to_chat(src, "<span class='userdanger'>You are tipped over by [M]!</span>")
		KnockDown(10)
		icon_state = icon_dead
		spawn(rand(20, 50))
			if(!stat && M)
				icon_state = icon_living
				var/external
				var/internal
				switch(pick(1,2,3,4))
					if(1,2,3)
						var/text = pick("imploringly.", "pleadingly.",
							"with a resigned expression.")
						external = "[src] looks at [M] [text]"
						internal = "You look at [M] [text]"
					if(4)
						external = "[src] seems resigned to its fate."
						internal = "You resign yourself to your fate."
				visible_message("<span class='notice'>[external]</span>",
					"<span class='revennotice'>[internal]</span>")
	else
		return ..()


/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground.","flaps its tiny wings.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 3
	maxHealth = 3
	var/amount_grown = 0
	flags_pass = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_SMALL


/mob/living/simple_animal/chick/Initialize()
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)


/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(loc)
			qdel(src)


/mob/living/simple_animal/chick/holo/Life()
	. = ..()
	amount_grown = 0


/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	var/egg_type = /obj/item/reagent_container/food/snacks/egg
	var/food_type = /obj/item/reagent_container/food/snacks/grown/wheat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"
	health = 15
	maxHealth = 15
	var/eggsleft = 0
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	flags_pass = PASSTABLE|PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/list/feedMessages = list("It clucks happily.","It clucks happily.")
	var/list/layMessage = list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")
	var/list/validColors = list("brown","black","white")
	var/static/chicken_count = 0


/mob/living/simple_animal/chicken/Initialize()
	. = ..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	++chicken_count


/mob/living/simple_animal/chicken/Destroy()
	--chicken_count
	return ..()


/mob/living/simple_animal/chicken/attackby(obj/item/O, mob/user, params)
	if(istype(O, food_type)) //feedin' dem chickens
		if(!stat && eggsleft < 8)
			var/feedmsg = "[user] feeds [O] to [name]! [pick(feedMessages)]"
			user.visible_message(feedmsg)
			qdel(O)
			eggsleft += rand(1, 4)
		else
			to_chat(user, "<span class='warning'>[name] doesn't seem hungry!</span>")
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if((!stat && prob(3) && eggsleft > 0) && egg_type)
		visible_message("<span class='alertalien'>[src] [pick(layMessage)]</span>")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(eggsFertile)
			if(chicken_count < 20 && prob(25))
				START_PROCESSING(SSobj, E)


/obj/item/reagent_container/food/snacks/egg
	var/amount_grown = 0


/obj/item/reagent_container/food/snacks/egg/process()
	if(isturf(loc))
		amount_grown += rand(1, 2)
		if(amount_grown >= 100)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)


/obj/item/udder
	name = "udder"


/obj/item/udder/Initialize()
	create_reagents(50)
	reagents.add_reagent("milk", 20)
	return ..()


/obj/item/udder/proc/generateMilk()
	if(prob(5))
		reagents.add_reagent("milk", rand(5, 10))


/obj/item/udder/proc/milkAnimal(obj/O, mob/user)
	var/obj/item/reagent_container/glass/G = O
	if(G.reagents.total_volume >= G.volume)
		to_chat(user, "<span class='danger'>[O] is full.</span>")
		return
	var/transfered = reagents.trans_to(O, rand(5,10))
	if(transfered)
		user.visible_message("[user] milks [src] using \the [O].", "<span class='notice'>You milk [src] using \the [O].</span>")
	else
		to_chat(user, "<span class='danger'>The udder is dry. Wait a bit longer...</span>")