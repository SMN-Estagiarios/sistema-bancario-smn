USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_ListarSimulacaoEmprestimo](
																@Id_Cta INT,
																@ValorSolicitado DECIMAL(15,2)
															  )
	RETURNS @Tabela TABLE(
							Parcelas TINYINT,
							PrecoParcela DECIMAL(6,2)
						 )
	AS
	/*
		Documentação
		Arquivo Fonte.........: FNC_ListarSimulacaoEmprestimo.sql
		Objetivo..............: Listar uma simulação de empréstimo do valor passado como parâmetro. Será listado o valor
								das parcelas mensais e a quantidade das mesmas
		Autor.................: João Victor Maia, Odlavir Florentino, Rafael Maurício
		Data..................: 29/04/2024
		Ex....................: BEGIN TRAN
									DBCC FREEPROCCACHE
									DECLARE @Dat_ini DATETIME = GETDATE()

									UPDATE [dbo].[Contas]
										SET Id_CreditScore = 1
										WHERE Id = 1

									SELECT	Parcelas,
											Precoparcela
										FROM [dbo].[FNC_ListarSimulacaoEmprestimo](1, 1000)
								
									SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao
								ROLLBACK TRAN
	*/
	BEGIN
		--Declarar variáveis
		DECLARE @TaxaTotal DECIMAL(5,4)
		
		--Pegar TaxaTotal da Conta
		SELECT @TaxaTotal = [dbo].[FNC_CalcularTaxaEmprestimo](@Id_Cta)

		--Listar a simulação de empréstimo em que o valor da parcela seja maior que 100
		INSERT INTO @Tabela 
			SELECT	QuantidadeParcela AS TotalParcelas,
					@ValorSolicitado * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - QuantidadeParcela)) AS PrecoParcela
			FROM [dbo].[FNC_ListarParcelasEmprestimo]()
			WHERE	@ValorSolicitado * @TaxaTotal / (1 - POWER(1 + @TaxaTotal, - QuantidadeParcela)) > 100
		RETURN 
	END
GO