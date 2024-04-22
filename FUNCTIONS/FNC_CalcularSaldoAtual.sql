USE SistemaBancario
GO

CREATE OR ALTER FUNCTION [dbo].[FNC_CalcularSaldoAtual](
														 @Id_Conta INT = NULL, 
														 @Vlr_SldInicial DECIMAL(15,2) = NULL, 
														 @Vlr_Credito DECIMAL(15,2) = NULL, 
														 @Vlr_Debito DECIMAL(15,2) = NULL
														)
	 RETURNS  DECIMAL(15,2)
	 AS 
	 /*
		Documentação
		Arquivo Fonte.....: FNC_CalcularSaldoAtual.sql
		Objetivo..........: Listar o saldo atual de todas as contas ou uma conta especifica
		Autor.............: Adriel Alexsander 
 		Data..............: 02/04/2024
		ObjetivoAlt.......: N/A
		AutorAlt..........: N/A
		DataAlt...........: N/A
		Ex................: DBCC DROPCLEANBUFFERS;
							DBCC FREEPROCCACHE;
								
							DECLARE @Dat_ini DATETIME = GETDATE()
							SELECT	[dbo].[FNC_CalcularSaldoAtual](NULL,200,500,100) AS Resultado,
									DATEDIFF(millisecond, @Dat_ini, GETDATE()) AS Tempo_Execucao	
	*/
	BEGIN
		  --Verificar ID nulo
		IF(@Id_Conta IS NOT NULL)
			--Recuperar Valores 
			BEGIN
				SELECT @Vlr_SldInicial = Vlr_SldInicial,
					   @Vlr_Credito = Vlr_Credito,
					   @Vlr_Debito = Vlr_Debito
					FROM [dbo].[Contas] WITH(NOLOCK)
					WHERE Id = @Id_Conta
			END
			--Caso do Id nulo, vai usar os demais valores passados como parâmetros
		RETURN @Vlr_SldInicial + @Vlr_Credito - @Vlr_Debito
	END
GO