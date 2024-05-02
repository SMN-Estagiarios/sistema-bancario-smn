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
   
        DECLARE @DataInicio DATE = DATEADD(MONTH, 0, GETDATE()),
                @DataFim DATE

        SET @DataInicio = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(@DataInicio), 01)
        SET @DataFim = EOMONTH(@DataInicio) ;
		
		-- Calculando saldo medio das contas para atribuir id_creditScore 
		WITH Cte_SaldoDiario AS (
									SELECT  SD.Vlr_Credito,
											SD.Vlr_Debito,
											SD.Vlr_SldInicial,
											SD.Vlr_SldFinal, 
											SD.Id_Conta,
											SD.Id,
											SD.Dat_Saldo
										FROM SaldoDiario SD
								), 
				MediaSaldoMensal AS (
										SELECT  AVG(CDC.Vlr_SldFinal) MediaSaldoMensal,
												CDC.Id_Conta	
											  FROM Cte_SaldoDiario CDC
											  WHERE Dat_Saldo BETWEEN @DataInicio AND @DataFim
											  GROUP BY CDC.Id_Conta
									)	
			UPDATE c
				SET Id_CreditScore = CASE WHEN MSM.MediaSaldoMensal > CS.Faixa 
											THEN (SELECT MAX(Id) 
													FROM CreditScore 
													WHERE MSM.MediaSaldoMensal > Faixa) 
										ELSE 1
									END,
					Lim_ChequeEspecial = ABS(MSM.MediaSaldoMensal * CS.Aliquota)
				FROM [dbo].[Contas] c
					INNER JOIN MediaSaldoMensal MSM
						ON MSM.ID_Conta = c.ID
					INNER JOIN [dbo].[CreditScore] CS WITH (NOLOCK)
						ON CS.Id = (SELECT MAX(Id)
										FROM [dbo].[CreditScore] WITH(NOLOCK)
										WHERE MSM.MediaSaldoMensal > Faixa)
				WHERE c.Id = MSM.ID_Conta;
    END
GO

SELECT * from saldoDiario
order bY iD_CONTA, dAT_SALDO