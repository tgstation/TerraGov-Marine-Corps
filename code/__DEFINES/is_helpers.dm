#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

#define ismovableatom(A) ismovable(A)

#define isatom(A) (isloc(A))

#define isclient(A) (istype(A, /client))

#define isdatum(thing) (istype(thing, /datum))

#define isweakref(D) (istype(D, /datum/weakref))

#define isgenerator(A) (istype(A, /generator))

//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

#define isopenturf(A) (istype(A, /turf/open))

#define isopengroundturf(A) (istype(A, /turf/open/ground/jungle) || istype(A, /turf/open/ground/grass))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define islava(A) (istype(A, /turf/open/liquid/lava))

#define iswater(A) (istype(A, /turf/open/liquid/water))

#define isbasalt(A) (istype(A, /turf/open/lavaland/basalt))

#define islavacatwalk(A) (istype(A, /turf/open/lavaland/catwalk))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define isrwallturf(A) (istype(A, /turf/closed/wall/r_wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

#define isnestedhost(A) ((CHECK_BITFIELD(A.status_flags, XENO_HOST) && CHECK_BITFIELD(A.restrained_flags, RESTRAINED_XENO_NEST)))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define isrobot(H) (is_species(H, /datum/species/robot))
#define issynth(H) (is_species(H, /datum/species/synthetic) || is_species(H, /datum/species/early_synthetic))
#define isspeciessynthetic(H) (H.species.species_flags & IS_SYNTHETIC)
#define ismoth(H) (is_species(H, /datum/species/moth))
#define issectoid(H) (is_species(H, /datum/species/sectoid))
#define ishumanbasic(H) (is_species(H, /datum/species/human))
#define iszombie(H) (is_species(H, /datum/species/zombie))

//Monkey species and subtypes
#define ismonkey(H) (is_species(H, /datum/species/monkey))
#define isfarwa(H) (is_species(H, /datum/species/monkey/farwa))
#define isstok(H) (is_species(H, /datum/species/monkey/stok))
#define isnaera(H) (is_species(H, /datum/species/monkey/naera))
#define isyiren(H) (is_species(H, /datum/species/monkey/yiren))

//Job/role helpers
#define ismarinefaction(H) (H.faction == "TerraGov")
#define isterragovjob(J) (istype(J, /datum/job/terragov))
#define ismedicaljob(J) (istype(J, /datum/job/terragov/medical))
#define isengineeringjob(J) (istype(J, /datum/job/terragov/engineering))
#define ismarinejob(J) (istype(J, /datum/job/terragov/squad))
#define issommarinejob(J) (istype(J, /datum/job/som/squad))
#define ismarinespecjob(J) (istype(J, /datum/job/terragov/squad/specialist))
#define ismarineleaderjob(J) (istype(J, /datum/job/terragov/squad/leader))
#define issommarineleaderjob(J) (istype(J, /datum/job/som/squad/leader))
#define ismarinecommandjob(J) (istype(J, /datum/job/terragov/command))
#define ismarinecaptainjob(J) (istype(J, /datum/job/terragov/command/captain))
#define issommarinecommandjob(J) (istype(J, /datum/job/som/command))
#define iscorporateliaisonjob(J) (istype(J, /datum/job/terragov/civilian/liaison))
#define issurvivorjob(J) (istype(J, /datum/job/survivor))
#define ischaplainjob(J) (istype(J, /datum/job/survivor/chaplain))
#define isxenosjob(J) (istype(J, /datum/job/xenomorph))

//Monkey sub-species

#define isxeno(A) (istype(A, /mob/living/carbon/xenomorph))

//Xeno castes
#define isxenoboiler(A) (istype(A, /mob/living/carbon/xenomorph/boiler))
#define isxenocarrier(A) (istype(A, /mob/living/carbon/xenomorph/carrier))
#define isxenocrusher(A) (istype(A, /mob/living/carbon/xenomorph/crusher))
#define isxenogorger(A) (istype(A, /mob/living/carbon/xenomorph/gorger))
#define isxenodrone(A) (istype(A, /mob/living/carbon/xenomorph/drone))
#define isxenohivelord(A) (istype(A, /mob/living/carbon/xenomorph/hivelord))
#define isxenohunter(A) (istype(A, /mob/living/carbon/xenomorph/hunter))
#define isxenodefender(A) (istype(A, /mob/living/carbon/xenomorph/defender))
#define isxenopraetorian(A) (istype(A, /mob/living/carbon/xenomorph/praetorian))
#define isxenoravager(A) (istype(A, /mob/living/carbon/xenomorph/ravager))
#define isxenorunner(A) (istype(A, /mob/living/carbon/xenomorph/runner))
#define isxenobaneling(A) (istype(A, /mob/living/carbon/xenomorph/baneling))
#define isxenospitter(A) (istype(A, /mob/living/carbon/xenomorph/spitter))
#define isxenosentinel(A) (istype(A, /mob/living/carbon/xenomorph/sentinel))
#define isxenowarrior(A) (istype(A, /mob/living/carbon/xenomorph/warrior))
#define isxenolarva(A) (istype(A, /mob/living/carbon/xenomorph/larva))
#define isxenoqueen(A) (istype(A, /mob/living/carbon/xenomorph/queen))
#define isxenoshrike(A) (istype(A, /mob/living/carbon/xenomorph/shrike))
#define isxenodefiler(A) (istype(A, /mob/living/carbon/xenomorph/defiler))
#define isxenobull(A) (istype(A, /mob/living/carbon/xenomorph/bull))
#define isxenohivemind(A) (istype(A, /mob/living/carbon/xenomorph/hivemind))
#define isxenowraith(A) (istype(A, /mob/living/carbon/xenomorph/wraith))
#define isxenowidow(A) (istype(A, /mob/living/carbon/xenomorph/widow))
#define isxenowarlock(A) (istype(A, /mob/living/carbon/xenomorph/warlock))
#define isxenoking(A) (istype(A, /mob/living/carbon/xenomorph/king))
#define isxenobehemoth(A) (istype(A, /mob/living/carbon/xenomorph/behemoth))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

#define issiliconoradminghost(A) (istype(A, /mob/living/silicon) || IsAdminGhost(A))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define iscrab(A) (istype(A, /mob/living/simple_animal/crab))

#define iscat(A) (istype(A, /mob/living/simple_animal/cat))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isbear(A) (istype(A, /mob/living/simple_animal/hostile/bear))

#define iscarp(A) (istype(A, /mob/living/simple_animal/hostile/carp))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/construct))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))

//Misc mobs
#define isobserver(A) (istype(A, /mob/dead/observer))

#define isdead(A) (istype(A, /mob/dead))

#define isnewplayer(A) (istype(A, /mob/new_player))

#define iscameramob(A) (istype(A, /mob/camera))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isgrabitem(A) (istype(A, /obj/item/grab))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define issuit(A) (istype(A, /obj/item/clothing/suit))

#define isfood(A) (istype(A, /obj/item/reagent_containers/food))

#define isgun(A) (istype(A, /obj/item/weapon/gun))

#define isammomagazine(A) (istype(A, /obj/item/ammo_magazine))

#define isgrenade(A) (istype(A, /obj/item/explosive/grenade))

#define isstorage(A) (istype(A, /obj/item/storage))

#define isitemstack(A) (istype(A, /obj/item/stack))

#define isuniform(A) (istype(A, /obj/item/clothing/under))

#define ismodularsuit(A) (istype(A, /obj/item/clothing/suit/modular))

#define ismodulararmormodule(A) (istype(A, /obj/item/armor_module))

#define ismodulararmorstoragemodule(A) (istype(A, /obj/item/armor_module/storage))

#define ismodulararmorarmorpiece(A) (istype(A, /obj/item/armor_module/armor))

#define ishat(A) (istype(A, /obj/item/clothing/head))

#define ismodularhelmet(A) (istype(A, /obj/item/clothing/head/modular))

#define isatmosscrubber(A) (istype(A, /obj/machinery/atmospherics/components/unary/vent_scrubber))

#define isatmosvent(A) (istype(A, /obj/machinery/atmospherics/components/unary/vent_pump))

#define isattachmentflashlight(A) (istype(A, /obj/item/attachable/flashlight))

#define isgunattachment(A) (istype(A, /obj/item/attachable))

#define ishandful(A) (istype(A, /obj/item/ammo_magazine/handful))

#define iswrench(I) (istype(I, /obj/item/tool/wrench))

#define iswelder(I) (istype(I, /obj/item/tool/weldingtool))

#define iscablecoil(I) (istype(I, /obj/item/stack/cable_coil))

#define iswirecutter(I) (istype(I, /obj/item/tool/wirecutters))

#define isscrewdriver(I) (istype(I, /obj/item/tool/screwdriver))

#define ismultitool(I) (istype(I, /obj/item/tool/multitool))

#define iscrowbar(I) (istype(I, /obj/item/tool/crowbar))

#define iscell(I) (istype(I, /obj/item/cell))

#define isfactorypart(I) (istype(I, /obj/item/factory_part))

#define isfactoryrefill(I) (istype(I, /obj/item/factory_refill))

#define isstructure(A) (istype(A, /obj/structure))

#define iscable(A) (istype(A, /obj/structure/cable))

#define isladder(A) (istype(A, /obj/structure/ladder))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ispowermachinery(A) (istype(A, /obj/machinery/power))

#define isAPC(A) (istype(A, /obj/machinery/power/apc))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define isvehicle(A) (istype(A, /obj/vehicle))

#define ismecha(A) (istype(A, /obj/vehicle/sealed/mecha))

#define isorgan(A) (istype(A, /datum/limb))

#define isidcard(A) (istype(A, /obj/item/card/id))

#define isinjector(A) (istype(A, /obj/item/reagent_containers/hypospray/autoinjector))

#define isuav(A) (istype(A, /obj/vehicle/unmanned))

#define isdroid(A) (istype(A, /obj/vehicle/unmanned/droid))

#define isreagentcontainer(A) (istype(A, /obj/item/reagent_containers)) //Checks for if something is a reagent container.

#define is_research_product(A) (istype(A, /obj/item/research_product)) //Checks if item is research item

#define isearthpillar(A) (istype(A, /obj/structure/earth_pillar))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/assembly))

#define isigniter(O) (istype(O, /obj/item/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/assembly/signaler))

#define isinfared(O) (istype(O, /obj/item/assembly/infra))

#define istimer(O) (istype(O, /obj/item/assembly/timer))

#define iseffect(O) (istype(O, /obj/effect))

#define isainode(O) (istype(O, /obj/effect/ai_node))

//Gamemode
#define iscrashgamemode(O) (istype(O, /datum/game_mode/infestation/crash))
#define isinfestationgamemode(O) (istype(O, /datum/game_mode/infestation))
#define iscombatpatrolgamemode(O) (istype(O, /datum/game_mode/hvh/combat_patrol))
#define issensorcapturegamemode(O) (istype(O, /datum/game_mode/hvh/combat_patrol/sensor_capture))
#define iscampaigngamemode(O) (istype(O, /datum/game_mode/hvh/campaign))

#define isxenoresearcharea(A) (istype(A, /area/mainship/medical/medical_science))

#define isspacearea(A) (istype(A, /area/space)) //Spacceeeee

// Admin
#define isaghost(mob) ( mob.key && mob.key[1] == "@" )
#define isclientedaghost(living) (isaghost(living) && GLOB.directory[copytext_char(living.ckey, 2)] && living.get_ghost())

// Shuttles
#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))
#define isdropshiparea(A) (istype(A, /area/shuttle/dropship))

// Xeno hives
#define isnormalhive(hive) (istype(hive, /datum/hive_status/normal))
#define isxenohive(A) ((A == XENO_HIVE_NONE) || (A == XENO_HIVE_NORMAL) || (A == XENO_HIVE_CORRUPTED) || (A == XENO_HIVE_ALPHA) || (A == XENO_HIVE_BETA) || (A == XENO_HIVE_ZETA) || (A == XENO_HIVE_ADMEME)) || (A == XENO_HIVE_FALLEN)

// Slot helpers
#define ishandslot(A) ((A == SLOT_L_HAND) || (A == SLOT_R_HAND))

// Objective helpers
#define ismaroonobjective(O) (istype(O, /datum/objective/maroon))
#define isstealobjective(O) (istype(O, /datum/objective/steal))
#define isassassinateobjective(O) (istype(O, /datum/objective/assassinate))
