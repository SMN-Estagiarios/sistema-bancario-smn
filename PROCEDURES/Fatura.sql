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
									SELECT * FROM Fatura
									EXEC [dbo].[SP_GerarFatura] 2
									SELECT * FROM Fatura
									ROLLBACK TRAN

			*/
	BEGIN

	IF NOT EXISTS (SELECT TOP 1 1
								FROM [dbo].[CartaoCredito]cc WITH(NOLOCK)
									INNER JOIN [dbo].[Contas]c WITH(NOLOCK)
										ON cc.Id_Conta = c.Id
								WHERE cc.Id_Conta = @IdConta)
		BEGIN 
			RETURN 1
		END

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
		

	DECLARE		@DataEmissao DATETIME = GETDATE()-5,
						@DiaVencimento INT,
						@DataVencimento DATETIME;

	DECLARE @DataValidacao INT = DAY(@DataEmissao)

	SET @DiaVencimento = (SELECT DiaVencimento 
												FROM [dbo].[CartaoCredito]
												WHERE Id_Conta = @IdConta)
		

	IF @DataValidacao+5 >= @DiaVencimento
		BEGIN			
			SET @DataVencimento = DATEFROMPARTS(YEAR(DATEADD(MONTH,1,@DataEmissao)),  MONTH(DATEADD(MONTH,1,@DataEmissao)), @DiaVencimento)
		END

      ELSE
		BEGIN
			SET @DataVencimento = DATEFROMPARTS(YEAR(@DataEmissao),MONTH(@DataEmissao), @DiaVencimento);
	  END
		
	
	INSERT INTO [dbo].[Fatura]	(Id_StatusFatura, Id_Conta, CodigoBarra, DataEmissao, DataVencimento) VALUES
												(1, @IdConta, 1243213213, @DataEmissao, @DataVencimento)												

	END
GO