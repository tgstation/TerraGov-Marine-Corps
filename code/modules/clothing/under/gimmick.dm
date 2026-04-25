
/obj/item/clothing/under/gimmick
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
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
	worn_icon_state = "jason_jacket"
	soft_armor = list(MELEE = 13, BULLET = 13, LASER = 13, ENERGY = 13, BOMB = 13, BIO = 13, FIRE = 13, ACID = 13)

//RAMBO
/obj/item/clothing/under/gimmick/rambo
	name = "combat pants"
	desc = "The only thing a man needs when he's up agains the world."
	icon_state = "rambo_suit"
	armor_protection_flags = LEGS|GROIN
	cold_protection_flags = LEGS|GROIN
	heat_protection_flags = LEGS|GROIN

/obj/item/clothing/suit/gimmick/rambo
	name = "pendant"
	desc = "It's a precious stone and something of a talisman of protection."
	armor_protection_flags = CHEST
	cold_protection_flags = CHEST
	heat_protection_flags = CHEST
	icon_state = "rambo_pendant"

//MCCLANE
/obj/item/clothing/under/gimmick/mcclane
	name = "holiday attire"
	desc = "The perfect outfit for a Christmas holiday with family. Shoes not included."
	icon_state = "mcclane_suit"
	armor_protection_flags = CHEST|GROIN|LEGS
	cold_protection_flags = CHEST|GROIN|LEGS
	heat_protection_flags = CHEST|GROIN|LEGS

//DUTCH
/obj/item/clothing/under/gimmick/dutch
	name = "combat fatigues"
	desc = "Just another pair of military fatigues for a grueling tour in a jungle."
	icon_state = "dutch_suit"
	armor_protection_flags = LEGS|GROIN
	cold_protection_flags = LEGS|GROIN
	heat_protection_flags = LEGS|GROIN

/obj/item/clothing/suit/armor/gimmick/dutch
	name = "armored jacket"
	desc = "It's hot in the jungle. Sometimes it's hot and heavy, and sometimes it's hell on earth."
	icon_state = "dutch_armor"
	armor_protection_flags = CHEST
	cold_protection_flags = CHEST
	heat_protection_flags = CHEST
	soft_armor = list(MELEE = 45, BULLET = 45, LASER = 35, ENERGY = 25, BOMB = 25, BIO = 0, FIRE = 25, ACID = 25)
	allowed = list(
		/obj/item/weapon/gun,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/attachable/bayonet,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/holster/blade,
	)

//ROBOCOP
/obj/item/clothing/under/gimmick/robocop
	name = "metal body"
	desc = "It may be metallic, but it contains the heart and soul of Alex J. Murphy."
	icon_state = "robocop_suit"
	atom_flags = CONDUCT

/obj/item/clothing/shoes/gimmick/robocop
	name = "polished metal boots"
	desc = "The perfect size to stomp on the scum of Detroit."
	icon_state = "robocop_shoes"
	soft_armor = list(MELEE = 87, BULLET = 87, LASER = 87, ENERGY = 87, BOMB = 87, BIO = 50, FIRE = 87, ACID = 87)
	inventory_flags = CONDUCT|NOSLIPPING

/obj/item/clothing/gloves/gimmick/robocop
	name = "metal hands"
	desc = "The cold, unfeeling hands of the law."
	icon_state = "black"
	atom_flags = CONDUCT
	soft_armor = list(MELEE = 87, BULLET = 87, LASER = 87, ENERGY = 87, BOMB = 87, BIO = 50, FIRE = 87, ACID = 87)

/obj/item/clothing/head/helmet/gimmick/robocop
	name = "polished metal helm"
	desc = "The impersonal face of the law. Constructed from titanium and laminated with kevlar."
	icon_state = "robocop_helmet"
	worn_icon_state = "robocop_helmet"
	soft_armor = list(MELEE = 87, BULLET = 87, LASER = 87, ENERGY = 87, BOMB = 87, BIO = 50, FIRE = 87, ACID = 87)
	inventory_flags = COVEREYES|BLOCKSHARPOBJ
	inv_hide_flags = HIDEEARS|HIDEEYES|HIDETOPHAIR
	anti_hug = 100

/obj/item/clothing/suit/armor/gimmick/robocop
	name = "polished metal armor"
	desc = "Clean and well maintained, unlike the ugly streets of Detroit. Constructed from titanium and laminated with kevlar."
	icon_state = "robocop_armor"
	worn_icon_state = "robocop_armor"
	slowdown = 1
	atom_flags = CONDUCT
	inventory_flags = BLOCKSHARPOBJ
	armor_protection_flags = CHEST|GROIN|ARMS|LEGS
	cold_protection_flags = CHEST|GROIN|ARMS|LEGS
	heat_protection_flags = CHEST|GROIN|ARMS|LEGS
	allowed = list(/obj/item/weapon/gun/pistol/auto9)
	soft_armor = list(MELEE = 87, BULLET = 87, LASER = 87, ENERGY = 87, BOMB = 87, BIO = 50, FIRE = 87, ACID = 87)

//LUKE
/obj/item/clothing/under/gimmick/skywalker
	name = "black jumpsuit"
	desc = "A simple, utilitarian jumpsuit worn by one who has mastered the force."
	icon_state = "skywalker_suit"

/obj/item/clothing/shoes/gimmick/skywalker
	name = "black boots"
	desc = "Perfectly functional, this pair of boots has stomped on many planets and starships."
	icon_state = "skywalker_shoes"
	inventory_flags = NOSLIPPING

/obj/item/clothing/gloves/gimmick/skywalker
	name = "black glove"
	desc = "Something to cover up that artificial hand... Who says heroes can't be self-conscious?"
	icon_state = "skywalker_gloves"



/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	worn_icon_state = "dg_suit"

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	worn_icon_state = "g_suit"
