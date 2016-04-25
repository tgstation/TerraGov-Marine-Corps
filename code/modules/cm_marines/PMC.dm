
//PMC Grunt gear

/obj/item/clothing/under/marine_jumpsuit/PMC
	name = "PMC uniform"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit."
	icon = 'icons/PMC/PMC.dmi'
	//icon_override = 'icons/PMC/PMC.dmi'
	icon_state = "pmc_jumpsuit"
	item_state = "armor"
	item_color = "pmc_jumpsuit"
	//	armor = list(melee = 20, bullet = 20, laser = 0,energy = 0, bomb = 10, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/marine/PMCarmor
	name = "M4 Pattern PMC Armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "armor"
	icon_state = "pmc_armor"

/obj/item/clothing/mask/gas/PMCmask
	name = "M8 Pattern Armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "helmet"
	icon_state = "pmc_mask"
	anti_hug = 3

/obj/item/clothing/head/helmet/marine/PMC
	name = "PMC tactical cap"
	desc = "A protective cap made from flexable kevlar. Standard issue for most security forms in the place of a helmet."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "helmet"
	icon_state = "pmc_hat"
	armor = list(melee = 30, bullet = 30, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)

//PMC Officer gear

/obj/item/clothing/under/marine_jumpsuit/PMC/leader
	name = "PMC command uniform"
	desc = "A white set of fatigues, designed for private security operators. The symbol of the Weyland-Yutani corporation is emblazed on the suit. This particular suit looks like it belongs to a high-ranking officer."
	item_state = "officer_jumpsuit"
	item_color = "officer_jumpsuit"

/obj/item/clothing/suit/storage/marine/PMCarmor/leader
	name = "M4 Pattern PMC Armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "officer_armor"

/obj/item/clothing/mask/gas/PMCmask/leader
	name = "M8 Pattern Armored balaclava"
	desc = "An armored balaclava designed to conceal both the identity of the operator and act as an air-filter. This particular suit looks like it belongs to a high-ranking officer."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "officer_mask"
	icon_state = "officer_mask"

/obj/item/clothing/head/helmet/marine/PMC/leader
	name = "PMC Beret"
	desc = "The pinacle of fashion for any aspiring mercenary leader. Designed to protect the head from light impacts."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "officer_hat"
	icon_state = "officer_hat"
	anti_hug = 3

/obj/item/weapon/grenade/explosive/PMC
	desc = "A fragmentation grenade produced for private security firms. It explodes 3 seconds after the pin has been pulled."
	icon = 'icons/obj/grenade2.dmi'
	icon_state = "grenade_ex"
	item_state = "grenade_ex"


	prime()
		spawn(0)
			explosion(src.loc,-1,-1,3)
			del(src)
		return

//headset
/obj/item/device/radio/headset/syndicate/PMC
	name = "Weyland Yutani headset"
	desc = "A headset used by Weyland Yutani field operatives"
	keyslot2 = new /obj/item/device/encryptionkey/syndicate/WY
	//frequency = 1468

//encryption key
/obj/item/device/encryptionkey/syndicate/WY
	name = "Weyland Yutani Encryption Key"
	desc = "An encyption key for a radio headset.  Contains cypherkeys."


/obj/item/clothing/under/rank/chef/exec
	name = "Weyland Yutani suit"
	desc = "A formal white undersuit."

/obj/item/clothing/under/marine_jumpsuit/PMC/commando
	name = "PMC Commando Uniform"
	desc = "An armored uniform worn by Weyland Yutani elite commandos."
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_jumpsuit"
	item_state = "commando_jumpsuit"
	item_color = "commando_jumpsuit"
	armor = list(melee = 10, bullet = 10, laser = 0,energy = 20, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/marine/PMCarmor/commando
	name = "PMC Commando Armor"
	desc = "A heavily armored suit built by a subsidiary of Weyland Yutani for elite commandos. It is a fully self-contained system and is heavily corrosion resistant."
	icon = 'icons/PMC/PMC.dmi'
	item_state = "commando_armor"
	icon_state = "commando_armor"
	icon_override = 'icons/PMC/PMC.dmi'
	armor = list(melee = 90, bullet = 90, laser = 70,energy = 90, bomb = 90, bio = 100, rad = 100)

/obj/item/clothing/head/helmet/marine/PMC/commando
	name = "PMC Commando Helmet"
	desc = "A fully enclosed, armored helmet made for Weyland Yutani elite commandos."
	item_state = "commando_helmet"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_helmet"
	icon_override = 'icons/PMC/PMC.dmi'
	armor = list(melee = 90, bullet = 90, laser = 70,energy = 90, bomb = 90, bio = 100, rad = 100)
	anti_hug = 6

/obj/item/clothing/shoes/PMC
	name = "PMC Commando Boots"
	icon = 'icons/PMC/PMC.dmi'
	icon_state = "commando_boots"
	icon_override = 'icons/PMC/PMC.dmi'
	desc = "A pair of heavily armored, acid-resistant boots."
	permeability_coefficient = 0.01
	flags = NOSLIP
	body_parts_covered = FEET|LEGS
	armor = list(melee = 90, bullet = 90, laser = 50,energy = 15, bomb = 50, bio = 30, rad = 30)
	siemens_coefficient = 0.2
	cold_protection = FEET
	heat_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/marine_smartgun_armor/heavypmc
	name = "PMC Gunner Armor"
	desc = "A modification of the standard Armat Systems M3 armor. Hooked up with harnesses and straps allowing the user to carry an M56 Smartgun."
	icon = 'icons/PMC/PMC.dmi'
	icon_override = 'icons/PMC/PMC.dmi'
	item_state = "heavy_armor"
	icon_state = "heavy_armor"
	item_color = "bear_jumpsuit"
	armor = list(melee = 85, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)

/obj/item/clothing/head/helmet/marine/PMC/heavypmc
	name = "PMC Gunner Helmet"
	desc = "A modification of the standard Armat Systems M3 armor."
	item_state = "heavy_helmet"
	icon_state = "heavy_helmet"
	flags = FPRINT|TABLEPASS|HEADCOVERSMOUTH|BLOCKHEADHAIR
	anti_hug = 4
	armor = list(melee = 80, bullet = 85, laser = 55,energy = 65, bomb = 70, bio = 10, rad = 10)
