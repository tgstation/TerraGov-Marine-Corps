/atom/movable/verb/pull()
	set name = "Pull"
	set category = "Object"
	set src in oview(1)

	if(Adjacent(usr))
		if( isobj(src) && isXeno(usr) || istype(src, /obj/item/device/flashlight) && ishuman(usr) )
			usr << "You can't pull that."
			return

		if(istype(src,/mob/living/carbon/Xenomorph) && !isXenoLarva(src))
			var/mob/living/carbon/Xenomorph/X = src
			if(X.stat < 2 && has_species(usr,"Human")) // If the Xeno is alive, fight back against a grab/pull
				usr.Weaken(rand(X.tacklemin,X.tacklemax))
				playsound(usr.loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				visible_message("<span class='warning'>[usr] tried to pull [X] but instead gets a tail swipe to the head!</span>")
				return

		usr.start_pulling(src)
	return

/atom/verb/point()
	set name = "Point To"
	set category = "Object"
	set src in oview()
	var/atom/this = src//detach proc from src

	src = null

	if(!usr || !isturf(usr.loc))
		return
	if(usr.stat || usr.restrained())
		return
	if(usr.status_flags & FAKEDEATH)
		return

	if(isYautja(this)) return

	var/tile = get_turf(this)
	if (!tile)
		return

	var/P = new /obj/effect/decal/point(tile)
	spawn (20)
		if(P)	del(P)

	usr.visible_message("<b>[usr]</b> points to [this]")
