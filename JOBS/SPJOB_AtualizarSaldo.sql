USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [SPJOB_AtualizarSaldo] 
	AS 
	/*
		Documenta��o
		Arquivo Fonte.....: SPJOB_AtualizarSaldo.sql
		Objetivo..........: Job automatica que atualiza o saldo conforme o o dia mude 
		Autor.............: Adriel Alexander 
		Data..............: 08/04/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_ini DATETIME = GETDATE();

								SELECT  TOP 20	Id,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
									FROM [dbo].[Contas] WITH(NOLOCK);

								EXEC [dbo].[SPJOB_AtualizarSaldo];

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS Resultado;
								SELECT  TOP 20	Id,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
									FROM [dbo].[Contas] WITH(NOLOCK);
							ROLLBACK TRAN
	*/
	BEGIN 
		--Declaracao de variavel 
		DECLARE @DataAtualizacao DATE = GETDATE(),
				@Msg VARCHAR(100),
				@Error INT
			 --Atualizacao das contas para quando a data do saldo for inferior a data de atualizacao 
		UPDATE[dbo].[Contas] 
			SET Vlr_SldInicial = [dbo].[FNC_CalcularSaldoAtual](NULL, Vlr_SldInicial, Vlr_Credito, Vlr_Debito), 
				Vlr_Credito = 0,
				Vlr_Debito = 0,
				Dat_Saldo = @DataAtualizacao
			WHERE Dat_Saldo < @DataAtualizacao
		END
GO