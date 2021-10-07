/*
*		Toy gun
*		Toy crossbow
*		Toy swords
*/



/*
* Toy gun: Why isnt this an /obj/item/weapon/gun?
*/
/obj/item/toy/gun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon_state = "capgun"
	item_state = "gun"
	flags_equip_slot = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL

	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

	examine(mob/user)
		. = ..()
		to_chat(user, "There are [bullets] caps\s left in the [src].")

	attackby(obj/item/toy/gun_ammo/A as obj, mob/user as mob)

		if (istype(A, /obj/item/toy/gun_ammo))
			if (src.bullets >= 7)
				to_chat(user, span_notice("It's already fully loaded!"))
				return 1
			if (A.amount_left <= 0)
				to_chat(user, span_warning("There is no more caps!"))
				return 1
			if (A.amount_left < (7 - bullets))
				src.bullets += A.amount_left
				to_chat(user, span_warning("You reload [A.amount_left] caps\s!"))
				A.amount_left = 0
			else
				to_chat(user, span_warning("You reload [7 - bullets] caps\s!"))
				A.amount_left -= 7 - bullets
				bullets = 7
			A.update_icon()
			A.desc = "There are [A.amount_left] caps\s left! Make sure to recycle the box in an autolathe when it gets empty."
			return 1
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if (flag)
			return
		if (src.bullets < 1)
			user.show_message(span_warning(" *click* *click*"), 2)
			playsound(user, 'sound/weapons/guns/fire/empty.ogg', 15, 1)
			return
		playsound(user, 'sound/weapons/guns/fire/gunshot.ogg', 15, 1)
		src.bullets--
		visible_message(span_danger("[user] fires a cap gun at [target]!"), null, span_warning(" You hear a gunshot"))

/obj/item/toy/gun_ammo
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon_state = "cap_ammo"
	w_class = WEIGHT_CLASS_TINY

	var/amount_left = 7

/obj/item/toy/gun_ammo/update_icon_state()
	if(amount_left)
		icon_state = "cap_ammo"
	else
		icon_state = "cap_ammo_e"


/*
* Toy crossbow
*/

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon_state = "foamcrossbow"
	item_state = "crossbow"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

	examine(mob/user)
		..()
		if (bullets)
			to_chat(user, span_notice("It is loaded with [bullets] foam darts!"))

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/toy/crossbow_ammo))
			if(bullets <= 4)
				if(user.drop_held_item())
					qdel(I)
					bullets++
					to_chat(user, span_notice("You load the foam dart into the crossbow."))
			else
				to_chat(usr, span_warning("It's already fully loaded."))


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if(!isturf(target.loc) || target == user) return
		if(flag) return

		if (locate (/obj/structure/table, src.loc))
			return
		else if (bullets)
			var/turf/trg = get_turf(target)
			var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
			bullets--
			D.icon_state = "foamdart"
			D.name = "foam dart"
			playsound(user.loc, 'sound/items/syringeproj.ogg', 15, 1)

			for(var/i=0, i<6, i++)
				if (D)
					if(D.loc == trg) break
					step_towards(D,trg)

					for(var/mob/living/M in D.loc)
						if(!istype(M,/mob/living)) continue
						if(M == user) continue
						visible_message(span_warning("[M] was hit by the foam dart!"), visible_message_flags = COMBAT_MESSAGE)
						new /obj/item/toy/crossbow_ammo(M.loc)
						qdel(D)
						return

					for(var/atom/A in D.loc)
						if(A == user) continue
						if(A.density)
							new /obj/item/toy/crossbow_ammo(A.loc)
							qdel(D)

				sleep(1)

			spawn(10)
				if(D)
					new /obj/item/toy/crossbow_ammo(D.loc)
					qdel(D)

			return
		else if(!bullets && isliving(user))
			var/mob/living/L = user
			L.Paralyze(10 SECONDS)
			visible_message(span_warning("[user] realized they were out of ammo and starting scrounging for some!"))


	attack(mob/M as mob, mob/user as mob)

// ******* Check

		if (bullets > 0 && M.lying_angle)
			visible_message(span_danger("[user] casually lines up a shot with [M]'s head and pulls the trigger!"), null, span_warning("You hear the sound of foam against skull"))
			visible_message(span_warning("[M] was hit in the head by the foam dart!"))

			playsound(user.loc, 'sound/items/syringeproj.ogg', 15, 1)
			new /obj/item/toy/crossbow_ammo(M.loc)
			src.bullets--
		else if(M.lying_angle && !bullets && isliving(M))
			var/mob/living/L = M
			L.visible_message(span_danger("[user] casually lines up a shot with [L]'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!"))
			L.Paralyze(10 SECONDS)
		return

/obj/item/toy/crossbow_ammo
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/items/toy.dmi'
	icon_state = "foamdart"
	w_class = WEIGHT_CLASS_TINY

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/items/toy.dmi'
	icon_state = "null"
	anchored = TRUE
	density = FALSE


/*
* Toy swords
*/
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "struck", "hit")

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			to_chat(user, span_notice("You extend the plastic blade with a quick flick of your wrist."))
			playsound(user, 'sound/weapons/saberon.ogg', 15, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = WEIGHT_CLASS_BULKY
		else
			to_chat(user, span_notice("You push the plastic blade back down into the handle."))
			playsound(user, 'sound/weapons/saberoff.ogg', 15, 1)
			src.icon_state = "sword0"
			src.item_state = "sword0"
			src.w_class = WEIGHT_CLASS_SMALL

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_l_hand(0)
			H.update_inv_r_hand()

		return

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "katana"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")


