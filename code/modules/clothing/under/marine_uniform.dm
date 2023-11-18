/*********MARINES***********/


/obj/item/clothing/under/marine
	name = "\improper TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	siemens_coefficient = 0.9
	icon = 'icons/obj/clothing/uniforms/marine_uniforms.dmi'
	icon_state = "marine_jumpsuit"
	item_icons = list(
		slot_w_uniform_str = 'icons/mob/clothing/uniforms/marine_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	has_sensor = 2
	adjustment_variants = list(
		"Rolled Sleeves" = "_d",
		"No Sleeves" = "_h",
		"No Top" = "_r",
	)

/obj/item/clothing/under/marine/hyperscale
	name = "\improper 8E Chameleon TGMC uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform BUT colorable with a facepaint! You suspect it's not as robust-proof as advertised."
	icon_state = "hyperscale_marine_jumpsuit"
	item_state = "hyperscale_marine_jumpsuit"
	greyscale_colors = ARMOR_PALETTE_BLACK
	greyscale_config = /datum/greyscale_config/marine_uniform
	colorable_colors = ARMOR_PALETTES_LIST
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED|PRESET_COLORS_ALLOWED

/obj/item/clothing/under/marine/black_vest
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)

//Squad colored turtlenecks
/obj/item/clothing/under/marine/squad/neck
	name = "\improper TGMC Delta turtleneck"
	desc = "A standard issued TGMC turtleneck colored blue."
	icon_state = "delta_merc"
	adjustment_variants = list(
		"Rolled Sleeves" = "_d",
	)

/obj/item/clothing/under/marine/squad/neck/delta
	name = "\improper TGMC Delta turtleneck"
	desc = "A standard issued TGMC turtleneck colored blue, with a slight hint of bravery."
	icon_state = "delta_merc"

/obj/item/clothing/under/marine/squad/neck/charile
	name = "\improper TGMC Charile turtleneck"
	desc = "A standard issued TGMC turtleneck colored purple, you're reminded of how proper squad cohesion can make or break a mission."
	icon_state = "charlie_merc"

/obj/item/clothing/under/marine/squad/neck/bravo
	name = "\improper TGMC Bravo turtleneck"
	desc = "A standard issued TGMC turtleneck colored yellow, you suddenly get thoughts of how to improve the FOB, if slightly."
	icon_state = "bravo_merc"

/obj/item/clothing/under/marine/squad/neck/alpha
	name = "\improper TGMC Alpha turtleneck"
	desc = "A standard issued TGMC turtleneck colored red, you feel as if you can face the world and all it has to bring against you."
	icon_state = "alpha_merc"

// camo things stuff yeah!

/obj/item/clothing/under/marine/camo
	name = "\improper TGMC camo fatigues (jungle)"
	icon_state = "m_marine_jumpsuit"

/obj/item/clothing/under/marine/camo/snow
	name = "\improper TGMC camo fatigues (snow)"
	icon_state = "s_marine_jumpsuit"

/obj/item/clothing/under/marine/camo/desert
	name = "\improper TGMC camo fatigues (desert)"
	icon_state = "d_marine_jumpsuit"

/obj/item/clothing/under/marine/corpsman
	name = "\improper TGMC corpsman fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat corpsman fatigues. You suspect it's not as robust-proof as advertised."
	icon_state = "marine_medic"

/obj/item/clothing/under/marine/corpsman/corpman_vest
	starting_attachments = list(/obj/item/armor_module/storage/uniform/white_vest)

/obj/item/clothing/under/marine/engineer
	name = "\improper TGMC engineer fatigues"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented combat engineer fatigues. You suspect it's not as robust-proof as advertised."
	icon_state = "marine_engineer"

/obj/item/clothing/under/marine/engineer/black_vest
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)

/obj/item/clothing/under/marine/jaeger
	name = "\improper TGMC jaeger undersuit"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented marine uniform. You suspect it's not as robust-proof as advertised."
	siemens_coefficient = 0.9
	icon_state = "marine_undersuit"
	adjustment_variants = list()
	has_sensor = 2
	flags_item_map_variant = null

/obj/item/clothing/under/marine/mp
	name = "military police uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented military police uniform. You suspect it's not as robust-proof as advertised."
	icon_state = "MP_jumpsuit"
	adjustment_variants = list()

/obj/item/clothing/under/marine/orion_fatigue
	name = "\improper Orion fatigues"
	desc = "Originated from Orion Military Outpost. Designed for ship and urban environments, they're meant for recon, stealth, and evac operations. They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. They're the definition of over-funded ideas, least they look neat. It is very likely that a boot fresh from boot camp to buy this at the BX with his E-1 pay because of how tacticool it looks."
	icon_state = "orion_fatigues"
	item_state = "orion_fatigues"
	adjustment_variants = list(
		"Down" = "_d",
	)

/obj/item/clothing/under/marine/red_fatigue
	name = "\improper Big Red fatigues"
	desc = "Originated from Big Red. Designed for dry, low humid, and Mars-eqse environments, they're meant for recon, stealth, and evac operations. They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. They make you feel like one with the desert, forged by the beating Sun. Rumors had it that it can recycle your sweat and urine for drinkable water!"
	icon_state = "red_fatigues"
	item_state = "red_fatigues"
	adjustment_variants = list(
		"Down" = "_d",
	)

/obj/item/clothing/under/marine/lv_fatigue
	name = "\improper LV-624 fatigues"
	desc = "Originated from LV-624. Designed for wet, high humid, and jungle environments, they're meant for recon, stealth, and evac operations. They come with a built in cassette player hearable only to the user to help pass time, during any possible long waits. Somewhere, someone is playing 'Fortunate Sons' in the background, and you can smell napalm and Agent Orange in the air..."
	icon_state = "lv_fatigues"
	item_state = "lv_fatigues"
	adjustment_variants = list(
		"Down" = "_d",
	)

/obj/item/clothing/under/marine/striped
	name = "\improper Striped fatigues"
	desc = "A simple set of camo pants and a striped shirt."
	icon_state = "marine_striped"
	item_state = "marine_striped"
	adjustment_variants = list()
/obj/item/clothing/under/marine/black_suit
	name = "\improper marine black suit"
	desc = "A easy fitting black suit, somehow exactly your size."
	icon_state = "marine_suit"
	item_state = "marine_suit"
	adjustment_variants = list()
/obj/item/clothing/under/marine/officer
	name = "marine officer uniform"
	desc = "A kevlar-weaved, hazmat-tested, EMF-augmented, yet extra-soft and extra-light officer uniform. You suspect it's not as extra-fancy as advertised."
	icon_state = "officertanclothes"
	item_state = "officertanclothes"
	adjustment_variants = list()

/obj/item/clothing/under/marine/officer/warden
	name = "marine officer uniform"
	desc = "A kevlar-weaved, hazmat-tested, EMF-augmented, yet extra-soft and extra-light officer uniform. You suspect it's not as extra-fancy as advertised."
	icon_state = "wardentanclothes"
	item_state = "wardentanclothes"

/obj/item/clothing/under/marine/officer/hos
	name = "marine officer uniform"
	desc = "A kevlar-weaved, hazmat-tested, EMF-augmented, yet extra-soft and extra-light officer uniform. You suspect it's not as extra-fancy as advertised."
	icon_state = "hostanclothes"
	item_state = "hostanclothes"

/obj/item/clothing/under/marine/officer/warrant
	name = "Command Master at Arms uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented uniform worn by lawful-good warrant officers. You suspect it's not as robust-proof as advertised."
	icon_state = "WO_jumpsuit"
	item_state = "WO_jumpsuit"

/obj/item/clothing/under/marine/officer/logistics
	name = "marine officer uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented uniform worn by logistics officers of the TGMC. Do the corps proud."
	icon_state = "BO_jumpsuit"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT)

/obj/item/clothing/under/marine/officer/ro_suit
	name = "requisition officer suit"
	desc = "A nicely-fitting, kevlar-weaved, hazmat-tested, EMF-augmented requisition officer suit. You suspect it's not as robust-proof as advertised."
	icon_state = "RO_jumpsuit"
	adjustment_variants = list()

/obj/item/clothing/under/marine/officer/pilot
	name = "pilot officer flightsuit"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented, survival-friendly pilot flightsuit. Fly the marines onwards to glory."
	icon_state = "pilot_flightsuit"
	flags_cold_protection = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	flags_item_map_variant = null
	adjustment_variants = list(
		"Half" = "_h",
	)

/obj/item/clothing/under/marine/officer/mech
	name = "mech pilot uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented uniform worn by mech pilots. Not as impressive as a titanium robot but good enough."
	icon_state = "marine_mech_pilot"

/obj/item/clothing/under/marine/officer/bridge
	name = "staff officer uniform"
	desc = "A standard-issue, kevlar-weaved, hazmat-tested, EMF-augmented staff officer uniform. Do the navy proud."
	icon_state = "BO_jumpsuit"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT)

/obj/item/clothing/under/marine/officer/exec
	name = "field commander uniform"
	desc = "A special-issue, kevlar-weaved, hazmat-tested, EMF-augmented worn by a field-grade officer of the TGMC. You suspect it's not as robust-proof as advertised."
	icon_state = "XO_jumpsuit"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT)

/obj/item/clothing/under/marine/officer/exec/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)

/obj/item/clothing/under/marine/officer/command
	name = "captain uniform"
	desc = "A special-issue, well-ironed, kevlar-weaved, hazmat-tested, EMF-augmented uniform worth of a TerraGov Naval Captain. Even looking at it the wrong way could result in being court-martialed."
	icon_state = "CO_jumpsuit"
	flags_item_map_variant = (ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT)

/obj/item/clothing/under/marine/officer/admiral
	name = "admiral uniform"
	desc = "A uniform worn by a fleet admiral. It comes in a shade of deep black, and has a light shimmer to it. The weave looks strong enough to provide some light protections."
	item_state = "admiral_jumpsuit"

/obj/item/clothing/under/marine/officer/ce
	name = "chief ship engineer uniform"
	desc = "An engine-friendly, kevlar-weaved, hazmat-tested, EMF-augmented ship engineer uniform. You suspect it's not as robust-proof as advertised."
	icon_state = "EC_jumpsuit"
	adjustment_variants = list(
		"Half" = "_h",
	)

/obj/item/clothing/under/marine/officer/engi
	name = "engineer uniform"
	desc = "An engine-friendly, kevlar-weaved, hazmat-tested, EMF-augmented chief ship engineer uniform. You suspect it's not as robust-proof as advertised."
	icon_state = "E_jumpsuit"
	adjustment_variants = list(
		"Half" = "_h",
	)

/obj/item/clothing/under/marine/officer/researcher
	name = "researcher clothes"
	desc = "A set of formal, yet comfy, clothing worn by scholars and researchers alike."
	icon_state = "research_jumpsuit"

/obj/item/clothing/under/marine/whites
	name = "\improper TGMC white dress uniform"
	desc = "A standard-issue TerraGov Marine Corps white dress uniform. The starch in the fabric chafes a small amount but it pales in comparison to the pride you feel when you first put it on during graduation from boot camp. Doesn't seem to fit perfectly around the waist though."
	siemens_coefficient = 0.9
	icon_state = "marine_whites" //with thanks to Manezinho
	item_state = "marine_whites" //with thanks to Manezinho
	adjustment_variants = list()

/obj/item/clothing/under/marine/service
	name = "\improper TGMC service uniform"
	desc = "A standard-issue TerraGov Marine Corps dress uniform. Sometimes, you hate wearing this since you remember wearing this to Infantry School and have to wear this when meeting a commissioned officer. This is what you wear when you are not deployed and are working in an office. Doesn't seem to fit perfectly around the waist."
	siemens_coefficient = 0.9
	icon_state = "marine_service" //with thanks to Fitz 'Pancake' Sholl
	item_state = "marine_service" //with thanks to Fitz 'Pancake' Sholl

/*=========================RESPONDERS================================*/


/*=========================Imperium=================================*/

/obj/item/clothing/under/marine/imperial
	name = "\improper Imperial uniform"
	desc = "This uniform is given out to pretty much every soldier in the Imperium."
	adjustment_variants = list() // don't disrespect the EMPEROR!
	icon = 'icons/obj/clothing/uniforms/ert_uniforms.dmi'
	icon_state = "guardjumpsuit"
	item_icons = list(
		slot_w_uniform_str = 'icons/mob/clothing/uniforms/ert_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	item_state = "guardjumpsuit"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)

/obj/item/clothing/under/marine/imperial/commissar
	name = "\improper commissar uniform"
	desc = "A commissars noble uniform."
	adjustment_variants = list() // don't disrespect the EMPEROR!
	icon_state = "commissar_uniform"
	item_state = "commissar_uniform"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)

/obj/item/clothing/under/marine/veteran //none of these are actual used by marines
	icon = 'icons/obj/clothing/uniforms/ert_uniforms.dmi'
	item_icons = list(
		slot_w_uniform_str = 'icons/mob/clothing/uniforms/ert_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	adjustment_variants = list()

/obj/item/clothing/under/marine/veteran/pmc
	name = "\improper PMC fatigues"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Nanotrasen corporation is emblazed on the suit."
	icon_state = "pmc_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/under/marine/veteran/pmc/holster
	starting_attachments = list(/obj/item/armor_module/storage/uniform/holster)

/obj/item/clothing/under/marine/veteran/pmc/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)
/obj/item/clothing/under/marine/veteran/pmc/leader
	name = "\improper PMC command fatigues"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Nanotrasen corporation is emblazed on the suit. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_jumpsuit"

/obj/item/clothing/under/marine/veteran/pmc/leader/holster
	starting_attachments = list(/obj/item/armor_module/storage/uniform/holster)

/obj/item/clothing/under/marine/veteran/pmc/commando
	name = "\improper PMC commando uniform"
	desc = "An armored uniform worn by Nanotrasen elite commandos. It is well protected while remaining light and comfortable."
	icon_state = "commando_jumpsuit"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 20, BOMB = 10, BIO = 10, FIRE = 20, ACID = 20)
	has_sensor = 0
	starting_attachments = list(/obj/item/armor_module/storage/uniform/holster/deathsquad)

/obj/item/clothing/under/marine/veteran/UPP
	name = "\improper USL fatigues"
	desc = "A well used set of USL fatigues, mass-produced for the pirates of the Lepidoptera."
	icon_state = "upp_uniform"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/UPP/medic
	name = "\improper USL medic fatigues"
	icon_state = "upp_uniform_medic"

//Freelancers

/obj/item/clothing/under/marine/veteran/freelancer
	name = "freelancer fatigues"
	desc = "A set of loose fitting fatigues, perfect for an informal mercenary. Smells like gunpowder, apple pie, and covered in grease and sake stains."
	icon_state = "freelancer_uniform"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	has_sensor = 0
	starting_attachments = list(/obj/item/armor_module/storage/uniform/holster/freelancer)

/obj/item/clothing/under/marine/veteran/freelancer/veteran
	starting_attachments = list(/obj/item/armor_module/storage/uniform/holster/vp)

/*===========================HELGHAST - MERCENARY================================*/

/obj/item/clothing/under/marine/veteran/mercenary
	name = "mercenary fatigues"
	desc = "A beige suit with a red armband. Sturdy and thick, simply imposing. A mysterious crest emblazons it."
	icon_state = "mercenary_heavy_uniform"
	min_cold_protection_temperature = ICE_PLANET_MIN_COLD_PROTECTION_TEMPERATURE
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 0, ENERGY = 0, BOMB = 10, BIO = 1, FIRE = 0, ACID = 0)

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
	has_sensor = 2

/obj/item/clothing/under/colonist/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)

/obj/item/clothing/under/CM_uniform
	name = "colonial marshal uniform"
	desc = "A blue shirt and tan trousers - the official uniform for a Colonial Marshal."
	icon_state = "marshal"
	has_sensor = 2

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
	adjustment_variants = list()

/obj/item/clothing/under/rank/synthetic
	name = "\improper TGMC Support Uniform"
	desc = "A simple uniform made for Synthetic crewmembers."
	icon_state = "rdalt"
	adjustment_variants = list()

/obj/item/clothing/under/som
	name = "\improper SOM officer uniform"
	desc = "The standard uniform of SOM military personnel. Its design shows a clear lineage from mining uniforms used in the old mining colonies."
	icon = 'icons/obj/clothing/uniforms/ert_uniforms.dmi'
	icon_state = "som_uniform"
	item_icons = list(
		slot_w_uniform_str = 'icons/mob/clothing/uniforms/ert_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/inhands/clothing/uniforms_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/clothing/uniforms_right.dmi',
	)
	item_state = "som_uniform"
	has_sensor = FALSE

/obj/item/clothing/under/som/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/brown_vest)


/obj/item/clothing/under/som/medic
	name = "\improper SOM medical uniform"
	desc = "The standard uniform of SOM military personnel. Its design shows a clear lineage from mining uniforms used in the old mining colonies. This one has medical markings."
	icon_state = "som_uniform_medic"
	item_state = "som_uniform_medic"

/obj/item/clothing/under/som/medic/vest
	starting_attachments = list(/obj/item/armor_module/storage/uniform/white_vest)

/obj/item/clothing/under/som/veteran
	name = "\improper SOM veteran uniform"
	desc = "The standard uniform of SOM military personnel. Its design shows a clear lineage from mining uniforms used in the old mining colonies. This one has markings indicating specialist status."
	icon_state = "som_uniform_veteran"
	item_state = "som_uniform_veteran"

/obj/item/clothing/under/som/veteran/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/brown_vest)

/obj/item/clothing/under/som/leader
	name = "\improper SOM leader uniform"
	desc = "The standard uniform of SOM military personnel. Its design shows a clear lineage from mining uniforms used in the old mining colonies. This one has leadership markings."
	icon_state = "som_uniform_leader"
	item_state = "som_uniform_leader"

/obj/item/clothing/under/som/leader/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/brown_vest)

/obj/item/clothing/under/som/officer
	name = "\improper SOM officer uniform"
	desc = "The distinct black uniform of a SOM officer. Usually worn by junior officers"
	icon_state = "som_officer_uniform"
	item_state = "som_officer_uniform"
	adjustment_variants = list()

/obj/item/clothing/under/som/officer/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)

/obj/item/clothing/under/som/officer/senior
	name = "\improper SOM officer uniform"
	desc = "The distinct jacketed black uniform of a SOM officer. Usually worn by senior officers"
	icon_state = "som_senior_officer_uniform"
	item_state = "som_senior_officer_uniform"

/obj/item/clothing/under/icc
	name = "\improper Modelle/30 uniform"
	desc = "The standard uniform of ICC military personnel. The design is clearly dual purpose, meant to be both a combat uniform and one fit for daily tasks abord ships."
	icon = 'icons/obj/clothing/uniforms/ert_uniforms.dmi'
	icon_state = "icc"
	item_icons = list(
		slot_w_uniform_str = 'icons/mob/clothing/uniforms/ert_uniforms.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	item_state = "icc"
	has_sensor = FALSE

/obj/item/clothing/under/icc/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/brown_vest)

/obj/item/clothing/under/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = DELONDROP

/obj/item/clothing/under/sectoid/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SECTOID_TRAIT)

/obj/item/clothing/under/marine/robotic
	name = "robotic armor suit mount"
	desc = "Additional structural armor plate used for mounting equipment on a combat robot."
	item_state = "chest_rig"
	icon_state = "chest_rig"
	adjustment_variants = list()
	species_exception = list(/datum/species/robot)

/obj/item/clothing/under/marine/robotic/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	. = ..()
	if(!isrobot(user))
		to_chat(user, span_warning("You can't equip this as it requires mounting screws on your body!"))
		return FALSE

/obj/item/clothing/under/marine/robotic/webbing
	starting_attachments = list(/obj/item/armor_module/storage/uniform/black_vest)
