/datum/autowiki/weapons
	page = "Template:Autowiki/Content/Guns"

/datum/autowiki/weapons/generate()
	var/output = ""

	for(var/gun_type in subtypesof(/obj/item/weapon/gun))
		var/obj/item/weapon/gun/gun_object = gun_type
		var/list/entry_contents = list()

		entry_contents["name"] = gun_object.name
		entry_contents["desc"] = gun_object.desc
		//entry_contents[""] = gun_object.icon
		//entry_contents[""] = gun_object.icon_state

		//entry_contents[""]
		//entry_contents[""]
		//entry_contents[""]
		//entry_contents[""]
		//entry_contents[""]

		output += include_template("Autowiki/Guns", entry_contents)

	return output
