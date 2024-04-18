CREATE OR ALTER TRIGGER [dbo].[TRG_AplicarTaxaAberturaConta]
ON [dbo].[Contas]
FOR INSERT
	AS
	/*
	DOCUMENTACAO
	Arquivo Fonte........:	TRG_AplicarTaxaAberturaConta.sql
	Objetivo.............:	Atualizar o SaldoInicial da tabela conta apos um lancamento
	Autor................:	Olivio Freitas, Danyel Targino e Rafael Mauricio
	Data.................:	10/04/2024
	ObjetivoAlt..........:	N/A
	AutorAlt.............:	N/A
	DataAlt..............:	N/A
	Ex...................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_init DATETIME = GETDATE()

								SELECT * FROM Contas ORDER BY Id DESC
								SELECT * FROM Lancamentos ORDER BY Id DESC

								INSERT INTO Contas
										(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura, Ativo, Lim_ChequeEspecial)
									VALUES
										(0, 0, 0, GETDATE(), GETDATE(), 'S', 0)

								SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS EXECUCAO

								SELECT * FROM Contas ORDER BY Id DESC
								SELECT * FROM Lancamentos ORDER BY Id DESC

							ROLLBACK TRAN
	Retornos.............:	0 - SUCESSO			   
	*/
	BEGIN
		-- Declaro as variaveis que preciso
		DECLARE @Id_Conta INT,
				@Vlr_Tarifa DECIMAL(15,2),
				@Id_TAC TINYINT = 5,
				@Data_Lancamento DATETIME = GETDATE(),
				@Operacao_Lancamento CHAR(1) = 'D'

		-- Atribuir valores as variaveis
		IF EXISTS (SELECT TOP 1 1 FROM inserted)
			BEGIN
				SELECT	@Id_Conta = Id
					FROM inserted
			END

		-- Salvo valor da taxa na variavel @Vlr_Tarifa
		IF @Id_TAC IS NOT NULL
			BEGIN
				SELECT	@Vlr_Tarifa = Valor
					FROM [dbo].[Tarifas] WITH(NOLOCK)
					WHERE Id = @Id_TAC
			END

		-- Gero um novo lancamento com o valor da taxa
		IF @Id_Conta IS NOT NULL
			BEGIN
				INSERT INTO Lancamentos
					VALUES
						(@Id_Conta, 1, @Id_TAC, @Operacao_Lancamento, @Vlr_Tarifa, 'Taxa de abertura de conta', @Data_Lancamento,0)
			END
	END
GO