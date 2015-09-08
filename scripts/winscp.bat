winscp.com /command ^
    "option batch abort" ^
    "open sftp://colonialmarines:n23b6oAqL8@hosted2.nfoservers.com/" ^
    "synchronize remote C:\Users\Administrator\Desktop\ColonialMarinesALPHA\data\logs /usr/www/colonialmarines/public/logs/ -filemask="*.log"" ^
	"put C:\Users\Administrator\Desktop\alpha_log.txt /usr/www/colonialmarines/public/logs/2015/" ^
	"close" ^
    "exit"