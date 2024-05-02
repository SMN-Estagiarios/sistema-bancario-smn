CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario]
			@Mes INT,
			@Ano INT
    AS
		/*
			Documenta��o
			Arquivo Fonte.....: SPJOB_AtualizarCreditScore.sql
			Objetivo..........: Atualizar o CreditScore das Contas
			Autor.............: Gustavo Targino, Jo o Victor Maia, Gabriel Damiani
			Data..............: 16/04/2024
			Autore Alteracao..: Adriel Alexander Pedro Avellino, Gabriel Damiani 
			Data Alteracao....: 01/05/2024
			EX................:	BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									SELECT * 
										FROM SaldoDiario
										ORDER BY Id_Conta
									TRUNCATE TABLE SaldoDiario

									SELECT * FROM SaldoDiario

									EXEC [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario] 4, 2024
									
									SELECT * 
										FROM SaldoDiario
										ORDER  BY Id_COnta, Dat_Saldo
									SELECT * 
										FROM Lancamentos
										ORDER BY Dat_LAncamento
    
								ROLLBACK TRAN
		*/
    BEGIN

				DECLARE @DataInicio DATE,
						@DataFim DATE

				SET @DataInicio = DATEFROMPARTS(@Ano, @Mes, 01)
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
										AND C.Id = la.Id_Conta
							    WHERE  td.DataSaldo >= C.Dat_Abertura
								GROUP BY td.DataSaldo, c.Id
											  )
												INSERT INTO [dbo].[SaldoDiario] (Vlr_Credito, Vlr_Debito, Dat_Saldo, Id_Conta, Vlr_SldInicial, Vlr_SldFinal)
												SELECT  Credito,
														Debito,
														DataSaldo,
														Id_Conta,
														ISNULL(LAG(Saldo_Final, 1, 0) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo), 0) AS Saldo_Inicial,
														Saldo_Final
											FROM (
													SELECT  Valor_Credito Credito,
															Valor_Debito Debito,
															DataSaldo DataSaldo,
															Id_Conta Id_Conta,
															SUM(Valor_Credito - Valor_Debito) OVER (PARTITION BY Id_Conta ORDER BY DataSaldo) AS Saldo_Final
														FROM CalculoCreditoDebito
												)x						
END




