



//Floors

/turf/open/floor/mainship
	icon = 'icons/turf/mainship.dmi'
	icon_state = "default"

/turf/open/floor/mainship/check_alien_construction(mob/living/builder, silent = FALSE, planned_building)
	if(ispath(planned_building, /turf/closed/wall/)) // The Canterbury moves and will leave a hole in space if there's a resin wall.
		if(!silent)
			to_chat(builder, "<span class='warning'>This place seems unable to support a wall.</span>")
		return FALSE
	return ..()

/turf/open/floor/mainship/stripesquare
	icon_state = "test_floor4"

/turf/open/floor/mainship/plate
	icon_state = "plate"

/turf/open/floor/mainship/cargo
	icon_state = "cargo"

/turf/open/floor/mainship/cargo/arrow
	icon_state = "cargo_arrow"
	icon_regular_floor = "cargo_arrow"

/turf/open/floor/mainship/blue
	icon_state = "blue"

/turf/open/floor/mainship/blue/full
	icon_state = "bluefull"

/turf/open/floor/mainship/blue/corner
	icon_state = "bluecorner"

/turf/open/floor/mainship/emerald
	icon_state = "emerald"

/turf/open/floor/mainship/orange
	icon_state = "orange"

/turf/open/floor/mainship/orange/corner
	icon_state = "orangecorner"

/turf/open/floor/mainship/orange/full
	icon_state = "orangefull"

/turf/open/floor/mainship/green
	icon_state = "green"

/turf/open/floor/mainship/green/corner
	icon_state = "greencorner"

/turf/open/floor/mainship/red
	icon_state = "red"

/turf/open/floor/mainship/red/full
	icon_state = "redfull"

/turf/open/floor/mainship/red/corner
	icon_state = "redcorner"

/turf/open/floor/mainship/ai
	icon_state = "ai_floors"

/turf/open/floor/mainship/sterile
	icon_state = "sterile_green"

/turf/open/floor/mainship/sterile/plain
	icon_state = "sterile"

/turf/open/floor/mainship/sterile/dark
	icon_state = "dark_sterile"

/turf/open/floor/mainship/sterile/corner
	icon_state = "sterile_green_corner"

/turf/open/floor/mainship/sterile/side
	icon_state = "sterile_green_side"

/turf/open/floor/mainship/mono
	icon_state = "mono"
	icon_regular_floor = "mono"

/turf/open/floor/mainship/tcomms
	icon_plating = "tcomms"
	icon_state = "tcomms"

//Cargo elevator
/turf/open/floor/mainship/empty
	name = "empty space"
	desc = "There seems to be an awful lot of machinery down below"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"

/turf/open/floor/mainship/empty/is_weedable()
	return FALSE

/turf/open/floor/mainship/empty/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/floor/mainship/empty/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return


//Others
/turf/open/floor/mainship/terragov
	icon_state = "logo_central"
	name = "\improper TerraGov logo"

/turf/open/floor/mainship/terragov/west
	icon_state = "logo_directional_west"

/turf/open/floor/mainship/terragov/south
	icon_state = "logo_directional_south"

/turf/open/floor/mainship/terragov/east
	icon_state = "logo_directional_east"

/turf/open/floor/mainship/terragov/north
	icon_state = "logo_directional_north"


// RESEARCH STUFF

/turf/open/floor/mainship/research/containment/floor1
	icon_state = "containment_floor_1"

/turf/open/floor/mainship/research/containment/floor2
	icon_state = "containment_floor_2"

/turf/open/floor/mainship/research/containment/corner1
	icon_state = "containment_corner_1"

/turf/open/floor/mainship/research/containment/corner2
	icon_state = "containment_corner_2"

/turf/open/floor/mainship/research/containment/corner3
	icon_state = "containment_corner_3"

/turf/open/floor/mainship/research/containment/corner4
	icon_state = "containment_corner_4"







//Outerhull

/turf/open/floor/mainship_hull
	icon = 'icons/turf/mainship.dmi'
	icon_state = "outerhull"
	name = "hull"
	hull_floor = TRUE

/turf/open/floor/mainship_hull/dir
	icon_state = "outerhull_dir"





//***********

/turf/open/floor/marking/loadingarea
	icon_state = "loadingarea"

/turf/open/floor/marking/bot
	icon_state = "bot"

/turf/open/floor/marking/delivery
	icon_state = "delivery"

/turf/open/floor/marking/warning
	icon_state = "warning"

/turf/open/floor/marking/warning/corner
	icon_state = "warningcorner"

/turf/open/floor/marking/asteroidwarning
	icon_state = "asteroidwarning"

/turf/open/floor/grimy
	icon_state = "grimy"

/turf/open/floor/asteroidfloor
	icon_state = "asteroidfloor"



//////////////////////////////////////////////////////////////////////



/turf/open/floor/freezer
	icon_state = "freezerfloor"

/turf/open/floor/light
	name = "Light floor"
	icon_state = "light_on"

/turf/open/floor/light/Initialize()
	. = ..()
	floor_tile = new /obj/item/stack/tile/light
	return INITIALIZE_HINT_LATELOAD


/turf/open/floor/light/LateInitialize(mapload)
	update_icon()


/turf/open/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = new/obj/item/stack/tile/wood
	shoefootstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD
	mediumxenofootstep = FOOTSTEP_WOOD

/turf/open/floor/wood/broken
	icon_state = "wood-broken"
	burnt = TRUE

/turf/open/floor/vault
	icon_state = "rockvault"

/turf/open/floor/vault/Initialize(mapload, state)
	. = ..()
	icon_state = "[state]vault"

/turf/open/floor/cult
	icon_state = "cult"

/turf/open/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	intact_tile = 0
	breakable_tile = FALSE
	burnable_tile = FALSE

/turf/open/floor/engine/make_plating()
	return

/turf/open/floor/engine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		user.visible_message("<span class='notice'>[user] starts removing [src]'s protective cover.</span>",
		"<span class='notice'>You start removing [src]'s protective cover.</span>")
		playsound(src, 'sound/items/ratchet.ogg', 25, 1)

		if(!do_after(user, 30, TRUE, src, BUSY_ICON_BUILD))
			return

		new /obj/item/stack/rods(src, 2)
		ChangeTurf(/turf/open/floor)
		var/turf/open/floor/F = src
		F.make_plating()


/turf/open/floor/engine/nitrogen

/turf/open/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"


/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"


/turf/open/floor/engine/mars/exterior
	name = "floor"
	icon_state = "ironsand1"

/turf/open/floor/scorched
	icon_state = "floorscorched1"

/turf/open/floor/scorched/two
	icon_state = "floorscorched2"


/turf/open/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/open/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"


/turf/open/floor/asteroid
	icon_state = "asteroid"

/turf/open/floor/grass
	name = "Grass patch"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass
	shoefootstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	mediumxenofootstep = FOOTSTEP_GRASS


/turf/open/floor/grass/Initialize()
	. = ..()
	floor_tile = new /obj/item/stack/tile/grass
	icon_state = "grass[pick("1","2","3","4")]"
	return INITIALIZE_HINT_LATELOAD


/turf/open/floor/grass/LateInitialize(mapload)
	update_icon()
	for(var/direction in GLOB.cardinals)
		if(!istype(get_step(src,direction), /turf/open/floor))
			continue
		var/turf/open/floor/FF = get_step(src,direction)
		FF.update_icon() //so siding get updated properly

/turf/open/floor/tile/damaged/panel
	icon_state = "panelscorched"

/turf/open/floor/tile/damaged/three
	icon_state = "damaged3"

/turf/open/floor/tile/damaged/four
	icon_state = "damaged4"

/turf/open/floor/tile/damaged/five
	icon_state = "damaged5"

/turf/open/floor/tile/white
	icon_state = "white"

/turf/open/floor/tile/chapel
	icon_state = "chapel"
	icon_regular_floor = "chapel"

/turf/open/floor/tile/cmo
	icon_state = "cmo"

/turf/open/floor/tile/bar
	icon_state = "bar"

/turf/open/floor/tile/brown
	icon_state = "brown"

/turf/open/floor/tile/dark
	icon_state = "dark"

/turf/open/floor/tile/barber
	icon_state = "barber"

/turf/open/floor/tile/vault
	icon_state = "vault"

/turf/open/floor/tile/yellow
	icon_state = "yellow"

/turf/open/floor/tile/yellow/patch
	icon_state = "yellowpatch"

/turf/open/floor/tile/yellow/full
	icon_state = "yellowfull"

/turf/open/floor/tile/whiteyellow
	icon_state = "whiteyellow"

/turf/open/floor/tile/whiteyellow/full
	icon_state = "whiteyellowfull"

/turf/open/floor/tile/whiteyellow/corner
	icon_state = "whiteyellowcorner"

/turf/open/floor/tile/red/redtaupecorner
	icon_state = "redcorner"

/turf/open/floor/tile/red/whitered
	icon_state = "whitered"

/turf/open/floor/tile/red/whitered/corner
	icon_state = "whiteredcorner"

/turf/open/floor/tile/red/whiteredfull
	icon_state = "whiteredfull"

// no directions
/turf/open/floor/tile/red/redblue/full
	icon_state = "redbluefull"

/turf/open/floor/tile/red/redtaupe
	icon_state = "red"

/turf/open/floor/tile/red/full
	icon_state = "redfull"

/turf/open/floor/tile/red/yellowfull
	icon_state = "redyellowfull"

/turf/open/floor/tile/lightred/full
	icon_state = "floor4"

/turf/open/floor/tile/purple/taupepurple
	icon_state = "purple"

/turf/open/floor/tile/purple/taupepurple/corner
	icon_state = "purplecorner"

/turf/open/floor/tile/purple/whitepurple
	icon_state = "whitepurple"

/turf/open/floor/tile/purple/whitepurplefull
	icon_state = "whitepurplefull"

/turf/open/floor/tile/purple/whitepurplecorner
	icon_state = "whitepurplecorner"

/turf/open/floor/tile/blue/whitebluecorner
	icon_state = "whitebluecorner"

/turf/open/floor/tile/blue/taupeblue
	icon_state = "blue"

/turf/open/floor/tile/blue/taupebluecorner
	icon_state = "bluecorner"

/turf/open/floor/tile/blue/whiteblue
	icon_state = "whiteblue"

/turf/open/floor/tile/blue/whitebluefull
	icon_state = "whitebluefull"

/turf/open/floor/tile/green/full
	icon_state = "greenfull"

/turf/open/floor/tile/green/greentaupe
	icon_state = "green"

/turf/open/floor/tile/green/whitegreen
	icon_state = "whitegreen"

/turf/open/floor/tile/green/whitegreencorner
	icon_state = "whitegreencorner"

/turf/open/floor/tile/green/whitegreenfull
	icon_state = "whitegreenfull"

/turf/open/floor/tile/darkgreen/darkgreen2
	icon_state = "darkgreen2"

/turf/open/floor/tile/darkgreen/darkgreen2/corner
	icon_state = "darkgreencorners2"

/turf/open/floor/tile/white/warningstripe
	icon_state = "warnwhite"

/turf/open/floor/tile/darkish
	icon_state = "darkish"

/turf/open/floor/tile/dark
	icon_state = "dark"

/turf/open/floor/tile/dark2
	icon_state = "dark2"

/turf/open/floor/tile/dark/purple2
	icon_state = "darkpurple2"

/turf/open/floor/tile/dark/purple2/corner
	icon_state = "darkpurplecorners2"

/turf/open/floor/tile/dark/yellow2
	icon_state = "darkyellow2"

/turf/open/floor/tile/dark/yellow2/corner
	icon_state = "darkyellowcorners2"

/turf/open/floor/tile/dark/brown2
	icon_state = "darkbrown2"

/turf/open/floor/tile/dark/brown2/corner
	icon_state = "darkbrowncorners2"

/turf/open/floor/tile/dark/green2
	icon_state = "darkgreen2"

/turf/open/floor/tile/dark/green2/corner
	icon_state = "darkgreencorners2"

/turf/open/floor/tile/dark/red2
	icon_state = "darkred2"

/turf/open/floor/tile/dark/red2/corner
	icon_state = "darkredcorners2"

/turf/open/floor/tile/dark/blue2
	icon_state = "darkblue2"

/turf/open/floor/tile/dark/blue2/corner
	icon_state = "darkbluecorners2"

/turf/open/floor/tile/whitegreenv
	icon_state = "whitegreen_v"

/turf/open/floor/animated/bcircuit
	icon_state = "bcircuit"

/turf/open/floor/grime
	icon_state = "floorgrime"

/turf/open/floor/podhatch
	icon_state = "podhatch"

/turf/open/floor/podhatch/floor
	icon_state = "podhatchfloor"

/turf/open/floor/stairs/rampbottom
	icon_state = "rampbottom"

/turf/open/floor/elevatorshaft
	icon_state = "elevatorshaft"

/turf/open/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	shoefootstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET
	mediumxenofootstep = FOOTSTEP_CARPET


/turf/open/floor/carpet/Initialize()
	. = ..()
	floor_tile = new /obj/item/stack/tile/carpet
	return INITIALIZE_HINT_LATELOAD


/turf/open/floor/carpet/LateInitialize(mapload)
	update_icon()
	for(var/direction in list(1,2,4,8,5,6,9,10))
		if(!istype(get_step(src, direction), /turf/open/floor))
			continue
		var/turf/open/floor/FF = get_step(src,direction)
		FF.update_icon() //so siding get updated properly

/turf/open/floor/carpet/edge2
	icon_state = "carpetedge"

// Start Prison tiles

/turf/open/floor/prison
	icon = 'icons/turf/prison.dmi'
	icon_state = "floor"

/turf/open/floor/prison/bright_clean
	icon_state = "bright_clean"

/turf/open/floor/prison/bright_clean/two
	icon_state = "bright_clean2"

/turf/open/floor/prison/rampbottom
	icon_state = "rampbottom"

/turf/open/floor/prison/plate
	icon_state = "floor_plate"

/turf/open/floor/prison/kitchen
	icon_state = "kitchen"

/turf/open/floor/prison/cleanmarked
	icon_state = "bright_clean_marked"

/turf/open/floor/prison/marked
	icon_state = "floor_marked"

/turf/open/floor/prison/cellstripe
	icon_state = "cell_stripe"

/turf/open/floor/prison/sterilewhite
	icon_state = "sterile_white"

/turf/open/floor/prison/trim/red
	icon_state = "darkred2"

/turf/open/floor/prison/purple/whitepurple
	icon_state = "whitepurple"

/turf/open/floor/prison/whitepurple/full
	icon_state = "whitepurplefull"

/turf/open/floor/prison/whitepurple/corner
	icon_state = "whitepurplecorner"

/turf/open/floor/prison/whitegreen
	icon_state = "whitegreen"

/turf/open/floor/prison/whitegreen/corner
	icon_state = "whitegreencorner"

/turf/open/floor/prison/whitegreen/full
	icon_state = "whitegreenfull"

/turf/open/floor/prison/darkred/corners
	icon_state = "darkredcorners2"

/turf/open/floor/prison/darkred/full
	icon_state = "darkredfull2"

/turf/open/floor/prison/darkpurple
	icon_state = "darkpurple2"

/turf/open/floor/prison/darkpurple/full
	icon_state = "darkpurplefull2"

/turf/open/floor/prison/darkpurple/corner
	icon_state = "darkpurplecorners2"

/turf/open/floor/prison/darkyellow
	icon_state = "darkyellow2"

/turf/open/floor/prison/darkyellow/full
	icon_state = "darkyellowfull2"

/turf/open/floor/prison/darkyellow/corner
	icon_state = "darkyellowcorners2"

/turf/open/floor/prison/darkgreen
	icon_state = "darkgreen2"

/turf/open/floor/prison/darkbrown
	icon_state = "darkbrown2"

/turf/open/floor/prison/darkbrown/corner
	icon_state = "darkbrowncorners2"

/turf/open/floor/prison/darkbrown/full
	icon_state = "darkbrownfull2"

/turf/open/floor/prison/green
	icon_state = "green"

/turf/open/floor/prison/green/full
	icon_state = "greenfull"

/turf/open/floor/prison/green/corner
	icon_state = "greencorner"

/turf/open/floor/prison/blue
	icon_state = "blue"

/turf/open/floor/prison/blue/full
	icon_state = "bluefull"

/turf/open/floor/prison/blue/corner
	icon_state = "bluecorner"

/turf/open/floor/prison/yellow
	icon_state = "yellow"

/turf/open/floor/prison/yellow/full
	icon_state = "yellowfull"

/turf/open/floor/prison/yellow/corner
	icon_state = "yellowcorner"

/turf/open/floor/prison/red
	icon_state = "red"

/turf/open/floor/prison/red/full
	icon_state = "redfull"

/turf/open/floor/prison/red/corner
	icon_state = "redcorner"


////// Cold war floors



/turf/open/floor/martiantile
	icon_state = "martian_tile"

/turf/open/floor/martiansolars
	icon_state = "martian_solar"

////// Mechbay /////////////////:


/turf/open/floor/mech_bay_recharge_floor
	name = "Mech Bay Recharge Station"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"

/turf/open/floor/mech_bay_recharge_floor/break_tile()
	if(broken) return
	ChangeTurf(/turf/open/floor/plating)
	broken = TRUE

/turf/open/floor/mech_bay_recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"
