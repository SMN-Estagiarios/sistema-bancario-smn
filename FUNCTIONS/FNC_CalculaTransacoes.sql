CREATE OR ALTER FUNCTION [dbo].[FNC_CalculaTransacoes](
    @Id_CartaoCredito INT
)

	RETURNS DECIMAL(15, 2)

	AS
		/*
			Documentação
			Arquivo fonte....: FNC_CalculaTransacoes.sql
			Objetivo...........: Somar todas as transações daquele cartao especifco naquele mês onde a fatura esteja fechada.
			Autor................: Isabella Siqueira, Olivio Freitas, Orcino Neto.
			Data................: 29/04/2024.
			Ex....................:
										BEGIN TRAN
											DBCC DROPCLEANBUFFERS;
											DBCC FREEPROCCACHE;

											DECLARE	@RET INT,
															@Dat_ini DATETIME = GETDATE();											

											SELECT @RET = [dbo].[FNC_CalculaTransacoes](7);

											SELECT @RET AS RETORNO

											SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao;
											
										ROLLBACK TRAN			
		*/
	BEGIN
		DECLARE @Resultado DECIMAL(15,2)
			IF (@Id_CartaoCredito IS NOT NULL)
				BEGIN
					SELECT @Resultado = ISNULL(SUM(Valor_Trans), 0)
						FROM [dbo].[TransacaoCartaoCredito]tc WITH(NOLOCK)
						WHERE tc.Id_Fatura IS NULL	AND @Id_CartaoCredito = Id_CartaoCredito						
				END
			RETURN @Resultado
	END
GO