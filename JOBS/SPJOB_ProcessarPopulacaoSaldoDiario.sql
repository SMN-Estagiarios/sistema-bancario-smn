CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario]
    AS
		/*
			Documentação
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
								   COALESCE(la.Id_Conta, t.Id_Conta) AS Id_Conta
								FROM #TabelaData td
								CROSS JOIN (SELECT DISTINCT Id_Conta FROM Lancamentos) t
								LEFT JOIN Lancamentos la 
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




/*CalculoCreditoDebito:
Esta parte da consulta calcula o crédito e débito referentes a cada dia para cada conta.
ISNULL(SUM(CASE WHEN Tipo_Operacao = 'C' THEN Vlr_Lanc ELSE 0 END), 0) AS Valor_Credito: Calcula o crédito para cada dia, somando o valor dos lançamentos do tipo 'C' (crédito) na tabela de lançamentos (Lancamentos). Se não houver lançamentos de crédito, retorna 0.
ISNULL(SUM(CASE WHEN Tipo_Operacao = 'D' THEN Vlr_Lanc ELSE 0 END), 0) AS Valor_Debito: Calcula o débito para cada dia, somando o valor dos lançamentos do tipo 'D' (débito) na tabela de lançamentos (Lancamentos). Se não houver lançamentos de débito, retorna 0.
td.DataSaldo: Seleciona a data de saldo da tabela temporária #TabelaData.
COALESCE(la.Id_Conta, t.Id_Conta) AS Id_Conta: Define o ID da conta como o ID da conta da tabela de lançamentos (la.Id_Conta) se estiver presente, caso contrário, utiliza o ID da conta da subconsulta t.
LEFT JOIN Lancamentos la ...: Faz um join entre a tabela de lançamentos (Lancamentos) e a tabela de datas (#TabelaData), associando os lançamentos à data correspondente.
GROUP BY td.DataSaldo, COALESCE(la.Id_Conta, t.Id_Conta): Agrupa os resultados pela data de saldo e pelo ID da conta.
CalculoSaldo:
Nesta parte, utilizamos os resultados da CTE CalculoCreditoDebito para calcular o saldo final e inicial para cada conta.
ISNULL(LAG(Saldo_Final, 1, 0) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo), 0) AS Saldo_Inicial: Utiliza a função LAG para obter o saldo final do dia anterior (se houver) como o saldo inicial do dia atual. Se não houver saldo final do dia anterior, define o saldo inicial como 0.
SUM(Valor_Credito - Valor_Debito) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo) AS Saldo_Final: Calcula o saldo final para cada dia somando o crédito e subtraindo o débito acumulados até aquele dia. O saldo final de um dia é o saldo inicial do dia anterior mais o crédito menos o débito do dia atual.
Consulta final:
Simplesmente seleciona todos os resultados da CTE CalculoSaldo, que incluem os campos de crédito, débito, saldo inicial, saldo final e a data de saldo.*/



