#define TGS_EXTERNAL_CONFIGURATION
#define TGS_V3_API
#define TGS_DEFINE_AND_SET_GLOBAL(Name, Value) var/##Name = ##Value
#define TGS_READ_GLOBAL(Name) global.##Name
#define TGS_WRITE_GLOBAL(Name, Value) global.##Name = ##Value
#define TGS_PROTECT_DATUM(Path)	//TODO
#define TGS_WORLD_ANNOUNCE(message) to_chat(world, "<span class='danger'>[##message]</span>")
#define TGS_NOTIFY_ADMINS(event) message_admins("TGS: [##event]")
#define TGS_INFO_LOG(message) to_chat(world.log, "TGS Info: [##message]")
#define TGS_ERROR_LOG(message) to_chat(world.log, "TGS Error: [##message]")
#define TGS_CLIENT_COUNT global.clients.len
