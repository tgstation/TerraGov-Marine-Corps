/datum/job/samurai
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_NEUTRAL



/datum/job/samurai/basic
	title = "Samurai reenactor"
	outfit = /datum/outfit/job/samurai/basic


/datum/outfit/job/samurai/basic
	name = "Samurai reenactor"
	jobtype = /datum/job/samurai/basic

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/color/black
	wear_suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/sandal
	back = /obj/item/weapon/twohanded/spear
	ears = /obj/item/radio/headset/survivor
	r_store = /obj/item/flashlight
	l_store = /obj/item/tool/crowbar/red

/datum/outfit/job/samurai/basic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/katana, SLOT_L_HAND)


/datum/job/samurai/basic/leader
	title = "Samurai reenactor"
	outfit = /datum/outfit/job/samurai/basic


/datum/outfit/job/samurai/basic/leader
	name = "Samurai reenactor"
	jobtype = /datum/job/samurai/basic
