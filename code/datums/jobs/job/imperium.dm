/datum/job/imperial
	job_category = JOB_CAT_MARINE
	comm_title = "IMP"
	faction = FACTION_IMP
	skills_type = /datum/skills/imperial
	supervisors = "the sergeant"
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS

//Base job for normal gameplay Imperium, not ERT.
/datum/job/imperial/squad
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	supervisors = "the sergeant"
	selection_color = "#ffeeee"
	exp_type_department = EXP_TYPE_MARINES

/datum/job/imperial/squad/radio_help_message(mob/M)
	. = ..()
	to_chat(M, span_highdanger("gloreh to terah"))

/datum/job/imperial/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_job(faction)
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/human_spawn = C
	if(!(human_spawn.species.species_flags & ROBOTIC_LIMBS))
		human_spawn.set_nutrition(250)
	if(!human_spawn.assigned_squad)
		CRASH("after_spawn called for a marine without an assigned_squad")
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[human_spawn.assigned_squad.color]>[lowertext(human_spawn.assigned_squad.name)] squad</font></b>.
Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."})

/datum/job/imperial/squad/equip_spawning_squad(mob/living/carbon/human/new_character, datum/squad/assigned_squad, client/player)
	if(!assigned_squad)
		SSjob.JobDebug("Failed to put marine role in squad. Player: [player.key] Job: [title]")
		return
	assigned_squad.insert_into_squad(new_character)

//Guard Standard
/datum/job/imperial/squad/standard
	title =	IMPERIUM_SQUAD_PRIVATE
	paygrade = "SOM1"
	comm_title = "Mar"
	minimap_icon = "private"
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	outfit = /datum/outfit/job/imperial/squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/imperial/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Easy<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Warhammer 40k<br /><br /><br />
		the meatgrinder of the imperoum.
		<br /><br />
		<b>Duty</b>: Carry out orders made by your Sergeant or the Commissar, deal with any threats that oppose the Imperium.
	"}

/datum/job/imperial/squad/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file guardsman of the Imperium, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the guard. For the emperor!"})

/datum/outfit/job/imperial/squad/standard
	name = "Guardsman Private"
	jobtype = /datum/job/imperial/squad/standard

	id = /obj/item/card/id/dogtag/imp

/datum/job/imperial/squad/medicae
	title = IMPERIUM_SQUAD_MEDICAE
	paygrade = "SOM2"
	comm_title = "Med"
	total_positions = 16
	minimap_icon = "medic"
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/imperial/squad/medicae
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/imperial/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Warhammer 40k<br /><br /><br />
		Corpsman are the vital line between life and death of a marine’s life should a marine be wounded in battle, if provided they do not run away. While marines treat themselves, it is the corpsmen who will treat injuries beyond what a normal person can do. With a higher degree of medical skill compared to a normal marine, they are capable of doing medical actions faster and reviving with defibrillators will heal more on each attempt. They can also perform surgery, in an event if there are no acting medical officers onboard.
		<br /><br />
		<b>Duty</b>: Tend the injuries of your fellow marines or related personnel, keep them at fighting strength.
	"}

/datum/job/imperial/squad/medicae/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."})

/datum/outfit/job/imperial/squad/medicae
	name = "Guardsman Medicae"
	jobtype = /datum/job/imperial/squad/medicae

	id = /obj/item/card/id/dogtag/imp


/datum/job/imperial/squad/veteran
	title = IMPERIUM_SQUAD_VETERAN
	paygrade = "SOM3"
	comm_title = "Vet"
	total_positions = 8
	skills_type = /datum/skills/crafty //smarter than the average bear
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	minimap_icon = "smartgunner"
	outfit = /datum/outfit/job/imperium/squad/veteran
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Warhammer 40k<br /><br /><br />
		You are a seasoned veteran of the Guard. You have fought and bled for the cause, proving your self a . As fitting reward for your service, you are entrusted with best arms and equipment the Guard can offer, and you are expected to serve as an example to your fellow soldier.
		<br /><br />
		<b>Duty</b>: Show your comrades how a true Guardsman acts, and crush our enemies without mercy!.
	"}

/datum/job/imperial/squad/veteran/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the a Veteran among the Guardsman. With your shockingly long experience (and better training and equipment), your job is to provide special weapons support to bolster the line."})

/datum/outfit/job/imperium/squad/veteran
	name = "Guardsman Veteran"
	jobtype = /datum/job/imperial/squad/veteran
	id = /obj/item/card/id/dogtag/imp

/datum/job/imperial/squad/sergeant
	title = IMPERIUM_SQUAD_SERGEANT
	req_admin_notify = TRUE
	paygrade = "SOM3"
	comm_title = JOB_COMM_TITLE_SQUAD_LEADER
	total_positions = 4
	supervisors = "the acting field commander"
	minimap_icon = "leader"
	skills_type = /datum/skills/sl
	display_order = JOB_DISPLAY_ORDER_SQUAD_LEADER
	outfit = /datum/outfit/job/imperial/squad/sergeant
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/imperial/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Warhammer 40k<br /><br /><br />
		Squad Leaders are basically the boss of any able-bodied squad. Though while they are not trained compared to engineers, corpsmen and smartgunners, they are (usually) capable of leading the squad. They can issue orders to bolster their soldiers, and are expected to confidentally lead them to victory.
		<br /><br />
		<b>Duty</b>: Be a responsible leader of your squad, make sure your squad communicates frequently all the time and ensure they are working together for the task at hand. Stay safe, as you’re a valuable leader.
	"}

/datum/job/imperial/squad/sergeant/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."})

/datum/outfit/job/imperial/squad/sergeant
	name = "Guardsman Sergeant"
	jobtype = /datum/job/imperial/squad/sergeant

	id = /obj/item/card/id/dogtag/imp

/datum/job/imperial/squad/tech_priest
	title = IMPERIUM_TECH_PRIEST
	paygrade = "SOM3"
	comm_title = "Tp"
	total_positions = 8
	skills_type = /datum/skills/crafty //smarter than the average bear
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	minimap_icon = "smartgunner"
	outfit = /datum/outfit/job/imperium/squad/veteran
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Warhammer 40k<br /><br /><br />
		You are a seasoned veteran of the Guard. You have fought and bled for the cause, proving your self a . As fitting reward for your service, you are entrusted with best arms and equipment the Guard can offer, and you are expected to serve as an example to your fellow soldier.
		<br /><br />
		<b>Duty</b>: Show your comrades how a true Guardsman acts, and crush our enemies without mercy!.
	"}

/datum/job/imperial/squad/tech_priest/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the a Veteran among the Guardsman. With your shockingly long experience (and better training and equipment), your job is to provide special weapons support to bolster the line."})

/datum/outfit/job/imperium/squad/tech_priest
	name = "Mechanicus Tech Priest"
	jobtype = /datum/job/imperial/squad/tech_priest
	id = /obj/item/card/id/dogtag/imp

/datum/job/imperial/squad/skitarii
	title = IMPERIUM_SKITARII
	paygrade = "SOM3"
	comm_title = "Skit"
	total_positions = 8
	skills_type = /datum/skills/crafty //smarter than the average bear
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	minimap_icon = "smartgunner"
	outfit = /datum/outfit/job/imperium/squad/veteran
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Warhammer 40k<br /><br /><br />
		You are a seasoned veteran of the Guard. You have fought and bled for the cause, proving your self a . As fitting reward for your service, you are entrusted with best arms and equipment the Guard can offer, and you are expected to serve as an example to your fellow soldier.
		<br /><br />
		<b>Duty</b>: Show your comrades how a true Guardsman acts, and crush our enemies without mercy!.
	"}

/datum/job/imperial/squad/skitarii/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the a Veteran among the Guardsman. With your shockingly long experience (and better training and equipment), your job is to provide special weapons support to bolster the line."})

/datum/outfit/job/imperium/squad/skitarii
	name = "Mechanicus Skitarii"
	jobtype = /datum/job/imperial/squad/skitarii
	id = /obj/item/card/id/dogtag/imp

//ERT Loadouts
/datum/outfit/job/imperial/ert
	name = "Imperial Standard"
	jobtype = /datum/job/imperial

	id = /obj/item/card/id/dogtag/imp
	//belt =
	ears = /obj/item/radio/headset/distress/imperial
	w_uniform = /obj/item/clothing/under/marine/imperial
	shoes = /obj/item/clothing/shoes/marine/imperial
	//wear_suit =
	gloves = /obj/item/clothing/gloves/marine
	//head =
	//mask =
	//glasses =
	//suit_store =
	//r_store =
	//l_store =
	//back =

/datum/outfit/job/imperial/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.grant_language(/datum/language/imperial)

/datum/job/imperial/guardsman
	title = "Guardsman"
	comm_title = "Guard"
	paygrade = "Guard"
	outfit = /datum/outfit/job/imperial/guardsman

/datum/outfit/job/imperial/guardsman
	name = "Guardsman Private"
	jobtype = /datum/job/imperial/guardsman

	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial
	head = /obj/item/clothing/head/helmet/marine/imperial
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/flare/full
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/lasgun

/datum/outfit/job/imperial/guardsman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

/datum/job/imperial/guardsman/sergeant
	title = "Guardsman Sergeant"
	comm_title = "Sergeant"
	skills_type = /datum/skills/imperial/sl
	paygrade = "Sergeant"
	outfit = /datum/outfit/job/imperial/sergeant

/datum/outfit/job/imperial/sergeant // don't inherit guardsman equipment
	name = "Guardsman Sergeant"
	jobtype = /datum/job/imperial/guardsman/sergeant

	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/sergeant
	head = /obj/item/clothing/head/helmet/marine/imperial/sergeant
	mask = /obj/item/clothing/mask/rebreather
	r_store = /obj/item/storage/pouch/explosive/upp
	l_store = /obj/item/storage/pouch/field_pouch/full
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/lasgun

/datum/outfit/job/imperial/sergeant/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

/datum/job/imperial/guardsman/medicae
	title = "Guardsman Medicae"
	comm_title = "Medicae"
	skills_type = /datum/skills/imperial/medicae
	paygrade = "Medicae"
	outfit = /datum/outfit/job/imperial/medicae

/datum/outfit/job/imperial/medicae
	name = "Guardsman Medicae"
	jobtype = /datum/job/imperial/guardsman/medicae

	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/medicae
	head = /obj/item/clothing/head/helmet/marine/imperial
	glasses = /obj/item/clothing/glasses/hud/health
	l_store = /obj/item/storage/pouch/medkit/medic
	r_store = /obj/item/storage/pouch/medical_injectors/medic
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/lasgun

/datum/outfit/job/imperial/medicae/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/zoom, SLOT_IN_BELT) // closest thing to combat performance drugs

/datum/job/imperial/guardsman/veteran
	title = "Guardsman Veteran"
	comm_title = "Veteran"
	paygrade = "Guard"
	outfit = /datum/outfit/job/imperial/guardsman/veteran

/datum/outfit/job/imperial/guardsman/veteran
	name = "Guardsman Veteran"
	jobtype = /datum/job/imperial/guardsman/veteran

	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/sergeant/veteran
	head = /obj/item/clothing/head/helmet/marine/imperial/sergeant/veteran
	mask = /obj/item/clothing/mask/rebreather
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/flare/full
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/lasgun

/datum/outfit/job/imperial/guardsman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

/datum/job/imperial/commissar
	title = "Imperial Commissar"
	comm_title = "Commissar"
	skills_type = /datum/skills/imperial/sl
	paygrade = "Commissar"
	outfit = /datum/outfit/job/imperial/commissar

/datum/outfit/job/imperial/commissar
	name = "Imperial Commissar"
	jobtype = /datum/job/imperial/commissar

	belt = /obj/item/weapon/gun/pistol/boltpistol //Ideally this can be later replaced with a bolter
	w_uniform = /obj/item/clothing/under/marine/commissar
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/commissar
	gloves = /obj/item/clothing/gloves/marine/commissar
	head = /obj/item/clothing/head/commissar
	l_store = /obj/item/storage/pouch/medkit
	r_store = /obj/item/storage/pouch/magazine/pistol/large/mateba
	back = /obj/item/storage/backpack/lightpack
	glasses = /obj/item/clothing/glasses/night/imager_goggles

/datum/outfit/job/imperial/commissar/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/claymore/mercsword/commissar_sword, SLOT_S_STORE)
