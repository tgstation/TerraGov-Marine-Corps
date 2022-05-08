/datum/job/som
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_SOM


/datum/outfit/job/som/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.undershirt = 6
	H.regenerate_icons()

///wip stuff, need to move main SOM and ert chads to separate child branches of SOM...

/datum/job/som/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_job(faction)
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/human_spawn = C
	if(!(human_spawn.species.species_flags & ROBOTIC_LIMBS))
		human_spawn.set_nutrition(rand(60, 250))
	if(!human_spawn.assigned_squad)
		CRASH("after_spawn called for a marine without an assigned_squad")
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[human_spawn.assigned_squad.color]>[lowertext(human_spawn.assigned_squad.name)] squad</font></b>.
Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."})

/datum/job/som/equip_spawning_squad(mob/living/carbon/human/new_character, datum/squad/assigned_squad, client/player)
	if(!assigned_squad)
		SSjob.JobDebug("Failed to put marine role in squad. Player: [player.key] Job: [title]")
		return
	assigned_squad.insert_into_squad(new_character)

//SOM Standard
/datum/job/som/standard
	title = SOM_SQUAD_MARINE //can change when ert split out if desired
	paygrade = "SOM1"
	comm_title = "Mar"
	minimap_icon = "private"
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	outfit = /datum/outfit/job/som/standard
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/standard,
		/datum/outfit/job/som/standard/one,
	)

/datum/outfit/job/som/standard
	name = "SOM Standard"
	jobtype = /datum/job/som/standard

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/standard
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/som
	r_store = /obj/item/storage/pouch/firstaid/som/full
	l_store = /obj/item/storage/pouch/pistol
	back = /obj/item/storage/backpack/lightpack/som

//AK
/datum/outfit/job/som/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp, SLOT_IN_L_POUCH)

//Charger
/datum/outfit/job/som/standard/one
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness

/datum/outfit/job/som/standard/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp, SLOT_IN_L_POUCH)

//SOM Medic
/datum/job/som/medic
	title = SOM_SQUAD_CORPSMAN
	paygrade = "SOM2"
	comm_title = "Med"
	minimap_icon = "medic"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/som/medic
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/medic,
		/datum/outfit/job/som/medic/one,
	)

//AK
/datum/outfit/job/som/medic
	name = "SOM Medic"
	jobtype = /datum/job/som/medic

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/combatLifesaver/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/medic/vest
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/medic
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/som
	r_store = /obj/item/storage/pouch/autoinjector/advanced/full
	l_store = /obj/item/storage/pouch/magazine/large
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/meraderm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_L_POUCH)

//Charger
/datum/outfit/job/som/medic/one
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness

/datum/outfit/job/som/medic/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/meraderm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_L_POUCH)

//SOM Veteran
/datum/job/som/veteran
	title = SOM_SQUAD_VETERAN
	paygrade = "SOM3"
	comm_title = "SGnr"
	minimap_icon = "smartgunner"
	outfit = /datum/outfit/job/som/veteran
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/veteran,
		/datum/outfit/job/som/veteran/one,
		/datum/outfit/job/som/veteran/two,
		/datum/outfit/job/som/veteran/three,
	)

//Charger
/datum/outfit/job/som/veteran
	name = "SOM Veteran"
	jobtype = /datum/job/som/veteran

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran/highpower
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran/vet
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	r_store = /obj/item/storage/pouch/grenade
	l_store = /obj/item/storage/pouch/firstaid/som/full
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/veteran/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

//Caliver
/datum/outfit/job/som/veteran/one
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet

/datum/outfit/job/som/veteran/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

//Caliver and powerpack
/datum/outfit/job/som/veteran/two
	w_uniform = /obj/item/clothing/under/som/veteran/webbing_vet
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/job/som/veteran/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

//Culverin - bringing the big guns
/datum/outfit/job/som/veteran/three
	w_uniform = /obj/item/clothing/under/som/veteran/webbing_vet
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/job/som/veteran/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)


//SOM Leader
/datum/job/som/leader
	job_category = JOB_CAT_COMMAND
	title = SOM_SQUAD_LEADER
	paygrade = "SOM3"
	comm_title = JOB_COMM_TITLE_SQUAD_LEADER
	minimap_icon = "leader"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/som/leader
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/leader,
		/datum/outfit/job/som/leader/one,
		/datum/outfit/job/som/leader/two,
	)

//Charger
/datum/outfit/job/som/leader
	name = "SOM Leader"
	jobtype = /datum/job/som/leader

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/leader/highpower
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/leader/valk
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran/leader
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	r_store = /obj/item/storage/pouch/grenade
	l_store = /obj/item/storage/pouch/magazine/large
	back = /obj/item/storage/backpack/lightpack/som


/datum/outfit/job/som/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/motiondetector, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_L_POUCH)

//Caliver
/datum/outfit/job/som/leader/one
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet


/datum/outfit/job/som/leader/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/motiondetector, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_L_POUCH)

//Caliver and powerpack
/datum/outfit/job/som/leader/two
	w_uniform = /obj/item/clothing/under/som/leader/webbing
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	belt = /obj/item/belt_harness
	back = /obj/item/cell/lasgun/volkite/powerpack
	l_store = /obj/item/storage/pouch/general/large

/datum/outfit/job/som/leader/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pocketpistol, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pocketpistol, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pocketpistol, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_L_POUCH)
