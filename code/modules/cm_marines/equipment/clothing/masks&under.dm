//========================//MASKS AND UNDER\\============================\\
//=======================================================================\\

/*This should contain all the various under clothing people can wear, along
with all of the masks and or other facial coverings. For the latter category
it doesn't matter if they provide hugger protection or not. This can also
include jackets and regular suits, not armor.*/

//=======================================================================\\
//=======================================================================\\


//===========================//MASKS\\===================================\\
//=======================================================================\\

/obj/item/clothing/mask/rebreather
	desc = "A close-fitting device that instantly heats or cools down air when you inhale so it doesn't damage your lungs."
	name = "rebreather"
	icon_state = "rebreather"
	item_state = "rebreather"
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH
	body_parts_covered = 0
	w_class = 2

/obj/item/clothing/mask/rebreather/scarf
	desc = "A close-fitting cap that covers the top, back, and sides of the head. Can also be adjusted to cover the lower part of the face so it keeps the user warm in harsh conditions."
	name = "Heat Absorbent Coif"
	icon_state = "coif"
	item_state = "coif"

/obj/item/clothing/mask/gas/PMCmask
	name = "M8 Pattern Armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "helmet"
	icon_state = "pmc_mask"
	anti_hug = 3
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 10, bio = 1, rad = 1)

/obj/item/clothing/mask/gas/PMCmask/leader
	name = "M8 Pattern Armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter. This particular suit looks like it belongs to a high-ranking officer."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "officer_mask"
	icon_state = "officer_mask"

/obj/item/clothing/mask/gas/Bear
	name = "Tactical Balaclava"
	desc = "A superior balaclava worn by the Iron Bears."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "bear_mask"
	icon_state = "bear_mask"
	icon_override = 'icons/PMC/PMC.dmi'
	anti_hug = 2

//=========================//MARINES\\===================================\\
//=======================================================================\\

/obj/item/clothing/under/marine_underoos
	name = "marine underpants"
	desc = "A simple outfit worn by USCM operators during cyrosleep. Makes you drowsy and slower while wearing. Wear this into battle if you have no self-respect."
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 10, rad = 0)
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9
	icon_state = "marine_underpants"
	item_state = "marine_underpants"
	item_color = "marine_underpants"
	has_sensor = 1
	slowdown = 3

/obj/item/clothing/under/marine_jumpsuit
	name = "USCM Uniform"
	desc = "The issue uniform for the USCM forces. It is weaved with light kevlar plates that protect against light impacts and light-caliber rounds."
	armor = list(melee = 5, bullet = 10, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9
	icon_state = "marine_jumpsuit"
	item_state = "marine_jumpsuit"
	item_color = "marine_jumpsuit"
	has_sensor = 3
	sensor_mode = 3

/obj/item/clothing/under/marine_jumpsuit/snow
	name = "USCM Snow Uniform"
	icon_state = "marine_jumpsuit_snow"
	item_state = "marine_jumpsuit_snow"
	item_color = "marine_jumpsuit_snow"

/obj/item/clothing/under/marine/fluff/marineengineer/snow
	name = "Marine Engineer Snow Uniform"
	icon_state = "marine_engineer_snow"
	item_state = "marine_engineer_snow"
	item_color = "marine_engineer_snow"

/obj/item/clothing/under/marine/fluff/marinemedic/snow
	name = "Marine Medic Snow Uniform"
	icon_state = "marine_medic_snow"
	item_state = "marine_medic_snow"
	item_color = "marine_medic_snow"

//========================//OFFICERS\\===================================\\
//=======================================================================\\

/obj/item/clothing/under/rank/chef/exec
	name = "Weyland Yutani suit"
	desc = "A formal white undersuit."

/obj/item/clothing/under/rank/ro_suit
	name = "Requisition officer suit."
	desc = "A nicely-fitting military suit for a requisition officer."
	icon_state = "RO_jumpsuit"
	item_state = "RO_jumpsuit"
	item_color = "RO_jumpsuit"
	has_sensor = 1

/obj/item/clothing/suit/storage/RO
	name = "RO Jacket"
	desc = "A green jacket worn by crew on the Sulaco. The back has the flag of the United Americas on it."
	icon_state = "RO_jacket"
	item_state = "RO_jacket"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/under/marine/mp
	name = "military police jumpsuit"
	icon_state = "MP_jumpsuit"
	item_state = "MP_jumpsuit"
	item_color = "MP_jumpsuit"

/obj/item/clothing/under/marine/officer
	name = "marine officer uniform"
	desc = "Softer than silk. Lighter than feather. More protective than Kevlar. Fancier than a regular jumpsuit, too."
	icon_state = "milohachert"
	item_state = "milohachert"
	item_color = "milohachert"

/obj/item/clothing/under/marine/officer/technical
	name = "technical officer uniform"
	icon_state = "johnny"
	item_color = "johnny"

/obj/item/clothing/under/marine/officer/logistics
	name = "marine officer uniform"
	desc = "A uniform worn by commissoned officers of the USCM. Do the corps proud."
	icon_state = "BO_jumpsuit"
	item_color = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/bridge
	name = "Bridge Officer uniform"
	desc = "A uniform worn by commissoned officers of the USCM. Do the corps proud."
	icon_state = "BO_jumpsuit"
	item_state = "BO_jumpsuit"
	item_color = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/exec
	name = "Executive Officer uniform"
	desc = "A uniform typically worn by a First-lieutenant in the USCM. The Executive Officer is the second in-charge of the USCM forces onboard the USS Sulaco."
	icon_state = "XO_jumpsuit"
	item_state = "XO_jumpsuit"
	item_color = "XO_jumpsuit"

/obj/item/clothing/under/marine/officer/command
	name = "Commander Uniform"
	desc = "The well-ironed uniform of a USCM Captain, the commander onboard the USS Sulaco. Even looking at it the wrong way could result in being court-marshalled."
	icon_state = "CO_jumpsuit"
	item_state = "CO_jumpsuit"
	item_color = "CO_jumpsuit"

/obj/item/clothing/under/marine/officer/ce
	name = "chief engineer uniform"
	desc = "A uniform for the engineering crew of the USS Sulaco. Slightly protective against enviromental hazards. Worn by the Chief.."
	armor = list(melee = 0, bullet = 0, laser = 25,energy = 0, bomb = 0, bio = 0, rad = 25)
	icon_state = "EC_jumpsuit"
	item_state = "EC_jumpsuit"
	item_color = "EC_jumpsuit"

/obj/item/clothing/under/marine/officer/engi
	name = "engineer uniform"
	desc = "A uniform for the engineering crew of the USS Sulaco. Slightly protective against enviromental hazards."
	armor = list(melee = 0, bullet = 0, laser = 15,energy = 0, bomb = 0, bio = 0, rad = 10)
	icon_state = "E_jumpsuit"
	item_state = "E_jumpsuit"
	item_color = "E_jumpsuit"

/obj/item/clothing/under/marine/officer/researcher
	name = "Researcher clothes"
	desc = "A simple set of civilian clothes worn by researchers. "
	armor = list(melee = 0, bullet = 0, laser = 15,energy = 10, bomb = 0, bio = 10, rad = 10)
	icon_state = "research_jumpsuit"
	item_state = "research_jumpsuit"
	item_color = "research_jumpsuit"

//=========================//RESPONDERS\\================================\\
//=======================================================================\\

/obj/item/clothing/under/marine_jumpsuit/PMC
	name = "PMC uniform"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit."
	icon = 'icons/PMC/PMC.dmi'
	//icon_override = 'icons/PMC/PMC.dmi'
	icon_state = "pmc_jumpsuit"
	item_state = "armor"
	item_color = "pmc_jumpsuit"
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 10, bio = 1, rad = 1)

/obj/item/clothing/under/marine_jumpsuit/PMC/leader
	name = "PMC command uniform"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit. This particular suit looks like it belongs to a high-ranking officer."
	item_state = "officer_jumpsuit"
	item_color = "officer_jumpsuit"

/obj/item/clothing/under/marine_jumpsuit/PMC/Bear
	name = "Iron Bear Uniform"
	desc = "A uniform worn by Iron Bears mercenaries"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "bear_jumpsuit"
	item_state = "bear_jumpsuit"
	item_color = "bear_jumpsuit"

/obj/item/clothing/under/marine_jumpsuit/PMC/dutch
	name = "Dutch's Dozen Uniform"
	desc = "A uniform worn by the mercenaries"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "dutch_jumpsuit"
	item_state = "dutch_jumpsuit"
	item_color = "dutch_jumpsuit"

/obj/item/clothing/under/marine_jumpsuit/PMC/dutch2
	name = "Dutch's Dozen Uniform"
	desc = "A uniform worn by the mercenaries"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "dutch_jumpsuit2"
	item_state = "dutch_jumpsuit2"
	item_color = "dutch_jumpsuit2"

/obj/item/clothing/under/marine_jumpsuit/PMC/commando
	name = "PMC Commando Uniform"
	desc = "An armored uniform worn by Weyland Yutani elite commandos."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_jumpsuit"
	item_state = "commando_jumpsuit"
	item_color = "commando_jumpsuit"
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 20, bomb = 10, bio = 10, rad = 10)

//===========================//CIVILIANS\\===============================\\
//=======================================================================\\

/obj/item/clothing/under/pizza
	name = "pizza delivery uniform"
	desc = "An ill-fitting, slightly stained uniform for a pizza delivery pilot. Smells of cheese."
	icon_state = "redshirt2"
	item_state = "r_suit"
	item_color = "redshirt2"

/obj/item/clothing/under/colonist
	name = "Colonist Uniform"
	desc = "A stylish grey-green jumpsuit - standard issue for colonists."
	icon_state = "colonist"
	item_state = "colonist"
	item_color = "colonist"

/obj/item/clothing/under/CM_uniform
	name = "Colonial Marshal Uniform"
	desc = "A blue shirt and tan trousers - the official uniform for a Colonial Marshal."
	icon_state = "marshal"
	item_state = "marshal"
	item_color = "marshal"
	armor = list(melee = 15, bullet = 15, laser = 15,energy = 5, bomb = 5, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/CMB
	name = "CMB Jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	item_state = "CMB_jacket"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/under/liaison_suit
	desc = "A stiff, stylish tan suit commonly worn by businessmen from the Weyland Yutani corporation. Specically crafted to make you look like a prick."
	name = "Liaison's Tan Suit"
	icon_state = "liaison_regular"
	item_state = "liaison_regular"
	item_color = "liaison_regular"
	has_sensor = 1

/obj/item/clothing/under/liaison_suit/outing
	desc = "A casual outfit consisting of a collared shirt and a vest. Looks like something you might wear on the weekends, or on a visit to a derelict colony."
	name = "Liaison's Outfit"
	icon_state = "liaison_outing"
	item_state = "liaison_outing"
	item_color = "liaison_outing"

/obj/item/clothing/under/liaison_suit/formal
	desc = "A formal, white suit. Looks like something you'd wear to a funeral, a Weyland-Yutani corporate dinner, or both. Stiff as a board, but makes you feel like rolling out of a Rolls-Royce."
	name = "Liaison's White Suit"
	icon_state = "liaison_formal"
	item_state = "liaison_formal"
	item_color = "liaison_formal"

/obj/item/clothing/under/liaison_suit/suspenders
	desc = "A collared shirt, complimented by a pair of suspenders. Worn by Weyland-Yutani employees who ask the tough questions. Smells faintly of cigars and bad acting."
	name = "Liaison's Attire"
	icon_state = "liaison_suspenders"
	item_state = "liaison_suspenders"
	item_color = "liaison_suspenders"

/obj/item/clothing/suit/storage/snow_suit
	name = "Snow Suit"
	desc = "A standard snow suit. It can protect the wearer from extreme temperatures down to 220K (-53°C)."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "snowsuit_alpha"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 15, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	siemens_coefficient = 0.7

/obj/item/clothing/suit/storage/snow_suit/doctor
	name = "Doctor's Snow Suit"
	icon_state = "snowsuit_doctor"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/snow_suit/engineer
	name = "Engineer's Snow Suit"
	icon_state = "snowsuit_engineer"
	armor = list(melee = 25, bullet = 35, laser = 35, energy = 20, bomb = 10, bio = 0, rad = 0)