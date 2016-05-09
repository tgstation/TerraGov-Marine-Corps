/**********************Marine Gear**************************/
//STANDARD MARINE CLOSET
/obj/structure/closet/secure_closet/marine
	name = "Marine's Locker"
	req_access = list(access_marine_prep)
	icon_state = "standard_locked"
	icon_closed = "standard_unlocked"
	icon_locked = "standard_locked"
	icon_opened = "squad_open"
	icon_broken = "standard_emmaged"
	icon_off = "standard_off"
	icon = 'icons/Marine/Marine_Lockers.dmi'
	special_equipment = 1

	New()
		spawn(5)
			new /obj/item/clothing/suit/storage/marine(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/clothing/head/helmet/marine(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/under/marine_jumpsuit(src)
		return

	select_gamemode_equipment(gamemode = "")
		if(special_equipment)
			switch(gamemode)
				if("Ice colony")
					new /obj/item/clothing/under/marine_jumpsuit/snow(src)
					new /obj/item/clothing/head/helmet/marine/snow(src)
					new /obj/item/clothing/suit/storage/marine/snow(src)
					new /obj/item/clothing/mask/rebreather/scarf(src)

				else
					new /obj/item/clothing/under/marine_jumpsuit(src)
					new /obj/item/clothing/head/helmet/marine(src)
					new /obj/item/clothing/suit/storage/marine(src)



//MARINE COMMAND CLOSET
/obj/structure/closet/secure_closet/marine/marine_commander
	name = "Marine Commander's Locker"
	req_access = list(access_sulaco_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"
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

/obj/structure/closet/secure_closet/securecom
	name = "Commander's Secure Box"
	req_access = list(access_sulaco_captain)
	desc = "You could probably get court-marshaled just by looking at this..."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largermetal"
	icon_opened = "largermetalopen"
	icon_closed = "largermetal"
	icon_locked = "largermetal"

/obj/structure/closet/secure_closet/marine/marine_lo
	name = "Bridge Officer's Locker"
	req_access = list(access_sulaco_logistics)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"
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

/**********************Military Police Gear**************************/
/obj/structure/closet/secure_closet/marine/military_officer
	name = "Military Police's Locker"
	req_access = list(access_sulaco_brig)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"
	icon = 'icons/obj/closet.dmi'

	New()
		spawn(3)
			new /obj/item/clothing/tie/holster/armpit(src)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/under/marine/mp(src)
			new /obj/item/clothing/suit/armor/riot/marine(src)
			new /obj/item/clothing/head/helmet/riot(src)
			new /obj/item/weapon/storage/belt/security/MP(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/device/radio/headset/mmpo(src)
			new /obj/item/weapon/gun/taser(src)
			new /obj/item/weapon/melee/baton(src)
			new /obj/item/weapon/storage/backpack/marine(src)



/obj/structure/closet/secure_closet/marine/military_officer_spare
	name = "Extra Equipment Locker"
	req_access = list(access_sulaco_brig)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"
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

//ALPHA EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_alpha_equipment
	name = "Alpha Equipment Locker"
	req_access = list(access_marine_prep, access_squad_alpha)
	icon_state = "squad_alpha_locked"
	icon_closed = "squad_alpha_unlocked"
	icon_locked = "squad_alpha_locked"
	icon_opened = "squad_open"
	icon_broken = "squad_alpha_emmaged"
	icon_off = "squad_alpha_off"

	New()
		spawn(5)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/gloves/marine/alpha(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/device/radio/headset/malpha(src)


//BRAVO EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_bravo_equipment
	name = "Bravo Equipment Locker"
	req_access = list(access_marine_prep, access_squad_bravo)
	icon_state = "squad_bravo_locked"
	icon_closed = "squad_bravo_unlocked"
	icon_locked = "squad_bravo_locked"
	icon_opened = "squad_open"
	icon_broken = "squad_bravo_emmaged"
	icon_off = "squad_bravo_off"

	New()
		spawn(6)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/gloves/marine/bravo(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/device/radio/headset/mbravo(src)



//CHARLIE EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_charlie_equipment
	name = "Charlie Equipment Locker"
	req_access = list(access_marine_prep, access_squad_charlie)
	icon_state = "squad_charlie_locked"
	icon_closed = "squad_charlie_unlocked"
	icon_locked = "squad_charlie_locked"
	icon_opened = "squad_open"
	icon_broken = "squad_charlie_emmaged"
	icon_off = "squad_charlie_off"

	New()
		spawn(7)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/gloves/marine/charlie(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/device/radio/headset/mcharlie(src)


//DELTA EQUIPMENT CLOSET
/obj/structure/closet/secure_closet/marine/marine_delta_equipment
	name = "Delta Equipment Locker"
	req_access = list(access_marine_prep, access_squad_delta)
	icon_state = "squad_delta_locked"
	icon_closed = "squad_delta_unlocked"
	icon_locked = "squad_delta_locked"
	icon_opened = "squad_open"
	icon_broken = "squad_delta_emmaged"
	icon_off = "squad_delta_off"

	New()
		spawn(8)
			new /obj/item/clothing/shoes/marine(src)
			new /obj/item/clothing/gloves/marine/delta(src)
			new /obj/item/weapon/storage/belt/marine(src)
			new /obj/item/device/radio/headset/mdelta(src)


//SULACO MEDICAL CLOSET
/obj/structure/closet/secure_closet/marine/medical
	name = "Sulaco Medical Doctor's Locker"
	req_access = list(access_sulaco_medbay)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"
	icon = 'icons/obj/closet.dmi'
	special_equipment = 1

	select_gamemode_equipment(gamemode = "")
		if(special_equipment)
			switch(gamemode)
				if("Ice colony")
					new /obj/item/clothing/under/marine_jumpsuit/snow(src)
					new /obj/item/clothing/head/helmet/marine/snow(src)
					new /obj/item/clothing/suit/storage/snow_suit/doctor(src)
					new /obj/item/clothing/mask/rebreather/scarf(src)

	New()
		spawn(9)
			if(prob(50))
				new /obj/item/weapon/storage/backpack/medic(src)
			else
				new /obj/item/weapon/storage/backpack/satchel_med(src)
			new /obj/item/clothing/under/rank/nursesuit (src)
			new /obj/item/clothing/head/nursehat (src)
			switch(pick("blue", "green", "purple"))
				if ("blue")
					new /obj/item/clothing/under/rank/medical/blue(src)
					new /obj/item/clothing/head/surgery/blue(src)
				if ("green")
					new /obj/item/clothing/under/rank/medical/green(src)
					new /obj/item/clothing/head/surgery/green(src)
				if ("purple")
					new /obj/item/clothing/under/rank/medical/purple(src)
					new /obj/item/clothing/head/surgery/purple(src)
			switch(pick("blue", "green", "purple"))
				if ("blue")
					new /obj/item/clothing/under/rank/medical/blue(src)
					new /obj/item/clothing/head/surgery/blue(src)
				if ("green")
					new /obj/item/clothing/under/rank/medical/green(src)
					new /obj/item/clothing/head/surgery/green(src)
				if ("purple")
					new /obj/item/clothing/under/rank/medical/purple(src)
					new /obj/item/clothing/head/surgery/purple(src)
			new /obj/item/clothing/under/rank/medical(src)
			new /obj/item/clothing/under/rank/nurse(src)
			new /obj/item/clothing/under/rank/orderly(src)
			new /obj/item/clothing/suit/storage/labcoat(src)
			new /obj/item/clothing/suit/storage/fr_jacket(src)
			new /obj/item/clothing/shoes/white(src)
			if(z && (z == 3 || z == 4))
				new /obj/item/device/radio/headset/headset_med(src)
			new /obj/item/weapon/storage/belt/medical(src)
			new /obj/item/clothing/glasses/hud/health(src)


//MARINE SUPPLY CRATES APOPHIS775 15JAN2015

//Meh.
/*
/obj/structure/closet/crate/large/marine/gear
	name = "Marine Gear"
	desc = "A crate containing standard issue Marine gear for 5 marines"
	New()
		..()
		for(var/c, c<5, c++)
			new /obj/item/clothing/under/marine_jumpsuit(src)
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
	name = "RO's Extra Locker"
	req_access = list(access_sulaco_cargo)
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
			new /obj/item/weapon/storage/belt/marine/full(src)
			new /obj/item/clothing/head/soft/ro_cap(src)
			new /obj/item/clothing/head/helmet/marine(src)
			new /obj/item/device/flashlight(src)
			new /obj/item/weapon/gun/taser(src)
			new /obj/item/weapon/melee/baton(src)
			new /obj/item/weapon/storage/backpack/marine(src)
