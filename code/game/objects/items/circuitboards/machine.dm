

//Machine Frame Circuit Boards
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add materials to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/

/obj/item/circuitboard/machine
	var/list/req_components = null
	var/frame_desc = null

/obj/item/circuitboard/machine/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	build_path = "/obj/machinery/r_n_d/destructive_analyzer"
	origin_tech = "magnets=2;engineering=2;programming=2"
	frame_desc = "Requires 1 Scanning Module, 1 Micro Manipulator, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/stock_parts/scanning_module" = 1,
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/stock_parts/micro_laser" = 1)

/obj/item/circuitboard/machine/autolathe
	name = "Circuit board (Autolathe)"
	build_path = "/obj/machinery/autolathe"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 3 Matter Bins, 1 Micro Manipulator, and 1 Console Screen."
	req_components = list(
							"/obj/item/stock_parts/matter_bin" = 3,
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/stock_parts/console_screen" = 1)

/obj/item/circuitboard/machine/protolathe
	name = "Circuit board (Protolathe)"
	build_path = "/obj/machinery/r_n_d/protolathe"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 2 Matter Bins, 2 Micro Manipulators, and 2 Beakers."
	req_components = list(
							"/obj/item/stock_parts/matter_bin" = 2,
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/reagent_container/glass/beaker" = 2)


/obj/item/circuitboard/machine/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	build_path = "/obj/machinery/r_n_d/circuit_imprinter"
	origin_tech = "engineering=2;programming=2"
	frame_desc = "Requires 1 Matter Bin, 1 Micro Manipulator, and 2 Beakers."
	req_components = list(
							"/obj/item/stock_parts/matter_bin" = 1,
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/reagent_container/glass/beaker" = 2)

/obj/item/circuitboard/machine/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman"
	origin_tech = "programming=3;powerstorage=3;phorontech=3;engineering=3"
	frame_desc = "Requires 1 Matter Bin, 1 Micro-Laser, 2 Pieces of Cable, and 1 Capacitor."
	req_components = list(
							"/obj/item/stock_parts/matter_bin" = 1,
							"/obj/item/stock_parts/micro_laser" = 1,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/capacitor" = 1)

/obj/item/circuitboard/machine/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/super"
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/circuitboard/machine/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=5;engineering=5"

obj/item/circuitboard/machine/rdserver
	name = "Circuit Board (R&D Server)"
	build_path = "/obj/machinery/r_n_d/server"
	origin_tech = "programming=3"
	frame_desc = "Requires 2 pieces of cable, and 1 Scanning Module."
	req_components = list(
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/scanning_module" = 1)

/obj/item/circuitboard/machine/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	build_path = "/obj/machinery/mecha_part_fabricator"
	origin_tech = "programming=3;engineering=3"
	frame_desc = "Requires 2 Matter Bins, 1 Micro Manipulator, 1 Micro-Laser and 1 Console Screen."
	req_components = list(
							"/obj/item/stock_parts/matter_bin" = 2,
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/stock_parts/micro_laser" = 1,
							"/obj/item/stock_parts/console_screen" = 1)

/obj/item/circuitboard/machine/clonepod
	name = "Circuit board (Clone Pod)"
	build_path = "/obj/machinery/clonepod"
	origin_tech = "programming=3;biotech=3"
	frame_desc = "Requires 2 Manipulator, 2 Scanning Module, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/scanning_module" = 2,
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stock_parts/console_screen" = 1)

/obj/item/circuitboard/machine/clonescanner
	name = "Circuit board (Cloning Scanner)"
	build_path = "/obj/machinery/dna_scannernew"
	origin_tech = "programming=2;biotech=2"
	frame_desc = "Requires 1 Scanning module, 1 Micro Manipulator, 1 Micro-Laser, 2 pieces of cable and 1 Console Screen."
	req_components = list(
							"/obj/item/stock_parts/scanning_module" = 1,
							"/obj/item/stock_parts/manipulator" = 1,
							"/obj/item/stock_parts/micro_laser" = 1,
							"/obj/item/stock_parts/console_screen" = 1,
							"/obj/item/stack/cable_coil" = 2,)

/obj/item/circuitboard/machine/unary_atmos

	var/machine_dir = SOUTH
	var/init_dirs = SOUTH

/obj/item/circuitboard/machine/unary_atmos/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/tool/screwdriver))
		machine_dir = turn(machine_dir, 90)
		init_dirs = machine_dir
		user.visible_message("\blue \The [user] adjusts the jumper on the [src]'s port configuration pins.", "\blue You adjust the jumper on the port configuration pins. Now set to [dir2text(machine_dir)].")
	return

/obj/item/circuitboard/machine/unary_atmos/examine(mob/user)
	..()
	user << "The jumper is connecting the [dir2text(machine_dir)] pins."

/obj/item/circuitboard/machine/unary_atmos/construct(var/obj/machinery/atmospherics/unary/U)
	//TODO: Move this stuff into the relevant constructor when pipe/construction.dm is cleaned up.
	U.dir = src.machine_dir
	U.initialize_directions = src.init_dirs
	U.initialize()
	U.build_network()
	if (U.node)
		U.node.initialize()
		U.node.build_network()

/obj/item/circuitboard/machine/unary_atmos/heater
	name = "Circuit Board (Gas Heating System)"
	build_path = "/obj/machinery/atmospherics/unary/heater"
	origin_tech = "powerstorage=2;engineering=1"
	frame_desc = "Requires 5 Pieces of Cable, 1 Matter Bin, and 2 Capacitors."
	req_components = list(
							"/obj/item/stack/cable_coil" = 5,
							"/obj/item/stock_parts/matter_bin" = 1,
							"/obj/item/stock_parts/capacitor" = 2)

/obj/item/circuitboard/machine/unary_atmos/cooler
	name = "Circuit Board (Gas Cooling System)"
	build_path = "/obj/machinery/atmospherics/unary/freezer"
	origin_tech = "magnets=2;engineering=2"
	frame_desc = "Requires 2 Pieces of Cable, 1 Matter Bin, 1 Micro Manipulator, and 2 Capacitors."
	req_components = list(
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/matter_bin" = 1,
							"/obj/item/stock_parts/capacitor" = 2,
							"/obj/item/stock_parts/manipulator" = 1)

// Telecomms circuit boards:

/obj/item/circuitboard/machine/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	build_path = "/obj/machinery/telecomms/receiver"
	origin_tech = "programming=4;engineering=3;bluespace=2"
	frame_desc = "Requires 1 Subspace Ansible, 1 Hyperwave Filter, 2 Micro Manipulators, and 1 Micro-Laser."
	req_components = list(
							"/obj/item/stock_parts/subspace/ansible" = 1,
							"/obj/item/stock_parts/subspace/filter" = 1,
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stock_parts/micro_laser" = 1)

/obj/item/circuitboard/machine/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	build_path = "/obj/machinery/telecomms/hub"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 2 Micro Manipulators, 2 Cable Coil and 2 Hyperwave Filter."
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/subspace/filter" = 2)

/obj/item/circuitboard/machine/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	build_path = "/obj/machinery/telecomms/relay"
	origin_tech = "programming=3;engineering=4;bluespace=3"
	frame_desc = "Requires 2 Micro Manipulators, 2 Cable Coil and 2 Hyperwave Filters."
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/subspace/filter" = 2)

/obj/item/circuitboard/machine/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	build_path = "/obj/machinery/telecomms/bus"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 2 Micro Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/stock_parts/subspace/filter" = 1)

/obj/item/circuitboard/machine/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	build_path = "/obj/machinery/telecomms/processor"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 3 Micro Manipulators, 1 Hyperwave Filter, 2 Treatment Disks, 1 Wavelength Analyzer, 2 Cable Coils and 1 Subspace Amplifier."
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 3,
							"/obj/item/stock_parts/subspace/filter" = 1,
							"/obj/item/stock_parts/subspace/treatment" = 2,
							"/obj/item/stock_parts/subspace/analyzer" = 1,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/stock_parts/subspace/amplifier" = 1)

/obj/item/circuitboard/machine/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	build_path = "/obj/machinery/telecomms/server"
	origin_tech = "programming=4;engineering=4"
	frame_desc = "Requires 2 Micro Manipulators, 1 Cable Coil and 1 Hyperwave Filter."
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/stock_parts/subspace/filter" = 1)

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	build_path = "/obj/machinery/telecomms/broadcaster"
	origin_tech = "programming=4;engineering=4;bluespace=2"
	frame_desc = "Requires 2 Micro Manipulators, 1 Cable Coil, 1 Hyperwave Filter, 1 Ansible Crystal and 2 High-Powered Micro-Lasers. "
	req_components = list(
							"/obj/item/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/stock_parts/subspace/filter" = 1,
							"/obj/item/stock_parts/subspace/crystal" = 1,
							"/obj/item/stock_parts/micro_laser/high" = 2)




/obj/item/circuitboard/machine/batteryrack
	name = "Circuit board (Battery rack PSU)"
	build_path = "/obj/machinery/power/smes/batteryrack"
	origin_tech = "powerstorage=3;engineering=2"
	frame_desc = "Requires 3 power cells."
	req_components = list("/obj/item/cell" = 3)


/obj/item/circuitboard/machine/ghettosmes
	name = "Circuit board (makeshift PSU)"
	desc = "An APC circuit repurposed into some power storage device controller"
	build_path = "/obj/machinery/power/smes/batteryrack/makeshift"
	frame_desc = "Requires 3 power cells."
	req_components = list("/obj/item/cell" = 3)



	//Board
/obj/item/circuitboard/machine/smes
	name = "Circuit board (SMES Cell)"
	build_path = "/obj/machinery/power/smes/buildable"
	origin_tech = "powerstorage=6;engineering=4" // Board itself is high tech. Coils have to be ordered from cargo or salvaged from existing SMESs.
	frame_desc = "Requires 1 superconducting magnetic coil and 30 wires."
	req_components = list("/obj/item/stock_parts/smes_coil" = 1, "/obj/item/stack/cable_coil" = 30)


