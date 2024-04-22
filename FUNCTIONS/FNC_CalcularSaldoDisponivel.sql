USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoDisponivel](
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
		Arquivo Fonte.........: FNC_CalcularSaldoDisponivel.sql
		Objetivo..............: Calcular o saldo disponível de uma conta específica
		Autor.................: Orcino Neto, Odlavir Florentino e Pedro Avelino
		Data..................: 11/04/2024
		EX....................: BEGIN TRAN
									SELECT [dbo].[FNC_CalcularSaldoDisponivel](NULL, 10, 20, 10, 100)
								ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @Resultado DECIMAL(15,2)
		
		-- Identificar caminho
			IF (@Id_Conta IS NOT NULL)
				BEGIN
					SELECT	@SaldoInicial = Vlr_SldInicial,
							@Credito = Vlr_Credito,
							@Debito = Vlr_Debito,
							@LimiteCredito = Lim_ChequeEspecial
						FROM [dbo].[Contas] WITH(NOLOCK)
						WHERE Id = @Id_Conta
				END

			-- Realizar o calculo
			SET @Resultado = (@SaldoInicial + @Credito - @Debito + @LimiteCredito)

			-- Retornar o resultado
			RETURN @Resultado
	END
GO