USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_LancarParcela]
	AS
	/*
		Documentacao
		Arquivo Fonte.....: SPJOB_LancarParcela.sql
		Objetivo..........: Verificar a data da parcela e caso esteja na data correta, fazer o seu lancamento
		Autor.............: Joao Victor, Odlavir Florentino e Rafael Mauricio
		Data..............: 29/04/2024
		Ex................:	BEGIN TRAN
								SELECT * FROM Lancamentos
									
								SELECT	Id,
										Id_Emprestimo,
										Id_Lancamento,
										Id_Status,
										Valor,
										ValorJurosAtraso,
										Data_Cadastro FROM 
									[dbo].[Parcela] WITH(NOLOCK)

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 500, 2, 'PRE', NULL

								--UPDATE [dbo].[Contas]
									--SET Lim_ChequeEspecial = 100
									--WHERE Id = 1

								SELECT * FROM Contas
								
								EXEC [dbo].[SPJOB_LancarParcela]

								SELECT	Id,
										Id_Emprestimo,
										Id_Lancamento,
										Id_Status,
										Valor,
										ValorJurosAtraso,
										Data_Cadastro FROM 
									[dbo].[Parcela] WITH(NOLOCK)
								SELECT * FROM Lancamentos
							ROLLBACK TRAN
	*/
	BEGIN
		--DECLARE @DataAtual DATE = GETDATE(),
		DECLARE @DataAtual DATE = '2024-05-30',
				@TaxaAtrasadoAtual DECIMAL(6,5);

		IF OBJECT_ID('tempdb..#Tabela') IS NOT NULL
			BEGIN
				DROP TABLE #Tabela;
			END

		CREATE TABLE #Tabela	(
									Id INT,
									Id_Conta INT,
									Id_Emprestimo INT,
									Id_Lancamento INT,
									Id_Status TINYINT,
									Valor DECIMAL(15,2),
									ValorJurosAtraso DECIMAL(6,2),
									Data_Cadastro DATE,
									SaldoDisponivel DECIMAL(15,2)
								)

		INSERT INTO #Tabela (	Id,
								Id_Conta,
								Id_Emprestimo,
								Id_Lancamento,
								Id_Status,
								Valor,
								ValorJurosAtraso,
								Data_Cadastro,
								SaldoDisponivel
							)
			SELECT	P.Id,
					E.Id_Conta,
					P.Id_Emprestimo,
					P.Id_Lancamento,
					P.Id_Status,
					P.Valor,
					P.ValorJurosAtraso,
					P.Data_Cadastro,
					[dbo].[FNC_CalcularSaldoDisponivel](E.Id_Conta, NULL, NULL, NULL, NULL) SaldoDisponivel
				FROM [dbo].[Parcela] P WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
						ON P.Id_Emprestimo = E.Id
				WHERE	Data_Cadastro <= @DataAtual AND
						Id_Status IN (1,2);

		IF EXISTS(SELECT TOP 1 1
					FROM #Tabela
					WHERE Valor <= SaldoDisponivel)
			BEGIN
				INSERT INTO [dbo].[Lancamentos] (
													Id_Conta,
													Id_Usuario,
													Id_TipoLancamento,
													Tipo_Operacao,
													Vlr_Lanc,
													Nom_Historico,
													Dat_Lancamento,
													Estorno
												)
					SELECT	Id_Conta,
							0,
							8,
							'D',
							(Valor + ValorJurosAtraso),
							'Parcela do emprestimo',
							@DataAtual,
							0							
						FROM #Tabela
						WHERE Valor <= SaldoDisponivel

				UPDATE [dbo].[Parcela]
					SET Id_Status = 3
				WHERE Id IN (SELECT Id
								FROM #Tabela
								WHERE Valor <= SaldoDisponivel)
			END

			

		IF EXISTS (SELECT TOP 1 1
							FROM #Tabela
							WHERE Valor > SaldoDisponivel)
			BEGIN
				UPDATE [dbo].[Parcela]
					SET Id_Status = 2,
						ValorJurosAtraso = ValorJurosAtraso + ([dbo].[FNC_BuscarTaxaJurosAtraso](Id_Emprestimo) * Valor)
				WHERE Id IN (SELECT Id
								FROM #Tabela
								WHERE	Valor > SaldoDisponivel AND
										Id_Status IN (1, 2))
			END
	END