/**********************Marine Gear**************************/
//MARINE CLOSETS
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
	var/closet_squad //which squad this closet belong to

	New()
		..()
		new /obj/item/clothing/shoes/marine(src)

		if(closet_squad)
			icon_state = "squad_[closet_squad]_locked"
			icon_closed = "squad_[closet_squad]_unlocked"
			icon_locked = "squad_[closet_squad]_locked"
			icon_opened = "squad_[closet_squad]_open"
			icon_broken = "squad_[closet_squad]_emmaged"
			icon_off = "squad_[closet_squad]_off"

	select_gamemode_equipment(gamemode)
		switch(map_tag)
			if(MAP_ICE_COLONY)
				new /obj/item/clothing/mask/rebreather/scarf(src)


// STANDARD MARINE

/obj/structure/closet/secure_closet/marine/standard
	select_gamemode_equipment(gamemode)
		..()
		new /obj/item/clothing/suit/storage/marine(src)
		new /obj/item/storage/belt/marine(src)
		new /obj/item/clothing/head/helmet/marine(src)
		new /obj/item/clothing/under/marine(src)

/obj/structure/closet/secure_closet/marine/standard/alpha
	name = "alpha equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA)
	closet_squad = "alpha"

	New()
		..()
		new /obj/item/device/radio/headset/almayer/marine/alpha(src)
		new /obj/item/clothing/gloves/marine/alpha(src)

/obj/structure/closet/secure_closet/marine/standard/bravo
	name = "bravo equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_BRAVO)
	closet_squad = "bravo"

	New()
		..()
		new /obj/item/device/radio/headset/almayer/marine/bravo(src)
		new /obj/item/clothing/gloves/marine/bravo(src)

/obj/structure/closet/secure_closet/marine/standard/charlie
	name = "charlie equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_CHARLIE)
	closet_squad = "charlie"

	New()
		..()
		new /obj/item/device/radio/headset/almayer/marine/charlie(src)
		new /obj/item/clothing/gloves/marine/charlie(src)

/obj/structure/closet/secure_closet/marine/standard/delta
	name = "delta equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DELTA)
	closet_squad = "delta"

	New()
		..()
		new /obj/item/device/radio/headset/almayer/marine/delta(src)
		new /obj/item/clothing/gloves/marine/delta(src)


// MARINE LEADER

/obj/structure/closet/secure_closet/marine/leader
	select_gamemode_equipment(gamemode)
		..()
		new /obj/item/clothing/suit/storage/marine/leader(src)
		new /obj/item/storage/belt/marine(src)
		new /obj/item/clothing/head/helmet/marine/leader(src)
		new /obj/item/clothing/under/marine(src)

/obj/structure/closet/secure_closet/marine/leader/alpha
	name = "alpha leader equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_LEADER)
	closet_squad = "alpha"

	New()
		..()
		new /obj/item/clothing/gloves/marine/alpha(src)
		new /obj/item/device/radio/headset/almayer/marine/alpha/lead(src)

/obj/structure/closet/secure_closet/marine/leader/bravo
	name = "bravo leader equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_BRAVO, ACCESS_MARINE_LEADER)
	closet_squad = "bravo"

	New()
		..()
		new /obj/item/clothing/gloves/marine/bravo(src)
		new /obj/item/device/radio/headset/almayer/marine/bravo/lead(src)

/obj/structure/closet/secure_closet/marine/leader/charlie
	name = "charlie leader equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_LEADER)
	closet_squad = "charlie"

	New()
		..()
		new /obj/item/clothing/gloves/marine/charlie(src)
		new /obj/item/device/radio/headset/almayer/marine/charlie/lead(src)

/obj/structure/closet/secure_closet/marine/leader/delta
	name = "delta leader equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DELTA, ACCESS_MARINE_LEADER)
	closet_squad = "delta"

	New()
		..()
		new /obj/item/clothing/gloves/marine/delta(src)
		new /obj/item/device/radio/headset/almayer/marine/delta/lead(src)



// MARINE ENGINEER

/obj/structure/closet/secure_closet/marine/engi
	slotlocked = 1
	slotlocktype = "engi"
	health = 100000 // just no

	New()
		..()
		new /obj/item/storage/belt/utility/full(src)
		new /obj/item/clothing/glasses/welding(src)
		new /obj/item/clothing/tie/storage/webbing(src)

	select_gamemode_equipment(gamemode)
		..()
		new /obj/item/clothing/suit/storage/marine(src)
		new /obj/item/clothing/head/helmet/marine/tech(src)
		new /obj/item/clothing/under/marine/engineer(src)

/obj/structure/closet/secure_closet/marine/engi/alpha
	name = "alpha engineer equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_ENGPREP)
	closet_squad = "alpha"

	New()
		..()
		new /obj/item/clothing/gloves/marine/alpha/insulated(src)
		new /obj/item/device/radio/headset/almayer/marine/alpha/engi(src)

/obj/structure/closet/secure_closet/marine/engi/bravo
	name = "bravo engineer equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_BRAVO, ACCESS_MARINE_ENGPREP)
	closet_squad = "bravo"

	New()
		..()
		new /obj/item/clothing/gloves/marine/bravo/insulated(src)
		new /obj/item/device/radio/headset/almayer/marine/bravo/engi(src)

/obj/structure/closet/secure_closet/marine/engi/charlie
	name = "charlie engineer equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_ENGPREP)
	closet_squad = "charlie"

	New()
		..()
		new /obj/item/clothing/gloves/marine/charlie/insulated(src)
		new /obj/item/device/radio/headset/almayer/marine/charlie/engi(src)

/obj/structure/closet/secure_closet/marine/engi/delta
	name = "delta engineer equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DELTA, ACCESS_MARINE_ENGPREP)
	closet_squad = "delta"

	New()
		..()
		new /obj/item/clothing/gloves/marine/delta/insulated(src)
		new /obj/item/device/radio/headset/almayer/marine/delta/engi(src)



// MARINE MEDIC
/obj/structure/closet/secure_closet/marine/medic
	slotlocked = 1
	slotlocktype = "medic"
	health = 100000 // just no

	New()
		..()
		new /obj/item/storage/belt/combatLifesaver(src)
		new /obj/item/clothing/glasses/hud/health(src)
		new /obj/item/clothing/tie/storage/webbing(src)
		new /obj/item/roller/medevac(src)
		new /obj/item/device/defibrillator(src)

	select_gamemode_equipment(gamemode)
		..()
		new /obj/item/clothing/suit/storage/marine(src)
		new /obj/item/clothing/head/helmet/marine/medic(src)
		new /obj/item/clothing/under/marine/medic(src)

/obj/structure/closet/secure_closet/marine/medic/alpha
	name = "alpha medic equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_MEDPREP)
	closet_squad = "alpha"

	New()
		..()
		new /obj/item/clothing/gloves/marine/alpha(src)
		new /obj/item/device/radio/headset/almayer/marine/alpha/med(src)

/obj/structure/closet/secure_closet/marine/medic/bravo
	name = "bravo medic equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_BRAVO, ACCESS_MARINE_MEDPREP)
	closet_squad = "bravo"

	New()
		..()
		new /obj/item/clothing/gloves/marine/bravo(src)
		new /obj/item/device/radio/headset/almayer/marine/bravo/med(src)

/obj/structure/closet/secure_closet/marine/medic/charlie
	name = "charlie medic equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_MEDPREP)
	closet_squad = "charlie"

	New()
		..()
		new /obj/item/clothing/gloves/marine/charlie(src)
		new /obj/item/device/radio/headset/almayer/marine/charlie/med(src)

/obj/structure/closet/secure_closet/marine/medic/delta
	name = "delta medic equipment locker"
	req_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DELTA, ACCESS_MARINE_MEDPREP)
	closet_squad = "delta"

	New()
		..()
		new /obj/item/clothing/gloves/marine/delta(src)
		new /obj/item/device/radio/headset/almayer/marine/delta/med(src)







//MARINE COMMAND CLOSET
/obj/structure/closet/secure_closet/commander
	name = "commander's locker"
	req_access = list(ACCESS_MARINE_COMMANDER)
	icon_state = "secure_locked_commander"
	icon_closed = "secure_unlocked_commander"
	icon_locked = "secure_locked_commander"
	icon_opened = "secure_open_commander"
	icon_broken = "secure_locked_commander"
	icon_off = "secure_closed_commander"

	New()
		..()
		new /obj/item/storage/backpack/mcommander(src)
		new /obj/item/clothing/shoes/marinechief/commander(src)
		new /obj/item/clothing/gloves/marine/techofficer/commander(src)
		new /obj/item/clothing/under/marine/officer/command(src)
		new /obj/item/clothing/head/beret/marine/commander(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/device/radio/headset/almayer/mcom(src)

/obj/structure/closet/secure_closet/securecom
	name = "commander's secure box"
	req_access = list(ACCESS_MARINE_COMMANDER)
	desc = "You could probably get court-marshaled just by looking at this..."
	icon = 'icons/Marine/Marine_Lockers.dmi'
	icon_state = "commander_safe"
	icon_opened = "commander_safe_open"
	icon_closed = "commander_safe"
	icon_locked = "commander_safe"

/obj/structure/closet/secure_closet/staff_officer
	name = "staff officer's locker"
	req_access = list(ACCESS_MARINE_LOGISTICS)
	icon_state = "secure_locked_staff"
	icon_closed = "secure_unlocked_staff"
	icon_locked = "secure_locked_staff"
	icon_opened = "secure_open_staff"
	icon_broken = "secure_locked_staff"
	icon_off = "secure_closed_staff"

	New()
		..()
		new /obj/item/clothing/head/cmberet(src)
		new /obj/item/clothing/head/cmberet(src)
		new /obj/item/clothing/head/cmberet/tan(src)
		new /obj/item/clothing/head/cmberet/tan(src)
		new /obj/item/clothing/head/cmcap/ro(src)
		new /obj/item/clothing/head/cmcap/ro(src)
		new /obj/item/clothing/head/cmcap/ro(src)
		new /obj/item/device/radio/headset/almayer/mcom(src)
		new /obj/item/device/radio/headset/almayer/mcom(src)
		new /obj/item/clothing/under/marine/officer/bridge(src)
		new /obj/item/clothing/under/marine/officer/bridge(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/clothing/suit/storage/marine/MP/RO(src)
		new /obj/item/clothing/suit/storage/marine/MP/RO(src)
		new /obj/item/storage/belt/marine(src)
		new /obj/item/storage/belt/marine(src)
		new /obj/item/storage/backpack/marine(src)

/obj/structure/closet/secure_closet/pilot_officer
	name = "pilot officer's locker"
	req_access = list(ACCESS_MARINE_PILOT)
	icon_state = "secure_locked_pilot"
	icon_closed = "secure_unlocked_pilot"
	icon_locked = "secure_locked_pilot"
	icon_opened = "secure_open_pilot"
	icon_broken = "secure_locked_pilot"
	icon_off = "secure_closed_pilot"

	New()
		..()
		new /obj/item/clothing/head/helmet/marine/pilot(src)
		new /obj/item/device/radio/headset/almayer/mcom(src)
		new /obj/item/clothing/under/marine/officer/pilot(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/clothing/suit/armor/vest/pilot(src)
		new /obj/item/storage/large_holster/m39(src)
		new /obj/item/storage/backpack/marine/satchel(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/glasses/sunglasses(src)

	select_gamemode_equipment(gamemode)
		switch(map_tag)
			if(MAP_ICE_COLONY)
				new /obj/item/clothing/mask/rebreather/scarf(src)
				new /obj/item/clothing/mask/rebreather/scarf(src)

/**********************Military Police Gear**************************/
/obj/structure/closet/secure_closet/military_police
	name = "military police's locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_police"
	icon_closed = "secure_unlocked_police"
	icon_locked = "secure_locked_police"
	icon_opened = "secure_open_police"
	icon_broken = "secure_broken_police"
	icon_off = "secure_closed_police"

	New()
		..()
		new /obj/item/clothing/head/cmberet/red(src)
		new /obj/item/clothing/head/cmberet/red(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/clothing/tie/holster/armpit(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/clothing/under/marine/mp(src)
		new /obj/item/storage/belt/security/MP(src)
		new /obj/item/device/flashlight(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/device/radio/headset/almayer/mmpo(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/weapon/baton(src)
		new /obj/item/storage/backpack/security (src)

/obj/structure/closet/secure_closet/warrant_officer
	name = "chief MP's locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_warrant"
	icon_closed = "secure_unlocked_warrant"
	icon_locked = "secure_locked_warrant"
	icon_opened = "secure_open_warrant"
	icon_broken = "secure_locked_warrant"
	icon_off = "secure_closed_warrant"

	New()
		..()
		new /obj/item/clothing/head/cmberet/wo(src)
		new /obj/item/clothing/tie/holster/armpit(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/clothing/under/marine/officer/warrant(src)
		new /obj/item/clothing/suit/storage/marine/MP/WO(src)
		new /obj/item/storage/belt/security/MP(src)
		new /obj/item/device/flashlight(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/device/radio/headset/almayer/mcom(src)
		new /obj/item/weapon/gun/energy/taser(src)
		new /obj/item/weapon/baton(src)
		new /obj/item/storage/backpack/security (src)

/obj/structure/closet/secure_closet/military_officer_spare
	name = "extra equipment locker"
	req_access = list(ACCESS_MARINE_BRIG)
	icon_state = "secure_locked_warrant"
	icon_closed = "secure_unlocked_warrant"
	icon_locked = "secure_locked_warrant"
	icon_opened = "secure_open_warrant"
	icon_broken = "secure_locked_warrant"
	icon_off = "secure_closed_warrant"

	New()
		..()
		new /obj/item/clothing/tie/holster/armpit(src)
		new /obj/item/storage/backpack/security(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/clothing/under/marine/mp(src)
		new /obj/item/clothing/suit/storage/marine/MP(src)
		new /obj/item/clothing/head/helmet/riot(src)
		new /obj/item/device/flashlight(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/device/radio/headset/almayer/mmpo(src)
		new /obj/item/clothing/gloves/black(src)
		new /obj/item/device/radio/headset/almayer/mmpo(src)
		new /obj/item/clothing/tie/holster/waist(src)

//ALMAYER MEDICAL CLOSET
/obj/structure/closet/secure_closet/medical_doctor
	name = "medical doctor's locker"
	req_access = list(ACCESS_MARINE_MEDBAY)
	icon_state = "secure_locked_medical"
	icon_closed = "secure_unlocked_medical"
	icon_locked = "secure_locked_medical"
	icon_opened = "secure_open_medical"
	icon_broken = "secure_broken_medical"
	icon_off = "secure_closed_medical"

	New()
		..()
		new /obj/item/storage/backpack/marine/satchel(src)
		if(z != 1) new /obj/item/device/radio/headset/almayer/doc(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/storage/belt/medical(src)
		new /obj/item/clothing/under/rank/medical/green(src)
		new /obj/item/clothing/under/rank/medical/green(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/head/surgery/green(src)
		new /obj/item/clothing/glasses/hud/health(src)

	select_gamemode_equipment(gamemode)
		switch(map_tag)
			if(MAP_ICE_COLONY)
				new /obj/item/clothing/suit/storage/snow_suit/doctor(src)
				new /obj/item/clothing/mask/rebreather/scarf(src)



//ALAMAYER CARGO CLOSET
/obj/structure/closet/secure_closet/req_officer
	name = "\improper RO's Locker"
	req_access = list(ACCESS_MARINE_RO)
	icon_state = "secure_locked_cargo"
	icon_closed = "secure_unlocked_cargo"
	icon_locked = "secure_locked_cargo"
	icon_opened = "secure_open_cargo"
	icon_broken = "secure_broken_cargo"
	icon_off = "secure_off_cargo"

	New()
		..()
		new /obj/item/device/radio/headset/almayer/mcom(src)
		new /obj/item/clothing/under/rank/ro_suit(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/storage/belt/marine(src)
		new /obj/item/clothing/head/cmcap/req(src)
		new /obj/item/device/flashlight(src)
		new /obj/item/storage/backpack/marine/satchel(src)

/obj/structure/closet/secure_closet/cargotech
	name = "Cargo Technician's Locker"
	req_access = list(ACCESS_MARINE_CARGO)
	icon_state = "secure_locked_cargo"
	icon_closed = "secure_unlocked_cargo"
	icon_locked = "secure_locked_cargo"
	icon_opened = "secure_open_cargo"
	icon_broken = "secure_broken_cargo"
	icon_off = "secure_off_cargo"

	New()
		..()
		new /obj/item/clothing/under/rank/cargotech(src)
		new /obj/item/clothing/shoes/marine(src)
		new /obj/item/device/radio/headset/almayer/ct(src)
		new /obj/item/clothing/gloves/yellow(src)
		new /obj/item/clothing/head/beanie(src)
		new /obj/item/device/flashlight(src)
		new /obj/item/storage/backpack/marine/satchel(src)
		return