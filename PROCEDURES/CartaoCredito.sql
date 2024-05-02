CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovoCartaoCredito]
	@IdCorrentista INT,
	@IdConta INT,
	@DiaVencimento TINYINT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: CartaoCredito.sql
	Objetivo..........: Cria um cartão de crédito com base em um correntista, uma conta e já escolhe uma data de vencimento.
						Se o Score da Conta for baixo, o Limite do Cartão é setado em 100
	Autor.............: Olivio Freitas, Orcino Ferreira, Isabella Tragante
	Data..............: 24/04/2024
	Ex................: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT * FROM Contas;
							SELECT * FROM CartaoCredito;
							SELECT * FROM Fatura;
							
							EXEC @RET =[dbo].[SP_InserirNovoCartaoCredito] 2, 2, 6

							SELECT * FROM CartaoCredito;
							SELECT * FROM Contas;
							SELECT * FROM Fatura;

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

						ROLLBACK TRAN
	RETORNO...........: 0 - Sucesso
						1 - Correntista nao existe em nosso banco
						2 - Conta nao encontrada
						3 - Conta não pertence ao correntista
	*/
	BEGIN
		DECLARE @NumeroCartao BIGINT,
				@NomeCorrentista VARCHAR(500),
				@NumeroCVC SMALLINT,
				@DataAtual DATE,
				@DataValidade DATE,
				@IdCreditScore TINYINT,
				@LimiteCartao DECIMAL(15,2),
				@Aliquota DECIMAL(3,2),
				@SaldoConta DECIMAL(15,2)

		-- Verifica se existe o correntista
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[Correntista] WITH(NOLOCK)
							WHERE Id = @IdCorrentista)
			BEGIN
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
				RETURN 2
			END
		ELSE
			BEGIN
				SELECT	@IdCreditScore = Id_CreditScore,
						@Aliquota = cs.Aliquota,
						@SaldoConta = c.Vlr_SldInicial
					FROM [dbo].[Contas] c WITH(NOLOCK)
						INNER JOIN [dbo].[CreditScore] cs WITH(NOLOCK)
							ON c.Id_CreditScore = cs.Id
					WHERE c.Id_Correntista = @IdCorrentista


				-- Verifica se o CreditScore está baixo ou nulo
				IF @IdCreditScore <= 3 OR @IdCreditScore IS NULL
					BEGIN
						SET @LimiteCartao = 100
					END
				ELSE
					-- Aplicar limite do cartao baseado no credit score
					BEGIN
						SET @LimiteCartao = (@SaldoConta * @Aliquota) / 1.6
					END

			END
		-- Verifica se a conta pertence ao correntista
		IF NOT EXISTS (SELECT TOP 1 1
							FROM [dbo].[Contas] con WITH(NOLOCK)
								INNER JOIN [dbo].[Correntista] cor
									ON cor.Id = CON.Id_Correntista
							WHERE cor.Id = @IdCorrentista
								AND con.Id = @IdConta)
			BEGIN
				RETURN 3
			END

		-- Gera novo numero de cartao de credito
		SET @NumeroCartao =  CAST(round(RAND()*10000000000000000,0) AS BIGINT)
		WHILE @NumeroCartao = (SELECT Numero
								FROM [dbo].[CartaoCredito] WITH(NOLOCK)
								WHERE Numero = @NumeroCartao)
			BEGIN
				SET @NumeroCartao =  CAST(round(RAND()*10000000000000000,0) AS BIGINT)
			END

		-- Gerar numero CVC
		SET @NumeroCVC =  FLOOR(100 + RAND() * 999)

		-- Gerar DataAtual e DataValidade
		SET @DataAtual = GETDATE()
		SET	@DataValidade = DATEADD(YEAR, 4, @DataAtual)

		-- Criar novo cartao
		IF @DiaVencimento IN (6, 11, 16, 21, 26)
			BEGIN			
				INSERT INTO CartaoCredito (	Id_Conta,
											Id_StatusCartaoCredito,
											NomeImpresso,
											Numero,
											Cvc,
											Limite,
											LimiteComprometido,
											DataEmissao,
											DataValidade,
											Aproximacao,
											DiaVencimento
											)
									VALUES (@IdConta,
											1,
											@NomeCorrentista,
											@NumeroCartao,
											@NumeroCVC,
											@LimiteCartao,
											0,
											@DataAtual,
											@DataValidade,
											1,
											@DiaVencimento
											)
			RETURN 0						
			END
		ELSE
			RAISERROR('Escolha entre os dias 6, 11, 16, 21 ou 26', 16, 1)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtivaCartaoCredito]
	@IdCartao INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: CartaoCredito.sql
	Objetivo..........: Muda o status do cartão de crédito para Ativo
	Autor.............: Olivio Freitas, Orcino Ferreira, Isabella Tragante
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
							
							EXEC [dbo].[SP_AtivaCartaoCredito] 1

							SELECT	CC.Id AS IdCartao,
									SCC.Nome
								FROM CartaoCredito CC
									INNER JOIN StatusCartaoCredito SCC
										ON CC.Id_StatusCartaoCredito = SCC.Id

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN

						RETORNO
								00.................: Sucesso
								01.................: Cartao nao existe
								02.................: Erro ao atualizar status
	*/
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 
							FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)
							WHERE cc.Id = @IdCartao)
			BEGIN
				RETURN 1
			END
		ELSE
		BEGIN
			UPDATE [dbo].[CartaoCredito]
				SET Id_StatusCartaoCredito = 1
				WHERE Id = @IdCartao

			IF @@ROWCOUNT = 1 
				RETURN 0
			ELSE 
				RETURN 2
		END
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtivaAproximacaoCartao]
	@IdCartao INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: CartaoCredito.sql
	Objetivo..........: Ativa a aproximação do cartão de crédito
	Autor.............: Olivio Freitas, Orcino Ferreira, Isabella Tragante
	Data..............: 26/04/2024
	Ex................: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT	Id,
									Aproximacao
								FROM CartaoCredito;
							
							EXEC  [dbo].[SP_AtivaAproximacaoCartao] 1

							SELECT	Id,
									Aproximacao
								FROM CartaoCredito;

							SELECT @RET AS RETORNO,
							DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao

						ROLLBACK TRAN

						RETORNO: 
								00.................: Sucesso
								01.................: Erro! Cartao nao existe
	*/
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 
							FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)
							WHERE cc.Id = @IdCartao)
			BEGIN
				RETURN 1
			END
		ELSE
		BEGIN
			UPDATE [dbo].[CartaoCredito]
				SET Aproximacao = 1
				WHERE Id = @IdCartao
			RETURN 0
		END
	END
GO



CREATE OR ALTER PROCEDURE [dbo].[SP_BloquearCartao]
	@IdCartaoCredito INT
	AS 
		/*
		Documentacao
		Arquivo Fonte.....: CartaoCredito.sql
		Objetivo..........: Alterar o Status do Cartao para bloqueado
		Autor.............: Isabella, Olivio e Orcino
		Data..............: 26/04/2024
		Ex................: BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								SELECT * FROM [dbo].[CartaoCredito]

								DECLARE @RET INT, @Inicio DATETIME = GETDATE()

								EXEC @RET = [dbo].[SP_BloquearCartao] 2

								SELECT * FROM [dbo].[CartaoCredito]

								SELECT DATEDIFF(MILLISECOND, @Inicio, GETDATE()) AS Tempo, 
									@RET AS Retorno

							ROLLBACK TRAN

							RETORNO
									00.................: Sucesso
									01.................: Cartao nao existe
									02.................: Erro ao tentar bloquear o cartão
		*/
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 1 
							FROM [dbo].[CartaoCredito] cc WITH(NOLOCK)
							WHERE cc.Id = @IdCartaoCredito)
			BEGIN
				RETURN 1
			END
		ELSE 
		BEGIN
			UPDATE [dbo].[CartaoCredito]
				SET Id_StatusCartaoCredito = 3
				WHERE Id = @IdCartaoCredito

			IF @@ROWCOUNT = 1 
				RETURN 0
			ELSE 
				RETURN 2
		END
	END
GO