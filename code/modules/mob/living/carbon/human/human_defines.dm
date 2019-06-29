/mob/living/carbon/human
	//Hair colour and style
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0
	var/h_style = "Crewcut"

	//Facial hair colour and style
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0
	var/f_style = "Shaved"

	//Eye colour
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	var/ethnicity = "Western"	// Ethnicity
	var/body_type = "Mesomorphic (Average)" // Body Type

	//Skin colour
	var/r_skin = 0
	var/g_skin = 0
	var/b_skin = 0

	//Species specific
	var/moth_wings = "Plain"

	var/lip_style		//no lipstick by default- arguably misleading, as it could be used for general makeup

	var/age = 30		//Player's age (pure fluff)
	var/b_type = "A+"	//Player's bloodtype

	var/underwear = 1	//Which underwear the player wants
	var/undershirt = 0	//Which undershirt the player wants.
	var/backpack = 2		//Which backpack type the player has chosen. Nothing, Satchel or Backpack.

	// General information
	var/home_system = ""
	var/citizenship = ""
	var/personal_faction = ""
	var/religion = ""

	//Equipment slots
	var/obj/item/wear_suit = null
	var/obj/item/clothing/under/w_uniform = null
	var/obj/item/clothing/shoes/shoes = null
	var/obj/item/belt = null
	var/obj/item/clothing/gloves/gloves = null
	var/obj/item/clothing/glasses/glasses = null
	var/obj/item/head = null
	var/obj/item/wear_ear = null
	var/obj/item/card/id/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/icon/stand_icon = null

	var/speech_problem_flag = 0

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/last_dam = -1	//Used for determining if we need to process all limbs or just some or even none.
	//var/list/bad_limbs = list()// limbs we check until they are good.

	var/mob/remoteview_target

	var/list/flavor_texts = list()
	var/last_unbuckled = 0 //Unbuckled cooldown.

	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/exploit_record = ""


	//Life variables

	var/undefibbable = FALSE //whether the human is dead and past the defibbrillation period.

	var/holo_card_color = "" //which color type of holocard is printed on us

	var/list/limbs = list()
	var/list/internal_organs_by_name = list() // so internal organs have less ickiness too

	var/command_aura = null //The command aura we are using as a string. Need to be trained or higher in Leadership
	var/command_aura_strength = 0 //The strength of our command aura. This depends on our Leadership skill
	var/command_aura_allowed = list("move", "hold", "focus") //Auras we can create. Leadership checked separately
	var/command_aura_tick = 0 //How many ticks left before we cut out your command aura
	var/command_aura_cooldown = 0 //Cooldown on our command aura

	var/mobility_aura = 0
	var/protection_aura = 0
	var/marksman_aura = 0

	var/mobility_new = 0
	var/protection_new = 0
	var/marksman_new = 0
	var/aura_recovery_multiplier = 0

	var/temporary_slowdown = 0 //Stacking slowdown caused from effects, currently used by neurotoxin gas

	var/datum/squad/assigned_squad //the squad assigned to

	var/cloaking = FALSE

	var/image/SL_directional = null

	var/last_chew = 0
	var/damageoverlaytemp = 0

	var/specset //Simple way to track which set has the player taken

	hud_type = /datum/hud/human