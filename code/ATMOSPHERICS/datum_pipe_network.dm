var/global/list/datum/pipe_network/pipe_networks = list()

/datum/pipe_network
	var/volume = 0	//caches the total volume for atmos machines to use in gas calculations

	var/list/obj/machinery/atmospherics/normal_members = list()
	var/list/datum/pipeline/line_members = list()
		//membership roster to go through for updates and what not


/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	//Purpose: Generate membership roster
	//Notes: Assuming that members will add themselves to appropriate roster in network_expand()

	if(!start_normal)
		cdel(src)

	start_normal.network_expand(src, reference)

	update_network_gases()

	if((normal_members.len>0)||(line_members.len>0))
		pipe_networks += src
	else
		cdel(src)

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver==src) return 0

	normal_members |= giver.normal_members

	line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member in giver.line_members)
		line_member.network = src

	update_network_gases()
	return 1

/datum/pipe_network/proc/update_network_gases()
