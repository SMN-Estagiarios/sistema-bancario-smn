USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularTaxaEmprestimo]	(
																@Id_Cta INT	
															)
	RETURNS DECIMAL(5,4)
	AS
	/*
	Documentação
		Arquivo Fonte.........: FNC_CalcularTaxaEmprestimo.sql
		Objetivo..............: Calcular a taxa total que será utilizada para realizar um empréstimo
		Autor.................: João Victor Maia, Rafael Maurício, Odlavir Florentino
		Data..................: 23/04/2024
		Ex....................: BEGIN TRAN
									UPDATE [dbo].[Contas]
										SET Id_CreditScore = 1
										WHERE Id = 1
									SELECT [dbo].[FNC_CalcularTaxaEmprestimo](1)
								ROLLBACK TRAN
								
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @IOF DECIMAL(5,4),
				@TaxaEmprestimo DECIMAL(5,4),
				@TaxaTotal DECIMAL(5,4),
				@DataAtual DATE = GETDATE()
		--Atribuir valor ao IOF
		SELECT @IOF = Aliquota
			FROM [dbo].[ValorTaxa] WITH(NOLOCK)
			WHERE Id = 2
		--Atribuir valor a TaxaEmprestimo
		SELECT @TaxaEmprestimo = vte.Aliquota
			FROM [dbo].[Contas] c
				INNER JOIN [ValorTaxaEmprestimo] vte
					ON c.Id_CreditScore = vte.Id_CreditScore
			WHERE	c.Id = @Id_Cta
					AND vte.DataInicial <= @DataAtual
		--Calcular a taxa total
		SET @TaxaTotal = @IOF + @TaxaEmprestimo
		RETURN @TaxaTotal
	END
GO