var/global/waiting_for_drop_votes = 0

var/global/list/good_items = list(/obj/item/weapon/storage/belt/utility/full,\
								/obj/item/device/binoculars,\
								/obj/item/device/flash,\
								/obj/item/weapon/flamethrower,\
								/obj/item/weapon/shield/riot,\
								/obj/item/weapon/storage/backpack/yautja,\
								/obj/item/weapon/gun/rifle/m41a,\
								/obj/item/weapon/gun/shotgun/pump,\
								/obj/structure/largecrate/guns/merc,\
								/obj/structure/largecrate/guns/russian,\
								/obj/item/weapon/storage/belt/knifepouch,\
								/obj/item/clothing/head/helmet/marine,\
								/obj/item/stack/medical/advanced/ointment,\
								/obj/item/stack/medical/advanced/bruise_pack,\
								/obj/item/clothing/tie/storage/webbing,\
								/obj/item/weapon/storage/firstaid/regular,\
								/obj/item/clothing/head/helmet/marine/leader,\
								/obj/item/attachable/suppressor,\
								/obj/item/attachable/reddot,\
								/obj/item/attachable/flashlight,\
								/obj/item/attachable/grenade,\
								/obj/item/attachable/flamer,\
								/obj/item/clothing/suit/storage/marine,\
								/obj/item/clothing/head/helmet/marine,\
								/obj/item/clothing/gloves/specialist,\
								/obj/item/weapon/gun/taser,\
								/obj/item/weapon/gun/pistol/vp70,\
								/obj/item/weapon/gun/rifle/m41a/scoped,\
								/obj/item/weapon/gun/rifle/lmg,\
								/obj/item/weapon/gun/shotgun/combat,\
								/obj/item/weapon/gun/sniper,
								/obj/item/clothing/head/helmet/marine/PMC/commando,\
								/obj/item/clothing/shoes/PMC
								)

var/global/list/god_items = list(/obj/item/weapon/twohanded/glaive,\
								/obj/item/clothing/head/helmet/space/yautja,\
								/obj/item/clothing/suit/armor/yautja,\
								/obj/item/clothing/suit/armor/yautja/full,\
								/obj/item/clothing/shoes/yautja,\
								/obj/item/weapon/melee/yautja_chain,\
								/obj/item/weapon/melee/yautja_knife,\
								/obj/item/weapon/melee/yautja_scythe,\
								/obj/item/weapon/melee/combistick,\
								/obj/item/weapon/storage/belt/medical/combatLifesaver,\
								/obj/item/weapon/storage/pill_bottle/tramadol,\
								/obj/item/weapon/storage/box/rocket_system,\
								/obj/item/weapon/storage/box/grenade_system,\
								/obj/item/weapon/storage/box/m42c_system,\
								/obj/item/clothing/suit/storage/marine/PMCarmor/commando,\
								/obj/item/clothing/suit/storage/marine_smartgun_armor/heavypmc,\
								/obj/item/clothing/head/helmet/marine/PMC/heavypmc,\
								/obj/item/weapon/gun/minigun,\
								/obj/item/weapon/gun/pistol/vp78,\
								/obj/item/weapon/gun/rifle/m41a/elite,\
								/obj/item/weapon/gun/sniper/elite,
								/obj/item/weapon/gun/rocketlauncher/quad)

var/global/list/crap_items = list(/obj/item/weapon/cell/high,\
								/obj/item/device/multitool,\
								/obj/item/weapon/crowbar,\
								/obj/item/weapon/crowbar,\
								/obj/item/device/flashlight,\
								/obj/item/device/flashlight,\
								/obj/item/weapon/reagent_containers/food/snacks/donkpocket,\
								/obj/item/weapon/grenade/smokebomb,\
								/obj/item/weapon/wirecutters,\
								/obj/item/weapon/weldingtool,\
								/obj/item/weapon/wrench,\
								/obj/random/bomb_supply,\
								/obj/random/toolbox,\
								/obj/random/tech_supply,\
								/obj/item/weapon/bananapeel,\
								/obj/item/weapon/soap,\
								/obj/item/weapon/plastique,\
								/obj/item/weapon/twohanded/fireaxe,\
								/obj/item/weapon/twohanded/spear,\
								/obj/item/weapon/claymore,\
								/obj/item/weapon/katana,\
								/obj/item/weapon/harpoon,\
								/obj/item/weapon/baseballbat,\
								/obj/item/weapon/baseballbat/metal,\
								/obj/item/weapon/butterfly,\
								/obj/item/weapon/grenade/empgrenade,\
								/obj/item/weapon/grenade/flashbang,\
								/obj/item/weapon/storage/backpack,\
								/obj/item/weapon/storage/backpack/holding,\
								/obj/item/weapon/storage/backpack/cultpack,\
								/obj/item/weapon/storage/backpack/satchel,\
								/obj/item/weapon/claymore/mercsword,\
								/obj/item/weapon/claymore/mercsword/machete,\
								/obj/item/weapon/storage/backpack/marinesatchel/commando,\
								/obj/item/clothing/suit/storage/CMB,\
								/obj/item/weapon/grenade/explosive,\
								/obj/item/weapon/grenade/incendiary,\
								/obj/item/device/flashlight/combat,\
								/obj/structure/largecrate/guns/merc,\
								/obj/item/weapon/legcuffs/yautja,\
								/obj/item/weapon/storage/box/wy_mre,\
								/obj/item/weapon/combat_knife,\
								/obj/item/stack/medical/ointment,\
								/obj/item/stack/medical/bruise_pack,\
								/obj/item/weapon/hatchet, \
								/obj/item/weapon/hatchet, \
								/obj/item/weapon/hatchet, \
								/obj/item/weapon/hatchet, \
								/obj/item/ammo_magazine/rifle/incendiary)


/datum/game_mode/huntergames
	name = "hunter games"
	config_tag = "huntergames"
	required_players = 1
	var/list/contestants = list()
	var/checkwin_counter = 0
	var/finished = 0
	var/has_started_timer = 5 //This is a simple timer so we don't accidently check win conditions right in post-game
	var/dropoff_timer = 800 //10 minutes.
	var/last_drop = 0
	var/last_death = 0
	var/death_timer = 300 // 3 minutes.
	var/last_tally
	var/list/turf/primary_spawns = list()
	var/list/turf/secondary_spawns = list()

	var/list/turf/crap_spawns = list()
	var/list/turf/good_spawns = list()
	var/list/turf/god_spawns = list()
	var/list/supply_votes = list()

	var/ticks_passed = 0
	var/drops_disabled = 0

/datum/game_mode/huntergames/announce()
	return 1

/datum/game_mode/huntergames/send_intercept()
	return 1

/datum/game_mode/huntergames/pre_setup()
	var/obj/effect/landmark/L
	primary_spawns = list()
	secondary_spawns = list()
	crap_spawns = list()
	good_spawns = list()
	god_spawns = list()

	for(L in world)
		if(L.name == "hunter_primary")
			primary_spawns += L.loc
		if(L.name == "hunter_secondary")
			secondary_spawns += L.loc
		if(L.name == "crap_item")
			crap_spawns += L.loc
		if(L.name == "good_item")
			good_spawns += L.loc
		if(L.name == "god_item")
			god_spawns += L.loc

	for(var/mob/new_player/player in player_list)
		if(player && player.ready)
			if(player.mind)
				player.mind.assigned_role = "ROLE"
			else
				if(player.client)
					player.mind = new(player.key)
	return 1

/datum/game_mode/huntergames/post_setup()
	var/mob/M
	for(M in mob_list)
		if(M.client && istype(M,/mob/living/carbon/human))
			contestants += M
			spawn_contestant(M)

	for(var/turf/T in crap_spawns)
		place_drop(T,"crap",0)

	for(var/turf/T in good_spawns)
		place_drop(T,"good",0)

	for(var/turf/T in god_spawns)
		place_drop(T,"god",0)


	spawn(10)
		world << "<B>The current game mode is - HUNTER GAMES!</B>"
		world << "You have been dropped off on a Weyland Yutani colony overrun with alien Predators who have turned it into a game preserve.."
		world << "And you are both the hunter and the hunted!"
		world << "Be the <B>last survivor</b> and <B>win glory</B>! Fight in any way you can! Team up or be a loner, it's up to you."
		world << "Be warned though - if someone hasn't died in 3 minutes, the watching Predators get irritated!"
		world << sound('sound/effects/siren.ogg')

	spawn(1000)
		loop_package()

/datum/game_mode/huntergames/proc/spawn_contestant(var/mob/M)

	var/mob/living/carbon/human/H
	var/turf/picked

	if(primary_spawns.len)
		picked = pick(primary_spawns)
		primary_spawns -= picked
	else
		if(secondary_spawns.len)
			picked = pick(secondary_spawns)
		else
			message_admins("There were no spawn points available for a contestant..")

	if(!picked || isnull(picked)) //???
		message_admins("Warning, null picked spawn in spawn_contestant")
		return 0

	if(istype(M,/mob/living/carbon/human)) //somehow?
		H = M
		if(H.contents.len)
			for(var/I in H.contents)
				del(I)
		H.loc = picked
	else
		H = new(picked)

	H.key = M.key

	if(!H.mind)
		H.mind = new(H.key)

	H.Weaken(15)
	H.nutrition = 300

	var/randjob = rand(0,10)
	switch(randjob)
		if(0) //colonial marine
			if(prob(50))
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit(H), slot_w_uniform)
			else
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_underoos(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		if(1) //MP
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/mp(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		if(2) //Commander!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), slot_shoes)
		if(3) //CL
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
		if(4) //PMC!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMCmask(H), slot_wear_mask)
		if(5) //Merc!
			if(prob(80))
				H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/dutch(H), slot_w_uniform)
			else
				H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), slot_w_uniform)
			if(prob(50))
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
			if(prob(75))
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/leather(M), slot_shoes)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/magboots(M), slot_shoes)
		if(6)//BEARS!!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/Bear(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
			H.remove_language("English")
			H.remove_language("Sol Common")
			H.add_language("Russian")
		if(7) //PMC Commando!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_jumpsuit/PMC/commando(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		if(8) //Assassin!
			H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
		if(9) //Corporate guy
			H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(H), slot_wear_suit)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
		if(10) //Colonial Marshal
			H.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform(H), slot_w_uniform)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), slot_shoes)

	H.equip_to_slot_or_del(new /obj/item/device/flashlight/flare(H), slot_l_store)

	H.update_icons()

	//Give them some information
	spawn(4)
		H << "<h2>There can be only one!!</h2>"
		H << "Use the flare in your pocket to light the way!"
	return 1

/datum/game_mode/huntergames/proc/loop_package()
	while(finished == 0)
		if(!drops_disabled)
			world << "<B>Your Predator capturers have decided it is time to bestow a gift upon the scurrying humans.</b>"
			world << "<B>One lucky contestant should prepare for a supply drop in 60 seconds.</b>"
			for(var/mob/dead/D in world)
				D << "<b>--> Now is your chance to vote for a supply drop beneficiary! Go to Ghost tab, Spectator Vote!</b>"
			world << sound('sound/effects/alert.ogg')
			last_drop = world.time
			waiting_for_drop_votes = 1
			sleep(600)
			if(!supply_votes.len)
				world << "<b>Nobody got anything! .. weird.</b>"
				waiting_for_drop_votes = 0
				supply_votes = null
				supply_votes = list()
			else
				var/mob/living/carbon/human/winner = pick(supply_votes) //Way it works is, more votes = more odds of winning. But not guaranteed.
				if(istype(winner) && !winner.stat)
					world << "The spectator and Predator votes have been talled, and the supply drop recipient is <B>[winner.real_name]</B>! Congrats!"
					world << sound('sound/effects/alert.ogg')
					world << "The package will shortly be dropped off at: [get_area(winner.loc)]."
					var/turf/drop_zone = locate(winner.x + rand(-2,2),winner.y + rand(-2,2),winner.z)
					if(istype(drop_zone))
						playsound(drop_zone,'sound/effects/bamf.ogg',100,1)
						if(prob(50))
							place_drop(drop_zone,"good")
						else
							place_drop(drop_zone,"god")
				else
					world << "<B>The spectator and Predator votes have been talled, and the supply drop recipient is </B>dead or dying<B>. Bummer.</b>"
					world << sound('sound/misc/sadtrombone.ogg')
				supply_votes = null
				supply_votes = list()
				waiting_for_drop_votes = 0
		sleep(5000)

/datum/game_mode/huntergames/process()

	checkwin_counter++
	ticks_passed++
	if(prob(2)) dropoff_timer += ticks_passed //Increase the timer the longer the round goes on.

	if(has_started_timer > 0) //Initial countdown, just to be safe, so that everyone has a chance to spawn before we check anything.
		has_started_timer--

	if(checkwin_counter >= 10) //Only check win conditions every 5 ticks.
		if(!finished)
			check_win()
		checkwin_counter = 0
	return 0

/datum/game_mode/huntergames/check_win()
	var/C = count_humans()
	if(C < last_tally)
		if(last_tally - C == 1)
			world << "<B>A contestant has died! There are now [C] contestants remaining!</b>"
			world << sound('sound/effects/explosionfar.ogg')
		else
			var/diff = last_tally - C
			world << "<B>Multiple contestants have died! [diff] in fact. [C] are left!</b>"
			spawn(7)
				world << sound('sound/effects/explosionfar.ogg')

	last_tally = C
	if(last_tally == 1 || ismob(last_tally))
		finished = 1
	else if (last_tally < 1)
		finished = 2
	else
		finished = 0
	return

/datum/game_mode/huntergames/proc/count_humans()
	var/human_count = 0

	for(var/mob/living/carbon/human/H in living_mob_list)
		if(istype(H) && H.stat == 0 && !istype(get_area(H.loc),/area/centcom) && !istype(get_area(H.loc),/area/tdome))
			if(H.species != "Yautja") // Preds don't count in round end.
				human_count += 1 //Add them to the amount of people who're alive.

	return human_count

///////////////////////////////
//Checks if the round is over//
///////////////////////////////
/datum/game_mode/huntergames/check_finished()
	if(finished != 0)
		return 1

	return 0


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relevant information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/huntergames/declare_completion()
	var/mob/living/carbon/winner = null

	for(var/mob/living/carbon/human/Q in living_mob_list)
		if(istype(Q) && Q.stat == 0 && !isYautja(Q) && !istype(get_area(Q.loc),/area/centcom) && !istype(get_area(Q.loc),/area/tdome))
			winner = Q
			break

	if(finished == 1 && !isnull(winner) && istype(winner))
		feedback_set_details("round_end_result","single winner")
		world << "\red <FONT size = 4><B>We have a winner! >> [winner.real_name] ([winner.key]) << defeated all enemies!</B></FONT>"
		world << "<FONT size = 3><B>Well done, your tale of survival will live on in legend!</B></FONT>"

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]\nBig Winner: [winner.real_name] ([winner.key])"

	else if(finished == 2)
		feedback_set_details("round_end_result","no winners")
		world << "\red <FONT size = 4><B>NOBODY WON!?</B></FONT>"
		world << "<FONT size = 3><B>'Somehow you stupid humans managed to even fuck up killing yourselves. Well done.'</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"
	else
		feedback_set_details("round_end_result","no winners")
		world << "\red <FONT size = 4><B>NOBODY WON!</B></FONT>"
		world << "<FONT size = 3><B>There was a winner, but they died before they could receive the prize!! Bummer.</B></FONT>"
		world << 'sound/misc/sadtrombone.ogg'

		if(round_stats) // Logging to data/logs/round_stats.log
			round_stats << "Humans remaining: [count_humans()]\nRound time: [worldtime2text()][log_end]"

	return 1

/datum/game_mode/proc/auto_declare_completion_huntergames()
	return

/datum/game_mode/huntergames/proc/place_drop(var/turf/T,var/OT, var/in_crate = 0)
	if(!istype(T)) return
	var/objtype

	if(in_crate == 0 && prob(15) && (OT == "good" || OT == "god")) in_crate = 1

	if(isnull(OT) || OT == "")
		OT = "crap"

	if(OT == "god")
		objtype = pick(god_items)
	else if (OT == "good")
		objtype = pick(good_items)
	else
		objtype = pick(crap_items)

	if(in_crate)
		var/crate = new /obj/structure/closet/crate(T)
		new objtype(crate)

	else
		new objtype(T)

	return

