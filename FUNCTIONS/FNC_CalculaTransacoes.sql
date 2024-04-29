CREATE OR ALTER FUNCTION [dbo].[FNC_CalculaTransacoes](
    @Id_Fatura INT
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

											SELECT @RET = [dbo].[FNC_CalculaTransacoes](1);

											SELECT @RET AS RETORNO

											SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao;
											
										ROLLBACK TRAN			
		*/
	BEGIN
		DECLARE @Resultado DECIMAL(15,2)
			IF (@Id_Fatura IS NOT NULL)
				BEGIN
					SELECT @Resultado = ISNULL(SUM(Valor_Trans), 0)
						FROM [dbo].[TransacaoCartaoCredito]cc WITH(NOLOCK)
							INNER JOIN [dbo].[Fatura] f WITH(NOLOCK)
								ON cc.Id_Fatura = f.Id
					WHERE @Id_Fatura = cc.Id_Fatura AND f.Id_StatusFatura = 2 
				END
			RETURN @Resultado
	END
GO