
/datum/crafting_recipe/roguetown/structure
	req_table = FALSE

/datum/crafting_recipe/roguetown/structure/TurfCheck(mob/user, turf/T)
	if(istype(T,/turf/open/transparent/openspace))
		return FALSE
	return ..()

/datum/crafting_recipe/roguetown/structure/handcart
	name = "handcart"
	result = /obj/structure/handcart
	reqs = list(/obj/item/grown/log/tree/small = 3,
				/obj/item/rope = 1)
	verbage = "carpents"
	craftsound = 'sound/foley/Building-01.ogg'

/datum/crafting_recipe/roguetown/structure/psycrss
	name = "wooden cross"
	result = /obj/structure/fluff/psycross/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/grown/log/tree/stake = 3)
	verbage = "carpents"
	craftsound = 'sound/foley/Building-01.ogg'

/datum/crafting_recipe/roguetown/structure/door
	name = "wooden door"
	result = /obj/structure/mineral_door/wood/deadbolt
	reqs = list(/obj/item/grown/log/tree/small = 2)
	verbage = "carpents"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry

/datum/crafting_recipe/roguetown/structure/barrel
	name = "wooden barrel"
	result = /obj/structure/fermenting_barrel/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "barrelmakes"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry

/obj/structure/fermenting_barrel/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/roguebin
	name = "wooden bin"
	result = /obj/item/roguebin
	reqs = list(/obj/item/grown/log/tree/small = 2)
	verbage = "barrelmakes"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 0

/datum/crafting_recipe/roguetown/structure/chair
	name = "wooden chair"
	result = /obj/item/chair/rogue/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "carpents"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry

/obj/item/chair/rogue/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/structure/stool
	name = "wooden stool"
	result = /obj/item/chair/stool/bar/rogue/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1)
	skillcraft = /datum/skill/craft/carpentry
	verbage = "carpents"
	craftsound = 'sound/foley/Building-01.ogg'

/obj/item/chair/stool/bar/rogue/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/structure/anvil
	name = "anvil"
	result = /obj/machinery/anvil
	reqs = list(/obj/item/ingot/iron = 1)

	verbage = "builds"
	craftsound = 'sound/foley/Building-01.ogg'

/datum/crafting_recipe/roguetown/structure/smelter
	name = "ore furnace"
	result = /obj/machinery/light/rogue/smelter
	reqs = list(/obj/item/natural/stone = 4,
			/obj/item/rogueore/coal = 1)
	verbage = "crafts"
	craftsound = null

/datum/crafting_recipe/roguetown/structure/greatsmelter
	name = "great furnace"
	result = /obj/machinery/light/rogue/smelter/great
	reqs = list(/obj/item/ingot/iron = 2,
				/obj/item/riddleofsteel = 1,
				/obj/item/rogueore/coal = 1)
	verbage = "crafts"
	craftsound = null

/datum/crafting_recipe/roguetown/structure/forge
	name = "forge"
	result = /obj/machinery/light/rogue/forge
	reqs = list(/obj/item/natural/stone = 4,
				/obj/item/rogueore/coal = 1)

	verbage = "builds"
	craftsound = null

/datum/crafting_recipe/roguetown/structure/sharpwheel
	name = "sherpening wheel"
	result = /obj/structure/fluff/grindwheel
	reqs = list(/obj/item/ingot/iron = 1,
				/obj/item/natural/stone = 1)

	verbage = "crafts"
	craftsound = null
/*
/datum/crafting_recipe/roguetown/structure/stairs
	name = "stairs (up)"
	result = /obj/structure/stairs
	reqs = list(/obj/item/grown/log/tree/small = 1)

	verbage = "carpents"
	craftsound = 'sound/foley/Building-01.ogg'
	ontile = TRUE

/datum/crafting_recipe/roguetown/structure/stairs/TurfCheck(mob/user, turf/T)
	var/turf/checking = get_step_multiz(T, UP)
	if(!checking)
		return FALSE
	if(!istype(checking,/turf/open/transparent/openspace))
		return FALSE
	checking = get_step(checking, user.dir)
	if(!checking)
		return FALSE
	if(!isopenturf(checking))
		return FALSE
	if(istype(checking,/turf/open/transparent/openspace))
		return FALSE
	for(var/obj/structure/S in checking)
		if(istype(S, /obj/structure/stairs))
			return FALSE
		if(S.density)
			return FALSE
	return TRUE
*/
/datum/crafting_recipe/roguetown/structure/stairsd
	name = "stairs"
	result = /obj/structure/stairs/d
	reqs = list(/obj/item/grown/log/tree/small = 1)
	skillcraft = /datum/skill/craft/carpentry
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	ontile = TRUE

/datum/crafting_recipe/roguetown/structure/stairsd/TurfCheck(mob/user, turf/T)
	var/turf/checking = get_step(T, user.dir)
	if(!checking)
		return FALSE
	if(!istype(checking,/turf/open/transparent/openspace))
		return FALSE
	checking = get_step_multiz(checking, DOWN)
	if(!checking)
		return FALSE
	if(!isopenturf(checking))
		return FALSE
	if(istype(checking,/turf/open/transparent/openspace))
		return FALSE
	for(var/obj/structure/S in checking)
		if(istype(S, /obj/structure/stairs))
			return FALSE
		if(S.density)
			return FALSE
	return TRUE

/datum/crafting_recipe/roguetown/structure/fence
	name = "palisade (s x2)"
	result = /obj/structure/fluff/railing/fence
	reqs = list(/obj/item/grown/log/tree/stake = 2)
	ontile = TRUE
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	buildsame = TRUE

/datum/crafting_recipe/roguetown/structure/fencealt
	name = "palisade (l)"
	result = /obj/structure/fluff/railing/fence
	reqs = list(/obj/item/grown/log/tree/small = 1)
	ontile = TRUE
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	buildsame = TRUE

/datum/crafting_recipe/roguetown/structure/chest
	name = "chest"
	result = /obj/structure/closet/crate/chest/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 0

/obj/structure/closet/crate/chest/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/structure/closet
	name = "closet"
	result = /obj/structure/closet/crate/roguecloset
	reqs = list(/obj/item/grown/log/tree/small = 2)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry

/obj/structure/closet/crate/roguecloset/crafted
	sellprice = 6

/datum/crafting_recipe/roguetown/structure/campfire
	name = "campfire"
	result = /obj/machinery/light/rogue/campfire
	reqs = list(/obj/item/grown/log/tree/stick = 2)
	verbage = "build"
	craftdiff = 0

/datum/crafting_recipe/roguetown/structure/densefire
	name = "greater campfire"
	result = /obj/machinery/light/rogue/campfire/densefire
	reqs = list(/obj/item/grown/log/tree/stick = 2,
				/obj/item/natural/stone = 2)
	verbage = "build"

/datum/crafting_recipe/roguetown/structure/cookpit
	name = "cookpit"
	result = /obj/machinery/light/rogue/hearth
	reqs = list(/obj/item/grown/log/tree/stick = 1,
				/obj/item/natural/stone = 3)
	verbage = "build"
	craftdiff = 0

/datum/crafting_recipe/roguetown/structure/brazier
	name = "brazier"
	result = /obj/machinery/light/rogue/firebowl/stump
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/rogueore/coal = 1)
	verbage = "build"

/datum/crafting_recipe/roguetown/structure/oven
	name = "oven"
	result = /obj/machinery/light/rogue/oven
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/natural/stone = 3)
	verbage = "mason"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/masonry
	wallcraft = TRUE

/datum/crafting_recipe/roguetown/structure/dryingrack
	name = "drying rack"
	result = /obj/structure/fluff/dryingrack
	reqs = list(/obj/item/grown/log/tree/stick = 3)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'

/datum/crafting_recipe/roguetown/structure/bed
	name = "bed"
	result = /obj/structure/bed/rogue/shit
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/natural/fibers = 1)
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	craftdiff = 0

/datum/crafting_recipe/roguetown/structure/nicebed
	name = "nice bed"
	result = /obj/structure/bed/rogue
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/natural/cloth = 1)
	tools = list(/obj/item/needle)
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 2

/datum/crafting_recipe/roguetown/structure/table
	name = "wooden table"
	result = /obj/structure/table/wood/crafted
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry

/datum/crafting_recipe/roguetown/structure/millstone
	name = "millstone"
	result = /obj/structure/fluff/millstone
	reqs = list(/obj/item/natural/stone = 3)
	verbage = "mason"
	craftsound = null
	wallcraft = TRUE
	skillcraft = /datum/skill/craft/masonry

/datum/crafting_recipe/roguetown/structure/lever
	name = "lever"
	result = /obj/structure/lever
	reqs = list(/obj/item/roguegear = 1)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/engineering

/datum/crafting_recipe/roguetown/structure/trapdoor
	name = "floorhatch"
	result = /obj/structure/floordoor
	reqs = list(/obj/item/grown/log/tree/small = 1,
					/obj/item/roguegear = 1)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/engineering

/datum/crafting_recipe/roguetown/structure/trapdoor/TurfCheck(mob/user, turf/T)
	if(istype(T,/turf/open/transparent/openspace))
		return TRUE
	if(istype(T,/turf/open/lava))
		return FALSE
	return ..()

/datum/crafting_recipe/roguetown/structure/sign
	name = "custom sign"
	result = /obj/structure/fluff/customsign
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 1

/datum/crafting_recipe/roguetown/structure/dummy
	name = "training dummy"
	result = /obj/structure/fluff/statue/tdummy
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 1

/datum/crafting_recipe/roguetown/structure/passage
	name = "passage"
	result = /obj/structure/bars/passage
	reqs = list(/obj/item/ingot/iron = 1,
					/obj/item/roguegear = 1)
	verbage = "construct"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/engineering

/datum/crafting_recipe/roguetown/structure/passage/TurfCheck(mob/user, turf/T)
	if(istype(T,/turf/open/transparent/openspace))
		return FALSE
	if(istype(T,/turf/open/lava))
		return FALSE
	if(istype(T,/turf/open/water))
		return FALSE
	return ..()

/datum/crafting_recipe/roguetown/structure/wallladder
	name = "wall ladder"
	result = /obj/structure/wallladder
	reqs = list(/obj/item/grown/log/tree/small = 1)
	verbage = "carpent"
	craftsound = 'sound/foley/Building-01.ogg'
	skillcraft = /datum/skill/craft/carpentry
	wallcraft = TRUE
	craftdiff = 1
