CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AplicarMultaAtrasoFatura]
	AS
	/*
	Documentação
	Arquivo Fonte....: SPJOB_AplicarMultaAtrasoFatura.sql
	Objetivo ........: Aplicar multa diaria por atraso de fatura.
	Autor............: Isabella Siqueira, Olivio Freitas, Orcino Neto
	EX...............:
						BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT, 
								@Dat_init DATETIME = GETDATE()
									
								SELECT * FROM Fatura
									
								EXEC @RET = [dbo].[SPJOB_AplicarMultaAtrasoFatura]
									
								SELECT * FROM Fatura																	

								SELECT @RET AS RETORNO,
								DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN

	Lista de Retornos:
			0 - Sucesso
			1 - Erro. Fatura não está atrasada.
	*/

	BEGIN
		DECLARE	@IdFatura INT,
				@IdCartaoCredito INT,
				@DataVencimento DATE,
				@VlrFatura DECIMAL(15,2),
				@MultaAtraso DECIMAL(15,2),
				@DiasAtraso INT,
				@ValorTaxa DECIMAL(6,5),
				@VlrMulta DECIMAL(15,2)

		--Criando Tabela Temporaria
		CREATE TABLE #MultaFatura  (
										Id INT,
										Id_CartaoCredito INT,
										DataVencimento DATE, 
										Vlr_Fatura DECIMAL(15,2), 
										MultaAtraso DECIMAL(15,2)
									)

		DECLARE @DataAtual DATE = GETDATE()
		--Populando Tabela Temporaria Caso a fatura nao esteja paga e com pelo menos 1 dia em atraso.

		INSERT INTO #MultaFatura		
			SELECT	f.Id,
					f.Id_CartaoCredito,
					f.DataVencimento,
					f.Vlr_Fatura,
					f.MultaAtraso
				FROM [dbo].[Fatura]f WITH(NOLOCK)
				WHERE Id_Lancamento IS NULL AND DataVencimento < @DataAtual
				
		--Pegando primeiro registro		
		SELECT TOP 1	@IdFatura = mf.Id,
						@IdCartaoCredito = mf.Id_CartaoCredito,
						@DataVencimento = mf.DataVencimento,
						@VlrFatura = mf.Vlr_Fatura,
						@MultaAtraso = mf.MultaAtraso
				FROM #MultaFatura mf

		--Verificação se existe algo na tabela temporaria
		WHILE @IdFatura IS NOT NULL
			BEGIN
				--Setando os quantos dias está em atrasod a fatura.
				SET @DiasAtraso = DATEDIFF(DAY,@DataVencimento,@DataAtual)				
				
				--Setando a variavel @ValorTaxa para receber a taxa atual de multa diaria.
				SELECT TOP 1 @ValorTaxa = vt.Aliquota
					FROM [dbo].[ValorTaxaCartao]vt WITH(NOLOCK)
						INNER JOIN [dbo].[TransacaoCartaoCredito] tc WITH(NOLOCK)
							ON tc.Id_ValorTaxaCartao = vt.Id
						INNER JOIN #MultaFatura mf
							ON tc.Id_Fatura = mf.Id
					WHERE mf.Id_CartaoCredito = tc.Id_CartaoCredito

				--Declarando e setando VlrMulta com Valor da fatura x valor da taxa da multa diaria x dias em atraso
				SET @VlrMulta  = @VlrFatura * @ValorTaxa * @DiasAtraso
				
				--Realizando Update na fatura atrasada especifica de acordo com os dias em atraso.
				UPDATE [dbo].[Fatura]
					SET MultaAtraso = @VlrMulta
					WHERE Id_CartaoCredito = @IdCartaoCredito AND Id = @IdFatura				

				--Deleta o top 1 da tabela temporaria para receber o proximo Id caso exista.
				DELETE FROM #MultaFatura WHERE Id = @IdFatura;

				--Zerando variaveis
				SELECT	@IdFatura = NULL,
						@IdCartaoCredito = NULL,
						@DataVencimento = NULL,
						@VlrFatura = NULL,
						@MultaAtraso = NULL

				--Setando as variaveis com os dados da tabela temporaria.
				SELECT TOP 1	@IdFatura = mf.Id,
								@IdCartaoCredito = mf.Id_CartaoCredito,
								@DataVencimento = mf.DataVencimento,
								@VlrFatura = mf.Vlr_Fatura,
								@MultaAtraso = mf.MultaAtraso
						FROM #MultaFatura mf
			END

		--Dropa a tabela temporaria.
		DROP TABLE #MultaFatura
		RETURN 0

	END
GO