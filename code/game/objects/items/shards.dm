// Glass shards

/obj/item/shard
	name = "glass shard"
	icon = 'icons/obj/items/shards.dmi'
	icon_state = ""
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 1
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 8
	item_state = "shard-glass"
	materials = list(/datum/material/glass = 3750)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	var/source_sheet_type = /obj/item/stack/sheet/glass
	var/shardsize

/obj/item/shard/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is slitting [user.p_their()] [pick("wrists", "throat")] with [src]! It looks like [user.p_theyre()] trying to commit suicide."))
	return (BRUTELOSS)

/obj/item/shard/attack(mob/living/carbon/M, mob/living/carbon/user)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 6)
	return ..()


/obj/item/shard/Initialize()
	. = ..()
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
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)


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


/obj/item/shard/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return

	var/mob/living/M = AM
	if(M.status_flags & INCORPOREAL)  //Flying over shards doesn't break them
		return
	if (CHECK_MULTIPLE_BITFIELDS(M.flags_pass, HOVERING))
		return

	pick(playsound(loc, 'sound/effects/shard1.ogg', 35, TRUE), playsound(loc, 'sound/effects/shard2.ogg', 35, TRUE), playsound(loc, 'sound/effects/shard3.ogg', 35, TRUE), playsound(loc, 'sound/effects/shard4.ogg', 35, TRUE), playsound(loc, 'sound/effects/shard5.ogg', 35, TRUE))
	if(prob(20))
		to_chat(M, span_danger("[isxeno(M) ? "We" : "You"] step on \the [src], shattering it!"))
		qdel(src)
		return

	if(M.buckled)
		return
	to_chat(M, span_danger("[isxeno(M) ? "We" : "You"] step on \the [src]!"))
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M

	if(H.species.species_flags & ROBOTIC_LIMBS || H.species.insulated)
		return

	if(!H.shoes && !(H.wear_suit?.flags_armor_protection & FEET))
		INVOKE_ASYNC(src, .proc/pierce_foot, H)

/obj/item/shard/proc/pierce_foot(mob/living/carbon/human/target)
	var/datum/limb/affecting = target.get_limb(pick("l_foot", "r_foot"))
	if(affecting.limb_status & LIMB_ROBOT)
		return
	target.Paralyze(60)

	if(affecting.take_damage_limb(5))
		UPDATEHEALTH(target)
		target.UpdateDamageIcon()

// Shrapnel

/obj/item/shard/shrapnel
	name = "shrapnel"
	icon_state = "shrapnel"
	desc = "A bunch of tiny bits of shattered metal."
	materials = list(/datum/material/metal = 50)
	source_sheet_type = null
	embedding = list("embedded_flags" = EMBEDDED_DEL_ON_HOLDER_DEL, "embed_chance" = 0, "embedded_fall_chance" = 0)


/obj/item/shard/shrapnel/Initialize(mapload, new_name, new_desc)
	. = ..()
	if(!isnull(new_name))
		name = new_name
	if(!isnull(new_desc))
		desc += new_desc


/obj/item/shard/phoron
	name = "phoron shard"
	desc = "A shard of phoron glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 8
	throwforce = 15
	icon_state = "phoron"
	source_sheet_type = /obj/item/stack/sheet/glass/phoronglass
