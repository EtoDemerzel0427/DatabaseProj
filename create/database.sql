/* 创建数据库，指定文件组在不同盘符 */
CREATE DATABASE TD_LTE
ON PRIMARY
  (NAME='TD-LTE_Primary',
    FILENAME=
       'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\data\TD-LTE_Prm.mdf',
    SIZE=50MB,
    MAXSIZE=100MB,
    FILEGROWTH=1MB),
FILEGROUP TD_LTE_FG1
  (NAME = 'TD-LTE_FG1_Dat1',
    FILENAME =
       'D:\data_script\TD-LTE_FG1_1.ndf ',
    SIZE = 30MB,
    MAXSIZE=50MB,
    FILEGROWTH=1MB),
  ( NAME = 'TD-LTE_FG1_Dat2',
    FILENAME =
	   'D:\data_script\TD-LTE_FG1_2.ndf ',
    SIZE = 30MB,
    MAXSIZE=50MB,
    FILEGROWTH=1MB)
LOG ON
  ( NAME='TD-LTE_log',
    FILENAME =
		'E:\sql_log\TD-LTE.ldf',
    SIZE=10MB,
    MAXSIZE=50MB,
    FILEGROWTH=1MB);
GO

