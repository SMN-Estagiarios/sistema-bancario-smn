USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularTaxaEmprestimo]	(
																@Id_Cta INT	
															)
	RETURNS DECIMAL(5,4)
	AS
	/*
	Documenta��o
		Arquivo Fonte.........: FNC_CalcularTaxaEmprestimo.sql
		Objetivo..............: Calcular a taxa total que ser� utilizada para realizar um empr�stimo
		Autor.................: Jo�o Victor Maia, Rafael Maur�cio, Odlavir Florentino
		Data..................: 23/04/2024
		Ex....................: BEGIN TRAN
									UPDATE [dbo].[Contas]
										SET Id_CreditScore = 1
										WHERE Id = 1
									SELECT [dbo].[FNC_CalcularTaxaEmprestimo](1)
								ROLLBACK TRAN
								
	*/
	BEGIN
		--Declarar vari�veis
		DECLARE @TaxaEmprestimo DECIMAL(5,4),
				@DataAtual DATE = GETDATE()
		
		--Atribuir valor a TaxaEmprestimo
		SELECT @TaxaEmprestimo = vte.Aliquota
			FROM [dbo].[Contas] c WITH(NOLOCK)
				INNER JOIN [ValorTaxaEmprestimo] vte WITH(NOLOCK)
					ON c.Id_CreditScore = vte.Id_CreditScore
			WHERE	c.Id = @Id_Cta
					AND vte.DataInicial <= @DataAtual
		--Retornar a taxa total
		RETURN @TaxaEmprestimo
	END
GO