/datum/job/terragov/squad
	job_category = JOB_CAT_MARINE
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	exp_type_department = EXP_TYPE_MARINES


/datum/job/terragov/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
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


//Squad Marine
/datum/job/terragov/squad/standard
	title = SQUAD_MARINE
	paygrade = "E1"
	comm_title = "Mar"
	access = list(ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Easy<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		TerraGov’s Squad Marines make up the bread and butter of Terra's fighting forces. They are fitted with the standard arsenal that the TGMC offers, and they can take up a variety of roles, being a sniper, a pyrotechnician, a machinegunner, rifleman and more. They’re often high in numbers and divided into squads, but they’re the lowest ranking individuals, with a low degree of skill, not adapt to engineering or medical roles. Still, they are not limited to the arsenal they can take on the field to deal whatever threat that lurks against Terra.
		<br /><br />
		<b>Duty</b>: Carry out orders made by your acting Squad Leader, deal with any threats that oppose the TGMC.
	"}
	minimap_icon = "private"

/datum/job/terragov/squad/standard/rebel
	title = REBEL_SQUAD_MARINE
	faction = FACTION_TERRAGOV_REBEL
	access = list(ACCESS_MARINE_PREP_REBEL)
	outfit = /datum/outfit/job/marine/standard/rebel
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner/rebel = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic/rebel = SYNTH_POINTS_REGULAR,
	)

/datum/job/terragov/squad/standard/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "E1"
		if(601 to 6000) // 10hrs
			new_human.wear_id.paygrade = "E2"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "E3"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "E3E"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "E8" //If you play way too much TGMC. 1000 hours.

/datum/job/terragov/squad/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file soldier of the TGMC, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the corps. Ooh-rah!"})


/datum/outfit/job/marine/standard
	name = SQUAD_MARINE
	jobtype = /datum/job/terragov/squad/standard

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/standard/rebel
	jobtype = /datum/job/terragov/squad/standard/rebel

/datum/outfit/job/marine/standard/equipped
	name = "Squad Marine (Equipped)"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/harness
	shoes = /obj/item/clothing/shoes/marine/full
	gloves =/obj/item/clothing/gloves/marine
	l_store = /obj/item/storage/pouch/medkit/firstaid
	r_hand = /obj/item/portable_vendor/marine/squadmarine

/datum/outfit/job/marine/standard/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

//Squad Engineer
/datum/job/terragov/squad/engineer
	title = SQUAD_ENGINEER
	paygrade = "E3"
	comm_title = "Eng"
	total_positions = 12
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_ENGINEERING)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_ENGINEERING)
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_SUQAD_ENGINEER
	outfit = /datum/outfit/job/marine/engineer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM, /datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		A mastermind of on-field construction, often regarded as the answer on whether the FOB succeeds or not, Squad Engineers are the people who construct the Forward Operating Base (FOB) and guard whatever threat that endangers the marines. In addition to this, they are also in charge of repairing power generators on the field as well as mining drills for requisitions. They have a high degree of engineering skill, meaning they can deploy and repair barricades faster than regular marines.
		<br /><br />
		<b>Duty</b>: Construct and reinforce the FOB that has been ordered by your acting Squad Leader, fix power generators and mining drills in the AO and stay on guard for any dangers that threaten your FOB.
	"}
	minimap_icon = "engi"

/datum/job/terragov/squad/engineer/rebel
	title = REBEL_SQUAD_ENGINEER
	faction = FACTION_TERRAGOV_REBEL
	outfit = /datum/outfit/job/marine/engineer/rebel
	access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_ENGPREP_REBEL, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD_REBEL, ACCESS_MARINE_ENGINEERING_REBEL)
	minimal_access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_ENGPREP_REBEL, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_DROPSHIP_REBEL, ACCESS_MARINE_REMOTEBUILD_REBEL, ACCESS_MARINE_ENGINEERING_REBEL)
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner/rebel = SMARTIE_POINTS_MEDIUM, /datum/job/terragov/silicon/synthetic/rebel = SYNTH_POINTS_REGULAR)

/datum/job/terragov/squad/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."})


/datum/outfit/job/marine/engineer
	name = SQUAD_ENGINEER
	jobtype = /datum/job/terragov/squad/engineer

	id = /obj/item/card/id/dogtag/engineer
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/engineer/rebel
	jobtype = /datum/job/terragov/squad/engineer/rebel

/datum/outfit/job/marine/engineer/equipped
	name = "Squad Engineer (Equipped)"

	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/engineer
	wear_suit = /obj/item/clothing/suit/storage/marine
	shoes = /obj/item/clothing/shoes/marine/full
	gloves =/obj/item/clothing/gloves/marine/insulated
	l_store = /obj/item/storage/pouch/medkit/firstaid
	r_store = /obj/item/storage/pouch/construction/equippedengineer
	r_hand = /obj/item/portable_vendor/marine/squadmarine/engineer
	l_hand = /obj/item/encryptionkey/engi
	back = /obj/item/storage/backpack/marine/engineerpack

/datum/outfit/job/marine/engineer/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/lightreplacer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

/datum/job/terragov/squad/engineer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E4"
		if(6001 to INFINITY) // 100 hrs
			new_human.wear_id.paygrade = "E5"

//Squad Corpsman
/datum/job/terragov/squad/corpsman
	title = SQUAD_CORPSMAN
	paygrade = "E3"
	comm_title = "Med"
	total_positions = 16
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/marine/corpsman
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR, /datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		Corpsman are the vital line between life and death of a marine’s life should a marine be wounded in battle, if provided they do not run away. While marines treat themselves, it is the corpsmen who will treat injuries beyond what a normal person can do. With a higher degree of medical skill compared to a normal marine, they are capable of doing medical actions faster and reviving with defibrillators will heal more on each attempt. They can also perform surgery, in an event if there are no acting medical officers onboard.
		<br /><br />
		<b>Duty</b>: Tend the injuries of your fellow marines or related personnel, keep them at fighting strength. Evacuate those who are incapacitated or rendered incapable of fighting due to severe wounds or larvae infections.
	"}
	minimap_icon = "medic"

/datum/job/terragov/squad/corpsman/rebel
	title = REBEL_SQUAD_CORPSMAN
	faction = FACTION_TERRAGOV_REBEL
	outfit = /datum/outfit/job/marine/corpsman/rebel
	access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_MEDPREP_REBEL, ACCESS_MARINE_MEDBAY_REBEL)
	minimal_access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_MEDPREP_REBEL, ACCESS_MARINE_MEDBAY_REBEL, ACCESS_MARINE_DROPSHIP_REBEL)
	jobworth = list(/datum/job/terragov/silicon/synthetic/rebel = SYNTH_POINTS_REGULAR, /datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner/rebel = SMARTIE_POINTS_MEDIUM)

/datum/job/terragov/squad/corpsman/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."})

/datum/outfit/job/marine/corpsman
	name = SQUAD_CORPSMAN
	jobtype = /datum/job/terragov/squad/corpsman

	id = /obj/item/card/id/dogtag/corpsman
	back = /obj/item/storage/backpack/marine/corpsman

/datum/outfit/job/marine/corpsman/rebel
	jobtype = /datum/job/terragov/squad/corpsman/rebel
/datum/outfit/job/marine/corpsman/equipped
	name = "Squad Corpsman (Equipped)"

	belt = /obj/item/storage/belt/lifesaver/full
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/corpsman
	wear_suit = /obj/item/clothing/suit/storage/marine
	shoes = /obj/item/clothing/shoes/marine/full
	gloves =/obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/modular/marine/m10x
	l_store = /obj/item/storage/pouch/medkit/medic
	r_store = /obj/item/storage/pouch/medical_injectors/medic
	glasses = /obj/item/clothing/glasses/hud/health
	r_hand = /obj/item/portable_vendor/marine/squadmarine/corpsman
	l_hand = /obj/item/encryptionkey/med

/datum/outfit/job/marine/corpsman/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/bicaridine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/kelotane , SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/medevac_beacon, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller/medevac, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_BACKPACK)

/datum/job/terragov/squad/corpsman/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E4"
		if(6001 to INFINITY) // 100 hrs
			new_human.wear_id.paygrade = "E5"

//Squad Smartgunner
/datum/job/terragov/squad/smartgunner
	title = SQUAD_SMARTGUNNER
	paygrade = "E3"
	comm_title = "SGnr"
	total_positions = 4
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/smartgunner
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	outfit = /datum/outfit/job/marine/smartgunner
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	job_points_needed  = 10 //Redefined via config.
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		When it comes to heavy firepower during the early stages of an operation, TGMC has provided the squad with Smartgunners. They are those who trained to operate the SG-29 Smart Machine Gun, an IFF heavy weapon that provides cover fire even directly behind the marines. Squad Smartgunners are best when fighting behind marines, as they can act as shields or during a hectic crossfire.
		<br /><br />
		<b>Duty</b>: Be the backline of your pointmen, provide heavy weapons support with your smart machine gun.
	"}
	minimap_icon = "smartgunner"

/datum/job/terragov/squad/smartgunner/rebel
	title = REBEL_SQUAD_SMARTGUNNER
	faction = FACTION_TERRAGOV_REBEL
	outfit = /datum/outfit/job/marine/smartgunner/rebel
	access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_SMARTPREP_REBEL)
	minimal_access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_SMARTPREP_REBEL, ACCESS_MARINE_DROPSHIP_REBEL)

/datum/job/terragov/squad/smartgunner/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the smartgunner. Your job is to provide heavy weapons support."})

/datum/job/terragov/squad/smartgunner/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E4"
		if(6001 to INFINITY) // 100 hrs
			new_human.wear_id.paygrade = "E5"

/datum/outfit/job/marine/smartgunner
	name = SQUAD_SMARTGUNNER
	jobtype = /datum/job/terragov/squad/smartgunner

	id = /obj/item/card/id/dogtag/smartgun
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/smartgunner/rebel
	jobtype = /datum/job/terragov/squad/smartgunner/rebel

/datum/outfit/job/marine/smartgunner/equipped
	name = "Squad Smartgunner (Equipped)"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/smartgunner
	shoes = /obj/item/clothing/shoes/marine/full
	gloves =/obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/modular/marine/m10x
	l_store = /obj/item/storage/pouch/medkit/firstaid
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	r_hand = /obj/item/portable_vendor/marine/squadmarine/smartgunner

/datum/outfit/job/marine/smartgunner/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar , SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)


//Squad Specialist
/datum/job/terragov/squad/specialist
	title = SQUAD_SPECIALIST
	req_admin_notify = TRUE
	paygrade = "E4" // Dead
	comm_title = "Spec"
	total_positions = 0
	max_positions = 0
	access = list(ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/specialist
	outfit = /datum/outfit/job/marine/specialist
	exp_requirements = XP_REQ_UNSEASONED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_STRONG)
	job_points_needed  = 10 //Redefined via config.


/datum/job/terragov/squad/specialist/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the very rare and valuable weapon expert, trained to use special equipment.
You can serve a variety of roles, so choose carefully."})


/datum/outfit/job/marine/specialist
	name = SQUAD_SPECIALIST
	jobtype = /datum/job/terragov/squad/specialist

	id = /obj/item/card/id/dogtag
	back = /obj/item/storage/backpack/marine/satchel
	head = /obj/item/clothing/head/helmet/specrag

//Squad Leader
/datum/job/terragov/squad/leader
	title = SQUAD_LEADER
	req_admin_notify = TRUE
	paygrade = "E5"
	comm_title = JOB_COMM_TITLE_SQUAD_LEADER
	total_positions = 4
	supervisors = "the acting field commander"
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/sl
	display_order = JOB_DISPLAY_ORDER_SQUAD_LEADER
	outfit = /datum/outfit/job/marine/leader
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_HIGH,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		Squad Leaders are basically the boss of any able-bodied squad. Though while they are not trained compared to engineers, corpsmen and smartgunners, they are (usually) capable of leading the squad. They have access to command assets such as a ship railgun, orbital bombardment as examples.
		<br /><br />
		<b>Duty</b>: Be a responsible leader of your squad, make sure your squad communicates frequently all the time and ensure they are working together for the task at hand. Stay safe, as you’re a valuable leader.
	"}
	minimap_icon = "leader"

/datum/job/terragov/squad/leader/rebel
	title = REBEL_SQUAD_LEADER
	faction = FACTION_TERRAGOV_REBEL
	outfit = /datum/outfit/job/marine/leader/rebel
	access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_LEADER_REBEL, ACCESS_MARINE_DROPSHIP_REBEL)
	minimal_access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_LEADER_REBEL, ACCESS_MARINE_DROPSHIP_REBEL)
	jobworth = list(
		/datum/job/terragov/squad/smartgunner/rebel = SMARTIE_POINTS_HIGH,
		/datum/job/terragov/silicon/synthetic/rebel = SYNTH_POINTS_REGULAR,
	)

/datum/job/terragov/squad/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."})


/datum/outfit/job/marine/leader
	name = SQUAD_LEADER
	jobtype = /datum/job/terragov/squad/leader

	id = /obj/item/card/id/dogtag/leader
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/marine/leader/rebel
	jobtype = /datum/job/terragov/squad/leader/rebel

/datum/outfit/job/marine/leader/equipped
	name = "Squad Leader (Equipped)"

	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/leader
	shoes = /obj/item/clothing/shoes/marine/full
	gloves =/obj/item/clothing/gloves/marine
	head = /obj/item/clothing/head/modular/marine/m10x/leader
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	l_store = /obj/item/storage/pouch/medkit/firstaid
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	r_hand = /obj/item/storage/box/squadmarine/squadleader
	l_hand = /obj/item/encryptionkey/squadlead
	belt = /obj/item/storage/belt/marine/t12

/datum/outfit/job/marine/leader/equipped/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/beacon/supply_beacon, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/beacon/supply_beacon, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/whistle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)


/datum/job/terragov/squad/leader/after_spawn(mob/living/carbon/C, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/new_human = C
	var/playtime_mins = user?.client?.get_exp(title)
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E5"
		if(1501 to 7500) // 25 hrs
			new_human.wear_id.paygrade = "E6"
		if(7501 to INFINITY) // 125 hrs
			new_human.wear_id.paygrade = "E7"
	if(!latejoin)
		return
	if(!new_human.assigned_squad)
		return
	if(new_human.assigned_squad.squad_leader != new_human)
		if(new_human.assigned_squad.squad_leader)
			new_human.assigned_squad.demote_leader()
		new_human.assigned_squad.promote_leader(new_human)



/datum/job/terragov/squad/vatgrown
	title = SQUAD_MARINE
	paygrade = "VM"
	comm_title = "Mar"
	access = list(ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/vatgrown
	total_positions = 0
	job_flags = JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR)
	minimap_icon = "private"

/datum/job/terragov/squad/vatgrown/rebel
	faction = FACTION_TERRAGOV_REBEL
	outfit = /datum/outfit/job/marine/vatgrown/rebel
	access = list(ACCESS_MARINE_PREP_REBEL)
	minimal_access = list(ACCESS_MARINE_PREP_REBEL, ACCESS_MARINE_DROPSHIP_REBEL)
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/silicon/synthetic/rebel = SYNTH_POINTS_REGULAR)

/datum/job/terragov/squad/vatgrown/return_spawn_type(datum/preferences/prefs)
	return /mob/living/carbon/human/species/vatgrown

/datum/outfit/job/marine/vatgrown
	name = SQUAD_VATGROWN
	jobtype = /datum/job/terragov/squad/vatgrown
	id = /obj/item/card/id/dogtag

/datum/outfit/job/marine/vatgrown/rebel
	jobtype = /datum/job/terragov/squad/vatgrown/rebel
