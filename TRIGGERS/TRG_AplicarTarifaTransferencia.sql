CREATE OR ALTER TRIGGER [dbo].[TRG_TarifaTransferencia]
ON [dbo].[Lancamentos]
FOR INSERT
	AS
	/*
	DOCUMENTACAO
	Arquivo Fonte........:	TRG_AplicarTarifaTransferencia.sql
	Objetivo.............:	Atualizar o Saldo da tabela apos o registro de uma Transferencia
	Autor................:	Olivio Freitas, Danyel Targino e Rafael Mauricio
	Data.................:	11/04/2024
	ObjetivoAlt..........:	N/A
	AutorAlt.............:	N/A
	DataAlt..............:	N/A
	Ex...................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_init DATETIME = GETDATE()

								SELECT * FROM Contas
								SELECT * FROM Transferencias
								SELECT * FROM Lancamentos

								INSERT INTO Lancamentos
										(Id_Cta, Id_Usuario, Id_Tarifa, Tipo_lanc ,Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
									VALUES
										(1, 1, 1,'D', 50, 'Teste100', GETDATE(), 1)

								SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS EXECUCAO 

								SELECT * FROM Contas
								SELECT * FROM Transferencias
								SELECT * FROM Lancamentos

							ROLLBACK TRAN
	Retornos.............:	0 - SUCESSO			   
	*/
	BEGIN
		-- Declaro as variaveis que preciso
		DECLARE @Id_Conta INT,
				@Id_Tarifa SMALLINT,
				@Valor_Tarifa DECIMAL(4,2),
				@Nome_Tarifa VARCHAR(50),
				@Valor_Debito DECIMAL(15,2),
				@Operacao_Lancamento CHAR(1),
				@Id_Usuario INT
				

		IF EXISTS (SELECT TOP 1 1
						FROM inserted WITH(NOLOCK)
						WHERE Estorno = 1 
							AND Id_Tarifa NOT IN (5,6,7)
							AND Id_Tarifa IS NOT NULL)
			BEGIN
				-- Atribuir valores as variaveis
				SELECT	@Id_Conta = Id_Cta,
						@Id_Tarifa = Id_Tarifa,
						@Operacao_Lancamento = 'C',
						@Id_Usuario = Id_Usuario
					FROM inserted
			
				-- Identifico qual a tarifa e capturo o valor
				IF @Id_Tarifa IS NOT NULL
					BEGIN
						SELECT	@Valor_Tarifa = Valor,
								@Nome_Tarifa = Nome
							FROM [dbo].[Tarifas] WITH(NOLOCK)
							WHERE Id = @Id_Tarifa
					END

				IF @Id_Conta IS NOT NULL
					BEGIN
						-- INSERT em Lancamentos
						INSERT INTO Lancamentos
							VALUES
								(@Id_Conta, @Id_Usuario, @Id_Tarifa, @Operacao_Lancamento, @Valor_Tarifa, @Nome_Tarifa, GETDATE(), 1)
					END
		    END
		ELSE IF EXISTS(SELECT TOP 1 1
							FROM inserted WITH(NOLOCK)
							WHERE Estorno = 0
							AND	  Tipo_Lanc = 'D'
							AND	  Id_Tarifa NOT IN (5,6,7)
							AND   Id_Tarifa IS NOT NULL)
			BEGIN
				-- Atribuir valores as variaveis
				SELECT	@Id_Conta = Id_Cta,
						@Id_Tarifa = Id_Tarifa,
						@Operacao_Lancamento = Tipo_Lanc,
						@Id_Usuario = Id_Usuario
					FROM inserted
				-- Identifico qual a tarifa e capturo o valor
				IF @Id_Tarifa IS NOT NULL
					BEGIN
						SELECT	@Valor_Tarifa = Valor,
								@Nome_Tarifa = Nome
							FROM [dbo].[Tarifas] WITH(NOLOCK)
							WHERE Id = @Id_Tarifa 
					END
				IF @Id_Conta IS NOT NULL
					BEGIN
						-- INSERT em Lancamentos
						INSERT INTO Lancamentos
							VALUES
								(@Id_Conta, @Id_Usuario, @Id_Tarifa, @Operacao_Lancamento, @Valor_Tarifa, @Nome_Tarifa, GETDATE(), 0)
					END
		    END
	END
GO