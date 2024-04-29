CREATE OR ALTER PROCEDURE [dbo].[SP_GerarFatura]
	@IdConta INT
	AS
			/*
			Documentacao
			Arquivo Fonte.....: Fatura.sql
			Objetivo..........: Gerar a fatura
			Autor.............: Isabella, Olivio e Orcino
 			Data..............: 26/04/2024
			Ex................:
								BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @RET INT, 
									@Dat_init DATETIME = GETDATE()

									SELECT * FROM Fatura
									EXEC @RET = [dbo].[SP_GerarFatura] 2
									SELECT * FROM Fatura

									SELECT @RET AS RETORNO,
									DATEDIFF(millisecond, @Dat_init, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN

			*/
	BEGIN
	--Verifica��o se n�o tem cartao de credito vinculado a conta.
	IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[CartaoCredito]cc WITH(NOLOCK)
									INNER JOIN [dbo].[Contas]c WITH(NOLOCK)
										ON cc.Id_Conta = c.Id
								WHERE cc.Id_Conta = @IdConta)
		BEGIN 
			RETURN 1
		END
	--Verifica��o se tem fatura vinculado aquela conta e se ela esta aberta.
	IF EXISTS (SELECT TOP 1 1
					FROM [dbo].[Fatura]f WITH(NOLOCK)
						INNER JOIN [dbo].[Contas]c WITH(NOLOCK)
							ON f.Id_Conta = c.Id
						INNER JOIN [dbo].[CartaoCredito]cc WITH(NOLOCK)
							ON c.Id = cc.Id_Conta
					WHERE f.Id_StatusFatura = 1 AND @IdConta = cc.Id_Conta)
		BEGIN
			RETURN 2
		END

	ELSE
	
	--Setando as variaveis para o calculo da geração de fatura mediante abertura e fechamento de fatura.
	DECLARE	@DataEmissao DATETIME = GETDATE(),
					@DataVencimento DATETIME,
					@DiaVencimento INT = (SELECT DiaVencimento 
														FROM [dbo].[CartaoCredito]
														WHERE Id_Conta = @IdConta);

	DECLARE @DataValidacao INT = DAY(@DataEmissao)		
	--Validação se o dia da geração da fatura seja maior ou igual ao dia do vencimento do cartao de credito.
	IF @DataValidacao+5 >= @DiaVencimento
		BEGIN			
			SET @DataVencimento = DATEFROMPARTS(YEAR(DATEADD(MONTH,1,@DataEmissao)),  MONTH(DATEADD(MONTH,1,@DataEmissao)), @DiaVencimento)
		END

      ELSE
		BEGIN
			SET @DataVencimento = DATEFROMPARTS(YEAR(@DataEmissao),MONTH(@DataEmissao), @DiaVencimento);
	  END
	--Verifica se o codigo de barras ja existe.	
	DECLARE @Barcode BIGINT = FLOOR(1000000000000000000 + RAND() * 8999999999999999999)
		WHILE @Barcode = (SELECT CodigoBarra
											FROM [dbo].[Fatura] WITH(NOLOCK)
											WHERE CodigoBarra = @Barcode)
				BEGIN
					SET @Barcode = FLOOR(1000000000000000000 + RAND() * 8999999999999999999)
				END

	INSERT INTO [dbo].[Fatura]	(Id_StatusFatura, Id_Conta, CodigoBarra, DataEmissao, DataVencimento) VALUES
												(1, @IdConta, @Barcode, @DataEmissao, @DataVencimento)												

	END
GO