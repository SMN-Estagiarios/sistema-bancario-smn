CREATE OR ALTER PROCEDURE [dbo].[SPJOB_FechamentoFatura]
	AS
	/*
	Documentação
	Arquivo fonte...: [dbo].[SPJOB_FechamentoFatura]
	Objetivo..........: Fecha fatura gerando fatura.
	Autor..............: Isabella Siqueira, Olivio Freitas, Orcino Neto.
	Data...............: 29/04/2024
	EX..................:
							BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @RET INT,
								@Dat_ini DATETIME = GETDATE();

								SELECT * FROM Fatura
								EXEC @RET=[dbo].[SPJOB_FechamentoFatura];

								SELECT * FROM Fatura
								--SELECT * FROM TransacaoCartaoCredito

								SELECT @RET AS RETORNO,
								DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao;	
							ROLLBACK TRAN
	Lista de Retornos:
		0 - Sucesso
		1 - Erro. Fatura não está em periodo de fechamento.
	*/
	BEGIN
		DECLARE	@DataVencimento DATE,
				@IdCartaoCredito INT,
				@DiaVencimento INT,
				@IdFatura INT,
				@DataAtual DATE = GETDATE(),
				@Vlr_Fatura DECIMAL(15,2)
			
		-- Criando uma tabela temporaria.
		CREATE TABLE #NovaFatura (Id INT)
				
		--Captura os Ids dos cartões que vence em 5 dias e armazena na tabela temporaria #NovaFatura
		INSERT INTO #NovaFatura
			SELECT cc.Id
				FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)
				WHERE	cc.DiaVencimento = DAY(DATEADD(DAY, 5, @DataAtual)) AND cc.Id_StatusCartaoCredito = 1

		--Verificação se exite algo na tabela temporaria
		WHILE EXISTS (SELECT 1 FROM #NovaFatura)
			BEGIN
				--Seleciona o Top 1 da tabela temporaria.
				SELECT TOP 1 @IdCartaoCredito = Id FROM #NovaFatura;

					--Seta o dia de vencimento com o dia escolhido na criação do cartao.
					SET	@DiaVencimento = (SELECT DiaVencimento 
											FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)
											WHERE cc.Id = @IdCartaoCredito);

					--Seta a Data de vencimento do cartao com a data atual e dia escolhido no cartao.
					SET @DataVencimento = DATEFROMPARTS(YEAR(@DataAtual), MONTH(@DataAtual), @DiaVencimento);

					--Declaração do do codigo de barra para gerar automatico.
					DECLARE @CodigoBarra BIGINT =  CAST(round(RAND()*10000000000000000,0) AS BIGINT)
					SET @Vlr_Fatura = (SELECT [dbo].[FNC_CalculaTransacoes](@IdCartaoCredito))

					--Gera nova Fatura.
					INSERT INTO [dbo].[Fatura]	(
												Id_CartaoCredito, 
												CodigoBarra, 
												DataEmissao, 
												DataVencimento, 
												Vlr_Fatura, 
												MultaAtraso
												) 	
										VALUES
												(
												@IdCartaoCredito, 
												@CodigoBarra, 
												@DataAtual, 
												@DataVencimento, 
												@Vlr_Fatura, 
												0
												)

					SET @IdFatura = SCOPE_IDENTITY()

					--Altera as transações do cartao de credito para o id da fatura correspondente.
					UPDATE [dbo].[TransacaoCartaoCredito]
						SET Id_Fatura = @IdFatura
					WHERE Id_CartaoCredito = @IdCartaoCredito
					--Deleta o Top 1 que ja foi registrado.
					DELETE FROM #NovaFatura WHERE Id = @IdCartaoCredito;
			END	

		--Dropa a Tabela temporaria.
		DROP TABLE #NovaFatura;

			IF @@ROWCOUNT <> 1
				RETURN 0
			ELSE
				RETURN 1
	END
GO