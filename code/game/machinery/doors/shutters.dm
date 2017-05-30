/obj/machinery/door/poddoor/shutters
	name = "\improper Shutters"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "shutter1"
	power_channel = ENVIRON

/obj/machinery/door/poddoor/shutters/New()
	..()
	layer = 3.1

/obj/machinery/door/poddoor/shutters/attackby(obj/item/weapon/C as obj, mob/user as mob)
	add_fingerprint(user)
	if( !istype(C, /obj/item/weapon/crowbar) && !( istype(C, /obj/item/weapon/twohanded/fireaxe) && (C.flags_atom & WIELDED) ) )
		return
	if(density && (stat & NOPOWER) && !operating)
		operating = 1
		spawn(-1)
			flick("shutterc0", src)
			icon_state = "shutter0"
			sleep(15)
			density = 0
			SetOpacity(0)
			operating = 0
			return
	return

/obj/machinery/door/poddoor/shutters/open()
	if(operating == 1) //doors can still open when emag-disabled
		return
	if(!ticker)
		return 0
	if(!operating) //in case of emag
		operating = 1
	flick("shutterc0", src)
	icon_state = "shutter0"
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)
	sleep(10)
	density = 0
	layer = open_layer
	SetOpacity(0)
	update_nearby_tiles()

	if(operating == 1) //emag again
		operating = 0
	if(autoclose)
		spawn(150)
			autoclose()		//TODO: note to self: look into this ~Carn
	return 1

/obj/machinery/door/poddoor/shutters/close()
	if(operating)
		return
	operating = 1
	flick("shutterc1", src)
	icon_state = "shutter1"
	layer = closed_layer
	density = 1
	if(visible)
		SetOpacity(1)
	update_nearby_tiles()
	playsound(loc, 'sound/machines/blastdoor.ogg', 25)

	sleep(10)
	operating = 0
	return

/obj/machinery/door/poddoor/shutters/pressure
	name = "pressure shutters"
	dir = 2
	density = 0
	opacity = 0
	unacidable = 1
	icon_state = "shutter0"
	open_layer = 2.9 //below grilles
	closed_layer = 3.3 //above windows
	var/chain_reacting = 1

	ex_act(severity)
		return

/obj/machinery/door/poddoor/shutters/pressure/divider
	chain_reacting = 0

/obj/machinery/door/poddoor/shutters/pressure/New()
	..()
	layer = 2.9

/obj/machinery/door/poddoor/shutters/pressure/close(var/delay = 0, var/from_dir = 0)

	spawn(delay)
		if(operating)
			return
		operating = 1
		flick("shutterc1", src)
		icon_state = "shutter1"
		layer = closed_layer
		density = 1
		update_nearby_tiles()


		if(!from_dir)
			playsound(loc, 'sound/machines/blastdoor.ogg', 50) //sound plays only for the initiating shutter

		if(chain_reacting)
			for(var/direction in cardinal)
				if(direction == from_dir) continue //doesn't check backwards
				for(var/obj/machinery/door/poddoor/shutters/pressure/P in get_step(src,direction) )
					if(!P.density)
						P.close(0,turn(direction,180))

		if(visible)
			SetOpacity(1)
		operating = 0
	return