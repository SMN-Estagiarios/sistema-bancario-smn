CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizarSaldo]
	ON [dbo].[Lancamentos]
	FOR INSERT
AS
	/*
		DOCUMENTAÇÃO
		Arquivo Fonte........:	TRG_AtualizarSaldo.sql
		Objetivo.............:	Atualizar Saldo da tabela [dbo].[Contas]
		Autor................:	Adriel Alexander
		Data.................:	05/04/2024
		Ex...................:		BEGIN TRAN
										DBCC DROPCLEANBUFFERS;
										DBCC FREEPROCCACHE;

										DECLARE @DATA_INI DATETIME = GETDATE();

										SELECT  Id,
												Id_Usuario,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
											FROM [dbo].[Contas]
											WHERE Id = 1

										INSERT INTO Lancamentos(Id_Cta, Id_Usuario, Id_Tarifa, Tipo_Lanc, Vlr_Lanc, Nom_Historico, Dat_Lancamento)
											VALUES (1,1,'C', 2000, 'TESTE TRIGGER', GETDATE())

										SELECT DATEDIFF(MILLISECOND, @DATA_INI,GETDATE()) AS Execução

										SELECT  Id,
												Id_Usuario,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
											FROM [dbo].[Contas]
											WHERE Id = 1
								ROLLBACK TRAN
	*/
	BEGIN
		DECLARE
				@Id_Conta INT,
    			@Tipo_Lancamento CHAR(1),
				@Data_Lanc DATETIME,
				@Vlr_Lancamento DECIMAL(15,2)
			 
		--ATRIBUINDO VALORES AS VARIÁVEIS 
			SELECT @Id_Conta = Id_Cta,
					@Tipo_Lancamento = Tipo_Lanc,
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
				WHERE Id = @Id_Conta
				
			
		
		--ATRIBUINDO VALORES AS VARIÁVEIS 
			SELECT	@Id_Conta = Id_Cta,
					@Tipo_Lancamento = Tipo_Lanc,
					@Data_Lanc = Dat_Lancamento, 
					@Vlr_Lancamento = Vlr_Lanc
				FROM DELETED
			
				UPDATE [dbo].[Contas] 
					SET  Vlr_SldInicial = (CASE WHEN @Data_Lanc < Dat_Saldo THEN Vlr_SldInicial + 
																								(CASE	WHEN @Tipo_Lancamento = 'C' 
																										THEN @Vlr_Lancamento * (-1)
																									ELSE @Vlr_Lancamento 
																								END)
												ELSE Vlr_SldInicial 
											END),

							Vlr_Credito = (CASE WHEN @Data_Lanc < Dat_Saldo OR @Tipo_Lancamento = 'D' 
												THEN Vlr_Credito
														ELSE (Vlr_Credito - @Vlr_Lancamento) END),

							Vlr_Debito =	(CASE	WHEN @Data_Lanc < Dat_Saldo OR @Tipo_Lancamento = 'C'
												THEN Vlr_Debito
													ELSE(Vlr_Debito - @Vlr_Lancamento)
											END)
					WHERE Id = @Id_Conta
						
    END



