USE [Northwind]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	==================================================================
	Description
		後台 - 記事本 - 取得資料
	==================================================================
	Result
		0: 正常
		1: 未知錯誤
	==================================================================
	Example
		DECLARE @ResultMessage		NVARCHAR(MAX)	= N''
				, @Result			INT				= 0
		EXEC [Northwind].dbo.Note_Get
			@Note_ID			= 1
			, @ResultMessage	= @ResultMessage OUT
			, @Result			= @Result OUT
		SELECT @Result, @ResultMessage
					
*/
CREATE PROCEDURE [dbo].[Note_Get]
@Note_ID			INT							-- 記事本編號
, @ResultMessage	NVARCHAR(MAX)	= N'' OUT	-- 回傳錯誤訊息，若成功執行則為空值
, @Result			INT				= 0   OUT	-- 回傳錯誤代碼
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		SET @ResultMessage = N'';
		SET @Result = 0;

		-- 判斷資料是否存在
		IF NOT EXISTS (SELECT 1 FROM [Northwind].dbo.Note WITH(NOLOCK) WHERE Note_ID = @Note_ID)
		BEGIN
			-- 資料不存在
			SET @ResultMessage = 'Data not exist';
			SET @Result = 12;
			RETURN;
		END

		--===================================================
		-- 取得單一 記事本
		--===================================================
		SELECT Note_ID			-- 記事本編號
				, Content		-- 記事本名稱(中)
				, Status		-- 有效無效，1:有效 0:無效
		FROM [Northwind].dbo.Note WITH(NOLOCK)
		WHERE Note_ID = @Note_ID

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
