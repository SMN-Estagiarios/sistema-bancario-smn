CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario]
    AS
		/*
			Documenta��o
			Arquivo Fonte.....: SPJOB_AtualizarCreditScore.sql
			Objetivo..........: Atualizar o CreditScore das Contas
			Autor.............: Gustavo Targino, Jo o Victor Maia, Gabriel Damiani
			Data..............: 16/04/2024
			EX................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									SELECT * 
										FROM SaldoDiario
										ORDER BY Id_Conta
									TRUNCATE TABLE SaldoDiario

									SELECT * FROM SaldoDiario

									EXEC [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario]
									
									SELECT * 
										FROM SaldoDiario
										ORDER  BY Id_COnta, Dat_Saldo
									SELECT * 
										FROM Lancamentos
										ORDER BY Dat_LAncamento
    
								ROLLBACK TRAN
		*/
    BEGIN

				DECLARE @DataInicio DATE = DATEADD(MONTH, 0, GETDATE()),
						@DataFim DATE

				SET @DataInicio = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, 0, GETDATE())), 01)
				SET @DataFim = EOMONTH(@DataInicio) 

				CREATE TABLE #TabelaData(
											DataSaldo DATE
										)
				
				--Populando tabela de dias
				WHILE @DataInicio <= @DataFim
					BEGIN
						INSERT INTO #TabelaData(DataSaldo) VALUES 
											   (@DataInicio)
						SET @DataInicio = DATEADD(DAY, 1, @DataInicio)
					END;

			WITH CalculoCreditoDebito AS (
							SELECT ISNULL(SUM(CASE WHEN Tipo_Operacao = 'C' THEN Vlr_Lanc ELSE 0 END), 0) AS Valor_Credito,
								   ISNULL(SUM(CASE WHEN Tipo_Operacao = 'D' THEN Vlr_Lanc ELSE 0 END), 0) AS Valor_Debito,
								   td.DataSaldo,
								   C.Id AS Id_Conta
								FROM #TabelaData td
								CROSS JOIN [dbo].[Contas] C WITH(NOLOCK)
								LEFT JOIN [dbo].[Lancamentos] la WITH(NOLOCK)
										ON DATEDIFF(DAY, td.DataSaldo, la.Dat_Lancamento) = 0 
										AND t.Id_Conta = la.Id_Conta
								GROUP BY td.DataSaldo, COALESCE(la.Id_Conta, t.Id_Conta)
										), 
			  CalculoSaldo AS (
							SELECT Credito,
								   Debito,
								   DataSaldo,
								   Id_Conta,
								   ISNULL(LAG(Saldo_Final, 1, 0) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo), 0) AS Saldo_Inicial,
								   Saldo_Final
							FROM (
								SELECT Valor_Credito Credito,
									   Valor_Debito Debito,
									   DataSaldo DataSaldo,
									   Id_Conta Id_Conta,
									   SUM(Valor_Credito - Valor_Debito) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo) AS Saldo_Final
								FROM CalculoCreditoDebito
								 )x
							 )    
							INSERT INTO [dbo].[SaldoDiario] (Vlr_Credito, Vlr_Debito, Vlr_SldFinal, Vlr_SldInicial, Dat_Saldo, Id_Conta)
								SELECT CS.Credito,
									   CS.Debito,
									   CS.Saldo_Final,
									   CS.Saldo_Inicial,
									   CS.DataSaldo,
										CS.Id_Conta
								FROM CalculoSaldo CS;
END




