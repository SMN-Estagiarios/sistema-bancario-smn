USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_AplicarTaxaAberturaConta]
ON [dbo].[Contas]
FOR INSERT
	AS
	/*
	DOCUMENTACAO
	Arquivo Fonte........:	TRG_AplicarTaxaAberturaConta.sql
	Objetivo.............:	Insere lancamento referente a taxa de abertura de conta.
	Autor................:	Olivio Freitas, Danyel Targino e Rafael Mauricio
	Data.................:	10/04/2024
	Ex...................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_init DATETIME = GETDATE()

								SELECT * FROM Contas ORDER BY Id DESC
								SELECT * FROM Lancamentos ORDER BY Id DESC

								INSERT INTO Contas
										(Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura ,Ativo, Lim_ChequeEspecial)
									VALUES
										(0, 0, 0, GETDATE(), GETDATE(), 1, 0)

								SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS EXECUCAO

								SELECT * FROM Contas ORDER BY Id DESC
								SELECT * FROM Lancamentos ORDER BY Id DESC

							ROLLBACK TRAN
	*/
	BEGIN
		-- Declaro as variaveis que preciso
		DECLARE @Id_Conta INT,
				@Vlr_Tarifa DECIMAL(15,2),
				@Data_Lancamento DATETIME = GETDATE(),
				
				@Id_TAC TINYINT = 5, -- C�digo 5 se refere a taxa de abertura de conta
				@Id_Usuario INT = 1, -- Setar para o Usu�rio 0 (usu�rio do sistema)
				@Operacao_Lancamento CHAR(1) = 'D', -- setar
				@Estorno BIT = 0,
				@Id_TipoLancamento INT = 7
				
		-- Atribuir valores as variaveis
		SELECT @Vlr_Tarifa = Valor
			FROM Tarifas WITH (NOLOCK)
			WHERE ID = @Id_TAC

		SELECT	@Id_Conta = Id
					FROM inserted

		-- Gero um novo lancamento com o valor da taxa
		INSERT INTO Lancamentos	(	Id_Cta, 
									Id_Usuario, 
									Id_TipoLancamento, 
									Id_Tarifa, 
									Tipo_Operacao, 
									Vlr_Lanc, 
									Nom_Historico, 
									Dat_Lancamento, 
									Estorno
								)
					VALUES	(	@Id_Conta, 
								@Id_Usuario , 
								@Id_TipoLancamento, 
								@Id_TAC, 
								@Operacao_Lancamento, 
								@Vlr_Tarifa, 
								'Taxa de abertura de conta', 
								@Data_Lancamento, 
								@Estorno
							)
		-- Checagem de erro
		--IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
	
	END
GO