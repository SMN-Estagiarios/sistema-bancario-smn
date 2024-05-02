USE SistemaBancario;
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarLimiteComprometidoAposPagamento]
	ON [dbo].[Fatura]
	AFTER UPDATE	
	AS
	/*
	Documentacao
	Arquivo Fonte:....: TRG_AtualizarLimiteComprometidoAposPagamento.sql
	Objetivo:.........: Atualiza o limite comprometido do cartão quando e gerado um pagamento na fatura
	Autor:............: Isabella Tragante, Olívio Freitas e Orcino Ferreira
	Data:.............: 01/05/2024
	Exemplo:..........: BEGIN TRAN
							DECLARE @Dat_init DATETIME = GETDATE(),
									@RET INT
							
							SELECT TOP 10 * FROM CartaoCredito
							SELECT TOP 10 * FROM Lancamentos	
							SELECT TOP 10 * FROM Fatura

							EXEC @RET = [dbo].[SPJOB_PagamentoFatura]

							SELECT TOP 10 * FROM Lancamentos
							SELECT TOP 10 * FROM Fatura
							SELECT TOP 10 * FROM CartaoCredito

	
							SELECT	@RET AS RETORNO,
									DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
						ROLLBACK TRAN
	*/
	BEGIN
		-- Declaro as variáveis que preciso
		DECLARE @ValorPagamento DECIMAL(15,2),
				@IdCartao INT

		-- Capturo os valores que preciso
		SELECT	@IdCartao = Id_CartaoCredito,
				@ValorPagamento = Vlr_Fatura
			FROM inserted;

		-- Subtraio o campo limiteComprometido
		UPDATE CartaoCredito
			SET LimiteComprometido = LimiteComprometido - @ValorPagamento
			WHERE Id = @IdCartao
	END
GO