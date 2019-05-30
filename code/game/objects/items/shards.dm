// Glass shards

/obj/item/shard
	name = "glass shard"
	icon = 'icons/obj/items/shards.dmi'
	icon_state = ""
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 1
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = 1
	force = 5
	throwforce = 8
	item_state = "shard-glass"
	matter = list("glass" = 3750)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	var/source_sheet_type = /obj/item/stack/sheet/glass
	var/shardsize

/obj/item/shard/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is slitting [user.p_their()] [pick("wrists", "throat")] with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS)

/obj/item/shard/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 6)
	return ..()


/obj/item/shard/New()
	shardsize = pick("large", "medium", "small")
	switch(shardsize)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)
	icon_state += shardsize
	..()


/obj/item/shard/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswelder(I))
		var/obj/item/tool/weldingtool/WT = I
		if(!source_sheet_type) //can be melted into something
			return

		if(!WT.remove_fuel(0, user))
			return

		var/obj/item/stack/sheet/NG = new source_sheet_type(user.loc)
		for(var/obj/item/stack/sheet/G in user.loc)
			if(G == NG)
				continue

			if(!istype(G, source_sheet_type))
				continue

			if(G.amount >= G.max_amount)
				continue

			G.attackby(NG, user, params)
			to_chat(user, "You add the newly-formed glass to the stack. It now contains [NG.amount] sheets.")

		qdel(src)


/obj/item/shard/Crossed(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		playsound(src.loc, 'sound/effects/glass_step.ogg', 25, 1) // not sure how to handle metal shards with sounds
		if(!M.buckled)
			to_chat(M, "<span class='danger'>You step on \the [src]!</span>")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M

				if(H.species.species_flags & IS_SYNTHETIC || H.species.insulated)
					return

				if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.flags_armor_protection & FEET) ) )
					var/datum/limb/affecting = H.get_limb(pick("l_foot", "r_foot"))
					if(affecting.limb_status & LIMB_ROBOT)
						return
					H.KnockDown(3)
					if(affecting.take_damage_limb(5))
						H.UpdateDamageIcon()
					H.updatehealth()
	..()

// Shrapnel

/obj/item/shard/shrapnel
	name = "shrapnel"
	icon_state = "shrapnel"
	desc = "A bunch of tiny bits of shattered metal."
	matter = list("metal" = 50)
	source_sheet_type = null




/obj/item/shard/phoron
	name = "phoron shard"
	desc = "A shard of phoron glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 8
	throwforce = 15
	icon_state = "phoron"
	source_sheet_type = /obj/item/stack/sheet/glass/phoronglass



