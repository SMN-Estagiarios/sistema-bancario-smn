USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ListarSaldoNegativo]()
	 RETURNS @SaldoNegativo TABLE(
									Id INT NOT NULL, 
									Vlr_SldInicial DECIMAL(15,2) NOT NULL, 
									Vlr_Credito DECIMAL(15,2) NOT NULL, 
									Vlr_Debito DECIMAL(15,2)  NOT NULL, 
									Saldo Decimal(15,2) NOT NULL
								 )
			AS 
           /* 
			Documentação
			Arquivo Fonte.....: FNC_ListarSaldoNegativo.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta especifica
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			ObjetivoAlt.......: N/A
			AutorAlt..........: N/A
			DataAlt...........: N/A
			Ex................:	DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;
			
								DECLARE @Dat_ini DATETIME = GETDATE()
								SELECT FLS.Id,
									   FLS.Vlr_SldInicial,
									   FLS.Vlr_Credito, 
									   FLS.Vlr_Debito,
									   FLS.Saldo,
									   DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao
									FROM [dbo].[FNC_ListarSaldoNegativo]() FLS	 
            */
	BEGIN	 
		INSERT INTO @SaldoNegativo
			SELECT  x.Id,
					x.Vlr_SldInicial, 
					x.Vlr_Credito,
					x.Vlr_Debito,
					x.Saldo
				FROM (
						SELECT	C.Id,
								C.Vlr_SldInicial,
								C.Vlr_Credito,
								C.Vlr_Debito,
								[dbo].[Func_CalculaSaldoAtual](C.Id, C.Vlr_SldInicial, C.Vlr_Credito, Vlr_Debito) AS Saldo
							FROM [dbo].[Contas] C WITH(NOLOCK)) x
				WHERE x.Saldo <0
		RETURN 
	END
GO
