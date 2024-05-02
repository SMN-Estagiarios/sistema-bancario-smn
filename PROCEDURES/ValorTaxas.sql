CREATE OR ALTER PROCEDURE [dbo].[SP_ListarValorTaxas]
	AS
	/*
		Documentação
		Arquivo Fonte.........:	ValorTaxas.sql
		Objetivo..............: Listar todos os valores de taxas registradas
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: DECLARE @Dat_ini DATETIME = GETDATE()

								EXEC [dbo].[SP_ListarValorTaxas]

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
	*/
	BEGIN
		SELECT	Id,
				Id_Taxa,
				Aliquota,
				DataInicial
			FROM [dbo].[ValorTaxa] WITH(NOLOCK)
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_AtualizarValorTaxas]
	@Id TINYINT,
	@Id_Taxa TINYINT = NULL,
	@Aliquota DECIMAL(6,5) = NULL,
	@DataInicial DATE = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.........:	ValorTaxas.sql
		Objetivo..............: Atualizar um valor de taxa
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: BEGIN TRAN
									DECLARE @Dat_ini DATETIME = GETDATE()

									EXEC [dbo].[SP_AtualizarValorTaxas] 1, 2, 0.0605
									EXEC [dbo].[SP_ListarValorTaxas]

									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
	UPDATE [dbo].[ValorTaxa]
		SET Id_Taxa = @Id_Taxa,
			Aliquota = @Aliquota,
			DataInicial = ISNULL(@DataInicial, GETDATE())
		WHERE Id = @Id
	END
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ExcluirValorTaxas]
	@Id TINYINT = NULL,
	@Id_Taxa TINYINT = NULL,
	@Aliquota DECIMAL(6,5) = NULL,
	@DataInicial DATE = NULL
	AS
	/*
		Documentação
		Arquivo Fonte.........:	ValorTaxas.sql
		Objetivo..............: Excluir um valor de taxa
		Autor.................: Odlavir Florentino, João Victor, Rafael Maurício
		Data..................: 01/05/2024
		Ex....................: BEGIN TRAN
									DECLARE @Dat_ini DATETIME = GETDATE()

									EXEC [dbo].[SP_ExcluirValorTaxas] 1
									EXEC [dbo].[SP_ListarValorTaxas]

									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
	DELETE FROM	[dbo].[ValorTaxa]
		WHERE	Id = ISNULL(@Id, NULL)
				OR @Id_Taxa = ISNULL(@Id_Taxa, NULL)
				OR @Aliquota = ISNULL(@Aliquota, NULL)
				OR @DataInicial = ISNULL(@DataInicial, NULL)
	END
GO