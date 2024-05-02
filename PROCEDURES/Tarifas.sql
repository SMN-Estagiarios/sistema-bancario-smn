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
				
			-- Listando todas as tarifas
            SELECT	T.Id,
					T.Nome
				FROM [dbo].[Tarifas] T WITH(NOLOCK)
					
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

                                    EXEC @Ret = [dbo].[SP_InserirValorTarifa] 1, 50.00, '2024-05-30'

									SELECT * FROM PrecoTarifas

                                    SELECT  @Ret Retorno,
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN

			Retornos..........:	
						0 - Registro inserido.
						1 - Data inválida: Não é possível a data inicial ser menor que a atual.
						2 - Falha na inclusão do registro.
		*/

    BEGIN
		-- Impedir data inicial anterior a hoje
		IF DATEDIFF(DAY, @DataInicial, GETDATE()) > 0
			RETURN 1

		-- Inserir novo valor com validade inicial para uma tarifa
		INSERT INTO [dbo].[PrecoTarifas] (Id_Tarifa, Valor, DataInicial)
			VALUES	(@IdTarifa, @Valor, @DataInicial)
	
		-- Verificando se houve erro ao inserir novo registro
		IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
			BEGIN
				RETURN 2
			END
			
		RETURN 0
    END		
GO