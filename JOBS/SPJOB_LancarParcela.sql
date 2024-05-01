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
								SELECT	Id,
										Id_Conta,
										Id_Usuario,
										Id_TipoLancamento,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos]
									
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

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Ret INT;

								DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE ('ALL')

								EXEC @Ret = [dbo].[SPJOB_LancarParcela]

								SELECT	@Ret AS Retorno,
										DATEDIFF(MILLISECOND, @DATA_INI, GETDATE()) AS ResultadoExecucao

								SELECT	Id,
										Id_Emprestimo,
										Id_Lancamento,
										Valor,
										ValorJurosAtraso,
										Data_Cadastro FROM 
									[dbo].[Parcela] WITH(NOLOCK)

								SELECT	Id,
										Id_Conta,
										Id_Usuario,
										Id_TipoLancamento,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos]
							ROLLBACK TRAN

							--- Resultado ---
							00: Lancamento(s) criado(s) com sucesso.
							01: Não teve lancamentos ou lancamentos foram adiados
	*/
	BEGIN
		DECLARE @DataAtual DATE = GETDATE(),
				@TaxaAtrasadoAtual DECIMAL(6,5);

		-- Verificar se existe a tabela temporaria, caso exista, dropar ela
		IF OBJECT_ID('tempdb..#Tabela') IS NOT NULL
			BEGIN
				DROP TABLE #Tabela;
			END

		-- Criar tabela temporaria
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

		-- Inserir valores nela
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

		-- Verificar se existe algum registro na tabela temporaria, onde o valor da parcela é menor que ou igual ao saldo disponivel
		IF EXISTS(SELECT TOP 1 1
					FROM #Tabela
					WHERE Valor <= SaldoDisponivel)
			BEGIN
				-- Fazer lancamento da parcela
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

				RETURN 0
			END

		-- Verificar se existe algum registro onde o valor da parcela é maior que o disponivel
		IF EXISTS (SELECT TOP 1 1
							FROM #Tabela
							WHERE Valor > SaldoDisponivel)
			BEGIN
				-- Gerar juros para a parcela
				UPDATE [dbo].[Parcela]
					SET ValorJurosAtraso = ValorJurosAtraso + ([dbo].[FNC_BuscarTaxaJurosAtraso](Id_Emprestimo) * Valor)
				WHERE	Data_Cadastro < @DataAtual AND
						Id_Lancamento IS NULL

				RETURN 1
			END
	END