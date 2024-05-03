USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ListarValorAtualTaxaEmprestimo]	(@IdTaxaEmprestimo INT, @IdCreditScore INT)
	RETURNS @Tabela TABLE(	
							IdValorTaxaEmprestimo INT, 
							IdTaxaEmprestimo TINYINT, 
							Nome VARCHAR(50), 
							Valor DECIMAL(6,5), 
							DataValidade DATE
						)
AS
		/*
            Documentação
            Arquivo Fonte.....: FNC_ListarValorAtualTaxaEmprestimo.sql
            Objetivo..........: Listar a taxa vigente na data de consulta para os empréstimos
            Autor.............: Gustavo Targino, Danyel Targino e Thays Carvalho
            Data..............: 23/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE()

									SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaEmprestimo](1, 8)

									INSERT INTO ValorTaxaEmprestimo (Id_TaxaEmprestimo, Id_CreditScore, Aliquota, DataInicial) VALUES
														 (1, 8, 0.10, GETDATE()-1)
								   
									SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaEmprestimo](1, 8)
								    
                                    SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao

									SELECT * FROM ValorTaxaEmprestimo
                                ROLLBACK TRAN
		*/

	BEGIN
		--Declarar variavel de data para hoje
		DECLARE @DataAtual DATE = GETDATE()

		-- Inserir na tabela da função o Id do registro, Id da taxa do empréstimo, nome da taxa do empréstimo, alíquota, e data inicial de vigência para a função retornar
		INSERT INTO @Tabela
            SELECT TOP 1 vte.Id,
						 te.Id,
						 te.Nome,
						 vte.Aliquota,
						 vte.DataInicial
				FROM [dbo].[TaxaEmprestimo] te WITH(NOLOCK)
					INNER JOIN [dbo].[ValorTaxaEmprestimo] vte WITH(NOLOCK)
						ON te.Id = vte.Id_TaxaEmprestimo
				WHERE	vte.DataInicial <= @DataAtual 
						AND vte.Id_TaxaEmprestimo = @IdTaxaEmprestimo
						AND vte.Id_CreditScore = @IdCreditScore
				ORDER BY vte.DataInicial DESC
		RETURN

	END