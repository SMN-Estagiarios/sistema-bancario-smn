USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ListarValorAtualTaxa](@IdTaxa INT)
	RETURNS @Tabela TABLE(IdValorTaxa INT, IdTaxa TINYINT, Nome VARCHAR(50), Valor DECIMAL(6,5), DataValidade DATE)
AS
		/*
            Documenta��o
            Arquivo Fonte.....: FNC_ListarValorAtualTaxa.sql
            Objetivo..........: Listar a taxa vigente na data de consulta
            Autor.............: Gustavo Targino, Danyel Targino e Thays Carvalho
            Data..............: 23/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE()

									SELECT * FROM [dbo].[FNC_ListarValorAtualTaxa](2)

									INSERT INTO ValorTaxa (Id_Taxa, Aliquota, DataInicial) VALUES
														 (2, 0.00500, GETDATE()-1)
								   
								    SELECT * FROM [dbo].[FNC_ListarValorAtualTaxa](2)

                                    SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/

	BEGIN
		
		--Declarar variavel de data para hoje
		DECLARE @DataAtual DATE = GETDATE()

		-- Inserir na tabela da fun��o o Id do registro, Id da taxa, nome da taxa, al�quota, e data inicial de vig�ncia para a fun��o retornar
		INSERT INTO @Tabela
            SELECT TOP 1 vt.Id,
						 t.Id,
						 t.Nome,
						 vt.Aliquota,
						 vt.DataInicial
				FROM [dbo].[Taxa] T WITH(NOLOCK)
					INNER JOIN [dbo].[ValorTaxa] vt WITH(NOLOCK)
						ON T.Id = vt.Id_Taxa
				WHERE vt.DataInicial <= @DataAtual 
					AND T.Id = @IdTaxa
				ORDER BY vt.DataInicial DESC
		RETURN

	END