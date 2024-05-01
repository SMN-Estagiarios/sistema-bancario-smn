CREATE OR ALTER PROCEDURE [dbo].[SPJOB_PagamentoFatura]
	AS
	/*
		Documentação
		Arquivo Fonte....: SPJOB_PagamentoFatura.sql.sql
		Objetivo ........: Realiazar pagamento da fatura mediante saldo disponivel
		Autor............: Isabella Siqueira, Olivio Freitas, Orcino Neto, Gabriel Damiani
		EX...............:
							BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT * FROM Contas
									SELECT * FROM Fatura
									SELECT * FROM Lancamentos
									EXEC @RET = [dbo].[SPJOB_PagamentoFatura]
									SELECT * FROM Lancamentos
									SELECT * FROM Fatura
									SELECT * FROM Contas
									

									SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		--Criação de tabela temporaria.
		CREATE TABLE #PagamentoFatura(Id INT,Id_CartaoCredito INT, Vlr_Fatura DECIMAL(15,2))
		DECLARE @DataAtual DATE = GETDATE()
		--Armazenando os valores na tabela temporaria.
		INSERT INTO #PagamentoFatura
			SELECT	f.Id,
					f.Id_CartaoCredito,
					f.Vlr_Fatura
				FROM [dbo].[Fatura]f WITH(NOLOCK)					
				WHERE f.Id_Lancamento IS NULL AND f.DataVencimento <= @DataAtual		
		--Verificação se tem registro na tabela temporaria.
		WHILE EXISTS (SELECT TOP 1 1 FROM #PagamentoFatura)
			BEGIN
				DECLARE @IdFatura INT,
						@IdCartaoCredito INT,
						@VlrFatura DECIMAL(15,2),
						@IdConta INT
				--Selecionando o top 1 da tabela temporaria.
				SELECT TOP 1 @IdFatura = pf.Id,
							 @IdCartaoCredito = pf.Id_CartaoCredito,
							 @VlrFatura = pf.Vlr_Fatura,
							 @IdConta = cc.Id_Conta
					FROM #PagamentoFatura pf
						INNER JOIN [dbo].[CartaoCredito]cc
							ON cc.Id = pf.Id_CartaoCredito		
					--Verificação se Valor da Fatura é maior que o saldo disponivel da conta.
					IF @VlrFatura > (SELECT [dbo].[FNC_CalcularSaldoDisponivel](@IdConta, NULL, NULL, NULL, NULL))
						BEGIN
							PRINT 'Contas com saldo insuficiente'
							RETURN 1
						END
					ELSE
						BEGIN
							--Gerando Lançamento caso a conta tenha saldo.
							EXEC [dbo].[SP_CriarLancamentos] @IdConta, 0, 4, 'D', @VlrFatura, 'Pagamento Fatura', null, 0

							DECLARE @IdLancamento INT;
							--Faço a Seleção do Id do lançamento que foi criado agora.
							SELECT TOP  1 
										@IdLancamento = Id 
								FROM Lancamentos
								WHERE Id_Conta = @IdConta And Vlr_Lanc = @VlrFatura
								ORDER BY Dat_Lancamento DESC
							--Setando o Id_lancamento da fatura para o id criado no lançamento.
							UPDATE [dbo].[Fatura]
							SET Id_Lancamento = @IdLancamento
							WHERE Id_CartaoCredito = @IdCartaoCredito AND @IdFatura = Id							
						END
				--Deletando o Top 1 da tabela temporaria para buscar o proximo Top 1 se existir.
				DELETE FROM #PagamentoFatura WHERE Id = @IdFatura;				
			END
		DROP TABLE #PagamentoFatura
		RETURN 0
	END
GO       