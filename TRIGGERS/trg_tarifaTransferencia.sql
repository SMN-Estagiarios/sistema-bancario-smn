CREATE OR ALTER TRIGGER [dbo].[TRG_TarifaTransferencia]
ON [dbo].[lancamentos]
FOR INSERT
	AS
	/*
	DOCUMENTA��O
	Arquivo Fonte........:	trg_tarifaTransferencia.sql
	Objetivo.............:	Atualizar o Saldo da tabela ap�s o registro de uma Transfer�ncia
	Autor................:	Ol�vio Freitas, Danyel Targino e Rafael Maur�cio
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

								INSERT INTO Transferencias
									VALUES
										(1, 1, 2, 5252, 'Teste123', GETDATE(), 2)

								SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS EXECU��O 

								SELECT * FROM Contas
								SELECT * FROM Transferencias
								SELECT * FROM Lancamentos

							ROLLBACK TRAN
	Retornos.............:	0 - SUCESSO			   
	*/
	BEGIN
		-- Declaro as vari�veis que preciso
		DECLARE @Id_Conta INT,
				@Id_Tarifa SMALLINT,
				@Valor_Tarifa DECIMAL(4,2),
				@Nome_Tarifa VARCHAR(50),
				@Valor_Debito DECIMAL(15,2),
				@Operacao_Lancamento CHAR(1),
				@Id_Usuario INT
				

		IF EXISTS (SELECT TOP 1 1
						FROM inserted WITH(NOLOCK)
						WHERE Nom_Historico LIKE 'Estorno recebido%')
			BEGIN
				-- Atribuir valores �s vari�veis
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
								(@Id_Conta, @Id_Usuario, @Id_Tarifa, @Operacao_Lancamento, @Valor_Tarifa, @Nome_Tarifa, GETDATE() )
					END
		    END
		ELSE IF EXISTS(SELECT TOP 1 1
							FROM inserted WITH(NOLOCK)
							WHERE Nom_Historico  NOT LIKE 'Estorno%'
							AND	  Tipo_Lanc = 'D'
							AND Id_Tarifa NOT IN (5,6))
			BEGIN
					-- Atribuir valores �s vari�veis
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
							(@Id_Conta, @Id_Usuario, @Id_Tarifa, @Operacao_Lancamento, @Valor_Tarifa, @Nome_Tarifa, GETDATE() )
				END
		    END
	END
GO

select * from tarifas