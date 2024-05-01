CREATE OR ALTER PROCEDURE [dbo].[SP_ListarParcelas]
	@Id_Emprestimo INT = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.........:	Parcelas.sql
		Objetivo..............: Listar todas as parcelas de empréstimos
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: DECLARE @Dat_ini DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarParcelas]

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		SELECT	Id,
				Id_Emprestimo,
				Id_Lancamento,
				Id_ValorIndice,
				Valor,
				ValorJurosAtraso,
				Data_Cadastro
			FROM [dbo].[Parcela] WITH(NOLOCK)
			WHERE Id_Emprestimo = ISNULL(@Id_Emprestimo, Id_Emprestimo)
	END
GO