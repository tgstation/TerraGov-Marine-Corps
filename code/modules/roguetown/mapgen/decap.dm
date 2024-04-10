//genstuff
/obj/effect/landmark/mapGenerator/rogue/decap
	mapGeneratorType = /datum/mapGenerator/decap
	endTurfX = 255
	endTurfY = 255
	startTurfX = 1
	startTurfY = 1


/datum/mapGenerator/decap
	modules = list(/datum/mapGeneratorModule/ambushing,/datum/mapGeneratorModule/decapdirt,/datum/mapGeneratorModule/decaproad)


/datum/mapGeneratorModule/decapdirt
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt)
	excluded_turfs = list(/turf/open/floor/rogue/dirt/road)
	spawnableAtoms = list(/obj/structure/flora/roguetree/burnt = 30,
							/obj/structure/flora/roguegrass/bush = 25,
							/obj/structure/flora/roguegrass = 23,
							/obj/structure/flora/roguegrass/maneater = 13,
							/obj/item/natural/stone = 23,
							/obj/item/natural/rock = 8,
							/obj/item/grown/log/tree/stick = 16,
							/obj/structure/closet/dirthole/closed/loot=3,
							/obj/structure/flora/roguegrass/maneater/real=7)
	spawnableTurfs = list(/turf/open/lava=2,/turf/open/floor/rogue/dirt/road=36)
	allowed_areas = list(/area/rogue/outdoors/mountains/decap)

/datum/mapGeneratorModule/decaproad
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt/road)
	spawnableAtoms = list(/obj/item/natural/stone = 23,/obj/item/natural/rock = 8,/obj/item/grown/log/tree/stick = 6)
	allowed_areas = list(/area/rogue/outdoors/mountains/decap)
