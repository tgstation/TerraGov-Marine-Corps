/**********************Marine Gear**************************/
//STANDARD MARINE CLOSET
/obj/structure/closet/secure_closet/marine
	name = "marine's locker"
	req_access = list(ACCESS_MARINE_PREP)
	icon_state = "standard_locked"
	icon_closed = "standard_unlocked"
	icon_locked = "standard_locked"
	icon_opened = "squad_open"
	icon_broken = "standard_emmaged"
	icon_off = "standard_off"
	icon = 'icons/Marine/Marine_Lockers.dmi'

	New()
		spawn(5)
			new /obj/item/clothing/shoes/marine(src)

	select_gamemode_equipment(gamemode)
		new /obj/item/clothing/suit/storage/marine(src)
		new /obj/item/weapon/storage/belt/marine(src)
		new /obj/item/clothing/head/helmet/marine(src)
		new /obj/item/clothing/under/marine(src)
		switch(gamemode)
			if(/datum/game_mode/ice_colony)
				new /obj/item/clothing/mask/rebreather/scarf(src)
			if(/datum/game_mode/bigred)
				new /obj/item/clothing/mask/gas/(src)

//MARINE COMMAND CLOSET
/obj/structure/closet/secure_closet/marine/marine_commander
	name = "\improper marine Commander's locker"
	req_access = list(ACCESS_MARINE_COMMANDER)
	icon_state = "secure_locked_commander"
	icon_closed = "secure_unlocked_commander"
	icon_locked = "secure_locked_commander"
	icon_opened = "secure_open_commander"
	icon_broken = "secure_locked_commander"
	icon_off = "secure_closed_commander"
	icon = 'icons/obj/closet.dmi'


	New()
		spawn(2)
			new /obj/item/weapon/storage/backpack/mcommander(src)
			new /obj/item/clothing/shoes/marinechief/commander(src)
			new /obj/item/clothing/gloves/marine/techofficer/commander(src)
			new /obj/item/clothing/under/marine/officer/command(src)
//			new /obj/item/clothing/suit/storage/marine/officer/commander(src)
			new /obj/item/clothing/head/beret/marine/commander(src)
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/device/radio/headset/mcom(src)

	select_gamemode_equipment()

/obj/structure/closet/secure_closet/securecom
	name = "\improper Commander's secure box"
	req_access = list(ACCESS_MARINE_COMMANDER)
	desc = "You could probably get court-marshaled just by looking at this..."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"
	icon_locked = "largermetal"

/obj/structure/closet/secure_closet/marine/marine_lo
	name = "bridge officer's locker"
	req_access = list(ACCESS_MARINE_LOGISTICS)
	icon_state = "secure_locked_pilot"
	icon_closed = "secure_unlocked_pilot"
	icon_locked = "secure_locked_pilot"
	icon_opened = "secure_open_pilot"
	icon_broken = "secure_locked_pilot"
	icon_off = "secure_closed_pilot"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(2)
			new /obj/item/clothing/head/cmberet(src)
			new /obj/item/clothing/head/cmberet(src)
			new /obj/item/clothing/head/cmberet/tan(src)
			new /obj/item/clothing/head/cmberet/tan(src)
			new /obj/item/clothing/head/cmcap/ro(src)
			new /obj/item/clothing/head/cmcap/ro(src)
			new /obj/item/clothing/head/cmcap/ro(src)
			new /obj/item/device/radio/headset/mcom(src)
			new /obj/item/device/radio/headset/mcom(src)
			new /obj/item/clothing/under/marine/officer/logistics(src)
			new /obj/item/clothing/under/marine/officer/logistics(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/suit/storage/marine/MP/RO(src)
			new /obj/item/clothing/suit/storage/marine/MP/RO(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/weapon/storage/backpack/marine(src)

	select_gamemode_equipment()

/obj/structure/closet/secure_closet/marine/marine_pilot
	name = "/improper Pilot Officer's locker"
	req_access = list(ACCESS_MARINE_PILOT)
	icon_state = "secure_locked_pilot"
	icon_closed = "secure_unlocked_pilot"
	icon_locked = "secure_locked_pilot"
	icon_opened = "secure_open_pilot"
	icon_broken = "secure_locked_pilot"
	icon_off = "secure_closed_pilot"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(2)
			new /obj/item/clothing/head/helmet/marine/pilot(src)
			new /obj/item/device/radio/headset/mcom(src)
			new /obj/item/clothing/under/marine/officer/pilot(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/suit/armor/vest/pilot(src)
			new /obj/item/weapon/storage/belt/gun/m39(src)
			new /obj/item/weapon/storage/backpack/marine/satchel(src)
			new /obj/item/clothing/gloves/yellow(src)
			new /obj/item/clothing/glasses/sunglasses(src)

	select_gamemode_equipment()

/**********************Military Police Gear**************************/
/obj/structure/closet/secure_closet/marine/military_officer
	name = "military police's locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_police"
	icon_closed = "secure_unlocked_police"
	icon_locked = "secure_locked_police"
	icon_opened = "secure_open_police"
	icon_broken = "secure_broken_police"
	icon_off = "secure_closed_police"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(3)
			new /obj/item/clothing/head/cmberet/red(src)
			new /obj/item/clothing/head/cmberet/red(src)
			new /obj/item/clothing/tie/holster/armpit(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/under/marine/mp(src)
			new /obj/item/clothing/suit/armor/riot/marine(src)
			new /obj/item/clothing/head/helmet/riot(src)
			new /obj/item/weapon/storage/belt/security/MP(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/device/radio/headset/mmpo(src)
			new /obj/item/weapon/gun/energy/taser(src)
			new /obj/item/weapon/melee/baton(src)
			new /obj/item/weapon/storage/backpack/security (src)

	select_gamemode_equipment()

/obj/structure/closet/secure_closet/marine/warrant_officer
	name = "\improper Warrant Officer's locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_warrant"
	icon_closed = "secure_closed_warrant"
	icon_locked = "secure_locked_warrant"
	icon_opened = "secure_open_warrant"
	icon_broken = "secure_broken_warrant"
	icon_off = "secure_off_warrant"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(3)
			new /obj/item/clothing/head/cmberet/wo(src)
			new /obj/item/clothing/tie/holster/armpit(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/under/marine/officer/warrant(src)
			new /obj/item/clothing/suit/storage/marine/MP/WO(src)
			new /obj/item/weapon/storage/belt/security/MP(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/device/radio/headset/mcom(src)
			new /obj/item/weapon/gun/energy/taser(src)
			new /obj/item/weapon/melee/baton(src)
			new /obj/item/weapon/storage/backpack/security (src)

	select_gamemode_equipment()

/obj/structure/closet/secure_closet/marine/military_officer_spare
	name = "extra equipment locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_warrant"
	icon_closed = "secure_unlocked_warrant"
	icon_locked = "secure_locked_warrant"
	icon_opened = "secure_open_warrant"
	icon_broken = "secure_locked_warrant"
	icon_off = "secure_closed_warrant"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(3)
			new /obj/item/clothing/tie/holster/armpit(src)
			new /obj/item/weapon/storage/backpack/security(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/under/marine/mp(src)
			new /obj/item/clothing/suit/storage/marine/MP(src)
			new /obj/item/clothing/head/helmet/riot(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/device/radio/headset/mmpo(src)
			new /obj/item/clothing/gloves/black(src)
			new /obj/item/device/radio/headset/mmpo(src)
			new /obj/item/clothing/tie/holster/waist(src)

	select_gamemode_equipment()

//ALPHA EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_alpha_equipment
	name = "alpha equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA)
	icon_state = "squad_alpha_locked"
	icon_closed = "squad_alpha_unlocked"
	icon_locked = "squad_alpha_locked"
	icon_opened = "squad_alpha_open"
	icon_broken = "squad_alpha_emmaged"
	icon_off = "squad_alpha_off"

	New()
		..()
		spawn(5)
			new /obj/item/clothing/gloves/marine/alpha(src)
			new /obj/item/device/radio/headset/malpha(src)

//BRAVO EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_bravo_equipment
	name = "bravo equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_BRAVO)
	icon_state = "squad_bravo_locked"
	icon_closed = "squad_bravo_unlocked"
	icon_locked = "squad_bravo_locked"
	icon_opened = "squad_bravo_open"
	icon_broken = "squad_bravo_emmaged"
	icon_off = "squad_bravo_off"

	New()
		..()
		spawn(6)
			new /obj/item/clothing/gloves/marine/bravo(src)
			new /obj/item/device/radio/headset/mbravo(src)

//CHARLIE EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_charlie_equipment
	name = "charlie equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_CHARLIE)
	icon_state = "squad_charlie_locked"
	icon_closed = "squad_charlie_unlocked"
	icon_locked = "squad_charlie_locked"
	icon_opened = "squad_charlie_open"
	icon_broken = "squad_charlie_emmaged"
	icon_off = "squad_charlie_off"

	New()
		..()
		spawn(7)
			new /obj/item/clothing/gloves/marine/charlie(src)
			new /obj/item/device/radio/headset/mcharlie(src)

//DELTA EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_delta_equipment
	name = "delta equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DELTA)
	icon_state = "squad_delta_locked"
	icon_closed = "squad_delta_unlocked"
	icon_locked = "squad_delta_locked"
	icon_opened = "squad_delta_open"
	icon_broken = "squad_delta_emmaged"
	icon_off = "squad_delta_off"

	New()
		..()
		spawn(8)
			new /obj/item/clothing/gloves/marine/delta(src)
			new /obj/item/device/radio/headset/mdelta(src)

//SULACO MEDICAL CLOSET
/obj/structure/closet/secure_closet/marine/medical
	name = "\improper medical doctor's locker"
	req_access = list(ACCESS_MARINE_MEDBAY)
	icon_state = "secure_locked_medical"
	icon_closed = "secure_unlocked_medical"
	icon_locked = "secure_locked_medical"
	icon_opened = "secure_open_medical"
	icon_broken = "secure_broken_medical"
	icon_off = "secure_closed_medical"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(9)
			if(prob(50)) new /obj/item/weapon/storage/backpack/medic(src)
			else new /obj/item/weapon/storage/backpack/satchel_med(src)
			new /obj/item/clothing/under/rank/nursesuit (src)
			new /obj/item/clothing/head/nursehat (src)
			var/i = 0
			var/new_item_path
			while(++i <= 2)
				var/rand_color = pick("blue", "green", "purple")
				new_item_path = text2path("/obj/item/clothing/under/rank/medical/[rand_color]")
				new new_item_path(src)
				new_item_path = text2path("/obj/item/clothing/head/surgery/[rand_color]")
				new new_item_path(src)
			new /obj/item/clothing/under/rank/medical(src)
			new /obj/item/clothing/under/rank/nurse(src)
			new /obj/item/clothing/under/rank/orderly(src)
			new /obj/item/clothing/suit/storage/labcoat(src)
			new /obj/item/clothing/suit/storage/fr_jacket(src)
			new /obj/item/clothing/shoes/white(src)
			if(z != 1) new /obj/item/device/radio/headset/headset_med(src)
			new /obj/item/weapon/storage/belt/medical(src)
			new /obj/item/clothing/glasses/hud/health(src)

	select_gamemode_equipment(gamemode)
		switch(gamemode)
			if(/datum/game_mode/ice_colony)
				new /obj/item/clothing/suit/storage/snow_suit/doctor(src)
				new /obj/item/clothing/mask/rebreather/scarf(src)
			if(/datum/game_mode/bigred)
				new /obj/item/clothing/mask/gas/(src)

//MARINE SUPPLY CRATES APOPHIS775 15JAN2015

//Meh.
/*
/obj/structure/closet/crate/large/marine/gear
	name = "Marine Gear"
	desc = "A crate containing standard issue Marine gear for 5 marines"
	New()
		..()
		for(var/c, c<5, c++)
			new /obj/item/clothing/under/marine(src)
			new /obj/item/clothing/head/helmet/marine(src)
			new /obj/item/clothing/suit/storage/marine(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/weapon/storage/backpack/marine(src)
		return


/obj/structure/closet/crate/plastic/marine/alpha
	name = "Alpha Supply Crate"
	desc = "A crate with additional Alpha Squad Supplies"
	New()
		..()
		for(var/c, c<10, c++)
			new /obj/item/clothing/gloves/marine/alpha(src)
			new /obj/item/device/radio/headset/malpha(src)
		new /obj/item/device/radio/headset/malphal(src)
		return

/obj/structure/closet/crate/plastic/marine/bravo
	name = "Bravo Supply Crate"
	desc = "A crate with additional Bravo Squad Supplies"
	New()
		..()
		for(var/c, c<5, c++)
			new /obj/item/clothing/gloves/marine/bravo(src)
			new /obj/item/device/radio/headset/mbravo(src)
		new /obj/item/device/radio/headset/mbravol(src)
		return

/obj/structure/closet/crate/plastic/marine/charlie
	name = "Charlie Supply Crate"
	desc = "A crate with additional Charlie Squad Supplies"
	New()
		..()
		for(var/c, c<5, c++)
			new /obj/item/clothing/gloves/marine/charlie(src)
			new /obj/item/device/radio/headset/mcharlie(src)
		new /obj/item/device/radio/headset/mcharliel(src)
		return

/obj/structure/closet/crate/plastic/marine/delta
	name = "Delta Supply Crate"
	desc = "A crate with additional Delta Squad Supplies"
	New()
		..()
		for(var/c, c<5, c++)
			new /obj/item/clothing/gloves/marine/delta(src)
			new /obj/item/device/radio/headset/mdelta(src)
		new /obj/item/device/radio/headset/mdeltal(src)
		return

/obj/structure/closet/crate/plastic/marine/REBEL
	name = "REBEL Supply Crate"
	desc = "A crate with additional REBEL ALLIANCE Supplies"
	New()
		..()
		for(var/c, c<5, c++)
			new /obj/item/clothing/under/color/grey(src)
			new /obj/item/clothing/head/helmet/swat(src)
			new /obj/item/clothing/suit/armor/vest(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/weapon/storage/belt/utility/full(src)
			new /obj/item/device/multitool(src)
			new /obj/item/weapon/storage/backpack(src)
		return
*/

/obj/structure/closet/secure_closet/req_officer
	name = "\improper RO's extra locker"
	req_access = list(ACCESS_MARINE_CARGO)
	icon_state = "securecargo1"
	icon_closed = "securecargo"
	icon_locked = "securecargo1"
	icon_opened = "securecargoopen"
	icon_broken = "securecargobroken"
	icon_off = "securecargooff"

	New()
		spawn(2)
			new /obj/item/device/radio/headset/mcom(src)
			new /obj/item/clothing/under/rank/ro_suit(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/clothing/head/cmcap/req(src)
			new /obj/item/clothing/head/helmet/marine(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/weapon/gun/energy/taser(src)
			new /obj/item/weapon/melee/baton(src)
			new /obj/item/weapon/storage/backpack/marine(src)
