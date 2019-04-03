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

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define iszombie(H) (is_species(H, /datum/species/zombie))
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

#define isxeno(A) (istype(A, /mob/living/carbon/Xenomorph))

//Xeno castes
#define isxenoboiler(A) (istype(A, /mob/living/carbon/Xenomorph/Boiler))
#define isxenocarrier(A) (istype(A, /mob/living/carbon/Xenomorph/Carrier))
#define isxenocrusher(A) (istype(A, /mob/living/carbon/Xenomorph/Crusher))
#define isxenodrone(A) (istype(A, /mob/living/carbon/Xenomorph/Drone))
#define isxenohivelord(A) (istype(A, /mob/living/carbon/Xenomorph/Hivelord))
#define isxenohunter(A) (istype(A, /mob/living/carbon/Xenomorph/Hunter))
#define isxenodefender(A) (istype(A, /mob/living/carbon/Xenomorph/Defender))
#define isxenopraetorian(A) (istype(A, /mob/living/carbon/Xenomorph/Praetorian))
#define isxenoravager(A) (istype(A, /mob/living/carbon/Xenomorph/Ravager))
#define isxenorunner(A) (istype(A, /mob/living/carbon/Xenomorph/Runner))
#define isxenospitter(A) (istype(A, /mob/living/carbon/Xenomorph/Spitter))
#define isxenosentinel(A) (istype(A, /mob/living/carbon/Xenomorph/Sentinel))
#define isxenowarrior(A) (istype(A, /mob/living/carbon/Xenomorph/Warrior))
#define isxenolarva(A) (istype(A, /mob/living/carbon/Xenomorph/Larva))
#define isxenoqueen(A) (istype(A, /mob/living/carbon/Xenomorph/Queen))
#define isxenoborg(A) (istype(A, /mob/living/carbon/Xenomorph/Xenoborg))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

#define iscyborg(A) (istype(A, /mob/living/silicon/robot))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ismaintdrone(A) (istype(A, /mob/living/silicon/robot/drone))

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

#define ismultitool(I) (istype(I, /obj/item/device/multitool))

#define iscrowbar(I) (istype(I, /obj/item/tool/crowbar))

#define isstructure(A) (istype(A, /obj/structure))

#define iscable(A) (istype(A, /obj/structure/cable))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ispowermachinery(A) (istype(A, /obj/machinery/power))

#define isAPC(A) (istype(A, /obj/machinery/power/apc))

#define ismecha(A) (istype(A, /obj/mecha))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define isorgan(A) (istype(A, /datum/limb))

#define isidcard(A) (istype(A, /obj/item/card/id))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/device/assembly))

#define isigniter(O) (istype(O, /obj/item/device/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/device/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/device/assembly/signaler))

#define isinfared(O) (istype(O, /obj/item/device/assembly/infra))

#define istimer(O) (istype(O, /obj/item/device/assembly/timer))

#define iseffect(O) (istype(O, /obj/effect))


//Gamemode
#define isdistress(O) (istype(O, /datum/game_mode/distress))