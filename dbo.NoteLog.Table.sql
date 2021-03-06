USE [Northwind]
GO
/****** Object:  Table [dbo].[NoteLog]    Script Date: 2020/3/20 下午 01:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoteLog](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[Note_ID] [int] NOT NULL,
	[Type] [int] NOT NULL,
	[OldData] [varchar](1000) NOT NULL,
	[NewData] [varchar](1000) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_NoteLog] PRIMARY KEY CLUSTERED 
(
	[LogID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoteLog] ADD  CONSTRAINT [DF_NoteLog_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'紀錄編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog', @level2type=N'COLUMN',@level2name=N'LogID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'記事本編號' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog', @level2type=N'COLUMN',@level2name=N'Note_ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'動作種類 1:新增 2:修改 3:刪除' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'舊資料' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog', @level2type=N'COLUMN',@level2name=N'OldData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'新資料' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog', @level2type=N'COLUMN',@level2name=N'NewData'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'建立時間' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DESCRIPTION', @value=N'記事本紀錄' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'NoteLog'
GO
