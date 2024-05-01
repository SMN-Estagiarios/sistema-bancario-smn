CREATE OR ALTER PROCEDURE [dbo].[SP_ListarIndices]
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Indices.sql
		Objetivo..............: Listar todos os índices registrados
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
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
		Documentação
		Arquivo Fonte.........:	Indices.sql
		Objetivo..............: Listar todos os períodos de índices registrados
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
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