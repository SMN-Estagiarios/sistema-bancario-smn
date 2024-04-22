USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarSaldo]
	ON [dbo].[Lancamentos]
	AFTER INSERT
AS
	/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_AtualizarSaldo.sql
		Objetivo.............:	Atualizar Saldo da tabela [dbo].[Contas]
		Autor................:	Adriel Alexander
		Data.................:	05/04/2024
		Ex...................: BEGIN TRAN
									DBCC DROPCLEANBUFFERS;
									DBCC FREEPROCCACHE;

									DECLARE @DATA_INI DATETIME = GETDATE();

									SELECT	Id,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]
										WHERE Id = 1

										SELECT * FROM [dbo].[Lancamentos]

									INSERT INTO Lancamentos(Id_Cta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
										VALUES (1, 1, 5, NULL, 'C', 2000, 'TESTE TRIGGER', '2024-04-12', 0)

									SELECT DATEDIFF(MILLISECOND, @DATA_INI,GETDATE()) AS Execução

									SELECT	Id,
											Vlr_SldInicial,
											Vlr_Credito,
											Vlr_Debito,
											Dat_Saldo 
										FROM [dbo].[Contas]
										WHERE Id = 1

										SELECT * FROM [dbo].[Lancamentos]
								ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @Tipo_Lancamento CHAR(1),
				@Data_Lanc DATETIME,
				@Vlr_Lancamento DECIMAL(15,2);
			 
		--ATRIBUINDO VALORES AS VARIÁVEIS 
		SELECT	@Tipo_Lancamento = Tipo_Operacao,
				@Data_Lanc = Dat_Lancamento, 
				@Vlr_Lancamento = Vlr_Lanc
			FROM INSERTED

		UPDATE [dbo].[Contas] 
			SET Vlr_SldInicial = (CASE	WHEN @Data_Lanc < Dat_Saldo 
										THEN Vlr_SldInicial + 
															(CASE WHEN @Tipo_Lancamento = 'C' 
																THEN @Vlr_Lancamento
																ELSE @Vlr_Lancamento* (-1)
															END)
										ELSE Vlr_SldInicial 
									END),

				Vlr_Credito = (CASE WHEN @Data_Lanc < Dat_Saldo  OR @Tipo_Lancamento = 'D' 
									THEN Vlr_Credito
										ELSE (Vlr_Credito + @Vlr_Lancamento) 
								END),


				Vlr_Debito = (CASE	WHEN @Data_Lanc < Dat_Saldo  OR @Tipo_Lancamento = 'C' 
									THEN Vlr_Debito
										ELSE(Vlr_Debito + @Vlr_Lancamento)END)
			WHERE Id IN (SELECT Id_Cta FROM INSERTED)
	END



