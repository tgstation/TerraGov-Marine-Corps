/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/storage/bible/booze/New()
	..()
	new /obj/item/reagent_container/food/drinks/cans/beer(src)
	new /obj/item/reagent_container/food/drinks/cans/beer(src)
	new /obj/item/spacecash(src)
	new /obj/item/spacecash(src)
	new /obj/item/spacecash(src)
//BS12 EDIT
/* // All cult functionality moved to Null Rod
/obj/item/storage/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/datum/limb/affecting in H.limbs)
			if(affecting.heal_damage(heal_amt, heal_amt))
				H.UpdateDamageIcon()
	return

/obj/item/storage/bible/attack(mob/living/M as mob, mob/living/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1


	log_combat(user, M, "attack", src)

	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "\red You don't have the dexterity to do this!")
		return
	if(!chaplain)
		to_chat(user, "\red The book sizzles in your hands.")
		user.take_limb_damage(0,10)
		return

	if ((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "\red The [src] slips out of your hand and hits your head.")
		user.take_limb_damage(10)
		user.KnockOut(20)
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if(M.mind && (M.mind.assigned_role == "Chaplain"))
			to_chat(user, "\red You can't heal yourself!")
			return
		/*if((M.mind in ticker.mode.cult) && (prob(20)))
			to_chat(M, "\red The power of [src.deity_name] clears your mind of heresy!")
			to_chat(user, "\red You see how [M]'s eyes become clear, the cult no longer holds control over him!")
			ticker.mode.remove_cultist(M.mind)*/
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] heals [] with the power of [src.deity_name]!</B>", user, M), 1)
			to_chat(M, "\red May the power of [src.deity_name] compel you to be healed!")
			playsound(src.loc, "punch", 25, 1)
		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				to_chat(M, "\red You feel dumber.")
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red <B>[] beats [] over the head with []!</B>", user, M, src), 1)
			playsound(src.loc, "punch", 25, 1)
	else if(M.stat == 2)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] smacks []'s lifeless corpse with [].</B>", user, M, src), 1)
		playsound(src.loc, "punch", 25, 1)
	return
*/
/obj/item/storage/bible/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity) return
/*	if (istype(A, /turf/open/floor))
		to_chat(user, "\blue You hit the floor with the bible.")
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)*/
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			to_chat(user, "\blue You bless [A].")
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)

/obj/item/storage/bible/attackby(obj/item/W as obj, mob/user as mob)
	if (src.use_sound)
		playsound(src.loc, src.use_sound, 25, 1, 6)
	..()
