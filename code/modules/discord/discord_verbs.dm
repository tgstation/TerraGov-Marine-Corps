/client/verb/connect_discord()
	set name = "Привязать Discord"
	set category = "Special verbs"

	if(IsGuestKey(key))
		to_chat(usr, "Гостевой аккаунт не может быть привязан.")
		return

	if (!CONFIG_GET(string/tlb_api_url) || !CONFIG_GET(string/tlb_api_key))
		to_chat(usr, "TheLostBay API не сконфигурирован.")
		return

	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_POST, "[CONFIG_GET(string/tlb_api_url)]/discord/CreateSS13State?ckey=[ckey]&access_key=[CONFIG_GET(string/tlb_api_key)]", "", "")
	request.begin_async()
	UNTIL(request.is_complete() || !usr)

	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		to_chat(usr, "Ошибка обращения к TheLostBay API.")
		return

	if (response.body == "Already connected.")
		to_chat(usr, "Аккаунт уже привязан.")
		return

	to_chat(usr, span_boldnotice("Для привязки аккаунта - перейдите в Discord проекта") + span_bold(" The Lost Bay ") + span_boldnotice("и отправьте следующую команду в любой доступный канал:\n") + span_bold("/привязать [response.body]"))
