//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/bush
	name = "dense vegetation"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "bush1"
	density = 0
	anchored = 1
	layer = BUSH_LAYER
	var/indestructable = 0
	var/stump = 0
	var/health = 100

/obj/structure/bush/New()
	health = rand(50,75)
	if(prob(75))
		opacity = 1

	//Randomise a bit
	var/matrix/M = matrix()
	M.Turn(rand(1,360))
	M.Scale(pick(0.7,0.8,0.9,1,1.1,1.2),pick(0.7,0.8,0.9,1,1.1,1.2))
	src.transform = M


/obj/structure/bush/Bumped(M as mob)
	if (istype(M, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = M
		A.loc = get_turf(src)
	else if (istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/A = M
		A.loc = get_turf(src)


/obj/structure/bush/Crossed(atom/movable/AM)
	if(!stump)
		if(isliving(AM))
			var/mob/living/L = AM
			var/bush_sound_prob = 60
			if(istype(L, /mob/living/carbon/Xenomorph))
				var/mob/living/carbon/Xenomorph/X = L
				bush_sound_prob = X.tier * 20

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
							H << "<span class='warning'>Moving through [src] slows you down.</span>"
					if(5 to 7)
						H.next_move_slowdown += rand(4,7)
						if(prob(10))
							H << "<span class='warning'>It is very hard to move trough this [src]...</span>"
					if(8 to 9)
						H.next_move_slowdown += rand(8,11)
						H << "<span class='warning'>You got tangeled in [src]!</span>"
					if(10)
						H.next_move_slowdown += rand(12,20)
						H << "<span class='warning'>You got completely tangeled in [src]! Oh boy...</span>"

/obj/structure/bush/attackby(var/obj/I as obj, var/mob/user as mob)
	//hatchets and shiet can clear away undergrowth
	if(I && (istype(I, /obj/item/tool/hatchet) || istype(I, /obj/item/weapon/combat_knife) || istype(I, /obj/item/weapon/claymore/mercsword) && !stump))
		var/damage = rand(2,5)
		if(istype(I,/obj/item/weapon/claymore/mercsword))
			damage = rand(8,18)
		if(indestructable)
			//this bush marks the edge of the map, you can't destroy it
			user << "\red You flail away at the undergrowth, but it's too thick here."
		else
			user.visible_message("\red [user] flails away at the  [src] with [I].","\red You flail away at the [src] with [I].")
			playsound(src.loc, 'sound/effects/vegetation_hit.ogg', 25, 1)
			health -= damage
			if(health < 0)
				user << "\blue You clear away [src]."
			healthcheck()
	else
		return ..()

/obj/structure/bush/proc/healthcheck()
	if(health < 35 && opacity)
		opacity = 0
	if(health < 0)
		if(prob(10))
			icon_state = "stump[rand(1,2)]"
			name = "cleared foliage"
			desc = "There used to be dense undergrowth here."
			stump = 1
			pixel_x = rand(-6,6)
			pixel_y = rand(-6,6)
		else
			cdel(src)

/obj/structure/bush/flamer_fire_act(heat)
	health -= 30
	healthcheck(src)

//*******************************//
// Strange, fruit-bearing plants //
//*******************************//

var/list/fruit_icon_states = list("badrecipe","kudzupod","reishi","lime","grapes","boiledrorocore","chocolateegg")
var/list/reagent_effects = list("toxin","anti_toxin","stoxin","space_drugs","mindbreaker","zombiepowder","impedrezene")
var/jungle_plants_init = 0

/proc/init_jungle_plants()
	jungle_plants_init = 1
	fruit_icon_states = shuffle(fruit_icon_states)
	reagent_effects = shuffle(reagent_effects)

/obj/item/reagent_container/food/snacks/grown/jungle_fruit
	name = "jungle fruit"
	desc = "It smells weird and looks off."
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "orange"
	potency = 1

/obj/structure/jungle_plant
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "plant1"
	desc = "Looks like some of that fruit might be edible."
	var/fruits_left = 3
	var/fruit_type = -1
	var/icon/fruit_overlay
	var/plant_strength = 1
	var/fruit_r
	var/fruit_g
	var/fruit_b


/obj/structure/jungle_plant/New()
	if(!jungle_plants_init)
		init_jungle_plants()

	fruit_type = rand(1,7)
	icon_state = "plant[fruit_type]"
	fruits_left = rand(1,5)
	fruit_overlay = icon('code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi',"fruit[fruits_left]")
	fruit_r = 255 - fruit_type * 36
	fruit_g = rand(1,255)
	fruit_b = fruit_type * 36
	fruit_overlay.Blend(rgb(fruit_r, fruit_g, fruit_b), ICON_ADD)
	overlays += fruit_overlay
	plant_strength = rand(20,200)

/obj/structure/jungle_plant/attack_hand(var/mob/user as mob)
	if(fruits_left > 0)
		fruits_left--
		user << "\blue You pick a fruit off [src]."

		var/obj/item/reagent_container/food/snacks/grown/jungle_fruit/J = new (src.loc)
		J.potency = plant_strength
		J.icon_state = fruit_icon_states[fruit_type]
		J.reagents.add_reagent(reagent_effects[fruit_type], 1+round((plant_strength / 20), 1))
		J.bitesize = 1+round(J.reagents.total_volume / 2, 1)
		J.attack_hand(user)

		overlays -= fruit_overlay
		fruit_overlay = icon('code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi',"fruit[fruits_left]")
		fruit_overlay.Blend(rgb(fruit_r, fruit_g, fruit_b), ICON_ADD)
		overlays += fruit_overlay
	else
		user << "\red There are no fruit left on [src]."
