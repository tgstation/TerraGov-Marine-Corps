/datum/authority
	var/name = "Authority" //Pretty obvious.
	var/authority_level = 1 //How important is this authority?

//My TO DO implementation of the master controller.
//This is the highest level of authority. It controls the other authorities.
/datum/authority/governing/GoverningAuthority
/datum/authority/governing
	name = "Governer"