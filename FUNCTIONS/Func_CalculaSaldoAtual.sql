USE SistemaBancario
GO
CREATE OR ALTER FUNCTION [dbo].[Func_CalculaSaldoAtual](
														@Id_Conta INT = NULL, 
														@Vlr_SldInicial DECIMAL(15,2) = NULL, 
														@Vlr_Credito DECIMAL(15,2) = NULL, 
														@Vlr_Debito DECIMAL(15,2) = NULL)
	 RETURNS  DECIMAL(15,2)
	 AS 
	 /*
			Documentação
			Arquivo Fonte.....: Func_CalculaSaldoAtual.sql
			Objetivo..........: Listar o saldo atual de todas as contas ou uma conta específica
			Autor.............: Adriel Alexsander 
 			Data..............: 02/04/2024
			ObjetivoAlt.......: N/A
			AutorAlt..........: N/A
			DataAlt...........: N/A
			Ex................: DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;
								
								DECLARE @dat_ini DATETIME = GETDATE()
								
								SELECT [dbo].[Func_CalculaSaldoAtual](1,200,500,100) AS resultado,
									   DATEDIFF(millisecond, @dat_ini, GETDATE()) AS EXECUCAO	
	*/
	BEGIN
		  --verificar se o id é nulo
		IF(@Id_Conta IS NOT NULL )
			--Recuperar Valores 
			BEGIN
				SELECT @Vlr_SldInicial = Vlr_SldInicial ,
					   @Vlr_Credito = Vlr_Credito,
					   @Vlr_Debito = Vlr_Debito
					  FROM [dbo].[Contas]
					  WHERE Id = @Id_Conta
			END
			--caso do id nulo usará os demais valores passados como parâmetros
		RETURN @Vlr_SldInicial + @Vlr_Credito - @Vlr_Debito
	END

GO