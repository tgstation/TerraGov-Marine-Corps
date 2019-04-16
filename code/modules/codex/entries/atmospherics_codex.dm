/datum/codex_entry/atmos_pipe
	associated_paths = list(/obj/machinery/atmospherics/pipe)
	mechanics_text = "This pipe, and all other pipes, can be connected or disconnected by a wrench.  The internal pressure of the pipe must \
	be below 300 kPa to do this.  More pipes can be obtained from the pipe dispenser."

//HE pipes
/datum/codex_entry/atmos_he
	associated_paths = list(/obj/machinery/atmospherics/components/unary/heat_exchanger)
	mechanics_text = "This radiates heat from the pipe's gas to space, cooling it down."

//Supply/Scrubber pipes
/datum/codex_entry/atmos_visible_scrub
	associated_paths = list(/obj/machinery/atmospherics/pipe/simple/scrubbers/visible)
	mechanics_text = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_visible_supply
	associated_paths = list(/obj/machinery/atmospherics/pipe/simple/supply/visible)
	mechanics_text = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_hidden_supply
	associated_paths = list(/obj/machinery/atmospherics/pipe/simple/supply/hidden)
	mechanics_text = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_hidden_scrub
	associated_paths = list(/obj/machinery/atmospherics/pipe/simple/scrubbers/hidden)
	mechanics_text = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

//Three way manifolds
/datum/codex_entry/atmos_manifold
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold)
	mechanics_text = "A normal pipe with three ends to connect to."

/datum/codex_entry/atmos_manifold_visible_scrub
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold/scrubbers/visible)
	mechanics_text = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_manifold_visible_supply
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold/supply/visible)
	mechanics_text = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_manifold_hidden_scrub
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold/scrubbers/hidden)
	mechanics_text = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_manifold_hidden_supply
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold/supply/hidden)
	mechanics_text = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

//Four way manifolds
/datum/codex_entry/atmos_manifold_manifold_four
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold4w)
	mechanics_text = "This is a four-way pipe."

/datum/codex_entry/atmos_manifold_manifold_four_visible_scrub
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/visible)
	mechanics_text = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_manifold_manifold_four_visible_supply
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold4w/supply/hidden)
	mechanics_text = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/datum/codex_entry/atmos_manifold_manifold_four_hidden_scrub
	associated_paths = list(/obj/machinery/atmospherics/pipe/manifold4w/scrubbers/hidden)
	mechanics_text = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

//Normal valves
/datum/codex_entry/atmos_valve
	associated_paths = list(/obj/machinery/atmospherics/components/binary/valve)
	mechanics_text = "Click this to turn the valve.  If red, the pipes on each end are seperated.  Otherwise, they are connected."

//TEG ports
/datum/codex_entry/atmos_circulator
	associated_paths = list(/obj/machinery/atmospherics/components/binary/circulator)
	mechanics_text = "This generates electricity, depending on the difference in temperature between each side of the machine.  The meter in \
	the center of the machine gives an indicator of how much elecrtricity is being generated."

//Passive gates
/datum/codex_entry/atmos_gate
	associated_paths = list(/obj/machinery/atmospherics/components/binary/passive_gate)
	mechanics_text = "This is a one-way regulator, allowing gas to flow only at a specific pressure and flow rate.  If the light is green, it is flowing."

//Normal pumps (high power one inherits from this)
/datum/codex_entry/atmos_pump
	associated_paths = list(/obj/machinery/atmospherics/components/binary/pump)
	mechanics_text = "This moves gas from one pipe to another.  A higher target pressure demands more energy.  The side with the red end is the output."

//Vents
/datum/codex_entry/atmos_vent_pump
	associated_paths = list(/obj/machinery/atmospherics/components/unary/vent_pump)
	mechanics_text = "This pumps the contents of the attached pipe out into the atmosphere, if needed.  It can be controlled from an Air Alarm."

//Freezers
/datum/codex_entry/atmos_freezer
	associated_paths = list(/obj/machinery/atmospherics/components/unary/thermomachine/freezer)
	mechanics_text = "Cools down the gas of the pipe it is connected to.  It uses massive amounts of electricity while on. \
	It can be upgraded by replacing the capacitors, manipulators, and matter bins.  It can be deconstructed by screwing the maintenance panel open with a \
	screwdriver, and then using a crowbar."

//Heaters
/datum/codex_entry/atmos_heater
	associated_paths = list(/obj/machinery/atmospherics/components/unary/thermomachine/heater)
	mechanics_text = "Heats up the gas of the pipe it is connected to.  It uses massive amounts of electricity while on. \
	It can be upgraded by replacing the capacitors, manipulators, and matter bins.  It can be deconstructed by screwing the maintenance panel open with a \
	screwdriver, and then using a crowbar."

//Gas injectors
/datum/codex_entry/atmos_injector
	associated_paths = list(/obj/machinery/atmospherics/components/unary/outlet_injector)
	mechanics_text = "Outputs the pipe's gas into the atmosphere, similar to an airvent.  It can be controlled by a nearby atmospherics computer. \
	A green light on it means it is on."

//Scrubbers
/datum/codex_entry/atmos_vent_scrubber
	associated_paths = list(/obj/machinery/atmospherics/components/unary/vent_scrubber)
	mechanics_text = "This filters the atmosphere of harmful gas.  Filtered gas goes to the pipes connected to it, typically a scrubber pipe. \
	It can be controlled from an Air Alarm.  It can be configured to drain all air rapidly with a 'panic syphon' from an air alarm."

//Canisters
/datum/codex_entry/atmos_canister
	display_name = "gas canister" // because otherwise it shows up as 'canister: [caution]'
	associated_paths = list(/obj/machinery/portable_atmospherics/canister)
	mechanics_text = "The canister can be connected to a connector port with a wrench.  Tanks of gas (the kind you can hold in your hand) \
	can be filled by the canister, by using the tank on the canister, increasing the release pressure, then opening the valve until it is full, and then close it.  \
	*DO NOT* remove the tank until the valve is closed.  A gas analyzer can be used to check the contents of the canister."
	antag_text = "Canisters can be damaged, spilling their contents into the air, or you can just leave the release valve open."

//Portable pumps
/datum/codex_entry/atmos_power_pump
	associated_paths = list(/obj/machinery/portable_atmospherics/pump)
	mechanics_text = "Invaluable for filling air in a room rapidly after a breach repair.  The internal gas container can be filled by \
	connecting it to a connector port.  The pump can pump the air in (sucking) or out (blowing), at a specific target pressure.  The powercell inside can be \
	replaced by using a screwdriver, and then adding a new cell.  A tank of gas can also be attached to the air pump."

//Portable scrubbers
/datum/codex_entry/atmos_power_scrubber
	associated_paths = list(/obj/machinery/portable_atmospherics/scrubber)
	mechanics_text = "Filters the air, placing harmful gases into the internal gas container.  The container can be emptied by \
	connecting it to a connector port.  The pump can pump the air in (sucking) or out (blowing), at a specific target pressure.  The powercell inside can be \
	replaced by using a screwdriver, and then adding a new cell.  A tank of gas can also be attached to the scrubber. "

//Meters
/datum/codex_entry/atmos_meter
	associated_paths = list(/obj/machinery/meter)
	mechanics_text = "Measures the volume and temperature of the pipe under the meter."

//Pipe dispensers
/datum/codex_entry/atmos_pipe_dispenser
	associated_paths = list(/obj/machinery/pipedispenser)
	mechanics_text = "This can be moved by using a wrench.  You will need to wrench it again when you want to use it.  You can put \
	excess (atmospheric) pipes into the dispenser, as well.  The dispenser requires electricity to function."

/datum/codex_entry/transfer_valve
	associated_paths = list(/obj/item/transfer_valve)
	mechanics_text = "This machine is used to merge the contents of two different gas tanks. Plug the tanks into the transfer, then open the valve to mix them together. You can also attach various assembly devices to trigger this process."
	antag_text = "With a tank of hot phoron and cold oxygen, this benign little atmospheric device becomes an incredibly deadly bomb. You don't want to be anywhere near it when it goes off."

/datum/codex_entry/gas_tank
	associated_paths = list(/obj/item/tank)
	mechanics_text = "These tanks are utilised to store any of the various types of gaseous substances. \
	They can be attached to various portable atmospheric devices to be filled or emptied. <br>\
	<br>\
	Each tank is fitted with an emergency relief valve. This relief valve will open if the tank is pressurised to over ~3000kPa or heated to over 173?C. \
	The valve itself will close after expending most or all of the contents into the air.<br>\
	<br>\
	Filling a tank such that experiences ~4000kPa of pressure will cause the tank to rupture, spilling out its contents and destroying the tank. \
	Tanks filled over ~5000kPa will rupture rather violently, exploding with significant force."
	antag_text = "Each tank may be incited to burn by attaching wires and an igniter assembly, though the igniter can only be used once and the mixture only burn if the igniter pushes a flammable gas mixture above the minimum burn temperature (126?C). \
	Wired and assembled tanks may be disarmed with a set of wirecutters. Any exploding or rupturing tank will generate shrapnel, assuming their relief valves have been welded beforehand. Even if not, they can be incited to expel hot gas on ignition if pushed above 173?C. \
	Relatively easy to make, the single tank bomb requries no tank transfer valve, and is still a fairly formidable weapon that can be manufactured from any tank."
