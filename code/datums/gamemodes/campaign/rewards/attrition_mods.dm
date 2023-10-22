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

/datum/campaign_asset/attrition_modifier/malus_standard
	name = "Degraded supply lines"
	desc = "-20% passive Attrition Point gain"
	detailed_desc = "Damage to our supply lines have increased the difficulty and time required to move men and materiel, resulting in a lower deployment of combat forces."
	attrition_mod = -0.2
	ui_icon = "logistics_malus"
	asset_flags = ASSET_PASSIVE_EFFECT|ASSET_DEBUFF

/datum/campaign_asset/attrition_modifier/malus_standard/higher
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
