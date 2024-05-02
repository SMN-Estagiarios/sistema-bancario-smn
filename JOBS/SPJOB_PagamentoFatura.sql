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

								--SELECT * FROM Contas
								SELECT * FROM Fatura
								--SELECT * FROM CartaoCredito
								--SELECT * FROM Lancamentos

								EXEC @RET = [dbo].[SPJOB_PagamentoFatura]

								SELECT * FROM Lancamentos
								--SELECT * FROM CartaoCredito
								SELECT * FROM Fatura
								--SELECT * FROM Contas
								--SELECT * FROM CartaoCredito

								SELECT @RET AS RETORNO,
								DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
							ROLLBACK TRAN
	Lista de Retornos:
			0 - Sucesso
			1 - Erro. Conta não tem saldo para pagamento da Fatura.
	*/
	BEGIN
		DECLARE @DataAtual DATE = GETDATE(),
				@RET INT

		--Criação de tabela temporaria.
		CREATE TABLE #PagamentoFatura(
										Id INT,
										Id_CartaoCredito INT, 
										Vlr_Fatura DECIMAL(15,2), 
										MultaAtraso DECIMAL(15,2)
									)

		--Armazenando os valores na tabela temporaria.
		INSERT INTO #PagamentoFatura
			SELECT	f.Id,
					f.Id_CartaoCredito,
					f.Vlr_Fatura,
					f.MultaAtraso
				FROM [dbo].[Fatura]f WITH(NOLOCK)
				WHERE f.Id_Lancamento IS NULL AND f.DataVencimento <= @DataAtual

		--Verificação se tem registro na tabela temporaria.
		WHILE EXISTS (SELECT TOP 1 1 FROM #PagamentoFatura)
			BEGIN
				DECLARE @IdFatura INT,
						@IdCartaoCredito INT,
						@VlrFatura DECIMAL(15,2),
						@MultaAtraso DECIMAL(15,2),
						@IdConta INT,
						@VlrTotal DECIMAL(15,2)

				--Selecionando o top 1 da tabela temporaria.
				SELECT TOP 1 @IdFatura = pf.Id,
							 @IdCartaoCredito = pf.Id_CartaoCredito,
							 @VlrFatura = pf.Vlr_Fatura,
							 @MultaAtraso = pf.MultaAtraso,
							 @IdConta = cc.Id_Conta
					FROM #PagamentoFatura pf
						INNER JOIN [dbo].[CartaoCredito]cc WITH(NOLOCK)
							ON cc.Id = pf.Id_CartaoCredito

					--Soma o valot da fatura mais juros por atraso se existir.
					SET @VlrTotal = @VlrFatura + @MultaAtraso

					--Verificação se Valor da Fatura é maior que o saldo disponivel da conta.
					IF @VlrTotal > (SELECT [dbo].[FNC_CalcularSaldoDisponivel](@IdConta, NULL, NULL, NULL, NULL))
						BEGIN
							RETURN 1
						END
					ELSE
						BEGIN
							--Gerando Lançamento caso a conta tenha saldo.
							EXEC  @RET = [dbo].[SP_CriarLancamentos] @IdConta, 0, 12, 'D', @VlrTotal, 'Pagamento Fatura', null, 0
							IF @RET < 0 
								RETURN 1
							
							--Setando o Id_lancamento da fatura para o id criado no lançamento.
							UPDATE [dbo].[Fatura]
								SET Id_Lancamento = @RET
							WHERE Id_CartaoCredito = @IdCartaoCredito 
									AND @IdFatura = Id
						END

				--Deletando o Top 1 da tabela temporaria para buscar o proximo Top 1 se existir.
				DELETE FROM #PagamentoFatura WHERE Id = @IdFatura;
				
			END
		--Dropa a tabela temporaria
		DROP TABLE #PagamentoFatura
		RETURN 0
	END
GO