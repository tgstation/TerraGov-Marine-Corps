//MARINE COMMAND CLOSET
/obj/structure/closet/secure_closet/captain
	name = "captain's locker"
	req_access = list(ACCESS_MARINE_CAPTAIN)
	icon_state = "secure_locked_commander"
	icon_closed = "secure_unlocked_commander"
	icon_locked = "secure_locked_commander"
	icon_opened = "secure_open_commander"
	icon_broken = "secure_locked_commander"
	icon_off = "secure_closed_commander"

/obj/structure/closet/secure_closet/captain/PopulateContents()
	new /obj/item/storage/backpack/captain(src)
	new /obj/item/clothing/shoes/marinechief/captain(src)
	new /obj/item/clothing/gloves/marine/techofficer/captain(src)
	new /obj/item/clothing/under/marine/officer/command(src)
	new /obj/item/clothing/head/beret/marine/captain(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/marine/whites(src)
	new /obj/item/clothing/head/white_dress(src)
	new /obj/item/storage/backpack/marine/satchel/captain_cloak_red(src)
	new /obj/item/storage/holster/belt/mateba/officer/full(src)

/obj/structure/closet/secure_closet/securecom
	name = "captain's secure box"
	req_access = list(ACCESS_MARINE_CAPTAIN)
	desc = "You could probably get court-marshaled just by looking at this..."
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

/obj/structure/closet/secure_closet/staff_officer/PopulateContents()
	new /obj/item/clothing/head/tgmcberet(src)
	new /obj/item/clothing/head/tgmcberet/tan(src)
	new /obj/item/clothing/head/tgmccap/ro(src)
	new /obj/item/clothing/head/tgmccap/ro/navy(src)
	new /obj/item/clothing/under/marine/officer/bridge(src)
	new /obj/item/clothing/shoes/marine(src)
	new /obj/item/clothing/suit/storage/marine/officer(src)
	new /obj/item/clothing/suit/storage/marine/officer(src)
	new /obj/item/storage/belt/marine(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/marine/whites(src)
	new /obj/item/clothing/head/white_dress(src)
	new /obj/item/storage/backpack/marine/satchel/officer_cloak(src)

/obj/structure/closet/secure_closet/pilot_officer
	name = "pilot officer's locker"
	req_access = list(ACCESS_MARINE_PILOT)
	icon_state = "secure_locked_pilot"
	icon_closed = "secure_unlocked_pilot"
	icon_locked = "secure_locked_pilot"
	icon_opened = "secure_open_pilot"
	icon_broken = "secure_locked_pilot"
	icon_off = "secure_closed_pilot"

/obj/structure/closet/secure_closet/pilot_officer/PopulateContents()
	new /obj/item/clothing/head/helmet/marine/pilot(src)
	new /obj/item/clothing/under/marine/officer/pilot(src)
	new /obj/item/clothing/shoes/marine(src)
	new /obj/item/clothing/suit/storage/marine/pilot(src)
	new /obj/item/storage/holster/m25/full(src)
	new /obj/item/storage/backpack/marine/satchel(src)
	new /obj/item/clothing/gloves/insulated(src)
	new /obj/item/clothing/glasses/sunglasses/aviator/yellow(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/marine/whites(src)
	new /obj/item/clothing/head/white_dress(src)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
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

/obj/structure/closet/secure_closet/military_police/PopulateContents()
	new /obj/item/clothing/head/tgmcberet/red(src)
	new /obj/item/clothing/head/tgmcberet/red(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/armor_module/storage/uniform/holster/armpit(src)
	new /obj/item/clothing/shoes/marine(src)
	new /obj/item/clothing/under/marine/mp(src)
	new /obj/item/flashlight(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/weapon/gun/energy/taser(src)
	new /obj/item/weapon/baton(src)
	new /obj/item/storage/backpack/security (src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/marine/whites(src)
	new /obj/item/clothing/head/white_dress(src)

//MARINE SHIP MEDICAL CLOSET
/obj/structure/closet/secure_closet/medical_doctor
	name = "medical doctor's locker"
	req_access = list(ACCESS_MARINE_MEDBAY)
	icon_state = "secure_locked_medical"
	icon_closed = "secure_unlocked_medical"
	icon_locked = "secure_locked_medical"
	icon_opened = "secure_open_medical"
	icon_broken = "secure_broken_medical"
	icon_off = "secure_closed_medical"

/obj/structure/closet/secure_closet/medical_doctor/PopulateContents()
	new /obj/item/storage/backpack/marine/satchel(src)
	if(!is_ground_level(z))
		new /obj/item/radio/headset/mainship/doc(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/storage/belt/lifesaver/full(src)
	new /obj/item/clothing/under/rank/medical/blue(src)
	new /obj/item/clothing/under/rank/medical/green(src)
	new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/head/surgery/green(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/suit/surgical(src)
	if(SSmapping.configs[GROUND_MAP].environment_traits[MAP_COLD])
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

/obj/structure/closet/secure_closet/req_officer/PopulateContents()
	new /obj/item/supplytablet(src)
	new /obj/item/clothing/under/marine/officer/ro_suit(src)
	new /obj/item/clothing/shoes/marine(src)
	new /obj/item/storage/belt/marine(src)
	new /obj/item/clothing/head/tgmccap/req(src)
	new /obj/item/flashlight(src)
	new /obj/item/storage/backpack/marine/satchel(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/clothing/suit/storage/marine/officer/req(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/marine/whites(src)
	new /obj/item/clothing/head/white_dress(src)
	new /obj/item/flash(src)

/obj/structure/closet/secure_closet/shiptech
	name = "Requisitions' Locker"
	req_access = list(ACCESS_MARINE_CARGO)
	icon_state = "secure_locked_cargo"
	icon_closed = "secure_unlocked_cargo"
	icon_locked = "secure_locked_cargo"
	icon_opened = "secure_open_cargo"
	icon_broken = "secure_broken_cargo"
	icon_off = "secure_off_cargo"

/obj/structure/closet/secure_closet/shiptech/PopulateContents()
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/shoes/marine(src)
	new /obj/item/radio/headset/mainship/ct(src)
	new /obj/item/clothing/gloves/insulated(src)
	new /obj/item/clothing/head/beanie(src)
	new /obj/item/flashlight(src)
	new /obj/item/storage/backpack/marine/satchel(src)
	new /obj/item/armor_module/storage/uniform/webbing(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/clothing/gloves/white(src)
	new /obj/item/clothing/under/marine/whites(src)
	new /obj/item/clothing/head/white_dress(src)
	new /obj/item/clothing/head/beanie(src)
