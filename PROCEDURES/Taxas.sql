CREATE OR ALTER PROCEDURE [dbo].[SP_ListarTaxas]
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Taxas.sql
		Objetivo..............: Listar todas as taxas registradas
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: DECLARE @Dat_ini DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarTaxas]

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		SELECT	Id,
				Nome
			FROM [dbo].[Taxa] WITH(NOLOCK)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirTaxa]
	@Id TINYINT,
	@Nome VARCHAR(50)
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Taxas.sql
		Objetivo..............: Inserir uma nova taxa
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: BEGIN TRAN
									DECLARE @Dat_ini DATETIME = GETDATE()

									EXEC [dbo].[SP_InserirTaxa] 3, IOF
									EXEC [dbo].[SP_ListarTaxas]

									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		--Conferir se a taxa já existe
		IF EXISTS(SELECT TOP 1 1
					FROM [dbo].[Taxa]
					WHERE Nome = @Nome)
			BEGIN
				RAISERROR('Essa taxa já existe dentro do banco', 16, 1)
				RETURN
				
			END
		--Conferir se o ID já existe
		IF EXISTS(SELECT TOP 1 1
					FROM [dbo].[Taxa]
					WHERE Id = Id)
			BEGIN
				RAISERROR('Esse ID já existe dentro do banco', 16, 1)
				RETURN
			END
		--Inserir a taxa
		INSERT INTO	[dbo].[Taxa]	(Id,
									Nome
									)
							VALUES	(@Id,
									@Nome
									)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirTaxa]
	@Id TINYINT,
	@Nome VARCHAR(50)
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Taxas.sql
		Objetivo..............: Excluir uma taxa
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: BEGIN TRAN
									DECLARE @Dat_ini DATETIME = GETDATE()

									EXEC [dbo].[SP_ExcluirTaxa] 2, IOF
									EXEC [dbo].[SP_ListarTaxas]

									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1
					FROM [dbo].[Taxa]
					WHERE Nome = @Nome)
			BEGIN
				RAISERROR('Essa taxa não existe dentro do banco', 16, 1)
				RETURN
				
			END
		IF NOT EXISTS(SELECT TOP 1 1
					FROM [dbo].[Taxa]
					WHERE Id = Id)
			BEGIN
				RAISERROR('Esse ID não existe dentro do banco', 16, 1)
				RETURN
				
			END
		DELETE FROM	[dbo].[Taxa]
			WHERE	Id = ISNULL(@Id, NULL)
					OR Nome = ISNULL(@Nome, NULL)
	END
GO