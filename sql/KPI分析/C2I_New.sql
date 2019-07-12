USE [TD_LTE]
GO
/****** Object:  StoredProcedure [dbo].[create_C2INew]    Script Date: 2019/7/9 11:00:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[create_C2INew]
@n int
AS

BEGIN
IF EXISTS(SELECT * FROM sys.Tables WHERE name='tbC2INew')
	DROP TABLE tbC2INew;

with temp as(
select count(TimeStamp) as t,ServingSector as s,InterferingSector as i 
from tbMROData 
group by ServingSector,InterferingSector 
having count(TimeStamp)>@n),

TEMP1 AS(select TOP(9000) ServingSector,InterferingSector, avg(LteScRSRP-LteNcRSRP) AS MEAN,STDEV(LteScRSRP-LteNcRSRP)AS STD 
from tbMROData 
GROUP BY ServingSector,InterferingSector 
having count(TimeStamp)in(select t from temp) 
order by ServingSector,InterferingSector)

SELECT ServingSector,InterferingSector,MEAN,STD, ((9-MEAN)/STD)as PrbC2I9,((6-MEAN)/STD)-((-6-MEAN)/STD)as PrbABS6 
into tbC2INew FROM TEMP1

alter table tbC2INew
add constraint PK_c2i
primary key (ServingSector,InterferingSector)
end
