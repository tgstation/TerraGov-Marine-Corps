#define VENDOR_BROKEN "vendor_broken"
#define VENDOR_BLANK "vendor_blank"
//----- Marine ship machinery file -----//
// Put any new machines in here before map is released and everything moved to their proper positions.



//----- Marine ship props -----//
//Put any props that don't function properly, they could function in the future but for now are for looks. This system could be expanded for other maps too. ~Art

/obj/item/prop/mainship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P03' IF SEEN IN ROUND WITH LOCATION"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "hangarbox"

/obj/machinery/prop/mainship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P01' IF SEEN IN ROUND WITH LOCATION"
	coverage = 15

/obj/machinery/prop/mainship/hangar/dropship_part_fabricator

/obj/machinery/prop/mainship/computer/PC
	name = "personal desktop"
	desc = "A small computer hooked up into the ship's computer network."
	icon_state = "terminal1"

/obj/machinery/prop/mainship/computer
	name = "systems computer"
	desc = "A small computer hooked up into the ship's systems."

	density = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20

	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "terminal"

/obj/machinery/prop/mainship/computer/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				set_broken()
		if(EXPLODE_LIGHT)
			if (prob(25))
				set_broken()


/obj/machinery/prop/mainship/computer/proc/set_broken()
	machine_stat |= BROKEN
	update_icon()

/obj/machinery/prop/mainship/computer/update_icon_state()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	if(machine_stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"

/obj/machinery/prop/mainship/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."

	icon_state = "aiupload"

/obj/machinery/prop/mainship/computer/dna
	icon_state = "dna"

/obj/structure/prop/mainship/massdiver
	name = "mass driver"
	desc = "The finest in spring-loaded piston toy technology, now on a space station near you."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"

/obj/structure/prop/mainship/shieldwall
	name = "shield wall generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "shield_wall_gen"

/obj/structure/prop/mainship/dnascanner
	name = "\improper DNA scanner"
	desc = "It scans DNA structures."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "scanner"

/obj/structure/prop/mainship/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/gateway.dmi'
	icon_state = "portal_frame"

/obj/structure/prop/mainship/gravitygenerator
	name = "gravitational generator"
	desc = "A device which produces a graviton field when set up."
	icon = 'icons/obj/gravity_generator.dmi'
	icon_state = "on_8"

/obj/structure/prop/mainship/holobarrier
	name = "\improper Engineering holobarrier"
	desc = "A wonder of subsidized corporate design, this holographic barrier is almost entirely resistant to atmos loss and degradation by melee or ballistic damage. It's also made of space asbestos and is illegal under the new Geneva conventions."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "holosign_engi"
	density = TRUE
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/deadai
	name = "\improper deactivated AI"
	desc = "A standard silicon unit assigned to manage the research duties of NT stations. This one is completely deactivated."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "ai_dead"
	density = TRUE
	resistance_flags = RESIST_ALL


/obj/structure/prop/mainship/deadai/Initialize(mapload)
	. = ..()
	icon_state = pick(
		"ai_dead",
		"ai-alien_dead",
		"ai-banned_dead",
		"ai-clown_dead",
		"ai-database_dead",
		"ai-glitchman_dead",
		"ai-goon_dead",
		"ai-house_dead",
		"ai-monochrome_dead",
		"ai-red_dead",
		"ai-red october_dead",
		"ai-static_dead",
		"ai-hades_dead",
	)

/obj/structure/prop/mainship/weapon_recharger
	name = "recharger"
	desc = "A charging dock for energy based weaponry, PDAs, and other devices. A small blinking light indicates that this recharger isn't functional."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "weapon_recharger"
	density = FALSE

//RND Props
/obj/machinery/prop/r_n_d/protolathe
	name = "Protolathe"
	icon = 'icons/obj/machines/research.dmi'
	desc = "Protolathe, used to be used to print tools and such."
	icon_state = "protolathe"

/obj/machinery/prop/computer/rdconsole
	name = "R&D Console"
	icon = 'icons/obj/machines/computer.dmi'
	desc = "A research console."
	icon_state = "rdcomp"

/obj/machinery/prop/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	desc = "A research server"
	icon_state = "server"

/obj/machinery/prop/computer/rdservercontrol
	name = "R&D Server Controller"
	icon = 'icons/obj/machines/computer.dmi'
	desc = "Oversees all research"
	icon_state = "rdcomp"

/obj/machinery/prop/r_n_d/server/alt
	name = "Alternate R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	desc = "A research server"
	icon_state = "server_alt"
//End RND props

//Nonpower using props

/obj/structure/prop/mainship
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P02' IF SEEN IN ROUND WITH LOCATION"
	density = TRUE
	anchored = TRUE
	coverage = 15

/obj/machinery/prop/autolathe
	name = "\improper autolathe"
	desc = "It used to produce items using metal and glass."
	icon_state = "autolathe"
	coverage = 30

/obj/structure/prop/mainship/minigun_crate
	name = "30mm ammo crate"
	desc = "A crate full of 30mm bullets used on one of the weapon pod types for the dropship. Moving this will require some sort of lifter."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "30mm_crate"


/obj/structure/prop/mainship/mission_planning_system
	name = "\improper MPS IV computer"
	desc = "The Mission Planning System IV (MPS IV), a enhancement in mission planning and charting for dropship pilots across the TGMC. Fully capable of customizing their flight paths and loadouts to suit their combat needs."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "mps"

/obj/structure/prop/mainship/mapping_computer
	name = "\improper CMPS II computer"
	desc = "The Common Mapping Production System version II allows for sensory imput from satellites and ship systems to derive planetary maps in a standardized fashion for all TGMC pilots."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "mapping_comp"

/obj/structure/prop/mainship/sensor_computer1
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sensor_comp1"

/obj/structure/prop/mainship/sensor_computer1/sd
	name = "self destruct status computer"

/obj/structure/prop/mainship/sensor_computer2
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sensor_comp2"

/obj/structure/prop/mainship/sensor_computer2/sd
	name = "self destruct regulator"

/obj/structure/prop/mainship/sensor_computer3
	name = "sensor computer"
	desc = "The IBM series 10 computer retrofitted to work as a sensor computer for the ship. While somewhat dated it still serves its purpose."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sensor_comp3"

/obj/structure/prop/mainship/sensor_computer3/sd
	name = "tempature regulator"

/obj/structure/prop/mainship/missile_tube
	name = "\improper Mk 33 ASAT launcher system"
	desc = "Cold launch tubes that can fire a few varieties of missiles out of them The most common being the ASAAR-21 Rapier IV missile used against satellites and other spacecraft and the BGM-227 Sledgehammer missile which is used for ground attack."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "missiletubenorth"
	bound_width = 32
	bound_height = 96
	resistance_flags = UNACIDABLE

/obj/structure/prop/mainship/missile_tube/south
	icon_state = "missiletubesouth"

/obj/structure/prop/mainship/ship_memorial
	name = "slab of victory"
	desc = "A ship memorial dedicated to the triumphs of the TGMC and the fallen marines of this ship. On the left there are grand tales of victory etched into the slab. On the right there is a list of famous marines who have fallen in combat serving the TGMC."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "ship_memorial"
	bound_width = 64
	bound_height = 32
	resistance_flags = UNACIDABLE
	flags_pass = NONE
	var/list/fallen_list

/obj/structure/prop/mainship/ship_memorial/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/dogtag))
		var/obj/item/dogtag/D = I
		if(D.fallen_names)
			to_chat(user, span_notice("You add [D] to [src]."))
			if(!fallen_list)
				fallen_list = list()
			fallen_list += D.fallen_names
			qdel(D)
		return TRUE
	else
		. = ..()

/obj/structure/prop/mainship/ship_memorial/examine(mob/user)
	. = ..()
	if((isobserver(user) || ishuman(user)) && fallen_list)
		var/faltext = ""
		for(var/i = 1 to length(fallen_list))
			if(i != length(fallen_list))
				faltext += "[fallen_list[i]], "
			else
				faltext += fallen_list[i]
		. += "[span_notice("To our fallen marines:")] <b>[faltext]</b>."


/obj/structure/prop/mainship/particle_cannon
	name = "\improper 75cm/140 Mark 74 General Atomics railgun"
	desc = "The Mark 74 Railgun is top of the line for space based weaponry. Capable of firing a round with a diameter of 3/4ths of a meter at 24 kilometers per second. It also is capable of using a variety of round types which can be interchanged at anytime with its newly designed feed system."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "1"
	resistance_flags = UNACIDABLE


/obj/structure/prop/mainship/name_stencil
	name = "\improper The TGMC, a TGMC-Class Marine Carrier Arsenal Ship"
	desc = "The name of the ship stenciled on the hull."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "TGMC1"
	density = FALSE
	resistance_flags = UNACIDABLE
	layer = ABOVE_TURF_LAYER

/obj/structure/prop/mainship/name_stencil/T
	icon_state = "TGMC1"

/obj/structure/prop/mainship/name_stencil/G
	icon_state = "TGMC2"

/obj/structure/prop/mainship/name_stencil/M
	icon_state = "TGMC3"

/obj/structure/prop/mainship/name_stencil/C
	icon_state = "TGMC4"

/obj/structure/prop/mainship/name_stencil/Initialize(mapload)
	. = ..()
	name = SSmapping.configs[SHIP_MAP].map_name


/obj/structure/prop/mainship/hangar_stencil
	name = "floor"
	desc = "A large number stenciled on the hangar floor used to designate which dropship it is."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "dropship1"
	density = FALSE
	layer = ABOVE_TURF_LAYER

/obj/structure/prop/mainship/hangar_stencil/two
	icon_state = "dropship2"

/obj/structure/prop/mainship/brokengen //all the aesthetics of having a generator without any of the function
	name = "\improper G-11 geothermal generator"
	desc = "A thermoelectric generator sitting atop a plasma-filled borehole. The powercell is missing and strange lines of text scroll by on its status panel, you get the feeling there's no fixing it."
	icon = 'icons/turf/geothermal.dmi'
	icon_state = "destroyedgen"
	resistance_flags = RESIST_ALL //normal generators can't be destroyed, so for appearances our fake ones can't be destroyed either.

/obj/structure/prop/mainship/cannon_cables
	name = "\improper Cannon cables"
	desc = "Some large cables."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "cannon_cables"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = LADDER_LAYER

/obj/structure/prop/mainship/supermatter //functionally inert, but will consume mobs and objects
	name = "supermatter crystal"
	desc = "A strangely translucent and iridescent crystal."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "darkmatter"
	layer = LADDER_LAYER
	light_range = 4
	resistance_flags = RESIST_ALL //no delaminations here


/obj/structure/prop/mainship/supermatter/proc/consume(atom/movable/consumed_object) //dust() and destroy living mobs, qdel thrown objects
	if(isliving(consumed_object))
		var/mob/living/consumed_mob = consumed_object
		consumed_mob.dust() //dust() plays a dusting animation and sets the mob to dead
	else if(isobj(consumed_object))
		qdel(consumed_object) //we cannot dust() objects so we just delete them

/obj/structure/prop/mainship/supermatter/Bumped(atom/movable/hit_object)
	if(isliving(hit_object)) //living objects get a nifty message about heat
		hit_object.visible_message(span_danger("\The [hit_object] slams into \the [src] inducing a resonance... [hit_object.p_their()] body starts to glow and burst into flames before flashing into dust!"),
			span_userdanger("You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\""),
			span_hear("You hear an unearthly noise as a wave of heat washes over you."))
	else if(isobj(hit_object) && !iseffect(hit_object))
		hit_object.visible_message(span_danger("\The [hit_object] smacks into \the [src] and rapidly flashes to ash."), null,
			span_hear("You hear a loud crack as you are washed with a wave of heat."))
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, TRUE)
	consume(hit_object) //all bumped objects get consume() called on them

/obj/structure/prop/mainship/radiationcollector
	name = "Radiation Collector Array"
	desc = "A device which uses radiation and plasma to produce power."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "radcollector"
	layer = LADDER_LAYER
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/invincibleshutter
	name = "\improper heavy shutters"
	desc = "A heavy set of blast resistant shutters."
	icon = 'icons/obj/doors/mainship/blastdoors_shutters.dmi'
	icon_state = "shutter1"
	density = TRUE
	layer = LADDER_LAYER
	light_range = 4
	resistance_flags = RESIST_ALL //no delaminations here
	opacity = TRUE

/obj/structure/prop/mainship/doorblocker //doors that exist only to block access, used mostly for valhalla omegastation
	name = "\improper Barred Airlock"
	icon = 'icons/Marine/mainship_props.dmi'
	resistance_flags = RESIST_ALL
	desc = "It opens and closes."
	opacity = TRUE

/obj/structure/prop/mainship/doorblocker/maint
	name = "\improper Maintenance Hatch"
	icon_state = "maint_locked"

/obj/structure/prop/mainship/doorblocker/external
	name = "\improper External Airlock"
	icon_state = "exit_locked"

/obj/structure/prop/mainship/doorblocker/engi
	name = "\improper External Airlock"
	icon_state = "engi_locked"

/obj/structure/prop/mainship/doorblocker/evac
	name = "\improper Evacuation Airlock"
	icon_state = "secure_locked"

/obj/structure/prop/mainship/doorblocker/command
	name = "\improper Command Airlock"
	icon_state = "command_locked"

/obj/structure/prop/mainship/doorblocker/patrol_base
	name = "\improper Main Airlock"
	icon_state = "command_locked"

/obj/structure/prop/mainship/doorblocker/patrol_base/som
	icon_state = "security_locked"

/obj/structure/prop/mainship/doorblocker/patrol_base/wide_left
	icon_state = "secure_wide_left_locked"

/obj/structure/prop/mainship/doorblocker/patrol_base/wide_right
	icon_state = "secure_wide_right_locked"

/obj/structure/prop/mainship/telecomms
	name = "subspace broadcaster"
	desc = "A mighty piece of hardware used to broadcast processed subspace signals."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "broadcaster_send"

/obj/structure/prop/mainship/telecomms/hub
	name = "subspace broadcaster"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"

/obj/structure/prop/mainship/telecomms/processor
	name = "processor unit"
	desc = "This machine is used to process large quantities of information."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"

/obj/structure/prop/mainship/telecomms/bus
	name = "bus mainframe"
	desc = "A mighty piece of hardware used to send massive amounts of data quickly."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "bus"

/obj/structure/prop/mainship/telecomms/broadcaster
	name = "subspace broadcaster"
	desc = "This machine has a dish-like shape and green lights. It is designed to detect and process subspace radio activity."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster"

/obj/structure/prop/mainship/telecomms/receiver
	name = "subspace receiver"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcast receiver"

/obj/structure/prop/mainship/telecomms/relay
	name = "telecomms relay"
	desc = "A mighty piece of hardware used to send massive amounts of data far away."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "relay"


/obj/structure/prop/mainship/suit_storage_prop
	name = "Suit Storage Unit"
	desc = "An industrial U-Stor-It Storage unit designed to accomodate all kinds of space suits. Its on-board equipment also allows the user to decontaminate the contents through a UV-ray purging cycle. There's a warning label dangling from the control pad, reading \"STRICTLY NO BIOLOGICALS IN THE CONFINES OF THE UNIT\". This one appears to be magnetically locked."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "suitstorageclose"

/obj/structure/prop/mainship/protolathe
	name = "Suit Storage Unit"
	desc = "A giant machine for processing data and producing department specific tools. A small warning light labeled 'server connection' is flashing red"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"

/obj/structure/prop/mainship/protolathe/engi
	name = "Engineering Protolathe"

/obj/structure/prop/mainship/protolathe/sci
	name = "Research Protolathe"

/obj/structure/prop/mainship/protolathe/medical
	name = "Medical Protolathe"

/obj/structure/prop/mainship/protolathe/security
	name = "Security Protolathe"

/obj/structure/prop/mainship/protolathe/service
	name = "Service Protolathe"

/obj/structure/prop/mainship/protolathe/cargo
	name = "Cargo Protolathe"

/obj/structure/prop/mainship/cannon_cables/ex_act()
	return

/obj/structure/prop/mainship/research
	icon = 'icons/obj/machines/research.dmi'

/obj/structure/prop/mainship/research/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	desc = "Manufactures circuit boards for the construction of machines."

/obj/structure/prop/mainship/research/mechafab
	icon_state = "mechfab1"
	name = "Exosuit Fabricator"
	desc = "Nothing is being built."

/obj/structure/prop/mainship/research/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"

/obj/structure/prop/mainship/research/tdoppler
	name = "tachyon-doppler array"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array.\n"
	icon_state = "tdoppler"

/obj/structure/prop/mainship/research/explosivecompressor
	name = "anomaly refinery"
	desc = "An advanced machine capable of implosion-compressing raw anomaly cores into finished artifacts. Also equipped with state of the art bomb prediction software."
	icon_state = "explosive_compressor"

/obj/structure/prop/mainship/research/tankcompressor
	name = "Tank Compressor"
	desc = "Heavy duty shielded air compressor designed to pressurize tanks above the safe limit."
	icon_state = "tank_compressor-open"

/obj/structure/prop/mainship/generator
	name = "field generator"
	desc = "A large thermal battery that projects a high amount of energy when powered."
	icon = 'icons/obj/machines/field_generator.dmi'
	icon_state = "Field_Gen"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	//100% immune to lasers and energy projectiles since it absorbs their energy.
	soft_armor = list(MELEE = 25, BULLET = 10, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 50, ACID = 70)
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/generator/shieldgen
	name = "anti-breach shielding projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "shieldoff"

/obj/structure/prop/mainship/generator/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "coil_open0"

/obj/structure/prop/mainship/generator/ground_rod
	name = "grounding rod"
	desc = "Keeps an area from being fried by Edison's Bane, does not work against handheld Tesla cannons commonly issued by paramilitaries."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "grounding_rod_open0"

/obj/structure/prop/mainship/cannon_cable_connector
	name = "\improper Cannon cable connector"
	desc = "A connector for the large cannon cables."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "cannon_cable_connector"
	density = TRUE

/obj/structure/prop/mainship/reflector
	name = "\improper reflector"
	desc = "An angled mirror for reflecting laser beams."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "reflector_prop"
	density = TRUE
	anchored = FALSE
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/mainship/cannon_cable_connector/ex_act()
	return

/obj/structure/prop/mainship/prop_sec
	name = "Security Officer"
	desc = "A NT security officer guarding the perimeter. They look rather busy and pays no attention to you."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "secprop"
	resistance_flags = RESIST_ALL
	density = TRUE

/obj/structure/prop/mainship/prop_so
	name = "Officer"
	desc = "A staff officer in charge of the ongoing operation, either too busy operating the observation consoles or simply looking at you and your comrades and hoping that you will succeed, that being said, it's best to leave them be."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "officerprop"
	resistance_flags = RESIST_ALL
	density = TRUE

/obj/structure/prop/mainship/prop_so/som
	icon_state = "officersomprop"

/obj/structure/prop/mainship/prop_tech
	name = "Technician"
	desc = "A hard working technician maintaining the vehicles of the base, as well as the base itself. They seem to be very busy investigating something right now."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "techieprop"
	resistance_flags = RESIST_ALL
	density = TRUE

/obj/structure/prop/mainship/prop_sominf
	name = "SOM Infantry"
	desc = "Standard Sons of Mars infantry with a V-31 assault rifle on hand. While their face is obscured by the visor, it feels like you should keep going instead of loitering around."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "som_inf"
	resistance_flags = RESIST_ALL
	density = TRUE


/obj/structure/prop/templedoor
	name = "Strange Temple"
	icon = 'icons/obj/doors/Doorsand.dmi'
	icon_state = "door_open"
	density = FALSE

/obj/structure/prop/oresilo
	name = "ore silo"
	desc = "An all-in-one bluespace storage and transmission system for the colony's mineral distribution needs. This one appears to be deactivated."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "silo"
	density = TRUE

/obj/structure/prop/mainship/propcarp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "carpprop"
	density = TRUE

/obj/structure/prop/mainship/propcarp/Initialize(mapload) //slightly randomize carp to simulate life
	. = ..()
	var/pickedrotate = pick(0,1,2,4,8,10)
	switch(pickedrotate) //prop carp can randomly move two tiles in any direction
		if(0) //1/6th chance of not moving in a random direction
			return
		if(1)
			dir = NORTH
			pixel_y = 64
		if(2)
			dir = SOUTH
			pixel_y = -64
		if(4)
			dir = EAST
			pixel_x = 64
		if(8)
			dir = WEST
			pixel_x = -64
		if(10)
			qdel(src)
		//remember that each carp must have at least 2 free spaces around them per carp, or they'll glitch into walls and/or each other

/obj/structure/prop/mainship/aislipprop
	name = "foam dispenser"
	desc = "A remotely-activatable dispenser for crowd-controlling foam."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "aislipper"
	density = FALSE
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/turretprop
	name = "laser turret"
	desc = "A point-defense laser turret supplied by NanoTrasen. This one looks inactive"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "turretprop"
	resistance_flags = RESIST_ALL

/obj/structure/prop/mainship/tubeprop
	name = "pneumatic tube"
	desc = "A pneumatic tube commonly used for transportation on NanoTrasen research stations."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "tubepropstraight"
	resistance_flags = RESIST_ALL
	layer = ABOVE_OBJ_LAYER //so our fake prop can visually pass under glass panels

/obj/structure/prop/mainship/tubeprop/decorative
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "decorative"
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/mainship/tubeprop/end
	icon_state = "tubepropend"

/obj/structure/prop/mainship/tubeprop/diagonal
	icon_state = "tubepropdiagonal"

/obj/structure/prop/mainship/tubeprop/decorativediagonal
	icon_state = "decorative_diag"

/obj/structure/prop/mainship/tubeprop/tubejunction
	icon_state = "tubejunction"

/obj/structure/prop/mainship/tubeprop/tubecurved
	icon_state = "tubecurved"

/obj/structure/prop/mainship/meterprop/
	name = "meter"
	desc = "That's a gas flow meter. It measures something."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "propmeterempty"
	resistance_flags = RESIST_ALL
	density = FALSE

/obj/structure/prop/mainship/meterprop/empty
	icon_state = "propmeterempty"

/obj/structure/prop/mainship/meterprop/random
	icon_state = "propmeter"
	var/kpa //fake temperatures and pressures for our meter
	var/kelvin

/obj/structure/prop/mainship/meterprop/random/examine(mob/user)
	. = ..()
	. += span_notice("The pressure gauge reads [kpa] kPa; [kelvin] K ([kelvin - 273.15]°C)") //output fake kelvin and celsius on examine

/obj/structure/prop/mainship/meterprop/empty/examine(mob/user)
	. = ..()
	. += span_notice("The pressure gauge reads 0 kPa; 0 K (-273.15°C)") //output fake kelvin and celsius on examine

/obj/structure/prop/mainship/meterprop/random/Initialize(mapload)
	. = ..()
	kpa = rand(9.3, 21.4)
	kelvin = rand(10.3, 28.4)

/obj/structure/prop/mainship/pipeprop //does not init and so doesn't generate lag at all
	name = "pipe"
	desc = "A one meter section of regular pipe."
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-2"
	density = FALSE
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/structure/prop/mainship/pipeprop/manifold
	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-2"

/obj/structure/prop/mainship/pipeprop/pump
	name = "pipe manifold"
	desc = "A pump that moves gas by pressure."
	icon = 'icons/obj/atmospherics/components/binary_devices.dmi'
	icon_state = "pump_map-2"

/obj/structure/prop/mainship/pipeprop/pump/on
	icon_state = "pump_on"
	layer = GAS_PUMP_LAYER

/obj/structure/prop/mainship/halfbuilt_mech
	name = "half-assembled mech"
	desc = "A half-assembled mech. It's missing limbs and the maintenance ports are open. You probably shouldn't screw with it."
	icon_state = ""
	pixel_x = -16
	/// selected parts you want displayed. remove parts if you dont want them
	var/selected_parts = list(
		MECH_GREY_TORSO = MECH_ASSAULT,
		MECH_GREY_LEGS = MECH_ASSAULT,
		MECH_GREY_L_ARM = MECH_ASSAULT,
	)

/obj/structure/prop/mainship/halfbuilt_mech/Initialize(mapload)
	. = ..()
	var/default_colors = MECH_GREY_PRIMARY_DEFAULT + MECH_GREY_SECONDARY_DEFAULT
	var/default_visor = MECH_GREY_VISOR_DEFAULT
	var/new_overlays = list()
	for(var/slot in selected_parts)
		var/datum/mech_limb/head/typepath = get_mech_limb(slot, selected_parts[slot])
		if(slot == MECH_GREY_L_ARM || slot == MECH_GREY_R_ARM)
			var/iconstate = "left"
			if(slot == MECH_GREY_R_ARM)
				iconstate = "right"
			new_overlays += iconstate2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.greyscale_type), default_colors), iconstate)
			continue
		new_overlays += icon2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.greyscale_type), default_colors))
		if(slot == MECH_GREY_HEAD)
			new_overlays += icon2appearance(SSgreyscale.GetColoredIconByType(initial(typepath.visor_config), default_visor))
	overlays = new_overlays

/obj/structure/prop/mainship/halfbuilt_mech/legs
	desc = "Leg."
	selected_parts = list(
		MECH_GREY_LEGS = MECH_RECON,
	)

/obj/structure/prop/mainship/halfbuilt_mech/vanguard
	selected_parts = list(
		MECH_GREY_TORSO = MECH_VANGUARD,
		MECH_GREY_HEAD = MECH_VANGUARD,
		MECH_GREY_LEGS = MECH_VANGUARD,
		MECH_GREY_L_ARM = MECH_VANGUARD,
	)

/obj/structure/prop/mainship/halfbuilt_mech/vanguard_finished
	name = "Vanguard mech"
	desc = "An advanced vanguard chassis mech. It's a recent advancement in military hardware only been in service for a short time and not in mass production yet."
	selected_parts = list(
		MECH_GREY_TORSO = MECH_VANGUARD,
		MECH_GREY_HEAD = MECH_VANGUARD,
		MECH_GREY_LEGS = MECH_VANGUARD,
		MECH_GREY_L_ARM = MECH_VANGUARD,
		MECH_GREY_R_ARM = MECH_VANGUARD,
	)

/obj/structure/prop/mainship/chimney
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/Marine/mainship_props64.dmi'
	icon_state = "fireplace"

//items props

/obj/item/prop
	name = "GENERIC SHIP PROP"
	desc = "THIS SHOULDN'T BE VISIBLE, AHELP 'ART-P03' IF SEEN IN ROUND WITH LOCATION"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "hangarbox"

/obj/item/prop/organ
	name = "organ"
	desc = "It looks like it probably just plopped out. It's too decayed to be reinserted in a patient."
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "heart"

/obj/item/prop/organ/heart
	name = "heart"
	icon_state = "heart-off"

/obj/item/prop/organ/brain
	name = "brain"
	icon_state = "brain1"

/obj/item/prop/organ/appendix
	name = "appendix"
	icon_state = "appendix"

/obj/item/prop/organ/lungs
	name = "lungs"
	icon_state = "lungs"

/obj/item/prop/organ/kidneys
	name = "kidneys"
	icon_state = "kidneys"

/obj/item/prop/organ/eyes
	name = "eyes"
	icon_state = "eyes"

/obj/item/prop/organ/liver
	name = "liver"
	icon_state = "liver"

/obj/item/prop/aimodule
	name = "AI module"
	desc = "An AI Module for programming laws to an AI."
	icon_state = "std_mod"

/obj/item/prop/aimodule/Initialize(mapload)
	. = ..()
	name = pick("'Safeguard' AI Module'",
				"'OneHuman' AI Module",
				"'ProtectStation' AI Module",
				"'Quarantine' AI Module",
				"'OxygenIsToxicToHumans' AI Module",
				"'Freeform' AI Module",
				"\improper 'Remove Law' AI module",
				"\improper 'Reset' AI module",
				"'Purge' AI Module",
				"'Asimov' Core AI Module",
				"'Asimov++' Core AI Module",
				"'Corporate' Core AI Module",
				"'P.A.L.A.D.I.N. version 3.5e' Core AI Module",
				"'T.Y.R.A.N.T.' Core AI Module",
				"'Robo-Officer' Core AI Module",
				"'Antimov' Core AI Module",
				"'Freeform' Core AI Module",
				"'Mother Drone' Core AI Module",
				"'Robodoctor' Core AI Module",
				"'Reportertron' Core AI Module",
				"'Thermodynamic' Core AI Module",
				"'Live And Let Live' Core AI Module",
				"'Guardian of Balance' Core AI Module",
				"'Station Efficiency' Core AI Module",
				"'Peacekeeper' Core AI Module",
				"'H.O.G.A.N.' Core AI Module",
	)

/obj/item/prop/aicard
	name = "intelliCard"
	desc = "A storage device for AIs. Patent pending."
	icon_state = "aicard"

/obj/item/prop/aicard/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "aicard-404"

/obj/item/prop/dogtag
	name = "John Doe" //generic name
	desc = "The remains of a marine long dead, you hope they found peace."
	icon = 'icons/obj/items/card.dmi'
	icon_state = "dogtag"

/obj/item/prop/dogtag/pfcjim
	name = "PFC Jim's dog tag"
	desc = "Whoever PFC Jim is, you hope made it out alive."
	icon = 'icons/obj/items/card.dmi'
	icon_state = "dogtag"

/obj/item/prop/dogtag/random/Initialize(mapload)
	. = ..()
	name = GLOB.namepool[/datum/namepool].get_random_name(pick(MALE, FEMALE))

///BROKEN MARINE VENDOR PROPS

/obj/structure/prop/brokenvendor
	name = "\improper Broken vendor"
	icon = 'icons/Marine/mainship_props.dmi'
	desc = "The insides of this vendor are visible and rusted through, you get the feeling there's no fixing this machine."
	density = TRUE
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/brokenvendor/brokenweaponsrack
	icon_state = "marinearmory-broken"

/obj/structure/prop/brokenvendor/brokenuniformvendor
	name = "\improper Broken automated uniform closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenuniformvendor/specialist
	name = "\improper Broken specialist equipment rack"
	icon_state = "specialist-broken"
	desc = "You study the rusted hulk in vain trying to determine what this vendor was before realizing that it's hopeless."

/obj/structure/prop/brokenvendor/brokenspecialistvendor/sg
	name = "\improper Broken automated smart gunner closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenspecialistvendor/leader
	name = "\improper Broken automated leader closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenspecialistvendor/corpsman
	name = "\improper Broken automated corpsman closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenspecialistvendor/engineer
	name = "\improper Broken automated engineer closet"
	icon_state = "marineuniform-broken"

/obj/structure/prop/brokenvendor/brokenmarinemedvendor
	icon_state = "marinemed-broken"

/obj/structure/prop/brokenvendor/brokennanomedvendor
	icon_state = "med-broken"

/obj/structure/prop/brokenvendor/brokencorpsmanvendor
	icon_state = "corpsmanvendor-broken"

/obj/structure/prop/brokenvendor/engivend
	icon_state = "engivend-broken"

/obj/structure/prop/brokenvendor/surplusclothes
	name = "\improper Broken surplus clothes vendor"
	icon_state = "surplus_clothes-broken"

/obj/structure/prop/brokenvendor/surplusarmor
	name = "\improper Broken armor clothes vendor"
	icon_state = "surplus_armor-broken"

///BROKEN VEHICLE PROPS
/obj/structure/prop/vehicle
	layer = TANK_BARREL_LAYER
/obj/structure/prop/vehicle/van
	name = "van"
	desc = "An old van, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "van"
	density = TRUE
	coverage = 80
	bound_height = 32
	bound_width = 64
	resistance_flags = RESIST_ALL

/obj/structure/prop/vehicle/van/Initialize(mapload)
	. = ..()
	if(dir & (NORTH|SOUTH))
		bound_height = 64
		bound_width = 32

/obj/structure/prop/vehicle/van/destructible
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/vehicle/truck
	name = "truck"
	desc = "An old truck, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "truck"
	density = TRUE
	coverage = 80
	bound_height = 32
	bound_width = 64
	resistance_flags = RESIST_ALL

/obj/structure/prop/vehicle/truck/destructible
	max_integrity = 150
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/vehicle/truck/truckcargo
	icon_state = "truck_cargo"

/obj/structure/prop/vehicle/truck/truckcargo/destructible
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/vehicle/crane
	name = "crane"
	desc = "An old crane, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "crane"
	density = TRUE
	coverage = 80
	bound_height = 64
	bound_width = 64
	resistance_flags = RESIST_ALL

/obj/structure/prop/vehicle/crane/destructible
	max_integrity = 300
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/vehicle/crane/cranecargo
	icon_state = "crane_cargo"

/obj/structure/prop/vehicle/crane/cranecargo/destructible
	max_integrity = 300
	resistance_flags = XENO_DAMAGEABLE

/obj/structure/prop/vehicle/crawler
	name = "crawler"
	desc = "An old crawler, seems to be broken down."
	icon = 'icons/obj/structures/vehicles.dmi'
	icon_state = "crawler"
	density = TRUE
	coverage = 80
	bound_height = 32
	bound_width = 64
	resistance_flags = RESIST_ALL

/obj/structure/prop/vehicle/crawler/destructible
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE


/obj/structure/prop/vehicle/crawler/crawler_blue
	icon_state = "crawler_crate_b"

/obj/structure/prop/vehicle/crawler/crawler_red
	icon_state = "crawler_crate_r"

/obj/structure/prop/vehicle/crawler/crawler_green
	icon_state = "crawler_crate_g"

/obj/structure/prop/vehicle/crawler/crawler_fuel
	icon_state = "crawler_fuel"

/obj/structure/prop/vehicle/crawler/crawler_cargo
	icon_state = "crawler_cargo"

/obj/structure/prop/vehicle/tank
	name = "Decommissioned TAV - Rhino"
	desc = "A decomissioned tank, all methods of propulsion have been disabled and the entrances sealed."
	icon = 'icons/Marine/tank_propns.dmi'
	icon_state = "tank_complete"
	density = TRUE
	coverage = 80
	bound_height = 128
	bound_width = 128
	resistance_flags = RESIST_ALL

/obj/structure/prop/vehicle/tank/north
	icon = 'icons/Marine/tank_propns.dmi'
	icon_state = "tank_complete"
	bound_height = 128
	bound_width = 96

/obj/structure/prop/vehicle/tank/north/base
	name = "Decommissioned TAV - Rhino"
	desc = "The base of a decomissioned tank."
	icon_state = "tank_base"

/obj/structure/prop/vehicle/tank/north/altnorth
	icon_state = "tank_complete_alt"

/obj/structure/prop/vehicle/tank/east
	icon = 'icons/Marine/tank_propew.dmi'
	icon_state = "tank_complete"
	bound_height = 96
	bound_width = 128

/obj/structure/prop/vehicle/tank/east/base
	name = "Decommissioned TAV - Rhino"
	desc = "The base of a decomissioned tank."
	icon_state = "tank_base"

/obj/structure/prop/vehicle/tank/east/turret
	icon_state = "turret_viper"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/east/turret/complete
	icon_state = "turret_complete"

/obj/structure/prop/vehicle/tank/east/turretalt
	icon_state = "turret_cobra"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/east/barrel
	icon_state = "ltb_cannon_0"
	layer = TANK_BARREL_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/tank/east/barrel/broken
	icon_state = "ltb_cannon_1"

/obj/structure/prop/vehicle/tank/east/barrel/minigun
	icon_state = "ltaaap_minigun_0"

/obj/structure/prop/vehicle/tank/east/barrel/minigunbroken
	icon_state = "ltaaap_minigun_1"

/obj/structure/prop/vehicle/tank/east/alteast
	icon_state = "tank_complete_alt"

/obj/structure/prop/vehicle/tank/east/decoration
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = TANK_DECORATION_LAYER

/obj/structure/prop/vehicle/tank/east/decoration/treads
	icon_state = "treads_stationary"

/obj/structure/prop/vehicle/tank/east/decoration/damagedtreads
	icon_state = "damaged_hardpt_treads"

/obj/structure/prop/vehicle/tank/east/decoration/armor
	icon_state = "caustic_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/causticarmor
	icon_state = "caustic_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/concussivearmor
	icon_state = "concussive_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/ballisticarmor
	icon_state = "ballistic_armor"

/obj/structure/prop/vehicle/tank/east/decoration/armor/paladinarmor
	icon_state = "paladin_armor"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpoint
	icon_state = "damaged_hardpt_armor"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointframe
	icon_state = "damaged_hardpt_frame"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointturret
	icon_state = "damaged_hardpt_turret"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointone
	icon_state = "damaged_hardpt_primary"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointtwo
	icon_state = "damaged_hardpt_secondary"

/obj/structure/prop/vehicle/tank/east/decoration/damagedhardpointthree
	icon_state = "damaged_hardpt_support"

/obj/structure/prop/vehicle/tank/east/decoration/slaunchone
	icon_state = "slauncher_0"

/obj/structure/prop/vehicle/tank/east/decoration/slaunchtwo
	icon_state = "slauncher_1"

/obj/structure/prop/vehicle/tank/east/decoration/slaunchthree
	icon_state = "slauncher_2"

/obj/structure/prop/vehicle/tank/east/decoration/driveenhancerone
	icon_state = "odrive_enhancer_1"

/obj/structure/prop/vehicle/tank/east/decoration/driveenhancerzero
	icon_state = "odrive_enhancer_0"

/obj/structure/prop/vehicle/tank/east/decoration/flamer
	icon_state = "flamer_1"

/obj/structure/prop/vehicle/tank/east/decoration/glauncherone
	icon_state = "glauncher_1"

/obj/structure/prop/vehicle/tank/east/decoration/glauncherzero
	icon_state = "glauncher_0"

/obj/structure/prop/vehicle/tank/east/decoration/cupolaone
	icon_state = "m56cupola_1"

/obj/structure/prop/vehicle/tank/east/decoration/cupolazero
	icon_state = "m56cupola_0"

/obj/structure/prop/vehicle/tank/east/decoration/towlauncherone
	icon_state = "towlauncher_1"

/obj/structure/prop/vehicle/tank/east/decoration/towlauncherzero
	icon_state = "towlauncher_0"

/obj/structure/prop/vehicle/tank/east/decoration/warrayone
	icon_state = "warray_1"

/obj/structure/prop/vehicle/tank/east/decoration/warrayzero
	icon_state = "warray_0"

/obj/structure/prop/vehicle/tank/east/decoration/artmodone
	icon_state = "artillerymod_1"

/obj/structure/prop/vehicle/tank/east/decoration/artmodzero
	icon_state = "artillerymod_0"

/obj/structure/prop/vehicle/tank/east/armor/snowplow
	icon_state = "snowplow_0"

/obj/structure/prop/vehicle/tank/east/armor/snowplowone
	icon_state = "snowplow_1"

/obj/structure/prop/vehicle/tank/north/turret
	icon_state = "turret_viper"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/north/turret/complete
	icon_state = "turret_complete"

/obj/structure/prop/vehicle/tank/north/turretalt
	icon_state = "turret_cobra"
	layer = TANK_TURRET_LAYER
	desc = "The turret of a decomissioned tank."

/obj/structure/prop/vehicle/tank/north/barrel
	icon_state = "ltb_cannon_0"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/tank/north/barrel/broken
	icon_state = "ltb_cannon_1"

/obj/structure/prop/vehicle/tank/north/barrel/minigun
	icon_state = "ltaaap_minigun_0"

/obj/structure/prop/vehicle/tank/north/barrel/minigunbroken
	icon_state = "ltaaap_minigun_1"

/obj/structure/prop/vehicle/tank/north/altnorth
	icon_state = "tank_complete_alt"

/obj/structure/prop/vehicle/tank/north/decoration
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = TANK_DECORATION_LAYER

/obj/structure/prop/vehicle/tank/north/decoration/treads
	icon_state = "treads_stationary"

/obj/structure/prop/vehicle/tank/north/decoration/damagedtreads
	icon_state = "damaged_hardpt_treads"

/obj/structure/prop/vehicle/tank/north/decoration/armor
	icon_state = "caustic_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/causticarmor
	icon_state = "caustic_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/concussivearmor
	icon_state = "concussive_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/ballisticarmor
	icon_state = "ballistic_armor"

/obj/structure/prop/vehicle/tank/north/decoration/armor/paladinarmor
	icon_state = "paladin_armor"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpoint
	icon_state = "damaged_hardpt_armor"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointframe
	icon_state = "damaged_hardpt_frame"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointturret
	icon_state = "damaged_hardpt_turret"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointone
	icon_state = "damaged_hardpt_primary"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointtwo
	icon_state = "damaged_hardpt_secondary"

/obj/structure/prop/vehicle/tank/north/decoration/damagedhardpointthree
	icon_state = "damaged_hardpt_support"

/obj/structure/prop/vehicle/tank/north/decoration/slaunchone
	icon_state = "slauncher_0"

/obj/structure/prop/vehicle/tank/north/decoration/slaunchtwo
	icon_state = "slauncher_1"

/obj/structure/prop/vehicle/tank/north/decoration/slaunchthree
	icon_state = "slauncher_2"

/obj/structure/prop/vehicle/tank/north/decoration/driveenhancerone
	icon_state = "odrive_enhancer_1"

/obj/structure/prop/vehicle/tank/north/decoration/driveenhancerzero
	icon_state = "odrive_enhancer_0"

/obj/structure/prop/vehicle/tank/north/decoration/flamer
	icon_state = "flamer_1"

/obj/structure/prop/vehicle/tank/north/decoration/glauncherone
	icon_state = "glauncher_1"

/obj/structure/prop/vehicle/tank/north/decoration/glauncherzero
	icon_state = "glauncher_0"

/obj/structure/prop/vehicle/tank/north/decoration/cupolaone
	icon_state = "m56cupola_1"

/obj/structure/prop/vehicle/tank/north/decoration/cupolazero
	icon_state = "m56cupola_0"

/obj/structure/prop/vehicle/tank/north/decoration/towlauncherone
	icon_state = "towlauncher_1"

/obj/structure/prop/vehicle/tank/north/decoration/towlauncherzero
	icon_state = "towlauncher_0"

/obj/structure/prop/vehicle/tank/north/decoration/warrayone
	icon_state = "warray_1"

/obj/structure/prop/vehicle/tank/north/decoration/warrayzero
	icon_state = "warray_0"

/obj/structure/prop/vehicle/tank/north/decoration/artmodone
	icon_state = "artillerymod_1"

/obj/structure/prop/vehicle/tank/north/decoration/artmodzero
	icon_state = "artillerymod_0"

/obj/structure/prop/vehicle/tank/north/armor/snowplow
	icon_state = "snowplow_0"

/obj/structure/prop/vehicle/tank/north/armor/snowplowone
	icon_state = "snowplow_1"

/obj/structure/prop/vehicle/apc
	name = "Decommissioned TAV - Athena"
	desc = "A decomissioned APC, all methods of propulsion have been disabled and the entrances sealed."
	icon = 'icons/Marine/apc_prop.dmi'
	icon_state = "apc_base"
	density = TRUE
	coverage = 70
	bound_height = 128
	bound_width = 128
	resistance_flags = RESIST_ALL

/obj/structure/prop/vehicle/apc/Initialize(mapload)
	. = ..()
	if(dir == EAST || dir == WEST)
		bound_height = 64
		pixel_y = -20
	else
		bound_width = 64
		pixel_x = -34

/obj/structure/prop/vehicle/apc/med
	icon_state = "apc_base_med"

/obj/structure/prop/vehicle/apc/com
	icon_state = "apc_base_com"

/obj/structure/prop/vehicle/apc/wheelszero
	icon_state = "wheels_0"
	layer = TANK_TURRET_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/wheelsone
	icon_state = "wheels_1"
	layer = TANK_TURRET_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/damagedframe
	icon_state = "damaged_frame"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/damagedhptone
	icon_state = "damaged_hdpt_primary"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/damagedhpttwo
	icon_state = "damaged_hdpt_secondary"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/damagedhpthree
	icon_state = "damaged_hdpt_support"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/dualcannonzero
	icon_state = "dualcannon_0"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/dualcannonone
	icon_state = "dualcannon_1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/decoration
	icon_state = "frontalcannon_0"
	density = FALSE
	layer = TANK_DECORATION_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/structure/prop/vehicle/apc/decoration/frontturretzero
	icon_state = "frontalcannon_0"

/obj/structure/prop/vehicle/apc/decoration/frontturretone
	icon_state = "frontalcannon_1"

/obj/structure/prop/vehicle/apc/decoration/freightzero
	icon_state = "freight_0"

/obj/structure/prop/vehicle/apc/decoration/freightone
	icon_state = "freight_1"

/obj/structure/prop/vehicle/apc/decoration/freighttwo
	icon_state = "freight_2"

/obj/structure/prop/vehicle/apc/decoration/freighttwo
	icon_state = "freight_2"

/obj/structure/prop/vehicle/apc/decoration/commsrelayzero
	icon_state = "comms_relay_0"

/obj/structure/prop/vehicle/apc/decoration/commsrelayone
	icon_state = "comms_relay_1"

/obj/structure/prop/vehicle/apc/decoration/flarelauncherzero
	icon_state = "flare_launcher_0"

/obj/structure/prop/vehicle/apc/decoration/flarelauncherone
	icon_state = "flare_launcher_1"

/obj/structure/prop/vehicle/apc/decoration/flarelaunchertwo
	icon_state = "flare_launcher_2"

/obj/structure/prop/vehicle/apc/decoration/emptyfuelcell
	icon_state = "emptyfuelcell"

/obj/structure/prop/mainship/gelida/propplaceholder
	name = "prop placeholder"
	desc = "Somebody fucked up, ping the map creator on Discord with the location of this object."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "placeholderprop"

/obj/structure/prop/mainship/gelida/smallwire
	name = "small wire"
	desc = "A small patch of wiring used for cordoning off areas."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "small_wire"
	density = FALSE

/obj/structure/prop/mainship/gelida/lightstick
	name = "light stick"
	desc = "A post with an empty bulb at the top, used for lighting areas of dense snow."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "lightstick_spoke1"
	density = FALSE

/obj/structure/prop/mainship/gelida/planterbox
	name = "plant box"
	desc = "A metallic box used for holding growing plants, this one is empty."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "planter_box_empty"
	layer = BELOW_OBJ_LAYER

/obj/structure/prop/mainship/gelida/planterboxsoil
	name = "plant box"
	desc = "A metallic box used for holding growing plants, this one is filled with soil."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "planter_box_soil"
	layer = BELOW_OBJ_LAYER

/obj/structure/prop/mainship/gelida/planterboxsoilgrid
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "soil_grid"
	layer = BELOW_OBJ_LAYER

/obj/structure/prop/mainship/gelida/propserver
	name = "colony research server"
	desc = "This machine sits quietly, you can see a warning light faintly shining on its diagnostic panel."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "comm_server_off"

/obj/structure/prop/mainship/gelida/propserveralt
	name = "colony research server"
	desc = "This machine sits quietly, you can see a warning light faintly shining on its diagnostic panel."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server_alt"

/obj/structure/prop/mainship/gelida/barrier
	name = "security barrier"
	desc = "A deployable barrier used by security forces to cordone off an area."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "barrier0"

/obj/structure/prop/mainship/gelida/heavycablenode
	name = "heavy cable node"
	desc = "A heavy cable node used for linking high performance cables between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "node"
	density = FALSE

/obj/structure/prop/mainship/gelida/powerconnector
	name = "heavy cable power connector"
	desc = "A heavy cable node used for connecting high performance cables between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "powerconnector"
	layer = ATMOS_PIPE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/powerccable
	name = "heavy cable wiring"
	desc = "A heavy cable wire used rapid data transfer between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "powercableheavy"
	layer = ATMOS_PIPE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/powercconnectortwoside
	name = "heavy cable wiring"
	desc = "A heavy cable wire used rapid data transfer between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "powerconnectortwoside"
	layer = ATMOS_PIPE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/powercconnectortwosidealt
	name = "heavy cable wiring"
	desc = "A heavy cable wire used rapid data transfer between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "powerconnectortwosidealt"
	layer = ATMOS_PIPE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/powercconnectorthreeside
	name = "heavy cable wiring"
	desc = "A heavy cable wire used rapid data transfer between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "powerconnectorthreeside"
	layer = ATMOS_PIPE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/powercconnectorfourside
	name = "heavy cable wiring"
	desc = "A heavy cable wire used rapid data transfer between buildings."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "powerconnectorfourside"
	layer = ATMOS_PIPE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/rails
	name = "minecart rails"
	desc = "Metal rails used for guiding a minecart."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "rail"
	layer = BELOW_TABLE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/railbumper
	name = "minecart rail bumper"
	desc = "A metal bumper designed to catch out of control minecarts."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "rail_bumpers"
	layer = BELOW_TABLE_LAYER
	density = FALSE

/obj/structure/prop/mainship/gelida/register
	name = "register"
	desc = "An antique cash register, it accepts only hard currency, not spacecredits."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "register_static"
	density = FALSE

/obj/structure/prop/mainship/gelida/propladder
	name = "ladder"
	desc = "The ladder sways precariously, its connection to the upper floor severed by a large chunk of sharp metal."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "ladder11"

/obj/structure/prop/mainship/gelida/miner
	name = "miner"
	desc = "The machine stands inert, waiting for the command to begin extracting natural resources from the earth below."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "thumper"

/obj/structure/prop/radio_prop
	name = "radio"
	desc = "A standard military radio."
	icon = 'icons/obj/items/radio.dmi'
	icon_state = "beacon"
	var/datum/looping_sound/radio/chatter_loop

/obj/structure/prop/radio_prop/Initialize(mapload, ...)
	. = ..()
	chatter_loop = new(null, FALSE)
	chatter_loop.start(src)

/obj/structure/prop/radio_prop/Destroy()
	QDEL_NULL(chatter_loop)
	return ..()

/obj/structure/prop/mainship/railing
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	icon = 'icons/Marine/mainship_props.dmi'
	density = FALSE
	icon_state = "railing"

/obj/structure/prop/mainship/railing/corner
	name = "railing"
	desc = "Basic railing meant to protect idiots like you from falling."
	density = FALSE
	icon_state = "railing_corner"

/obj/structure/prop/mainship/solar
	name = "Solar Array"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "sp_base"

/obj/structure/prop/mainship/solar/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon_state = "tracker_base"

/obj/structure/prop/vehicle/som_mech
	name = "Marauder assault mech"
	desc = "A heavily armed mech used by the SOM to spearhead an assault, this one seems to be non-functional."
	icon = 'icons/Marine/mech_prop.dmi'
	icon_state = "som_mech"
	density = TRUE
	coverage = 70
	bound_width = 32
	pixel_x = -15
	pixel_y = -15
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER

/obj/structure/prop/machine_frame3
	name = "machine frame"
	desc = "That's a constructable machine frame."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_2"

/obj/structure/prop/keycardauth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"

/obj/structure/prop/turbine
	name = "power turbine"
	desc = "A gigantic turbine that runs on who knows what. It could probably be turned on by someone with the correct know-how."
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "biomass_turbine"
	density = TRUE


//TG BROKEN VENDOR PROPS
//USE THESE SPARINGLY OUTSIDE OF TG THEMED MAPS OR I'LL BREAK YOUR KNEECAPS

/obj/structure/prop/tgbrokenvendor
	name = "\improper Broken vendor"
	icon = 'icons/obj/tg_vending_props.dmi'
	desc = "The insides of this vendor are visible and rusted through, you get the feeling there's no fixing this machine."
	density = TRUE
	///var to control vendor appearance, can be vendor_broken, vendor_working or vendor_blank
	var/vendorstate = VENDOR_BROKEN

/obj/structure/prop/tgbrokenvendor/Initialize(mapload)
	. = ..()
	vendorstate = pick(VENDOR_BROKEN, VENDOR_BLANK)
	if(vendorstate == VENDOR_BROKEN)
		icon_state += "-broken"
	else
		icon_state += "-off"

/obj/structure/prop/tgbrokenvendor/snackbrokebed
	icon_state = "snack"

/obj/structure/prop/tgbrokenvendor/snackbrokeblue
	icon_state = "snackblue"

/obj/structure/prop/tgbrokenvendor/snackbrokeorange
	icon_state = "snackorange"

/obj/structure/prop/tgbrokenvendor/snackbrokegreen
	icon_state = "snackgreen"

/obj/structure/prop/tgbrokenvendor/snackbroketeal
	icon_state = "snackteal"

/obj/structure/prop/tgbrokenvendor/smartfridge
	icon_state = "smartfridge"

/obj/structure/prop/tgbrokenvendor/dinnerware
	icon_state = "dinnerware"

/obj/structure/prop/tgbrokenvendor/cigs
	icon_state = "cigs"

/obj/structure/prop/tgbrokenvendor/generic
	icon_state = "generic"

/obj/structure/prop/tgbrokenvendor/sec
	icon_state = "sec"

/obj/structure/prop/tgbrokenvendor/nutri
	icon_state = "nutri"

/obj/structure/prop/tgbrokenvendor/seeds
	icon_state = "seeds"

/obj/structure/prop/tgbrokenvendor/cola
	icon_state = "cola-machine"

/obj/structure/prop/tgbrokenvendor/colablack
	icon_state = "cola_black"

/obj/structure/prop/tgbrokenvendor/colared
	icon_state = "cola_red"

/obj/structure/prop/tgbrokenvendor/spaceup
	icon_state = "space_up"

/obj/structure/prop/tgbrokenvendor/pwrgame
	icon_state = "starkist"

/obj/structure/prop/tgbrokenvendor/starkist
	icon_state = "pwr_game"

/obj/structure/prop/tgbrokenvendor/soda
	icon_state = "starkist"

/obj/structure/prop/tgbrokenvendor/sovietsoda
	icon_state = "sovietsoda"

/obj/structure/prop/tgbrokenvendor/coffee
	icon_state = "coffee"

/obj/structure/prop/tgbrokenvendor/boozeomat
	icon_state = "boozeomat"

/obj/structure/prop/tgbrokenvendor/magivend
	icon_state = "MagiVend"

/obj/structure/prop/tgbrokenvendor/med
	icon_state = "med"

/obj/structure/prop/tgbrokenvendor/drug
	icon_state = "drug"

/obj/structure/prop/tgbrokenvendor/engi
	icon_state = "engi"

/obj/structure/prop/tgbrokenvendor/robotics
	icon_state = "robotics"

/obj/structure/prop/tgbrokenvendor/cart
	icon_state = "cart"

/obj/structure/prop/tgbrokenvendor/theater
	icon_state = "theater"

/obj/structure/prop/tgbrokenvendor/clothes
	icon_state = "clothes"

/obj/structure/prop/tgbrokenvendor/liberationstation
	icon_state = "liberationstation"

/obj/structure/prop/tgbrokenvendor/syndi
	icon_state = "syndi"

/obj/structure/prop/tgbrokenvendor/ntdonk
	icon_state = "nt-donk"

/obj/structure/prop/tgbrokenvendor/games
	icon_state = "games"

/obj/structure/prop/tgbrokenvendor/bardrobe
	icon_state = "bardrobe"

/obj/structure/prop/tgbrokenvendor/secdrobe
	icon_state = "secdrobe"

/obj/structure/prop/tgbrokenvendor/chefdrobe
	icon_state = "chefdrobe"

/obj/structure/prop/tgbrokenvendor/medidrobe
	icon_state = "medidrobe"

/obj/structure/prop/tgbrokenvendor/chemdrobe
	icon_state = "chemdrobe"

/obj/structure/prop/tgbrokenvendor/genedrobe
	icon_state = "genedrobe"

/obj/structure/prop/tgbrokenvendor/virodrobe
	icon_state = "virodrobe"

/obj/structure/prop/tgbrokenvendor/scidrobe
	icon_state = "scidrobe"

/obj/structure/prop/tgbrokenvendor/robodrobe
	icon_state = "robodrobe"

/obj/structure/prop/tgbrokenvendor/chapdrobe
	icon_state = "chapdrobe"

/obj/structure/prop/tgbrokenvendor/engidrobe
	icon_state = "engidrobe"

/obj/structure/prop/tgbrokenvendor/atmosdrobe
	icon_state = "atmosdrobe"

/obj/structure/prop/tgbrokenvendor/hydrodrobe
	icon_state = "hydrobe"

/obj/structure/prop/tgbrokenvendor/cargodrobe
	icon_state = "cargodrobe"

/obj/structure/prop/tgbrokenvendor/curadrobe
	icon_state = "curadrobe"

/obj/structure/prop/tgbrokenvendor/janidrobe
	icon_state = "janidrobe"

/obj/structure/prop/tgbrokenvendor/lawdrobe
	icon_state = "lawdrobe"

/obj/structure/prop/tgbrokenvendor/detdrobe
	icon_state = "detdrobe"

/obj/structure/prop/tgbrokenvendor/parts
	icon_state = "parts"

/obj/structure/prop/tgbrokenvendor/custom
	icon_state = "custom"

/obj/structure/prop/tgbrokenvendor/greed
	icon_state = "greed"

/obj/structure/prop/tgbrokenvendor/centdrobe
	icon_state = "centdrobe"

/obj/structure/prop/tgbrokenvendor/shamblersjuice
	icon_state = "shamblers_juice"

/obj/structure/prop/tgbrokenvendor/modularpc
	icon_state = "modularpc"

/obj/structure/prop/camera
	name = "broken security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "camera_icon"
	layer = WALL_OBJ_LAYER
	anchored = TRUE

/obj/structure/prop/camera/Initialize(mapload, newDir)
	. = ..()
	icon_state = "camera1"

/obj/structure/prop/computer/broken
	name = "broken computer"
	desc = "A busted PC, the internals look fried, there's no fixing this one."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "broken_computer1"
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	max_integrity = 120

/obj/structure/prop/computer/broken/two
	icon_state = "broken_computer2"

/obj/structure/prop/computer/broken/three
	icon_state = "broken_computer3"

/obj/structure/prop/computer/broken/four
	icon_state = "broken_computer4"

/obj/structure/prop/computer/broken/five
	icon_state = "broken_computer5"

/obj/structure/prop/computer/broken/six
	icon_state = "broken_computer6"

/obj/structure/prop/computer/broken/seven
	icon_state = "broken_computer7"

/obj/structure/prop/computer/broken/eight
	icon_state = "broken_computer8"

/obj/structure/prop/computer/broken/nine
	icon_state = "broken_computer9"

/obj/structure/prop/computer/broken/ten
	icon_state = "broken_computer10"

/obj/structure/prop/computer/broken/eleven
	icon_state = "broken_computer11"

/obj/structure/prop/computer/broken/twelve
	icon_state = "broken_computer12"

/obj/structure/prop/computer/broken/thirteen
	icon_state = "broken_computer13"

/obj/structure/prop/computer/broken/fourteen
	icon_state = "broken_computer14"

/obj/structure/prop/computer/broken/fifteen
	icon_state = "broken_computer15"

/obj/structure/prop/computer/broken/sixteen
	icon_state = "broken_computer16"

/obj/structure/prop/computer/broken/seventeen
	icon_state = "broken_computer17"

/obj/structure/prop/computer/broken/eighteen
	icon_state = "broken_computer18"

/obj/structure/prop/computer/broken/nineteen
	icon_state = "broken_computer19"

/obj/machinery/computer/solars
	name = "Port Quarter Solar Control"
	desc = "A controller for solar panel arrays."
	icon_state = "solar"

/obj/structure/prop/mainship/errorprop
	name = "ERROR"
	desc = "If you see this object in game you should ahelp, something has broken."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "error"

#undef VENDOR_BROKEN
#undef VENDOR_BLANK
