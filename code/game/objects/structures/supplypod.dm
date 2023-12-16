
GLOBAL_LIST_INIT(pod_styles, list(\
	list("supplypod", "supply pod", "A Nanotrasen supply drop pod.", STYLE_STANDARD),\
	list("bluespacepod", "bluespace supply pod" , "A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery.", STYLE_BLUESPACE),\
	list("centcompod", "\improper Centcom supply pod", "A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to Centcom after delivery.", STYLE_CENTCOM),\
	list("syndiepod", "blood-red supply pod", "A dark, intimidating supply pod, covered in the blood-red markings of the Syndicate. It's probably best to stand back from this.", STYLE_SYNDICATE),\
	list("squadpod", "\improper MK. II supply pod", "A Nanotrasen supply pod. This one has been marked the markings of some sort of elite strike team.", STYLE_BLUE),\
	list("cultpod", "bloody supply pod", "A Nanotrasen supply pod covered in scratch-marks, blood, and strange runes.", STYLE_CULT),\
	list("missilepod", "cruise missile", "A big ass missile that didn't seem to fully detonate. It was likely launched from some far-off deep space missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible.", STYLE_MISSILE),\
	list("smissilepod", "\improper Syndicate cruise missile", "A big ass, blood-red missile that didn't seem to fully detonate. It was likely launched from some deep space Syndicate missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible.", STYLE_RED_MISSILE),\
	list("boxpod", "\improper Aussec supply crate", "An incredibly sturdy supply crate, designed to withstand orbital re-entry. Has 'Aussec Armory - 2532' engraved on the side.", STYLE_BOX),\
	list("honkpod", "\improper HONK pod", "A brightly-colored supply pod. It likely originated from the Clown Federation.", STYLE_HONK),\
	list("fruitpod", "\improper Orange", "An angry orange.", STYLE_FRUIT),\
	list("", "\improper S.T.E.A.L.T.H. pod MKVII", "A supply pod that, under normal circumstances, is completely invisible to conventional methods of detection. How are you even seeing this?", STYLE_INVISIBLE),\
	list("gondolapod", "gondola", "The silent walker. This one seems to be part of a delivery agency.", STYLE_GONDOLA),\
	list("", "", "", STYLE_SEETHROUGH)\
))


/obj/structure/closet/supplypod
	name = "supply pod"
	desc = "A Nanotrasen supply drop pod."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "supplypod"
	pixel_x = -16
	pixel_y = -5
	layer = TABLE_LAYER
	closet_flags = CLOSET_ALLOW_OBJS|CLOSET_ALLOW_DENSE_OBJ
	soft_armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 100, BIO = 0, FIRE = 100, ACID = 80)
	anchored = TRUE
	flags_atom = PREVENT_CONTENTS_EXPLOSION
	var/adminNamed = FALSE
	var/bluespace = FALSE
	var/landingDelay = 30
	var/openingDelay = 30
	var/departureDelay = 30
	var/damage = 0
	var/effectStun = FALSE
	var/effectLimb = FALSE
	var/effectOrgans = FALSE
	var/effectGib = FALSE
	var/effectStealth = FALSE
	var/effectQuiet = FALSE
	var/effectMissile = FALSE
	var/effectCircle = FALSE
	var/style = STYLE_STANDARD
	var/reversing = FALSE
	var/fallDuration = 4
	var/fallingSoundLength = 11
	var/fallingSound = 'sound/weapons/guns/misc/mortar_long_whistle.ogg'
	var/landingSound
	var/openingSound
	var/leavingSound
	var/soundVolume = 80
	var/bay
	var/list/explosionSize = list(0, 0, 2, 3)


/obj/structure/closet/supplypod/bluespacepod
	style = STYLE_BLUESPACE
	bluespace = TRUE
	explosionSize = list(0, 0, 1, 2)
	landingDelay = 15


/obj/structure/closet/supplypod/centcompod
	style = STYLE_CENTCOM
	bluespace = TRUE
	explosionSize = list(0, 0, 0, 0)
	landingDelay = 20
	resistance_flags = RESIST_ALL


/obj/structure/closet/supplypod/Initialize(mapload)
	. = ..()
	setStyle(style, TRUE)


/obj/structure/closet/supplypod/update_icon()
	cut_overlays()
	if(style == STYLE_SEETHROUGH || style == STYLE_INVISIBLE)
		return

	if(opened)
		add_overlay("[icon_state]_open")
	else
		add_overlay("[icon_state]_door")


/obj/structure/closet/supplypod/proc/setStyle(chosenStyle, duringInit = FALSE)
	if(!duringInit && style == chosenStyle)
		setStyle(STYLE_CENTCOM)
		return
	style = chosenStyle
	icon_state = GLOB.pod_styles[chosenStyle][POD_ICON_STATE]
	if(!adminNamed)
		name = GLOB.pod_styles[chosenStyle][POD_NAME]
		desc = GLOB.pod_styles[chosenStyle][POD_DESC]
	update_icon()


/obj/structure/closet/supplypod/ex_act()
	return


/obj/structure/closet/supplypod/toggle(mob/living/user)
	return


/obj/structure/closet/supplypod/proc/preOpen()
	var/turf/T = get_turf(src)
	var/list/B = explosionSize

	if(landingSound)
		playsound(get_turf(src), landingSound, soundVolume, 0, 0)

	for(var/mob/living/L in T)
		if(effectLimb && ishuman(L))
			var/mob/living/carbon/human/H = L
			for(var/datum/limb/E in H.limbs)
				if(istype(E, /datum/limb/chest) || istype(E, /datum/limb/groin) || istype(E, /datum/limb/head))
					continue
				E.droplimb()

		if(effectOrgans && ishuman(L))
			var/mob/living/carbon/human/H = L
			for(var/datum/internal_organ/IO in H.internal_organs)
				var/destination = get_edge_target_turf(T, pick(GLOB.alldirs))
				var/obj/item/organ/O = IO.remove(H)
				O.forceMove(T)
				O.throw_at(destination, 2, 3)
				sleep(0.1 SECONDS)

		if(effectGib)
			L.adjustBruteLoss(5000)
			L.gib()
			continue

		L.adjustBruteLoss(damage)
		UPDATEHEALTH(L)

	var/explosion_sum = B[1] + B[2] + B[3] + B[4]
	if(explosion_sum != 0)
		explosion(get_turf(src), B[1], B[2], B[3], 0, B[4])
	else if(!effectQuiet)
		playsound(src, "explosion", landingSound ? 15 : 80, 1)

	if(effectMissile)
		opened = TRUE
		qdel(src)
		return
	if(style == STYLE_SEETHROUGH)
		open(src)
	else
		addtimer(CALLBACK(src, PROC_REF(open), src), openingDelay)



/obj/structure/closet/supplypod/prevent_content_explosion()
	return TRUE


/obj/structure/closet/supplypod/open(atom/movable/holder, broken = FALSE, forced = FALSE)
	if(!holder)
		return
	if(opened)
		return
	opened = TRUE
	var/turf/T = get_turf(holder)
	var/mob/M
	if(istype(holder, /mob))
		M = holder
		if(M.key && !forced && !broken)
			return
	if(openingSound)
		playsound(get_turf(holder), openingSound, soundVolume, 0, 0)
	INVOKE_ASYNC(holder, PROC_REF(setOpened))
	if(style == STYLE_SEETHROUGH)
		update_icon()
	for(var/i in holder.contents)
		var/atom/movable/AM = i
		AM.forceMove(T)
	if(!effectQuiet && !openingSound && style != STYLE_SEETHROUGH)
		playsound(get_turf(holder), open_sound, 15, 1, -3)
	if(broken)
		return
	if(style == STYLE_SEETHROUGH)
		depart(src)
	else
		addtimer(CALLBACK(src, PROC_REF(depart), holder), departureDelay)


/obj/structure/closet/supplypod/proc/depart(atom/movable/holder)
	if(leavingSound)
		playsound(get_turf(holder), leavingSound, soundVolume, 0, 0)
	if(reversing)
		close(holder)
	else if(bluespace)
		if(!effectQuiet && style != STYLE_INVISIBLE && style != STYLE_SEETHROUGH)
			var/datum/effect_system/spark_spread/sparks = new
			sparks.set_up(5, TRUE, get_turf(src))
			sparks.start()
		qdel(src)
		if(holder != src)
			qdel(holder)


/obj/structure/closet/supplypod/centcompod/close(atom/movable/holder)
	opened = FALSE
	INVOKE_ASYNC(holder, PROC_REF(setClosed))
	for(var/i in get_turf(holder))
		var/atom/movable/AM = i
		if(ismob(AM) && !isliving(AM))
			continue
		AM.forceMove(holder)
	var/obj/effect/temp_visual/risingPod = new /obj/effect/DPfall(get_turf(holder), src)
	risingPod.pixel_z = 0
	holder.forceMove(bay)
	animate(risingPod, pixel_z = 200, time = 10, easing = LINEAR_EASING)
	QDEL_IN(risingPod, 10)
	reversing = FALSE
	open(holder, forced = TRUE)


/obj/structure/closet/supplypod/proc/setOpened()
	update_icon()


/obj/structure/closet/supplypod/proc/setClosed()
	update_icon()


/obj/structure/closet/supplypod/Destroy()
	open(src, broken = TRUE)
	return ..()


/obj/effect/DPfall
	name = ""
	icon = 'icons/obj/supplypods.dmi'
	pixel_x = -16
	pixel_y = -5
	pixel_z = 200
	desc = "Get out of the way!"
	layer = FLY_LAYER
	icon_state = ""


/obj/effect/DPfall/Initialize(mapload, obj/structure/closet/supplypod/pod)
	if(!pod)
		return INITIALIZE_HINT_QDEL
	if(pod.style == STYLE_SEETHROUGH)
		pixel_x = -16
		pixel_y = 0
		for(var/i in pod.contents)
			var/atom/movable/AM = i
			var/icon/I = getFlatIcon(AM)
			add_overlay(I)

	else if(pod.style != STYLE_INVISIBLE)
		icon_state = "[pod.icon_state]_falling"
		name = pod.name

	return ..()


/obj/effect/DPtarget
	name = "Landing Zone Indicator"
	desc = "A holographic projection designating the landing zone of something. It's probably best to stand back."
	icon = 'icons/mob/actions.dmi'
	icon_state = "sniper_zoom"
	layer = XENO_HIDING_LAYER
	var/obj/effect/temp_visual/fallingPod
	var/obj/structure/closet/supplypod/pod


/obj/effect/ex_act()
	return


/obj/effect/DPtarget/Initialize(mapload, podParam, single_order)
	. = ..()
	if(!podParam)
		return INITIALIZE_HINT_QDEL
	if(ispath(podParam))
		podParam = new podParam()
	pod = podParam
	if(single_order)
		if(istype(single_order, /datum/supply_packs))
			var/datum/supply_packs/S = single_order
			S.generate(pod)
		else if(istype(single_order, /atom/movable))
			var/atom/movable/O = single_order
			O.forceMove(pod)
	for(var/mob/living/L in pod)
		L.forceMove(src)
	if(pod.effectStun)
		for(var/mob/living/M in get_turf(src))
			M.Stun((pod.landingDelay + 10) * 20)
	if(pod.effectStealth)
		icon_state = ""
	if(pod.fallDuration == initial(pod.fallDuration) && pod.landingDelay + pod.fallDuration < pod.fallingSoundLength)
		pod.fallingSoundLength = 3
		pod.fallingSound = 'sound/weapons/guns/misc/mortar_whistle.ogg'
	var/soundStartTime = pod.landingDelay - pod.fallingSoundLength + pod.fallDuration
	if(soundStartTime < 0)
		soundStartTime = 1
	if(!pod.effectQuiet)
		addtimer(CALLBACK(src, PROC_REF(playFallingSound)), soundStartTime)
	addtimer(CALLBACK(src, PROC_REF(beginLaunch), pod.effectCircle), pod.landingDelay)


/obj/effect/DPtarget/proc/playFallingSound()
	playsound(src, pod.fallingSound, pod.soundVolume, 1, 6)


/obj/effect/DPtarget/proc/beginLaunch(effectCircle)
	fallingPod = new /obj/effect/DPfall(get_turf(src), pod)
	var/matrix/M = matrix(fallingPod.transform)
	var/angle = effectCircle ? rand(0, 360) : rand(70, 110)
	fallingPod.pixel_x = cos(angle) * 400
	fallingPod.pixel_z = sin(angle) * 400
	var/rotation = Get_Pixel_Angle(fallingPod.pixel_z, fallingPod.pixel_x)
	M.Turn(rotation)
	fallingPod.transform = M
	M = matrix(pod.transform)
	M.Turn(rotation)
	pod.transform = M
	animate(fallingPod, pixel_z = 0, pixel_x = -16, time = pod.fallDuration, , easing = LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(endLaunch)), pod.fallDuration, TIMER_CLIENT_TIME)


/obj/effect/DPtarget/proc/endLaunch()
	pod.update_icon()
	pod.forceMove(get_turf(src))
	QDEL_NULL(fallingPod)
	for(var/mob/living/M in src)
		M.forceMove(pod)
	pod.preOpen()
	qdel(src)
