USE [Northwind]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	==================================================================
	Description
		後台 - 記事本 - 編輯
	==================================================================
	History
	==================================================================
	Step
	==================================================================
	Result
		0: 正常
		1: 未知錯誤
	==================================================================
	Example
		DECLARE @ResultMessage		NVARCHAR(MAX)	= N''
				, @Result			INT				= 0
		EXEC [Northwind].dbo.Note_Edit
			@Note_ID			= 1
			, @Content			= N'記事本內容修改'
			, @Status			= 1
			, @ResultMessage	= @ResultMessage OUT
			, @Result			= @Result OUT
		SELECT @Result, @ResultMessage
					
*/
CREATE PROCEDURE [dbo].[Note_Edit]
@Note_ID			INT							-- 記事本編號
, @Content			NVARCHAR(200)				-- 記事本內容
, @Status			SMALLINT					-- 有效無效，1:有效 0:無效
, @ResultMessage	NVARCHAR(MAX)	= N'' OUT	-- 回傳錯誤訊息，若成功執行則為空值
, @Result			INT				= 0   OUT	-- 回傳錯誤代碼
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		SET @ResultMessage = N'';
		SET @Result = 0;

		DECLARE
			@Old_Content				NVARCHAR(200)			-- (舊)記事本內容
			, @Old_Status				SMALLINT		= -1	-- (舊)有效無效，1:有效 0:無效，-1:資料不存在

			, @Old_ModifyDate			DATETIME				-- (舊)更新時間

		-- 取得(舊)記事本資訊
		SELECT 	@Old_Content			= Content				-- (舊)記事本內容
				, @Old_Status			= Status				-- (舊)有效無效，1:有效 0:無效，-1:資料不存在
				, @Old_ModifyDate		= ModifyDate			-- (舊)更新時間
		FROM [Northwind].dbo.Note WITH(NOLOCK) 
			WHERE Note_ID = @Note_ID


		-- 判斷資料是否存在
		IF (@Old_Status = -1)
		BEGIN
			-- 資料不存在
			SET @ResultMessage = 'Data not exist';
			SET @Result = 12;
			RETURN;
		END
		
		IF (LEN(@Content) = 0)
		
		BEGIN
			-- 資料不可空白
			SET @ResultMessage = 'Data can not be empty';
			SET @Result = 34;
			RETURN ;
		END

	
		

		-- 檢查資料是否相同
		IF (
				@Content	= @Old_Content		-- (舊)記事本內容
			AND	@Status		= @Old_Status			-- (舊)有效無效，1:有效 0:無效
			)
		BEGIN
			-- 資料一樣不變更任何資料
			SET @ResultMessage = 'The data is the same'
			SET @Result = 19
			RETURN;
		END

		--===================================================
		-- 編輯 記事本
		--===================================================
		DECLARE
			@TimeNow	DATETIME = GETDATE()	-- 當下時間

		BEGIN TRAN

			INSERT INTO [Northwind].dbo.NoteLog
			(
				Note_ID		-- 記事本編號
				, Type			-- 動作種類 1:新增 2:修改 3:刪除
				, OldData		-- 舊資料
				, NewData		-- 新資料
				, CreateDate	-- 建立時間
			)
			VALUES
			(
				@Note_ID
				, 2				-- 修改
				, N'Content=' + @Old_Content
				 +N'<br />ModifyDate=' + CAST(CONVERT(VARCHAR(23),@Old_ModifyDate,121) AS VARCHAR)
				, N'Content=' + @Content
				 +N'<br />Status=' + CAST(@Status AS VARCHAR)
				 +N'<br />ModifyDate=' + CAST(CONVERT(VARCHAR(23),@TimeNow,121) AS VARCHAR)
				, @TimeNow
			)

			UPDATE [Northwind].dbo.Note
			SET Content			= @Content			-- 記事本內容
				, Status		= @Status			-- 有效無效，1:有效 0:無效
				, ModifyDate	= @TimeNow			-- 更新時間
			WHERE Note_ID = @Note_ID

		COMMIT TRAN

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
