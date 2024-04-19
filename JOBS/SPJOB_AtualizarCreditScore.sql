USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AtualizarCreditScore]
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

								DECLARE @Ret INT,
										@Dat_ini DATETIME = GETDATE();

								SELECT  TOP 20	*
									FROM [dbo].[Contas] WITH(NOLOCK);

								EXEC @Ret = [dbo].[SPJOB_AtualizarCreditScore]

								SELECT  TOP 20	*
									FROM [dbo].[Contas] WITH(NOLOCK);

								SELECT  @Ret AS Retorno,
										DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
		*/
    BEGIN

        DECLARE @DataInicio DATE = DATEADD(MONTH, -1, GETDATE()),
                @DataFim DATE

        SET @DataInicio = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 01)
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
						(s.ValorSaldoAtual - ISNULL(l.Credito, 0) + ISNULL(l.Debito, 0)) AS ValorSaldoFinalNaData
			FROM (
					SELECT  c.id AS ID_Conta,
							td.DataSaldo,
							(c.Vlr_SldInicial + c.Vlr_Credito - c.Vlr_Debito) AS ValorSaldoAtual
						FROM #TabelaData td
						CROSS JOIN [dbo].[Contas] c WITH(NOLOCK)
				) s
			LEFT OUTER JOIN (
								SELECT  x.Id_Cta, --Somar todos os cr ditos e todos os d bitos ap s a data
										x.DataSaldo,
										SUM(CASE WHEN x.TipoLancamento = 'C' THEN x.Vlr_Lanc ELSE 0 END) AS Credito,
										SUM(CASE WHEN x.TipoLancamento = 'D' THEN x.Vlr_Lanc ELSE 0 END) AS Debito
									FROM (
											SELECT  td.DataSaldo, --Listar todos os lan amentos feitos ap s a data, por exemplo, DataSaldo 28 ir  ter os lan amentos do dia 30 e 29
													la.Dat_Lancamento,
													la.ID_Cta,
													ISNULL(la.Tipo_Operacao, 'X') as TipoLancamento,
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
				(	SELECT 
						SD.ID_Conta,
						AVG(SD.ValorSaldoFinalNaData) MediaSaldoMensal
					FROM SaldoDiario SD
						INNER JOIN Contas C
							ON C.Id = SD.ID_Conta
					WHERE SD.DataSaldo >= C.Dat_Abertura
						  AND C.Ativo = 1
					GROUP BY SD.ID_Conta
				) 
					UPDATE Contas
						SET IdCreditScore = CASE WHEN MSM.MediaSaldoMensal > CS.Faixa 
												 THEN (SELECT MAX(Id) 
															FROM CreditScore 
															WHERE MSM.MediaSaldoMensal > Faixa) 
												ELSE 1
											END,
							Lim_ChequeEspecial = ABS(MSM.MediaSaldoMensal * CS.Aliquota)
						FROM Contas 
							INNER JOIN MediaSaldoMensal MSM
								ON MSM.ID_Conta = Contas.ID
							INNER JOIN CreditScore CS WITH (NOLOCK)
								ON CS.Id = (SELECT MAX(Id)
												FROM CreditScore
												WHERE MSM.MediaSaldoMensal > Faixa)
						WHERE Contas.Id = MSM.ID_Conta;
			
			DROP TABLE #TabelaData

    END
GO

SELECT * FROM CreditScore