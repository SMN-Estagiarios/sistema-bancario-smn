USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AtualizarSaldo] 
	AS 
	/*
		Documentacao
		Arquivo Fonte.....: SPJOB_AtualizarSaldo.sql
		Objetivo..........: Job que atualiza diariamente o saldo de todas as contas e faz a popula��o da tabela [dbo].[SaldoDiario] com base no dia anterior 
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

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao;
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
				DECLARE @ProcedureError VARCHAR(120) = ERROR_PROCEDURE();
				--Declaracao de variavel 
				DECLARE @DataAtualizacao DATE = GETDATE(), 
						@DataSaldoDiario DATE = DATEADD(DAY,-1,GETDATE()),
						@MensagemError VARCHAR(4000) = 'Error no [SP_JOBAtualizaSaldo] ' + @ProcedureError +': '+ ERROR_MESSAGE(),
						@EstadoError INT = ERROR_STATE(), 
						@SeveridadeError INT = ERROR_SEVERITY();
		
				BEGIN TRANSACTION 
		
				BEGIN TRY
					INSERT INTO SaldoDiario (Id_Conta, Vlr_Debito, Vlr_Credito, Vlr_SldInicial, Vlr_SldFinal, Dat_Saldo)
						SELECT C.Id, 
							   C.Vlr_Debito,
							   C.Vlr_Credito,
							   C.Vlr_SldInicial,
							   [dbo].[FNC_CalcularSaldoAtual](C.Id, Vlr_SldInicial, Vlr_Credito, Vlr_Debito), 
							   @DataSaldoDiario
							FROM [dbo].[Contas] C
			
				END TRY
					BEGIN CATCH
						-- Se ocorrer algum erro, faz o rollback da transa��o
						ROLLBACK TRANSACTION; 
						-- Retornando mensagem de erro com raiserror
						RAISERROR(@MensagemError,@SeveridadeError, @EstadoError)
					END CATCH;
	
		
				BEGIN TRY	 
				--Atualizacao das contas para quando a data do saldo for inferior a data de atualizacao 
				UPDATE[dbo].[Contas] 
					SET Vlr_SldInicial = [dbo].[FNC_CalcularSaldoAtual](NULL, Vlr_SldInicial, Vlr_Credito, Vlr_Debito), 
						Vlr_Credito = 0,
						Vlr_Debito = 0,
						Dat_Saldo = @DataAtualizacao
					WHERE Dat_Saldo < @DataAtualizacao
		
				END TRY
					BEGIN CATCH
						-- Se ocorrer algum erro, faz o rollback da transa��o
						ROLLBACK TRANSACTION;
						-- Retornando mensagem de erro com raiserror
						RAISERROR(@MensagemError,@SeveridadeError, @EstadoError)
					END CATCH;	

				COMMIT TRANSACTION

	END
GO