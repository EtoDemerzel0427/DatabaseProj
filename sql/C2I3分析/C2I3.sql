USE [TD_LTE]
GO
/****** Object:  StoredProcedure [dbo].[C2I2]    Script Date: 2019/7/10 9:33:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[C2I3]
@X FLOAT
AS
BEGIN

	truncate table temp
	truncate table tbC2I3
	insert into temp  select InterferingSector,ServingSector from tbC2Inew where PrbABS6 > @x
	insert into tbC2I3 
	select distinct A.NCELL as CELL1,A.SCELL as CELL2,B.NCELL as CELL3 from temp A,temp B,temp C
	where 
	(A.SCELL=B.SCELL and A.NCELL=C.SCELL and B.NCELL=C.NCELL) or
	(A.NCELL=B.SCELL and A.SCELL=C.SCELL and B.NCELL=C.NCELL) or
	(A.SCELL=B.SCELL and A.NCELL=C.NCELL and B.NCELL=C.SCELL) or
	(A.NCELL=B.SCELL and A.SCELL=C.NCELL and B.NCELL=C.SCELL) 
	union
	select distinct A.NCELL as CELL1,A.SCELL as CELL2,B.SCELL as CELL3 from temp A,temp B,temp C
	where 
	(A.SCELL=B.NCELL and A.NCELL=C.SCELL and B.SCELL=C.NCELL) or
	(A.NCELL=B.NCELL and A.SCELL=C.SCELL and B.SCELL=C.NCELL) or
	(A.SCELL=B.NCELL and A.NCELL=C.NCELL and B.SCELL=C.SCELL) or
	(A.NCELL=B.NCELL and A.SCELL=C.NCELL and B.SCELL=C.SCELL)
	
END
