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

/*
* Utensils
*/
/obj/item/tool/kitchen/utensil
	force = 5
	w_class = 1
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	flags_atom = CONDUCT
	origin_tech = "materials=1"
	attack_verb = list("attacked", "stabbed", "poked")
	sharp = 0
	var/loaded      //Descriptive string for currently loaded food object.

/obj/item/tool/kitchen/utensil/Initialize()
	. = ..()
	if (prob(60))
		src.pixel_y = rand(0, 4)

	create_reagents(5)

/obj/item/tool/kitchen/utensil/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if(user.a_intent != INTENT_HELP)
		return ..()

	if (reagents.total_volume > 0)
		reagents.reaction(M, INGEST)
		reagents.trans_to(M, reagents.total_volume)
		if(M == user)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='notice'> [] eats some [] from \the [].</span>", user, loaded, src), 1)
				M.reagents.add_reagent("nutriment", 1)
		else
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='notice'> [] feeds [] some [] from \the []</span>", user, M, loaded, src), 1)
				M.reagents.add_reagent("nutriment", 1)
		playsound(M.loc,'sound/items/eatfood.ogg', 15, 1)
		overlays.Cut()
		return
	else
		..()

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
	desc = "It's a spoon. You can see your own upside-down face in it."
	icon_state = "spoon"
	attack_verb = list("attacked", "poked")

/obj/item/tool/kitchen/utensil/pspoon
	name = "plastic spoon"
	desc = "It's a plastic spoon. How dull."
	icon_state = "pspoon"
	attack_verb = list("attacked", "poked")

/*
* Knives
*/
/obj/item/tool/kitchen/utensil/knife
	name = "knife"
	desc = "Can cut through any food."
	icon_state = "knife"
	force = 10.0
	throwforce = 10.0
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1

/obj/item/tool/kitchen/utensil/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return (BRUTELOSS)

/obj/item/tool/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 5)
	return ..()

/obj/item/tool/kitchen/utensil/pknife
	name = "plastic knife"
	desc = "The bluntest of blades."
	icon_state = "pknife"
	force = 10.0
	throwforce = 10.0

/obj/item/tool/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 5)
	return ..()

/*
* Kitchen knives
*/
/obj/item/tool/kitchen/knife
	name = "kitchen knife"
	icon_state = "knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."
	flags_atom = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1
	force = 10.0
	w_class = 3.0
	throwforce = 6.0
	throw_speed = 3
	throw_range = 6
	matter = list("metal" = 12000)
	origin_tech = "materials=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/tool/kitchen/knife/suicide_act(mob/user)
	user.visible_message(pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
							"<span class='danger'>[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return (BRUTELOSS)

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
	flags_atom = CONDUCT
	force = 15.0
	w_class = 2.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	matter = list("metal" = 12000)
	origin_tech = "materials=1"
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_ACCURATE
	edge = 1

/obj/item/tool/kitchen/knife/butcher/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 5)
	return ..()

/*
* Rolling Pins
*/

/obj/item/tool/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked") //I think the rollingpin attackby will end up ignoring this anyway.

/obj/item/tool/kitchen/rollingpin/attack(mob/living/M as mob, mob/living/user as mob)
	log_combat(user, M, "attacked", src)
	msg_admin_attack("[ADMIN_TPMONTY(usr)] used the [src.name] to attack [ADMIN_TPMONTY(M)].")

	var/t = user:zone_selected
	if (t == "head")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/head_protection = H.head
			if (H.stat < 2 && H.health < 50 && prob(90))
				// ******* Check
				if (istype(head_protection) && head_protection.flags_inventory & BLOCKSHARPOBJ  && prob(80))
					to_chat(H, "<span class='warning'>The helmet protects you from being hit hard in the head!</span>")
					return
				var/time = rand(2, 6)
				if (prob(75))
					H.KnockOut(time)
				else
					H.Stun(time)
				if(H.stat != 2)	H.stat = 1
				user.visible_message("<span class='danger'>[H] has been knocked unconscious!</span>", "<span class='danger'>You knock [H] unconscious!</span>")
				return
			else
				H.visible_message("<span class='warning'> [user] tried to knock [H] unconscious!</span>", "<span class='warning'> [user] tried to knock you unconscious!</span>")
				H.blur_eyes(3)
	return ..()

/*
* Trays - Agouri
*/
/obj/item/tool/kitchen/tray
	name = "tray"
	icon = 'icons/obj/items/kitchen_tools.dmi'
	icon_state = "tray"
	desc = "A metal tray to lay food on."
	throwforce = 12.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags_atom = CONDUCT
	matter = list("metal" = 3000)
	/* // NOPE
	var/food_total= 0
	var/burger_amt = 0
	var/cheese_amt = 0
	var/fries_amt = 0
	var/classyalcdrink_amt = 0
	var/alcdrink_amt = 0
	var/bottle_amt = 0
	var/soda_amt = 0
	var/carton_amt = 0
	var/pie_amt = 0
	var/meatbreadslice_amt = 0
	var/salad_amt = 0
	var/miscfood_amt = 0
	*/
	var/list/carrying = list() // List of things on the tray. - Doohl
	var/max_carry = 10 // w_class = 1 -- takes up 1
						// w_class = 2 -- takes up 3
						// w_class = 3 -- takes up 5

/obj/item/tool/kitchen/tray/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	// Drop all the things. All of them.
	overlays.Cut()
	for(var/obj/item/I in carrying)
		I.loc = M.loc
		carrying.Remove(I)
		if(isturf(I.loc))
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))

	var/mob/living/carbon/human/H = M      ///////////////////////////////////// /Let's have this ready for later.


	if(!(user.zone_selected == ("eyes" || "head"))) //////////////hitting anything else other than the eyes
		if(prob(33))
			src.add_mob_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf))
				location.add_mob_blood(H)     ///Plik plik, the sound of blood


		log_combat(user, M, "attacked", src)
		msg_admin_attack("[ADMIN_TPMONTY(usr)] used the [src.name] to attack [ADMIN_TPMONTY(M)].")

		if(prob(15))
			M.KnockDown(3)
			M.take_limb_damage(3)
		else
			M.take_limb_damage(5)
		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 25, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
			return
		else
			playsound(M, 'sound/items/trayhit2.ogg', 25, 1)  //we applied the damage, we played the sound, we showed the appropriate messages. Time to return and stop the proc
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
			return




	if(ishuman(M) && ((H.head && (H.head.flags_inventory & COVEREYES) ) || (H.wear_mask && (H.wear_mask.flags_inventory & COVEREYES) ) || (H.glasses && (H.glasses.flags_inventory & COVEREYES) )))
		to_chat(M, "<span class='warning'>You get slammed in the face with the tray, against your mask!</span>")
		if(prob(33))
			src.add_mob_blood(H)
			if (H.wear_mask)
				H.wear_mask.add_mob_blood(H)
			if (H.head)
				H.head.add_mob_blood(H)
			if (H.glasses && prob(33))
				H.glasses.add_mob_blood(H)
			var/turf/location = H.loc
			if (istype(location, /turf))     //Addin' blood! At least on the floor and item :v
				location.add_mob_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 25, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 25, 1)  //sound playin'
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] with the tray!</span>", user, M), 1)
		if(prob(10))
			M.Stun(rand(1,3))
			M.take_limb_damage(3)
			return
		else
			M.take_limb_damage(5)
			return

	else //No eye or head protection, tough luck!
		to_chat(M, "<span class='warning'>You get slammed in the face with the tray!</span>")
		if(prob(33))
			src.add_mob_blood(M)
			var/turf/location = H.loc
			if (istype(location, /turf))
				location.add_mob_blood(H)

		if(prob(50))
			playsound(M, 'sound/items/trayhit1.ogg', 25, 1)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] in the face with the tray!</span>", user, M), 1)
		else
			playsound(M, 'sound/items/trayhit2.ogg', 25, 1)  //sound playin' again
			for(var/mob/O in viewers(M, null))
				O.show_message(text("<span class='danger'>[] slams [] in the face with the tray!</span>", user, M), 1)
		if(prob(30))
			M.Stun(rand(2,4))
			M.take_limb_damage(4)
			return
		else
			M.take_limb_damage(8)
			if(prob(30))
				M.KnockDown(2)
				return
			return

/obj/item/tool/kitchen/tray/var/cooldown = 0	//shield bash cooldown. based on world.time

/obj/item/tool/kitchen/tray/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/kitchen/rollingpin))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [I]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 25, 1)
			cooldown = world.time

/*
===============~~~~~================================~~~~~====================
=																			=
=  Code for trays carrying things. By Doohl for Doohl erryday Doohl Doohl~  =
=																			=
===============~~~~~================================~~~~~====================
*/
/obj/item/tool/kitchen/tray/proc/calc_carry()
	// calculate the weight of the items on the tray
	var/val = 0 // value to return

	for(var/obj/item/I in carrying)
		if(I.w_class == 1.0)
			val ++
		else if(I.w_class == 2.0)
			val += 3
		else
			val += 5

	return val

/obj/item/tool/kitchen/tray/pickup(mob/user)

	if(!isturf(loc))
		return

	for(var/obj/item/I in loc)
		if( I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile) )
			var/add = 0
			if(I.w_class == 1.0)
				add = 1
			else if(I.w_class == 2.0)
				add = 3
			else
				add = 5
			if(calc_carry() + add >= max_carry)
				break

			I.loc = src
			carrying.Add(I)
			overlays += image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer)

/obj/item/tool/kitchen/tray/dropped(mob/user)
	..()
	var/mob/living/M
	for(M in src.loc) //to handle hand switching
		return

	var/foundtable = 0
	for(var/obj/structure/table/T in loc)
		foundtable = 1
		break

	overlays.Cut()

	for(var/obj/item/I in carrying)
		I.loc = loc
		carrying.Remove(I)
		if(!foundtable && isturf(loc))
			// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
			spawn()
				for(var/i = 1, i <= rand(1,2), i++)
					if(I)
						step(I, pick(NORTH,SOUTH,EAST,WEST))
						sleep(rand(2,4))
