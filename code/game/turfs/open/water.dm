///////////// OVERLAY EFFECTS /////////////
/obj/effect/overlay/water
	icon = 'icons/turf/newwater.dmi'
	icon_state = "bottom"
	density = 0
	mouse_opacity = 0
	layer = BELOW_MOB_LAYER
	anchored = TRUE

/obj/effect/overlay/water/top
	icon_state = "top"
	layer = BELOW_MOB_LAYER


/turf/open/water
	gender = PLURAL
	name = ""
	desc = ""
	icon = null
	icon_state = ""
	baseturfs = /turf/open/water
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	slowdown = 5
	var/obj/effect/overlay/water/water_overlay
	var/obj/effect/overlay/water/top/water_top_overlay
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/mineral,/turf/closed/wall/mineral/rogue, /turf/open/floor/rogue)
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	landsound = 'sound/foley/jumpland/waterland.wav'
	neighborlay_override = "edge"
	var/water_color = "#6a9295"
	var/water_reagent = /datum/reagent/water
	var/water_level = 2
	var/wash_in = TRUE
	var/swim_skill = FALSE
	nomouseover = FALSE
	var/swimdir = FALSE

/turf/open/water/Initialize()
	.  = ..()
	water_overlay = new(src)
	water_top_overlay = new(src)
	update_icon()

/turf/open/water/update_icon()
	if(water_overlay)
		water_overlay.color = water_color
		water_overlay.icon_state = "bottom[water_level]"
	if(water_top_overlay)
		water_top_overlay.color = water_color
		water_top_overlay.icon_state = "top[water_level]"

/turf/open/water/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	for(var/obj/structure/S in src)
		if(S.obj_flags & BLOCK_Z_OUT_DOWN)
			return
	if(isliving(AM) && !AM.throwing)
		var/mob/living/user = AM
		if(water_overlay)
			if((get_dir(src, newloc) == SOUTH))
				water_overlay.layer = BELOW_MOB_LAYER
				water_overlay.plane = GAME_PLANE
			else
				spawn(6)
					if(!locate(/mob/living) in src)
						water_overlay.layer = BELOW_MOB_LAYER
						water_overlay.plane = GAME_PLANE
		for(var/D in GLOB.cardinals) //adjacent to a floor to hold onto
			if(istype(get_step(newloc, D), /turf/open/floor))
				return
		if(swim_skill)
			if(swimdir && newloc) //we're being pushed by water or swimming with the current, easy
				if(get_dir(src, newloc) == dir)
					return
			if(user.mind && !user.buckled)
				var/drained = max(15 - (user.mind.get_skill_level(/datum/skill/misc/swimming) * 5), 1)
//				drained += (user.checkwornweight()*2)
				if(!user.check_armor_skill())
					drained += 40
				if(!user.rogfat_add(drained))
					user.Immobilize(30)
					addtimer(CALLBACK(user, /mob/living/.proc/Knockdown, 30), 10)

/turf/open/water/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	playsound(src, pick('sound/foley/water_land1.ogg','sound/foley/water_land2.ogg','sound/foley/water_land3.ogg'), 100, FALSE)


/turf/open/water/cardinal_smooth(adjacencies)
	roguesmooth(adjacencies)

/turf/open/water/roguesmooth(adjacencies)
	var/list/Yeah = ..()
	if(water_overlay)
		water_overlay.cut_overlays(TRUE)
		if(Yeah)
			water_overlay.add_overlay(Yeah)
	if(water_top_overlay)
		water_top_overlay.cut_overlays(TRUE)
		if(Yeah)
			water_top_overlay.add_overlay(Yeah)

/turf/open/water/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	for(var/obj/structure/S in src)
		if(S.obj_flags & BLOCK_Z_OUT_DOWN)
			return
	if(isliving(AM) && !AM.throwing)
		var/mob/living/L = AM
		if(L.lying || water_level == 3)
			L.SoakMob(FULL_BODY)
		else
			if(water_level == 2)
				L.SoakMob(BELOW_CHEST)
		if(water_overlay)
			if(water_level > 1)
				if(istype(oldLoc, type))
					playsound(AM, pick('sound/foley/watermove (1).ogg','sound/foley/watermove (2).ogg'), 100, FALSE)
				else
					playsound(AM, 'sound/foley/waterenter.ogg', 100, FALSE)
			if(istype(oldLoc, type) && (get_dir(src, oldLoc) != SOUTH))
				water_overlay.layer = ABOVE_MOB_LAYER
				water_overlay.plane = GAME_PLANE_UPPER
			else
				spawn(6)
					if(AM.loc == src)
						water_overlay.layer = ABOVE_MOB_LAYER
						water_overlay.plane = GAME_PLANE_UPPER

/turf/open/water/attackby(obj/item/C, mob/user, params)
	if(user.used_intent.type == /datum/intent/fill)
		if(C.reagents)
			if(C.reagents.holder_full())
				to_chat(user, "<span class='warning'>[C] is full.</span>")
				return
			if(do_after(user, 8, target = src))
				user.changeNext_move(CLICK_CD_MELEE)
				playsound(user, 'sound/foley/drawwater.ogg', 100, FALSE)
				var/list/L = list()
				L[water_reagent] = 100
				C.reagents.add_reagent_list(L)
				to_chat(user, "<span class='notice'>I fill [C] from [src].</span>")
			return
	. = ..()

/turf/open/water/attack_right(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.stat != CONSCIOUS)
			return
		var/list/wash = list('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg')
		playsound(user, pick_n_take(wash), 100, FALSE)
		var/item2wash = user.get_active_held_item()
		if(!item2wash)
			user.visible_message("<span class='info'>[user] starts to wash in [src].</span>")
			if(do_after(L, 30, target = src))
				if(wash_in)
					wash_atom(user, CLEAN_STRONG)
				playsound(user, pick(wash), 100, FALSE)
/*				if(water_reagent == /datum/reagent/water) //become shittified, checks so bath water can be naturally gross but not discolored
					water_reagent = /datum/reagent/water/gross
					water_color = "#a4955b"
					update_icon()*/
		else
			user.visible_message("<span class='info'>[user] starts to wash [item2wash] in [src].</span>")
			if(do_after(L, 30, target = src))
				if(wash_in)
					wash_atom(item2wash, CLEAN_STRONG)
				playsound(user, pick(wash), 100, FALSE)
		return
	..()

/turf/open/water/onbite(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.stat != CONSCIOUS)
			return
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(C.is_mouth_covered())
				return
		playsound(user, pick('sound/foley/waterwash (1).ogg','sound/foley/waterwash (2).ogg'), 100, FALSE)
		user.visible_message("<span class='info'>[user] starts to drink from [src].</span>")
		if(do_after(L, 25, target = src))
			var/list/waterl = list()
			waterl[water_reagent] = 2
			var/datum/reagents/reagents = new()
			reagents.add_reagent_list(waterl)
			reagents.trans_to(L, reagents.total_volume, transfered_by = user, method = INGEST)
			playsound(user,pick('sound/items/drink_gen (1).ogg','sound/items/drink_gen (2).ogg','sound/items/drink_gen (3).ogg'), 100, TRUE)
		return
	..()

/turf/open/water/Destroy()
	. = ..()
	if(water_overlay)
		QDEL_NULL(water_overlay)
	if(water_top_overlay)
		QDEL_NULL(water_top_overlay)

/turf/open/water/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		var/obj/O = AM
		O.extinguish()

/turf/open/water/get_slowdown(mob/user)
	var/returned = slowdown
	if(user.mind && swim_skill)
		returned = returned - (user.mind.get_skill_level(/datum/skill/misc/swimming))
	return returned

//turf/open/water/Initialize()
//	dir = pick(NORTH,SOUTH,WEST,EAST)
//	. = ..()


/turf/open/water/bath
	name = "water"
	desc = ""
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "bathtileW"
	water_level = 2
	water_color = "#FFFFFF"
	slowdown = 3
	water_reagent = /datum/reagent/water/gross

/turf/open/water/bath/Initialize()
	.  = ..()
	icon_state = "bathtile"

/turf/open/water/sewer
	name = "sewage"
	desc = ""
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "pavingW"
	water_level = 1
	water_color = "#705a43"
	slowdown = 1
	wash_in = FALSE
	water_reagent = /datum/reagent/water/gross

/turf/open/water/sewer/Initialize()
	icon_state = "paving"
	water_color = pick("#705a43","#697043")
	.  = ..()

/turf/open/water/swamp
	name = "murk"
	desc = ""
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "dirtW2"
	water_level = 2
	water_color = "#705a43"
	slowdown = 3
	wash_in = TRUE
	water_reagent = /datum/reagent/water/gross

/turf/open/water/swamp/Initialize()
	icon_state = "dirt"
	dir = pick(GLOB.cardinals)
	water_color = pick("#705a43")
	.  = ..()

/turf/open/water/swamp/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		if(!prob(3))
			return
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(C.blood_volume <= 0)
				return
			var/zonee = list(BODY_ZONE_R_LEG,BODY_ZONE_L_LEG)
			for(var/X in zonee)
				var/obj/item/bodypart/BP = C.get_bodypart(X)
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				var/obj/item/natural/worms/leeches/I = new(C)
				BP.embedded_objects |= I
				return .

/turf/open/water/swamp/deep
	name = "murk"
	icon_state = "dirtW"
	water_level = 3
	water_color = "#705a43"
	slowdown = 5
	swim_skill = TRUE

/turf/open/water/swamp/deep/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		if(!prob(8))
			return
		if(iscarbon(AM))
			var/mob/living/carbon/C = AM
			if(C.blood_volume <= 0)
				return
			var/zonee = list(BODY_ZONE_CHEST,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_R_ARM,BODY_ZONE_L_ARM)
			for(var/X in zonee)
				var/obj/item/bodypart/BP = C.get_bodypart(X)
				if(!BP)
					continue
				if(BP.skeletonized)
					continue
				var/obj/item/natural/worms/leeches/I = new(C)
				BP.embedded_objects |= I
				return .

/turf/open/water/cleanshallow
	name = "water"
	desc = ""
	icon = 'icons/turf/roguefloor.dmi'
	icon_state = "rockw2"
	water_level = 2
	slowdown = 3
	wash_in = TRUE
	water_reagent = /datum/reagent/water

/turf/open/water/cleanshallow/Initialize()
	icon_state = "rock"
	dir = pick(GLOB.cardinals)
	.  = ..()


/turf/open/water/river
	name = "water"
	icon_state = "rockwd"
	icon = 'icons/turf/roguefloor.dmi'
	water_level = 3
	slowdown = 5
	wash_in = TRUE
	swim_skill = TRUE
	var/river_processing
	swimdir = TRUE

/turf/open/water/river/update_icon()
	if(water_overlay)
		water_overlay.color = water_color
		water_overlay.icon_state = "riverbot"
		water_overlay.dir = dir
	if(water_top_overlay)
		water_top_overlay.color = water_color
		water_top_overlay.icon_state = "rivertop"
		water_top_overlay.dir = dir

/turf/open/water/river/Initialize()
	icon_state = "rock"
	.  = ..()

/turf/open/water/river/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(isliving(AM))
		if(!river_processing)
			river_processing = addtimer(CALLBACK(src, .proc/process_river), 5, TIMER_STOPPABLE)

/turf/open/water/river/proc/process_river()
	river_processing = null
	for(var/atom/movable/A in contents)
		if((A.loc == src) && A.has_gravity())
			A.ConveyorMove(dir)