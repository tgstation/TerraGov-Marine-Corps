/**********************Marine Clothing**************************/

//HEADGEAR
/obj/item/clothing/head/helmet/marine/tech
	name = "M10 Technician Helmet"
	icon_state = "helmet-tech"
	item_color = "helmet-tech"

/obj/item/clothing/head/helmet/marine/medic
	name = "M10 Medic Helmet"
	icon_state = "helmet-medic"
	item_color = "helmet-medic"

/obj/item/clothing/head/helmet/marine/fluff/anthonycarmine
	name = "Anthony's helmet"
	desc = "COG helmet owned by Anthony Carmine"
	icon_state = "anthonycarmine"
	item_state = "anthonycarmine"
	item_color = "anthonycarmine"

/obj/item/clothing/head/helmet/marine/fluff/goldshieldberet
	name = "beret"
	desc = "A military black beret with a gold shield."
	icon_state = "gberet"

/obj/item/clothing/head/helmet/marine/fluff/goldtrimberet
	name = "beret"
	desc = "A maroon beret with gold trim"
	icon_state = "gtberet"

/obj/item/clothing/head/helmet/marine/fluff/elliotberet
	name = "Elliots Beret"
	desc = "A dark maroon beret"
	icon_state = "eberet"

/obj/item/clothing/head/helmet/marine/fluff/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"

/obj/item/clothing/head/soft/marine
	name = "marine sergeant cap"
	desc = "It's a soft cap made from advanced ballistic-resistant fibres. Fails to prevent lumps in the head."
	armor = list(melee = 50, bullet = 80, laser = 50,energy = 10, bomb = 50, bio = 0, rad = 0)
	icon_state = "greysoft"
	item_color = "grey"

/obj/item/clothing/head/soft/marine/alpha
	name = "alpha squad sergeant cap"
	icon_state = "redsoft"
	item_color = "red"

/obj/item/clothing/head/soft/marine/beta
	name = "beta squad sergeant cap"
	icon_state = "yellowsoft"
	item_color = "yellow"

/obj/item/clothing/head/soft/marine/charlie
	name = "charlie squad sergeant cap"
	icon_state = "purplesoft"
	item_color = "purple"

/obj/item/clothing/head/soft/marine/delta
	name = "delta squad sergeant cap"
	icon_state = "bluesoft"
	item_color = "blue"

/obj/item/clothing/head/soft/marine/mp
	name = "marine police sergeant cap"
	icon_state = "greensoft"
	item_color = "green"

/obj/item/clothing/head/beret/marine
	name = "marine officer beret"
	desc = "A beret with the ensign insignia emblazoned on it. It radiates respect and authority."
	armor = list(melee = 50, bullet = 100, laser = 50,energy = 50, bomb = 50, bio = 100, rad = 100)
	icon_state = "beret_badge"

/obj/item/clothing/head/beret/marine/commander
	name = "marine commander beret"
	desc = "A beret with the commander insignia emblazoned on it. Wearer may suffer the heavy weight of responsibility upon his head and shoulders."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/beret/marine/chiefofficer
	name = "chief officer beret"
	desc = "A beret with the lieutenant-commander insignia emblazoned on it. It emits a dark aura and may corrupt the soul."
	icon_state = "hosberet"

/obj/item/clothing/head/beret/marine/techofficer
	name = "technical officer beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. There's something inexplicably efficient about it..."
	icon_state = "e_beret_badge"

/obj/item/clothing/head/beret/marine/logisticsofficer
	name = "logistics officer beret"
	desc = "A beret with the lieutenant insignia emblazoned on it. It inspires a feeling of respect."
	icon_state = "hosberet"

//JUMPSUITS
/obj/item/clothing/under/marine
	name = "Marine jumpsuit" //<<<<<<<<<<<<<UNUSED
	desc = "An advanced Colonial Marine jumpsuit. Weaved with armored plates to protect against low-caliber rounds and light impacts.  Also contains a full array of sensors."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9
	has_sensor = 3
	sensor_mode = 3

/obj/item/clothing/under/marine_jumpsuit
	name = "USCM Uniform" //<<<<<<<<<<<<<USED BY MARINES
	desc = "The issue uniform for the USCM forces. It is weaved with light kevlar plates that protect against light impacts and light-caliber rounds."
	armor = list(melee = 5, bullet = 10, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)
	flags = FPRINT | TABLEPASS
	siemens_coefficient = 0.9
	icon_state = "marine_jumpsuit"
	item_state = "marine_jumpsuit"
	item_color = "marine_jumpsuit"
	has_sensor = 3
	sensor_mode = 3

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

/obj/item/clothing/under/rank/ro_suit
	name = "Requisition officer suit."
	desc = "A nicely-fitting military suit for a requisition officer."
	icon_state = "RO_jumpsuit"
	item_state = "RO_jumpsuit"
	item_color = "RO_jumpsuit"
	has_sensor = 1

/obj/item/clothing/under/marine/fluff/marinemedic
	name = "Marine Medic jumpsuit"
	desc = "A standard quilted Colonial Marine jumpsuit. Weaved with armored plates to protect against low-caliber rounds and light impacts. Has medical markings. "
	icon_state = "marine_medic"
	item_state = "marine_medic_s"
	item_color = "marine_medic"

/obj/item/clothing/under/marine/fluff/marineengineer
	name = "Marine Technician jumpsuit"
	desc = "A standard quilted Colonial Marine jumpsuit. Weaved with armored plates to protect against low-caliber rounds and light impacts. Has engineer markings. "
	icon_state = "marine_engineer"
	item_state = "marine_engineer_s"
	item_color = "marine_engineer"

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




//ARMOR
/obj/item/clothing/suit/storage/marine/fluff/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"

/obj/item/clothing/suit/storage/marine/fluff/cia
	name = "CIA jacket"
	desc = "An armored jacket with CIA on the back."
	icon_state = "cia"
	item_state = "cia"

/obj/item/clothing/suit/storage/marine/fluff/armorammo
	name = "marine armor w/ ammo"
	desc = "A marine combat vest with ammunition on it."
	icon_state = "bulletproofammo"
	item_state = "bulletproofammo"
	item_color = "bulletproofammo"

/obj/item/clothing/suit/storage/marine/officer
	name = "officer jacket"
	desc = "The leather is fake, but the style is real."
	armor = list(melee = 60, bullet = 90, laser = 60, energy = 20, bomb = 25, bio = 10, rad = 10)
	icon_state = "leatherjack"
	item_state = "leatherjack"
	item_color = "leatherjack"

/obj/item/clothing/suit/storage/marine/officer/commander
	name = "commander jacket"
	desc = "This single item cost as much as a brand new space station. Remember to drywash."
	armor = list(melee = 80, bullet = 90, laser = 60, energy = 60, bomb = 100, bio = 100, rad = 100)
	icon_state = "capjacket"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/storage/marine/officer/chief
	name = "chief officer coat"
	desc = "It has dried bloodstains all over. Or is that the fabric itself?"
	icon_state = "nazi"
	item_state = "nazi"

/obj/item/clothing/suit/storage/marine/officer/technical
	name = "tech officer coat"
	desc = "Made to resist high radiation, bio-hazards, explosions, and coffee spills."
	armor = list(melee = 10, bullet = 80, laser = 10, energy = 10, bomb = 100, bio = 100, rad = 100)
	icon_state = "johnny"
	item_state = "johnny"

/obj/item/clothing/suit/armor/riot/marine
	name = "M5 Riot Control Armor"
	desc = "A heavily modified suit of M2 MP Armor used to supress riots from buckethead marines. Slows you downa lot."
	icon_state = "riot"
	item_state = "swat_suit"
	slowdown = 3
	armor = list(melee = 70, bullet = 80, laser = 60, energy = 30, bomb = 35, bio = 10, rad = 10)

//GLOVES
/obj/item/clothing/gloves/marine
	name = "marine combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	icon_state = "gray"
	item_state = "graygloves"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = 200
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	body_parts_covered = HANDS
	armor = list(melee = 60, bullet = 50, laser = 20,energy = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/gloves/marine/alpha
	name = "alpha squad gloves"
	icon_state = "red"
	item_state = "redgloves"

/obj/item/clothing/gloves/marine/bravo
	name = "bravo squad gloves"
	icon_state = "yellow"
	item_state = "ygloves"

/obj/item/clothing/gloves/marine/charlie
	name = "charlie squad gloves"
	icon_state = "purple"
	item_state = "purplegloves"

/obj/item/clothing/gloves/marine/delta
	name = "delta squad gloves"
	icon_state = "blue"
	item_state = "bluegloves"

/obj/item/clothing/gloves/marine/officer
	name = "officer gloves"
	desc = "Shiny and impressive. They look expensive."
	icon_state = "black"
	item_state = "bgloves"

/obj/item/clothing/gloves/marine/officer/chief
	name = "chief officer gloves"
	desc = "Blood crusts are attached to its metal studs, which are slightly dented."

/obj/item/clothing/gloves/marine/techofficer
	name = "tech officer gloves"
	desc = "Sterile AND insulated! Why is not everyone issued with these?"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.01

/obj/item/clothing/gloves/marine/techofficer/commander
	name = "commander's gloves"
	desc = "You may like these gloves, but THEY think you are unworthy of them."
	icon_state = "captain"
	item_state = "egloves"

//SHOES
/obj/item/clothing/shoes/marine
	name = "marine combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	item_state = "jackboots"
	armor = list(melee = 60, bullet = 80, laser = 10,energy = 10, bomb = 10, bio = 10, rad = 0)
	body_parts_covered = FEET
	cold_protection = FEET
	min_cold_protection_temperature = 200
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.7
	var/obj/item/weapon/combat_knife/knife
	//flags = NOSLIP  Removed because it makes them not slip when there are breaches.
	var/armor_stage = 0

	//Knife slot
	attack_hand(var/mob/living/M)
		if(knife && src.loc == M && !M.stat) //Only allow someone to take out the knife if it's being worn or held. So you can pick them up off the floor
			knife.loc = get_turf(src)
			if(M.put_in_active_hand(knife))
				M << "<div class='notice'>You slide the [knife] out of [src].</div>"
				playsound(M, 'sound/weapons/shotgun_shell_insert.ogg', 40, 1)
				knife = 0
				update_icon()
			return
		..()

	attackby(var/obj/item/I, var/mob/living/M)
		if(istype(I, /obj/item/weapon/combat_knife))
			if(knife)	return
			M.drop_item()
			knife = I
			I.loc = src
			M << "<div class='notice'>You slide the [I] into [src].</div>"
			playsound(M, 'sound/weapons/shotgun_shell_insert.ogg', 40, 1)
			update_icon()

	update_icon()
		if(knife && !armor_stage)
			icon_state = "jackboots-1"
		else
			if(!armor_stage)
				icon_state = initial(icon_state)


/obj/item/clothing/shoes/marinechief
	name = "chief officer shoes"
	desc = "Only a small amount of monkeys, kittens, and orphans were killed in making this."
	icon_state = "laceups"
	armor = list(melee = 50, bullet = 90, laser = 50,energy = 50, bomb = 50, bio = 50, rad = 50)
	flags = NOSLIP
	siemens_coefficient = 0.6

/obj/item/clothing/shoes/marinechief/commander
	name = "commander shoes"
	desc = "Has special soles for better trampling those underneath."

//BACKPACK

/obj/item/weapon/storage/backpack/mcommander
	name = "marine commander backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"
	item_state = "marinepack" //Placeholder

/obj/item/weapon/storage/backpack/marine
	name = "USCM Infantry Backpack"
	desc = "The standard-issue backpack of the USCM forces."
	icon_state = "marinepack"
	item_state = "backpack"
	max_w_class = 3    //  Largest item that can be placed into the backpack
	max_combined_w_class = 21   //Capacity of the backpack

/obj/item/weapon/storage/backpack/smock
	name = "Sniper's Smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	item_state = "smock"
	max_w_class = 3
	max_combined_w_class = 21


/obj/item/weapon/storage/backpack/marine/medic
	name = "USCM Medic Backpack"
	desc = "The standard-issue backpack worn by USCM Medics."
	icon_state = "marinepack-medic"
	item_state = "marinepack-medic"

/obj/item/weapon/storage/backpack/marine/tech
	name = "USCM Technician Backpack"
	desc = "The standard-issue backpack worn by USCM Technicians."
	icon_state = "marinepack-tech"
	item_state = "marinepack-tech"

/obj/item/weapon/storage/backpack/marinesatchel
	name = "USCM Infantry Satchel"
	desc = "A heavy-duty satchel carried by some USCM soldiers."
	icon_state = "marinepack2"
	item_state = "marinepack2"
	max_w_class = 3    //  Largest item that can be placed into the backpack
	max_combined_w_class = 21   //Capacity of the backpack

/obj/item/weapon/storage/backpack/marinesatchel/medic
	name = "USCM Medic Satchel"
	desc = "A heavy-duty satchel carried by some USCM Medics."
	icon_state = "marinepack-medic2"
	item_state = "marinepack-medic"

/obj/item/weapon/storage/backpack/marinesatchel/tech
	name = "USCM Technician Satchel"
	desc = "A heavy-duty satchel carried by some USCM Technicians."
	icon_state = "marinepack-tech2"
	item_state = "marinepack-tech2"

//BELT

/obj/item/weapon/storage/belt/marine
	name = "marine belt"
	desc = "A standard issue toolbelt for USCM military forces. Put your ammo in here."
	icon_state = "marinebelt"
	item_state = "marine"//Could likely use a better one.
	w_class = 4
	storage_slots = 8
	max_combined_w_class = 9
	max_w_class = 3
	can_hold = list(
		"/obj/item/weapon/gun/pistol",
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/device/flash",
		"/obj/item/ammo_magazine",
		"/obj/item/flareround_s",
		"/obj/item/flareround_sp",
		"/obj/item/weapon/grenade",
		"/obj/item/device/mine",
		"/obj/item/weapon/melee/baton"
		)

/obj/item/weapon/storage/belt/security/MP
	name = "MP Belt"
	desc = "Can hold Military Police Equipment."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 7
	max_w_class = 3
	max_combined_w_class = 30
	can_hold = list(
		"/obj/item/weapon/grenade/flashbang",
		"/obj/item/weapon/reagent_containers/spray/pepper",
		"/obj/item/weapon/handcuffs",
		"/obj/item/device/flash",
		"/obj/item/clothing/glasses",
		"/obj/item/weapon/gun/taser",
		"/obj/item/weapon/gun/pistol",
		"/obj/item/weapon/melee/baton",
		"/obj/item/weapon/handcuffs",
		"/obj/item/weapon/combat_knife",
		"/obj/item/device/flashlight/flare",
		"/obj/item/ammo_magazine",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/normal",
		"/obj/item/weapon/reagent_containers/food/snacks/donut/jelly",
		"/obj/item/clothing/glasses/hud/security",
		"/obj/item/taperoll/police"
		)

/obj/item/weapon/storage/belt/security/MP/full/New()
	..()
	new /obj/item/weapon/gun/taser(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/melee/baton(src)
	new /obj/item/weapon/handcuffs(src)

/obj/item/weapon/storage/belt/marine/full/New()
	..()
	new /obj/item/weapon/gun/pistol/m4a3(src)
	new /obj/item/ammo_magazine/pistol(src)

/obj/item/weapon/storage/belt/knifepouch
	name="Knife Rig"
	desc="Storage for your sharp toys"
	icon_state="securitybelt" // temp
	item_state="security" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 3
	storage_slots = 3
	max_w_class = 1
	max_combined_w_class=3

	can_hold=list("/obj/item/weapon/throwing_knife")


/obj/item/weapon/storage/belt/grenade
	name="grenade bandolier"
	desc="Storage for your exploding toys."
	icon_state="grenadebelt" // temp
	item_state="security" // aslo temp, maybe somebody update these icons with better ones?
	w_class = 4
	storage_slots = 8
	max_w_class = 3
	max_combined_w_class = 24

	can_hold=list("/obj/item/weapon/grenade/explosive", "/obj/item/weapon/grenade/incendiary", "/obj/item/weapon/grenade/smokebomb","/obj/item/weapon/grenade/")

	New()
		..()
		spawn(1)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/incendiary(src)
			new /obj/item/weapon/grenade/explosive(src)
			new /obj/item/weapon/grenade/explosive(src)
			new /obj/item/weapon/grenade/explosive(src)
			new /obj/item/weapon/grenade/explosive(src)

/obj/item/weapon/storage/belt/knifepouch/New()
	..()
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)
	new /obj/item/weapon/throwing_knife(src)


/obj/item/clothing/head/cmbandana
	name = "USCM Bandana (Green)"
	desc = "Typically worn by heavy-weapon operators, mercenaries and scouts, the bandana serves as a lightweight and comfortable hat. Comes in two stylish colors."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "band"
	item_state = "band"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "band"
	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/cmbandana/tan
	name = "USCM Bandana (Tan)"
	icon_state = "band2"
	item_state = "band2"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "band2"
	flags = FPRINT|TABLEPASS|BLOCKHEADHAIR

/obj/item/clothing/head/cmberet
	name = "USCM Beret"
	desc = "A hat typically worn by the field-officers of the USCM. Occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "beret"
	item_state = "beret"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "beret"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/cmberet/tan
	icon_state = "berettan"
	item_state = "berettan"
	item_color = "berettan"

/obj/item/clothing/head/cmberet/red
	icon_state = "beretred"
	item_state = "beretred"
	item_color = "beretred"

/obj/item/clothing/head/headband
	name = "USCM Headband"
	desc = "A rag typically worn by the less-orthodox weapons operators in the USCM. While it offers no protection, it is certainly comfortable to wear compared to the standard helmet. Comes in two stylish colors."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "headband"
	item_state = "headband"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "headband"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/headband/red
	icon_state = "headbandred"
	item_state = "headbandred"
	item_color = "headbandred"

/obj/item/clothing/head/headset
	name = "USCM Headset"
	desc = "A headset typically found in use by radio-operators and officers. This one appears to be malfunctioning."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "headset"
	item_state = "headset"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "headset"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/cmcap
	name = "USCM Cap"
	desc = "A casual cap occasionally  worn by Squad-leaders and Combat-Engineers. While it has limited combat functionality, some prefer to wear it over the standard issue helmet."
	icon = 'icons/Marine/marine_armor.dmi'
	icon_state = "cap"
	item_state = "cap"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "cap"
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/cmcap/ro
	name = "USCM Officer Cap"
	desc = "A hat usually worn by officers in the USCM. While it has limited combat functionality, some prefer to wear it over the standard issue helmet."
	icon_state = "rocap"
	item_state = "rocap"
	item_color = "rocap"

/obj/item/clothing/head/cmcap/req
	name = "USCM Requisition Cap"
	desc = "A hat usually worn by officers in the USCM. While it has limited combat functionality, some prefer to wear it over the standard issue helmet."
	icon_state = "cargocap"
	item_state = "cargocap"
	item_color = "cargocap"

/obj/item/clothing/head/soft/ro_cap
	name = "Requisition officer cap"
	desc = "It's a fancy hat for a not-so-fancy military supply clerk."
	icon_state = "cargocap"
	item_state = "cargocap"
	icon_override = 'icons/Marine/marine_armor.dmi'
	item_color = "cargocap"

/obj/item/clothing/suit/storage/RO
	name = "RO Jacket"
	desc = "A green jacket worn by crew on the Sulaco. The back has the flag of the United Americas on it."
	icon_state = "RO_jacket"
	item_state = "RO_jacket"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/under/CM_uniform
	name = "Colonial Marshal Uniform"
	desc = "A blue shirt and tan trousers - the official uniform for a Colonial Marshal."
	icon_state = "marshal"
	item_state = "marshal"
	item_color = "marshal"
	armor = list(melee = 15, bullet = 25, laser = 15,energy = 5, bomb = 5, bio = 0, rad = 0)

/obj/item/clothing/under/colonist
	name = "Colonist Uniform"
	desc = "A stylish grey-green jumpsuit - standard issue for colonists."
	icon_state = "colonist"
	item_state = "colonist"
	item_color = "colonist"


