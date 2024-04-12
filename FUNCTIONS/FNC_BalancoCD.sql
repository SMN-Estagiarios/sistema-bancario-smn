CREATE OR ALTER FUNCTION [DBO].[FNC_BalancoCD]()
	RETURNS @Tabela TABLE(
								Id_Conta INT NOT NULL,
								Credito DECIMAL(15,2) NOT NULL,
								Debito DECIMAL(15,2) NOT NULL,
								DataBalanco DATETIME NOT NULL
							)
	AS
		/*
			Documentação
			Arquivo Fonte.....: FNC_BalancoCD.sql
			Objetivo.............: Calcular todo o balanço de crédito e debito de uma conta desde o primeiro lançamento
			Autor.................: Orcino Neto, Odlavir Florentino e Pedro Avelino
			Data..................: 11/04/2024
			EX.....................: BEGIN TRAN
											SELECT * FROM [DBO].[FNC_BalancoCD]()
										ROLLBACK TRAN
		*/

	BEGIN
		INSERT INTO @Tabela  SELECT	Id_Cta,
														ISNULL(SUM(CASE WHEN Tipo_Lanc = 'C' THEN Vlr_Lanc END), 0.00) Credito,
														ISNULL(SUM(CASE WHEN Tipo_Lanc = 'D' THEN Vlr_Lanc END), 0.00) Debito,
														Dat_Lancamento
												FROM [DBO].[Lancamentos] WITH(NOLOCK)												
												GROUP BY Id_Cta, Dat_Lancamento
		RETURN 
	END