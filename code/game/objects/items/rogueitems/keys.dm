
/obj/item/roguekey
	name = "key"
	desc = ""
	icon_state = "iron"
	icon = 'icons/roguetown/items/keys.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 0.75
	throwforce = 0
	var/lockhash = 0
	var/lockid = null
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_MOUTH|ITEM_SLOT_NECK

/obj/item/roguekey/Initialize()
	. = ..()
	if(lockid)
		if(GLOB.lockids[lockid])
			lockhash = GLOB.lockids[lockid]
		else
			lockhash = rand(100,999)
			while(lockhash in GLOB.lockhashes)
				lockhash = rand(100,999)
			GLOB.lockhashes += lockhash
			GLOB.lockids[lockid] = lockhash
	else if(!lockhash)
		qdel(src)

/obj/item/roguekey/lord
	name = "master key"
	icon_state = "bosskey"
	lockid = "lord"

/obj/item/roguekey/lord/pre_attack(target, user, params)
	. = ..()
	if(istype(target, /obj/structure/closet))
		var/obj/structure/closet/C = target
		if(C.masterkey)
			lockhash = C.lockhash
	if(istype(target, /obj/structure/mineral_door))
		var/obj/structure/mineral_door/D = target
		if(D.masterkey)
			lockhash = D.lockhash


/obj/item/roguekey/manor
	name = "manor key"
	icon_state = "mazekey"
	lockid = "manor"

/obj/item/roguekey/garrison
	name = "town watch key"
	icon_state = "spikekey"
	lockid = "garrison"

/obj/item/roguekey/dungeon
	name = "dungeon key"
	icon_state = "rustkey"
	lockid = "dungeon"

/obj/item/roguekey/vault
	name = "vault key"
	icon_state = "cheesekey"
	lockid = "vault"

/obj/item/roguekey/sheriff
	name = "bailiff's key"
	icon_state = "cheesekey"
	lockid = "sheriff"

/obj/item/roguekey/merchant
	name = "merchant's key"
	icon_state = "cheesekey"
	lockid = "merchant"

/obj/item/roguekey/shop
	name = "shop key"
	icon_state = "ekey"
	lockid = "shop"

/obj/item/roguekey/tavern
	name = "tavern key"
	icon_state = "hornkey"
	lockid = "tavern"

/obj/item/roguekey/roomi
	name = "room I key"
	icon_state = "brownkey"
	lockid = "roomi"

/obj/item/roguekey/roomii
	name = "room II key"
	icon_state = "brownkey"
	lockid = "roomii"

/obj/item/roguekey/roomiii
	name = "room III key"
	icon_state = "brownkey"
	lockid = "roomiii"

/obj/item/roguekey/roomiv
	name = "room IV key"
	icon_state = "brownkey"
	lockid = "roomiv"

/obj/item/roguekey/roomv
	name = "room V key"
	icon_state = "brownkey"
	lockid = "roomv"

/obj/item/roguekey/roomvi
	name = "room VI key"
	icon_state = "brownkey"
	lockid = "roomvi"

/obj/item/roguekey/roomhunt
	name = "room HUNT key"
	icon_state = "brownkey"
	lockid = "roomhunt"

//vampire mansion//
/obj/item/roguekey/vampire
	name = "mansion key"
	icon_state = "vampkey"
	lockid = "mansionvampire"
//

/obj/item/roguekey/blacksmith
	name = "blacksmith key"
	icon_state = "brownkey"
	lockid = "blacksmith"

/obj/item/roguekey/walls
	name = "walls key"
	icon_state = "rustkey"
	lockid = "walls"

/obj/item/roguekey/church
	name = "church key"
	icon_state = "brownkey"
	lockid = "priest"

/obj/item/roguekey/priest
	name = "priest's key"
	icon_state = "cheesekey"
	lockid = "hpriest"

/obj/item/roguekey/tower
	name = "tower key"
	icon_state = "greenkey"
	lockid = "tower"

/obj/item/roguekey/mage
	name = "magicians's key"
	icon_state = "eyekey"
	lockid = "mage"

/obj/item/roguekey/graveyard
	name = "crypt key"
	icon_state = "rustkey"
	lockid = "graveyard"

/obj/item/roguekey/mason
	name = "mason's key"
	icon_state = "brownkey"
	lockid = "mason"

/obj/item/roguekey/nightman
	name = "nightmaster's key"
	icon_state = "greenkey"
	lockid = "nightman"

/obj/item/roguekey/nightmaiden
	name = "nightmaiden's key"
	icon_state = "brownkey"
	lockid = "nightmaiden"

/obj/item/roguekey/mercenary
	name = "mercenary key"
	icon_state = "greenkey"
	lockid = "merc"

/obj/item/roguekey/puritan
	name = "puritan's key"
	icon_state = "mazekey"
	lockid = "puritan"

/obj/item/roguekey/confession
	name = "confessional key"
	icon_state = "brownkey"
	lockid = "confession"

/obj/item/roguekey/hand
	name = "hand's key"
	icon_state = "cheesekey"
	lockid = "hand"

/obj/item/roguekey/steward
	name = "steward's key"
	icon_state = "cheesekey"
	lockid = "steward"

/obj/item/roguekey/archive
	name = "archive key"
	icon_state = "ekey"
	lockid = "archive"
//grenchensnacker
/obj/item/roguekey/porta
	name = "strange key"
	icon_state = "eyekey"
	lockid = "porta"
