
/obj/item/clothing/under/gimmick
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 10, bomb = 10, bio = 10, rad = 10)
	has_sensor = 0
	displays_id = 0

//JASON
/obj/item/clothing/under/gimmick/jason
	name = "dirty work attire"
	desc = "Perfect thing to wear when digging graves."
	icon_state = "jason_suit"

/obj/item/clothing/mask/gimmick/jason
	name = "hockey mask"
	desc = "It smells like teenage spirit."
	icon_state = "jason_mask"
	anti_hug = 100

/obj/item/clothing/suit/gimmick/jason
	name = "musty jacket"
	desc = "A killer fashion statement."
	icon_state = "jason_jacket"
	item_state = "jason_jacket"
	armor = list(melee = 13, bullet = 13, laser = 13, energy = 13, bomb = 13, bio = 13, rad = 13)

//RAMBO
/obj/item/clothing/under/gimmick/rambo
	name = "combat pants"
	desc = "The only thing a man needs when he's up agains the world."
	icon_state = "rambo_suit"
	flags_armor_protection = LEGS|LOWER_TORSO
	flags_cold_protection = LEGS|LOWER_TORSO
	flags_heat_protection = LEGS|LOWER_TORSO

/obj/item/clothing/suit/gimmick/rambo
	name = "pendant"
	desc = "It's a precious stone and something of a talisman of protection."
	flags_armor_protection = UPPER_TORSO
	flags_cold_protection = UPPER_TORSO
	flags_heat_protection = UPPER_TORSO
	icon_state = "rambo_pendant"

//MCCLANE
/obj/item/clothing/under/gimmick/mcclane
	name = "holiday attire"
	desc = "The perfect outfit for a Christmas holiday with family. Shoes not included."
	icon_state = "mcclane_suit"
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS

//DUTCH
/obj/item/clothing/under/gimmick/dutch
	name = "combat fatigues"
	desc = "Just another pair of military fatigues for a grueling tour in a jungle."
	icon_state = "dutch_suit"
	flags_armor_protection = LEGS|LOWER_TORSO
	flags_cold_protection = LEGS|LOWER_TORSO
	flags_heat_protection = LEGS|LOWER_TORSO

/obj/item/clothing/suit/armor/gimmick/dutch
	name = "armored jacket"
	desc = "It's hot in the jungle. Sometimes it's hot and heavy, and sometimes it's hell on earth."
	icon_state = "dutch_armor"
	flags_armor_protection = UPPER_TORSO
	flags_cold_protection = UPPER_TORSO
	flags_heat_protection = UPPER_TORSO
	armor = list(melee = 45, bullet = 45, laser = 35, energy = 25, bomb = 25, bio = 0, rad = 0)
	allowed = list(
			/obj/item/weapon/gun,
			/obj/item/device/flashlight,
			/obj/item/ammo_magazine/,
			/obj/item/storage/fancy/cigarettes,
			/obj/item/tool/lighter,
			/obj/item/explosive/grenade,
			/obj/item/device/binoculars,
			/obj/item/weapon/combat_knife,
			/obj/item/storage/sparepouch,
			/obj/item/storage/large_holster/machete)

//ROBOCOP
/obj/item/clothing/under/gimmick/robocop
	name = "metal body"
	desc = "It may be metallic, but it contains the heart and soul of Alex J. Murphy."
	icon_state = "robocop_suit"
	flags_atom = CONDUCT

/obj/item/clothing/shoes/gimmick/robocop
	name = "polished metal boots"
	desc = "The perfect size to stomp on the scum of Detroit."
	icon_state = "robocop_shoes"
	armor = list(melee = 87, bullet = 87, laser = 87, energy = 87, bomb = 87, bio = 50, rad = 50)
	flags_inventory = CONDUCT|NOSLIPPING

/obj/item/clothing/gloves/gimmick/robocop
	name = "metal hands"
	desc = "The cold, unfeeling hands of the law."
	icon_state = "robocop_gloves"
	flags_atom = CONDUCT
	armor = list(melee = 87, bullet = 87, laser = 87,energy = 87, bomb = 87, bio = 50, rad = 50)

/obj/item/clothing/head/helmet/gimmick/robocop
	name = "polished metal helm"
	desc = "The impersonal face of the law. Constructed from titanium and laminated with kevlar."
	icon_state = "robocop_helmet"
	item_state = "robocop_helmet"
	armor = list(melee = 87, bullet = 87, laser = 87, energy = 87, bomb = 87, bio = 50, rad = 50)
	flags_inventory = COVEREYES|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDETOPHAIR
	anti_hug = 100

/obj/item/clothing/suit/armor/gimmick/robocop
	name = "polished metal armor"
	desc = "Clean and well maintained, unlike the ugly streets of Detroit. Constructed from titanium and laminated with kevlar."
	icon_state = "robocop_armor"
	item_state = "robocop_armor"
	slowdown = 1
	flags_atom = CONDUCT
	flags_inventory = BLOCKSHARPOBJ
	flags_armor_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	allowed = list(/obj/item/weapon/gun/pistol/auto9)
	armor = list(melee = 87, bullet = 87, laser = 87, energy = 87, bomb = 87, bio = 50, rad = 50)

//LUKE
/obj/item/clothing/under/gimmick/skywalker
	name = "black jumpsuit"
	desc = "A simple, utilitarian jumpsuit worn by one who has mastered the force."
	icon_state = "skywalker_suit"

/obj/item/clothing/shoes/gimmick/skywalker
	name = "black boots"
	desc = "Perfectly functional, this pair of boots has stomped on many planets and starships."
	icon_state = "skywalker_shoes"
	flags_inventory = NOSLIPPING

/obj/item/clothing/gloves/gimmick/skywalker
	name = "black glove"
	desc = "Something to cover up that artificial hand... Who says heroes can't be self-conscious?"
	icon_state = "skywalker_gloves"



/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "g_suit"
