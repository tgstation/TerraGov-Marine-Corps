/obj/item/loot_box
	name = "Blackmarket loot box"
	desc = "A box of loot, what could be inside?"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lootbox"
	item_state = "lootbox"
	///list of the lowest probability drops
	var/list/legendary_list
	///list of rare propability drops
	var/list/rare_list
	///list of uncommon drops
	var/list/uncommon_list
	///list of common drops
	var/list/common_list
	///the odds of each loot category being picked
	var/list/weight_list = list(legendary_list = 10, rare_list = 20, uncommon_list = 30, common_list = 40)

/obj/item/loot_box/ex_act()
	qdel(src)

/obj/item/loot_box/attack_self(mob/user)
	var/obj/loot_pick
	switch(pickweight(weight_list))
		if("legendary_list")
			loot_pick = pick(legendary_list)
		if("rare_list")
			loot_pick = pick(rare_list)
		if("uncommon_list")
			loot_pick = pick(uncommon_list)
		if("common_list")
			loot_pick = pick(common_list)
	loot_pick = new loot_pick(get_turf(user))
	if(isitem(loot_pick))
		user.put_in_hands(loot_pick)
	user.visible_message("[user] pulled a [loot_pick.name] out of the [src]!")
	qdel(src)

/obj/item/loot_box/marine
	legendary_list = list(
		/obj/item/weapon/karambit,
		/obj/item/weapon/karambit/fade,
		/obj/item/weapon/karambit/case_hardened,
	)
	rare_list = list(
		/obj/vehicle/unmanned,
		/obj/item/weapon/gun/rifle/sniper/antimaterial,
		/obj/item/weapon/gun/rifle/tx8,
		/obj/item/weapon/gun/minigun,
		/obj/item/weapon/gun/launcher/rocket/sadar,
		/obj/item/weapon/gun/rifle/railgun,
		/obj/item/weapon/gun/rifle/standard_autosniper,
		/obj/item/weapon/gun/shotgun/zx76,
		/obj/item/storage/belt/champion,
	)
	uncommon_list = list(
		/obj/item/weapon/gun/revolver/mateba,
		/obj/item/storage/fancy/crayons,
		/obj/item/weapon/claymore,
		/obj/vehicle/ridden/motorbike,
		/obj/item/weapon/gun/launcher/rocket/oneuse,
		/obj/item/weapon/gun/rifle/m412l1_hpr,
		/obj/item/weapon/gun/shotgun/som,
		/obj/item/loot_box/marine, //reroll time
	)
	common_list = list(
		/obj/item/clothing/head/strawhat,
		/obj/item/storage/bag/trash,
		/obj/item/toy/bikehorn,
		/obj/item/clothing/tie/horrible,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/weapon/banhammer,
	)

// 150 to 200 points of value packs, spend 100 points get 150 to 200 in value, basically. Ideally, commons are variety packs, uncommons maybe shake up the round a bit, rares a bit more. Legendaries make the round go wacko. You get a crate of stuff dropped on spawn.

/obj/item/loot_box/tgmclootbox
	name = "TGMC pack box"
	desc = "A box of gear sent over by the TGMC on request, nobody knows whats in it. You just know it'll probably be good."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lootbox"
	item_state = "lootbox"

	legendary_list = list(
	/obj/item/storage/box/loot/operator_pack,
	/obj/item/storage/box/loot/heavy_pack,
	/obj/item/storage/box/loot/b18classic_pack,
	/obj/item/storage/box/loot/sadarclassic_pack,
	)
	rare_list = list(
		/obj/item/storage/box/loot/tl102_pack,
		/obj/item/storage/box/loot/mortar_pack,
		/obj/item/storage/box/loot/howitzer_pack,
	)
	uncommon_list = list(
		/obj/item/storage/box/loot/materials_pack,
		/obj/item/storage/box/loot/railgun_pack,
		/obj/item/storage/box/loot/scoutrifle_pack,
		/obj/item/storage/box/loot/recoilless_pack,
	)
	common_list = list(
		/obj/item/storage/box/loot/autosniper_pack,
		/obj/item/storage/box/loot/thermobaric_pack,
		/obj/item/storage/box/loot/tesla_pack,
		/obj/item/storage/box/loot/tx54_pack,
	)

// Crates the lootbox uses.

/obj/item/storage/box/loot
	name = "\improper generic equipment"
	desc = "A large case containing some kind of equipment. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = "smartgun_case"
	w_class = WEIGHT_CLASS_HUGE
	storage_slots = 21
	can_hold = list() // Holds absolutely nothing after you take it out.
	foldable = null

/obj/item/storage/box/loot/Initialize()
	. = ..()
	new /obj/item/weapon/banhammer(src)

// Common

/obj/item/storage/box/loot/autosniper_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/standard_autosniper(src)
	new /obj/item/weapon/gun/rifle/standard_autosniper(src)
	new /obj/item/weapon/gun/rifle/standard_autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src)
	new /obj/item/ammo_magazine/rifle/autosniper(src) //180 total and common, fine considering 3 autos is really strong.

/obj/item/storage/box/loot/thermobaric_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/m57a4/t57(src)
	new /obj/item/weapon/gun/launcher/rocket/m57a4/t57(src)
	new /obj/item/weapon/gun/launcher/rocket/m57a4/t57(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src)
	new /obj/item/ammo_magazine/rocket/m57a4(src) // three launchers and 10 arrays. Common. 200.

/obj/item/storage/box/loot/tesla_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/energy/lasgun/lasrifle/tesla(src)
	new /obj/item/weapon/gun/energy/lasgun/lasrifle/tesla(src)
	new /obj/item/weapon/gun/energy/lasgun/lasrifle/tesla(src) // 180 and nothing else. Have fun.

/obj/item/storage/box/loot/tx54_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/tx54(src)
	new /obj/item/weapon/gun/rifle/tx54(src)
	new /obj/item/weapon/gun/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54(src)
	new /obj/item/ammo_magazine/rifle/tx54/he(src)
	new /obj/item/ammo_magazine/rifle/tx54/he(src)
	new /obj/item/ammo_magazine/rifle/tx54/he(src)
	new /obj/item/ammo_magazine/rifle/tx54/he(src)
	new /obj/item/ammo_magazine/rifle/tx54/he(src)
	new /obj/item/ammo_magazine/rifle/tx54/he(src)

// Uncommon

/obj/item/storage/box/loot/materials_pack/Initialize()
	. = ..()
	new /obj/item/stack/sheet/plasteel/large_stack(src)
	new /obj/item/stack/sheet/plasteel/large_stack(src)
	new /obj/item/stack/sheet/metal/large_stack(src)
	new /obj/item/stack/sheet/metal/large_stack(src)
	new /obj/item/stack/sheet/metal/large_stack(src)
	new /obj/item/stack/sheet/metal/large_stack(src)
	new /obj/item/stack/sandbags_empty/full(src)
	new /obj/item/stack/sandbags_empty/full(src)
	new /obj/item/stack/sandbags_empty/full(src)
	new /obj/item/stack/sandbags_empty/full(src)

/obj/item/storage/box/loot/recoilless_pack/Initialize()
	. = ..()
	new /obj/item/storage/holster/backholster/rpg/full(src)
	new /obj/item/storage/holster/backholster/rpg/full(src)
	new /obj/item/storage/holster/backholster/rpg/full(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heat(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heat(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heat(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heat(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heat(src)
	new /obj/item/ammo_magazine/rocket/recoilless/heat(src)

/obj/item/storage/box/loot/railgun_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/railgun(src)
	new /obj/item/weapon/gun/rifle/railgun(src)
	new /obj/item/weapon/gun/rifle/railgun(src)
	new /obj/item/ammo_magazine/railgun/smart(src)
	new /obj/item/ammo_magazine/railgun/smart(src)
	new /obj/item/ammo_magazine/railgun/smart(src)
	new /obj/item/ammo_magazine/railgun/smart(src)
	new /obj/item/ammo_magazine/railgun/hvap(src)
	new /obj/item/ammo_magazine/railgun/hvap(src)
	new /obj/item/ammo_magazine/railgun/hvap(src)
	new /obj/item/ammo_magazine/railgun/hvap(src)
	new /obj/item/ammo_magazine/railgun(src)
	new /obj/item/ammo_magazine/railgun(src)
	new /obj/item/ammo_magazine/railgun(src)
	new /obj/item/ammo_magazine/railgun(src)

/obj/item/storage/box/loot/scoutrifle_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/tx8(src)
	new /obj/item/weapon/gun/rifle/tx8(src)
	new /obj/item/weapon/gun/rifle/tx8(src)
	new /obj/item/ammo_magazine/packet/scout_rifle(src)
	new /obj/item/ammo_magazine/packet/scout_rifle(src)
	new /obj/item/ammo_magazine/packet/scout_rifle(src)
	new /obj/item/ammo_magazine/packet/scout_rifle(src)
	new /obj/item/ammo_magazine/rifle/tx8
	new /obj/item/ammo_magazine/rifle/tx8
	new /obj/item/ammo_magazine/rifle/tx8
	new /obj/item/ammo_magazine/rifle/tx8
	new /obj/item/ammo_magazine/rifle/tx8
	new /obj/item/ammo_magazine/rifle/tx8


// Rares

/obj/item/storage/box/loot/mortar_pack/Initialize()
	. = ..()
	new /obj/item/mortar_kit(src)
	new /obj/item/mortar_kit(src)
	new /obj/item/mortar_kit(src)
	new /obj/item/mortar_kit(src)
	new /obj/item/mortar_kit(src)

/obj/item/storage/box/loot/howitzer_pack/Initialize()
	. = ..()
	new /obj/item/mortar_kit/howitzer(src)
	new /obj/item/mortar_kit/howitzer(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)

/obj/item/storage/box/loot/tl102_pack/Initialize()
	. = ..()
	new /obj/item/storage/box/tl102(src)
	new /obj/item/storage/box/tl102(src)

/obj/item/storage/box/loot/sentry_pack/Initialize()
	. = ..()
	new /obj/item/storage/box/sentry(src)
	new /obj/item/storage/box/sentry(src)
	new /obj/item/storage/box/sentry(src)
	new /obj/item/storage/box/minisentry(src)

// Legendaries

/obj/item/storage/box/loot/operator_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/rifle/m412/elite
	new /obj/item/ammo_magazine/rifle
	new /obj/item/ammo_magazine/rifle
	new /obj/item/ammo_magazine/rifle
	new /obj/item/ammo_magazine/rifle
	new /obj/item/clothing/glasses/night/tx8

/obj/item/storage/box/loot/b18classic_pack/Initialize()
	. = ..()
	new /obj/item/clothing/suit/storage/marine/specialist(src)
	new /obj/item/clothing/head/helmet/marine/specialist(src)
	new /obj/item/clothing/gloves/marine/specialist(src)
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)

/obj/item/storage/box/loot/heavy_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/weapon/gun/minigun(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/ammo_magazine/minigun_powerpack(src)
	new /obj/item/armor_module/module/tyr_extra_armor(src)
	new /obj/item/armor_module/module/tyr_extra_armor(src)

/obj/item/storage/box/loot/sadarclassic_pack/Initialize()
	. = ..()
	new /obj/item/weapon/gun/launcher/rocket/sadar(src)
	new /obj/item/storage/backpack/marine/satchel/scout_cloak/scout(src)
	new /obj/item/ammo_magazine/rocket/sadar/ap(src)
