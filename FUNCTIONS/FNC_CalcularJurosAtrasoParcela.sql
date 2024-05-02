USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularJurosAtrasoParcela]	(
																	@Id_Emprestimo INT,
																	@Valor_Parcela DECIMAL(15,2),
																	@Dias_Atrasados INT
																)
	RETURNS DECIMAL(6,5)
	AS
	/*
		Documentacao:
		Arquivo Fonte.....: FNC_CalcularJurosAtrasoParcela.sql
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

								SELECT [dbo].[FNC_CalcularJurosAtrasoParcela](@Id_Emp, 400, 1)
							ROLLBACK TRAN
	*/

	BEGIN
		DECLARE @Id_CreditScore INT,
				@ValorTaxa DECIMAL(6,5),
				@Juros DECIMAL(15,2);

		SELECT @Id_CreditScore = c.Id_CreditScore
			FROM [dbo].[Contas] c WITH(NOLOCK)
				INNER JOIN [dbo].[Emprestimo] e WITH(NOLOCK)
					ON e.Id_Conta = c.Id
			WHERE e.Id = @Id_Emprestimo;

		SELECT	@ValorTaxa = Valor
			FROM FNC_ListarValorAtualTaxaEmprestimo(2, @Id_CreditScore)

		SET @Juros = @Valor_Parcela * @Dias_Atrasados * @ValorTaxa
		RETURN ISNULL(@Juros, 0)
	END