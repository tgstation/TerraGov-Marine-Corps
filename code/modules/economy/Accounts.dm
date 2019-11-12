
/datum/money_account
	var/owner_name = ""
	var/account_number = 0
	var/remote_access_pin = 0
	var/money = 0
	var/list/transaction_log = list()
	var/suspended = 0
	var/security_level = 0	//0 - auto-identify from worn ID, require only account number
							//1 - require manual login / account number and pin
							//2 - require card and manual login

/datum/transaction
	var/target_name = ""
	var/purpose = ""
	var/amount = 0
	var/date = ""
	var/time = ""
	var/source_terminal = ""

/proc/create_account(new_owner_name = "Default user", starting_funds = 0)

	//create a new account
	var/datum/money_account/M = new()
	M.owner_name = new_owner_name
	M.remote_access_pin = rand(1111, 111111)
	M.money = starting_funds

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = new_owner_name
	T.purpose = "Account creation"
	T.amount = starting_funds

	//set a random date, time and location some time over the past few decades
	T.date = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [GAME_YEAR - rand(1,20)]"
	T.time = "[rand(0,24)]:[rand(11,59)]"
	T.source_terminal = "NTGalaxyNet Terminal #[rand(111,1111)]"

	M.account_number = rand(111111, 999999)

	//add the account
	M.transaction_log.Add(T)
	GLOB.all_money_accounts.Add(M)

	return M

/proc/charge_to_account(attempt_account_number, source_name, purpose, terminal_id, amount)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number && !D.suspended)
			D.money += amount

			//create a transaction log entry
			var/datum/transaction/T = new()
			T.target_name = source_name
			T.purpose = purpose
			if(amount < 0)
				T.amount = "([amount])"
			else
				T.amount = "[amount]"
			T.date = GLOB.current_date_string
			T.time = worldtime2text()
			T.source_terminal = terminal_id
			D.transaction_log.Add(T)

			return 1
		break

	return 0

//this returns the first account datum that matches the supplied accnum/pin combination, it returns null if the combination did not match any account
/proc/attempt_account_access(attempt_account_number, attempt_pin_number, security_level_passed = 0)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == attempt_account_number)
			if( D.security_level <= security_level_passed && (!D.security_level || D.remote_access_pin == attempt_pin_number) )
				return D
			break

/proc/get_account(account_number)
	for(var/datum/money_account/D in GLOB.all_money_accounts)
		if(D.account_number == account_number)
			return D
