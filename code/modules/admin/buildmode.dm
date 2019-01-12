/proc/togglebuildmode(mob/M as mob in player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"
	if(M.client)
		if(M.client.buildmode)
			log_admin("[key_name(usr)] has left build mode.")
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			for(var/obj/effect/bmode/buildholder/H)
				if(H.cl == M.client)
					del(H)
		else
			log_admin("[key_name(usr)] has entered build mode.")
			M.client.buildmode = 1
			M.client.show_popup_menus = 0

			var/obj/effect/bmode/buildholder/H = new/obj/effect/bmode/buildholder()
			var/obj/effect/bmode/builddir/A = new/obj/effect/bmode/builddir(H)
			A.master = H
			var/obj/effect/bmode/buildhelp/B = new/obj/effect/bmode/buildhelp(H)
			B.master = H
			var/obj/effect/bmode/buildmode/C = new/obj/effect/bmode/buildmode(H)
			C.master = H
			var/obj/effect/bmode/buildquit/D = new/obj/effect/bmode/buildquit(H)
			D.master = H

			H.builddir = A
			H.buildhelp = B
			H.buildmode = C
			H.buildquit = D
			M.client.screen += A
			M.client.screen += B
			M.client.screen += C
			M.client.screen += D
			H.cl = M.client

/obj/effect/bmode//Cleaning up the tree a bit
	density = 1
	anchored = 1
	layer = ABOVE_HUD_LAYER
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	var/obj/effect/bmode/buildholder/master = null

/obj/effect/bmode/builddir
	icon_state = "build"
	screen_loc = "NORTH,WEST"

/obj/effect/bmode/builddir/clicked()
	switch(dir)
		if(NORTH)
			dir = EAST
		if(EAST)
			dir = SOUTH
		if(SOUTH)
			dir = WEST
		if(WEST)
			dir = NORTHWEST
		if(NORTHWEST)
			dir = NORTH
	return 1

/obj/effect/bmode/buildhelp
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"

/obj/effect/bmode/buildhelp/clicked()
	switch(master.cl.buildmode)
		if(1)
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
			to_chat(usr, "<span class='notice'> Left Mouse Button        = Construct / Upgrade</span>")
			to_chat(usr, "<span class='notice'> Right Mouse Button       = Deconstruct / Delete / Downgrade</span>")
			to_chat(usr, "<span class='notice'> Left Mouse Button + ctrl = R-Window</span>")
			to_chat(usr, "<span class='notice'> Left Mouse Button + alt  = Airlock</span>")
			to_chat(usr, "")
			to_chat(usr, "<span class='notice'> Use the button in the upper left corner to</span>")
			to_chat(usr, "<span class='notice'> change the direction of built objects.</span>")
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
		if(2)
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
			to_chat(usr, "<span class='notice'> Right Mouse Button on buildmode button = Set object type</span>")
			to_chat(usr, "<span class='notice'> Middle Mouse Button on turf/obj        = Set object type</span>")
			to_chat(usr, "<span class='notice'> Left Mouse Button on turf/obj          = Place objects</span>")
			to_chat(usr, "<span class='notice'> Right Mouse Button                     = Delete objects</span>")
			to_chat(usr, "")
			to_chat(usr, "<span class='notice'> Use the button in the upper left corner to</span>")
			to_chat(usr, "<span class='notice'> change the direction of built objects.</span>")
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
		if(3)
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
			to_chat(usr, "<span class='notice'> Right Mouse Button on buildmode button = Select var(type) & value</span>")
			to_chat(usr, "<span class='notice'> Left Mouse Button on turf/obj/mob      = Set var(type) & value</span>")
			to_chat(usr, "<span class='notice'> Right Mouse Button on turf/obj/mob     = Reset var's value</span>")
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
		if(4)
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
			to_chat(usr, "<span class='notice'> Left Mouse Button on turf/obj/mob      = Select</span>")
			to_chat(usr, "<span class='notice'> Right Mouse Button on turf/obj/mob     = Throw</span>")
			to_chat(usr, "<span class='notice'> ***********************************************************</span>")
	return 1

/obj/effect/bmode/buildquit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"

/obj/effect/bmode/buildquit/clicked()
	togglebuildmode(master.cl.mob)
	return 1

/obj/effect/bmode/buildholder
	density = 0
	anchored = 1
	var/client/cl = null
	var/obj/effect/bmode/builddir/builddir = null
	var/obj/effect/bmode/buildhelp/buildhelp = null
	var/obj/effect/bmode/buildmode/buildmode = null
	var/obj/effect/bmode/buildquit/buildquit = null
	var/atom/movable/throw_atom = null

/obj/effect/bmode/buildmode
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = /obj/structure/closet

/obj/effect/bmode/buildmode/clicked(var/mob/M, var/list/mods)

	if(mods["left"])
		switch(master.cl.buildmode)
			if(1)
				master.cl.buildmode = 2
				src.icon_state = "buildmode2"
			if(2)
				master.cl.buildmode = 3
				src.icon_state = "buildmode3"
			if(3)
				master.cl.buildmode = 4
				src.icon_state = "buildmode4"
			if(4)
				master.cl.buildmode = 1
				src.icon_state = "buildmode1"

	else if(mods["right"])
		switch(master.cl.buildmode)
			if(1)
				return 1
			if(2)
				objholder = text2path(input(usr,"Enter typepath:" ,"Typepath","/obj/structure/closet"))
				if(!ispath(objholder))
					objholder = /obj/structure/closet
					alert("That path is not allowed.")
				else
					if(ispath(objholder,/mob) && !check_rights(R_DEBUG,0))
						objholder = /obj/structure/closet
			if(3)
				var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

				master.buildmode.varholder = input(usr,"Enter variable name:" ,"Name", "name")
				if(master.buildmode.varholder in locked && !check_rights(R_DEBUG,0))
					return 1
				var/thetype = input(usr,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
				if(!thetype) return 1
				switch(thetype)
					if("text")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", "value") as text
					if("number")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", 123) as num
					if("mob-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as mob in mob_list
					if("obj-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as obj in object_list
					if("turf-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as turf in turfs
    return 1

/proc/build_click(var/mob/user, buildmode, var/list/mods, var/obj/object)
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H)
		if(H.cl == user.client)
			holder = H
			break
	if(!holder) return

	switch(buildmode)
		if(1)
			if(istype(object,/turf) && mods["left"] && !mods["alt"] && !mods["ctrl"] )
				if(istype(object,/turf/open/space))
					var/turf/T = object
					T.ChangeTurf(/turf/open/floor)
					return
				else if(istype(object,/turf/open/floor))
					var/turf/T = object
					T.ChangeTurf(/turf/closed/wall)
					return
				else if(istype(object,/turf/closed/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/closed/wall/r_wall)
					return
			else if(mods["right"])
				if(istype(object,/turf/closed/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/open/floor)
					return
				else if(istype(object,/turf/open/floor))
					var/turf/T = object
					T.ChangeTurf(/turf/open/space)
					return
				else if(istype(object,/turf/closed/wall/r_wall))
					var/turf/T = object
					T.ChangeTurf(/turf/closed/wall)
					return
				else if(istype(object,/obj))
					qdel(object)
					return
			else if(istype(object,/turf) && mods["alt"] && mods["left"])
				new/obj/machinery/door/airlock(get_turf(object))
			else if(istype(object,/turf) && mods["ctrl"] && mods["left"])
				switch(holder.builddir.dir)
					if(NORTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = NORTH
					if(SOUTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = SOUTH
					if(EAST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = EAST
					if(WEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = WEST
					if(NORTHWEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = NORTHWEST
		if(2)
			if(mods["left"])
				if(ispath(holder.buildmode.objholder,/turf))
					var/turf/T = get_turf(object)
					T.ChangeTurf(holder.buildmode.objholder)
				else
					var/obj/A = new holder.buildmode.objholder (get_turf(object))
					A.dir = holder.builddir.dir
			else if(mods["middle"])
				holder.buildmode.objholder = text2path("[object.type]")
				to_chat(usr, "Selected: [object.type]")
			else if(mods["right"])
				if(isobj(object)) qdel(object)

		if(3)
			if(mods["left"]) //I cant believe this shit actually compiles.
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = holder.buildmode.valueholder
				else
					to_chat(usr, "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")
			if(mods["right"])
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = initial(object.vars[holder.buildmode.varholder])
				else
					to_chat(usr, "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")

		if(4)
			if(mods["left"])
				if(istype(object, /atom/movable))
					holder.throw_atom = object
			if(mods["right"])
				if(holder.throw_atom)
					holder.throw_atom.throw_at(object, 10, 1)
