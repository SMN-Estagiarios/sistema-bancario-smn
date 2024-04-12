CREATE OR ALTER FUNCTION [DBO].[FNC_SaldoDisponivel](
																								@Id_Conta INT,
																								@SaldoInicial DECIMAL(15,2),
																								@Credito DECIMAL(15,2),
																								@Debito DECIMAL(15,2),
																								@LimiteCredito DECIMAL(15,2)
																							)
	RETURNS DECIMAL(15,2)
	AS
		/*
			Documentação
			Arquivo Fonte.....: FNC_SaldoDisponivel.sql
			Objetivo.............: Calcular o saldo disponível de uma conta específica
			Autor.................: Orcino Neto, Odlavir Florentino e Pedro Avelino
			Data..................: 11/04/2024
			EX.....................: BEGIN TRAN
											SELECT [DBO].[FNC_SaldoDisponivel](NULL, 10, 20, 10, 100)
										ROLLBACK TRAN
		*/

	BEGIN
		DECLARE @RESULTADO DECIMAL(15,2)
		
		-- Identificar caminho
		IF (@Id_Conta IS NOT NULL)
			BEGIN
				SELECT	@SaldoInicial = Vlr_SldInicial,
							@Credito = Vlr_Credito,
							@Debito = Vlr_Debito,
							@LimiteCredito = Lim_ChequeEspecial
					FROM [DBO].[Contas] WITH(NOLOCK)
					WHERE Id = @Id_Conta
			END

		-- Realizar o cálculo
		SET @RESULTADO = (@SaldoInicial + @Credito - @Debito + @LimiteCredito)

		-- Retornar o resultado
		RETURN @RESULTADO
	END