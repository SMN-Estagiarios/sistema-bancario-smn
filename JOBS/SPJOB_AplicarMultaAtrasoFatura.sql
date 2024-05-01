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
	*/
	BEGIN
		--Criando Tabela Temporaria
		CREATE TABLE #MultaFatura (Id INT,Id_CartaoCredito INT,DataVencimento DATE, Vlr_Fatura DECIMAL(15,2), MultaAtraso DECIMAL(15,2))
		DECLARE @DataAtual DATE = GETDATE()
		--Populando Tabela Temporaria Caso a fatura nao esteja paga e com pelo menos 1 dia em atraso.
		INSERT INTO #MultaFatura		
				SELECT  f.Id,
						f.Id_CartaoCredito,
						f.DataVencimento,
						f.Vlr_Fatura,
						f.MultaAtraso
					FROM [dbo].[Fatura]f WITH(NOLOCK)
					WHERE Id_Lancamento IS NULL AND DataVencimento < @DataAtual
		--Verificação se existe algo na tabela temporaria
		WHILE EXISTS (SELECT TOP 1 1 FROM #MultaFatura)
			BEGIN
				DECLARE @IdFatura INT,
						@IdCartaoCredito INT,
						@DataVencimento DATE,
						@VlrFatura DECIMAL(15,2),
						@MultaAtraso DECIMAL(15,2),
						@DiasAtraso INT

					SELECT TOP 1 @IdFatura = mf.Id,
								 @IdCartaoCredito = mf.Id_CartaoCredito,
								 @DataVencimento = mf.DataVencimento,
								 @VlrFatura = mf.Vlr_Fatura,
								 @MultaAtraso = mf.MultaAtraso
						FROM #MultaFatura mf

				SET @DiasAtraso = DATEDIFF(DAY,@DataVencimento,@DataAtual)

				DECLARE @ValorTaxa DECIMAL(6,5) =	(SELECT TOP 1 vt.Aliquota
														FROM [dbo].[ValorTaxaCartao]vt WITH(NOLOCK)
															INNER JOIN [dbo].[TransacaoCartaoCredito] tc
																ON tc.Id_ValorTaxaCartao = vt.Id
															INNER JOIN #MultaFatura mf
																ON tc.Id_Fatura = mf.Id
															WHERE mf.Id_CartaoCredito = tc.Id_CartaoCredito
													)
				--Declarando e setando VlrMulta com Valor da fatura x valor da taxa da multa diaria
				DECLARE @VlrMulta DECIMAL(15,2) = @VlrFatura * @ValorTaxa * @DiasAtraso
				--Verificação se a fatura esta atrasada
				IF @DataVencimento >= @DataAtual
					BEGIN
						RETURN 1
					END
				ELSE
					BEGIN
						--Realizando Update na fatura atrasada especifica de acordo com os dias em atraso.
						UPDATE [dbo].[Fatura]
							SET MultaAtraso = @VlrMulta
						WHERE Id_CartaoCredito = @IdCartaoCredito AND Id = @IdFatura
					END
				DELETE FROM #MultaFatura WHERE Id = @IdFatura;						
			END
		DROP TABLE #MultaFatura
		RETURN 0
	END
GO