
//=========================//MARINES\\===================================



/obj/item/clothing/under/marine
	name = "\improper TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	siemens_coefficient = 0.9
	icon_state = "marine_jumpsuit"
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 5, "bomb" = 5, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)
	rollable_sleeves = TRUE
	has_sensor = 2

/obj/item/clothing/under/marine/corpsman
	name = "\improper TGMC corpsman fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat corpsman fatigues. You suspect it's not as robust-proof as advertised."
	icon_state = "marine_medic"

/obj/item/clothing/under/marine/medic/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper TGMC corpsman snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE))
	..(loc,expected_type, new_name, new_protection)

/obj/item/clothing/under/marine/engineer
	name = "\improper TGMC engineer fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat engineer fatigues. You suspect it's not as robust-proof as advertised."
	icon_state = "marine_engineer"

/obj/item/clothing/under/marine/engineer/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper TGMC engineer snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE))
	..(loc,expected_type, new_name, new_protection)

/obj/item/clothing/under/marine/sniper
	name = "\improper TGMC sniper uniform"
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/sniper/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper TGMC sniper snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE),
	override_icon_state[]		= list(MAP_ICE_COLONY = "s_marine_sniper")
	)
	..(loc,expected_type, override_icon_state, new_name, new_protection)

/obj/item/clothing/under/marine/tanker
	name = "\improper TGMC tanker uniform"
	icon_state = "marine_tanker"
	rollable_sleeves = FALSE

/*
/obj/item/clothing/under/marine/tanker/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper TGMC tanker snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE),
	override_icon_state[]		= list(MAP_ICE_COLONY = "s_marine_tanker")
	)
	..(loc,expected_type, override_icon_state, new_name, new_protection)
*/

/obj/item/clothing/under/marine/mp
	name = "military police uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented military police uniform. You suspect it's not as robust-proof as advertised."
	icon_state = "MP_jumpsuit"
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/officer
	name = "marine officer uniform"
	desc = "A kevlar-weaved, hazmat-tested, EMF-augmented, yet extra-soft and extra-light officer uniform. You suspect it's not as extra-fancy as advertised."
	icon_state = "officertanclothes"
	item_state = "officertanclothes"
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/officer/warrant
	name = "Command Master at Arms uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented uniform worn by lawful-good warrant officers. You suspect it's not as robust-proof as advertised."
	icon_state = "WO_jumpsuit"
	item_state = "WO_jumpsuit"


/obj/item/clothing/under/marine/officer/technical
	name = "technical officer uniform"
	icon_state = "johnny"

/obj/item/clothing/under/marine/officer/logistics
	name = "marine officer uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented uniform worn by logistics officers of the TGMC. Do the corps proud."
	icon_state = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/pilot
	name = "pilot officer bodysuit"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented, survival-friendly pilot bodysuit. Fly the marines onwards to glory."
	icon_state = "pilot_flightsuit"
	flags_cold_protection = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/under/marine/officer/tanker
	name = "tank crewman officer uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented fatigues worth of a tankman. Do the corps proud."
	icon_state = "marine_tanker"

/obj/item/clothing/under/marine/officer/bridge
	name = "intelligence officer uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented intelligence officer uniform. Do the navy proud."
	icon_state = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/exec
	name = "field commander uniform"
	desc = "A special-issue, kevlar-weaved, hazmat-tested, EMF-augmented worn by a field-grade officer of the TGMC. You suspect it's not as robust-proof as advertised."
	icon_state = "XO_jumpsuit"

/obj/item/clothing/under/marine/officer/command
	name = "captain uniform"
	desc = "A special-issue, well-ironed, kevlar-weaved, hazmat-tested, EMF-augmented uniform worth of a TerraGov Naval Captain. Even looking at it the wrong way could result in being court-martialed."
	icon_state = "CO_jumpsuit"

/obj/item/clothing/under/marine/officer/admiral
	name = "admiral uniform"
	desc = "A uniform worn by a fleet admiral. It comes in a shade of deep black, and has a light shimmer to it. The weave looks strong enough to provide some light protections."
	item_state = "admiral_jumpsuit"

/obj/item/clothing/under/marine/officer/ce
	name = "chief ship engineer uniform"
	desc = "An engine-friendly, kevlar-weaved, hazmat-tested, EMF-augmented ship engineer uniform. You suspect it's not as robust-proof as advertised."
	armor = list("melee" = 5, "bullet" = 5, "laser" = 25, "energy" = 5, "bomb" = 5, "bio" = 5, "rad" = 25, "fire" = 5, "acid" = 5)
	icon_state = "EC_jumpsuit"

/obj/item/clothing/under/marine/officer/engi
	name = "engineer uniform"
	desc = "An engine-friendly, kevlar-weaved, hazmat-tested, EMF-augmented chief ship engineer uniform. You suspect it's not as robust-proof as advertised."
	armor = list("melee" = 5, "bullet" = 5, "laser" = 15, "energy" = 5, "bomb" = 5, "bio" = 5, "rad" = 10, "fire" = 5, "acid" = 5)
	icon_state = "E_jumpsuit"

/obj/item/clothing/under/marine/officer/researcher
	name = "researcher clothes"
	desc = "A simple set of kevlar-weaved, hazmat-tested, EMF-augmented clothing worn by marine researchers. You suspect it's not as robust-proof as advertised."
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 5, "fire" = 10, "acid" = 10)
	icon_state = "research_jumpsuit"

/obj/item/clothing/under/whites
	name = "\improper TGMC dress uniform"
	desc = "A standard-issue Marine dress uniform. The starch in the fabric chafes a small amount but it pales in comparison to the pride you feel when you first put it on during graduation from boot camp. doesn't seem to fit perfectly around the waist though."
	siemens_coefficient = 0.9
	icon_state = "marine_whites" //with thanks to Manezinho
	rollable_sleeves = FALSE

//=========================//RESPONDERS\\================================


//=========================//Imperium\\==================================\\

/obj/item/clothing/under/marine/imperial
	name = "\improper Imperial uniform"
	desc = "This uniform is given out to pretty much every soldier in the Imperium."
	rollable_sleeves = FALSE // don't disrespect the EMPEROR!
	icon_state = "guardjumpsuit"
	item_state = "guardjumpsuit"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)

/obj/item/clothing/under/marine/veteran
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/veteran/PMC
	name = "\improper PMC fatigues"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Nanotrasen corporation is emblazed on the suit."
	icon_state = "pmc_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 5, "energy" = 5, "bomb" = 10, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)

/obj/item/clothing/under/marine/veteran/PMC/leader
	name = "\improper PMC command fatigues"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Nanotrasen corporation is emblazed on the suit. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_jumpsuit"

/obj/item/clothing/under/marine/veteran/PMC/commando
	name = "\improper PMC commando uniform"
	desc = "An armored uniform worn by Nanotrasen elite commandos. It is well protected while remaining light and comfortable."
	icon_state = "commando_jumpsuit"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/bear
	name = "\improper Iron Bear uniform"
	desc = "A uniform worn by Iron Bears mercenaries in the service of Mother Russia. Smells a little like an actual bear."
	icon_state = "bear_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	has_sensor = 0


/obj/item/clothing/under/marine/veteran/UPP
	name = "\improper UPP fatigues"
	desc = "A set of UPP fatigues, mass-produced for the armed-forces of the Union of Progressive Peoples. The dark drab pattern of the UPP 17th battalion 'Smoldering Sons' emblazons it."
	icon_state = "upp_uniform"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/UPP/medic
	name = "\improper UPP medic fatigues"
	icon_state = "upp_uniform_medic"

/obj/item/clothing/under/marine/veteran/freelancer
	name = "freelancer fatigues"
	desc = "A set of loose fitting fatigues, perfect for an informal mercenary. Smells like gunpowder, apple pie, and covered in grease and sake stains."
	icon_state = "freelancer_uniform"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/dutch
	name = "\improper Dutch's Dozen uniform"
	desc = "A comfortable uniform worn by the Dutch's Dozen mercenaries. It's seen some definite wear and tear, but is still in good condition."
	flags_armor_protection = CHEST|GROIN|LEGS
	flags_cold_protection = CHEST|GROIN|LEGS
	flags_heat_protection = CHEST|GROIN|LEGS
	icon_state = "dutch_jumpsuit"
	has_sensor = 0


/obj/item/clothing/under/marine/veteran/dutch/ranger
	icon_state = "dutch_jumpsuit2"

//===========================//HELGHAST - MERCENARY\\================================

/obj/item/clothing/under/marine/veteran/mercenary
	name = "mercenary fatigues"
	desc = "A beige suit with a red armband. Sturdy and thick, simply imposing. A mysterious crest emblazons it."
	icon_state = "mercenary_heavy_uniform"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 5, "energy" = 5, "bomb" = 10, "bio" = 1, "rad" = 1, "fire" = 5, "acid" = 5)

/obj/item/clothing/under/marine/veteran/mercenary/miner
	name = "mercenary miner fatigues"
	desc = "A beige suit with a red armband. The silky thin weaves of its design almost fool its purposes. A mysterious crest emblazons it."
	icon_state = "mercenary_miner_uniform"

/obj/item/clothing/under/marine/veteran/mercenary/engineer
	name = "mercenary engineer fatigues"
	desc = "A blue suit with yellow accents. A work of tailoring hardly seen on combat fatigues. A mysterious crest emblazons it."
	icon_state = "mercenary_engineer_uniform"


////// Civilians /////////


/obj/item/clothing/under/pizza
	name = "pizza delivery uniform"
	desc = "An ill-fitting, slightly stained uniform for a pizza delivery pilot. Smells of cheese."
	icon_state = "redshirt2"
	item_state = "r_suit"
	has_sensor = 0

/obj/item/clothing/under/colonist
	name = "colonist uniform"
	desc = "A stylish grey-green jumpsuit - standard issue for colonists."
	icon_state = "colonist"
	has_sensor = 0

/obj/item/clothing/under/CM_uniform
	name = "colonial marshal uniform"
	desc = "A blue shirt and tan trousers - the official uniform for a Colonial Marshal."
	icon_state = "marshal"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 5, "bomb" = 5, "bio" = 5, "rad" = 5, "fire" = 5, "acid" = 5)
	has_sensor = 0


/obj/item/clothing/under/liaison_suit
	name = "liaison's tan suit"
	desc = "A stiff, stylish tan suit commonly worn by businessmen from the Nanotrasen corporation. Expertly crafted to make you look like a prick."
	icon_state = "liaison_regular"

/obj/item/clothing/under/liaison_suit/outing
	name = "liaison's outfit"
	desc = "A casual outfit consisting of a collared shirt and a vest. Looks like something you might wear on the weekends, or on a visit to a derelict colony."
	icon_state = "liaison_outing"

/obj/item/clothing/under/liaison_suit/formal
	name = "liaison's white suit"
	desc = "A formal, white suit, something you'd wear to a funeral, a corporate dinner, or both. Stiff as a board, but makes you feel like rolling out of a Rolls-Royce."
	icon_state = "liaison_formal"

/obj/item/clothing/under/liaison_suit/suspenders
	name = "liaison's attire"
	desc = "A collared shirt, complimented by a pair of suspenders. Worn by Nanotrasen employees who ask the tough questions. Smells faintly of cigars and bad acting."
	icon_state = "liaison_suspenders"

/obj/item/clothing/under/liaison_suit/galaxy_blue
	name = "\improper De Void of Soul"
	desc = "A suit of stars and high-V gas. One that screams the cosmos and unfathomnable vastness. Earned by only the best of the best."
	icon_state = "liaison_galaxy_blue" // Thanks to Manezinho

/obj/item/clothing/under/liaison_suit/galaxy_red
	name = "\improper Pulsar gonne"
	desc = "A suit of stars and high-V gas. One that screams stellar fusion and re-entry burn. Earned by only the best of the best."
	icon_state = "liaison_galaxy_red" // Thanks to Manezinho

/obj/item/clothing/under/rank/chef/exec
	name = "\improper Nanotrasen suit"
	desc = "A formal white undersuit."
	rollable_sleeves = FALSE

/obj/item/clothing/under/rank/ro_suit
	name = "requisition officer suit"
	desc = "A nicely-fitting, kevlar-weaved, hazmat-tested, EMF-augmented requisition officer suit. You suspect it's not as robust-proof as advertised."
	icon_state = "RO_jumpsuit"
	rollable_sleeves = FALSE

/obj/item/clothing/under/rank/synthetic
	name = "\improper TGMC Support Uniform"
	desc = "A simple uniform made for Synthetic crewmembers."
	icon_state = "rdalt"
	rollable_sleeves = FALSE
