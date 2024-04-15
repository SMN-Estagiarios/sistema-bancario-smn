CREATE OR ALTER PROCEDURE [SPJOB_AtualizaSaldo] 
	AS 
	/*
		Documentação
		Arquivo Fonte.....: SPJOB_AtualizaSaldo.sql
		Objetivo..........: SP automática que atualiza o saldo conforme o o dia mude 
		Autor.............: Adriel Alexander 
		Data..............: 08/04/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @DATA_INI DATETIME = GETDATE();

								SELECT  Id,
										Id_Usuario,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo 
									FROM [DBO].[Contas];

								EXEC [dbo].[SPJOB_AtualizaSaldo];

								SELECT DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS RESULTADO;

								SELECT  Id,
										Id_Usuario,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo 
									FROM [DBO].[Contas];
							ROLLBACK TRAN
	*/
		BEGIN 
		--Declaracao de variável 
		 DECLARE @DataAtualizacao DATE = GETDATE(),
				 @MSG VARCHAR(100),
				 @ERROR INT
		 --atualização das contas para quando a data do saldo for inferior a data de atualização 
			UPDATE[dbo].[Contas] 
				SET Vlr_SldInicial = [dbo].[Func_CalculaSaldoAtual](null, Vlr_SldInicial, Vlr_Credito, Vlr_Debito), 
					Vlr_Credito = 0,
					Vlr_Debito = 0,
					Dat_Saldo = @DataAtualizacao
				WHERE Dat_Saldo < @DataAtualizacao
	
		END