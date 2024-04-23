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

                                    SELECT  @Ret AS Retorno,
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/


    BEGIN
       
            SELECT  t.Id,
                    t.Nome,
                    pt.Valor,
                    pt.Taxa
                FROM [dbo].[Tarifas] t WITH(NOLOCK)
					INNER JOIN [dbo].[PrecoTarifas] pt WITH(NOLOCK)
						ON pt.IdTarifa = t.Id
    END		
GO