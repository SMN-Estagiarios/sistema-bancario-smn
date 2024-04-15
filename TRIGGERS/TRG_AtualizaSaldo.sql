CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizaSaldo]
ON [dbo].[Lancamentos]
FOR INSERT, DELETE, UPDATE
	AS
	/*
	DOCUMENTAÇÃO
	Arquivo Fonte........:	TRG_AtualizaSaldo.sql
	Objetivo.............:	Atualizar Saldo da tabela [dbo].[Contas]
	Autor................:	Adriel Alexander
	Data.................:	05/04/2024
	ObjetivoAlt..........: 
	AutorAlt.............: 
	DataAlt..............: 
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

									INSERT INTO Lancamentos VALUES (1,1,'C', 2000, 'TESTE TRIGGER', GETDATE())

									SELECT DATEDIFF(MILLISECOND,@DATA_INI,GETDATE()) AS Execução

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
			--IF POR INSERT
	IF EXISTS (SELECT TOP 1 1 FROM inserted) 
		BEGIN 
		--ATRIBUINDO VALORES AS VARIÁVEIS 
			SELECT @Id_Conta = Id_Cta,
				   @Tipo_Lancamento = Tipo_Lanc,
				   @Data_Lanc = Dat_Lancamento, 
				   @Vlr_Lancamento = Vlr_Lanc
				FROM inserted
			IF @Id_Conta IS NOT NULL
			 BEGIN 
				
				UPDATE [dbo].[Contas] 
					SET Vlr_SldInicial = (CASE WHEN @Data_Lanc < Dat_Saldo THEN Vlr_SldInicial + 
																							(CASE WHEN @Tipo_Lancamento = 'C' THEN @Vlr_Lancamento
																								  ELSE @Vlr_Lancamento* (-1)END)
											   ELSE Vlr_SldInicial END),
						Vlr_Credito = (CASE WHEN @Data_Lanc < Dat_Saldo  OR @Tipo_Lancamento = 'D' THEN Vlr_Credito
																									   ELSE (Vlr_Credito + @Vlr_Lancamento) END),
						Vlr_Debito = (CASE WHEN @Data_Lanc < Dat_Saldo  OR @Tipo_Lancamento = 'C' THEN Vlr_Debito
																								 ELSE(Vlr_Debito + @Vlr_Lancamento)END)
					WHERE Id = @Id_Conta
			 END
		END
	IF EXISTS (SELECT TOP 1 1 FROM deleted) 
		BEGIN 
		--ATRIBUINDO VALORES AS VARIÁVEIS 
			SELECT @Id_Conta = Id_Cta,
				   @Tipo_Lancamento = Tipo_Lanc,
				   @Data_Lanc = Dat_Lancamento, 
				   @Vlr_Lancamento = Vlr_Lanc
				FROM deleted
			IF @Id_Conta IS NOT NULL
			 BEGIN 
				UPDATE [dbo].[Contas] 
					SET  Vlr_SldInicial = (CASE WHEN @Data_Lanc < Dat_Saldo THEN Vlr_SldInicial + 
																							(CASE WHEN @Tipo_Lancamento = 'C' THEN @Vlr_Lancamento * (-1)
																								  ELSE @Vlr_Lancamento END)
											   ELSE Vlr_SldInicial END),
						 Vlr_Credito = (CASE WHEN @Data_Lanc < Dat_Saldo OR @Tipo_Lancamento = 'D' THEN Vlr_Credito
																									   ELSE (Vlr_Credito - @Vlr_Lancamento) END),
						 Vlr_Debito = (CASE WHEN @Data_Lanc < Dat_Saldo OR @Tipo_Lancamento = 'C'THEN Vlr_Debito
																								 ELSE(Vlr_Debito - @Vlr_Lancamento)END)
					WHERE Id = @Id_Conta
			 END
		END
    END



