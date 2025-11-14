



//Floors

/turf/open/floor/mainship
	icon = 'icons/turf/mainship.dmi'
	icon_state = "default"

/turf/open/floor/mainship/stripesquare
	icon_state = "test_floor4"

/turf/open/floor/mainship/plate
	icon_state = "plate"

/turf/open/floor/mainship/floor
	icon_state = "floor"

/turf/open/floor/mainship/plate/outline
	icon_state = "test_floor5"

/turf/open/floor/mainship/hexagon
	icon_state = "hexagon"

/turf/open/floor/mainship/cargo
	icon_state = "cargo"

/turf/open/floor/mainship/yellow_cargo
	icon_state = "yellow_cargo"

/turf/open/floor/mainship/yellow_cargo/arrow
	icon_state = "yellow_cargo_arrow"

/turf/open/floor/mainship/cargo/arrow
	icon_state = "cargo_arrow"

/turf/open/floor/mainship/blue
	icon_state = "blue"

/turf/open/floor/mainship/blue/full
	icon_state = "bluefull"

/turf/open/floor/mainship/blue/corner
	icon_state = "bluecorner"

/turf/open/floor/mainship/emerald
	icon_state = "emerald"

/turf/open/floor/mainship/emerald/corner
	icon_state = "emeraldcorner"

/turf/open/floor/mainship/emerald/full
	icon_state = "emeraldfull"

/turf/open/floor/mainship/purple
	icon_state = "purple"

/turf/open/floor/mainship/purple/corner
	icon_state = "purplecorner"

/turf/open/floor/mainship/purple/full
	icon_state = "purplefull"

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

/turf/open/floor/mainship/green/full
	icon_state = "greenfull"

/turf/open/floor/mainship/black/
	icon_state = "black"

/turf/open/floor/mainship/black/corner
	icon_state = "blackcorner"

/turf/open/floor/mainship/black/full
	icon_state = "blackfull"

/turf/open/floor/mainship/white
	icon_state = "white"

/turf/open/floor/mainship/white/corner
	icon_state = "whitecorner"

/turf/open/floor/mainship/white/full
	icon_state = "whitefull"

/turf/open/floor/mainship/silver
	icon_state = "silver"

/turf/open/floor/mainship/silver/corner
	icon_state = "silvercorner"

/turf/open/floor/mainship/silver/full
	icon_state = "silverfull"

/turf/open/floor/mainship/red
	icon_state = "red"

/turf/open/floor/mainship/red/full
	icon_state = "redfull"

/turf/open/floor/mainship/red/corner
	icon_state = "redcorner"

/turf/open/floor/mainship/ai
	icon_state = "ai_floors"

/turf/open/floor/mainship/sandtemple
	icon_state = "sandtemplefloor"

/turf/open/floor/mainship/sterile
	icon_state = "sterile_green"

/turf/open/floor/mainship/sterile/plain
	icon_state = "sterile"

/turf/open/floor/mainship/sterile/dark
	icon_state = "dark_sterile"

/turf/open/floor/mainship/sterile/white
	icon_state = "white_sterile"

/turf/open/floor/mainship/sterile/corner
	icon_state = "sterile_green_corner"

/turf/open/floor/mainship/sterile/side
	icon_state = "sterile_green_side"

/turf/open/floor/mainship/mono
	icon_state = "mono"

/turf/open/floor/mainship/tcomms
	icon_state = "tcomms"

/turf/open/floor/mainship/sterile/purple
	icon_state = "sterile_purple"

/turf/open/floor/mainship/sterile/purple/corner
	icon_state = "sterile_purple_corner"

/turf/open/floor/mainship/sterile/purple/side
	icon_state = "sterile_purple_side"

/turf/open/floor/mainship/office
	icon_state = "office_tile"

/turf/open/floor/mainship/ntlogo
	icon_state = "nt1"

/turf/open/floor/mainship/ntlogo/nt2
	icon_state = "nt2"

/turf/open/floor/mainship/ntlogo/nt3
	icon_state = "nt3"

//Cargo elevator
/turf/open/floor/mainship/empty
	name = "empty space"
	desc = "There seems to be an awful lot of machinery down below"
	icon = 'icons/effects/effects.dmi'
	icon_state = "1"
	hull_floor = TRUE

/turf/open/floor/mainship/empty/is_weedable()
	return FALSE

/turf/open/floor/mainship/empty/fire_act(burn_level)
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

/turf/open/floor/mainship/som
	icon_state = "somn"

/turf/open/floor/mainship/som/nw
	icon_state = "somnw"

/turf/open/floor/mainship/som/ne
	icon_state = "somne"

/turf/open/floor/mainship/som/s
	icon_state = "soms"

/turf/open/floor/mainship/som/se
	icon_state = "somse"

/turf/open/floor/mainship/som/sw
	icon_state = "somsw"

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

/turf/open/floor/mainship_hull/gray
	icon = 'icons/turf/mainship.dmi'
	icon_state = "outerhull_gray"
	name = "hull"
	hull_floor = TRUE

/turf/open/floor/mainship_hull/gray/dir
	icon_state = "outerhull_gray_dir"



//***********

/turf/open/floor/marking/loadingarea
	icon_state = "loadingarea"

/turf/open/floor/marking/bot
	icon_state = "bot"

/turf/open/floor/marking/delivery
	icon_state = "delivery"

/turf/open/floor/marking/bot/white
	icon_state = "whitebot"

/turf/open/floor/marking/delivery/white
	icon_state = "whitedelivery"

/turf/open/floor/marking/warning
	icon_state = "warning"

/turf/open/floor/marking/warning/corner
	icon_state = "warningcorner"

/turf/open/floor/marking/asteroidwarning
	icon_state = "asteroidwarning"
	smoothing_groups = list(SMOOTH_GROUP_ASTEROID_WARNING)

/turf/open/floor/grimy
	icon_state = "grimy"

/turf/open/floor/asteroidfloor
	icon_state = "asteroidfloor"
	smoothing_groups = list(SMOOTH_GROUP_ASTEROID_WARNING)

/turf/open/ground/sandrock
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "varadero_0"
	minimap_color = MINIMAP_DIRT

//////////////////////////////////////////////////////////////////////



/turf/open/floor/freezer
	icon_state = "freezerfloor"

/turf/open/floor/light
	name = "Light floor"
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light

/turf/open/floor/light/LateInitialize()
	update_icon()

/turf/open/floor/light/plating
	icon_state = "plating"

/turf/open/floor/wood
	name = "wood floor"
	icon = 'icons/turf/wood_floor.dmi'
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	shoefootstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD
	mediumxenofootstep = FOOTSTEP_WOOD
	var/damaged_states = 7

/turf/open/floor/wood/broken_states()
	if(!damaged_states)
		return icon_state
	return "[initial(icon_state)]_damaged_[rand(1, damaged_states)]"

/turf/open/floor/wood/burnt_states()
	if(!damaged_states)
		return icon_state
	return "[initial(icon_state)]_damaged_[rand(1, damaged_states)]"

/turf/open/floor/wood/broken
	burnt = TRUE

/turf/open/floor/wood/fancy
	icon_state = "wood_fancy"
	damaged_states = 6

/turf/open/floor/wood/fancy/damaged
	burnt = TRUE

/turf/open/floor/wood/darker
	icon_state = "wood_darker"

/turf/open/floor/wood/thatch
	icon_state = "thatch"
	damaged_states = NONE

/turf/open/floor/wood/alt_one
	icon_state = "wood_alt_1"
	damaged_states = NONE

/turf/open/floor/wood/alt_two
	icon_state = "wood_alt_2"
	damaged_states = NONE

/turf/open/floor/wood/alt_three
	icon_state = "wood_alt_3"
	damaged_states = NONE

/turf/open/floor/wood/alt_four
	icon_state = "wood_alt_4"
	damaged_states = NONE

/turf/open/floor/wood/alt_five
	icon_state = "wood_alt_5"
	damaged_states = NONE

/turf/open/floor/wood/alt_six
	icon_state = "wood_alt_6"
	damaged_states = NONE

/turf/open/floor/wood/alt_seven
	icon_state = "wood_alt_7"
	damaged_states = NONE

/turf/open/floor/wood/alt_eight
	icon_state = "wood_alt_8"
	damaged_states = NONE

/turf/open/floor/wood/alt_nine
	icon_state = "wood_alt_9"
	damaged_states = NONE

/turf/open/floor/wood/alt_ten
	icon_state = "wood_alt_10"
	damaged_states = NONE

/turf/open/floor/wood/alt_eleven
	icon_state = "wood_alt_11"
	damaged_states = NONE

/turf/open/floor/wood/variable
	icon_state = "wood_common"
	damaged_states = 6

/turf/open/floor/wood/variable/damaged
	burnt = TRUE

/turf/open/floor/wood/variable/wide
	icon_state = "wood_wide"
	damaged_states = 6

/turf/open/floor/wood/variable/wide/damaged
	burnt = TRUE

/turf/open/floor/wood/variable/mosaic
	icon_state = "wood_mosaic"
	damaged_states = 6

/turf/open/floor/wood/variable/mosaic/damaged
	burnt = TRUE

/turf/open/floor/vault
	icon_state = "rockvault"

/turf/open/floor/vault/Initialize(mapload, state)
	. = ..()
	icon_state = "[state]vault"

/turf/open/floor/cult
	icon_state = "cult"

/turf/open/floor/cult/broken_states()
	return pick("cultdamage", "cultdamage2", "cultdamage3", "cultdamage4", "cultdamage5", "cultdamage6", "cultdamage7")

/turf/open/floor/cult/burnt_states()
	return pick("cultdamage", "cultdamage2", "cultdamage3", "cultdamage4", "cultdamage5", "cultdamage6", "cultdamage7")

/turf/open/floor/dark2
	icon_state = "darktile2"

/turf/open/floor/cult/clock
	icon_state = "clockwork"

/turf/open/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	breakable_tile = FALSE
	burnable_tile = FALSE
	floor_tile = null


/turf/open/floor/engine/attackby(obj/item/I, mob/user, params)
	if(iscrowbar(I)) // Prevent generation of infinite 'floor_tile' objs caused by the overridden make_plating() above never clearing the var
		return
	. = ..()
	if(.)
		return

	if(iswrench(I))
		user.visible_message(span_notice("[user] starts removing [src]'s protective cover."),
		span_notice("You start removing [src]'s protective cover."))
		playsound(src, 'sound/items/ratchet.ogg', 25, 1)

		if(LAZYLEN(user.do_actions))
			balloon_alert(user, "busy!")
			return
		if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return

		new /obj/item/stack/rods(src, 2)
		make_plating()

/turf/open/floor/engine/nitrogen

/turf/open/floor/engine/cult
	name = "engraved floor"
	icon_state = "cult"

/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"

/turf/open/floor/engine/atmos
	name = "vacuum floor"
	icon_state = "darkgraytile"

/turf/open/floor/engine/atmosdark
	name = "vacuum floor"
	icon_state = "dark"

/turf/open/floor/engine/mars/exterior
	name = "floor"
	icon_state = "ironsand1"

/turf/open/floor/scorched
	icon_state = "floorscorched1"

/turf/open/floor/scorched/two
	icon_state = "floorscorched2"

/turf/open/floor/foamplating
	icon_state = "foam_plating"

/turf/open/floor/rustyplating
	icon_state = "plating_rust"

/turf/open/floor/bcircuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"

/turf/open/floor/bcircuit/off
	icon_state = "bcircuitoff"

/turf/open/floor/bcircuit/anim
	icon_state = "bcircuitanim"

/turf/open/floor/rcircuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "rcircuit"

/turf/open/floor/rcircuit/off
	icon_state = "rcircuitoff"

/turf/open/floor/rcircuit/anim
	icon_state = "rcircuitanim"

/turf/open/floor/gcircuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"

/turf/open/floor/gcircuit/off
	icon_state = "gcircuitoff"

/turf/open/floor/gcircuit/anim
	icon_state = "gcircuitanim"

/turf/open/floor/asteroid
	icon_state = "asteroid"

/turf/open/floor/grass
	name = "Grass patch"
	icon_state = "grass"
	floor_tile = /obj/item/stack/tile/grass
	shoefootstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	mediumxenofootstep = FOOTSTEP_GRASS
	icon_variants = 4


/turf/open/floor/grass/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD


/turf/open/floor/grass/LateInitialize()
	for(var/direction in GLOB.cardinals)
		if(!istype(get_step(src,direction), /turf/open/floor))
			continue
		var/turf/open/floor/FF = get_step(src,direction)
		FF.update_icon() //so siding get updated properly

/turf/open/floor/tile/damaged/panel
	icon_state = "panelscorched"

/turf/open/floor/tile/damaged/thermite
	icon_state = "wall_thermite"

/turf/open/floor/tile/damaged/three
	icon_state = "damaged3"

/turf/open/floor/tile/damaged/four
	icon_state = "damaged4"

/turf/open/floor/tile/damaged/five
	icon_state = "damaged5"

/turf/open/floor/tile/white
	icon_state = "white"

/turf/open/floor/tile/white/hall
	icon_state = "whitehall"

/turf/open/floor/tile/white/hall/full
	icon_state = "whitehallfull"

/turf/open/floor/tile/white/hall/corner
	icon_state = "whitehallcorner"

/turf/open/floor/tile/arrival
	icon_state = "arrival"

/turf/open/floor/tile/arrival/corner
	icon_state = "arrivalcorner"

/turf/open/floor/tile/escape
	icon_state = "escape"

/turf/open/floor/tile/escape/corner
	icon_state = "escapecorner"

/turf/open/floor/tile/black
	icon_state = "black"

/turf/open/floor/tile/black/corner
	icon_state = "blackcorner"

/turf/open/floor/tile/black/full
	icon_state = "blackfull"

/turf/open/floor/tile/caution
	icon_state = "caution"

/turf/open/floor/tile/caution/corner
	icon_state = "cautioncorner"

/turf/open/floor/tile/logoss
	icon = 'icons/turf/floors.dmi'
	icon_state = "logoss"

/turf/open/floor/tile/logoss/two
	icon_state = "logoss2"

/turf/open/floor/tile/solarpanel
	icon_state = "solarpanel"

/turf/open/floor/tile/derelict
	icon_state = "derelict"

/turf/open/floor/tile/derelict/derelict2
	icon_state = "derelict2"

/turf/open/floor/tile/hydro
	icon_state = "hydrofloor"

/turf/open/floor/tile/showroom
	icon_state = "showroom"

/turf/open/floor/tile/plaque
	icon_state = "plaque"

/turf/open/floor/tile/whitebluegreen
	icon_state = "whitebluegreen"

/turf/open/floor/tile/chapel
	icon_state = "chapel"

/turf/open/floor/tile/cmo
	icon_state = "cmo"

/turf/open/floor/tile/bar
	icon_state = "bar"

/turf/open/floor/tile/brown
	icon_state = "brown"

/turf/open/floor/tile/brown/full
	icon_state = "brownfull"

/turf/open/floor/tile/brown/corner
	icon_state = "browncorner"

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

/turf/open/floor/tile/red/whitered/full
	icon_state = "whiteredfull"

// no directions
/turf/open/floor/tile/red/redblue/
	icon_state = "redblue"

/turf/open/floor/tile/red/redblue/full
	icon_state = "redbluefull"

/turf/open/floor/tile/red/redblue/bluered
	icon_state = "bluered"

/turf/open/floor/tile/redgreen
	icon_state = "redgreen"

/turf/open/floor/tile/redgreen/full
	icon_state = "redgreenfull"

/turf/open/floor/tile/greenyellow
	icon_state = "greenyellow"

/turf/open/floor/tile/greenyellow/full
	icon_state = "greenyellow"

/turf/open/floor/tile/blueyellow
	icon_state = "blueyellow"

/turf/open/floor/tile/blueyellow/full
	icon_state = "blueyellow"

/turf/open/floor/tile/red/redtaupe
	icon_state = "red"

/turf/open/floor/tile/red/full
	icon_state = "redfull"

/turf/open/floor/tile/red/yellowfull
	icon_state = "redyellowfull"

/turf/open/floor/tile/red/yellowfull/corner
	icon_state = "redyellowcorner"

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

/turf/open/floor/tile/green/greentaupecorner
	icon_state = "greencorner"

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

/turf/open/floor/tile/white/warningstripe/corner
	icon_state = "warnwhitecorner"

/turf/open/floor/tile/darkish
	icon_state = "darkish"

/turf/open/floor/tile/dark
	icon_state = "dark"

/turf/open/floor/tile/dark2
	icon_state = "dark2"

/turf/open/floor/tile/dark/purple2
	icon_state = "darkpurple2"

/turf/open/floor/tile/dark/gray
	icon_state = "darkgraytile"

/turf/open/floor/tile/cafe
	icon_state = "cafetile"

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

/turf/open/floor/tile/dark/brown3
	icon_state = "darkbrown3"

/turf/open/floor/tile/dark/brown3/corner
	icon_state = "darkbrowncorners3"


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

/turf/open/floor/tile/neutral
	icon_state = "neutral"

/turf/open/floor/tile/neutral/full
	icon_state = "neutralfull"

/turf/open/floor/tile/neutral/corner
	icon_state = "neutralcorner"

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

/turf/open/floor/squares
	icon_state = "squares"

/turf/open/floor/sterileplate
	icon_state = "sterileplate"

/turf/open/floor/retrosquareslightrough
	icon_state = "retrosquareslightrough"

/turf/open/floor/retrosquareslight
	icon_state = "retrosquareslight"

/turf/open/floor/retrosquares
	icon_state = "retrosquares"

/turf/open/floor/squareswood
	icon_state = "squareswood"

/turf/open/floor/lightspiral
	icon_state = "lightspiral"

/turf/open/floor/lightplate
	icon_state = "lightplate"

/turf/open/floor/spiralwoodalt
	icon_state = "spiralwoodalt"

/turf/open/floor/box
	icon_state = "box"

/turf/open/floor/plate
	icon_state = "plate"

/turf/open/floor/threeway
	icon_state = "threeway"

/turf/open/floor/officetiles
	icon_state = "officetiles"

/turf/open/floor/officesquares
	icon_state = "officesquares"

/turf/open/floor/spiraloffice
	icon_state = "spiraloffice"

/turf/open/floor/spiralblueoffice
	icon_state = "spiralblueoffice"

/turf/open/floor/spiralplate
	icon_state = "spiralplate"

/turf/open/floor/teleporter_static
	icon_state = "teleporter_static"

/turf/open/floor/tcomms
	icon_state = "tcomms"

/turf/open/floor/marked
	icon_state = "marked"

/turf/open/floor/urban_plating
	icon_state = "urban_plating"

/turf/open/floor/tan
	icon_state = "tan"

/turf/open/floor/urban_wood
	icon_state = "wood"

/turf/open/floor/floortwo
	icon_state = "floor2"

/turf/open/floor/floorthree
	icon_state = "floor3"

/turf/open/floor/multi_tiles
	icon_state = "multi_tiles"

/turf/open/floor/orange_cover
	icon_state = "orange_cover"

/turf/open/floor/orangetile
	icon_state = "orangetile"

/turf/open/floor/orange_edge
	icon_state = "orange_edge"

/turf/open/floor/orange_icorner
	icon_state = "orange_icorner"

/turf/open/floor/blue
	icon_state = "blue"

/turf/open/floor/bluetwo
	icon_state = "blue2"

/turf/open/floor/bluethree
	icon_state = "blue3"

/turf/open/floor/bluefour
	icon_state = "blue4"

/turf/open/floor/purp
	icon_state = "purp"

/turf/open/floor/purptwo
	icon_state = "purp2"

/turf/open/floor/purpthree
	icon_state = "purp3"

/turf/open/floor/purpfour
	icon_state = "purp4"

/turf/open/floor/green
	icon_state = "green"

/turf/open/floor/greentwo
	icon_state = "green2"

/turf/open/floor/greenthree
	icon_state = "green3"

/turf/open/floor/greenfour
	icon_state = "green4"

/turf/open/floor/cyan
	icon_state = "cyan"

/turf/open/floor/cyantwo
	icon_state = "cyan2"

/turf/open/floor/cyanthree
	icon_state = "cyan3"

/turf/open/floor/cyanfour
	icon_state = "cyan4"

/turf/open/floor/yellow
	icon_state = "yellow"

/turf/open/floor/yellowtwo
	icon_state = "yellow2"

/turf/open/floor/yellowthree
	icon_state = "yellow3"

/turf/open/floor/yellowfour
	icon_state = "yellow4"

/turf/open/floor/red
	icon_state = "red"

/turf/open/floor/redone
	icon_state = "red1"

/turf/open/floor/redtwo
	icon_state = "red2"

/turf/open/floor/redthree
	icon_state = "red3"

/turf/open/floor/redfour
	icon_state = "red4"

/turf/open/floor/whitecyan
	icon_state = "white_cyan1"

/turf/open/floor/whitecyantwo
	icon_state = "white_cyan2"

/turf/open/floor/whitecyanthree
	icon_state = "white_cyan3"

/turf/open/floor/whitecyanfour
	icon_state = "white_cyan4"

/turf/open/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	base_icon_state = "carpet"
	icon_state = "carpet-0"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CARPET)
	canSmoothWith = list(SMOOTH_GROUP_CARPET)
	shoefootstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET
	mediumxenofootstep = FOOTSTEP_CARPET
	floor_tile = /obj/item/stack/tile/carpet

/turf/open/floor/carpet/broken_states()
	return icon_state

/turf/open/floor/carpet/burnt_states()
	return icon_state

/turf/open/floor/carpet/ex_act(severity)
	if(hull_floor)
		return ..()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			make_plating()
		if(EXPLODE_HEAVY)
			if(prob(80))
				make_plating()
		if(EXPLODE_LIGHT)
			if(prob(50))
				make_plating()
	return ..()

/turf/open/floor/carpet/edge2
	icon_state = "carpetedge"

/turf/open/floor/carpet/side
	icon_state = "carpetside"

/turf/open/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	base_icon_state = "carpet_blue"
	icon_state = "carpet_blue-0"

/turf/open/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	base_icon_state = "carpet_black"
	icon_state = "carpet_black-0"

/turf/open/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	base_icon_state = "carpet_green"
	icon_state = "carpet_green-0"

/turf/open/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	base_icon_state = "carpet_orange"
	icon_state = "carpet_orange-0"

/turf/open/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	base_icon_state = "carpet_purple"
	icon_state = "carpet_purple-0"

/turf/open/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	base_icon_state = "carpet_red"
	icon_state = "carpet_red-0"

/turf/open/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	base_icon_state = "carpet_cyan"
	icon_state = "carpet_cyan-0"

/turf/open/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	base_icon_state = "carpet_royalblack"
	icon_state = "carpet_royalblack-0"

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

/turf/open/floor/prison/marked
	icon_state = "floor_marked"

/turf/open/floor/prison/cleanmarked
	icon_state = "floor_marked_white"

/turf/open/floor/prison/whitered
	icon_state = "whitered"

/turf/open/floor/prison/whiteredcorner
	icon_state = "whiteredcorner"

/turf/open/floor/prison/arrow
	icon_state = "floor_arrow"

/turf/open/floor/prison/arrow/clean
	icon_state = "floor_arrow_white"

/turf/open/floor/prison/cellstripe
	icon_state = "cell_stripe"

/turf/open/floor/prison/ramptop
	icon_state = "ramptop"

/turf/open/floor/prison/sterilewhite
	icon_state = "sterile_white"

/turf/open/floor/prison/sterilewhite/full
	icon_state = "sterile_white_full"

/turf/open/floor/prison/whitepurple
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

/turf/open/floor/prison/greenblue
	icon_state = "greenblue"

/turf/open/floor/prison/greenbluecorner
	icon_state = "greenbluecorner"
/turf/open/floor/prison/darkred
	icon_state = "darkred2"

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

/turf/open/floor/prison/darkbrown
	icon_state = "darkbrown2"

/turf/open/floor/prison/darkbrown/corner
	icon_state = "darkbrowncorners2"

/turf/open/floor/prison/darkbrown/full
	icon_state = "darkbrownfull2"

/turf/open/floor/prison/whitegreenfull2
	icon_state = "whitegreenfull2"

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

/turf/open/floor/prison/blue/plate
	icon_state = "blueplate"
/turf/open/floor/prison/yellow
	icon_state = "yellow"

/turf/open/floor/prison/yellow/full
	icon_state = "yellowfull"

/turf/open/floor/prison/yellow/corner
	icon_state = "yellowcorner"

/turf/open/floor/prison/yellow/siding
	icon_state = "yellowsiding"

/turf/open/floor/prison/yellow/siding/corner
	icon_state = "yellowcornersiding"

/turf/open/floor/prison/red
	icon_state = "red"

/turf/open/floor/prison/red/full
	icon_state = "redfull"

/turf/open/floor/prison/red/corner
	icon_state = "redcorner"

/turf/open/floor/prison/blackfloor
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "floor7"

/turf/open/floor/prison/redfloor
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "floor6"

/turf/open/floor/prison/bluefloor
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "floor"

/////// grayscale floor for easy recoloring /////

/turf/open/floor/placeholderturf
	icon_state = "placeholderturf"

/turf/open/floor/grayscale
	icon_state = "grayfloor"

/turf/open/floor/grayscale/black
	color = "#5e5e5e"

/turf/open/floor/grayscale/white
	color = "#fffdfd"

/turf/open/floor/grayscale/darkred
	color = "#41292e"

/turf/open/floor/grayscale/darkgray
	color = "#818181"

/turf/open/floor/grayscale/lightgray
	color = "#ffffff"

/turf/open/floor/grayscale/darkblue
	color = "#4f5a5e"

//color values will NOT look the same between /grayscale and /grayscale/round, don't plug in a color value in one hoping to get the same result in the other

/turf/open/floor/grayscale/round
	icon_state = "grayfloorround"
	color = "#9b9b9b"

/turf/open/floor/grayscale/round/black
	color = "#3f3f3f"

/turf/open/floor/grayscale/round/lightgray
	color = "#aaaaaa"

/turf/open/floor/grayscale/round/darkgray
	color = "#4e4e4e"

/turf/open/floor/grayscale/round/darkred
	color = "#301e21"

/turf/open/floor/grayscale/edge/black
	icon_state = "grayscale_edge"
	color = "#363636"

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

//Industrial//

/turf/open/floor/industrial
	icon = 'icons/turf/industrial.dmi'
	icon_state = "industrial"

//Kutjevo turfs

/turf/open/floor/plating/kutjevo
	icon = 'icons/turf/kutjevo_floor.dmi'

/turf/open/floor/kutjevo //Instance based on icon_states
	icon = 'icons/turf/kutjevo_floor.dmi'
	icon_state = "floor"

/turf/open/floor/kutjevo/catwalk
	icon = 'icons/turf/kutjevo_floor.dmi'
	icon_state = "catwalk"

/turf/open/floor/kutjevo/tiles
	icon_state = "floor2"

/turf/open/floor/kutjevo/plate
	icon_state = "floor3"

/turf/open/floor/kutjevo/multi_tiles
	icon_state = "multi_tiles"

/turf/open/floor/kutjevo/fake_wood
	icon_state = "fake_wood"

//LIGHT TAN PRIMARIES

/turf/open/floor/kutjevo/tan
	icon_state = "floor_tan"

/turf/open/floor/kutjevo/tan/plate
	icon_state = "floor_tan2"

/turf/open/floor/kutjevo/tan/multi_tiles
	icon_state = "floor_tan_multi"

//TAN TRANSITION PIECES

/turf/open/floor/kutjevo/tan/grey_edge
	icon_state = "floor_tan_grey3"

/turf/open/floor/kutjevo/tan/grey_inner_edge
	icon_state = "floor_tan_grey4"

/turf/open/floor/kutjevo/tan/alt_edge
	icon_state = "floor_tan_alt3"

/turf/open/floor/kutjevo/tan/alt_inner_edge
	icon_state = "floor_tan_alt4"

//GREY SECONDARIES TO LIGHT TAN

/turf/open/floor/kutjevo/grey
	icon_state = "floor_grey1"

/turf/open/floor/kutjevo/grey/plate
	icon_state = "floor_grey2"

//Turf sorting for object tree below!

//ORANGE//

/turf/open/floor/kutjevo/colors/orange
	icon_state = "orange1"

/turf/open/floor/kutjevo/colors/orange/tile
	icon_state = "orange2"

/turf/open/floor/kutjevo/colors/orange/edge
	icon_state = "orange3"

/turf/open/floor/kutjevo/colors/orange/inner_corner
	icon_state = "orange4"

//BLUE//

/turf/open/floor/kutjevo/colors/blue
	icon_state = "blue1"

/turf/open/floor/kutjevo/colors/blue/tile
	icon_state = "blue2"

/turf/open/floor/kutjevo/colors/blue/edge
	icon_state = "blue3"

/turf/open/floor/kutjevo/colors/blue/inner_corner
	icon_state = "blue4"

//PURPLE//

/turf/open/floor/kutjevo/colors/purple
	icon_state = "purp1"

/turf/open/floor/kutjevo/colors/purple/tile
	icon_state = "purp2"

/turf/open/floor/kutjevo/colors/purple/edge
	icon_state = "purp3"

/turf/open/floor/kutjevo/colors/purple/inner_corner
	icon_state = "purp4"

//GREEN//

/turf/open/floor/kutjevo/colors/green
	icon_state = "green1"

/turf/open/floor/kutjevo/colors/green/tile
	icon_state = "green2"

/turf/open/floor/kutjevo/colors/green/edge
	icon_state = "green3"

/turf/open/floor/kutjevo/colors/green/inner_corner
	icon_state = "green4"

//CYAN//

/turf/open/floor/kutjevo/colors/cyan
	icon_state = "cyan1"

/turf/open/floor/kutjevo/colors/cyan/tile
	icon_state = "cyan2"

/turf/open/floor/kutjevo/colors/cyan/edge
	icon_state = "cyan3"

/turf/open/floor/kutjevo/colors/cyan/inner_corner
	icon_state = "cyan4"

//YELLOW//

/turf/open/floor/kutjevo/colors/yellow
	icon_state = "yellow1"

/turf/open/floor/kutjevo/colors/yellow/tile
	icon_state = "yellow2"

/turf/open/floor/kutjevo/colors/yellow/edge
	icon_state = "yellow3"

/turf/open/floor/kutjevo/colors/yellow/inner_corner
	icon_state = "yellow4"

//RED//

/turf/open/floor/kutjevo/colors/red
	icon_state = "red1"

/turf/open/floor/kutjevo/colors/red/tile
	icon_state = "red2"

/turf/open/floor/kutjevo/colors/red/edge
	icon_state = "red3"

/turf/open/floor/kutjevo/colors/red/inner_corner
	icon_state = "red4"

//Kutjevo turfs

/turf/open/floor/plating/kutjevo
	icon = 'icons/turf/kutjevo_floor.dmi'

/turf/open/floor/kutjevo //Instance based on icon_states
	icon = 'icons/turf/kutjevo_floor.dmi'
	icon_state = "floor"

/turf/open/floor/kutjevo/catwalk
	icon = 'icons/turf/kutjevo_floor.dmi'
	icon_state = "catwalk"

/turf/open/floor/kutjevo/tiles
	icon_state = "floor2"

/turf/open/floor/kutjevo/plate
	icon_state = "floor3"

/turf/open/floor/kutjevo/multi_tiles
	icon_state = "multi_tiles"

/turf/open/floor/kutjevo/fake_wood
	icon_state = "fake_wood"

//LIGHT TAN PRIMARIES

/turf/open/floor/kutjevo/tan
	icon_state = "floor_tan"

/turf/open/floor/kutjevo/tan/plate
	icon_state = "floor_tan2"

/turf/open/floor/kutjevo/tan/multi_tiles
	icon_state = "floor_tan_multi"

//TAN TRANSITION PIECES

/turf/open/floor/kutjevo/tan/grey_edge
	icon_state = "floor_tan_grey3"

/turf/open/floor/kutjevo/tan/grey_inner_edge
	icon_state = "floor_tan_grey4"

/turf/open/floor/kutjevo/tan/alt_edge
	icon_state = "floor_tan_alt3"

/turf/open/floor/kutjevo/tan/alt_inner_edge
	icon_state = "floor_tan_alt4"

//GREY SECONDARIES TO LIGHT TAN

/turf/open/floor/kutjevo/grey
	icon_state = "floor_grey1"

/turf/open/floor/kutjevo/grey/plate
	icon_state = "floor_grey2"

//Turf sorting for object tree below!

//ORANGE//

/turf/open/floor/kutjevo/colors/orange
	icon_state = "orange1"

/turf/open/floor/kutjevo/colors/orange/tile
	icon_state = "orange2"

/turf/open/floor/kutjevo/colors/orange/edge
	icon_state = "orange3"

/turf/open/floor/kutjevo/colors/orange/inner_corner
	icon_state = "orange4"

//BLUE//

/turf/open/floor/kutjevo/colors/blue
	icon_state = "blue1"

/turf/open/floor/kutjevo/colors/blue/tile
	icon_state = "blue2"

/turf/open/floor/kutjevo/colors/blue/edge
	icon_state = "blue3"

/turf/open/floor/kutjevo/colors/blue/inner_corner
	icon_state = "blue4"

//PURPLE//

/turf/open/floor/kutjevo/colors/purple
	icon_state = "purp1"

/turf/open/floor/kutjevo/colors/purple/tile
	icon_state = "purp2"

/turf/open/floor/kutjevo/colors/purple/edge
	icon_state = "purp3"

/turf/open/floor/kutjevo/colors/purple/inner_corner
	icon_state = "purp4"

//GREEN//

/turf/open/floor/kutjevo/colors/green
	icon_state = "green1"

/turf/open/floor/kutjevo/colors/green/tile
	icon_state = "green2"

/turf/open/floor/kutjevo/colors/green/edge
	icon_state = "green3"

/turf/open/floor/kutjevo/colors/green/inner_corner
	icon_state = "green4"

//CYAN//

/turf/open/floor/kutjevo/colors/cyan
	icon_state = "cyan1"

/turf/open/floor/kutjevo/colors/cyan/tile
	icon_state = "cyan2"

/turf/open/floor/kutjevo/colors/cyan/edge
	icon_state = "cyan3"

/turf/open/floor/kutjevo/colors/cyan/inner_corner
	icon_state = "cyan4"

//YELLOW//

/turf/open/floor/kutjevo/colors/yellow
	icon_state = "yellow1"

/turf/open/floor/kutjevo/colors/yellow/tile
	icon_state = "yellow2"

/turf/open/floor/kutjevo/colors/yellow/edge
	icon_state = "yellow3"

/turf/open/floor/kutjevo/colors/yellow/inner_corner
	icon_state = "yellow4"

//RED//

/turf/open/floor/kutjevo/colors/red
	icon_state = "red1"

/turf/open/floor/kutjevo/colors/red/tile
	icon_state = "red2"

/turf/open/floor/kutjevo/colors/red/edge
	icon_state = "red3"

/turf/open/floor/kutjevo/colors/red/inner_corner
	icon_state = "red4"

// Hybrisa tiles


/turf/open/hybrisa
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "hybrisa"


/turf/open/floor/hybrisa
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "hybrisa"


// Street


/turf/open/urban/street
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "cement1"
	baseturfs = /turf/open/urban/street/asphalt


/turf/open/urban/street/cement1
	icon_state = "cement1"

/turf/open/urban/street/cement2
	icon_state = "cement2"

/turf/open/urban/street/cement3
	icon_state = "cement3"

/turf/open/urban/street/asphalt
	icon_state = "asphalt_old"
	minimap_color = MINIMAP_DIRT

/turf/open/urban/street/sidewalk
	icon_state = "sidewalk"

/turf/open/urban/street/sidewalkfull
	icon_state = "sidewalkfull"

/turf/open/urban/street/sidewalkcorner
	icon_state = "sidewalkcorner"

/turf/open/urban/street/sidewalkcenter
	icon_state = "sidewalkcenter"
	minimap_color = MINIMAP_DIRT

/turf/open/urban/street/roadlines
	icon_state = "asphalt_old_roadlines"

/turf/open/urban/street/roadlines2
	icon_state = "asphalt_old_roadlines2"

/turf/open/urban/street/roadlines3
	icon_state = "asphalt_old_roadlines3"

/turf/open/urban/street/roadlines4
	icon_state = "asphalt_old_roadlines4"

/turf/open/urban/street/CMB_4x4_emblem
	icon_state = "marshallsemblem_concrete_2x2"

// Unweedable

/turf/open/urban/street/underground_unweedable
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "underground"
	baseturfs = /turf/open/urban/street/asphalt

/turf/open/urban/metal/underground_unweedable
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "podfloor"

// Engineer Ship Hull
/turf/open/engineership/ship_hull
	name = "strange metal wall"
	desc = "Nigh indestructible walls that make up the hull of an unknown ancient ship."
	icon = 'icons/turf/engineership.dmi'
	icon_state = "engineerwallfloor1"
	baseturfs = /turf/open/urban/street/asphalt

// Carpet


/turf/open/floor/urban/carpet
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "carpetred"


/turf/open/floor/urban/carpet/carpetfadedred
	icon_state = "carpetfadedred"

/turf/open/floor/urban/carpet/carpetgreen
	icon_state = "carpetgreen"

/turf/open/floor/urban/carpet/carpetbeige
	icon_state = "carpetbeige"

/turf/open/floor/urban/carpet/carpetblack
	icon_state = "carpetblack"

/turf/open/floor/urban/carpet/carpetred
	icon_state = "carpetred"

/turf/open/floor/urban/carpet/carpetdarkerblue
	icon_state = "carpetdarkerblue"

/turf/open/floor/urban/carpet/carpetorangered
	icon_state = "carpetorangered"

/turf/open/floor/urban/carpet/carpetblue
	icon_state = "carpetblue"

/turf/open/floor/urban/carpet/carpetpatternblue
	icon_state = "carpetpatternblue"

/turf/open/floor/urban/carpet/carpetpatternbrown
	icon_state = "carpetpatternbrown"

/turf/open/floor/urban/carpet/carpetreddeco
	icon_state = "carpetred_deco"

/turf/open/floor/urban/carpet/carpetbluedeco
	icon_state = "carpetblue_deco"

/turf/open/floor/urban/carpet/carpetblackdeco
	icon_state = "carpetblack_deco"

/turf/open/floor/urban/carpet/carpetbeigedeco
	icon_state = "carpetbeige_deco"

/turf/open/floor/urban/carpet/carpetgreendeco
	icon_state = "carpetgreen_deco"

// Tile

/turf/open/floor/urban/tile
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "supermartfloor1"


/turf/open/floor/urban/tile/supermartfloor1
	icon_state = "supermartfloor1"

/turf/open/floor/urban/tile/supermartfloor2
	icon_state = "supermartfloor2"

/turf/open/floor/urban/tile/cuppajoesfloor
	icon_state = "cuppafloor"

/turf/open/floor/urban/tile/tilered
	icon_state = "tilered"

/turf/open/floor/urban/tile/tileblue
	icon_state = "tileblue"

/turf/open/floor/urban/tile/tilegreen
	icon_state = "tilegreen"

/turf/open/floor/urban/tile/tileblackcheckered
	icon_state = "tileblack"

/turf/open/floor/urban/tile/tilewhitecheckered
	icon_state = "tilewhitecheck"

/turf/open/floor/urban/tile/tilelightbeige
	icon_state = "tilelightbeige"

/turf/open/floor/urban/tile/tilebeigecheckered
	icon_state = "tilebeigecheck"

/turf/open/floor/urban/tile/tilebeige
	icon_state = "tilebeige"

/turf/open/floor/urban/tile/tilewhite
	icon_state = "tilewhite"

/turf/open/floor/urban/tile/tilegrey
	icon_state = "tilegrey"

/turf/open/floor/urban/tile/tileblack
	icon_state = "tileblack2"

/turf/open/floor/urban/tile/beigetileshiny
	icon_state = "beigetileshiny"

/turf/open/floor/urban/tile/blacktileshiny
	icon_state = "blacktileshiny"

/turf/open/floor/urban/tile/cementflat
	icon_state = "cementflat"

/turf/open/floor/urban/tile/beige_bigtile
	icon_state = "beige_bigtile"

/turf/open/floor/urban/tile/yellow_bigtile
	icon_state = "yellow_bigtile"

/turf/open/floor/urban/tile/darkgrey_bigtile
	icon_state = "darkgrey_bigtile"

/turf/open/floor/urban/tile/darkbrown_bigtile
	icon_state = "darkbrown_bigtile"

/turf/open/floor/urban/tile/darkbrowncorner_bigtile
	icon_state = "darkbrowncorner_bigtile"

/turf/open/floor/urban/tile/asteroidfloor_bigtile
	icon_state = "asteroidfloor_bigtile"

/turf/open/floor/urban/tile/asteroidwarning_bigtile
	icon_state = "asteroidwarning_bigtile"

/turf/open/floor/urban/tile/lightbeige_bigtile
	icon_state = "lightbeige_bigtile"

/turf/open/floor/urban/tile/green_bigtile
	icon_state = "green_bigtile"

/turf/open/floor/urban/tile/greencorner_bigtile
	icon_state = "greencorner_bigtile"

/turf/open/floor/urban/tile/greenfull_bigtile
	icon_state = "greenfull_bigtile"
// Wood

/turf/open/floor/urban/wood
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "darkerwood"

/turf/open/floor/urban/wood/greywood
	icon_state = "greywood"

/turf/open/floor/urban/wood/blackwood
	icon_state = "blackwood"

/turf/open/floor/urban/wood/darkerwood
	icon_state = "darkerwood"

/turf/open/floor/urban/wood/redwood
	icon_state = "redwood"


// Metal


/turf/open/floor/urban/metal
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "bluemetal1"

/turf/open/floor/urban/metal/bluemetal1
	icon_state = "bluemetal1"

/turf/open/floor/urban/metal/bluemetalfull
	icon_state = "bluemetalfull"

/turf/open/floor/urban/metal/bluemetalcorner
	icon_state = "bluemetalcorner"

/turf/open/floor/urban/metal/orangelinecorner
	icon_state = "orangelinecorner"

/turf/open/floor/urban/metal/orangeline
	icon_state = "orangeline"

/turf/open/floor/urban/metal/darkblackmetal1
	icon_state = "darkblackmetal1"

/turf/open/floor/urban/metal/darkblackmetal2
	icon_state = "darkblackmetal2"

/turf/open/floor/urban/metal/darkredfull2
	icon_state = "darkredfull2"

/turf/open/floor/urban/metal/redcorner
	icon_state = "zredcorner"

/turf/open/floor/urban/metal/grated
	icon_state = "rampsmaller"

/turf/open/floor/urban/metal/stripe_red
	icon_state = "stripe_red"

/turf/open/floor/urban/metal/zbrownfloor1
	icon_state = "zbrownfloor1"

/turf/open/floor/urban/metal/zbrownfloor_corner
	icon_state = "zbrownfloorcorner1"

/turf/open/floor/urban/metal/zbrownfloor_full
	icon_state = "zbrownfloorfull1"

/turf/open/floor/urban/metal/greenmetal1
	icon_state = "greenmetal1"

/turf/open/floor/urban/metal/greenmetalfull
	icon_state = "greenmetalfull"

/turf/open/floor/urban/metal/greenmetalcorner
	icon_state = "greenmetalcorner"

/turf/open/floor/urban/metal/metalwhitefull
	icon_state = "metalwhitefull"

// Misc

/turf/open/floor/urban/misc/spaceport1
	icon_state = "spaceport1"

/turf/open/floor/urban/misc/spaceport2
	icon_state = "spaceport2"


// Dropship


/turf/open/urban/dropship
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "dropshipfloor1"

/turf/open/urban/dropship/dropship1
	icon_state = "dropshipfloor1"

/turf/open/urban/dropship/dropship2
	icon_state = "dropshipfloor2"

/turf/open/urban/dropship/dropship3
	icon_state = "dropshipfloor2"

/turf/open/urban/dropship/dropship3
	icon_state = "dropshipfloor3"

/turf/open/urban/dropship/dropship4
	icon_state = "dropshipfloor4"

/turf/open/urban/dropship/dropshipfloorcorner1
	icon_state = "dropshipfloorcorner1"

/turf/open/urban/dropship/dropshipfloorcorner2
	icon_state = "dropshipfloorcorner2"

/turf/open/urban/dropship/dropshipfloorfull
	icon_state = "dropshipfloorfull"

// Engineer tiles

/turf/open/engineership
	name = "floor"
	desc = "A strange metal floor, unlike any metal you've seen before."
	icon = 'icons/turf/engineership.dmi'
	icon_state = "hybrisa"
	baseturfs = /turf/open/urban/street/asphalt

/turf/open/engineership/engineer_floor1
	icon_state = "engineer_metalfloor_3"

/turf/open/engineership/engineer_floor2
	icon_state = "engineer_floor_4"

/turf/open/engineership/engineer_floor3
	icon_state = "engineer_metalfloor_2"

/turf/open/engineership/engineer_floor4
	icon_state = "engineer_metalfloor_1"

/turf/open/engineership/engineer_floor5
	icon_state = "engineerlight"

/turf/open/engineership/engineer_floor6
	icon_state = "engineer_floor_2"

/turf/open/engineership/engineer_floor7
	icon_state = "engineer_floor_1"

/turf/open/engineership/engineer_floor8
	icon_state = "engineer_floor_5"

/turf/open/engineership/engineer_floor9
	icon_state = "engineer_metalfloor_4"

/turf/open/engineership/engineer_floor10
	icon_state = "engineer_floor_corner1"

/turf/open/engineership/engineer_floor11
	icon_state = "engineer_floor_corner2"

/turf/open/engineership/engineer_floor12
	icon_state = "engineerwallfloor1"

/turf/open/engineership/engineer_floor13
	icon_state = "outerhull_dir"

/turf/open/engineership/engineer_floor14
	icon_state = "engineer_floor_corner3"

// Pillars
/turf/open/engineership/pillars
	name = "strange metal pillar"
	desc = "A strange metal pillar, unlike any metal you've seen before."
	icon_state = "eng_pillar1"

/turf/open/engineership/pillars/north/pillar1
	icon_state = "eng_pillar1"

/turf/open/engineership/pillars/north/pillar2
	icon_state = "eng_pillar2"

/turf/open/engineership/pillars/north/pillar3
	icon_state = "eng_pillar3"

/turf/open/engineership/pillars/north/pillar4
	icon_state = "eng_pillar4"

/turf/open/engineership/pillars/south/pillarsouth1
	icon_state = "eng_pillarsouth1"

/turf/open/engineership/pillars/south/pillarsouth2
	icon_state = "eng_pillarsouth2"

/turf/open/engineership/pillars/south/pillarsouth3
	icon_state = "eng_pillarsouth3"

/turf/open/engineership/pillars/south/pillarsouth4
	icon_state = "eng_pillarsouth4"

/turf/open/engineership/pillars/west/pillarwest1
	icon_state = "eng_pillarwest1"

/turf/open/engineership/pillars/west/pillarwest2
	icon_state = "eng_pillarwest2"

/turf/open/engineership/pillars/west/pillarwest3
	icon_state = "eng_pillarwest3"

/turf/open/engineership/pillars/west/pillarwest4
	icon_state = "eng_pillarwest4"

/turf/open/engineership/pillars/east/pillareast1
	icon_state = "eng_pillareast1"

/turf/open/engineership/pillars/east/pillareast2
	icon_state = "eng_pillareast2"

/turf/open/engineership/pillars/east/pillareast3
	icon_state = "eng_pillareast3"

/turf/open/engineership/pillars/east/pillareast4
	icon_state = "eng_pillareast4"

// Hybrisa auto-turf

/turf/open/urbanshale
	name = "shale"
	icon = 'icons/turf/auto_shaledesaturated.dmi'
	mediumxenofootstep = FOOTSTEP_GRAVEL
	barefootstep = FOOTSTEP_GRAVEL
	shoefootstep = FOOTSTEP_GRAVEL
	minimap_color = MINIMAP_SHALE

/turf/open/urbanshale/layer0
	icon_state = "shale_0"

/turf/open/urbanshale/layer0_plate
	icon_state = "shale_1_alt"

/turf/open/urbanshale/layer1
	icon_state = "shale_1"

/turf/open/urbanshale/layer2
	icon_state = "shale_2"
