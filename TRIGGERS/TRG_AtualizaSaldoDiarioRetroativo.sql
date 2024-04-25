CREATE OR ALTER TRIGGER [dbo].[TRG_AtualizaSaldoDiarioRetroativo] 
ON [dbo].[Lancamentos]
FOR INSERT 
	AS 
	/*
		Documentacao
		Arquivo Fonte.....: TRG_AtualizarSaldoDiarioRetroativo.sql
		Objetivo..........: Trigger que atualiza a situação dos saldos finais na data com base em lancamentos retroativos de crédito ou débito
		Autor.............: Adriel Alexander 
		Data..............: 08/04/2024
		EX................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_ini DATETIME = GETDATE();

								SELECT  TOP 20	Id,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
									FROM [dbo].[SaldoDiario] WITH(NOLOCK);

								--inserir insert de lancamento retroativo para teste

								SELECT DATEDIFF(MILLISECOND, @Dat_ini, GETDATE()) AS TempoExecucao;
								SELECT  TOP 20	Id,
												Vlr_SldInicial,
												Vlr_Credito,
												Vlr_Debito,
												Dat_Saldo 
									FROM [dbo].[SaldoDiario] WITH(NOLOCK);
							ROLLBACK TRAN
	*/

	BEGIN 
			
			--Declaração de Varáveis
			DECLARE @Id_Conta INT,
					@Tipo_Lancamento CHAR(1),
					@Data_Lanc DATETIME,
					@Vlr_Lancamento DECIMAL(15,2)

			--ATRIBUINDO VALORES AS VARIÁVEIS 
			SELECT @Id_Conta = Id_Conta,
				   @Tipo_Lancamento = Tipo_Operacao,
				   @Data_Lanc = Dat_Lancamento, 
				   @Vlr_Lancamento = Vlr_Lanc
				FROM INSERTED
			--Realização de update para os atributos de Saldo Diario 
			UPDATE [dbo].[SaldoDiario]
			SET
				Vlr_Credito = (
					CASE 
						WHEN @Tipo_Lancamento = 'C' AND DATEDIFF(DAY, @Data_Lanc, Dat_Saldo) = 0 
						THEN Vlr_Credito + @Vlr_Lancamento 
						ELSE Vlr_Credito 
					END
				),
				Vlr_Debito = (
					CASE 
						WHEN @Tipo_Lancamento = 'D' AND DATEDIFF(DAY, @Data_Lanc, Dat_Saldo) = 0 
						THEN Vlr_Debito + @Vlr_Lancamento
						ELSE Vlr_Debito 
					END
				),
				Vlr_SldInicial = (
					CASE
						WHEN DATEDIFF(DAY, @Data_Lanc, Dat_Saldo) > 0
						THEN Vlr_SldInicial + (CASE WHEN @Tipo_Lancamento = 'C' 
													THEN @Vlr_Lancamento
													ELSE @Vlr_Lancamento * (-1) END)
						ELSE Vlr_SldInicial
					END
				),
				Vlr_SldFinal =(    CASE
						WHEN DATEDIFF(DAY, @Data_Lanc, Dat_Saldo) >= 0
						THEN Vlr_SldFinal + (CASE WHEN @Tipo_Lancamento = 'C' 
													THEN @Vlr_Lancamento
													ELSE @Vlr_Lancamento * (-1) END)
						ELSE Vlr_SldFinal
					END)
				WHERE Id_Conta = @Id_Conta

END