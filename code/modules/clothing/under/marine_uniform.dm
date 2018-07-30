
//=========================//MARINES\\===================================\\
//=======================================================================\\


/obj/item/clothing/under/marine
	name = "\improper USCM uniform"
	desc = "A standard-issue Marine uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	siemens_coefficient = 0.9
	icon_state = "marine_jumpsuit"
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 5, bomb = 5, bio = 5, rad = 5)
	suit_restricted = list(/obj/item/clothing/suit/storage/marine)
	rollable_sleeves = TRUE

/obj/item/clothing/under/marine/New(loc,expected_type 		= /obj/item/clothing/under/marine,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper USCM snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature),
	override_icon_state[] 	= null
	)
	select_gamemode_skin(expected_type,override_icon_state,new_name,new_protection)
	..()

/obj/item/clothing/under/marine/set_sensors(mob/user)
	user << "<span class='warning'>The sensors in your uniform can't be modified.</span>"
	return

/obj/item/clothing/under/marine/medic
	name = "\improper USCM medic fatigues"
	desc = "A standard-issue Marine Medic fatigues It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "marine_medic"

/obj/item/clothing/under/marine/medic/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper USCM medic snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	..(loc,expected_type, new_name, new_protection)

/obj/item/clothing/under/marine/engineer
	name = "\improper USCM engineer fatigues"
	desc = "A standard-issue Marine Engineer fatigues It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "marine_engineer"

/obj/item/clothing/under/marine/engineer/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper USCM engineer snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature))
	..(loc,expected_type, new_name, new_protection)

/obj/item/clothing/under/marine/sniper
	name = "\improper USCM sniper uniform"
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/sniper/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper USCM sniper snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature),
	override_icon_state[]		= list(MAP_ICE_COLONY = "s_marine_sniper")
	)
	..(loc,expected_type, override_icon_state, new_name, new_protection)

/obj/item/clothing/under/marine/tanker
	name = "\improper USCM tanker uniform"
	icon_state = "marine_tanker"
	rollable_sleeves = FALSE

/*
/obj/item/clothing/under/marine/tanker/New(loc,expected_type 		= type,
	new_name[] 			= list(MAP_ICE_COLONY = "\improper USCM tanker snow uniform"),
	new_protection[] 	= list(MAP_ICE_COLONY = ICE_PLANET_min_cold_protection_temperature),
	override_icon_state[]		= list(MAP_ICE_COLONY = "s_marine_tanker")
	)
	..(loc,expected_type, override_icon_state, new_name, new_protection)
*/


/obj/item/clothing/under/marine/mp
	name = "military police jumpsuit"
	desc = "A standard-issue Military Police uniform. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "MP_jumpsuit"
	suit_restricted = list(/obj/item/clothing/suit/storage/marine, /obj/item/clothing/suit/armor/riot/marine)
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/officer
	name = "marine officer uniform"
	desc = "Softer than silk. Lighter than feather. More protective than Kevlar. Fancier than a regular jumpsuit, too. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "officertanclothes"
	item_state = "officertanclothes"
	suit_restricted = null //so most officers can wear whatever suit they want
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/officer/warrant
	name = "\improper chief MP uniform"
	desc = "A uniform typically worn by a Chief MP of the USCM. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions. This uniform includes a small EMF distributor to help nullify energy-based weapon fire, along with a hazmat chemical filter woven throughout the material to ward off biological and radiation hazards."
	icon_state = "WO_jumpsuit"
	item_state = "WO_jumpsuit"
	suit_restricted = list(/obj/item/clothing/suit/storage/marine, /obj/item/clothing/suit/armor/riot/marine)


/obj/item/clothing/under/marine/officer/technical
	name = "technical officer uniform"
	icon_state = "johnny"

/obj/item/clothing/under/marine/officer/logistics
	name = "marine officer uniform"
	desc = "A uniform worn by commissioned officers of the USCM. Do the corps proud. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/pilot
	name = "pilot officer bodysuit"
	desc = "A bodysuit worn by pilot officers of the USCM, and is meant for survival in inhospitable conditions. Fly the marines onwards to glory. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "pilot_flightsuit"
	flags_cold_protection = ICE_PLANET_min_cold_protection_temperature
	suit_restricted = list(/obj/item/clothing/suit/armor/vest/pilot)

/obj/item/clothing/under/marine/officer/pilot/New()
	select_gamemode_skin(/obj/item/clothing/under/marine/officer/pilot)
	..()

/obj/item/clothing/under/marine/officer/tanker
	name = "tank crewman officer uniform"
	desc = "A uniform worn by commissioned officers of the USCM. Do the corps proud. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "marine_tanker"
	suit_restricted = list(/obj/item/clothing/suit/storage/marine/tanker)

/obj/item/clothing/under/marine/officer/bridge
	name = "staff officer uniform"
	desc = "A uniform worn by commissioned officers of the USCM. Do the corps proud. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "BO_jumpsuit"

/obj/item/clothing/under/marine/officer/bridge/New()
	select_gamemode_skin(/obj/item/clothing/under/marine/officer/bridge)
	..()


/obj/item/clothing/under/marine/officer/exec
	name = "executive officer uniform"
	desc = "A uniform typically worn by a first-lieutenant Executive Officer in the USCM. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "XO_jumpsuit"

/obj/item/clothing/under/marine/officer/exec/New()
	select_gamemode_skin(/obj/item/clothing/under/marine/officer/exec)
	..()

/obj/item/clothing/under/marine/officer/command
	name = "commander uniform"
	desc = "The well-ironed uniform of a USCM commander. Even looking at it the wrong way could result in being court-marshalled. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "CO_jumpsuit"

/obj/item/clothing/under/marine/officer/command/New()
	select_gamemode_skin(/obj/item/clothing/under/marine/officer/command)
	..()

/obj/item/clothing/under/marine/officer/admiral
	name = "admiral uniform"
	desc = "A uniform worn by a fleet admiral. It comes in a shade of deep black, and has a light shimmer to it. The weave looks strong enough to provide some light protections."
	item_state = "admiral_jumpsuit"

/obj/item/clothing/under/marine/officer/ce
	name = "chief engineer uniform"
	desc = "A uniform for a military engineer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	armor = list(melee = 5, bullet = 5, laser = 25, energy = 5, bomb = 5, bio = 5, rad = 25)
	icon_state = "EC_jumpsuit"

/obj/item/clothing/under/marine/officer/engi
	name = "engineer uniform"
	desc = "A uniform for a military engineer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	armor = list(melee = 5, bullet = 5, laser = 15, energy = 5, bomb = 5, bio = 5, rad = 10)
	icon_state = "E_jumpsuit"

/obj/item/clothing/under/marine/officer/researcher
	name = "researcher clothes"
	desc = "A simple set of civilian clothes worn by researchers. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 10, bomb = 10, bio = 10, rad = 5)
	icon_state = "research_jumpsuit"

//=========================//RESPONDERS\\================================\\
//=======================================================================\\

/obj/item/clothing/under/marine/veteran
	rollable_sleeves = FALSE

/obj/item/clothing/under/marine/veteran/PMC
	name = "\improper PMC fatigues"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit."
	icon_state = "pmc_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 10, bio = 1, rad = 1)
	suit_restricted = list(/obj/item/clothing/suit/storage/marine/veteran/PMC, /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC)

/obj/item/clothing/under/marine/veteran/PMC/leader
	name = "\improper PMC command fatigues"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_jumpsuit"

/obj/item/clothing/under/marine/veteran/PMC/commando
	name = "\improper PMC commando uniform"
	desc = "An armored uniform worn by Weyland Yutani elite commandos. It is well protected while remaining light and comfortable."
	icon_state = "commando_jumpsuit"
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 20, bomb = 10, bio = 10, rad = 10)
	has_sensor = 0

/obj/item/clothing/under/marine/veteran/bear
	name = "\improper Iron Bear uniform"
	desc = "A uniform worn by Iron Bears mercenaries in the service of Mother Russia. Smells a little like an actual bear."
	icon_state = "bear_jumpsuit"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	has_sensor = 0
	suit_restricted = list(/obj/item/clothing/suit/storage/marine/veteran/bear)


/obj/item/clothing/under/marine/veteran/UPP
	name = "\improper UPP fatigues"
	desc = "A set of UPP fatigues, mass produced for the armed-forces of the Union of Progressive Peoples. A rare sight, especially in ICC zones. This particular set sports the dark drab pattern of the UPP 17th battalion, 'Smoldering Sons', operating in the sparse UPP frontier in the Anglo-Japanese arm."
	icon_state = "upp_uniform"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	has_sensor = 0
	suit_restricted = list(/obj/item/clothing/suit/storage/faction/UPP, /obj/item/clothing/suit/storage/marine/smartgunner/UPP)

/obj/item/clothing/under/marine/veteran/UPP/medic
	name = "\improper UPP medic fatigues"
	icon_state = "upp_uniform_medic"

/obj/item/clothing/under/marine/veteran/freelancer
	name = "\improper freelancer fatigues"
	desc = "A set of loose fitting fatigues, perfect for an informal mercenary. Smells like gunpowder, apple pie, and covered in grease and sake stains."
	icon_state = "freelancer_uniform"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	has_sensor = 0
	suit_restricted = list(/obj/item/clothing/suit/storage/faction/freelancer)

/obj/item/clothing/under/marine/veteran/dutch
	name = "\improper Dutch's Dozen uniform"
	desc = "A comfortable uniform worn by the Dutch's Dozen mercenaries. It's seen some definite wear and tear, but is still in good condition."
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	icon_state = "dutch_jumpsuit"
	has_sensor = 0
	suit_restricted = list(/obj/item/clothing/suit/storage/marine/veteran/dutch, /obj/item/clothing/suit/armor/vest/dutch)


/obj/item/clothing/under/marine/veteran/dutch/ranger
	icon_state = "dutch_jumpsuit2"

//===========================//HELGHAST - MERCENARY\\================================\\
//=====================================================================\\

/obj/item/clothing/under/marine/veteran/mercenary
	name = "\improper Mercenary fatigues"
	desc = "A thick, beige suit with a red armband. There is an unknown symbol is emblazed on the suit."
	icon_state = "mercenary_heavy_uniform"
	min_cold_protection_temperature = ICE_PLANET_min_cold_protection_temperature
	armor = list(melee = 10, bullet = 10, laser = 5, energy = 5, bomb = 10, bio = 1, rad = 1)
	suit_restricted = list(/obj/item/clothing/suit/storage/marine/veteran/mercenary)

/obj/item/clothing/under/marine/veteran/mercenary/miner
	name = "\improper Mercenary miner fatigues"
	desc = "A beige suit with a red armband. It looks a little thin, like it wasn't designed for protection. There is an unknown symbol is emblazed on the suit."
	icon_state = "mercenary_miner_uniform"

/obj/item/clothing/under/marine/veteran/mercenary/engineer
	name = "\improper Mercenary engineer fatigues"
	desc = "A blue suit with yellow accents, used by engineers. There is an unknown symbol is emblazed on the suit."
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
	armor = list(melee = 15, bullet = 15, laser = 15,energy = 5, bomb = 5, bio = 5, rad = 5)
	has_sensor = 0


/obj/item/clothing/under/liaison_suit
	name = "liaison's tan suit"
	desc = "A stiff, stylish tan suit commonly worn by businessmen from the Weyland Yutani corporation. Expertly crafted to make you look like a prick."
	icon_state = "liaison_regular"

/obj/item/clothing/under/liaison_suit/outing
	name = "liaison's outfit"
	desc = "A casual outfit consisting of a collared shirt and a vest. Looks like something you might wear on the weekends, or on a visit to a derelict colony."
	icon_state = "liaison_outing"

/obj/item/clothing/under/liaison_suit/formal
	name = "liaison's white suit"
	desc = "A formal, white suit. Looks like something you'd wear to a funeral, a Weyland-Yutani corporate dinner, or both. Stiff as a board, but makes you feel like rolling out of a Rolls-Royce."
	icon_state = "liaison_formal"

/obj/item/clothing/under/liaison_suit/suspenders
	name = "liaison's attire"
	desc = "A collared shirt, complimented by a pair of suspenders. Worn by Weyland-Yutani employees who ask the tough questions. Smells faintly of cigars and bad acting."
	icon_state = "liaison_suspenders"



/obj/item/clothing/under/rank/chef/exec
	name = "\improper Weyland Yutani suit"
	desc = "A formal white undersuit."
	rollable_sleeves = FALSE

/obj/item/clothing/under/rank/ro_suit
	name = "requisition officer suit."
	desc = "A nicely-fitting military suit for a requisition officer. It has shards of light Kevlar to help protect against stabbing weapons, bullets, and shrapnel from explosions, a small EMF distributor to help null energy-based weapons, and a hazmat chemical filter weave to ward off biological and radiation hazards."
	icon_state = "RO_jumpsuit"
	rollable_sleeves = FALSE

/obj/item/clothing/under/rank/synthetic
	name = "\improper USCM Support Uniform"
	desc = "A simple uniform made for Synthetic crewmembers."
	icon_state = "rdalt"
	rollable_sleeves = FALSE
