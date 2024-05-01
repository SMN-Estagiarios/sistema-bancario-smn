CREATE OR ALTER PROCEDURE [dbo].[SP_ListarIndices]
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Indices.sql
		Objetivo..............: Listar todos os �ndices registrados
		Autor.................: Odlavir Florentino, Jo�o Victor, Rafael Maur�cio
		Data..................: 01/05/2024
		Ex....................: DECLARE @Dat_ini DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarIndices]

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		SELECT	Id,
				Nome
			FROM [dbo].[Indice] WITH(NOLOCK)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarPeriodosIndices]
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Indices.sql
		Objetivo..............: Listar todos os per�odos de �ndices registrados
		Autor.................: Odlavir Florentino, Jo�o Victor, Rafael Maur�cio
		Data..................: 01/05/2024
		Ex....................: DECLARE @Dat_ini DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarPeriodosIndices]

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		SELECT	Id,
				Nome
			FROM [dbo].[PeriodoIndice] WITH(NOLOCK)
	END
GO