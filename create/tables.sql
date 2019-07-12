create table tbUser(
    id int not null identity primary key,
	username varchar(20) not null unique,
	email varchar(120) not null unique,
	password varchar(60) not null,
)


create table tbCell(
	CITY nvarchar(255) null,
	SECTOR_ID nvarchar(255) not null,
	SECTOR_NAME nvarchar(255) not null,
	EARFCN int not null
	constraint EARFCN_tbCell check (EARFCN in (38350,38400,38098,38100,37900,37902,40936,40938,40940,38950,39052,39148,39250,38496,38544)),
	PCI int null
	constraint PCI_tbCell check (PCI is null or (PCI between 0 and 503)),
	PSS int null
	constraint PSS_tbCell check (PSS is null or (PSS in (0,1,2))),
	SSS int null
	constraint SSS_tbCell check (SSS is null or (SSS between 0 and 167)),
	TAC int null,
	AZIMUTH float not null,
	HEIGHT float null,
	ELECTTILT float null,
	MECHTILT float null,
	TOTLETILT float not null,
	ENODEBID int not null,
	ENODEB_NAME nvarchar(255) not null,
	VENDOR nvarchar(255) null
	constraint VENDOR_tbCell check(VENDOR is null or (VENDOR in('华为','中兴','诺西','爱立信','贝尔','大唐'))),
	LONGITUDE float not null
	constraint LONGITUDE_tbCell check (LONGITUDE between -180.00000 and 180.00000),
	LATITUDE float not null
	constraint LATITUDE_tbCell check (LATITUDE between -90.00000 and 90.00000),
	style nvarchar(255) null
	constraint STYLE_tbCell check (STYLE is null or (STYLE in ('宏站','室内','室外','室分'))),
	primary key(SECTOR_ID)
)
CREATE NONCLUSTERED INDEX IX_tbCell ON tbCell (SECTOR_NAME)

create table tbOptCell(
	SECTOR_ID nvarchar(50) not null,
	EARFCN int null
	constraint EARFCN_tbOptCell check (EARFCN in (38350,38400,38098,38100,37900,37902,40936,40938,40940,38950,39052,39148,39250,38496,38544)),
	CELL_TYPE nvarchar(50) null
	constraint CELL_TYPE_tbOptCell check (CELL_TYPE is null or (CELL_TYPE in ('优化区','保护带'))),
	primary key(SECTOR_ID)
)

create table tbAdjCell(
	S_SECTOR_ID nvarchar(50) not null,
	N_SECTOR_ID nvarchar(50) not null,
	S_EARFCN int null
	constraint S_EARFCN_tbAdjCel check (S_EARFCN in (38350,38400,38098,38100,37900,37902,40936,40938,40940,38950,39052,39148,39250,38496,38544)),
	N_EARFCN int null
	constraint N_EARFCN_tbAdjCel check (N_EARFCN in (38350,38400,38098,38100,37900,37902,40936,40938,40940,38950,39052,39148,39250,38496,38544)),
	primary key(S_SECTOR_ID,N_SECTOR_ID)
)

create table tbSecAdjCell(
	S_SECTOR_ID varchar(50) not null,
	N_SECTOR_ID varchar(50) not null,
	primary key(S_SECTOR_ID,N_SECTOR_ID)
)
create table tbPCIAssignment(
	ASSIGN_ID smallint identity(1,1),
	EARFCN int null
	constraint EARFCN_tbPCIAssignment check (EARFCN in (38350,38400,38098,38100,37900,37902,40936,40938,40940,38950,39052,39148,39250,38496,38544)),
	SECTOR_ID nvarchar(200) not null,
	SECTOR_NAME nvarchar(200) null,
	ENBODEB_ID int null,
	PCI int null,
	PSS int null,
	constraint PSS_tbPCIAssignment check(PSS=PCI%3),
	SSS int null,
	constraint SSS_tbPCIAssignment check(SSS=PCI/3),
	LONGITUDE float null,
	LATITUDE float null,
	style varchar(50)null
	constraint STYLE_tbPCIAssignment check (STYLE is null or (STYLE in ('宏站','室内','室外'))),
	OPT_DATETIME datetime null default getdate(),
	primary key(ASSIGN_ID,SECTOR_ID)

)

create table tbATUData(
	seq bigint not null,
	FileName nvarchar(255) not null,
	Time varchar(100),
	Longitude float,
	Latitude float,
	CellID nvarchar(50),
	TAC int,
	EARFCN int,
	PCI smallint,
	RSRP float,
	RS_SINR float,
	NCell_ID_1 nvarchar(50),
	NCell_EARFCN_1 int,
	NCell_PCI_1 smallint,
	NCell_RSRP_1 float,
	NCell_ID_2 nvarchar(50),
	NCell_EARFCN_2 int,
	NCell_PCI_2 smallint,
	NCell_RSRP_2 float,
	NCell_ID_3 nvarchar(50),
	NCell_EARFCN_3 int,
	NCell_PCI_3 smallint,
	NCell_RSRP_3 float,
	NCell_ID_4 nvarchar(50),
	NCell_EARFCN_4 int,
	NCell_PCI_4 smallint,
	NCell_RSRP_4 float,
	NCell_ID_5 nvarchar(50),
	NCell_EARFCN_5 int,
	NCell_PCI_5 smallint,
	NCell_RSRP_5 float,
	NCell_ID_6 nvarchar(50),
	NCell_EARFCN_6 int,
	NCell_PCI_6 smallint,
	NCell_RSRP_6 float,
	primary key(seq,FileName)
)

create table tbATUC2I(
	SECTOR_ID nvarchar(50) not null,
	NCELL_ID nvarchar(50)not null,
	RATIO_ALL float,
	RANK int,
	COSITE tinyint
	constraint COSITE_tbATUC2I check (COSITE is null or (COSITE in (0,1))),
	primary key(SECTOR_ID,NCELL_ID)
)

create table tbATUHandOver(
	SSECTOR_ID nvarchar(50),
	NSECTOR_ID varchar(50),
	HOATT int
)

create table tbMROData(
	TimeStamp nvarchar(30) not null,
	ServingSector nvarchar(255) not null,
	InterferingSector nvarchar(50) not null,
	LteScRSRP float,
	LteNcRSRP float,
	LteNcEarfcn int,
	LteNcPci smallint
	foreign key(ServingSector) references tbCell(SECTOR_ID)
)
CREATE NONCLUSTERED INDEX IX_tbMROData ON tbMROData (ServingSector,InterferingSector)

create table tbC2I(
	CITY nvarchar(255),
	SCELL nvarchar(255) not null,
	NCELL nvarchar(255) not null,
	PrC2I9 float,
	C2I_Mean float,
	Std float,
	SampleCount float,
	WeightedC2I float,
	foreign key (SCELL) references tbCell(Sector_ID)
)

create table tbC2INew(
	SCELL nvarchar(255) not null,
	NCELL nvarchar(255) not null,
	C2I_mean float,
	std float,
	PrbC2I9 float,
	PrbABS6 float
)

create table tbHandOver(
	CITY nvarchar(255),
	SCELL varchar(50) not null,
	NCELL varchar(50) not null,
	HOATT int,
	HOSUCC int,
	HOSUCCRATE numeric(7,4),
	primary key(SCELL,NCELL),
)

create table tbKPI(
	startTime date not null,
	turnround int,
	name nvarchar(50),
	cell_multi nvarchar(255) not null,
	cell nvarchar(50),
	suc_time int,
	req_time int,
	RRC_suc_rate float,
	suc_total int,
	try_total int,
	E_RAB_suc_rate float,
	eNodeB_exception int,
	cell_exception int,
	E_RAB_offline float,
	ay float,
	enodeb_release_time int,
	UE_Context_exception_time int,
	UE_Context_suc_time int,
	wifi_offline_rate float,
	t_ int,
	u_ int,
	v_ int,
	w_ int,
	x_ int,
	y_ int,
	z_ int,
	aa_ int,
	ab_ float,  --NIL????
	ac_ float,
	ad_ float,
	ae_ float, --NIL???
	af_ float,
	ag_ bigint,
	ah_ bigint,
	ai_ int,
	aj_ float,
	ak_ int,
	al_ int,
	am_ int,
	an_ int,
	ao_ int,
	ap_ int,
	primary key(startTime,cell_multi)
)
CREATE NONCLUSTERED INDEX IX_tbKPI ON tbKPI (name,starttime)

create table tbPRB(
	startTime datetime not null,
	turnround int,
	name nvarchar(50),
	cell nvarchar(255) not null,
	cell_name nvarchar(50),
	PRB0 float,
	PRB1 float,
	PRB2 float,
	PRB3 float,
	PRB4 float,
	PRB5 float,
	PRB6 float,
	PRB7 float,
	PRB8 float,
	PRB9 float,
	PRB10 float,
	PRB11 float,
	PRB12 float,
	PRB13 float,
	PRB14 float,
	PRB15 float,
	PRB16 float,
	PRB17 float,
	PRB18 float,
	PRB19 float,
	PRB20 float,
	PRB21 float,
	PRB22 float,
	PRB23 float,
	PRB24 float,
	PRB25 float,
	PRB26 float,
	PRB27 float,
	PRB28 float,
	PRB29 float,
	PRB30 float,
	PRB31 float,
	PRB32 float,
	PRB33 float,
	PRB34 float,
	PRB35 float,
	PRB36 float,
	PRB37 float,
	PRB38 float,
	PRB39 float,
	PRB40 float,
	PRB41 float,
	PRB42 float,
	PRB43 float,
	PRB44 float,
	PRB45 float,
	PRB46 float,
	PRB47 float,
	PRB48 float,
	PRB49 float,
	PRB50 float,
	PRB51 float,
	PRB52 float,
	PRB53 float,
	PRB54 float,
	PRB55 float,
	PRB56 float,
	PRB57 float,
	PRB58 float,
	PRB59 float,
	PRB60 float,
	PRB61 float,
	PRB62 float,
	PRB63 float,
	PRB64 float,
	PRB65 float,
	PRB66 float,
	PRB67 float,
	PRB68 float,
	PRB69 float,
	PRB70 float,
	PRB71 float,
	PRB72 float,
	PRB73 float,
	PRB74 float,
	PRB75 float,
	PRB76 float,
	PRB77 float,
	PRB78 float,
	PRB79 float,
	PRB80 float,
	PRB81 float,
	PRB82 float,
	PRB83 float,
	PRB84 float,
	PRB85 float,
	PRB86 float,
	PRB87 float,
	PRB88 float,
	PRB89 float,
	PRB90 float,
	PRB91 float,
	PRB92 float,
	PRB93 float,
	PRB94 float,
	PRB95 float,
	PRB96 float,
	PRB97 float,
	PRB98 float,
	PRB99 float,
	primary key(startTime,cell)
)

create table tbPRBNew(
	startTime nvarchar(50) not null,
	turnround int,
	name nvarchar(50),
	cell nvarchar(255) not null,
	cell_name nvarchar(50),
	PRB0 float,
	PRB1 float,
	PRB2 float,
	PRB3 float,
	PRB4 float,
	PRB5 float,
	PRB6 float,
	PRB7 float,
	PRB8 float,
	PRB9 float,
	PRB10 float,
	PRB11 float,
	PRB12 float,
	PRB13 float,
	PRB14 float,
	PRB15 float,
	PRB16 float,
	PRB17 float,
	PRB18 float,
	PRB19 float,
	PRB20 float,
	PRB21 float,
	PRB22 float,
	PRB23 float,
	PRB24 float,
	PRB25 float,
	PRB26 float,
	PRB27 float,
	PRB28 float,
	PRB29 float,
	PRB30 float,
	PRB31 float,
	PRB32 float,
	PRB33 float,
	PRB34 float,
	PRB35 float,
	PRB36 float,
	PRB37 float,
	PRB38 float,
	PRB39 float,
	PRB40 float,
	PRB41 float,
	PRB42 float,
	PRB43 float,
	PRB44 float,
	PRB45 float,
	PRB46 float,
	PRB47 float,
	PRB48 float,
	PRB49 float,
	PRB50 float,
	PRB51 float,
	PRB52 float,
	PRB53 float,
	PRB54 float,
	PRB55 float,
	PRB56 float,
	PRB57 float,
	PRB58 float,
	PRB59 float,
	PRB60 float,
	PRB61 float,
	PRB62 float,
	PRB63 float,
	PRB64 float,
	PRB65 float,
	PRB66 float,
	PRB67 float,
	PRB68 float,
	PRB69 float,
	PRB70 float,
	PRB71 float,
	PRB72 float,
	PRB73 float,
	PRB74 float,
	PRB75 float,
	PRB76 float,
	PRB77 float,
	PRB78 float,
	PRB79 float,
	PRB80 float,
	PRB81 float,
	PRB82 float,
	PRB83 float,
	PRB84 float,
	PRB85 float,
	PRB86 float,
	PRB87 float,
	PRB88 float,
	PRB89 float,
	PRB90 float,
	PRB91 float,
	PRB92 float,
	PRB93 float,
	PRB94 float,
	PRB95 float,
	PRB96 float,
	PRB97 float,
	PRB98 float,
	PRB99 float,
	primary key(startTime,cell)
)



create table tbC2I3(
	A_sector_id nvarchar(50),
	B_sector_id nvarchar(50),
	C_sector_id nvarchar(50)
)
CREATE NONCLUSTERED INDEX IX_tbAdjCell ON tbAdjCell (S_EARFCN)--创建非聚集索引
go
