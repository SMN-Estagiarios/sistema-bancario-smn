CREATE OR ALTER FUNCTION [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa INT)
	RETURNS @Tabela TABLE(IdPrecoTarifas INT, IdTarifa INT, Nome VARCHAR(50), Valor DECIMAL(4,2), DataValidade DATE)
AS
		/*
            Documentação
            Arquivo Fonte.....: FNC_ListaValorAtualTarifa.sql
            Objetivo..........: Listar a taxa ou valor vigente na data de consulta para uma tarifa
            Autor.............: Gustavo Targino, Danyel Targino e Thays Carvalho
            Data..............: 23/04/2024
            EX................:	BEGIN TRAN
                                    DBCC DROPCLEANBUFFERS;
                                    DBCC FREEPROCCACHE;

                                    DECLARE @Dat_ini DATETIME = GETDATE();

									SELECT * FROM [dbo].[FNC_ListarValorAtualTarifa](4)

									INSERT INTO PrecoTarifas (Id_Tarifa, Valor, DataInicial) VALUES
															  (4, 0.005, GETDATE()-1)

									
									SELECT * FROM [dbo].[FNC_ListarValorAtualTarifa](4)

                                    SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
                                ROLLBACK TRAN
		*/

	BEGIN
		
		DECLARE @DataAtual DATE = GETDATE()

		INSERT INTO @Tabela
            SELECT TOP 1 P.Id,
						 T.Id,
						 T.Nome,
						 P.Valor,
						 P.DataInicial
				FROM [dbo].[Tarifas] T WITH(NOLOCK)
					INNER JOIN [dbo].[PrecoTarifas] P WITH(NOLOCK)
						ON T.Id = P.Id_Tarifa
				WHERE P.DataInicial <= @DataAtual 
				AND T.Id = @IdTarifa
				ORDER BY P.DataInicial DESC
		RETURN

	END
