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

		WITH SaldoDiario AS (
				SELECT	s.ID_Conta, --Listar o saldo atual de todos os dias
						s.DataSaldo,
						(s.ValorSaldoAtual - ISNULL(l.Credito, 0) + ISNULL(l.Debito, 0)) AS ValorSaldoFinalNaData,
						ISNULL(l.Credito, 0) Vlr_Credito,
						ISNULL(l.Debito, 0 )Vlr_Debito,
						s.ValorSaldoAtual
			FROM (
					SELECT  c.id AS ID_Conta,
							td.DataSaldo,
							(c.Vlr_SldInicial + c.Vlr_Credito - c.Vlr_Debito) AS ValorSaldoAtual
						FROM #TabelaData td
						CROSS JOIN [dbo].[Contas] c WITH(NOLOCK)
				) s
			LEFT OUTER JOIN (
								SELECT  x.Id_Conta, --Somar todos os cr ditos e todos os d bitos ap s a data
										x.DataSaldo,
										SUM(CASE WHEN x.TipoLancamento = 'C' THEN x.Vlr_Lanc ELSE 0 END) AS Credito,
										SUM(CASE WHEN x.TipoLancamento = 'D' THEN x.Vlr_Lanc ELSE 0 END) AS Debito
									FROM (
											SELECT  td.DataSaldo, --Listar todos os lan amentos feitos ap s a data, por exemplo, DataSaldo 28 ir  ter os lan amentos do dia 30 e 29
													la.Dat_Lancamento,
													la.Id_Conta,
													ISNULL(la.Tipo_Operacao, 'X') as TipoLancamento,
													la.Vlr_Lanc
											FROM #TabelaData td
												LEFT OUTER JOIN [dbo].[Lancamentos] la WITH(NOLOCK)
													ON DATEDIFF(DAY, td.DataSaldo, la.Dat_Lancamento) > 0
										) x
										GROUP BY x.DataSaldo, x.Id_Conta
							) l
				ON s.ID_Conta = l.Id_Conta
					AND s.DataSaldo = l.DataSaldo
				--LEFT JOIN [DBO].[FNC_BalancoCD]() BCD
				--	     ON BCD.Id_Conta = l.ID_Conta
				--		AND l.DataSaldo = BCD.DataBalanco

			)	INSERT INTO [dbo].[SaldoDiario] (Id_Conta, Vlr_SldFinal, Dat_Saldo, Vlr_Debito, Vlr_Credito, Vlr_SldInicial)
				SELECT 
						SD.ID_Conta,
						SD.ValorSaldoFinalNaData,
						SD.DataSaldo,
						SD.Vlr_Debito,
						SD.Vlr_Credito,
						SD.ValorSaldoAtual
					FROM SaldoDiario SD
						INNER JOIN [dbo].[Contas] C
							ON C.Id = SD.ID_Conta
					WHERE SD.DataSaldo >= C.Dat_Abertura
						  AND C.Ativo = 1
				  
						  
			
			
			DROP TABLE #TabelaData

    END
GO



--CREATE OR ALTER PROCEDURE [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario]
--AS
--BEGIN
--    DECLARE @DataInicio DATE = DATEADD(MONTH, 0, GETDATE()),
--            @DataFim DATE

--    SET @DataInicio = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, 0, GETDATE())), 01)
--    SET @DataFim = EOMONTH(@DataInicio) 

--    CREATE TABLE #TabelaData(
--        DataSaldo DATE
--    )

--    --Populando tabela de dias
--    WHILE @DataInicio <= @DataFim
--    BEGIN
--        INSERT INTO #TabelaData(DataSaldo) VALUES (@DataInicio)
--        SET @DataInicio = DATEADD(DAY, 1, @DataInicio)
--    END;

--    INSERT INTO [dbo].[SaldoDiario] (Id_Conta, Vlr_SldFinal, Dat_Saldo, Vlr_Debito, Vlr_Credito, Vlr_SldInicial)
--    SELECT 
--        s.ID_Conta,
--        (s.ValorSaldoAtual - ISNULL(l.Credito, 0) + ISNULL(l.Debito, 0)) AS ValorSaldoFinalNaData,
--        s.DataSaldo,
--		ISNULL(l.Debito, 0) AS Vlr_Debito,
--        ISNULL(l.Credito, 0) AS Vlr_Credito,
--        s.ValorSaldoAtual
--    FROM (
--        SELECT  
--            c.id AS ID_Conta,
--            td.DataSaldo,
--            (c.Vlr_SldInicial + c.Vlr_Credito - c.Vlr_Debito) AS ValorSaldoAtual
--        FROM #TabelaData td
--        CROSS JOIN [dbo].[Contas] c WITH(NOLOCK)
--    ) s
--    LEFT OUTER JOIN (
--        SELECT  
--            x.Id_Conta,
--            x.DataSaldo,
--            SUM(CASE WHEN x.TipoLancamento = 'C' THEN x.Vlr_Lanc ELSE 0 END) AS Credito,
--            SUM(CASE WHEN x.TipoLancamento = 'D' THEN x.Vlr_Lanc ELSE 0 END) AS Debito
--        FROM (
--            SELECT  
--                td.DataSaldo,
--                la.Dat_Lancamento,
--                la.Id_Conta,
--                ISNULL(la.Tipo_Operacao, 'X') as TipoLancamento,
--                la.Vlr_Lanc
--            FROM #TabelaData td
--            LEFT OUTER JOIN [dbo].[Lancamentos] la WITH(NOLOCK) ON DATEDIFF(DAY, td.DataSaldo, la.Dat_Lancamento) = 0
--        ) x
--        GROUP BY x.DataSaldo, x.Id_Conta
--    ) l ON s.ID_Conta = l.Id_Conta AND s.DataSaldo = l.DataSaldo

--    DROP TABLE #TabelaData
--END
--GO
