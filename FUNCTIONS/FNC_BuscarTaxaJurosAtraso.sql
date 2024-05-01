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
		Ex................:	BEGIN TRAN
								DECLARE @Id_Emp INT;

								EXEC [dbo].[SP_RealizarEmprestimo] 1, 1000, 5, 'PRE'

								SELECT	Id,
										Id_Conta,
										Id_StatusEmprestimo,
										Id_ValorTaxaEmprestimo,
										Id_Indice,
										Id_PeriodoIndice,
										ValorSolicitado,
										NumeroParcelas,
										Tipo,
										DataInicio
									FROM [dbo].[Emprestimo] WITH(NOLOCK)

								SELECT	TOP 1 @Id_Emp = Id
									FROM [dbo].[Emprestimo] WITH(NOLOCK)

								SELECT [dbo].[FNC_BuscarTaxaJurosAtraso](@Id_Emp)
							ROLLBACK TRAN
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