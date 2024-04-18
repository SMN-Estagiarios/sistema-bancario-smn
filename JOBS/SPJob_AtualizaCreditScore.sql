CREATE OR ALTER PROCEDURE [dbo].[spjob_AtualizarCreditScore]
    AS
		/*
		Documentação
			Arquivo Fonte.....: SPJob_AtualizarCreditScore.sql
			Objetivo..........: Atualizar o CreditScore das Contas
			Autor.............: Gustavo Targino, Jo�o Victor Maia, Gabriel Damiani
			Data..............: 16/04/2024
			EX................:	BEGIN TRAN
									
									SELECT * FROM Contas

									EXEC [dbo].[spjob_AtualizarCreditScore]

									SELECT * FROM Contas

								ROLLBACK TRAN
		*/
    BEGIN


        DECLARE @DataInicio DATE = DATEADD(MONTH, -1, GETDATE()),
                @DataFim DATE

        SET @DataInicio = DATEADD(month, DATEDIFF(month, 0, @DataInicio), 0)
        SET @DataFim = EOMONTH(@DataInicio) 

        CREATE TABLE #TabelaData(
        DataSaldo DATE
    )

    --Populando tabela de dias
    WHILE @DataInicio <= @DataFim
        BEGIN
            INSERT INTO #TabelaData(DataSaldo) VALUES (@DataInicio)
            SET @DataInicio = DATEADD(DAY, 1, @DataInicio)
        END;

    WITH SaldoDiario AS (
    SELECT		s.ID_Conta, --Listar o saldo atual de todos os dias
				s.DataSaldo,
            (s.ValorSaldoAtual - ISNULL(l.Credito, 0) + ISNULL(l.Debito, 0)) AS ValorSaldoFinalNaData
        FROM(
                SELECT    c.id AS ID_Conta,
                        td.DataSaldo,
                        (c.Vlr_SldInicial + c.Vlr_Credito - c.Vlr_Debito) AS ValorSaldoAtual
                    FROM #TabelaData td
                    CROSS JOIN [dbo].[Contas] c WITH(NOLOCK)
            ) s
        LEFT OUTER JOIN    (
                            SELECT    x.Id_Cta, --Somar todos os cr�ditos e todos os d�bitos ap�s a data
                                    x.DataSaldo,
                                    SUM(CASE WHEN x.TipoLancamento = 'C' THEN x.Vlr_Lanc ELSE 0 END) AS Credito,
                                    SUM(CASE WHEN x.TipoLancamento = 'D' THEN x.Vlr_Lanc ELSE 0 END) AS Debito
                                FROM (
                                        SELECT    td.DataSaldo, --Listar todos os lan�amentos feitos ap�s a data, por exemplo, DataSaldo 28 ir� ter os lan�amentos do dia 30 e 29
                                                la.Dat_Lancamento,
                                                la.ID_Cta,
                                                ISNULL(la.Tipo_Lanc, 'X') as TipoLancamento,
                                                la.Vlr_Lanc
                                        FROM #TabelaData td
                                            LEFT OUTER JOIN [dbo].[Lancamentos] la WITH(NOLOCK)
                                                ON DATEDIFF(DAY, td.DataSaldo, la.Dat_Lancamento) > 0
                                    ) x
                                    GROUP BY x.DataSaldo, x.Id_Cta
                        ) l
            ON s.ID_Conta = l.Id_Cta
                AND s.DataSaldo = l.DataSaldo
        ), MediaSaldoMensal AS
			(SELECT 
                SD.ID_Conta,
                AVG(SD.ValorSaldoFinalNaData) MediaSaldoMensal
            FROM SaldoDiario SD
                INNER JOIN Contas C
                    ON C.Id = SD.ID_Conta
            WHERE SD.DataSaldo >= C.Dat_Abertura
                  AND C.Ativo = 'S'
            GROUP BY SD.ID_Conta
			) UPDATE Contas
				SET IdCreditScore = CASE WHEN MSM.MediaSaldoMensal > CS.Faixa THEN (SELECT MAX(Id) FROM CreditScore WHERE MSM.MediaSaldoMensal > Faixa) ELSE 1 END
					FROM Contas
						INNER JOIN MediaSaldoMensal MSM
							ON MSM.ID_Conta = Contas.ID
						CROSS JOIN CreditScore CS
					WHERE Contas.Id = MSM.ID_Conta;
			
		DROP TABLE #TabelaData

    END
GO