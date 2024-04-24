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
					P.Taxa,
					P.Valor,
					P.DataInicial
				FROM [dbo].[Tarifas] T WITH(NOLOCK)
					INNER JOIN [dbo].[PrecoTarifas] P WITH(NOLOCK)
						ON P.IdTarifa = T.Id
				ORDER BY P.DataInicial DESC
				
    END		
GO	