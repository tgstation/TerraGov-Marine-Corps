//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/bush
	name = "dense vegetation"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon = 'icons/obj/structures/jungle.dmi'
	icon_state = "bush1"
	density = FALSE
	anchored = TRUE
	layer = BUSH_LAYER
	var/stump = 0
	max_integrity = 100

/obj/structure/bush/stickervines
	name = "dense sticker vines"
	desc = "Pretty thick vines with sharp stickers on them, it'll take something sharp and a lot of determination to clear away."
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "thickvines"

/obj/structure/bush/Initialize()
	. = ..()
	if(prob(75))
		opacity = TRUE

	//Randomise a bit
	var/matrix/M = matrix()
	M.Turn(rand(1,360))
	M.Scale(pick(0.7,0.8,0.9,1,1.1,1.2),pick(0.7,0.8,0.9,1,1.1,1.2))
	src.transform = M


/obj/structure/bush/Bumped(mob/M) //todo shitcode
	if (istype(M, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = M
		A.forceMove(get_turf(src))
	else if (ismonkey(M))
		var/mob/living/carbon/human/species/monkey/A = M
		A.forceMove(get_turf(src))


/obj/structure/bush/Crossed(atom/movable/AM)
	. = ..()
	if(!stump)
		if(isliving(AM))
			var/mob/living/L = AM
			var/bush_sound_prob = 60
			if(istype(L, /mob/living/carbon/xenomorph))
				var/mob/living/carbon/xenomorph/X = L
				bush_sound_prob = X.tier_as_number() * 20

			if(prob(bush_sound_prob))
				var/sound = pick('sound/effects/vegetation_walk_0.ogg','sound/effects/vegetation_walk_1.ogg','sound/effects/vegetation_walk_2.ogg')
				playsound(src.loc, sound, 25, 1)
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				var/stuck = rand(0,10)
				switch(stuck)
					if(0 to 4)
						H.next_move_slowdown += rand(2,3)
						if(prob(2))
							to_chat(H, span_warning("Moving through [src] slows you down."))
					if(5 to 7)
						H.next_move_slowdown += rand(4,7)
						if(prob(10))
							to_chat(H, span_warning("It is very hard to move trough this [src]..."))
					if(8 to 9)
						H.next_move_slowdown += rand(8,11)
						to_chat(H, span_warning("You got tangeled in [src]!"))
					if(10)
						H.next_move_slowdown += rand(12,20)
						to_chat(H, span_warning("You got completely tangeled in [src]! Oh boy..."))

/obj/structure/bush/attackby(obj/item/I, mob/user, params)
	. = ..()

	if((istype(I, /obj/item/tool/hatchet) || istype(I, /obj/item/weapon/combat_knife) || istype(I, /obj/item/weapon/claymore/mercsword) && !stump))
		var/damage = rand(2, 5)
		if(istype(I, /obj/item/weapon/claymore/mercsword))
			damage = rand(8, 18)
		if(resistance_flags & INDESTRUCTIBLE)
			to_chat(user, span_warning(" You flail away at the undergrowth, but it's too thick here."))
			return

		user.visible_message(span_warning(" [user] flails away at the  [src] with [I]."),span_warning(" You flail away at the [src] with [I]."))
		playsound(loc, 'sound/effects/vegetation_hit.ogg', 25, 1)
		take_damage(damage)


/obj/structure/bush/flamer_fire_act(heat)
	take_damage(30, BURN, "fire")

//*******************************//
// Strange, fruit-bearing plants //
//*******************************//

GLOBAL_LIST_INIT(fruit_icon_states, list("badrecipe","kudzupod","reishi","lime","grapes","boiledrorocore","chocolateegg"))
GLOBAL_LIST_INIT(reagent_effects, list(/datum/reagent/toxin,/datum/reagent/medicine/dylovene,/datum/reagent/toxin/sleeptoxin,/datum/reagent/space_drugs,/datum/reagent/toxin/mindbreaker,/datum/reagent/impedrezene))

/obj/item/reagent_containers/food/snacks/grown/jungle_fruit
	name = "jungle fruit"
	desc = "It smells weird and looks off."
	icon = 'icons/obj/structures/jungle.dmi'
	icon_state = "orange"
	potency = 1

/obj/structure/jungle_plant
	icon = 'icons/obj/structures/jungle.dmi'
	icon_state = "plant1"
	desc = "Looks like some of that fruit might be edible."
	var/fruits_left = 3
	var/fruit_type = -1
	var/icon/fruit_overlay
	var/plant_strength = 1
	var/fruit_r
	var/fruit_g
	var/fruit_b

/obj/structure/jungle_plant/Initialize()
	. = ..()
	fruit_type = rand(1,7)
	icon_state = "plant[fruit_type]"
	fruits_left = rand(1,5)
	fruit_overlay = icon('icons/obj/structures/jungle.dmi',"fruit[fruits_left]")
	fruit_r = 255 - fruit_type * 36
	fruit_g = rand(1,255)
	fruit_b = fruit_type * 36
	fruit_overlay.Blend(rgb(fruit_r, fruit_g, fruit_b), ICON_ADD)
	overlays += fruit_overlay
	plant_strength = rand(20,200)

/obj/structure/jungle_plant/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(fruits_left > 0)
		fruits_left--
		to_chat(user, span_notice("You pick a fruit off [src]."))

		var/obj/item/reagent_containers/food/snacks/grown/jungle_fruit/J = new (src.loc)
		J.potency = plant_strength
		J.icon_state = GLOB.fruit_icon_states[fruit_type]
		J.reagents.add_reagent(GLOB.reagent_effects[fruit_type], 1+round((plant_strength / 20), 1))
		J.bitesize = 1+round(J.reagents.total_volume / 2, 1)
		J.attack_hand(user)

		overlays -= fruit_overlay
		fruit_overlay = icon('icons/obj/structures/jungle.dmi',"fruit[fruits_left]")
		fruit_overlay.Blend(rgb(fruit_r, fruit_g, fruit_b), ICON_ADD)
		overlays += fruit_overlay
	else
		to_chat(user, span_warning(" There are no fruit left on [src]."))

