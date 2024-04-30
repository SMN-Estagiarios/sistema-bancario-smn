USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarTarifas] 
    AS  
        /*
            Documentação
            Arquivo Fonte.....: Tarifas.sql
            Objetivo..........: Listar tabela domínio Tarifas
            Autor.............: Membros formação estágio 2023.2
            Data..............: 18/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE();

                                    EXEC [dbo].[SP_ListarTarifas]

                                    SELECT 
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/


    BEGIN
       
		DECLARE @DataAtual DATE = GETDATE()

            SELECT	T.Nome,
					P.Valor,
					P.DataInicial
				FROM [dbo].[Tarifas] T WITH(NOLOCK)
					INNER JOIN [dbo].[PrecoTarifas] P WITH(NOLOCK)
						ON P.Id_Tarifa = T.Id
				ORDER BY P.DataInicial DESC
				
    END		
GO	


CREATE OR ALTER PROCEDURE [dbo].[SP_InserirValorTarifa]
		@IdTarifa INT,
		@Valor DECIMAL(4,2),
		@DataInicial DATE
    AS  
        /*
            Documentação
            Arquivo Fonte.....: Tarifas.sql
            Objetivo..........: Inserir novo valor tarifa com data inicial maior ou igual a data atual
            Autor.............: Gustavo Targino, Danyel Targino, Thays Carvalho
            Data..............: 30/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE(),
											@Ret INT;

									SELECT * FROM PrecoTarifas

                                    EXEC @Ret = [dbo].[SP_InserirValorTarifa] 1, 50.00, '2024-04-30'

									SELECT * FROM PrecoTarifas

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

		INSERT INTO [dbo].[PrecoTarifas] (Id_Tarifa, Valor, DataInicial) VALUES
										 (@IdTarifa, @Valor, @DataInicial)
	
		-- Checagem de erro
		DECLARE @MSG VARCHAR(100),
				@ERRO INT = @@ERROR
			
		IF @ERRO <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', ao inserir nova tarifa com data inicial'
					RAISERROR(@MSG, 16, 1)
			END
			
		RETURN 1
        		
    END		
GO