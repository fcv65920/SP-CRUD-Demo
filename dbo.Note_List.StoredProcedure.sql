USE [Northwind]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	==================================================================
	Description
		後台 - 記事本 - 列表
	==================================================================
	Step
		排序Sort Asc
	==================================================================
	Result
		0: 正常
		1: 未知錯誤
	==================================================================
	Example
		DECLARE @ResultMessage		NVARCHAR(MAX)	= N''
				, @Result			INT				= 0
				, @TotalCount		INT				= 0
		EXEC [Northwind].dbo.Note_List
			@PageIndex			= 1
			, @PageSize			= 10
			, @Start_Date		= NULL
			, @End_Date			= NULL
			, @TotalCount		= @TotalCount OUT
			, @ResultMessage	= @ResultMessage OUT
			, @Result			= @Result OUT
		SELECT @Result, @ResultMessage, @TotalCount
					
*/
CREATE PROCEDURE [dbo].[Note_List]
@PageIndex			INT				= 1				-- 第幾頁
, @PageSize			INT				= 20			-- 每頁幾筆資料
, @Start_Date		DATETIME		= NULL			-- 起始時間
, @End_Date			DATETIME		= NULL			-- 結束時間
, @TotalCount		INT				= 0	  OUT		-- 總筆數
, @ResultMessage	NVARCHAR(MAX)	= N'' OUT		-- 回傳錯誤訊息，若成功執行則為空值
, @Result			INT				= 0   OUT		-- 回傳錯誤代碼
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		SET @ResultMessage = N'';
		SET @Result = 0;
		SET @TotalCount = 0

		-- 判斷時間(預設一月)
		IF(@Start_Date IS NULL AND @End_Date IS NULL)
		BEGIN
			SET @Start_Date = DATEADD(dd,DATEDIFF(d,0,DATEADD(mm,-1,GETDATE())),0)
			SET @End_Date =  CONCAT(CONVERT(CHAR(19), DATEADD(ss,-1,DATEADD(dd,DATEDIFF(d,0,GETDATE())+1,0)), 121), '.997')
		END
		-- 判斷時間(結束時間-1月)
		ELSE IF (@Start_Date IS NULL)
		BEGIN
			SET @Start_Date = DATEADD(dd,DATEDIFF(d,0,DATEADD(mm,-1,@End_Date)),0)
			SET @End_Date = CONCAT(CONVERT(CHAR(19), DATEADD(ss,-1,DATEADD(dd,DATEDIFF(d,0,@End_Date)+1,0)), 121), '.997')
		END
		-- 判斷時間(開始時間+1月)
		ELSE IF (@End_Date IS NULL)
		BEGIN
			SET @Start_Date = DATEADD(dd,DATEDIFF(dd,0,@Start_Date),0)
			SET @End_Date =  CONCAT(CONVERT(CHAR(10),DATEADD(mm,1,DATEADD(dd,DATEDIFF(d,0,@Start_Date),0)), 121), ' 23:59:59.997')
		END

		CREATE	TABLE	#NoteList
		(
			Note_ID			INT				-- 記事本編號
			, Title			NVARCHAR(20)
			, Content		NVARCHAR(200)	-- 記事本名稱(中)
			, Status			SMALLINT		-- 有效無效，1:有效 0:無效 -1:全部
	
			, CreateDate		DATETIME		-- 建立時間
			, ModifyDate		DATETIME		-- 更新時間
		)

		--===================================================
		-- 取得 記事本 列表
		--===================================================
		-- 取得記事本資訊
		INSERT INTO #NoteList
		(
			Note_ID				-- 記事本編號
			, Title			-- 記事本
			, Content			-- 記事本名稱(中)
			, Status				-- 有效無效，1:有效 0:無效 -1:全部
			, CreateDate			-- 建立時間
			, ModifyDate			-- 更新時間
		)
		SELECT n.Note_ID		-- 記事本編號
				, n.Title		-- 記事本
				, n.Content		-- 記事本名稱(中)
				, n.Status		-- 有效無效，1:有效 0:無效 -1:全部
				, n.CreateDate		-- 建立時間
				, n.ModifyDate		-- 更新時間
		FROM [Northwind].dbo.Note n WITH(NOLOCK)				-- 記事本
	WHERE ModifyDate BETWEEN @Start_Date AND @End_Date
		-- 	取得總筆數
		SELECT @TotalCount = @@ROWCOUNT

		-- 查詢資料
		SELECT 
			Note_ID				-- 記事本編號
			, Title
			, Content			-- 記事本名稱(中)
			, Status				-- 有效無效，1:有效 0:無效 -1:全部
			, CreateDate			-- 建立時間
			, ModifyDate			-- 更新時間
			FROM #NoteList
			ORDER BY Note_ID Asc
			OFFSET (@PageIndex-1)*@PageSize ROWS
			FETCH NEXT @PageSize ROWS ONLY

		DROP TABLE #NoteList

	END TRY
	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
		BEGIN
			ROLLBACK TRAN
		END

		SELECT
			@ResultMessage = @ResultMessage
			+ 'ErrorNumber: ' + CAST(ERROR_NUMBER() AS VARCHAR) + ', '
			+ 'ErrorLine: ' + CAST(ERROR_LINE() AS VARCHAR) + ', '
			+ 'ErrorMsg: ' + ERROR_MESSAGE()
		SET @Result = 1;

	END CATCH
	
END
GO
