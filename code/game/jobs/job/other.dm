/datum/job/other
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/datum/job/other/colonist
	title = "Colonist"
	comm_title = "CLN"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)
	equipment = TRUE

/datum/job/other/colonist/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/clothing/shoes/marine/S = new /obj/item/clothing/shoes/marine(H)
	S.knife = new /obj/item/weapon/combat_knife
	S.update_icon()

	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	H.equip_to_slot(new /obj/item/storage/pouch/survival/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/radio(H), SLOT_R_STORE)


/datum/job/other/passenger
	title = "Passenger"
	comm_title = "PAS"
	paygrade = "C"
	access = list(ACCESS_IFF_MARINE)
	minimal_access = list(ACCESS_IFF_MARINE)


/datum/job/other/pizza
	title = "Pizza Deliverer"
	idtype = /obj/item/card/id/centcom
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	equipment = TRUE

/datum/job/other/pizza/generate_equipment(mob/living/carbon/human/H)
	var/obj/item/storage/backpack/satchel/B = new /obj/item/storage/backpack/satchel(H)
	B.contents += new /obj/item/device/flashlight
	B.contents += new /obj/item/reagent_container/food/drinks/cans/thirteenloko
	B.contents += new /obj/item/pizzabox/vegetable
	B.contents += new /obj/item/pizzabox/mushroom
	B.contents += new /obj/item/pizzabox/meat
	B.contents += new /obj/item/ammo_magazine/pistol/holdout
	B.contents += new /obj/item/ammo_magazine/pistol/holdout


	H.equip_to_slot_or_del(new /obj/item/clothing/under/pizza(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/red(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/red(H), SLOT_SHOES)
	H.equip_to_slot_or_del(B, SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/pizzabox/margherita(H), SLOT_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/holdout(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/device/radio(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/drinks/cans/dr_gibb(H), SLOT_L_STORE)

/datum/job/other/spatial_agent
	title = "Spatial Agent"
	idtype = /obj/item/card/id/centcom
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	equipment = TRUE
	skills_type = /datum/skills/spatial_agent

/datum/job/other/spatial_agent/generate_entry_conditions(mob/living/carbon/human/H)
	. = ..()
	H.add_language("English")
	H.add_language("Sainja")
	H.add_language("Xenomorph")
	H.add_language("Hivemind")
	H.add_language("Russian")
	H.add_language("Tradeband")
	H.add_language("Gutter")

/datum/job/other/spatial_agent/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_commander/sa(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/sa(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/officer/chief/sa(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sa(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), SLOT_BELT)


/datum/job/other/survivor
	skills_type = /datum/skills/civilian/survivor
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	equipment = TRUE


/datum/job/other/survivor/assistant
	disp_title = "Assistant"

/datum/job/other/survivor/assistant/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)


/datum/job/other/survivor/scientist
	disp_title = "Scientist"
	skills_type = /datum/skills/civilian/survivor/scientist

/datum/job/other/survivor/scientist/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/tox(H), SLOT_BACK)


/datum/job/other/survivor/doctor
	disp_title = "Doctor's Assistant"
	skills_type = /datum/skills/civilian/survivor/doctor

/datum/job/other/survivor/doctor/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/medical(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/med(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H.back), SLOT_IN_BACKPACK)


/datum/job/other/survivor/liaison
	disp_title = "Liaison"

/datum/job/other/survivor/liaison/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)


/datum/job/other/survivor/security
	disp_title = "Security Guard"
	skills_type = /datum/skills/civilian/survivor/marshal

/datum/job/other/survivor/security/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/security/corp(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(H), SLOT_L_HAND)


/datum/job/other/survivor/civilian
	disp_title = "Civilian"

/datum/job/other/survivor/civilian/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)


/datum/job/other/survivor/chef
	disp_title = "Chef"
	skills_type = /datum/skills/civilian/survivor/chef

/datum/job/other/survivor/chef/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/chef(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/tool/kitchen/rollingpin(H), SLOT_L_HAND)


/datum/job/other/survivor/botanist
	disp_title = "Botanist"

/datum/job/other/survivor/botanist/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/tool/hatchet(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/hydroponics(H), SLOT_BACK)


/datum/job/other/survivor/atmos
	disp_title = "Atmospherics Technician"
	skills_type = /datum/skills/civilian/survivor/atmos

/datum/job/other/survivor/atmos/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/colonist(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/atmostech(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/eng(H), SLOT_BACK)


/datum/job/other/survivor/chaplain
	disp_title = "Chaplain"

/datum/job/other/survivor/chaplain/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chaplain(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/bible/booze(H.back), SLOT_IN_BACKPACK)


/datum/job/other/survivor/miner
	disp_title = "Miner"
	skills_type = /datum/skills/civilian/survivor/miner

/datum/job/other/survivor/miner/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/miner(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/tool/pickaxe(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/lantern(H.back), SLOT_IN_BACKPACK)


/datum/job/other/survivor/salesman
	disp_title = "Salesman"

/datum/job/other/survivor/salesman/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/wcoat(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/briefcase(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(H), SLOT_BACK)


/datum/job/other/survivor/marshal
	disp_title = "Colonial Marshal"
	skills_type = /datum/skills/civilian/survivor/marshal

/datum/job/other/survivor/marshal/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/CMB(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/CM_uniform(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/jackboots(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/cmb(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(H), SLOT_BACK)


/datum/job/other/survivor/clown
	disp_title = "Clown"
	skills_type = /datum/skills/civilian/survivor/clown

/datum/job/other/survivor/clown/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/clown(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/tool/stamp/clown(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/spray/waterflower(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/grown/banana(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/grown/banana(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/toy/bikehorn(H), SLOT_IN_BACKPACK)

/datum/job/other/survivor/clown/generate_entry_conditions(mob/living/carbon/human/H)
	H.fully_replace_character_name(H.real_name, pick(clown_names))
	var/datum/dna/gene/disability/clumsy/G = new /datum/dna/gene/disability/clumsy
	G.activate(H)