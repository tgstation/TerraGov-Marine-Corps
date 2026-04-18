/obj/item/weapon/ice_axe
	name = "ice axe"
	desc = "a multi-purpose hiking and climbing tool used by mountaineers and disgruntled colonists in icy conditions."
	icon_state = "ice_pick"
	worn_icon_state = "ice_pick"
	icon = 'icons/obj/items/weapons/civilian.dmi'
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
	desc = "Some kind of large, menacing hatchet. Looks more medieval than a modern tool, it could definitely do some damage."
	icon_state = "hatchet_broad"
	worn_icon_state = "hatchet_broad"
	icon = 'icons/obj/items/weapons/civilian.dmi'
	force = 65
	throwforce = 50
	attack_speed = 9
	w_class = WEIGHT_CLASS_BULKY
	equip_slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	edge = TRUE
	sharp = IS_SHARP_ITEM_BIG
	atom_flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("chops", "attacks", "slashes", "stabs", "jabs", "slices", "tears", "gores", "rips", "dices", "cuts", "hacks")

/obj/item/weapon/cleaver
	name = "cleaver"
	desc = "A big cleaver used for hacking apart meat and bone."
	icon_state = "cleaver"
	worn_icon_state = "hatchet_broad"
	icon = 'icons/obj/items/weapons/civilian.dmi'
	force = 55
	throwforce = 50
	attack_speed = 9
	equip_slot_flags = ITEM_SLOT_BELT
	edge = TRUE
	sharp = IS_SHARP_ITEM_BIG
	atom_flags = CONDUCT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("cleaves", "chops", "attacks", "slashes", "slices", "tears", "gores", "rips", "dices", "cuts", "hacks")

/obj/item/weapon/pipe
	name = "metal pipe"
	desc = "A hefty metal pipe. Looks good for hitting things."
	icon_state = "lead_pipe"
	worn_icon_state = "lead_pipe"
	icon = 'icons/obj/items/weapons/civilian.dmi'
	force = 50
	attack_speed = 10
	w_class = WEIGHT_CLASS_NORMAL
	equip_slot_flags = ITEM_SLOT_BELT
	atom_flags = CONDUCT
	attack_verb = list("smashes", "attacks", "bashes", "thrashes", "smacks", "beats", "brutalises", "bludgeon", "pummels")

/obj/item/weapon/pipe/alt
	icon_state = "lead_pipe_alt"
	worn_icon_state = "lead_pipe_alt"

/obj/item/weapon/pipe/tire_iron
	name = "tire iron"
	desc = "A tire iron. You can change a tire with this, if you're not bashing heads in."
	icon_state = "tire_iron"
	worn_icon_state = "tire_iron"

/obj/item/weapon/brass_knuckle
	name = "brass knuckle"
	desc = "A brass knuckle. For a spicier fist sandwich."
	icon_state = "knuckles"
	worn_icon_state = "knuckles"
	icon = 'icons/obj/items/weapons/civilian.dmi'
	force = 18
	attack_speed = CLICK_CD_UNARMED //same as punching
	w_class = WEIGHT_CLASS_SMALL
	equip_slot_flags = ITEM_SLOT_BELT
	atom_flags = CONDUCT
	hitsound = SFX_PUNCH
	attack_verb = list("punches", "smashes", "attacks", "bashes", "thrashes", "smacks", "beats", "brutalises", "bludgeon", "pummels")

/obj/item/weapon/brass_knuckle/weighted
	name = "weighted brass knuckle"
	desc = "A brass knuckle. This one feels extra heavy."
	icon_state = "knuckles_weighted"
	worn_icon_state = "knuckles_weighted"
	force = 25
	attack_speed = CLICK_CD_MELEE

/obj/item/weapon/brass_knuckle/spiked
	name = "spiked brass knuckle"
	desc = "A brass knuckle. This one has wicked sharp metal spikes attached."
	icon_state = "knuckles_spike"
	worn_icon_state = "knuckles_spike"
	force = 25
	sharp = IS_SHARP_ITEM_SIMPLE
