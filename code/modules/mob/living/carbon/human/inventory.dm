/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		if(!I)
			H << "<span class='notice'>You are not holding anything to equip.</span>"
			return
		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else
			H << "\red You are unable to equip that."

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		del(W)
	return null


/mob/living/carbon/human/proc/has_organ(name)
	var/datum/organ/external/O = organs_by_name[name]

	return (O && !(O.status & ORGAN_DESTROYED) )

/mob/living/carbon/human/proc/has_organ_for_slot(slot)
	switch(slot)
		if(WEAR_BACK)
			return has_organ("chest")
		if(WEAR_FACE)
			return has_organ("head")
		if(WEAR_HANDCUFFS)
			return has_organ("l_hand") && has_organ("r_hand")
		if(WEAR_LEGCUFFS)
			return has_organ("l_leg") && has_organ("r_leg")
		if(WEAR_L_HAND)
			return has_organ("l_hand")
		if(WEAR_R_HAND)
			return has_organ("r_hand")
		if(WEAR_WAIST)
			return has_organ("chest")
		if(WEAR_ID)
			return 1
		if(WEAR_L_EAR)
			return has_organ("head")
		if(WEAR_R_EAR)
			return has_organ("head")
		if(WEAR_EYES)
			return has_organ("head")
		if(WEAR_HANDS)
			return has_organ("l_hand") && has_organ("r_hand")
		if(WEAR_HEAD)
			return has_organ("head")
		if(WEAR_FEET)
			return has_organ("r_foot") && has_organ("l_foot")
		if(WEAR_JACKET)
			return has_organ("chest")
		if(WEAR_BODY)
			return has_organ("chest")
		if(WEAR_L_STORE)
			return has_organ("chest")
		if(WEAR_R_STORE)
			return has_organ("chest")
		if(WEAR_J_STORE)
			return has_organ("chest")
		if(WEAR_ACCESSORY)
			return has_organ("chest")
		if(WEAR_IN_BACK)
			return 1
		if(WEAR_IN_JACKET)
			return 1
		if(WEAR_IN_ACCESSORY)
			return 1

/mob/living/carbon/human/put_in_l_hand(obj/item/W)
	var/datum/organ/external/O = organs_by_name["l_hand"]
	if(!O || (O.status & (ORGAN_DESTROYED|ORGAN_CUT_AWAY|ORGAN_MUTATED)))
		return FALSE
	. = ..()

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	var/datum/organ/external/O = organs_by_name["r_hand"]
	if(!O || (O.status & (ORGAN_DESTROYED|ORGAN_CUT_AWAY|ORGAN_MUTATED)))
		return FALSE
	. = ..()

/mob/living/carbon/human/u_equip(obj/item/I, atom/newloc, nomoveupdate, force)
	. = ..()
	if(!. || !I)
		return FALSE

	if(I == wear_suit)
		if(s_store)
			drop_inv_item_on_ground(s_store)
		wear_suit = null
		if(I.flags_inventory & HIDESHOES)
			update_inv_shoes()
		if(I.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
			update_hair()
		update_inv_wear_suit()
	else if(I == w_uniform)
		if(r_store)
			drop_inv_item_on_ground(r_store)
		if(l_store)
			drop_inv_item_on_ground(l_store)
		if(belt)
			drop_inv_item_on_ground(belt)
		if(wear_suit) //We estimate all armors with uniform restrictions aren't okay with removing the uniform altogether
			var/obj/item/clothing/suit/S = wear_suit
			if(S.uniform_restricted.len)
				drop_inv_item_on_ground(wear_suit)
		w_uniform = null
		update_inv_w_uniform()
	else if(I == head)
		head = null
		if(I.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
			update_hair()	//rebuild hair
		if(I.flags_inventory & HIDEEARS)
			update_inv_ears()
		if(I.flags_inventory & HIDEMASK)
			update_inv_wear_mask()
		update_inv_head()
	else if (I == gloves)
		gloves = null
		update_inv_gloves()
	else if (I == glasses)
		glasses = null
		update_inv_glasses()
	else if (I == l_ear)
		l_ear = null
		update_inv_ears()
	else if (I == r_ear)
		r_ear = null
		update_inv_ears()
	else if (I == shoes)
		shoes = null
		update_inv_shoes()
	else if (I == belt)
		belt = null
		update_inv_belt()
	else if (I == wear_id)
		wear_id = null
		update_inv_wear_id()
	else if (I == r_store)
		r_store = null
		update_inv_pockets()
	else if (I == l_store)
		l_store = null
		update_inv_pockets()
	else if (I == s_store)
		s_store = null
		update_inv_s_store()




/mob/living/carbon/human/wear_mask_update(obj/item/I)
	if(istype(I,/obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/F = I
		if(F.stat != DEAD && !F.sterile && !(status_flags & XENO_HOST)) //Huggered but not impregnated, deal damage.
			visible_message("<span class='danger'>[F] frantically claws at [src]'s face!</span>","<span class='danger'>[F] frantically claws at your face! Auugh!</span>")
			adjustBruteLossByPart(25,"head")
	if(I.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
		update_hair()	//rebuild hair
	if(I.flags_inventory & HIDEEARS)
		update_inv_ears()
	if(internal)
		if(internals)
			internals.icon_state = "internal0"
		internal = null
	update_inv_wear_mask()


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot)
	if(!slot) return
	if(!istype(W)) return
	if(!has_organ_for_slot(slot)) return

	if(W == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(W == r_hand)
		r_hand = null
		update_inv_r_hand()

	W.screen_loc = null
	W.loc = src
	W.layer = 20

	switch(slot)
		if(WEAR_BACK)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		if(WEAR_FACE)
			wear_mask = W
			if( wear_mask.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
				update_hair()	//rebuild hair
				update_inv_ears()
			W.equipped(src, slot)
			update_inv_wear_mask()
		if(WEAR_HANDCUFFS)
			handcuffed = W
			handcuff_update()
		if(WEAR_LEGCUFFS)
			legcuffed = W
			W.equipped(src, slot)
			legcuff_update()
		if(WEAR_L_HAND)
			l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand()
		if(WEAR_R_HAND)
			r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand()
		if(WEAR_WAIST)
			belt = W
			W.equipped(src, slot)
			update_inv_belt()
		if(WEAR_ID)
			wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id()
		if(WEAR_L_EAR)
			l_ear = W
			W.equipped(src, slot)
			update_inv_ears()
		if(WEAR_R_EAR)
			r_ear = W
			W.equipped(src, slot)
			update_inv_ears()
		if(WEAR_EYES)
			glasses = W
			W.equipped(src, slot)
			update_inv_glasses()
		if(WEAR_HANDS)
			gloves = W
			W.equipped(src, slot)
			update_inv_gloves()
		if(WEAR_HEAD)
			head = W
			if(head.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
				update_hair()	//rebuild hair
			if(head.flags_inventory & HIDEEARS)
				update_inv_ears()
			if(head.flags_inventory & HIDEMASK)
				update_inv_wear_mask()
			W.equipped(src, slot)
			update_inv_head()
		if(WEAR_FEET)
			shoes = W
			W.equipped(src, slot)
			update_inv_shoes()
		if(WEAR_JACKET)
			wear_suit = W
			if(wear_suit.flags_inventory & HIDESHOES)
				update_inv_shoes()
			if( wear_suit.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
				update_hair()
			W.equipped(src, slot)
			update_inv_wear_suit()
		if(WEAR_BODY)
			w_uniform = W
			W.equipped(src, slot)
			update_inv_w_uniform()
		if(WEAR_L_STORE)
			l_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(WEAR_R_STORE)
			r_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(WEAR_ACCESSORY)
			var/obj/item/clothing/under/U = w_uniform
			if(U && !U.hastie)
				var/obj/item/clothing/tie/T = W
				T.on_attached(U, src)
				U.hastie = T
				update_inv_w_uniform()
		if(WEAR_J_STORE)
			s_store = W
			W.equipped(src, slot)
			update_inv_s_store()
		if(WEAR_IN_BACK)
			if(get_active_hand() == W)
				temp_drop_inv_item(W)
			W.forceMove(back)
		if(WEAR_IN_JACKET)
			var/obj/item/clothing/suit/storage/S = wear_suit
			if(istype(S) && S.pockets.storage_slots) W.loc = S.pockets//Has to have some slots available.

		if(WEAR_IN_ACCESSORY)
			var/obj/item/clothing/under/U = w_uniform
			if(U && U.hastie)
				var/obj/item/clothing/tie/storage/T = U.hastie
				if(istype(T) && T.hold.storage_slots) W.loc = T.hold

		else
			src << "\red You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it..."
			return

	return 1



/obj/effect/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null	//source location
	var/t_loc = null	//target location
	var/obj/item/item = null
	var/place = null

/obj/effect/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/effect/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/New()
	if (!ticker)
		del(src)
	spawn(100)
		del(src)
	..()
	return

/obj/effect/equip_e/human/process()
	if (item)
		item.add_fingerprint(source)
	else
		switch(place)
			if("mask")
				if(!(target.wear_mask))
					del(src)
			if("l_hand")
				if(!(target.l_hand))
					del(src)
			if("r_hand")
				if(!(target.r_hand))
					del(src)
			if("suit")
				if(!(target.wear_suit))
					del(src)
			if("uniform")
				if(!(target.w_uniform))
					del(src)
			if("back")
				if(!(target.back))
					del(src)
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if(!(target.handcuffed))
					del(src)
			if("id")
				if((!(target.wear_id)))
					del(src)
			if("splints")
				var/count = 0
				for(var/organ in list("l_leg","r_leg","l_arm","r_arm","r_hand","l_hand","r_foot","l_foot","chest","head","groin"))
					var/datum/organ/external/o = target.organs_by_name[organ]
					if(o.status & ORGAN_SPLINTED)
						count = 1
						break
				if(count == 0)
					del(src)
					return
			if("sensor")
				if(!target.w_uniform)
					del(src)
			if("internal")
				if((!((istype(target.wear_mask, /obj/item/clothing/mask) && (istype(target.back, /obj/item/weapon/tank) || istype(target.belt, /obj/item/weapon/tank) || istype(target.s_store, /obj/item/weapon/tank)) && !(target.internal))) && !(target.internal)))
					del(src)

	var/list/L = list("syringe", "pill", "drink", "dnainjector", "fuel", "sensor", "internal", "tie")
	var/message = null
	if((item && !(L.Find(place))))
		if(isrobot(source) && place != "handcuff")
			del(src)
		message = "\red <B>[source] is trying to put \a [item.name] on [target]</B>"
	switch(place)
		if("syringe")
			message = "\red <B>[source] is trying to inject [target]!</B>"
		if("pill")
			message = "\red <B>[source] is trying to force [target] to swallow [item]!</B>"
		if("drink")
			message = "\red <B>[source] is trying to force [target] to swallow a gulp of [item]!</B>"
		if("dnainjector")
			message = "\red <B>[source] is trying to inject [target] with the [item]!</B>"
		if("mask")
			if(target.wear_mask)
				if(!target.wear_mask.canremove)
					message = "\red <B>[source] fails to take off [target.wear_mask] from [target]'s face!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their mask ([target.wear_mask.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) mask</font>")
				message = "\red <B>[source] is trying to take off [target.wear_mask] from [target]'s face!</B>"
		if("l_hand")
			if(target.l_hand)
				if(!target.l_hand.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left hand item ([target.l_hand.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left hand item ([target.l_hand])</font>")
				message = "\red <B>[source] is trying to take off [target.l_hand] from [target]'s left hand!</B>"
		if("r_hand")
			if(target.r_hand)
				if(!target.r_hand.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right hand item ([target.r_hand.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right hand item ([target.r_hand])</font>")
				message = "\red <B>[source] is trying to take off [target.r_hand] from [target]'s right hand!</B>"
		if("gloves")
			if(target.gloves)
				if(!target.gloves.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their gloves ([target.gloves.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) gloves ([target.gloves])</font>")
				message = "\red <B>[source] is trying to take off [target.gloves] from [target]'s hands!</B>"
		if("eyes")
			if(target.glasses)
				if(!target.glasses.canremove)
					message = "\red <B>[source] fails to take off [target.glasses] from [target]'s eyes!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their eyewear ([target.glasses.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) eyewear ([target.glasses])</font>")
				message = "\red <B>[source] is trying to take off [target.glasses] from [target]'s eyes!</B>"
		if("l_ear")
			if(target.l_ear)
				if(!target.l_ear.canremove)
					message = "\red <B>[source] fails to take off [target.l_ear] from [target]'s left ear!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left ear item ([target.l_ear.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left ear item ([target.l_ear])</font>")
				message = "\red <B>[source] is trying to take off [target.l_ear] from [target]'s left ear!</B>"
		if("r_ear")
			if(target.r_ear)
				if(!target.r_ear.canremove)
					message = "\red <B>[source] fails to take off [target.r_ear] from [target]'s right ear!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right ear item ([target.r_ear.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right ear item ([target.r_ear])</font>")
				message = "\red <B>[source] is trying to take off [target.r_ear] from [target]'s right ear!</B>"
		if("head")
			if(target.head)
				if(!target.head.canremove)
					message = "\red <B>[source] fails to take off [target.head] from [target]'s head!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their hat ([target.head.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) hat ([target.head])</font>")
				message = "\red <B>[source] is trying to take off [target.head] from [target]'s head!</B>"
		if("shoes")
			if(target.shoes)
				if(!target.shoes.canremove)
					message = "\red <B>[source] fails to take off [target.shoes] from [target]'s feet!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their shoes ([target.shoes.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) shoes ([target.shoes])</font>")
				message = "\red <B>[source] is trying to take off [target.shoes] from [target]'s feet!</B>"
		if("belt")
			if(target.belt)
				if(!target.belt.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their belt item ([target.belt.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) belt item ([target.belt])</font>")
				message = "\red <B>[source] is trying to take off the [target.belt] from [target]'s waist!</B>"
		if("suit")
			if(target.wear_suit)
				if(!target.wear_suit.canremove)
					message = "\red <B>[source] fails to take off [target.wear_suit] from [target]'s body!</B>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit ([target.wear_suit.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit ([target.wear_suit])</font>")
				message = "\red <B>[source] is trying to take off [target.wear_suit] from [target]'s body!</B>"
		if("back")
			if(target.back)
				if(!target.back.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their back item ([target.back.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) back item ([target.back])</font>")
				message = "\red <B>[source] is trying to take off [target.back] from [target]'s back!</B>"
		if("handcuff")
			if(target.handcuffed)
				if(!target.handcuffed.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unhandcuffed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unhandcuff [target.name]'s ([target.ckey])</font>")
				message = "\red <B>[source] is trying to unhandcuff [target]!</B>"
		if("legcuff")
			if(target.legcuffed)
				if(!target.legcuffed.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unlegcuffed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unlegcuff [target.name]'s ([target.ckey])</font>")
				message = "\red <B>[source] is trying to unlegcuff [target]!</B>"
		if("uniform")
			if(target.w_uniform)
				if(!target.w_uniform.canremove)
					message = "\red <B>[source] fails to take off [target.w_uniform] from [target]'s body!</B>"
					return
				for(var/obj/item/I in list(target.l_store, target.r_store))
					if(I.on_found(source))
						return
				//This needs to be expanded, you shouldn't be able to pull an uniform through a suit of body armor, but there's other examples with other slots
				if(target.wear_suit) //There's a suit in the way
					source << "<span class='warning'>[target.wear_suit] is in the way, remove that first.</span>"
					return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their uniform ([target.w_uniform.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) uniform ([target.w_uniform])</font>")
				message = "\red <B>[source] is trying to take off [target.w_uniform] from [target]'s body!</B>"
		if("tie")
			if(target.w_uniform && istype(target.w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/uniform_suit = target.w_uniform
				if(uniform_suit.hastie)
					target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their accessory ([uniform_suit.hastie.name]) removed by [source.name] ([source.ckey])</font>")
					source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) accessory ([uniform_suit.hastie])</font>")
					if(istype(uniform_suit.hastie, /obj/item/clothing/tie/holobadge) || istype(uniform_suit.hastie, /obj/item/clothing/tie/medal))
						source.visible_message("\red <B>[source] tears off \the [uniform_suit.hastie] from [target]'s [uniform_suit]!</B>")
						done()
						return
					else
						message = "\red <B>[source] is trying to take off \a [uniform_suit.hastie] from [target]'s [uniform_suit]!</B>"
		if("s_store")
			if(target.s_store)
				if(!target.s_store.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit storage item ([target.s_store.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit storage item ([target.s_store])</font>")
				message = "\red <B>[source] is trying to take off [target.s_store] from [target]'s suit!</B>"
		if("pockets")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their pockets emptied by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to empty [target.name]'s ([target.ckey]) pockets</font>")
			for(var/obj/item/I in list(target.l_store, target.r_store))
				if(I.on_found(source))
					return
			message = "\red <B>[source] is trying to empty [target]'s pockets.</B>"
		if("CPR")
			if(!target.cpr_time)
				del(src)
			target.cpr_time = 0
			message = "\red <B>[source] is trying perform CPR on [target]!</B>"
		if("id")
			if(target.wear_id)
				if(!target.wear_id.canremove) return
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their ID ([target.wear_id.name]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) ID ([target.wear_id])</font>")
				message = "\red <B>[source] is trying to take off [target.wear_id] from [target]'s body!</B>"
		if("internal")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
			if(target.internal)
				message = "\red <B>[source] is trying to disable [target]'s internals</B>"
			else
				message = "\red <B>[source] is trying to enable [target]'s internals.</B>"
		if("splints")
			message = "\red <B>[source] is trying to remove [target]'s splints!</B>"
		if("sensor")
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors toggled by [source.name] ([source.ckey])</font>")
			source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) sensors</font>")
			var/obj/item/clothing/under/suit = target.w_uniform
			if(suit.has_sensor >= 2)
				source << "The controls are locked."
				return
			message = "\red <B>[source] is trying to modify [target]'s suit sensors!</B>"

	source.visible_message(message)
	spawn(HUMAN_STRIP_DELAY)
		done()
		return
	return

/*
This proc equips stuff (or does something else) when removing stuff manually from the character window when you click and drag.
It works in conjuction with the process() above.
This proc works for humans only. Aliens stripping humans and the like will all use this proc. Stripping monkeys or somesuch will use their version of this proc.
The first if statement for "mask" and such refers to items that are already equipped and un-equipping them.
The else statement is for equipping stuff to empty slots.
!canremove refers to variable of /obj/item/clothing which either allows or disallows that item to be removed.
It can still be worn/put on as normal.
*/
/obj/effect/equip_e/human/done()	//TODO: And rewrite this :< ~Carn
	target.cpr_time = 1
	if(isanimal(source)) return //animals cannot strip people
	if(!source || !target) return		//Target or source no longer exist
	if(source.loc != s_loc) return		//source has moved
	if(target.loc != t_loc) return		//target has moved
	if(LinkBlocked(s_loc,t_loc)) return	//Use a proxi!
	if(item && source.get_active_hand() != item) return	//Swapped hands / removed item from the active one
	if ((source.is_mob_restrained() || source.stat)) return //Source restrained or unconscious / dead

	var/slot_to_process
	var/obj/item/strip_item //this will tell us which item we will be stripping - if any.

	switch(place)	//here we go again...
		if("mask")
			slot_to_process = WEAR_FACE
			if (target.wear_mask && target.wear_mask.canremove)
				strip_item = target.wear_mask
		if("gloves")
			slot_to_process = WEAR_HANDS
			if (target.gloves && target.gloves.canremove)
				strip_item = target.gloves
		if("eyes")
			slot_to_process = WEAR_EYES
			if (target.glasses)
				strip_item = target.glasses
		if("belt")
			slot_to_process = WEAR_WAIST
			if (target.belt)
				strip_item = target.belt
		if("s_store")
			slot_to_process = WEAR_J_STORE
			if (target.s_store)
				strip_item = target.s_store
		if("head")
			slot_to_process = WEAR_HEAD
			if (target.head && target.head.canremove)
				strip_item = target.head
		if("l_ear")
			slot_to_process = WEAR_L_EAR
			if (target.l_ear)
				strip_item = target.l_ear
		if("r_ear")
			slot_to_process = WEAR_R_EAR
			if (target.r_ear)
				strip_item = target.r_ear
		if("shoes")
			slot_to_process = WEAR_FEET
			if (target.shoes && target.shoes.canremove)
				strip_item = target.shoes
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				del(src)
			slot_to_process = WEAR_L_HAND
			if (target.l_hand)
				strip_item = target.l_hand
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				del(src)
			slot_to_process = WEAR_R_HAND
			if (target.r_hand)
				strip_item = target.r_hand
		if("uniform")
			slot_to_process = WEAR_BODY
			if(target.w_uniform && target.w_uniform.canremove)
				strip_item = target.w_uniform
		if("suit")
			slot_to_process = WEAR_JACKET
			if (target.wear_suit && target.wear_suit.canremove)
				strip_item = target.wear_suit
		if("tie")
			var/obj/item/clothing/under/suit = target.w_uniform
			if(suit && suit.hastie)
				suit.hastie.on_removed(usr)
				suit.hastie = null
				target.update_inv_w_uniform()
		if("id")
			slot_to_process = WEAR_ID
			if (target.wear_id)
				strip_item = target.wear_id
		if("back")
			slot_to_process = WEAR_BACK
			if (target.back)
				strip_item = target.back
		if("handcuff")
			slot_to_process = WEAR_HANDCUFFS
			if (target.handcuffed)
				strip_item = target.handcuffed
		if("legcuff")
			slot_to_process = WEAR_LEGCUFFS
			if (target.legcuffed)
				strip_item = target.legcuffed
		if("splints")
			var/can_reach_splints = 1
			if(target.wear_suit && istype(target.wear_suit,/obj/item/clothing/suit/space))
				var/obj/item/clothing/suit/space/suit = target.wear_suit
				if(suit.supporting_limbs && suit.supporting_limbs.len)
					source << "You cannot remove the splints, [target]'s [suit] is supporting some of the breaks."
					can_reach_splints = 0

			if(can_reach_splints)
				for(var/organ in list("l_leg","r_leg","l_arm","r_arm","r_hand","l_hand","r_foot","l_foot","chest","head","groin"))
					var/datum/organ/external/o = target.get_organ(organ)
					if (o && o.status & ORGAN_SPLINTED)
						var/obj/item/W = new /obj/item/stack/medical/splint(amount=1)
						o.status &= ~ORGAN_SPLINTED
						if (W)
							W.loc = target.loc
							W.layer = initial(W.layer)
							W.add_fingerprint(source)
		if("CPR")
			if ((target.health > config.health_threshold_dead && target.health < config.health_threshold_crit))
				var/suff = min(target.getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
				target.adjustOxyLoss(-suff)
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message("\red [source] performs CPR on [target]!", 1)
				target << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
				source << "\red Repeat at least every 7 seconds."
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(S)
				S.add_fingerprint(source)
				if (!(istype(S, /obj/item/weapon/dnainjector)))
					S.inuse = 0
					del(src)
				S.inject(target, source)
				if (S.s_time >= world.time + 30)
					S.inuse = 0
					del(src)
				S.s_time = world.time
				source.visible_message("\red [source] injects [target] with the DNA Injector!")
				S.inuse = 0
		if("pockets")
			if (!item || (target.l_store && target.r_store))	// Only empty pockets when hand is empty or both pockets are full
				slot_to_process = WEAR_L_STORE
				strip_item = target.l_store		//We'll do both
			else if (target.l_store)
				slot_to_process = WEAR_R_STORE
			else
				slot_to_process = WEAR_L_STORE
		if("sensor")
			var/obj/item/clothing/under/suit = target.w_uniform
			if (suit)
				if(suit.has_sensor >= 2)
					source << "The controls are locked."
				else
					suit.set_sensors(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!(istype(target.wear_mask, /obj/item/clothing/mask)))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
					else if (istype(target.s_store, /obj/item/weapon/tank))
						target.internal = target.s_store
					else if (istype(target.belt, /obj/item/weapon/tank))
						target.internal = target.belt
					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message("[target] is now running on internals.", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"
	if(slot_to_process)
		if(strip_item) //Stripping an item from the mob
			if(istype(strip_item,/obj/item/weapon/gun/smartgun)) //NOPE
				del(src)
				return

			//Prevent donor items from being unequipped
			if(strip_item.flags_inventory & CANTSTRIP)
				source << "<span class='warning'>You're having difficulty removing that item.</span>"
				return

			target.drop_inv_item_on_ground(strip_item)
			if(slot_to_process == WEAR_L_STORE) //pockets! Needs to process the other one too. Snowflake code, wooo! It's not like anyone will rewrite this anytime soon. If I'm wrong then... CONGRATULATIONS! ;)
				//Psst. You were wrong. - Abby
				if(target.r_store)
					target.drop_inv_item_on_ground(target.r_store)
			target.update_icons()
		else
			if(item && target.has_organ_for_slot(slot_to_process)) //Placing an item on the mob
				if(item.mob_can_equip(target, slot_to_process, 0))
					source.drop_inv_item_on_ground(item)
					if(item) //Might be self-deleted?
						target.equip_to_slot_if_possible(item, slot_to_process, 0, 1, 1)
					source.update_icons()
					target.update_icons()

	if(source && target)
		if(source.machine == target)
			target.show_inv(source)
	del(src)
