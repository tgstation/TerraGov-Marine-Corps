var/global/vox_tick = 1

/mob/living/carbon/human/proc/equip_vox_raider()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate(src)
	R.set_frequency(SYND_FREQ)
	equip_to_slot_or_del(R, WEAR_L_EAR)

	equip_to_slot_or_del(new /obj/item/clothing/under/vox/vox_robes(src), SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots/vox(src), SLOT_SHOES) // REPLACE THESE WITH CODED VOX ALTERNATIVES.
	equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow/vox(src), SLOT_GLOVES) // AS ABOVE.

	switch(vox_tick)
		if(1) // Vox raider!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/carapace(src), SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/carapace(src), SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(src), SLOT_BELT)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(src), SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/device/chameleon(src), SLOT_L_STORE)

			var/obj/item/weapon/gun/launcher/spikethrower/W = new(src)
			equip_to_slot_or_del(W, SLOT_R_HAND)


		if(2) // Vox engineer!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/pressure(src), SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/pressure(src), SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(src), SLOT_BELT)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/meson(src), SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/storage/box/emps(src), SLOT_R_HAND)
			equip_to_slot_or_del(new /obj/item/device/multitool(src), SLOT_L_HAND)


		if(3) // Vox saboteur!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/stealth(src), SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/stealth(src), SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(src), SLOT_BELT)
			equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(src), SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/card/emag(src), SLOT_L_STORE)
			equip_to_slot_or_del(new /obj/item/weapon/gun/dartgun/vox/raider(src), SLOT_R_HAND)
			equip_to_slot_or_del(new /obj/item/device/multitool(src), SLOT_L_HAND)

		if(4) // Vox medic!
			equip_to_slot_or_del(new /obj/item/clothing/suit/space/vox/medic(src), SLOT_WEAR_SUIT)
			equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/vox/medic(src), SLOT_HEAD)
			equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(src), SLOT_BELT) // Who needs actual surgical tools?
			equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(src), SLOT_GLASSES) // REPLACE WITH CODED VOX ALTERNATIVE.
			equip_to_slot_or_del(new /obj/item/weapon/circular_saw(src), SLOT_L_STORE)
			equip_to_slot_or_del(new /obj/item/weapon/gun/dartgun/vox/medical, SLOT_R_HAND)

	equip_to_slot_or_del(new /obj/item/clothing/mask/breath(src), SLOT_WEAR_MASK)
	equip_to_slot_or_del(new /obj/item/weapon/tank/nitrogen(src), SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/device/flashlight(src), SLOT_R_STORE)

	var/obj/item/weapon/card/id/syndicate/C = new(src)
	C.name = "[real_name]'s Legitimate Human ID Card"
	C.icon_state = "id"
	C.access = list(access_syndicate)
	C.assignment = "Trader"
	C.registered_name = real_name
	C.registered_user = src
	var/obj/item/weapon/storage/wallet/W = new(src)
	W.handle_item_insertion(C)
	spawn_money(rand(50,150)*10,W)
	equip_to_slot_or_del(W, SLOT_WEAR_ID)
	vox_tick++
	if (vox_tick > 4) vox_tick = 1

	return 1
