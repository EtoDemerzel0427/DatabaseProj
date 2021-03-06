USE [TD_LTE]
GO
/****** Object:  Trigger [dbo].[C2I3_trigger]    Script Date: 2019/7/11 22:46:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER trigger [dbo].[C2I3_trigger] 
on [dbo].[tbC2I3]
instead of insert
as 
begin 
    --定义变量用于传值
    DECLARE @Cell1 VARCHAR(50)
    DECLARE @Cell2 VARCHAR(50)
    DECLARE @Cell3 VARCHAR(50)
    --创建游标
    DECLARE YB CURSOR FOR    
    SELECT [A_sector_id],[B_sector_id],[C_sector_id]FROM INSERTED--游标读取行信息
    OPEN YB --打开游标
    FETCH NEXT FROM YB INTO @Cell1,@Cell2,@Cell3--把游标读取到的第一行信息赋值到变量中
    WHILE @@FETCH_STATUS = 0 --[代表是否读取到数据行]0操作成功，-1 FETCH 语句失败或此行不在结果集中，-2 被提取的行不存在 
    BEGIN

        --判断表中是否存在该订单
        IF NOT EXISTS(SELECT 1 FROM tbC2I3 WHERE A_sector_id=@Cell1 or B_sector_id=@Cell1 or C_sector_id=@Cell1)  --判断CELL1是否已存在于tbC2I3中
        BEGIN
			insert into tbC2I3(A_sector_id,B_sector_id,C_sector_id) values (@Cell1,@Cell2,@Cell3)
        END
		else			--存在，则得考虑去重
		begin
			--找出含有@Cell1的纪录

			insert into tbC2I3(A_sector_id,B_sector_id,C_sector_id) values (@Cell1,@Cell2,@Cell3)
			delete top(1) from tbC2I3 where A_sector_id in(
				select A_sector_id from tbC2I3 where (A_sector_id=@Cell1 or B_sector_id=@Cell1 or C_sector_id=@Cell1) and (A_sector_id=@Cell2 or B_sector_id=@Cell2 or C_sector_id=@Cell2) 
				and (A_sector_id=@Cell3 or B_sector_id=@Cell3 or C_sector_id=@Cell3)	
				group by A_sector_id
				)
			--)
		end
	
	FETCH NEXT FROM YB INTO @Cell1,@Cell2,@Cell3
    END
    CLOSE YB --关闭游标 
    DEALLOCATE YB --释放游标    
end

