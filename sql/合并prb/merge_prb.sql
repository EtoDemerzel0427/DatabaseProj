USE [TD_LTE]
GO
/****** Object:  StoredProcedure [dbo].[merge_prb]    Script Date: 2019/7/11 2:26:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [TD_LTE]
--GO﻿
ALTER PROCEDURE [dbo].[merge_prb]
AS
	declare @i int =0
	declare @startTime varchar(50)
	declare @turnround int
	declare @neName nvarchar(50)
	declare @cell nvarchar(255)
	declare @cellName nvarchar(50)
	declare @PRB0 float=0
	declare @PRB1 float=0
	declare @PRB2 float=0
	declare @PRB3 float=0
	declare @PRB4 float=0
	declare @PRB5 float=0
	declare @PRB6 float=0
	declare @PRB7 float=0
	declare @PRB8 float=0
	declare @PRB9 float=0
	declare @PRB10 float=0
	declare @PRB11 float=0
	declare @PRB12 float=0
	declare @PRB13 float=0
	declare @PRB14 float=0
	declare @PRB15 float=0
	declare @PRB16 float=0
	declare @PRB17 float=0
	declare @PRB18 float=0
	declare @PRB19 float=0
	declare @PRB20 float=0
	declare @PRB21 float=0
	declare @PRB22 float=0
	declare @PRB23 float=0
	declare @PRB24 float=0
	declare @PRB25 float=0
	declare @PRB26 float=0
	declare @PRB27 float=0
	declare @PRB28 float=0
	declare @PRB29 float=0
	declare @PRB30 float=0
	declare @PRB31 float=0
	declare @PRB32 float=0
	declare @PRB33 float=0
	declare @PRB34 float=0
	declare @PRB35 float=0
	declare @PRB36 float=0
	declare @PRB37 float=0
	declare @PRB38 float=0
	declare @PRB39 float=0
	declare @PRB40 float=0
	declare @PRB41 float=0
	declare @PRB42 float=0
	declare @PRB43 float=0
	declare @PRB44 float=0
	declare @PRB45 float=0
	declare @PRB46 float=0
	declare @PRB47 float=0
	declare @PRB48 float=0
	declare @PRB49 float=0
	declare @PRB50 float=0
	declare @PRB51 float=0
	declare @PRB52 float=0
	declare @PRB53 float=0
	declare @PRB54 float=0
	declare @PRB55 float=0
	declare @PRB56 float=0
	declare @PRB57 float=0
	declare @PRB58 float=0
	declare @PRB59 float=0
	declare @PRB60 float=0
	declare @PRB61 float=0
	declare @PRB62 float=0
	declare @PRB63 float=0
	declare @PRB64 float=0
	declare @PRB65 float=0
	declare @PRB66 float=0
	declare @PRB67 float=0
	declare @PRB68 float=0
	declare @PRB69 float=0
	declare @PRB70 float=0
	declare @PRB71 float=0
	declare @PRB72 float=0
	declare @PRB73 float=0
	declare @PRB74 float=0
	declare @PRB75 float=0
	declare @PRB76 float=0
	declare @PRB77 float=0
	declare @PRB78 float=0
	declare @PRB79 float=0
	declare @PRB80 float=0
	declare @PRB81 float=0
	declare @PRB82 float=0
	declare @PRB83 float=0
	declare @PRB84 float=0
	declare @PRB85 float=0
	declare @PRB86 float=0
	declare @PRB87 float=0
	declare @PRB88 float=0
	declare @PRB89 float=0
	declare @PRB90 float=0
	declare @PRB91 float=0
	declare @PRB92 float=0
	declare @PRB93 float=0
	declare @PRB94 float=0
	declare @PRB95 float=0
	declare @PRB96 float=0
	declare @PRB97 float=0
	declare @PRB98 float=0
	declare @PRB99 float=0
BEGIN
select @i=count(*)from tbPRB;
with temp as
(
select TOP(@i) * from tbPRB order by cell, startTime
)
select * into prbtemp from temp
alter table prbtemp
add constraint PK_temp
primary key (cell, startTime)

declare @j int=0
declare @time nvarchar (100)
while @j<=@i
begin
 select top(1) @time=startTime,@turnround=turnround,@neName=neName,@cell=cell,@cellName=cellName,@PRB0+=PRB0,@PRB1+=PRB1,@PRB2+=PRB2,@PRB3+=PRB3,@PRB4+=PRB4,@PRB5+=PRB5,@PRB6+=PRB6,@PRB7+=PRB7,@PRB8+=PRB8,@PRB9+=PRB9,@PRB10+=PRB10,@PRB11+=PRB11,@PRB12+=PRB12,@PRB13+=PRB13,@PRB14+=PRB14,@PRB15+=PRB15,@PRB16+=PRB16,@PRB17+=PRB17,@PRB18+=PRB18,@PRB19+=PRB19,@PRB20+=PRB20,@PRB21+=PRB21,@PRB22+=PRB22,@PRB23+=PRB23,@PRB24+=PRB24,@PRB25+=PRB25,@PRB26+=PRB26,@PRB27+=PRB27,@PRB28+=PRB28,@PRB29+=PRB29,@PRB30+=PRB30,@PRB31+=PRB31,@PRB32+=PRB32,@PRB33+=PRB33,@PRB34+=PRB34,@PRB35+=PRB35,@PRB36+=PRB36,@PRB37+=PRB37,@PRB38+=PRB38,@PRB39+=PRB39,@PRB40+=PRB40,@PRB41+=PRB41,@PRB42+=PRB42,@PRB43+=PRB43,@PRB44+=PRB44,@PRB45+=PRB45,@PRB46+=PRB46,@PRB47+=PRB47,@PRB48+=PRB48,@PRB49+=PRB49,@PRB50+=PRB50,@PRB51+=PRB51,@PRB52+=PRB52,@PRB53+=PRB53,@PRB54+=PRB54,@PRB55+=PRB55,@PRB56+=PRB56,@PRB57+=PRB57,@PRB58+=PRB58,@PRB59+=PRB59,@PRB60+=PRB60,@PRB61+=PRB61,@PRB62+=PRB62,@PRB63+=PRB63,@PRB64+=PRB64,@PRB65+=PRB65,@PRB66+=PRB66,@PRB67+=PRB67,@PRB68+=PRB68,@PRB69+=PRB69,@PRB70+=PRB70,@PRB71+=PRB71,@PRB72+=PRB72,@PRB73+=PRB73,@PRB74+=PRB74,@PRB75+=PRB75,@PRB76+=PRB76,@PRB77+=PRB77,@PRB78+=PRB78,@PRB79+=PRB79,@PRB80+=PRB80,@PRB81+=PRB81,@PRB82+=PRB82,@PRB83+=PRB83,@PRB84+=PRB84,@PRB85+=PRB85,@PRB86+=PRB86,@PRB87+=PRB87,@PRB88+=PRB88,@PRB89+=PRB89,@PRB90+=PRB90,@PRB91+=PRB91,@PRB92+=PRB92,@PRB93+=PRB93,@PRB94+=PRB94,@PRB95+=PRB95,@PRB96+=PRB96,@PRB97+=PRB97,@PRB98+=PRB98,@PRB99+=PRB99 
 from prbtemp

 if @j%4=0
 begin
 set @startTime=@time
 print @startTime
 end
 delete top(1) from prbtemp

 set @j=@j+1
 if @j%4=0
 begin
 print @j
 INSERT INTO tbPRBnew VALUES ( @startTime,@turnround,@neName,@cell,@cellName,@PRB0/4,@PRB1/4,@PRB2/4,@PRB3/4,@PRB4/4,@PRB5/4,@PRB6/4,@PRB7/4,@PRB8/4,@PRB9/4,@PRB10/4,@PRB11/4,@PRB12/4,@PRB13/4,@PRB14/4,@PRB15/4,@PRB16/4,@PRB17/4,@PRB18/4,@PRB19/4,@PRB20/4,@PRB21/4,@PRB22/4,@PRB23/4,@PRB24/4,@PRB25/4,@PRB26/4,@PRB27/4,@PRB28/4,@PRB29/4,@PRB30/4,@PRB31/4,@PRB32/4,@PRB33/4,@PRB34/4,@PRB35/4,@PRB36/4,@PRB37/4,@PRB38/4,@PRB39/4,@PRB40/4,@PRB41/4,@PRB42/4,@PRB43/4,@PRB44/4,@PRB45/4,@PRB46/4,@PRB47/4,@PRB48/4,@PRB49/4,@PRB50/4,@PRB51/4,@PRB52/4,@PRB53/4,@PRB54/4,@PRB55/4,@PRB56/4,@PRB57/4,@PRB58/4,@PRB59/4,@PRB60/4,@PRB61/4,@PRB62/4,@PRB63/4,@PRB64/4,@PRB65/4,@PRB66/4,@PRB67/4,@PRB68/4,@PRB69/4,@PRB70/4,@PRB71/4,@PRB72/4,@PRB73/4,@PRB74/4,@PRB75/4,@PRB76/4,@PRB77/4,@PRB78/4,@PRB79/4,@PRB80/4,@PRB81/4,@PRB82/4,@PRB83/4,@PRB84/4,@PRB85/4,@PRB86/4,@PRB87/4,@PRB88/4,@PRB89/4,@PRB90/4,@PRB91/4,@PRB92/4,@PRB93/4,@PRB94/4,@PRB95/4,@PRB96/4,@PRB97/4,@PRB98/4,@PRB99/4 )
set @startTime=null set @turnround=null set @neName=null set @cell=null set @cellName=null set @PRB0=0 set @PRB1=0 set @PRB2=0 set @PRB3=0 set @PRB4=0 set @PRB5=0 set @PRB6=0 set @PRB7=0 set @PRB8=0 set @PRB9=0 set @PRB10=0 set @PRB11=0 set @PRB12=0 set @PRB13=0 set @PRB14=0 set @PRB15=0 set @PRB16=0 set @PRB17=0 set @PRB18=0 set @PRB19=0 set @PRB20=0 set @PRB21=0 set @PRB22=0 set @PRB23=0 set @PRB24=0 set @PRB25=0 set @PRB26=0 set @PRB27=0 set @PRB28=0 set @PRB29=0 set @PRB30=0 set @PRB31=0 set @PRB32=0 set @PRB33=0 set @PRB34=0 set @PRB35=0 set @PRB36=0 set @PRB37=0 set @PRB38=0 set @PRB39=0 set @PRB40=0 set @PRB41=0 set @PRB42=0 set @PRB43=0 set @PRB44=0 set @PRB45=0 set @PRB46=0 set @PRB47=0 set @PRB48=0 set @PRB49=0 set @PRB50=0 set @PRB51=0 set @PRB52=0 set @PRB53=0 set @PRB54=0 set @PRB55=0 set @PRB56=0 set @PRB57=0 set @PRB58=0 set @PRB59=0 set @PRB60=0 set @PRB61=0 set @PRB62=0 set @PRB63=0 set @PRB64=0 set @PRB65=0 set @PRB66=0 set @PRB67=0 set @PRB68=0 set @PRB69=0 set @PRB70=0 set @PRB71=0 set @PRB72=0 set @PRB73=0 set @PRB74=0 set @PRB75=0 set @PRB76=0 set @PRB77=0 set @PRB78=0 set @PRB79=0 set @PRB80=0 set @PRB81=0 set @PRB82=0 set @PRB83=0 set @PRB84=0 set @PRB85=0 set @PRB86=0 set @PRB87=0 set @PRB88=0 set @PRB89=0 set @PRB90=0 set @PRB91=0 set @PRB92=0 set @PRB93=0 set @PRB94=0 set @PRB95=0 set @PRB96=0 set @PRB97=0 set @PRB98=0 set @PRB99=0
 end
 end
  drop table prbtemp
end