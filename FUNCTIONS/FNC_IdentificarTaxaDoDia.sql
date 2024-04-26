USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_IdentificarTaxaDoDia]	(
																	@IdTaxa INT,
																	@DataAtual DATE = NULL
																)
	RETURNS @Tabela TABLE	(
								Id INT NOT NULL,
								Id_Taxa INT NOT NULL,
								Aliquota DECIMAL(6,5) NOT NULL,
								Data_Taxa DATE NOT NULL
							)
	AS
	/*
		Documentacao
		Arquivo Fonte.....: FNC_IdentificarTaxaDoDia.sql
		Objetivo..........: Identificar qual o id e valor da taxa no dia solicitado
		Autor.............: Odlavir Florentino
		Data..............: 26/04/2024
		EX................: BEGIN TRAN
								DBCC FREEPROCCACHE
								DBCC DROPCLEANBUFFERS

								DECLARE @Data_Ini DATETIME = GETDATE()

								SELECT * FROM [dbo].[FNC_IdentificarTaxaDoDia](1, '2024-03-14') AliquotaVigente;

								SELECT DATEDIFF(MILLISECOND, @Data_Ini, GETDATE()) AS TempoExecucao;
							ROLLBACK TRAN
	*/
	BEGIN
		SET @DataAtual = ISNULL(@DataAtual, GETDATE());
				
		INSERT INTO @Tabela (Id, Id_Taxa, Aliquota, Data_Taxa)
			SELECT TOP 1	VT.Id,
							T.Id,
							VT.Aliquota,
							VT.DataInicial
				FROM [dbo].[Taxa] T WITH(NOLOCK)
					INNER JOIN [dbo].[ValorTaxa] VT WITH(NOLOCK)
						ON T.Id = VT.Id_Taxa
				WHERE	T.Id = 1 AND
						VT.DataInicial < @DataAtual
				ORDER BY VT.DataInicial DESC;
		RETURN;
	END