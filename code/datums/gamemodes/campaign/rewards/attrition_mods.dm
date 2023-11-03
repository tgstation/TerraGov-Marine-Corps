//Parent for all passive attrition modifiers
/datum/campaign_asset/attrition_modifier
	asset_flags = ASSET_PASSIVE_EFFECT|ASSET_ACTIVE
	///Modifier to faction passive attrition gain
	var/attrition_mod = 0

/datum/campaign_asset/attrition_modifier/passive_effect()
	. = ..()
	faction.attrition_gain_multiplier += attrition_mod

/datum/campaign_asset/attrition_modifier/remove_passive_effect()
	faction.attrition_gain_multiplier -= attrition_mod
	asset_flags |= ASSET_CONSUMED

/datum/campaign_asset/attrition_modifier/Destroy(force, ...)
	if(!(asset_flags & ASSET_CONSUMED))
		remove_passive_effect()
	return ..()

/datum/campaign_asset/attrition_modifier/bonus_standard
	name = "Improved supply lines"
	desc = "+20% passive Attrition Point gain"
	detailed_desc = "Improved supply lines allow for the smooth transfer of men and materiel, allowing for the deployment of more combat forces."
	attrition_mod = 0.2
	ui_icon = "logistics_buff"

//corpo support
/datum/campaign_asset/attrition_modifier/corporate_approval
	name = "Corporate approval"
	desc = "+10% passive Attrition Point gain"
	detailed_desc = "The favorable attitude of several Megacorporations to our mission has resulted in easier and cheaper logistics throughout the system."
	attrition_mod = 0.1
	ui_icon = "support_1"

/datum/campaign_asset/attrition_modifier/corporate_approval/reapply()
	faction.add_asset(/datum/campaign_asset/attrition_modifier/corporate_backing) //we upgrade to the next level
	remove_passive_effect()

/datum/campaign_asset/attrition_modifier/corporate_backing
	name = "Corporate backing"
	desc = "+20% passive Attrition Point gain"
	detailed_desc = "Our mission is directly aligned with the goals of several megacorporations, who are now actively supporting our efforts."
	attrition_mod = 0.2
	ui_icon = "support_2"

/datum/campaign_asset/attrition_modifier/corporate_backing/reapply()
	faction.add_asset(/datum/campaign_asset/attrition_modifier/corporate_directive)
	remove_passive_effect()

/datum/campaign_asset/attrition_modifier/corporate_directive
	name = "Corporate directive"
	desc = "+30% passive Attrition Point gain"
	detailed_desc = "Our mission goals have been realigned with ensuring that lawful megacorporate economic uplift programs can be reestablished. The corporations are now heavily support our efforts."
	attrition_mod = 0.3
	ui_icon = "support_3"

//native support
/datum/campaign_asset/attrition_modifier/local_approval
	name = "Indigenous approval"
	desc = "+10% passive Attrition Point gain"
	detailed_desc = "Large portions of the local population is now sympathetic towards our mission, providing us a level of assistance and support."
	attrition_mod = 0.1
	ui_icon = "support_1"

/datum/campaign_asset/attrition_modifier/local_approval/reapply()
	faction.add_asset(/datum/campaign_asset/attrition_modifier/local_backing) //we upgrade to the next level
	remove_passive_effect()

/datum/campaign_asset/attrition_modifier/local_backing
	name = "Indigenous backing"
	desc = "+20% passive Attrition Point gain"
	detailed_desc = "Signficiant portions of the local population now directly support our mission, actively assisting us and hampering the efforts of the enemy."
	attrition_mod = 0.2
	ui_icon = "support_2"

/datum/campaign_asset/attrition_modifier/local_backing/reapply()
	faction.add_asset(/datum/campaign_asset/attrition_modifier/local_uprising)
	remove_passive_effect()

/datum/campaign_asset/attrition_modifier/local_uprising
	name = "Indigenous uprising"
	desc = "+30% passive Attrition Point gain"
	detailed_desc = "Signficiant portions of the local population now actively oppose our enemy as well as supporting our forces. Large swathes of the planet can be considered friendly territory."
	attrition_mod = 0.3
	ui_icon = "support_3"

/datum/campaign_asset/attrition_modifier/malus_standard
	name = "Degraded supply lines"
	desc = "-20% passive Attrition Point gain"
	detailed_desc = "Damage to our supply lines have increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.2
	ui_icon = "logistics_malus"
	asset_flags = ASSET_PASSIVE_EFFECT|ASSET_DEBUFF

/datum/campaign_asset/attrition_modifier/malus_strong
	name = "Severely degraded supply lines"
	desc = "-25% passive Attrition Point gain"
	detailed_desc = "Serious damage to our supply lines have increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.25

/datum/campaign_asset/attrition_modifier/malus_teleporter
	name = "Bluespace logistics disabled"
	desc = "-20% passive Attrition Point gain"
	detailed_desc = "The loss of our teleporter arrays has increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.2
	ui_icon = "bluespace_logistics_malus"
	asset_flags = ASSET_PASSIVE_EFFECT|ASSET_DEBUFF
