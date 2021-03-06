USE [Northwind]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	==================================================================
	Description
		後台 - 記事本 - 新增
	==================================================================
	Result
		0: 正常
		1: 未知錯誤
	==================================================================
	Example
		DECLARE @ResultMessage		NVARCHAR(MAX)	= N''
				, @Result			INT				= 0
		EXEC [Northwind].dbo.Note_Add
			@Title					= N'記事本標題20字'
			, @Content				= N'記事本內容200字'
			, @Status				= 1
			, @ResultMessage		= @ResultMessage OUT
			, @Result				= @Result OUT
		SELECT @Result, @ResultMessage
					
*/
CREATE PROCEDURE [dbo].[Note_Add]
@Title					NVARCHAR(20)				-- 記事本標題
, @Content				NVARCHAR(200)				-- 記事本內容
, @Status				SMALLINT					-- 有效無效，1:有效 0:無效
, @ResultMessage		NVARCHAR(MAX)	= N'' OUT	-- 回傳錯誤訊息，若成功執行則為空值
, @Result				INT				= 0   OUT	-- 回傳錯誤代碼
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		SET @ResultMessage = N'';
		SET @Result = 0;
		
		IF ((LEN(@Title) = 0)
			OR (LEN(@Content) = 0)
			)
		BEGIN
			-- 資料不可空白
			SET @ResultMessage = 'Data can not be empty';
			SET @Result = 34;
			RETURN ;
		END
 
		--===================================================
		-- 新增 記事本
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
			SELECT Note_ID
				,  1			-- 新增
				, N''
				, N'Title=' + @Title
				 +N'<br />@Content=' + @Content
				 +N'<br />Status=' + CAST(@Status AS VARCHAR)
				, @TimeNow
			FROM(
					INSERT INTO　[Northwind].dbo.Note
					(
						Title				-- 標題
						, Content			-- 記事本內容
						, Status			-- 有效無效
						, CreateDate		-- 建立時間
						, ModifyDate		-- 更新時間
					)	OUTPUT
							INSERTED.Note_ID	-- 記事本編號
					VALUES
					(
						@Title				-- 標題
						, @Content			-- 記事本內容
						, @Status			-- 有效無效
						, @TimeNow			-- 建立時間
						, @TimeNow			-- 更新時間
					)
				) n

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
