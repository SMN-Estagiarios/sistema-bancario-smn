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
										Valor,
										ValorJurosAtraso,
										Data_Cadastro FROM 
									[dbo].[Parcela] WITH(NOLOCK)

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 500, 2, 'PRE'

								UPDATE [dbo].[Contas]
									SET Lim_ChequeEspecial = 100
									WHERE Id = 1

								SELECT * FROM Contas
								
								EXEC [dbo].[SPJOB_LancarParcela]

								SELECT	Id,
										Id_Emprestimo,
										Id_Lancamento,
										Valor,
										ValorJurosAtraso,
										Data_Cadastro FROM 
									[dbo].[Parcela] WITH(NOLOCK)
								SELECT * FROM Lancamentos
							ROLLBACK TRAN
	*/
	BEGIN
		--DECLARE @DataAtual DATE = GETDATE(),
		DECLARE @DataAtual DATE = GETDATE(),
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
								Valor,
								ValorJurosAtraso,
								Data_Cadastro,
								SaldoDisponivel
							)
			SELECT	P.Id,
					E.Id_Conta,
					P.Id_Emprestimo,
					P.Id_Lancamento,
					P.Valor,
					P.ValorJurosAtraso,
					P.Data_Cadastro,
					[dbo].[FNC_CalcularSaldoDisponivel](E.Id_Conta, NULL, NULL, NULL, NULL) SaldoDisponivel
				FROM [dbo].[Parcela] P WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
						ON P.Id_Emprestimo = E.Id
				WHERE	Data_Cadastro <= @DataAtual AND
						Id_Lancamento IS NULL

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
			END

			

		IF EXISTS (SELECT TOP 1 1
							FROM #Tabela
							WHERE Valor > SaldoDisponivel)
			BEGIN
				UPDATE [dbo].[Parcela]
					SET ValorJurosAtraso = ValorJurosAtraso + ([dbo].[FNC_BuscarTaxaJurosAtraso](Id_Emprestimo) * Valor)
				WHERE	Data_Cadastro < @DataAtual AND
						Id_Lancamento IS NULL
			END
	END