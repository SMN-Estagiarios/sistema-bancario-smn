USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarTaxas]
	AS
	/*
		Documenta��o
		Arquivo Fonte.........:	Taxas.sql
		Objetivo..............: Listar todas as taxas registradas
		Autor.................: Odlavir Florentino, Jo�o Victor, Rafael Maur�cio
		Data..................: 01/05/2024
		Ex....................: BEGIN TRAN
		
								DECLARE @Dat_ini DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarTaxas]

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao

								ROLLBACK TRAN
	*/
	BEGIN

		-- Listando todas as taxas
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
		Autor.................: Odlavir Florentino, Jo�o Victor, Rafael Maur�cio
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
		Documenta��o
		Arquivo Fonte.........:	Taxas.sql
		Objetivo..............: Excluir uma taxa
		Autor.................: Odlavir Florentino, Jo�o Victor, Rafael Maur�cio
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
				RAISERROR('Essa taxa n�o existe dentro do banco', 16, 1)
				RETURN
				
			END
		IF NOT EXISTS(SELECT TOP 1 1
					FROM [dbo].[Taxa]
					WHERE Id = Id)
			BEGIN
				RAISERROR('Esse ID n�o existe dentro do banco', 16, 1)
				RETURN
				
			END

		EXEC [dbo].[SP_ExcluirValorTaxas] NULL, @Id

		DELETE FROM	[dbo].[Taxa]
			WHERE	Id = ISNULL(@Id, NULL)
					OR Nome = ISNULL(@Nome, NULL)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirValorTaxa]
		@IdTaxa INT,
		@Aliquota DECIMAL(6,5),
		@DataInicial DATE
    AS  
        /*
            Documentação
            Arquivo Fonte.....: Taxas.sql
            Objetivo..........: Inserir novo valor taxa com data inicial maior ou igual a data atual
            Autor.............: Gustavo Targino, Danyel Targino, Thays Carvalho
            Data..............: 30/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE(),
											@Ret INT;

									SELECT * FROM ValorTaxa

                                    EXEC @Ret = [dbo].[SP_InserirValorTaxa] 1, 0.04, '2024-05-30'

									SELECT * FROM ValorTaxa

                                    SELECT  @Ret Retorno,
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN

			Retornos..........:	
						0 - Data inv�lida: N�o � poss�vel a data inicial ser menor que a atual.
						1 - Registro inserido.
		*/


    BEGIN
       
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 0

		-- Inserir nova alíquota com validade inicial para uma taxa
		INSERT INTO [dbo].[ValorTaxa] (Id_Taxa, Aliquota, DataInicial) VALUES
										 (@IdTaxa, @Aliquota, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
		-- Verificando se houve erro ao inserir novo registro
		IF @ERRO <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', ao inserir nova taxa com data inicial'
					RAISERROR(@MSG, 16, 1)
			END
			
		RETURN 1
        		
    END		
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirValorTaxaCartao]
		@IdTaxaCartao INT,
		@Aliquota DECIMAL(6,5),
		@DataInicial DATE
    AS  
        /*
            Documentação
            Arquivo Fonte.....: Taxas.sql
            Objetivo..........: Inserir novo valor taxa do cart�o com data inicial maior ou igual a data atual
            Autor.............: Gustavo Targino, Danyel Targino, Thays Carvalho
            Data..............: 30/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE(),
											@Ret INT;

									SELECT * FROM ValorTaxaCartao

                                    EXEC @Ret = [dbo].[SP_InserirValorTaxaCartao] 1, 0.04, '2024-04-30'

									SELECT * FROM ValorTaxaCartao

                                    SELECT  @Ret Retorno,
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN

			Retornos..........:	
						0 - Data inv�lida: N�o � poss�vel a data inicial ser menor que a atual.
						1 - Registro inserido.
		*/


    BEGIN
       
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 0

		-- Inserir nova alíquota com validade inicial para uma taxa de cartão
		INSERT INTO [dbo].[ValorTaxaCartao] (Id_TaxaCartao, Aliquota, DataInicial) VALUES
										 (@IdTaxaCartao, @Aliquota, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
		-- Verificando se houve erro ao inserir novo registro
		IF @ERRO <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', ao inserir nova taxa com data inicial'
					RAISERROR(@MSG, 16, 1)
			END
			
		RETURN 1
        		
    END		
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_InserirValorTaxaEmprestimo]
		@IdTaxaEmprestimo INT,
		@IdCreditScore TINYINT,
		@Aliquota DECIMAL(6,5),
		@DataInicial DATE
    AS  
        /*
            Documentação
            Arquivo Fonte.....: Taxas.sql
            Objetivo..........: Inserir novo valor taxa do cart�o com data inicial maior ou igual a data atual
            Autor.............: Gustavo Targino, Danyel Targino, Thays Carvalho
            Data..............: 30/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE(),
											@Ret INT;

									SELECT * FROM ValorTaxaEmprestimo

                                    EXEC @Ret = [dbo].[SP_InserirValorTaxaEmprestimo] 2, 1, 0.10, '2024-04-30'

									SELECT * FROM ValorTaxaEmprestimo

                                    SELECT  @Ret Retorno,
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN

			Retornos..........:	
						0 - Data inv�lida: N�o � poss�vel a data inicial ser menor que a atual.
						1 - Registro inserido.
		*/


    BEGIN
       
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 0

		-- Inserir nova alíquota com validade inicial para uma taxa de empréstimo
		INSERT INTO [dbo].[ValorTaxaEmprestimo] (Id_TaxaEmprestimo, Id_CreditScore, Aliquota, DataInicial) VALUES
												(@IdTaxaEmprestimo, @IdCreditScore, @Aliquota, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
		-- Verificando se houve erro ao inserir novo registro
		IF @ERRO <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', ao inserir nova taxa com data inicial'
					RAISERROR(@MSG, 16, 1)
			END
			
		RETURN 1
        		
    END		
GO