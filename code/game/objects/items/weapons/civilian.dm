/obj/item/weapon/ice_axe
	name = "ice axe"
	desc = "a multi-purpose hiking and climbing tool used by mountaineers in icy conditions, or disgruntled colonists on icy planets."
	//icon_state = "spearglass"
	//worn_icon_state = "spearglass"
	force = 50
	penetration = 15
	attack_speed = 13
	w_class = WEIGHT_CLASS_NORMAL
	equip_slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	edge = TRUE
	sharp = IS_SHARP_ITEM_BIG
	atom_flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacks", "stabs", "jabs", "tears", "gores", "cuts")

/obj/item/weapon/axe
	name = "axe"
	desc = "Some kind of axe. Looks more medieval than a modern tool, it could definitely do some damage."
	//icon_state = "spearglass"
	//worn_icon_state = "spearglass"
	force = 65
	attack_speed = 9
	w_class = WEIGHT_CLASS_BULKY
	equip_slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	edge = TRUE
	sharp = IS_SHARP_ITEM_BIG
	atom_flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("chops", "attacks", "slashes", "stabs", "jabs", "slices", "tears", "gores", "rips", "dices", "cuts")

/obj/item/weapon/tire_iron
	name = "tire iron"
	desc = "A tire iron. You can change a tire with this, if you're not bashing someone's head in."
	//icon_state = "spearglass"
	//worn_icon_state = "spearglass"
	force = 50
	attack_speed = 9
	w_class = WEIGHT_CLASS_NORMAL
	equip_slot_flags = ITEM_SLOT_BELT
	atom_flags = CONDUCT
	//hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("smashes", "attacks", "bashes", "thrashes", "smacks", "beats", "brutalises", "bludgeon", "pummels")

/obj/item/weapon/tire_iron/pipe
	name = "metal pipe"
	desc = "A hefty metal pipe. A basic, if dangerous makeshift weapon."
	//icon_state = "spearglass"
	//worn_icon_state = "spearglass"

/obj/item/weapon/brass_knuckle
	name = "brass knuckle"
	desc = "A brass knuckle. For a spicier fist sandwich."
	//icon_state = "spearglass"
	//worn_icon_state = "spearglass"
	force = 30
	attack_speed = CLICK_CD_MELEE //same as punching
	w_class = WEIGHT_CLASS_SMALL
	equip_slot_flags = ITEM_SLOT_BELT
	atom_flags = CONDUCT
	//hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("punches", "smashes", "attacks", "bashes", "thrashes", "smacks", "beats", "brutalises", "bludgeon", "pummels")
