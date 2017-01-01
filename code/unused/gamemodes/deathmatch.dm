/*
/datum/game_mode/deathmatch
	name = "deathmatch"
	config_tag = "deathmatch"
	var/startedat
	var/const/gamelength = 15 * 600 // 1/10 second

	announce()
		world << "<B>The current game mode is - Death Commando Deathmatch!</B>"
		world << "<B>Just kill everyone else. They're gonna try to kill you, after all. Respawning is enabled.</B>"

	post_setup()
		startedat = world.realtime
		abandon_allowed = 1
		setup_game()

		// TODO: DEFERRED Make this massively cleaner. It should hook before spawning, not after.
		var/list/mobs = list()
		for(var/mob/living/carbon/human/M in world)
			if (M.client)
				mobs += M
		for(var/mob/living/carbon/human/M in mobs)
			spawn()
				if(M.client)
					for(var/obj/item/weapon/W in list(M.wear_suit, M.w_uniform, M.r_store, M.l_store, M.wear_id, M.belt,
					                              M.gloves, M.glasses, M.head, M.ears, M.shoes, M.wear_mask, M.back,
					                              M.handcuffed, M.r_hand, M.l_hand))
						M.u_equip(W)
						del(W)

					var/randomname = "Killiam Shakespeare"
					if(commando_names.len)
						randomname = pick(commando_names)
						commando_names -= randomname
					var/newname = input(M,"You are a death commando. Would you like to change your name?", "Character Creation", randomname)
					if(!length(newname))
						newname = randomname
					newname = strip_html(newname,40)

					M.real_name = newname
					M.name = newname // there are WAY more things than this to change, I'm almost certain

					M.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(M), WEAR_BODY)
					M.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(M), WEAR_FEET)
					M.equip_to_slot_or_del(new /obj/item/clothing/suit/swat_suit/death_commando(M), WEAR_JACKET)
					M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/death_commando(M), WEAR_FACE)
					M.equip_to_slot_or_del(new /obj/item/clothing/gloves/swat(M), WEAR_HANDS)
					M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal(M), WEAR_EYES)
					M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse_rifle(M), WEAR_L_HAND)
					M.equip_to_slot_or_del(new /obj/item/weapon/m_pill/cyanide(M), WEAR_L_STORE)
					M.equip_to_slot_or_del(new /obj/item/weapon/flashbang(M), WEAR_R_STORE)

					var/obj/item/weapon/tank/air/O = new(M)
					M.equip_to_slot_or_del(O, WEAR_BACK)
					M.internal = O

					var/obj/item/weapon/card/id/W = new(M)
					W.access = get_all_accesses()
					W.name = "[newname]'s ID card (Death Commando)"
					W.assignment = "Death Commando"
					W.registered_name = newname
					M.equip_to_slot_or_del(W, WEAR_ID)
		..()

	check_win()
		return 1
*/