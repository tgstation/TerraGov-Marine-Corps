
/datum/crafting_recipe/roguetown/leather
	tools = list(/obj/item/needle)
	structurecraft = /obj/structure/fluff/dryingrack
	skillcraft = /datum/skill/craft/tanning

/datum/crafting_recipe/roguetown/leather/pouch
	name = "leather pouch"
	result = list(/obj/item/storage/belt/rogue/pouch,
				/obj/item/storage/belt/rogue/pouch)
	reqs = list(/obj/item/natural/hide = 1,
				/obj/item/natural/fibers = 1)
	sellprice = 6

/datum/crafting_recipe/roguetown/leather/satchel
	name = "leather satchel"
	result = /obj/item/storage/backpack/rogue/satchel
	reqs = list(/obj/item/natural/hide = 2,
				/obj/item/natural/fibers = 1)
	sellprice = 15

/datum/crafting_recipe/roguetown/leather/backpack
	name = "leather backpack"
	result = /obj/item/storage/backpack/rogue/backpack
	reqs = list(/obj/item/natural/hide = 2,
				/obj/item/natural/fibers = 1)
	sellprice = 45

/datum/crafting_recipe/roguetown/leather/gloves
	name = "leather gloves"
	result = list(/obj/item/clothing/gloves/roguetown/leather,
	/obj/item/clothing/gloves/roguetown/leather)
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 10

/datum/crafting_recipe/roguetown/leather/bracers
	name = "leather bracers"
	result = list(/obj/item/clothing/wrists/roguetown/bracers/leather,
			/obj/item/clothing/wrists/roguetown/bracers/leather)
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 10

/datum/crafting_recipe/roguetown/leather/pants
	name = "leather pants"
	result = list(/obj/item/clothing/under/roguetown/trou/leather)
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 10

/datum/crafting_recipe/roguetown/leather/shoes
	name = "leather shoes"
	result = list(/obj/item/clothing/shoes/roguetown/simpleshoes,
				/obj/item/clothing/shoes/roguetown/simpleshoes,
				/obj/item/clothing/shoes/roguetown/simpleshoes)
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 10

/datum/crafting_recipe/roguetown/leather/boots
	name = "leather boots"
	result = /obj/item/clothing/shoes/roguetown/boots/leather
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 27

/datum/crafting_recipe/roguetown/leather/helmet
	name = "leather helmet"
	result = /obj/item/clothing/head/roguetown/helmet/leather
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 27

/datum/crafting_recipe/roguetown/leather/hood
	name = "leather hood"
	result = /obj/item/clothing/head/roguetown/roguehood
	reqs = list(/obj/item/natural/hide = 1)
	sellprice = 26

/datum/crafting_recipe/roguetown/leather/armor
	name = "leather armor"
	result = /obj/item/clothing/suit/roguetown/armor/leather
	reqs = list(/obj/item/natural/hide = 2)
	sellprice = 26

/datum/crafting_recipe/roguetown/leather/hidearmor
	name = "hide armor"
	result = /obj/item/clothing/suit/roguetown/armor/leather/hide
	reqs = list(/obj/item/natural/hide = 2,
				/obj/item/natural/fur = 1)
	sellprice = 26

/datum/crafting_recipe/roguetown/leather/cloak
	name = "leather cloak"
	result = /obj/item/clothing/cloak/raincloak/brown
	reqs = list(/obj/item/natural/hide = 2)


/obj/item/clothing/cloak/raincloak/brown
	sellprice = 20

/datum/crafting_recipe/roguetown/leather/cloakfur
	name = "fur cloak"
	result = /obj/item/clothing/cloak/raincloak/furcloak/crafted
	reqs = list(/obj/item/natural/hide = 2,/obj/item/natural/fur = 1)


/obj/item/clothing/cloak/raincloak/furcloak/crafted
	sellprice = 55

/datum/crafting_recipe/roguetown/leather/saddle
	name = "saddle"
	result = /obj/item/natural/saddle
	reqs = list(/obj/item/natural/hide = 2)

