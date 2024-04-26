CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovoCartaoCredito]
	@IdCorrentista INT,
	@IdConta INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: CartaoCredito.sql
	Objetivo..........: 
	Autor.............: Olívio Freitas, Orcino Ferreira, Isabella Tragante
	Data..............: 24/04/2024
	Ex................: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT * FROM Correntista;
							SELECT * FROM Contas;
							SELECT * FROM CartaoCredito;
							
							EXEC [dbo].[SP_InserirNovoCartaoCredito] 2, 2

							SELECT * FROM CartaoCredito;
							SELECT * FROM Contas;

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

						ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @NumeroCartao BIGINT,
				@NomeCorrentista VARCHAR(500),
				@NumeroCVC SMALLINT,
				@DataAtual DATE,
				@DataValidade DATE,
				@DiaVencimento TINYINT,
				@IdCreditScore TINYINT,
				@LimiteCartao DECIMAL(15,2),
				@Aliquota DECIMAL(3,2),
				@SaldoConta DECIMAL(15,2)

		-- Verifica se existe o correntista
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[Correntista] WITH(NOLOCK)
							WHERE Id = @IdCorrentista)
			BEGIN
				PRINT 'Correntista não existe em nosso banco'
				RETURN 1
			END
		ELSE
			BEGIN
				SET @NomeCorrentista = (SELECT Nome
											FROM [dbo].[Correntista] WITH(NOLOCK)
											WHERE Id = @IdCorrentista)
			END
		-- Verifica se existe a conta
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[Contas] WITH(NOLOCK)
							WHERE Id = @IdConta)
			BEGIN
				PRINT 'Conta não encontrada'
				RETURN 2
			END
		ELSE
			BEGIN
				SELECT	@IdCreditScore = Id_CreditScore,
						@Aliquota = CS.Aliquota,
						@SaldoConta = C.Vlr_SldInicial
					FROM [dbo].[Contas] C WITH(NOLOCK)
						INNER JOIN [dbo].[CreditScore] CS WITH(NOLOCK)
							ON C.Id_CreditScore = CS.Id
					WHERE C.Id_Correntista = @IdCorrentista

				IF @IdCreditScore IN (1,2,3, NULL)
					-- Restrição para criação do cartão baseado no credit score.
					BEGIN
						SET @LimiteCartao = 100
						PRINT 'Score baixo. Aumente sua renda!'
					END
				ELSE
					-- Aplicar limite do cartão baseado no credit score
					BEGIN
						SET @LimiteCartao = (@SaldoConta * @Aliquota) / 1.6
					END

			END
		-- Verifica se a conta pertence ao correntista
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[Contas] CON WITH(NOLOCK)
								INNER JOIN [dbo].[Correntista] COR
									ON COR.Id = CON.Id_Correntista
							WHERE COR.Id = @IdCorrentista
								AND CON.Id = @IdConta)
			BEGIN
				PRINT 'Conta não pertence ao correntista'
				RETURN 3
			END

		-- Gera novo número de cartão de crédito
		SET @NumeroCartao =  CAST(round(RAND()*10000000000000000,0) AS BIGINT)
		WHILE @NumeroCartao = (SELECT Numero
								FROM [dbo].[CartaoCredito] WITH(NOLOCK)
								WHERE Numero = @NumeroCartao)
			BEGIN
				SET @NumeroCartao =  CAST(round(RAND()*10000000000000000,0) AS BIGINT)
			END

		-- Gerar numero CVC
		SET @NumeroCVC =  FLOOR(1000 + RAND() * 8999)

		-- Gerar DataAtual e DataValidade
		SET @DataAtual = GETDATE()
		SET	@DataValidade = DATEADD(YEAR, 4, @DataAtual)

		-- Setar o DiaVencimento
		SET @DiaVencimento = DAY(DATEADD(DAY, 30, @DataAtual))

		-- Criar novo cartão
		INSERT INTO CartaoCredito (Id_Conta, Id_StatusCartaoCredito, NomeImpresso, Numero, Cvc, Limite, DataEmissao, DataValidade, Aproximacao, DiaVencimento)
							VALUES(@IdConta, 2, @NomeCorrentista, @NumeroCartao, @NumeroCVC, @LimiteCartao, @DataAtual, @DataValidade, 0, @DiaVencimento)
	END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_AtivaCartaoCredito]
	@IdCartao INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: CartaoCredito.sql
	Objetivo..........: 
	Autor.............: Olívio Freitas, Orcino Ferreira, Isabella Tragante
	Data..............: 26/04/2024
	Ex................: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT	CC.Id AS IdCartao,
									SCC.Nome
								FROM CartaoCredito CC
									INNER JOIN StatusCartaoCredito SCC
										ON CC.Id_StatusCartaoCredito = SCC.Id
							
							EXEC [dbo].[SP_AtivaCartaoCredito] 31

							SELECT	CC.Id AS IdCartao,
									SCC.Nome
								FROM CartaoCredito CC
									INNER JOIN StatusCartaoCredito SCC
										ON CC.Id_StatusCartaoCredito = SCC.Id

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

						ROLLBACK TRAN
	*/
	BEGIN
		UPDATE [dbo].[CartaoCredito]
			SET Id_StatusCartaoCredito = 1
			WHERE Id = @IdCartao
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtivaAproximacaoCartao]
	@IdCartao INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: CartaoCredito.sql
	Objetivo..........: Cria uma conta na tabela [dbo].[Contas]
	Autor.............: Olívio Freitas, Orcino Ferreira, Isabella Tragante
	Data..............: 26/04/2024
	Ex................: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT	Id,
									Aproximacao
								FROM CartaoCredito;
							
							EXEC  [dbo].[SP_AtivaAproximacaoCartao] 31

							SELECT	Id,
									Aproximacao
								FROM CartaoCredito;

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

						ROLLBACK TRAN
	*/
	BEGIN
		UPDATE [dbo].[CartaoCredito]
			SET Aproximacao = 1
			WHERE Id = @IdCartao
	END
GO