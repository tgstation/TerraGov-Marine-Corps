/client/proc/only_one()
	if(!ticker)
		alert("The game hasn't started yet!")
		return

	for(var/mob/living/carbon/human/H in player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue

		ticker.mode.traitors += H.mind
		H.mind.special_role = "traitor"

		H << "<B>You are the traitor.</B>"

		for (var/obj/item/I in H)
			if (istype(I, /obj/item/implant))
				continue
			cdel(I)

		H.equip_to_slot_or_del(new /obj/item/clothing/under/kilt(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret(H), WEAR_HEAD)
		H.equip_to_slot_or_del(new /obj/item/weapon/claymore(H), WEAR_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), WEAR_FEET)

		var/obj/item/card/id/W = new(H)
		W.name = "[H.real_name]'s ID Card"
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Highlander"
		W.registered_name = H.real_name
		H.equip_to_slot_or_del(W, WEAR_ID)

	message_admins("\blue [key_name_admin(usr)] used THERE CAN BE ONLY ONE!", 1)
	log_admin("[key_name(usr)] used there can be only one.")
