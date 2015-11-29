winscp.com /command ^
    "option batch abort" ^
    "open sftp://colonialmarines:n23b6oAqL8@hosted2.nfoservers.com/" ^
    "synchronize remote C:\Users\Administrator\Desktop\ColonialMarinesALPHA\data\logs /usr/www/colonialmarines/public/logs/ -filemask="*.log"" ^
	"put ""C:\Users\Administrator\Desktop\ColonialMarinesALPHA\tools\Runtime Condenser\Input.txt"" /usr/www/colonialmarines/public/logs/2015/alpha_log.txt" ^
	"put ""C:\Users\Administrator\Desktop\ColonialMarinesALPHA\tools\Runtime Condenser\Output.txt"" /usr/www/colonialmarines/public/logs/2015/alpha_log_condensed.txt" ^
	"close" ^
    "exit"