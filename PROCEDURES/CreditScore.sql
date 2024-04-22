USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ListarCreditSCore] 
    AS  
        /*
            Documentação
            Arquivo Fonte.....: CreditScore.sql
            Objetivo..........: Listar tabela domínio CreditScore
            Autor.............: Membros formação estágio 2023.2
            Data..............: 18/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE();

                                    EXEC [dbo].[SP_ListarCreditSCore] 

                                    SELECT  DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/


    BEGIN
		SELECT  Id,
				Nome,
				Faixa,
				Aliquota
			FROM [dbo].[CreditScore] WITH(NOLOCK)
    END