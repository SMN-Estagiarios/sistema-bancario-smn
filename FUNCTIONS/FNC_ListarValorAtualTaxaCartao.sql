CREATE OR ALTER FUNCTION [dbo].[FNC_ListarValorAtualTaxaCartao](@IdTaxaCartao INT)
	RETURNS @Tabela TABLE(IdValorTaxaCartao INT, IdTaxaCartao TINYINT, Nome VARCHAR(50), Valor DECIMAL(6,5), DataValidade DATE)
AS
		/*
            Documentação
            Arquivo Fonte.....: FNC_ListarValorAtualTaxaCartao.sql
            Objetivo..........: Listar a taxa ou valor vigente na data de consulta para uma tarifa
            Autor.............: Gustavo Targino, Danyel Targino e Thays Carvalho
            Data..............: 26/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE();
									
                                   SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaCartao](1)
								   
								   INSERT INTO ValorTaxaCartao (Id_TaxaCartao, Aliquota, DataInicial) VALUES
															   (1, 0.00500, GETDATE()-1)

									 SELECT * FROM [dbo].[FNC_ListarValorAtualTaxaCartao](1)

                                    SELECT 
                                            DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/

	BEGIN
		
		DECLARE @DataAtual DATE = GETDATE()

		INSERT INTO @Tabela
            SELECT TOP 1 vtc.Id,
						 tc.Id,
						 tc.Nome,
						 vtc.Aliquota,
						 vtc.DataInicial
				FROM [dbo].[TaxaCartao] tc WITH(NOLOCK)
					INNER JOIN [dbo].[ValorTaxaCartao] vtc WITH(NOLOCK)
						ON tc.Id = vtc.Id_TaxaCartao
				WHERE vtc.DataInicial <= @DataAtual 
				AND vtc.Id_TaxaCartao = @IdTaxaCartao
				ORDER BY vtc.DataInicial DESC
		RETURN
	END


	