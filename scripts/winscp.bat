winscp.com /command ^
    "option batch abort" ^
    "open sftp://colonialmarines:n23b6oAqL8@hosted2.nfoservers.com/" ^
    "synchronize remote C:\Users\Administrator\Desktop\ColonialMarinesALPHA\data\logs /usr/www/colonialmarines/public/logs/ -filemask="*.log"" ^
	"close" ^
    "exit"