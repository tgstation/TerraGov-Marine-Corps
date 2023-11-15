//Parent for all bonus role assets
/datum/campaign_asset/bonus_job
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_DISABLE_ON_MISSION_END
	///list of bonus jobs to grant for this asset
	var/list/datum/job/bonus_job_list = list()

/datum/campaign_asset/bonus_job/activated_effect()
	for(var/job_type in bonus_job_list)
		var/datum/job/bonus_job = SSjob.type_occupations[job_type]
		bonus_job.add_job_positions(bonus_job_list[job_type])

//Removes the job slots once the mission is over
/datum/campaign_asset/bonus_job/deactivate()
	. = ..()
	for(var/job_type in bonus_job_list)
		var/datum/job/bonus_job = SSjob.type_occupations[job_type]
		bonus_job.set_job_positions(0)
		bonus_job.free_job_positions(bonus_job_list[job_type])

/datum/campaign_asset/bonus_job/colonial_militia
	name = "Colonial militia support"
	desc = "A colonial militia squad to augment our forces"
	detailed_desc = "A large number of militia job slots are opened at no attrition cost. \
	A local colonial militia sympathetic to our cause has offered a squad to support our troops. Equipped with lesser arms and armor than our own troops, but fairly numerous."
	ui_icon = "militia"
	bonus_job_list = list(
		/datum/job/som/mercenary/militia/leader = 1,
		/datum/job/som/mercenary/militia/medic = 2,
		/datum/job/som/mercenary/militia/standard = 9,
	)

/datum/campaign_asset/bonus_job/freelancer
	name = "Freelancer team"
	desc = "A squad of freelance guns for hire to support our forces"
	detailed_desc = "A moderate number of freelancer job slots are opened at no attrition cost. \
	A contract has been bought for a squad of freelancers to augment our forces. With comparable equipment and training, they can help turn the tables when our forces are stretched thin."
	ui_icon = "freelancers"
	bonus_job_list = list(
		/datum/job/freelancer/leader/campaign_bonus = 1,
		/datum/job/freelancer/grenadier/campaign_bonus = 2,
		/datum/job/freelancer/medic/campaign_bonus = 1,
		/datum/job/freelancer/standard/campaign_bonus = 5,
	)

/datum/campaign_asset/bonus_job/icc
	name = "ICC strike team"
	desc = "A squad of ICC soldiers to support our forces"
	detailed_desc = "A moderate number of ICC job slots are opened at no attrition cost. \
	The ICC have authorised a small, local detachment of their troops to aid us in our conflict. They are well armed and armored, and could prove a valuable advantage in a fight."
	ui_icon = "icc"
	bonus_job_list = list(
		/datum/job/icc/leader/campaign_bonus = 1,
		/datum/job/icc/guard/campaign_bonus = 2,
		/datum/job/icc/medic/campaign_bonus = 1,
		/datum/job/icc/standard/campaign_bonus = 6,
	)

/datum/campaign_asset/bonus_job/pmc
	name = "PMC security detail"
	desc = "An elite PMC team to assist in a joint operation"
	detailed_desc = "A small number of PMC job slots are opened at no attrition cost. \
	NanoTrasen have authorised a small team of their PMC contractors to assist us in combat. With superior arms and armor, they a powerful tactical asset."
	ui_icon = "pmc"
	bonus_job_list = list(
		/datum/job/pmc/leader/campaign_bonus = 1,
		/datum/job/pmc/gunner/campaign_bonus = 2,
		/datum/job/pmc/standard/campaign_bonus = 4,
	)

/datum/campaign_asset/bonus_job/combat_robots
	name = "Combat robots"
	desc = "A shipment of combat robots to bolster your forces"
	detailed_desc = "A four combat robot job slots are opened at no attrition cost. \
	Combat robots are tough to kill, being immune to pain and chemicals, and resist both fire and radiation. They suffer from low mobility however."
	ui_icon = "combat_robots"
	cost = 6
	bonus_job_list = list(
		/datum/job/terragov/squad/standard/campaign_robot = 4,
	)
