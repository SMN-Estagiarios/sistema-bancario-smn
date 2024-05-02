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

                                    EXEC @Ret = [dbo].[SP_InserirValorTaxa] 1, 0.04, '2024-04-30'

									SELECT * FROM ValorTaxa

                                    SELECT  @Ret Retorno,
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN

			Retornos..........:	
						0 - Data inválida: Não é possível a data inicial ser menor que a atual.
						1 - Registro inserido.
		*/


    BEGIN
       
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 0

		INSERT INTO [dbo].[ValorTaxa] (Id_Taxa, Aliquota, DataInicial) VALUES
										 (@IdTaxa, @Aliquota, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
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
            Objetivo..........: Inserir novo valor taxa do cartão com data inicial maior ou igual a data atual
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
						0 - Data inválida: Não é possível a data inicial ser menor que a atual.
						1 - Registro inserido.
		*/


    BEGIN
       
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 0

		INSERT INTO [dbo].[ValorTaxaCartao] (Id_TaxaCartao, Aliquota, DataInicial) VALUES
										 (@IdTaxaCartao, @Aliquota, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
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
            Objetivo..........: Inserir novo valor taxa do cartão com data inicial maior ou igual a data atual
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
						0 - Data inválida: Não é possível a data inicial ser menor que a atual.
						1 - Registro inserido.
		*/


    BEGIN
       
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 0

		INSERT INTO [dbo].[ValorTaxaEmprestimo] (Id_TaxaEmprestimo, Id_CreditScore, Aliquota, DataInicial) VALUES
												(@IdTaxaEmprestimo, @IdCreditScore, @Aliquota, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
		IF @ERRO <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', ao inserir nova taxa com data inicial'
					RAISERROR(@MSG, 16, 1)
			END
			
		RETURN 1
        		
    END		
GO