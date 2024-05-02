USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_LancarParcela]
	AS
	/*
		Documentacao
		Arquivo Fonte.....: SPJOB_LancarParcela.sql
		Objetivo..........: Lancar parcela quando a data atual for igual ao dia do vencimento da parcela
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
										Juros,
										Data_Vencimento
										FROM [dbo].[Parcela] WITH(NOLOCK)

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 500, 2, 'PRE'
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 750, 2, 'PRE'
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 2, 'PRE'
								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1500, 2, 'PRE'

								--UPDATE [dbo].[Contas]
									--SET Lim_ChequeEspecial = 100
									--WHERE Id = 1

								DECLARE @DATA_INI DATETIME = GETDATE(),
										@Ret INT,
										@Id_Parcela INT;

								SELECT TOP 1 @Id_Parcela = Id
									FROM [dbo].[Parcela] WITH(NOLOCK)

								UPDATE [dbo].[Parcela]
									SET Data_Vencimento = @DATA_INI
									WHERE Data_Vencimento = '2024-06-02'

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
										Juros,
										Data_Vencimento
										FROM [dbo].[Parcela] WITH(NOLOCK)

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
				@TaxaAtrasadoAtual DECIMAL(6,5),
				@Id_Parcela INT,
				@Valor_Lancamento DECIMAL(15,2),
				@Id_Lancamento INT;



		-- Criar tabela temporaria
		CREATE TABLE #Tabela	(
									Id INT,
									Id_Conta INT,
									Id_Emprestimo INT,
									Id_Lancamento INT,
									Id_Status TINYINT,
									Valor DECIMAL(15,2),
									Juros DECIMAL(15,2),
									Data_Cadastro DATE,
									SaldoDisponivel DECIMAL(15,2)
								)

		-- Inserir valores nela
		INSERT INTO #Tabela (	Id,
								Id_Conta,
								Id_Emprestimo,
								Id_Lancamento,
								Valor,
								Juros,
								Data_Cadastro,
								SaldoDisponivel
							)
			SELECT	p.Id,
					e.Id_Conta,
					p.Id_Emprestimo,
					p.Id_Lancamento,
					p.Valor,
					p.Juros,
					p.Data_Vencimento,
					[dbo].[FNC_CalcularSaldoDisponivel](e.Id_Conta, NULL, NULL, NULL, NULL) SaldoDisponivel
				FROM [dbo].[Parcela] p WITH(NOLOCK)
					INNER JOIN [dbo].[Emprestimo] e WITH(NOLOCK)
						ON p.Id_Emprestimo = e.Id
				WHERE	p.Data_Vencimento <= @DataAtual AND
						p.Id_Lancamento IS NULL

		-- Verificar se existe algum registro onde o valor da parcela é maior que o disponivel
		IF EXISTS (SELECT TOP 1 1
							FROM #Tabela
							WHERE Valor > SaldoDisponivel)
			BEGIN
				-- Gerar juros para a parcela
				UPDATE [dbo].[Parcela]
					SET Juros = [dbo].[FNC_CalcularJurosAtrasoParcela](Id_Emprestimo, Valor,  DAY(DATEDIFF(DAY, Data_Vencimento, @DataAtual)))
				WHERE	Data_Vencimento <= @DataAtual AND
						Id_Lancamento IS NULL

				RETURN 1
			END

		-- Verificar se existe algum registro na tabela temporaria, onde o valor da parcela é menor que ou igual ao saldo disponivel
		WHILE EXISTS(SELECT TOP 1 1
						FROM #Tabela
						WHERE Valor <= SaldoDisponivel)
			BEGIN
				-- Setando o Id da parcela
				SELECT TOP 1	@Id_Parcela = Id,
								@Valor_Lancamento = (Valor + Juros)
					FROM #Tabela

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
							@Valor_Lancamento,
							'Parcela do emprestimo',
							@DataAtual,
							0							
						FROM #Tabela
						WHERE Id = @Id_Parcela

				SET @Id_Lancamento = SCOPE_IDENTITY()

				UPDATE [dbo].[Parcela]
					SET Id_Lancamento = @Id_Lancamento
					WHERE Id = @Id_Parcela

				DELETE #Tabela
					WHERE Id =	@Id_Parcela

				SELECT	@Id_Lancamento = NULL,
						@Id_Parcela = NULL,
						@Valor_Lancamento = NULL
			END

			DROP TABLE #Tabela
			RETURN 0
	END