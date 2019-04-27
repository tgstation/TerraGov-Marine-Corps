/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species

	var/name                                             // Species name.
	var/name_plural

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/prone_icon                                       // If set, draws this from icobase when mob is prone.
	var/eyes = "eyes_s"                                  // Icon for eyes.

	var/primitive                              // Lesser form, if any (ie. monkey for humans)
	var/tail                                   // Name of tail image in species effects icon file.
	var/datum/unarmed_attack/unarmed           // For empty hand harm-intent attack
	var/datum/unarmed_attack/secondary_unarmed // For empty hand harm-intent attack if the first fails.
	var/datum/hud_data/hud
	var/hud_type
	var/slowdown = 0
	var/taste_sensitivity = TASTE_NORMAL
	var/gluttonous        // Can eat some mobs. 1 for monkeys, 2 for people.
	var/rarity_value = 1  // Relative rarity/collector value for this species. Only used by ninja and cultists atm.
	var/unarmed_type =           /datum/unarmed_attack
	var/secondary_unarmed_type = /datum/unarmed_attack/bite

	var/language                  // Default racial language, if any.
	// Default language is used when 'say' is used without modifiers.
	var/default_language = /datum/language/common
	var/speech_verb_override
	var/secondary_langs = list()  // The names of secondary languages that are available to this species.
	var/mutantrace                // Safeguard due to old code.
	var/list/speech_sounds        // A list of sounds to potentially play when speaking.
	var/list/speech_chance
	var/has_fine_manipulation = TRUE // Can use small items.
	var/insulated                 // Immune to electrocution and glass shards to the feet.
	var/show_paygrade = FALSE
	var/count_human = FALSE // Does this count as a human?

	// Some species-specific gibbing data.
	var/gibbed_anim = "gibbed-h"
	var/dusted_anim = "dust-h"
	var/remains_type = /obj/effect/decal/remains/xeno
	var/death_sound
	var/death_message = "seizes up and falls limp, their eyes dead and lifeless..."

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/poison_type = "phoron"   // Poisonous air.
	var/exhale_type = "carbon_dioxide"      // Exhaled gas type.

	var/total_health = 100  //new maxHealth

	var/cold_level_1 = BODYTEMP_COLD_DAMAGE_LIMIT_ONE  	// Cold damage level 1 below this point.
	var/cold_level_2 = BODYTEMP_COLD_DAMAGE_LIMIT_TWO  	// Cold damage level 2 below this point.
	var/cold_level_3 = BODYTEMP_COLD_DAMAGE_LIMIT_THREE	// Cold damage level 3 below this point.

	var/heat_level_1 = BODYTEMP_HEAT_DAMAGE_LIMIT_ONE  	// Heat damage level 1 above this point.
	var/heat_level_2 = BODYTEMP_HEAT_DAMAGE_LIMIT_TWO  	// Heat damage level 2 above this point.
	var/heat_level_3 = BODYTEMP_HEAT_DAMAGE_LIMIT_THREE	// Heat damage level 2 above this point.

	var/body_temperature = BODYTEMP_NORMAL 	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/reagent_tag                 //Used for metabolizing reagents.

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = null    // Physical damage reduction/malus.
	var/burn_mod = null     // Burn damage reduction/malus.

	var/species_flags  = NOFLAGS       // Various specific features.

	var/list/abilities = list()	// For species-derived or admin-given powers
	var/list/preferences = list()
	var/list/screams = list()
	var/list/paincries = list()

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/base_color      //Used when setting species.
	var/hair_color      //If the species only has one hair color

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template

	// Species-specific abilities.
	var/list/inherent_verbs
	var/list/has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"lungs" =    /datum/internal_organ/lungs,
		"liver" =    /datum/internal_organ/liver,
		"kidneys" =  /datum/internal_organ/kidneys,
		"brain" =    /datum/internal_organ/brain,
		"appendix" = /datum/internal_organ/appendix,
		"eyes" =     /datum/internal_organ/eyes
		)

	var/knock_down_reduction = 1 //how much the knocked_down effect is reduced per Life call.
	var/stun_reduction = 1 //how much the stunned effect is reduced per Life call.
	var/knock_out_reduction = 1 //same thing

/datum/species/New()
	if(hud_type)
		hud = new hud_type()
	else
		hud = new()

	if(unarmed_type) unarmed = new unarmed_type()
	if(secondary_unarmed_type) secondary_unarmed = new secondary_unarmed_type()

/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs and limbs.

	H.limbs = list()
	H.internal_organs = list()
	H.internal_organs_by_name = list()

	//This is a basic humanoid limb setup.
	var/datum/limb/chest/C = new(null, H)
	H.limbs += C
	var/datum/limb/groin/G = new(C, H)
	H.limbs += G
	H.limbs += new/datum/limb/head(C, H)
	var/datum/limb/l_arm/LA = new(C, H)
	H.limbs += LA
	var/datum/limb/r_arm/RA = new(C, H)
	H.limbs += RA
	var/datum/limb/l_leg/LL = new(G, H)
	H.limbs += LL
	var/datum/limb/r_leg/RL = new(G, H)
	H.limbs += RL
	H.limbs +=  new/datum/limb/l_hand(LA, H)
	H.limbs +=  new/datum/limb/r_hand(RA, H)
	H.limbs +=  new/datum/limb/l_foot(LL, H)
	H.limbs +=  new/datum/limb/r_foot(RL, H)

	for(var/organ in has_organ)
		var/organ_type = has_organ[organ]
		H.internal_organs_by_name[organ] = new organ_type(H)

	if(species_flags & IS_SYNTHETIC)
		for(var/datum/limb/E in H.limbs)
			if(E.limb_status & LIMB_DESTROYED) continue
			E.limb_status |= LIMB_ROBOT
		for(var/datum/internal_organ/I in H.internal_organs)
			I.mechanize()


/datum/species/proc/hug(var/mob/living/carbon/human/H,var/mob/living/target)
	if(H.zone_selected == "head")
		H.visible_message("<span class='notice'>[H] pats [target] on the head.</span>", \
					"<span class='notice'>You pat [target] on the head.</span>", null, 4)	
	else
		H.visible_message("<span class='notice'>[H] hugs [target] to make [target.p_them()] feel better!</span>", \
					"<span class='notice'>You hug [target] to make [target.p_them()] feel better!</span>", null, 4)

/datum/species/proc/random_name(gender)
	if(gender == FEMALE)
		return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else
		return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

//special things to change after we're no longer that species
/datum/species/proc/post_species_loss(mob/living/carbon/human/H)
	return

/datum/species/proc/remove_inherent_verbs(var/mob/living/carbon/human/H)
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			H.verbs -= verb_path
	return

/datum/species/proc/add_inherent_verbs(var/mob/living/carbon/human/H)
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			H.verbs |= verb_path
	return

/datum/species/proc/handle_post_spawn(var/mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	add_inherent_verbs(H)

/datum/species/proc/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events.

//Only used by horrors at the moment. Only triggers if the mob is alive and not dead.
/datum/species/proc/handle_unique_behavior(var/mob/living/carbon/human/H)
	return

// Used to update alien icons for aliens.
/datum/species/proc/handle_login_special(var/mob/living/carbon/human/H)
	return

// As above.
/datum/species/proc/handle_logout_special(var/mob/living/carbon/human/H)
	return

// Builds the HUD using species-specific icons and usable slots.
/datum/species/proc/build_hud(var/mob/living/carbon/human/H)
	return

// Grabs the window recieved when you click-drag someone onto you.
/datum/species/proc/get_inventory_dialogue(var/mob/living/carbon/human/H)
	return

//Used by xenos understanding larvae and dionaea understanding nymphs.
/datum/species/proc/can_understand(var/mob/other)
	return

/datum/species/proc/handle_fire(mob/living/carbon/human/H)
	return

/datum/species/proc/update_body(mob/living/carbon/human/H)
	return

/datum/species/proc/update_inv_head(mob/living/carbon/human/H)
	return

/datum/species/proc/update_inv_w_uniform(mob/living/carbon/human/H)
	return

/datum/species/proc/update_inv_wear_suit(mob/living/carbon/human/H)
	return

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(species_flags & NO_CHEM_METABOLIZATION) //explicit
		H.reagents.del_reagent(chem.id) //for the time being
		return TRUE
	if(species_flags & NO_OVERDOSE) //no stacking
		for(var/datum/reagent/R in H.reagents)
			if(R.volume > R.overdose_threshold)
				H.reagents.remove_reagent(R, R.volume - R.overdose_threshold)
				return FALSE
	return FALSE

/datum/species/human
	name = "Human"
	name_plural = "Humans"
	language = /datum/language/common
	primitive = /mob/living/carbon/monkey
	unarmed_type = /datum/unarmed_attack/punch
	species_flags = HAS_SKIN_TONE|HAS_LIPS|HAS_UNDERWEAR
	show_paygrade = TRUE
	count_human = TRUE

	screams = list("male" = "male_scream", "female" = "female_scream")
	paincries = list("male" = "male_pain", "female" = "female_pain")

	//If you wanted to add a species-level ability:
	/*abilities = list(/client/proc/test_ability)*/

//Slightly tougher humans.
/datum/species/human/hero
	name = "Human Hero"
	name_plural = "Human Heroes"
	brute_mod = 0.55
	burn_mod = 0.55
	unarmed_type = /datum/unarmed_attack/punch/strong

	cold_level_1 = 220
	cold_level_2 = 180
	cold_level_3 = 80
	heat_level_1 = 390
	heat_level_2 = 480
	heat_level_3 = 1100


//Various horrors that spawn in and haunt the living.
/datum/species/human/spook
	name = "Horror"
	name_plural = "Horrors"
	icobase = 'icons/mob/human_races/r_spooker.dmi'
	deform = 'icons/mob/human_races/r_spooker.dmi'
	brute_mod = 0.15
	burn_mod = 1.50
	reagent_tag = IS_HORROR
	species_flags = HAS_SKIN_COLOR|NO_BREATHE|NO_POISON|HAS_LIPS|NO_PAIN|NO_SCAN|NO_POISON|NO_BLOOD|NO_SLIP|NO_CHEM_METABOLIZATION
	unarmed_type = /datum/unarmed_attack/punch/strong
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	death_message = "doubles over, unleashes a horrible, ear-shattering scream, then falls motionless and still..."
	death_sound = 'sound/voice/scream_horror1.ogg'

	darksight = 8
	slowdown = 0.3
	insulated = 1
	has_fine_manipulation = FALSE

	heat_level_1 = 1000
	heat_level_2 = 1500
	heat_level_3 = 2000

	cold_level_1 = 100
	cold_level_2 = 50
	cold_level_3 = 20

	//To show them we mean business.
	handle_unique_behavior(var/mob/living/carbon/human/H)
		if(prob(25)) animation_horror_flick(H)

		//Organ damage will likely still take them down eventually.
		H.adjustBruteLoss(-3)
		H.adjustFireLoss(-3)
		H.adjustOxyLoss(-15)
		H.adjustToxLoss(-15)

/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = /datum/language/unathi
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	primitive = /mob/living/carbon/monkey/unathi
	darksight = 3
	taste_sensitivity = TASTE_SENSITIVE
	gluttonous = 1

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#34AF10"

	reagent_tag = IS_UNATHI
	base_color = "#066000"

/datum/species/tajaran
	name = "Tajara"
	name_plural = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = /datum/language/tajaran
	tail = "tajtail"
	unarmed_type = /datum/unarmed_attack/claws
	darksight = 8

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80 //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	primitive = /mob/living/carbon/monkey/tajara

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = /datum/language/skrell
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch

	species_flags = HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR

	flesh_color = "#8CD7A3"

	reagent_tag = IS_SKRELL

/datum/species/moth
	name = "Moth"
	name_plural = "Moth"
	icobase = 'icons/mob/human_races/r_moth.dmi'
	deform = 'icons/mob/human_races/r_moth.dmi'
	eyes = "blank_eyes"
	speech_verb_override = "flutters"
	show_paygrade = TRUE
	count_human = TRUE

	species_flags = HAS_LIPS|HAS_NO_HAIR
	preferences = list("moth_wings" = "Wings")

	screams = list("neuter" = 'sound/voice/moth_scream.ogg')
	paincries = list("neuter" = 'sound/voice/human_male_pain_3.ogg')

	flesh_color = "#E5CD99"

	reagent_tag = IS_MOTH

/datum/species/moth/handle_fire(mob/living/carbon/human/H)
	if(H.moth_wings != "Burnt Off" && H.bodytemperature >= 400 && H.fire_stacks > 0)
		to_chat(H, "<span class='danger'>Your precious wings burn to a crisp!</span>")
		H.moth_wings = "Burnt Off"
		H.update_body()

/datum/species/moth/random_name()
	return "[pick(moth_first)] [pick(moth_last)]"

/datum/species/moth/proc/update_moth_wings(mob/living/carbon/human/H)
	H.remove_overlay(MOTH_WINGS_LAYER)
	H.remove_underlay(MOTH_WINGS_BEHIND_LAYER)

	var/datum/sprite_accessory/moth_wings/wings = GLOB.moth_wings_list[H.moth_wings]

	if(wings)
		H.overlays_standing[MOTH_WINGS_LAYER] = image(wings.icon, icon_state = "m_moth_wings_[wings.icon_state]_FRONT")
		H.underlays_standing[MOTH_WINGS_BEHIND_LAYER] = image(wings.icon, icon_state = "m_moth_wings_[wings.icon_state]_BEHIND")
		H.apply_overlay(MOTH_WINGS_LAYER)
		H.apply_underlay(MOTH_WINGS_BEHIND_LAYER)

/datum/species/moth/update_body(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/update_inv_head(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/update_inv_w_uniform(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/update_inv_wear_suit(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/post_species_loss(mob/living/carbon/human/H)
	H.remove_overlay(MOTH_WINGS_LAYER)
	H.remove_underlay(MOTH_WINGS_BEHIND_LAYER)

/datum/species/vox
	name = "Vox"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = /datum/language/vox
	taste_sensitivity = TASTE_DULL
	unarmed_type = /datum/unarmed_attack/claws/strong
	secondary_unarmed_type = /datum/unarmed_attack/bite/strong
	rarity_value = 2

	speech_sounds = list('sound/voice/shriek1.ogg')
	speech_chance = 20

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"

	breath_type = "oxygen"//"nitrogen"
	poison_type = "phoron"//"oxygen"
	insulated = 1

	species_flags = NO_SCAN

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = IS_VOX

	inherent_verbs = list(
		/mob/living/carbon/human/proc/leap
		)

	has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"lungs" =    /datum/internal_organ/lungs,
		"liver" =    /datum/internal_organ/liver,
		"kidneys" =  /datum/internal_organ/kidneys,
		"brain" =    /datum/internal_organ/brain,
		"eyes" =     /datum/internal_organ/eyes,
		"stack" =    /datum/internal_organ/stack/vox
		)

/datum/species/vox/armalis
	name = "Vox Armalis"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	rarity_value = 10

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	eyes = "blank_eyes"
	breath_type = "nitrogen"
	poison_type = "oxygen"

	species_flags = NO_SCAN|NO_BLOOD|NO_PAIN

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	reagent_tag = IS_VOX

	inherent_verbs = list(
		/mob/living/carbon/human/proc/leap,
		/mob/living/carbon/human/proc/gut,
		/mob/living/carbon/human/proc/commune
		)

/datum/species/machine
	name = "Machine"
	name_plural = "machines"

	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	language = /datum/language/trader
	unarmed_type = /datum/unarmed_attack/punch
	rarity_value = 2

	eyes = "blank_eyes"
	brute_mod = 0.25
	burn_mod = 1.1

	warning_low_pressure = 0
	hazard_low_pressure = 0

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION

	blood_color = "#EEEEEE"
	flesh_color = "#272757"

	has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"brain" =    /datum/internal_organ/brain,
		)

/datum/species/synthetic
	name = "Synthetic"
	name_plural = "synthetics"

	unarmed_type = /datum/unarmed_attack/punch
	rarity_value = 2

	total_health = 150 //more health than regular humans

	brute_mod = 0.75
	burn_mod = 1.1

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION

	blood_color = "#EEEEEE"

	has_organ = list(
		"heart" =    /datum/internal_organ/heart/prosthetic,
		"brain" =    /datum/internal_organ/brain/prosthetic,
		)


/datum/species/early_synthetic
	name = "Early Synthetic"
	name_plural = "Early Synthetics"
	icobase = 'icons/mob/human_races/r_synthetic.dmi'
	deform = 'icons/mob/human_races/r_synthetic.dmi'
	unarmed_type = /datum/unarmed_attack/punch
	rarity_value = 1.5
	slowdown = 1.3 //Slower than later synths
	total_health = 200 //But more durable
	insulated = 1
	brute_mod = 0.75
	burn_mod = 1.1

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION

	blood_color = "#EEEEEE"
	hair_color = "#000000"
	has_organ = list(
		"heart" =    /datum/internal_organ/heart/prosthetic,
		"brain" =    /datum/internal_organ/brain/prosthetic,
		)


/mob/living/carbon/human/proc/reset_jitteriness()
	jitteriness = 0


/datum/species/synthetic/handle_post_spawn(mob/living/carbon/human/H)
	H.universal_understand = 1
	return ..()


// Called when using the shredding behavior.
/datum/species/proc/can_shred(var/mob/living/carbon/human/H)

	if(H.a_intent != INTENT_HARM)
		return 0

	if(unarmed.is_usable(H))
		if(unarmed.shredding)
			return 1
	else if(secondary_unarmed.is_usable(H))
		if(secondary_unarmed.shredding)
			return 1

	return 0

//Species unarmed attacks
/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/shredding = 0 // Calls the old attack_alien() behavior on objects/mobs when on harm intent.
	var/sharp = 0
	var/edge = 0

/datum/unarmed_attack/proc/is_usable(var/mob/living/carbon/human/user)
	if(user.restrained())
		return 0

	// Check if they have a functioning hand.
	var/datum/limb/E = user.get_limb("l_hand")
	if(E && !(E.limb_status & LIMB_DESTROYED))
		return 1

	E = user.get_limb("r_hand")
	if(E && !(E.limb_status & LIMB_DESTROYED))
		return 1

	return 0

/datum/unarmed_attack/bite
	attack_verb = list("bite") // 'x has biteed y', needs work.
	attack_sound = 'sound/weapons/bite.ogg'
	shredding = 0
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/bite/is_usable(var/mob/living/carbon/human/user)
	if (user.wear_mask && istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		return 0
	return 1

/datum/unarmed_attack/punch
	attack_verb = list("punch")
	damage = 3

/datum/unarmed_attack/punch/strong
	attack_verb = list("punch","bust","jab")
	damage = 10

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/claws/strong
	attack_verb = list("slash")
	damage = 10
	shredding = 1

/datum/unarmed_attack/bite/strong
	attack_verb = list("maul")
	damage = 15
	shredding = 1

/datum/hud_data
	var/icon              // If set, overrides ui_style.
	var/has_a_intent = 1  // Set to draw intent box.
	var/has_m_intent = 1  // Set to draw move intent box.
	var/has_warnings = 1  // Set to draw environment warnings.
	var/has_pressure = 1  // Draw the pressure indicator.
	var/has_nutrition = 1 // Draw the nutrition indicator.
	var/has_bodytemp = 1  // Draw the bodytemp indicator.
	var/has_hands = 1     // Set to draw shand.
	var/has_drop = 1      // Set to draw drop button.
	var/has_throw = 1     // Set to draw throw button.
	var/has_resist = 1    // Set to draw resist button.
	var/has_internals = 1 // Set to draw the internals toggle button.
	var/list/equip_slots = list() // Checked by mob_can_equip().

	// Contains information on the position and tag for all inventory slots
	// to be drawn for the mob. This is fairly delicate, try to avoid messing with it
	// unless you know exactly what it does.
	var/list/gear = list(
		"i_clothing" =   list("loc" = ui_iclothing, "slot" = SLOT_W_UNIFORM, "state" = "center", "toggle" = 1, "dir" = SOUTH),
		"o_clothing" =   list("loc" = ui_oclothing, "slot" = SLOT_WEAR_SUIT, "state" = "equip",  "toggle" = 1,  "dir" = SOUTH),
		"mask" =         list("loc" = ui_mask,      "slot" = SLOT_WEAR_MASK, "state" = "equip",  "toggle" = 1,  "dir" = NORTH),
		"gloves" =       list("loc" = ui_gloves,    "slot" = SLOT_GLOVES,    "state" = "gloves", "toggle" = 1),
		"eyes" =         list("loc" = ui_glasses,   "slot" = SLOT_GLASSES,   "state" = "glasses","toggle" = 1),
		"wear_ear" =     list("loc" = ui_wear_ear,  "slot" = SLOT_EARS,     "state" = "ears",   "toggle" = 1),
		"head" =         list("loc" = ui_head,      "slot" = SLOT_HEAD,      "state" = "hair",   "toggle" = 1),
		"shoes" =        list("loc" = ui_shoes,     "slot" = SLOT_SHOES,     "state" = "shoes",  "toggle" = 1),
		"suit storage" = list("loc" = ui_sstore1,   "slot" = SLOT_S_STORE,   "state" = "belt",   "dir" = 8),
		"back" =         list("loc" = ui_back,      "slot" = SLOT_BACK,      "state" = "back",   "dir" = NORTH),
		"id" =           list("loc" = ui_id,        "slot" = SLOT_WEAR_ID,   "state" = "id",     "dir" = NORTH),
		"storage1" =     list("loc" = ui_storage1,  "slot" = SLOT_L_STORE,   "state" = "pocket"),
		"storage2" =     list("loc" = ui_storage2,  "slot" = SLOT_R_STORE,   "state" = "pocket"),
		"belt" =         list("loc" = ui_belt,      "slot" = SLOT_BELT,      "state" = "belt")
		)

/datum/hud_data/New()
	. = ..()
	for(var/slot in gear)
		equip_slots |= gear[slot]["slot"]

	if(has_hands)
		equip_slots |= SLOT_L_HAND
		equip_slots |= SLOT_R_HAND
		equip_slots |= SLOT_HANDCUFFED
	if(SLOT_HEAD in equip_slots)
		equip_slots |= SLOT_IN_HEAD
	if(SLOT_BACK in equip_slots)
		equip_slots |= SLOT_IN_BACKPACK
		equip_slots |= SLOT_IN_B_HOLSTER
	if(SLOT_BELT in equip_slots)
		equip_slots |= SLOT_IN_HOLSTER
		equip_slots |= SLOT_IN_BELT
	if(SLOT_WEAR_SUIT in equip_slots)
		equip_slots |= SLOT_IN_S_HOLSTER
		equip_slots |= SLOT_IN_SUIT
	if(SLOT_SHOES in equip_slots)
		equip_slots |= SLOT_LEGCUFFED
		equip_slots |= SLOT_IN_BOOT
	if(SLOT_W_UNIFORM in equip_slots)
		equip_slots |= SLOT_IN_STORAGE
		equip_slots |= SLOT_IN_L_POUCH
		equip_slots |= SLOT_IN_R_POUCH
		equip_slots |= SLOT_ACCESSORY
		equip_slots |= SLOT_IN_ACCESSORY
