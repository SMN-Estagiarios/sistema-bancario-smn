CREATE OR ALTER FUNCTION [dbo].[FNC_ListarParcelasEmprestimo]()
	RETURNS @Tabela TABLE(
							QuantidadeParcela TINYINT
						 )
	AS
	/*
		Documentação
		Arquivo Fonte.........: Emprestimos.sql
		Objetivo..............: Listar as possíveis quantidade de parcelas para efetuar empréstimos
		Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
		Data..................: 23/04/2024
		Ex....................: DBCC DROPCLEANBUFFERS
								DECLARE @Dat_ini DATETIME = GETDATE()

								SELECT QuantidadeParcela 
									FROM [dbo].[FNC_ListarParcelasEmprestimo]()

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS Tempo
	*/ 
	BEGIN
	
		--Declarar variáveis
		DECLARE @Mes TINYINT = 1
		--Criar e popular tabela com a quantidade de parcelas
		WHILE @Mes <= 72
			BEGIN
				IF @Mes <= 12 OR @Mes = 24 OR @Mes = 36 OR @Mes = 48 OR @Mes = 60 OR @Mes = 72
					BEGIN
						INSERT INTO @Tabela VALUES(@Mes)
					END
				SET @Mes = @Mes + 1
			END
		
		RETURN
	END
GO