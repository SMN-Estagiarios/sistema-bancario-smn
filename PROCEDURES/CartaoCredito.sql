CREATE OR ALTER PROCEDURE [dbo].[SP_InserirNovoCartaoCredito]
	@IdCorrentista INT,
	@IdConta INT
	AS
	/*
	Documentacao
	Arquivo Fonte.....: Contas.sql
	Objetivo..........: Cria uma conta na tabela [dbo].[Contas]
	Autor.............: Adriel Alexsander, Isabela Tragante, Thays Carvalho
	Data..............: 02/04/2024
	Ex................: BEGIN TRAN
							DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;

							DECLARE @RET INT, 
							@Dat_init DATETIME = GETDATE()

							SELECT * FROM CartaoCredito;
							
							EXEC [dbo].[SP_InserirNovoCartaoCredito] 2, 2

							SELECT * FROM CartaoCredito;

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
				@DiaVencimento TINYINT

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

		-- Restrição para criação do cartão baseado no credit score.
		-- Aplicar limite de crédito baseado no credit score
		-- Lógica para setar o DiaVencimento

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

	-- Criar novo cartão
		INSERT INTO CartaoCredito (Id_Conta, Id_StatusCartaoCredito, NomeImpresso, Numero, Cvc, Limite, DataEmissao, DataValidade, Aproximacao, DiaVencimento)
							VALUES(@IdConta, 1, @NomeCorrentista, @NumeroCartao, @NumeroCVC, 1000, @DataAtual, @DataValidade, 1, 10)
	END
GO
