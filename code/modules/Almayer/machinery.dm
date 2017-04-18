//-----USS Almayer Machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.

/obj/machinery/vending/marine/uniform_supply
	name = "ColMarTech Surplus Uniform Vender"
	desc = "A automated weapon rack hooked up to a colossal storage of uniforms"
	icon_state = "armory"
	icon_vend = "armory-vend"
	icon_deny = "armory"
	req_access = null
	req_access_txt = "0"
	req_one_access = null
	req_one_access_txt = "9;2;21"
	var/squad_tag = ""

	product_ads = "If it moves, it's hostile!;How many enemies have you killed today?;Shoot first, perform autopsy later!;Your ammo is right here.;Guns!;Die, scumbag!;Don't shoot me bro!;Shoot them, bro.;Why not have a donut?"
	products = list(
					/obj/item/weapon/storage/backpack/marine = 10,
					/obj/item/device/radio/headset/msulaco = 10,
					/obj/item/weapon/storage/belt/marine = 10,
					/obj/item/clothing/shoes/marine = 10,
					/obj/item/clothing/under/marine = 10
					)

	prices = list()

	New()

		..()
		if(squad_tag != null) //probably some better way to slide this in but no sleep is no sleep.
			var/products2[]
			switch(squad_tag)
				if("Alpha")
					products2 = list(/obj/item/device/radio/headset/malpha = 20)
				if("Bravo")
					products2 = list(/obj/item/device/radio/headset/mbravo = 20)
				if("Charlie")
					products2 = list(/obj/item/device/radio/headset/mcharlie = 20)
				if("Delta")
					products2 = list(/obj/item/device/radio/headset/mdelta = 20)
			build_inventory(products2)
		marine_vendors.Add(src)



//-----USS Almayer Props -----//
//Put any props that don't function properly, they could function in the future but for now are for looks. This system could be expanded for other maps too. ~Art

/obj/machinery/prop/almayer
	name = "GENERIC USS ALMAYER PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P01' IF SEEN IN ROUND WITH LOCATION"

/obj/machinery/prop/almayer/hangar/dropship_part_fabricator
	name = "dropship part fabricator"
	desc = "A large automated 3D printer for producing new dropship parts."

	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20

	icon = 'icons/obj/machines/drone_fab.dmi'
	icon_state = "drone_fab_idle"

//---USS Almayer Lights -----//

/obj/machinery/light/almayer/New()
	..()
	switch(dir)
		if(1)	pixel_y = 23
		if(4)	pixel_x = 10
		if(8)	pixel_x = -10

// the smaller bulb light fixture

/obj/machinery/light/small/almayer/New()
	..()
	switch(dir)
		if(1)	pixel_y = 23
		if(4)	pixel_x = 10
		if(8)	pixel_x = -10

//------APCs ------//

/obj/machinery/power/apc/almayer
	icon = 'icons/obj/almayer.dmi'
	cell_type = /obj/item/weapon/cell/high

//------USS Almayer Door Section-----//
// This is going to be fucken huge. This is where all babeh perspective doors go to grow up.

/obj/machinery/door/airlock/almayer
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi' //Tiles with is here FOR SAFETY PURPOSES
	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer,
		/obj/machinery/door/airlock)

	New()
		spawn(10) // No fucken idea but this somehow makes it work. What the actual fuck.
			relativewall_neighbours()
		..()

/obj/machinery/door/airlock/almayer/attackby(C as obj, mob/user as mob) //This is to make it so you can't hack them open.
	//world << text("airlock attackby src [] obj [] mob []", src, C, user)
	if(!istype(usr, /mob/living/silicon))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	if(istype(C, /obj/item/device/detective_scanner) || istype(C, /obj/item/taperoll))
		return

	src.add_fingerprint(user)
	if((istype(C, /obj/item/weapon/weldingtool) && !( src.operating > 0 ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0,user))
			user.visible_message("<span class='notice'>[user] starts working on the [src] with the [W].</span>", \
			"<span class='notice'>You start working on the [src] with the [W].</span>", \
			"<span class='notice'>You hear welding.</span>")
			playsound(src.loc, 'sound/items/weldingtool_weld.ogg', 50)
			if(do_after(user, 50))
				if(!src.welded)
					src.welded = 1
				else
					src.welded = null
				src.update_icon()
				return
		else
			return
	else if(istype(C, /obj/item/weapon/screwdriver))
		src.p_open = !( src.p_open )
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/multitool))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/device/assembly/signaler))
		return src.attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/crowbar) || istype(C, /obj/item/weapon/twohanded/fireaxe) )
		var/beingcrowbarred = null
		if(istype(C, /obj/item/weapon/crowbar) )
			beingcrowbarred = 1 //derp, Agouri
		else if(arePowerSystemsOn())
			user << "\blue The airlock's motors resist your efforts to force it."
		else if(locked)
			user << "\blue The airlock's bolts prevent it from being forced."
		else if( !welded && !operating )
			if(density)
				if(beingcrowbarred == 0) //being fireaxe'd
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F.flags_atom & WIELDED)
						spawn(0)	open(1)
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn(0)	open(1)
			else
				if(beingcrowbarred == 0)
					var/obj/item/weapon/twohanded/fireaxe/F = C
					if(F.flags_atom & WIELDED)
						spawn(0)	close(1)
					else
						user << "\red You need to be wielding the Fire axe to do that."
				else
					spawn(0)	close(1)

	else
		..()
	return

/obj/machinery/door/airlock/almayer/security
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'
	req_access_txt = "3"

/obj/machinery/door/airlock/almayer/command
	name = "Command Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'
	req_access_txt = "19"

/obj/machinery/door/airlock/almayer/maint
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/almayer/maintdoor.dmi'
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/engineering
	name = "Engineering Airlock"
	icon = 'icons/obj/doors/almayer/engidoor.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt = "2;7"

/obj/machinery/door/airlock/almayer/medical
	name = "Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor.dmi'
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/medical/glass
	name = "Medical Airlock"
	icon = 'icons/obj/doors/almayer/medidoor_glass.dmi'
	opacity = 0
	req_access_txt = "0"
	req_one_access_txt =  "2;8;19"

/obj/machinery/door/airlock/almayer/generic
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'

/obj/machinery/door/airlock/almayer/marine
	name = "Airlock"
	icon = 'icons/obj/doors/almayer/comdoor.dmi'