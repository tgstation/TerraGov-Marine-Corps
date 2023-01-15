/datum/job/boxer
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	skills_type = /datum/skills/skeleton
	faction = FACTION_NEUTRAL
	title = "Boxer"
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/boxer/red,
		/datum/outfit/job/boxer/blue,
		/datum/outfit/job/boxer/green,
	)

/datum/outfit/job/boxer/red
	w_uniform = /obj/item/clothing/under/shorts/red/eord
	gloves = /obj/item/clothing/gloves/heldgloves/boxing

/datum/outfit/job/boxer/blue
	w_uniform = /obj/item/clothing/under/shorts/blue/eord
	gloves = /obj/item/clothing/gloves/heldgloves/boxing/blue

/datum/outfit/job/boxer/green
	w_uniform = /obj/item/clothing/under/shorts/green/eord
	gloves = /obj/item/clothing/gloves/heldgloves/boxing/green
