/obj/machinery/computer/arcade
	name = "Black Donnovan II: Double Revenge"
	desc = "Does not support Pinball."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "arcade"
	circuit = "/obj/item/circuitboard/computer/arcade"
	var/enemy_name = "Space Villain"
	var/temp = "Sponsored by Nanotrasen and the TerraGov Marine Corps" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	var/list/prizes = list(	/obj/item/storage/box/MRE			    = 3,
							/obj/item/spacecash/c10					= 4,
							/obj/item/ammo_magazine/flamer_tank			    = 1,
							/obj/item/tool/lighter/zippo			= 2,
							/obj/item/tool/weldingtool					= 1,
							/obj/item/storage/box/uscm_mre			= 2,
							/obj/item/camera				        	= 2,
							/obj/item/camera_film					= 4,
							/obj/item/cell/crap/empty				= 3,
							/obj/item/tool/hand_labeler					= 1
							)

/obj/machinery/computer/arcade
	var/turtle = 0

/obj/machinery/computer/arcade/New()
	..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn")

	src.enemy_name = oldreplacetext((name_part1 + name_part2), "the ", "")
	src.name = (name_action + name_part1 + name_part2)



/obj/machinery/computer/arcade/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/arcade/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/arcade/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_interaction(src)
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"
	dat += "<center><h4>[src.enemy_name]</h4></center>"

	dat += "<br><center><h3>[src.temp]</h3></center>"
	dat += "<br><center>Health: [src.player_hp]|Magic: [src.player_mp]|Enemy Health: [src.enemy_hp]</center>"

	if (src.gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a>|"
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a>|"
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	var/datum/browser/popup = new(user, "arcade", "<div align='center'>Arcade</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "arcade")


/obj/machinery/computer/arcade/Topic(href, href_list)
	if(..())
		return

	if (!src.blocked && !src.gameover)
		if (href_list["attack"])
			src.blocked = 1
			var/attackamt = rand(2,6)
			src.temp = "Your sword strikes for [attackamt] damage!"
			src.updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.updateUsrDialog()
			turtle++

			sleep(10)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			src.blocked = 1
			var/chargeamt = rand(4,7)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt
			if(turtle > 0)
				turtle--

			src.updateUsrDialog()
			sleep(10)
			src.arcade_action()

	if (href_list["close"])
		usr.unset_interaction()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0

		if(CHECK_BITFIELD(obj_flags, EMAGGED))
			src.New()
			DISABLE_BITFIELD(obj_flags, EMAGGED)

	src.updateUsrDialog()
	return

/obj/machinery/computer/arcade/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		if(!gameover)
			src.gameover = 1
			src.temp = "[src.enemy_name] has fallen! Rejoice!"

			if(CHECK_BITFIELD(obj_flags, EMAGGED))
				new /obj/effect/spawner/newbomb/timer/syndicate(src.loc)
				new /obj/item/clothing/head/collectable/petehat(src.loc)
				log_game("[key_name(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				message_admins("[ADMIN_TPMONTY(usr)] has outbombed Cuban Pete and been awarded a bomb.")

				src.New()
				DISABLE_BITFIELD(obj_flags, EMAGGED)
			else if(!contents.len)
				var/prizeselect = pickweight(prizes)
				new prizeselect(src.loc)

				if(istype(prizeselect, /obj/item/toy/gun)) //Ammo comes with the gun
					new /obj/item/toy/gun_ammo(src.loc)

				else if(istype(prizeselect, /obj/item/clothing/suit/syndicatefake)) //Helmet is part of the suit
					new	/obj/item/clothing/head/syndicatefake(src.loc)

			else
				var/atom/movable/prize = pick(contents)
				prize.loc = src.loc

	else if (CHECK_BITFIELD(obj_flags, EMAGGED) && (turtle >= 4))
		var/boomamt = rand(5,10)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			src.temp = "You have been drained! GAME OVER"
			if(CHECK_BITFIELD(obj_flags, EMAGGED))
				usr.gib()

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "GAME OVER"
		if(CHECK_BITFIELD(obj_flags, EMAGGED))
			usr.gib()

	src.blocked = 0
	return


/obj/machinery/computer/arcade/attackby(obj/item/I, mob/user, params)
	. = ..()
	
	if(istype(I, /obj/item/card/emag) && !CHECK_BITFIELD(obj_flags, EMAGGED))
		temp = "If you die in the game, you die for real!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = FALSE
		blocked = FALSE

		ENABLE_BITFIELD(obj_flags, EMAGGED)

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"

		updateUsrDialog()


/obj/machinery/computer/arcade/emp_act(severity)
	if(machine_stat & (NOPOWER|BROKEN))
		..(severity)
		return
	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(num_of_prizes; num_of_prizes > 0; num_of_prizes--)
		empprize = pickweight(prizes)
		new empprize(src.loc)

	..(severity)
