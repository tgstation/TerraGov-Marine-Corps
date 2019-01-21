/client/proc/only_one()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		to_chat(H, "<B>You are the traitor.</B>")

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/implant))
				continue
			qdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), SLOT_HEAD)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), SLOT_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), SLOT_SHOES)

		var/obj/item/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, SLOT_WEAR_ID)

	message_admins("<span class='notice'> [key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>", 1)
	log_admin("[key_name(usr)] used there can be only one.")
