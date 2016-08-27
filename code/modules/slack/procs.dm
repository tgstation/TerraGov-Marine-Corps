proc/slackMessage(type as text, message as text)
	var/username = "server"
	if(type=="adminhelp")
		username = "ahelp-bot"
	var/json = "{\"username\": \"[username]\", \"icon_emoji\": \":exclamation:\", \"text\": \"[message]\"}"
	shell("scripts/curl -k -X POST -H \"Content-type: application/x-www-form-urlencoded\\r\\n\" -d \"payload=[url_encode(json)]\" [config.slack_token]")