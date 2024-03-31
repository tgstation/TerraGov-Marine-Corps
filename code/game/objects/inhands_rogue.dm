/obj/item
	var/list/onprop = list()
//#ifdef TESTSERVER
	var/force_reupdate_inhand = TRUE
//#else
//	var/force_reupdate_inhand = FALSE
//#endif

/obj/item/inhand_tester
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "inhand_test"

/obj/item/inhand_tester/big
	icon = 'icons/roguetown/misc/64x64.dmi'

/obj/item/proc/getmoboverlay(tag, prop, behind = FALSE, mirrored = FALSE)
	var/used_index = icon_state
	var/extra_index = get_extra_onmob_index()
	if(extra_index) //WIP, unimplemented
		used_index += extra_index
	if(HAS_BLOOD_DNA(src))
		used_index += "_b"
	var/static/list/onmob_sprites = list()
	var/icon/onmob = onmob_sprites["[tag][behind][mirrored][used_index]"]
	if(!onmob || force_reupdate_inhand)
		onmob = fcopy_rsc(generateonmob(tag, prop, behind, mirrored))
		onmob_sprites["[tag][behind][mirrored][used_index]"] = onmob
	return onmob

/obj/item/proc/get_extra_onmob_index()
	//perhaps in the future: force items like flasks to use getflaticon to get their filled states and drinking cups too. that's all
	return

/obj/item/proc/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.2,"sx" = -7,"sy" = -4,"nx" = 7,"ny" = -4,"wx" = -4,"wy" = -4,"ex" = 2,"ey" = -4,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
			if("wielded")
				return null
			if("altgrip")
				return null
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = 1,"sy" = -1,"nx" = 1,"ny" = -1,"wx" = 4,"wy" = -1,"ex" = -1,"ey" = -1,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 8,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/obj/item/proc/mirror_fix(shrink, big)
	if(!shrink)
		return FALSE
	switch(shrink)
		if(0.5)
			return 1
		if(0.6)
			if(big)
				return 1
			else
				return 2
		if(0.7)
			return 1

/obj/item/proc/generateonmob(tag, prop, behind, mirrored)
	var/list/used_prop = prop
	var/UH = 64
	var/UW = 64
	var/used_mask = 'icons/roguetown/helpers/inhand_64.dmi'
	var/icon/returned = icon(used_mask, "blank")
	var/icon/blended
//	var/skipoverlays = FALSE
	if(behind)
		var/icon/J = new(icon)
		var/list/istates = J.IconStates()
		if(istates.Find("[icon_state]_behind"))
			blended=icon("icon"=icon, "icon_state"="[icon_state]_behind")
//			skipoverlays = TRUE
		else
		//	blended=icon("icon"=icon, "icon_state"=icon_state)
//			blended=getFlatIcon(src)
			blended=icon("icon"=icon, "icon_state"=icon_state)
	else
	//	blended=icon("icon"=icon, "icon_state"=icon_state)
//		blended=getFlatIcon(src)
		blended=icon("icon"=icon, "icon_state"=icon_state)

	if(!blended)
		blended=getFlatIcon(src)

	if(!blended)
		return

//	if(color) //getflat does this i think?
//		blended.Blend(color,ICON_MULTIPLY)

//	if(!skipoverlays)
//		for(var/V in overlays)
//			var/image/IM = V
//			var/icon/image_overlay = new(IM.icon,IM.icon_state)
//			if(IM.color)
//				image_overlay.Blend(IM.color,ICON_MULTIPLY)
//			blended.Blend(image_overlay,ICON_OVERLAY)

	var/icon/holder
	if(blended.Height() == 32)
		UW = 32
		UH = 32
		used_mask = 'icons/roguetown/helpers/inhand.dmi'
	var/icon/masky
	var/px = 0
	var/py = 0
	var/ax = 0
	var/usedtag

	//north
	var/render_this_dir = FALSE
	if(!behind)
		if(used_prop["northabove"] == 1)
			render_this_dir = TRUE
	else
		if(used_prop["northabove"] == 0)
			render_this_dir = TRUE
	if(render_this_dir)
		holder = icon(blended)
		masky = icon("icon"=used_mask, "icon_state"="north")
		holder.Blend(masky, ICON_MULTIPLY)
		if("nflip" in used_prop)
			holder.Flip(used_prop["nflip"])
		if("nturn" in used_prop)
			holder.Turn(used_prop["nturn"])
		if("nx" in used_prop)
			if(mirrored)
				px += used_prop["nx"]*-1
				var/biggu = FALSE
				if(UH > 32)
					biggu = TRUE
				if(mirror_fix(used_prop["shrink"], biggu))
					px += mirror_fix(used_prop["shrink"], biggu)
//				if(UH == 64)
//				else
			else
				px += used_prop["nx"]
		if("ny" in used_prop)
			py = used_prop["ny"]
		ax = 0
		if("shrink" in used_prop)
			holder.Scale(UW*used_prop["shrink"],UH*used_prop["shrink"])
			ax = 32-(holder.Width()/2)
		px += ax
		py += ax
		if(mirrored)
			holder.Flip(WEST)
		returned.Blend(holder,ICON_OVERLAY,x=px,y=py)

	//south
	render_this_dir = FALSE
	if(!behind)
		if(used_prop["southabove"] == 1)
			render_this_dir = TRUE
	else
		if(used_prop["southabove"] == 0)
			render_this_dir = TRUE
	if(render_this_dir)
		px = 0
		py = 0
		holder = icon(blended)
		masky = icon("icon"=used_mask, "icon_state"="south")
		holder.Blend(masky, ICON_MULTIPLY)
		if("sflip" in used_prop)
			holder.Flip(used_prop["sflip"])
		if("sturn" in used_prop)
			holder.Turn(used_prop["sturn"])
		if("sx" in used_prop)
			if(mirrored)
				px += used_prop["sx"]*-1
				var/biggu = FALSE
				if(UH > 32)
					biggu = TRUE
				if(mirror_fix(used_prop["shrink"], biggu))
					px += mirror_fix(used_prop["shrink"], biggu)
//				if(UH == 64)
//				else
			else
				px += used_prop["sx"]
		if("sy" in used_prop)
			py += used_prop["sy"]
		ax = 0
		if("shrink" in used_prop)
			holder.Scale(UW*used_prop["shrink"],UH*used_prop["shrink"])
			ax = 32-(holder.Width()/2)
		px += ax
		py += ax
		if(mirrored)
			holder.Flip(EAST)
		returned.Blend(holder,ICON_OVERLAY,x=px,y=py)

	//east
	render_this_dir = FALSE
	var/t2us = "eastabove"
	if(mirrored)
		t2us = "westabove"
	if(!behind)
		if(used_prop[t2us] == 1)
			render_this_dir = TRUE
	else
		if(used_prop[t2us] == 0)
			render_this_dir = TRUE
	if(render_this_dir)
		usedtag = "e"
		if(mirrored)
			usedtag = "w"
		px = 0
		py = 0
		holder = icon(blended)
		masky = icon("icon"=used_mask, "icon_state"="east")
		holder.Blend(masky, ICON_MULTIPLY)
		if("[usedtag]flip" in used_prop)
			holder.Flip(used_prop["[usedtag]flip"])
		if("[usedtag]turn" in used_prop)
			holder.Turn(used_prop["[usedtag]turn"])
		if("[usedtag]x" in used_prop)
			px = used_prop["[usedtag]x"]
			if(mirrored)
				px = px*-1
		if("[usedtag]y" in used_prop)
			py = used_prop["[usedtag]y"]
		ax = 0
		if("shrink" in used_prop)
			holder.Scale(UW*used_prop["shrink"],UH*used_prop["shrink"])
			ax = 32-(holder.Width()/2)
		px += ax
		py += ax
		if(mirrored)
			holder.Flip(EAST)
		returned.Blend(holder,ICON_OVERLAY,x=px,y=py)

	//west
	render_this_dir = FALSE
	t2us = "westabove"
	if(mirrored)
		t2us = "eastabove"
	if(!behind)
		if(used_prop[t2us] == 1)
			render_this_dir = TRUE
	else
		if(used_prop[t2us] == 0)
			render_this_dir = TRUE
	if(render_this_dir)
		usedtag = "w"
		if(mirrored)
			usedtag = "e"
		px = 0
		py = 0
		holder = icon(blended)
		masky = icon("icon"=used_mask, "icon_state"="west")
		holder.Blend(masky, ICON_MULTIPLY)
		if("[usedtag]flip" in used_prop)
			holder.Flip(used_prop["[usedtag]flip"])
		if("[usedtag]turn" in used_prop)
			holder.Turn(used_prop["[usedtag]turn"])
		if("[usedtag]x" in used_prop)
			px = used_prop["[usedtag]x"]
			if(mirrored)
				px = px*-1
		if("[usedtag]y" in used_prop)
			py = used_prop["[usedtag]y"]
		ax = 0
		if("shrink" in used_prop)
			holder.Scale(UW*used_prop["shrink"],UH*used_prop["shrink"])
			ax = 32-(holder.Width()/2)
		px += ax
		py += ax
		if(mirrored)
			holder.Flip(EAST)
		returned.Blend(holder,ICON_OVERLAY,x=px,y=py)


	return returned

#ifdef TESTSERVER

/client/verb/output_inhands()
	set category = "INHANDS"
	set name = "Output Variables"
	set desc = ""

	var/mob/living/carbon/human/LI = mob
	var/obj/item/I = LI.get_active_held_item()
	if(!I)
		I = LI.beltr
	if(!I)
		I = LI.beltl
	if(!I)
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		for(var/X in I.onprop)
			var/list/L = I.onprop[X]
			var/list/tegst = list()
			to_chat(mob, "\"[X]\"")
			tegst += "return list("
			if(L && L.len)
				for(var/P in L)
					tegst += "\"[P]\" = [L[P]],"
			to_chat(mob, "[tegst.Join()]")

/client/verb/inhand_xplus()
	set category = "INHANDS"
	set name = "X+1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "nx"
		if(SOUTH)
			needtofind = "sx"
		if(WEST)
			needtofind = "wx"
		if(EAST)
			needtofind = "ex"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					for(var/P in L)
						if(P == needtofind)
							L[P] += 1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_xminus()
	set category = "INHANDS"
	set name = "X-1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "nx"
		if(SOUTH)
			needtofind = "sx"
		if(WEST)
			needtofind = "wx"
		if(EAST)
			needtofind = "ex"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					for(var/P in L)
						if(P == needtofind)
							L[P] -= 1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_yplus()
	set category = "INHANDS"
	set name = "Y+1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "ny"
		if(SOUTH)
			needtofind = "sy"
		if(WEST)
			needtofind = "wy"
		if(EAST)
			needtofind = "ey"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					for(var/P in L)
						if(P == needtofind)
							L[P] += 1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_yminus()
	set category = "INHANDS"
	set name = "Y-1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "ny"
		if(SOUTH)
			needtofind = "sy"
		if(WEST)
			needtofind = "wy"
		if(EAST)
			needtofind = "ey"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					for(var/P in L)
						if(P == needtofind)
							L[P] -= 1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_flip()
	set category = "INHANDS"
	set name = "FLIP"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "nflip"
		if(SOUTH)
			needtofind = "sflip"
		if(WEST)
			needtofind = "wflip"
		if(EAST)
			needtofind = "eflip"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					if(!needtofind in L)
						L += needtofind
					for(var/P in L)
						if(P == needtofind)
							if(!L[P])
								L[P] = NORTH
							else
								switch(L[P])
									if(NORTH)
										L[P] = SOUTH
									if(SOUTH)
										L[P] = WEST
									if(WEST)
										L[P] = EAST
									if(EAST)
										L[P] = 0
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_turnplus()
	set category = "INHANDS"
	set name = "Turn +1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "nturn"
		if(SOUTH)
			needtofind = "sturn"
		if(WEST)
			needtofind = "wturn"
		if(EAST)
			needtofind = "eturn"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					if(!needtofind in L)
						L += needtofind
					for(var/P in L)
						if(P == needtofind)
							L[P] += 1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_turnminus()
	set category = "INHANDS"
	set name = "Turn -1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind
	switch(LI.dir)
		if(NORTH)
			needtofind = "nturn"
		if(SOUTH)
			needtofind = "sturn"
		if(WEST)
			needtofind = "wturn"
		if(EAST)
			needtofind = "eturn"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					if(!needtofind in L)
						L += needtofind
					for(var/P in L)
						if(P == needtofind)
							L[P] -= 1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_scaleplus()
	set category = "INHANDS"
	set name = "Shrink+0.1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind = "shrink"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					if(!needtofind in L)
						L += needtofind
					for(var/P in L)
						if(P == needtofind)
							L[P] += 0.1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/inhand_scaleminus()
	set category = "INHANDS"
	set name = "Shrink-0.1"

	if(!isliving(mob))
		return
	var/mob/living/carbon/human/LI = mob

	var/needtofind = "shrink"

	var/obj/item/I = LI.get_active_held_item()
	var/used_cat
	if(!I)
		I = LI.beltr
		used_cat = "onbelt"
	if(!I)
		I = LI.beltl
	if(!I)
		used_cat = "onback"
		I = LI.backr
	if(!I)
		I = LI.backl
	if(I)
		if(!used_cat && I.altgripped)
			used_cat = "altgrip"
		if(!used_cat && I.wielded)
			used_cat = "wielded"
		if(!used_cat)
			used_cat = "gen"

		for(var/X in I.onprop)
			if(X == used_cat)
				var/list/L = I.onprop[X]
				if(L.len)
					if(!needtofind in L)
						L += needtofind
					for(var/P in L)
						if(P == needtofind)
							L[P] -= 0.1
							to_chat(LI, "[needtofind] = [L[P]]")
	LI.update_inv_hands()
	LI.update_inv_belt()
	LI.update_inv_back()

/client/verb/give_me_money()
	set category = "DEBUGTEST"
	set name = "GiveMeMoney"
	if(mob)
		var/turf/T = get_turf(mob)
		if(T)
			new /obj/item/roguecoin/gold/pile(T)
/*
/client/verb/wwolf()
	set category = "DEBUGTEST"
	set name = "Werewolf"
	if(mob.mind)
		if(mob.mind.has_antag_datum(/datum/antagonist/werewolf, TRUE))
			to_chat(mob, "I am already a werewolf.")
		else
			var/datum/antagonist/werewolf/new_antag = new /datum/antagonist/werewolf()
			mob.mind.add_antag_datum(new_antag)
*/

/client/verb/zoomtest()
	set category = "DEBUGTEST"
	set name = "ZoomTest"
	if(mob)
		if(iscarbon(mob))
			var/mob/living/carbon/C = mob
			var/list/screens = list(C.hud_used.plane_masters["[FLOOR_PLANE]"], C.hud_used.plane_masters["[GAME_PLANE]"], C.hud_used.plane_masters["[LIGHTING_PLANE]"])
			var/matrix/skew = matrix()
			skew.Scale(2)
			var/matrix/newmatrix = skew
			for(var/whole_screen in screens)
				animate(whole_screen, transform = newmatrix, time = 5, easing = QUAD_EASING, loop = -1)
				animate(transform = -newmatrix, time = 5, easing = QUAD_EASING)

/client/verb/zoomteststop()
	set category = "DEBUGTEST"
	set name = "ZoomTestEnd"
	if(mob)
		if(iscarbon(mob))
			var/mob/living/carbon/C = mob
			var/list/screens = list(C.hud_used.plane_masters["[FLOOR_PLANE]"], C.hud_used.plane_masters["[GAME_PLANE]"], C.hud_used.plane_masters["[LIGHTING_PLANE]"])
			for(var/whole_screen in screens)
				animate(whole_screen, transform = matrix(), time = 5, easing = QUAD_EASING)
#endif

#ifdef TESTING
/client/verb/door_test_button()
	set category = "DEBUGTEST"
	set name = "door_test_button"
	if(mob)
		var/mob/M = mob
		if(isturf(M.loc))
			var/turf/T = M.loc
			for(var/obj/structure/mineral_door/D in T)
				to_chat(M, "DOOR - [D]")
				to_chat(M, "LOCKID: [D.lockid]")
				to_chat(M, "LOCKSTATUS: [D.locked]")
#endif