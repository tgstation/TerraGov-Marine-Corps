/datum/job/roguetown/adventurer/villager
	title = "Towner"
	flag = ADVENTURER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 30
	spawn_positions = 30
	allowed_races = list("Humen",
	"Elf",
	"Half-Elf",
	"Dwarf",
	"Tiefling",
	"Aasimar"
	)
	tutorial = "You've lived in this shithole for effectively all your life. You are not an explorer, nor exactly a warrior in many cases. You're just some average poor bastard who thinks they'll be something someday."

	outfit = null
	outfit_female = null
	bypass_jobban = FALSE
	display_order = JDO_VILLAGER
	isvillager = TRUE
	give_bank_account = TRUE

/*
/datum/job/roguetown/adventurer/villager/New()
	. = ..()
	for(var/X in GLOB.peasant_positions)
		peopleiknow += X
		peopleknowme += X
	for(var/X in GLOB.serf_positions)
		peopleiknow += X
	for(var/X in GLOB.church_positions)
		peopleiknow += X
	for(var/X in GLOB.garrison_positions)
		peopleiknow += X
	for(var/X in GLOB.noble_positions)
		peopleiknow += X*/
