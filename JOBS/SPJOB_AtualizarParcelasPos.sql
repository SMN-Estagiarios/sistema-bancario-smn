USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AtualizarParcelasPos]
	AS
	/*
		Documentacao
		Arquivo Fonte.....: SPJOB_AtualizarParcelasPos.sql
		Objetivo..........: Analisar se existem parcelas nulas para serem atualizadas
		Autor.............: Joao Victor, Odlavir Florentino e Rafael Mauricio
		Data..............: 30/04/2024
		Ex................:
	*/
	BEGIN
		IF EXISTS (SELECT TOP 1 1
						FROM [dbo].[Parcela]
						WHERE Valor IS NULL)
			BEGIN

				CREATE TABLE #Tabela	(
											Id_Parcela INT,
											Valor_Parcela DECIMAL(15,2),
											Numero_Parcelas INT,
											Valor_JurosAtraso DECIMAL(15,2),
											Id_Emprestimo INT,
											Id_ValorIndice INT,
											Valor_Solicitado DECIMAL(15,2),
											Data_Cadastro DATE
										)

				INSERT INTO #Tabela (	Id_Parcela,
										Valor_Parcela,
										Numero_Parcelas,
										Valor_JurosAtraso,
										Id_Emprestimo,
										Id_ValorIndice,
										Valor_Solicitado,
										Data_Cadastro
									)
					SELECT	P.Id,
							
						FROM [dbo].[Parcela] P WITH(NOLOCK)
							INNER JOIN [dbo].[Emprestimo] E	WITH(NOLOCK)
								ON P.Id_Emprestimo = E.Id
			END
	END