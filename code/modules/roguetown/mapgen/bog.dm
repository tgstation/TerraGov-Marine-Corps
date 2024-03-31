
/obj/effect/landmark/mapGenerator/rogue/bog
	mapGeneratorType = /datum/mapGenerator/bog
	endTurfX = 255
	endTurfY = 255
	startTurfX = 1
	startTurfY = 1

/datum/mapGenerator/bog
	modules = list(/datum/mapGeneratorModule/ambushing,/datum/mapGeneratorModule/bog, /datum/mapGeneratorModule/bogwater)

/datum/mapGeneratorModule/bog
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	allowed_turfs = list(/turf/open/floor/rogue/dirt)
	spawnableAtoms = list(/obj/structure/flora/roguetree = 18,
							/obj/structure/flora/roguegrass/bush = 12,
							/obj/structure/flora/roguegrass/maneater = 13,
							/obj/structure/flora/roguegrass = 23,
							/obj/structure/flora/roguetree/stump/log = 3,
							/obj/item/natural/stone = 8,
							/obj/item/reagent_containers/food/snacks/grown/rogue/sweetleaf = 4,
							/obj/item/grown/log/tree/stick = 4,
							/obj/structure/flora/roguegrass/maneater/real=8,
							/obj/item/restraints/legcuffs/beartrap/armed/camouflage=4)
	spawnableTurfs = list(/turf/open/water/swamp=3)
	allowed_areas = list(/area/rogue/outdoors/bog)

/datum/mapGeneratorModule/bogwater
	clusterCheckFlags = CLUSTER_CHECK_DIFFERENT_ATOMS
	spawnableAtoms = list(/obj/structure/flora/roguegrass/water = 50,
						/obj/structure/flora/roguegrass/water/reeds = 10,
						/obj/structure/glowshroom = 5)
	allowed_turfs = list(/turf/open/water/swamp,
						/turf/open/water/swamp/deep)
	allowed_areas = list(/area/rogue/outdoors/bog)