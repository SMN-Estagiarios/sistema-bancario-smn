CREATE OR ALTER FUNCTION [dbo].[FNC_ListarValorAtualTaxaEmprestimo](@IdTaxaEmprestimo INT, @IdCreditScore INT)
	RETURNS @Tabela TABLE(IdValorTaxaEmprestimo INT, IdTaxaEmprestimo TINYINT, Nome VARCHAR(50), Valor DECIMAL(6,5), DataValidade DATE)
AS
		/*
            Documentação
            Arquivo Fonte.....: FNC_ListarValorAtualTaxaEmprestimo.sql
            Objetivo..........: Listar a taxa ou valor vigente na data de consulta para uma tarifa
            Autor.............: Gustavo Targino, Danyel Targino e Thays Carvalho
            Data..............: 26/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE();
									
									SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaEmprestimo](1, 8)

									INSERT INTO ValorTaxaEmprestimo (Id_TaxaEmprestimo, Id_CreditScore, Aliquota, DataInicial) VALUES
																   (1, 8, 0.04500, GETDATE()-1);

									SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaEmprestimo](1, 8)

									SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaEmprestimo](2, 8)

                                    SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/

	BEGIN
		
		DECLARE @DataAtual DATE = GETDATE()

		INSERT INTO @Tabela
            SELECT TOP 1 vte.Id,
						 te.Id,
						 te.Nome,
						 vte.Aliquota,
						 vte.DataInicial
				FROM [dbo].[TaxaEmprestimo] te WITH(NOLOCK)
					INNER JOIN [dbo].[ValorTaxaEmprestimo] vte WITH(NOLOCK)
						ON te.Id = vte.Id_TaxaEmprestimo
				WHERE vte.DataInicial <= @DataAtual 
				AND vte.Id_TaxaEmprestimo = @IdTaxaEmprestimo
				AND vte.Id_CreditScore = @IdCreditScore
				ORDER BY vte.DataInicial DESC
		RETURN

	END