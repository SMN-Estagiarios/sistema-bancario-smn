USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_BuscarTaxaJurosAtraso]	(
																@Id_Emprestimo INT
															)
	RETURNS DECIMAL(6,5)
	AS
	/*
		Documentacao:
		Arquivo Fonte.....: FNC_BuscarTaxaJurosAtraso.sql
		Objetivo..........: Buscar a taxa de juros de atraso atual para uma determinada conta
		Autor.............: Joao Victor, Odlavir Florentino, Rafael Mauricio
		Data..............: 29/04/2024
		Ex................:	SELECT [dbo].[FNC_BuscarTaxaJurosAtraso](29)
	*/

	BEGIN
		DECLARE @Id_CreditScore INT,
				@ValorTaxa DECIMAL(6,5)

		SELECT @Id_CreditScore = Id_CreditScore
			FROM [dbo].[Contas] C WITH(NOLOCK)
				INNER JOIN [dbo].[Emprestimo] E WITH(NOLOCK)
					ON E.Id_Conta = C.Id
			WHERE E.Id = @Id_Emprestimo;

		SELECT	@ValorTaxa = Valor
			FROM FNC_ListarValorAtualTaxaEmprestimo(2, @Id_CreditScore)

		RETURN ISNULL(@ValorTaxa, 0)
	END