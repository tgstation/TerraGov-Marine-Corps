#define islist(L) (istype(L, /list))

#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

#define ismovableatom(A) (istype(A, /atom/movable))

#define isatom(A) (isloc(A))

//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

#define isopenturf(A) (istype(A, /turf/open))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define isrwallturf(A) (istype(A, /turf/closed/wall/r_wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))


//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

#define isnestedhost(A)	((CHECK_BITFIELD(A.status_flags, XENO_HOST) && istype(A.buckled, /obj/structure/bed/nest)))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define ishorror(H) (is_species(H, datum/species/spook))
#define isunathi(H) (is_species(H, /datum/species/unathi))
#define istajaran(H) (is_species(H, /datum/species/tajaran))
#define isskrell(H) (is_species(H, /datum/species/skrell))
#define isvox(H) (is_species(H, /datum/species/vox))
#define isvoxarmalis(H) (is_species(H, /datum/species/vox/armalis))
#define isIPC(H) (is_species(H, /datum/species/machine))
#define issynth(H) (is_species(H, /datum/species/synthetic) || is_species(H, /datum/species/early_synthetic))
#define ismoth(H) (is_species(H, /datum/species/moth))
#define ishumanbasic(H) (is_species(H, /datum/species/human))

//Job/role helpers
#define issurvivor(H) (H?.mind?.assigned_role == "Survivor")
#define ismarine(H) (H?.faction == "Marine" && (H?.mind?.assigned_role in JOBS_MARINES))
#define ispmc(H) (H?.faction == "PMC")

//more carbon mobs
#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

//Monkey sub-species
#define ismonkeytajaran(M) (istype(M, /mob/living/carbon/monkey/tajara))
#define ismonkeyskrell(M) (istype(M, /mob/living/carbon/monkey/skrell))
#define ismonkeyunathi(M) (istype(M, /mob/living/carbon/monkey/unathi))
#define ismonkeyyiren(M) (istype(M, /mob/living/carbon/monkey/yiren))

#define isxeno(A) (istype(A, /mob/living/carbon/xenomorph))

//Xeno castes
#define isxenoboiler(A) (istype(A, /mob/living/carbon/xenomorph/boiler))
#define isxenocarrier(A) (istype(A, /mob/living/carbon/xenomorph/carrier))
#define isxenocrusher(A) (istype(A, /mob/living/carbon/xenomorph/crusher))
#define isxenodrone(A) (istype(A, /mob/living/carbon/xenomorph/drone))
#define isxenohivelord(A) (istype(A, /mob/living/carbon/xenomorph/hivelord))
#define isxenohunter(A) (istype(A, /mob/living/carbon/xenomorph/hunter))
#define isxenodefender(A) (istype(A, /mob/living/carbon/xenomorph/defender))
#define isxenopraetorian(A) (istype(A, /mob/living/carbon/xenomorph/praetorian))
#define isxenoravager(A) (istype(A, /mob/living/carbon/xenomorph/ravager))
#define isxenorunner(A) (istype(A, /mob/living/carbon/xenomorph/runner))
#define isxenospitter(A) (istype(A, /mob/living/carbon/xenomorph/spitter))
#define isxenosentinel(A) (istype(A, /mob/living/carbon/xenomorph/sentinel))
#define isxenowarrior(A) (istype(A, /mob/living/carbon/xenomorph/warrior))
#define isxenolarva(A) (istype(A, /mob/living/carbon/xenomorph/larva))
#define isxenoqueen(A) (istype(A, /mob/living/carbon/xenomorph/queen))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

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

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define iswrench(I) (istype(I, /obj/item/tool/wrench))

#define iswelder(I) (istype(I, /obj/item/tool/weldingtool))

#define iscablecoil(I) (istype(I, /obj/item/stack/cable_coil))

#define iswirecutter(I) (istype(I, /obj/item/tool/wirecutters))

#define isscrewdriver(I) (istype(I, /obj/item/tool/screwdriver))

#define ismultitool(I) (istype(I, /obj/item/multitool))

#define iscrowbar(I) (istype(I, /obj/item/tool/crowbar))

#define isstructure(A) (istype(A, /obj/structure))

#define iscable(A) (istype(A, /obj/structure/cable))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ispowermachinery(A) (istype(A, /obj/machinery/power))

#define isAPC(A) (istype(A, /obj/machinery/power/apc))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define isorgan(A) (istype(A, /datum/limb))

#define isidcard(A) (istype(A, /obj/item/card/id))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/assembly))

#define isigniter(O) (istype(O, /obj/item/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/assembly/signaler))

#define isinfared(O) (istype(O, /obj/item/assembly/infra))

#define istimer(O) (istype(O, /obj/item/assembly/timer))

#define iseffect(O) (istype(O, /obj/effect))


//Gamemode
#define isdistress(O) (istype(O, /datum/game_mode/distress))


// Admin
#define isaghost(mob) ( copytext(mob.key, 1, 2) == "@" )

// Shuttles
#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))
