USE SistemaBancario
GO
CREATE OR ALTER FUNCTION [dbo].[Func_ListaSaldoNegativo]()
	 RETURNS @SaldoNegativo TABLE (
									Id INT NOT NULL, 
									Vlr_SldInicial DECIMAL(15,2) NOT NULL, 
									Vlr_Credito DECIMAL(15,2) NOT NULL, 
									Vlr_Debito DECIMAL(15,2)  NOT NULL, 
									Saldo Decimal(15,2) NOT NULL
								 )
			AS 
           /* 
			Documentação
			Arquivo Fonte.....: Func_ListaSaldoNegativo.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta específica
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			ObjetivoAlt.......: N/A
			AutorAlt..........: N/A
			DataAlt...........: N/A
			Ex................:    DBCC DROPCLEANBUFFERS;
								   DBCC FREEPROCCACHE;
			
									DECLARE @Dat_init DATETIME = GETDATE()
									SELECT FLS.Id,
										   FLS.Vlr_SldInicial,
										   FLS.Vlr_Credito, 
										   FLS.Vlr_Debito,
										   FLS.Saldo,
										   DATEDIFF(millisecond, @Dat_init, GETDATE()) AS EXECUÇÃO
										   FROM [dbo].[Func_ListaSaldoNegativo]() FLS	 
            */
	BEGIN	 
			
				INSERT INTO @SaldoNegativo
				SELECT x.Id,
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
							FROM [dbo].[Contas] C WITH(NOLOCK))x
							WHERE x.Saldo <0
		
	/*	WITH Cte_CalculaSaldoNegativo AS 
			(
						SELECT	C.Id,
								C.Id_Usuario,
								C.Vlr_SldInicial,
								C.Vlr_Credito,
								C.Vlr_Debito,
								[dbo].[Func_CalculaSaldoAtual](C.Id, C.Vlr_SldInicial, C.Vlr_Credito, Vlr_Debito) AS Saldo
							FROM [dbo].[Contas] C WITH(NOLOCK)
) INSERT INTO @SaldoNegativo
	SELECT    ct.Id,
			  Ct.Id_Usuario,
			  Ct.Vlr_SldInicial,
			  Ct.Vlr_Credito,
			  Ct.Vlr_Debito,
			  ct.Saldo
			FROM Cte_CalculaSaldoNegativo ct
			WHERE ct.Saldo <0*/
	
	RETURN 
	END
GO
