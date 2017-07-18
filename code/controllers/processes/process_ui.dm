var/global/datum/process_ui/proc_scheduler = new()

/datum/process_ui

/datum/process_ui/Topic(href, href_list)
	if (!href_list["action"])
		return

	switch (href_list["action"])
		if ("kill")
			var/kill = href_list["target"]
			processScheduler.killProcess(kill)
			display_ui()
		if ("enable")
			var/enable = href_list["target"]
			processScheduler.enableProcess(enable)
			display_ui()
		if ("disable")
			var/disable = href_list["target"]
			processScheduler.disableProcess(disable)
			display_ui()
		if ("refresh")
			display_ui()

/datum/process_ui/proc/process_table()
	var/dat = "<table class=\"table table-striped\"><thead><tr><td>Name</td><td>Avg(s)</td><td>Last(s)</td><td>Highest(s)</td><td>Tickcount</td><td>Tickrate</td><td>State</td><td>Action</td></tr></thead><tbody>"
	// and the context of each
	for (var/list/data in processScheduler.getStatusData())
		dat += "<tr>"
		dat += "<td>[data["name"]]</td>"
		dat += "<td>[num2text(data["averageRunTime"]/10,3)]</td>"
		dat += "<td>[num2text(data["lastRunTime"]/10,3)]</td>"
		dat += "<td>[num2text(data["highestRunTime"]/10,3)]</td>"
		dat += "<td>[num2text(data["ticks"],4)]</td>"
		dat += "<td>[data["schedule"]]</td>"
		dat += "<td>[data["status"]]</td>"
		dat += "<td><a href='?src=\ref[src];action=kill;target=[data["name"]]'>\[Kill]</a>"
		if (data["disabled"])
			dat += "<a href='?src=\ref[src];action=enable;target=[data["name"]]'>\[Enable]</a>"
		else
			dat += "<a href='?src=\ref[src];action=disable;target=[data["name"]]'>\[Disable]</a>"
		dat += "</td>"
		dat += "</tr>"

	dat += "<th>world.cpu</th><td>[world.cpu]</td>"
	dat += "</tbody></table>"
	return dat

/datum/process_ui/proc/display_ui()

	var/text = {"<html><head>
	<title>Process Scheduler UI</title>
	</head>
	<body>
	<h2>Process Scheduler</h2>
	<a href='?src=\ref[src];action=refresh'>\[Refresh]</a>"}

	text += "<div id=\"processTable\">"
	text += process_table()
	text += "</div></body></html>"

	usr << browse(text, "window=processSchedulerContext;size=800x600")

/client/proc/scheduler()
	set category = "Debug"
	set name = "Process Scheduler"

	proc_scheduler.display_ui()