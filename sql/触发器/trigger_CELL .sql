
create TRIGGER [dbo].[Cell_trigger]
   ON  [dbo].[tbCell]
   instead of  insert
AS 
BEGIN
	
	--因为insert一组数据时，触发器只会被触发一次。考虑两种情况：
	--Case1 : inserted中有多个纪录的主键重复，这时如果tbCell中没有这个主键，这多条重复的纪录都会被插入到tbCell
	--Case2 : inserted中有多个纪录的主键重复，这时如果tbCell中有这个主键,触发器只会用第一条纪录去更新tbCell表
	--以上两种情况都是错的
	--考虑的解决方案是：使用游标，逐条触发一次

	
    --定义变量用于传值
	declare @CITY nvarchar(255)
	declare @SECTOR_ID nvarchar(50)
	declare @SECTOR_NAME nvarchar(255)
	declare @ENODEBID int
	declare @ENODEB_NAME nvarchar(255)
	declare @EARFCN int
	declare @PCI int
	declare @PSS int 
	declare @SSS int
	declare @TAC int 
	declare @VENDOR varchar(255)
	declare @LONGITUDE decimal(13, 5)
	declare @LATITUDE decimal(13, 5)
	declare @STYLE nvarchar(255)
	declare @AZIMUTH float
	declare @HEIGHT float 
	declare @ELECTTILT float
	declare @MECHTILT float
	declare @TOTLETILT float

    --创建游标
    DECLARE YB CURSOR FOR    
    SELECT CITY,SECTOR_ID,SECTOR_NAME,ENODEBID,ENODEB_NAME,EARFCN,PCI,PSS,SSS,TAC,VENDOR,LONGITUDE,LATITUDE,STYLE,AZIMUTH,HEIGHT,ELECTTILT,MECHTILT,TOTLETILT  FROM INSERTED--游标读取行信息
    OPEN YB --打开游标
    FETCH NEXT FROM YB INTO @CITY,@SECTOR_ID,@SECTOR_NAME,@ENODEBID,@ENODEB_NAME, @EARFCN ,@PCI, @PSS,@SSS,@TAC,@VENDOR,@LONGITUDE, @LATITUDE , @STYLE,@AZIMUTH ,@HEIGHT , @ELECTTILT , @MECHTILT,@TOTLETILT--把游标读取到的第一行信息赋值到变量中
    WHILE @@FETCH_STATUS = 0 --[代表是否读取到数据行]0操作成功，-1 FETCH 语句失败或此行不在结果集中，-2 被提取的行不存在 
    BEGIN
        --判断表中是否存在该订单
        IF NOT EXISTS(SELECT 1 FROM tbCell WHERE SECTOR_ID=@SECTOR_ID)  --以第一个CELL为主键
        BEGIN
			insert into tbCell(CITY,SECTOR_ID,SECTOR_NAME,ENODEBID,ENODEB_NAME,EARFCN,PCI,PSS,SSS,TAC,VENDOR,LONGITUDE,LATITUDE,STYLE,AZIMUTH,HEIGHT,ELECTTILT,MECHTILT,TOTLETILT) 
			values ( @CITY,@SECTOR_ID,@SECTOR_NAME,@ENODEBID,@ENODEB_NAME, @EARFCN ,@PCI, @PSS,@SSS,@TAC,@VENDOR,@LONGITUDE, @LATITUDE , @STYLE,@AZIMUTH ,@HEIGHT , @ELECTTILT , @MECHTILT,@TOTLETILT)
        END
		else 
		begin
			update tbCell set CITY=@CITY,SECTOR_NAME=@SECTOR_NAME,SECTOR_ID=@SECTOR_ID,ENODEBID=@ENODEBID,ENODEB_NAME=@ENODEB_NAME,EARFCN=@EARFCN,
			PCI=@PCI,PSS=@PSS,SSS=@SSS,TAC=@TAC,VENDOR=@VENDOR,LONGITUDE=@LONGITUDE,LATITUDE=@LATITUDE,STYLE=@STYLE,AZIMUTH=@AZIMUTH,HEIGHT=@HEIGHT,ELECTTILT=@ELECTTILT,
			MECHTILT=@MECHTILT,TOTLETILT=@TOTLETILT where SECTOR_ID=@SECTOR_ID
		end
		FETCH NEXT FROM YB INTO @CITY,@SECTOR_ID,@SECTOR_NAME,@ENODEBID,@ENODEB_NAME, @EARFCN ,@PCI, @PSS,@SSS,@TAC,@VENDOR,@LONGITUDE, @LATITUDE , @STYLE,@AZIMUTH ,@HEIGHT , @ELECTTILT , @MECHTILT,@TOTLETILT--把游标读取到的第一行信息赋值到变量中
    END
    CLOSE YB --关闭游标 
    DEALLOCATE YB --释放游标    

END


create TRIGGER [dbo].[Mro_trigger]
   ON  [dbo].[tbMROData]
   instead of  insert
AS 
BEGIN
	
	--因为insert一组数据时，触发器只会被触发一次。考虑两种情况：
	--Case1 : inserted中有多个纪录的主键重复，这时如果tbCell中没有这个主键，这多条重复的纪录都会被插入到tbCell
	--Case2 : inserted中有多个纪录的主键重复，这时如果tbCell中有这个主键,触发器只会用第一条纪录去更新tbCell表
	--以上两种情况都是错的
	--考虑的解决方案是：使用游标，逐条触发一次

	
    --定义变量用于传值
	declare @TimeStamp nvarchar(30)
	declare @ServingSector nvarchar(50)
	declare @InterferingSector nvarchar(50)
	declare @LteScRSRP float
	declare @LteNcRSRP float
	declare @LteNcEarfcn int
	declare @LteNcPci smallint

    --创建游标
    DECLARE YB CURSOR FOR    
    SELECT TimeStamp, ServingSector, InterferingSector, LteScRSRP, LteNcRSRP, LteNcEarfcn, LteNcPci  FROM INSERTED--游标读取行信息
    OPEN YB --打开游标
    FETCH NEXT FROM YB INTO @TimeStamp, @ServingSector, @InterferingSector, @LteScRSRP, @LteNcRSRP, @LteNcEarfcn, @LteNcPci--把游标读取到的第一行信息赋值到变量中
    WHILE @@FETCH_STATUS = 0 --[代表是否读取到数据行]0操作成功，-1 FETCH 语句失败或此行不在结果集中，-2 被提取的行不存在 
    BEGIN
        --判断表中是否存在该订单
        IF NOT EXISTS(SELECT 1 FROM tbMROData WHERE TimeStamp=@TimeStamp and ServingSector=@ServingSector and InterferingSector=@InterferingSector)  --以第一个CELL为主键
        BEGIN
			insert into tbMROData(TimeStamp, ServingSector, InterferingSector, LteScRSRP, LteNcRSRP, LteNcEarfcn, LteNcPci) 
			values ( @TimeStamp, @ServingSector, @InterferingSector, @LteScRSRP, @LteNcRSRP, @LteNcEarfcn, @LteNcPci )
        END
		else 
		begin
			update tbMROData set TimeStamp=@TimeStamp, ServingSector=@ServingSector, InterferingSector=@InterferingSector, LteScRSRP=@LteScRSRP, LteNcRSRP=@LteNcRSRP, LteNcEarfcn=@LteNcEarfcn, LteNcPci=@LteNcPci
			where TimeStamp=@TimeStamp and ServingSector=@ServingSector and InterferingSector=@InterferingSector
		end
		FETCH NEXT FROM YB INTO @TimeStamp, @ServingSector, @InterferingSector, @LteScRSRP, @LteNcRSRP, @LteNcEarfcn, @LteNcPci--把游标读取到的第一行信息赋值到变量中
    END
    CLOSE YB --关闭游标 
    DEALLOCATE YB --释放游标    

END


create TRIGGER [dbo].[Kpi_trigger]
   ON  [dbo].[tbKPI]
   instead of  insert
AS 
BEGIN
	
	--因为insert一组数据时，触发器只会被触发一次。考虑两种情况：
	--Case1 : inserted中有多个纪录的主键重复，这时如果tbCell中没有这个主键，这多条重复的纪录都会被插入到tbCell
	--Case2 : inserted中有多个纪录的主键重复，这时如果tbCell中有这个主键,触发器只会用第一条纪录去更新tbCell表
	--以上两种情况都是错的
	--考虑的解决方案是：使用游标，逐条触发一次
	--起始时间	周期	网元名称	小区	小区	RRC连接建立完成次数 (无)	RRC连接请求次数（包括重发） (无)	RRC建立成功率qf (%)	E-RAB建立成功总次数 (无)	E-RAB建立尝试总次数 (无)	E-RAB建立成功率2 (%)	eNodeB触发的E-RAB异常释放总次数 (无)	小区切换出E-RAB异常释放总次数 (无)	E-RAB掉线率(新) (%)	无线接通率ay (%)	eNodeB发起的S1 RESET导致的UE Context释放次数 (无)	UE Context异常释放次数 (无)	UE Context建立成功总次数 (无)	无线掉线率 (%)	eNodeB内异频切换出成功次数 (无)	eNodeB内异频切换出尝试次数 (无)	eNodeB内同频切换出成功次数 (无)	eNodeB内同频切换出尝试次数 (无)	eNodeB间异频切换出成功次数 (无)	eNodeB间异频切换出尝试次数 (无)	eNodeB间同频切换出成功次数 (无)	eNodeB间同频切换出尝试次数 (无)	eNB内切换成功率 (%)	eNB间切换成功率 (%)	同频切换成功率zsp (%)	异频切换成功率zsp (%)	切换成功率 (%)	小区PDCP层所接收到的上行数据的总吞吐量 (比特)	小区PDCP层所发送的下行数据的总吞吐量 (比特)	RRC重建请求次数 (无)	RRC连接重建比率 (%)	通过重建回源小区的eNodeB间同频切换出执行成功次数 (无)	通过重建回源小区的eNodeB间异频切换出执行成功次数 (无)	通过重建回源小区的eNodeB内同频切换出执行成功次数 (无)	通过重建回源小区的eNodeB内异频切换出执行成功次数 (无)	eNB内切换出成功次数 (次)	eNB内切换出请求次数 (次)

	
    --定义变量用于传值
	declare @startTime varchar(50)
	declare @turnround int
	declare @neName nvarchar(50)
	declare @cell nvarchar(255)
	declare @cellName nvarchar(50)
	declare @rrcSucTime int
	declare @rrcReqTime int
	declare @rrcSucRate float
	declare @erabSucTime int
	declare @erabReqTime int
	declare @erabSucRate float
	declare @enodebException int
	declare @cellException int
	declare @erabOfflineRate float
	declare @_O float
	declare @_P int
	declare @_Q int
	declare @_R int
	declare @_S float
	declare @_T int
	declare @_U int
	declare @_V int
	declare @_W int
	declare @_X int
	declare @_Y int
	declare @_Z int
	declare @_AA int
	declare @_AB float
	declare @_AC float
	declare @_AD float
	declare @_AE float
	declare @_AF float
	declare @_AG bigint
	declare @_AH bigint
	declare @_AI int
	declare @_AJ float
	declare @_AK int
	declare @_AL int
	declare @_AM int
	declare @_AN int
	declare @_AO int
	declare @_AP int

    --创建游标
    DECLARE YB CURSOR FOR    
    SELECT  startTime ,turnround ,neName,cell,cellName,rrcSucTime,rrcReqTime,rrcSucRate,erabSucTime,erabReqTime,erabSucRate,enodebException,cellException,
	erabOfflineRate,_O,	_P,	_Q,	_R,	_S,	_T,	_U,	_V,	_W,	_X,	_Y,	_Z,	_AA,_AB,_AC,_AD,_AE,_AF,_AG,_AH,_AI,_AJ,_AK,_AL,_AM,_AN,_AO,_AP 
	FROM INSERTED--游标读取行信息
    OPEN YB --打开游标
    FETCH NEXT FROM YB INTO @startTime, @turnround, @neName, @cell, @cellName, @rrcSucTime, @rrcReqTime, @rrcSucRate, @erabSucTime, @erabReqTime, @erabSucRate, @enodebException, @cellException,
	@erabOfflineRate,@_O,@_P,@_Q,@_R,@_S,@_T,@_U,@_V,@_W,@_X,@_Y,@_Z,@_AA,@_AB,@_AC,@_AD,@_AE,@_AF,@_AG,@_AH,
	@_AI,@_AJ,@_AK,@_AL,@_AM,@_AN,@_AO,@_AP--把游标读取到的第一行信息赋值到变量中
    WHILE @@FETCH_STATUS = 0 --[代表是否读取到数据行]0操作成功，-1 FETCH 语句失败或此行不在结果集中，-2 被提取的行不存在 
    BEGIN
        --判断表中是否存在该订单
        IF NOT EXISTS(SELECT 1 FROM tbKPI WHERE startTime=@startTime and cell=@cell )  --以第一个CELL为主键
        BEGIN
			insert into tbKPI(startTime ,turnround ,neName,cell,cellName,rrcSucTime,rrcReqTime,rrcSucRate,erabSucTime,erabReqTime,erabSucRate,enodebException,cellException,
	erabOfflineRate,_O,	_P,	_Q,	_R,	_S,	_T,	_U,	_V,	_W,	_X,	_Y,	_Z,	_AA,_AB,_AC,_AD,_AE,_AF,_AG,_AH,_AI,_AJ,_AK,_AL,_AM,_AN,_AO,_AP) 
			values ( @startTime, @turnround, @neName, @cell, @cellName, @rrcSucTime, @rrcReqTime, @rrcSucRate, @erabSucTime, @erabReqTime, @erabSucRate, @enodebException, @cellException,
	@erabOfflineRate,@_O,@_P,@_Q,@_R,@_S,@_T,@_U,@_V,@_W,@_X,@_Y,@_Z,@_AA,@_AB,@_AC,@_AD,@_AE,@_AF,@_AG,@_AH,
	@_AI,@_AJ,@_AK,@_AL,@_AM,@_AN,@_AO,@_AP )
        END
		else 
		begin
			update tbKPI set startTime=@startTime ,turnround=@turnround ,neName=@neName,cell=@cell,cellName=@cellName,rrcSucTime=@rrcSucTime,rrcReqTime=@rrcReqTime,rrcSucRate=@rrcSucRate,erabSucTime=@erabSucTime,erabReqTime=@erabReqTime,erabSucRate=@erabSucRate,enodebException=@enodebException,cellException=@cellException,
	erabOfflineRate=@erabOfflineRate,_O=@_O,_P=@_P,	_Q=@_Q,	_R=@_R,	_S=@_S,	_T=@_T,	_U=@_U,	_V=@_V,	_W=@_W,	_X=@_X,	_Y=@_Y,	_Z=@_Z,_AA=@_AA,_AB=@_AB,_AC=@_AC,_AD=@_AD,_AE=@_AE,_AF=@_AF,_AG=@_AG,_AH=@_AH,_AI=@_AI,_AJ=@_AJ,_AK=@_AK,_AL=@_AL,_AM=@_AM,_AN=@_AN,_AO=@_AO,_AP=@_AP
			where startTime=@startTime and cell=@cell
		end
		FETCH NEXT FROM YB INTO @startTime, @turnround, @neName, @cell, @cellName, @rrcSucTime, @rrcReqTime, @rrcSucRate, @erabSucTime, @erabReqTime, @erabSucRate, @enodebException, @cellException,
	@erabOfflineRate,@_O,@_P,@_Q,@_R,@_S,@_T,@_U,@_V,@_W,@_X,@_Y,@_Z,@_AA,@_AB,@_AC,@_AD,@_AE,@_AF,@_AG,@_AH,@_AI,@_AJ,@_AK,@_AL,@_AM,@_AN,@_AO,@_AP--把游标读取到的第一行信息赋值到变量中
    END
    CLOSE YB --关闭游标 
    DEALLOCATE YB --释放游标    

END


create TRIGGER [dbo].[Prb_trigger]
   ON  [dbo].[tbPRB]
   instead of  insert
AS 
BEGIN
	
	--因为insert一组数据时，触发器只会被触发一次。考虑两种情况：
	--Case1 : inserted中有多个纪录的主键重复，这时如果tbCell中没有这个主键，这多条重复的纪录都会被插入到tbCell
	--Case2 : inserted中有多个纪录的主键重复，这时如果tbCell中有这个主键,触发器只会用第一条纪录去更新tbCell表
	--以上两种情况都是错的
	--考虑的解决方案是：使用游标，逐条触发一次
	--起始时间	周期	网元名称	小区	小区	RRC连接建立完成次数 (无)	RRC连接请求次数（包括重发） (无)	RRC建立成功率qf (%)	E-RAB建立成功总次数 (无)	E-RAB建立尝试总次数 (无)	E-RAB建立成功率2 (%)	eNodeB触发的E-RAB异常释放总次数 (无)	小区切换出E-RAB异常释放总次数 (无)	E-RAB掉线率(新) (%)	无线接通率ay (%)	eNodeB发起的S1 RESET导致的UE Context释放次数 (无)	UE Context异常释放次数 (无)	UE Context建立成功总次数 (无)	无线掉线率 (%)	eNodeB内异频切换出成功次数 (无)	eNodeB内异频切换出尝试次数 (无)	eNodeB内同频切换出成功次数 (无)	eNodeB内同频切换出尝试次数 (无)	eNodeB间异频切换出成功次数 (无)	eNodeB间异频切换出尝试次数 (无)	eNodeB间同频切换出成功次数 (无)	eNodeB间同频切换出尝试次数 (无)	eNB内切换成功率 (%)	eNB间切换成功率 (%)	同频切换成功率zsp (%)	异频切换成功率zsp (%)	切换成功率 (%)	小区PDCP层所接收到的上行数据的总吞吐量 (比特)	小区PDCP层所发送的下行数据的总吞吐量 (比特)	RRC重建请求次数 (无)	RRC连接重建比率 (%)	通过重建回源小区的eNodeB间同频切换出执行成功次数 (无)	通过重建回源小区的eNodeB间异频切换出执行成功次数 (无)	通过重建回源小区的eNodeB内同频切换出执行成功次数 (无)	通过重建回源小区的eNodeB内异频切换出执行成功次数 (无)	eNB内切换出成功次数 (次)	eNB内切换出请求次数 (次)

	
    --定义变量用于传值
	declare @startTime varchar(50)
	declare @turnround int
	declare @neName nvarchar(50)
	declare @cell nvarchar(255)
	declare @cellName nvarchar(50)
	declare @PRB0 float
	declare @PRB1 float
	declare @PRB2 float
	declare @PRB3 float
	declare @PRB4 float
	declare @PRB5 float
	declare @PRB6 float
	declare @PRB7 float
	declare @PRB8 float
	declare @PRB9 float
	declare @PRB10 float
	declare @PRB11 float
	declare @PRB12 float
	declare @PRB13 float
	declare @PRB14 float
	declare @PRB15 float
	declare @PRB16 float
	declare @PRB17 float
	declare @PRB18 float
	declare @PRB19 float
	declare @PRB20 float
	declare @PRB21 float
	declare @PRB22 float
	declare @PRB23 float
	declare @PRB24 float
	declare @PRB25 float
	declare @PRB26 float
	declare @PRB27 float
	declare @PRB28 float
	declare @PRB29 float
	declare @PRB30 float
	declare @PRB31 float
	declare @PRB32 float
	declare @PRB33 float
	declare @PRB34 float
	declare @PRB35 float
	declare @PRB36 float
	declare @PRB37 float
	declare @PRB38 float
	declare @PRB39 float
	declare @PRB40 float
	declare @PRB41 float
	declare @PRB42 float
	declare @PRB43 float
	declare @PRB44 float
	declare @PRB45 float
	declare @PRB46 float
	declare @PRB47 float
	declare @PRB48 float
	declare @PRB49 float
	declare @PRB50 float
	declare @PRB51 float
	declare @PRB52 float
	declare @PRB53 float
	declare @PRB54 float
	declare @PRB55 float
	declare @PRB56 float
	declare @PRB57 float
	declare @PRB58 float
	declare @PRB59 float
	declare @PRB60 float
	declare @PRB61 float
	declare @PRB62 float
	declare @PRB63 float
	declare @PRB64 float
	declare @PRB65 float
	declare @PRB66 float
	declare @PRB67 float
	declare @PRB68 float
	declare @PRB69 float
	declare @PRB70 float
	declare @PRB71 float
	declare @PRB72 float
	declare @PRB73 float
	declare @PRB74 float
	declare @PRB75 float
	declare @PRB76 float
	declare @PRB77 float
	declare @PRB78 float
	declare @PRB79 float
	declare @PRB80 float
	declare @PRB81 float
	declare @PRB82 float
	declare @PRB83 float
	declare @PRB84 float
	declare @PRB85 float
	declare @PRB86 float
	declare @PRB87 float
	declare @PRB88 float
	declare @PRB89 float
	declare @PRB90 float
	declare @PRB91 float
	declare @PRB92 float
	declare @PRB93 float
	declare @PRB94 float
	declare @PRB95 float
	declare @PRB96 float
	declare @PRB97 float
	declare @PRB98 float
	declare @PRB99 float

    --创建游标
    DECLARE YB CURSOR FOR    
    SELECT  startTime ,turnround ,neName,cell,cellName,PRB0,PRB1,PRB2,PRB3,PRB4,PRB5,PRB6,PRB7,PRB8,PRB9,PRB10,PRB11,PRB12,PRB13,PRB14,PRB15,PRB16,PRB17,PRB18,PRB19,PRB20,PRB21,PRB22,PRB23,PRB24,PRB25,PRB26,PRB27,PRB28,PRB29,PRB30,PRB31,PRB32,PRB33,PRB34,PRB35,PRB36,PRB37,PRB38,
	PRB39,PRB40,PRB41,PRB42,PRB43,PRB44,PRB45,PRB46,PRB47,PRB48,PRB49,PRB50,PRB51,PRB52,PRB53,PRB54,PRB55,PRB56,PRB57,PRB58,PRB59,PRB60,PRB61,PRB62,PRB63,PRB64,PRB65,PRB66,PRB67,PRB68,PRB69,PRB70,PRB71,PRB72,PRB73,PRB74,PRB75,PRB76,PRB77,PRB78,PRB79,PRB80,PRB81,PRB82,PRB83,PRB84,
	PRB85,PRB86,PRB87,PRB88,PRB89,PRB90,PRB91,PRB92,PRB93,PRB94,PRB95,PRB96,PRB97,PRB98,PRB99
	FROM INSERTED--游标读取行信息
    OPEN YB --打开游标
    FETCH NEXT FROM YB INTO @startTime ,@turnround ,@neName,@cell,@cellName,@PRB0,@PRB1,@PRB2,@PRB3,@PRB4,@PRB5,@PRB6,@PRB7,@PRB8,@PRB9,@PRB10,@PRB11,@PRB12,@PRB13,@PRB14,@PRB15,@PRB16,@PRB17,@PRB18,@PRB19,@PRB20,@PRB21,@PRB22,@PRB23,@PRB24,@PRB25,@PRB26,@PRB27,@PRB28,@PRB29,@PRB30,@PRB31,@PRB32,@PRB33,@PRB34,@PRB35,@PRB36,@PRB37,@PRB38,
	@PRB39,@PRB40,@PRB41,@PRB42,@PRB43,@PRB44,@PRB45,@PRB46,@PRB47,@PRB48,@PRB49,@PRB50,@PRB51,@PRB52,@PRB53,@PRB54,@PRB55,@PRB56,@PRB57,@PRB58,@PRB59,@PRB60,@PRB61,@PRB62,@PRB63,@PRB64,@PRB65,@PRB66,@PRB67,@PRB68,@PRB69,@PRB70,@PRB71,@PRB72,@PRB73,@PRB74,@PRB75,@PRB76,@PRB77,@PRB78,@PRB79,@PRB80,@PRB81,@PRB82,@PRB83,@PRB84,
	@PRB85,@PRB86,@PRB87,@PRB88,@PRB89,@PRB90,@PRB91,@PRB92,@PRB93,@PRB94,@PRB95,@PRB96,@PRB97,@PRB98,@PRB99--把游标读取到的第一行信息赋值到变量中
    WHILE @@FETCH_STATUS = 0 --[代表是否读取到数据行]0操作成功，-1 FETCH 语句失败或此行不在结果集中，-2 被提取的行不存在 
    BEGIN
        --判断表中是否存在该订单
        IF NOT EXISTS(SELECT 1 FROM tbPRB WHERE startTime=@startTime and cell=@cell )  --以第一个CELL为主键
        BEGIN
			insert into tbPRB(startTime ,turnround ,neName,cell,cellName,PRB0,PRB1,PRB2,PRB3,PRB4,PRB5,PRB6,PRB7,PRB8,PRB9,PRB10,PRB11,PRB12,PRB13,PRB14,PRB15,PRB16,PRB17,PRB18,PRB19,PRB20,PRB21,PRB22,PRB23,PRB24,PRB25,PRB26,PRB27,PRB28,PRB29,PRB30,PRB31,PRB32,PRB33,PRB34,PRB35,PRB36,PRB37,PRB38,
	PRB39,PRB40,PRB41,PRB42,PRB43,PRB44,PRB45,PRB46,PRB47,PRB48,PRB49,PRB50,PRB51,PRB52,PRB53,PRB54,PRB55,PRB56,PRB57,PRB58,PRB59,PRB60,PRB61,PRB62,PRB63,PRB64,PRB65,PRB66,PRB67,PRB68,PRB69,PRB70,PRB71,PRB72,PRB73,PRB74,PRB75,PRB76,PRB77,PRB78,PRB79,PRB80,PRB81,PRB82,PRB83,PRB84,
	PRB85,PRB86,PRB87,PRB88,PRB89,PRB90,PRB91,PRB92,PRB93,PRB94,PRB95,PRB96,PRB97,PRB98,PRB99) 
			values ( @startTime ,@turnround ,@neName,@cell,@cellName,@PRB0,@PRB1,@PRB2,@PRB3,@PRB4,@PRB5,@PRB6,@PRB7,@PRB8,@PRB9,@PRB10,@PRB11,@PRB12,@PRB13,@PRB14,@PRB15,@PRB16,@PRB17,@PRB18,@PRB19,@PRB20,@PRB21,@PRB22,@PRB23,@PRB24,@PRB25,@PRB26,@PRB27,@PRB28,@PRB29,@PRB30,@PRB31,@PRB32,@PRB33,@PRB34,@PRB35,@PRB36,@PRB37,@PRB38,
	@PRB39,@PRB40,@PRB41,@PRB42,@PRB43,@PRB44,@PRB45,@PRB46,@PRB47,@PRB48,@PRB49,@PRB50,@PRB51,@PRB52,@PRB53,@PRB54,@PRB55,@PRB56,@PRB57,@PRB58,@PRB59,@PRB60,@PRB61,@PRB62,@PRB63,@PRB64,@PRB65,@PRB66,@PRB67,@PRB68,@PRB69,@PRB70,@PRB71,@PRB72,@PRB73,@PRB74,@PRB75,@PRB76,@PRB77,@PRB78,@PRB79,@PRB80,@PRB81,@PRB82,@PRB83,@PRB84,
	@PRB85,@PRB86,@PRB87,@PRB88,@PRB89,@PRB90,@PRB91,@PRB92,@PRB93,@PRB94,@PRB95,@PRB96,@PRB97,@PRB98,@PRB99 )
        END
		else 
		begin
			update tbPRB set startTime=@startTime ,turnround=@turnround ,neName=@neName,cell=@cell,cellName=@cellName,PRB0=@PRB0,PRB1=@PRB1,PRB2=@PRB2,PRB3=@PRB3,PRB4=@PRB4,PRB5=@PRB5,PRB6=@PRB6,PRB7=@PRB7,PRB8=@PRB8,PRB9=@PRB9,PRB10=@PRB10,PRB11=@PRB11,PRB12=@PRB12,PRB13=@PRB13,PRB14=@PRB14,PRB15=@PRB15,PRB16=@PRB16,PRB17=@PRB17,PRB18=@PRB18,PRB19=@PRB19,PRB20=@PRB20,PRB21=@PRB21,PRB22=@PRB22,PRB23=@PRB23,PRB24=@PRB24,PRB25=@PRB25,PRB26=@PRB26,PRB27=@PRB27,PRB28=@PRB28,PRB29=@PRB29,PRB30=@PRB30,PRB31=@PRB31,PRB32=@PRB32,PRB33=@PRB33,PRB34=@PRB34,PRB35=@PRB35,PRB36=@PRB36,PRB37=@PRB37,PRB38=@PRB38,
	PRB39=@PRB39,PRB40=@PRB40,PRB41=@PRB41,PRB42=@PRB42,PRB43=@PRB43,PRB44=@PRB44,PRB45=@PRB45,PRB46=@PRB46,PRB47=@PRB47,PRB48=@PRB48,PRB49=@PRB49,PRB50=@PRB50,PRB51=@PRB51,PRB52=@PRB52,PRB53=@PRB53,PRB54=@PRB54,PRB55=@PRB55,PRB56=@PRB56,PRB57=@PRB57,PRB58=@PRB58,PRB59=@PRB59,PRB60=@PRB60,PRB61=@PRB61,PRB62=@PRB62,PRB63=@PRB63,PRB64=@PRB64,PRB65=@PRB65,PRB66=@PRB66,PRB67=@PRB67,PRB68=@PRB68,PRB69=@PRB69,PRB70=@PRB70,PRB71=@PRB71,PRB72=@PRB72,PRB73=@PRB73,PRB74=@PRB74,PRB75=@PRB75,PRB76=@PRB76,PRB77=@PRB77,PRB78=@PRB78,PRB79=@PRB79,PRB80=@PRB80,PRB81=@PRB81,PRB82=@PRB82,PRB83=@PRB83,PRB84=@PRB84,
	PRB85=@PRB85,PRB86=@PRB86,PRB87=@PRB87,PRB88=@PRB88,PRB89=@PRB89,PRB90=@PRB90,PRB91=@PRB91,PRB92=@PRB92,PRB93=@PRB93,PRB94=@PRB94,PRB95=@PRB95,PRB96=@PRB96,PRB97=@PRB97,PRB98=@PRB98,PRB99=@PRB99
			where startTime=@startTime and cell=@cell
		end
		FETCH NEXT FROM YB INTO @startTime ,@turnround ,@neName,@cell,@cellName,@PRB0,@PRB1,@PRB2,@PRB3,@PRB4,@PRB5,@PRB6,@PRB7,@PRB8,@PRB9,@PRB10,@PRB11,@PRB12,@PRB13,@PRB14,@PRB15,@PRB16,@PRB17,@PRB18,@PRB19,@PRB20,@PRB21,@PRB22,@PRB23,@PRB24,@PRB25,@PRB26,@PRB27,@PRB28,@PRB29,@PRB30,@PRB31,@PRB32,@PRB33,@PRB34,@PRB35,@PRB36,@PRB37,@PRB38,
	@PRB39,@PRB40,@PRB41,@PRB42,@PRB43,@PRB44,@PRB45,@PRB46,@PRB47,@PRB48,@PRB49,@PRB50,@PRB51,@PRB52,@PRB53,@PRB54,@PRB55,@PRB56,@PRB57,@PRB58,@PRB59,@PRB60,@PRB61,@PRB62,@PRB63,@PRB64,@PRB65,@PRB66,@PRB67,@PRB68,@PRB69,@PRB70,@PRB71,@PRB72,@PRB73,@PRB74,@PRB75,@PRB76,@PRB77,@PRB78,@PRB79,@PRB80,@PRB81,@PRB82,@PRB83,@PRB84,
	@PRB85,@PRB86,@PRB87,@PRB88,@PRB89,@PRB90,@PRB91,@PRB92,@PRB93,@PRB94,@PRB95,@PRB96,@PRB97,@PRB98,@PRB99--把游标读取到的第一行信息赋值到变量中
    END
    CLOSE YB --关闭游标 
    DEALLOCATE YB --释放游标    

END

--测试代码1
--insert into UserInformation values ('jjj','111')
--insert into UserInformation values ('jjj','222')
--ALTER TABLE UserInformation ADD id bigint IDENTITY(1,1)
--delete UserInformation 
--where  id
--NOT IN (Select MIN(id)  From [UserInformation] Group By [name]) --取重复里的最小的RowId记录
--ALTER table userInformation drop column id

--测试代码 
insert into tbMROData(TimeStamp, ServingSector, InterferingSector, LteScRSRP, LteNcRSRP, LteNcEarfcn, LteNcPci) values ('1','5641-129','1',1,1,1,1)
select * from tbMROData where TimeStamp='1'
delete  from tbMROData where TimeStamp='1'
/*
--试试批量的insert，进一步理解触发器
select top(10)*　into cell from  tbCell
select * from cell
insert into tbCell select * from cell
select * from tbCell where SECTOR_ID='2'
delete tbCell where SECTOR_ID='2'
truncate table tbCell
truncate table cell
*/