CREATE OR ALTER TRIGGER [dbo].[trg_tarifaTransferencia]
ON [dbo].[Transferencias]
FOR INSERT
	AS
	/*
	DOCUMENTAÇÃO
	Arquivo Fonte........:	trg_tarifaTransferencia.sql
	Objetivo.............:	Atualizar o Saldo da tabela após o registro de uma Transferência
	Autor................:	Olívio Freitas, Danyel Targino e Rafael Maurício
	Data.................:	11/04/2024
	ObjetivoAlt..........:	N/A
	AutorAlt.............:	N/A
	DataAlt..............:	N/A
	Ex...................:	BEGIN TRAN
								DBCC DROPCLEANBUFFERS;
								DBCC FREEPROCCACHE;

								DECLARE @Dat_init DATETIME = GETDATE()

								SELECT * FROM Contas WHERE Id = 10
								SELECT * FROM Transferencias
								SELECT * FROM Lancamentos

								INSERT INTO Transferencias
									VALUES
										(1, 10, 2, 5252, 'Teste123', GETDATE(), 2)

								SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS EXECUÇÃO 

								SELECT * FROM Contas WHERE Id = 10
								SELECT * FROM Transferencias
								SELECT * FROM Lancamentos

							ROLLBACK TRAN
	Retornos.............:	0 - SUCESSO			   
	*/
	BEGIN
		-- Declaro as variáveis que preciso
		DECLARE @Id_ContaDeb INT,
				@Id_Tarifa SMALLINT,
				@Valor_Tarifa DECIMAL(4,2),
				@Nome_Tarifa VARCHAR(50),
				@Valor_Debito DECIMAL(15,2),
				@Operacao_Lancamento CHAR(1) = 'D'

		IF EXISTS (SELECT TOP 1 1 FROM inserted)
			BEGIN
				-- Atribuir valores às variáveis
				SELECT	@Id_ContaDeb = Id_CtaDeb,
						@Id_Tarifa = Id_Tarifa
					FROM inserted
			END
		-- Identifico qual a tarifa e capturo o valor
		IF @Id_Tarifa IS NOT NULL
			BEGIN
				SELECT	@Valor_Tarifa = Valor,
						@Nome_Tarifa = Descricao
					FROM [dbo].[Tarifas] WITH(NOLOCK)
					WHERE Id = @Id_Tarifa
			END

		IF @Id_ContaDeb IS NOT NULL
			BEGIN
				-- INSERT em Lancamentos
				INSERT INTO Lancamentos
					VALUES
						(@Id_ContaDeb, 1, @Valor_Tarifa, @Nome_Tarifa, GETDATE(), @Operacao_Lancamento, @Id_Tarifa)
			END
	END
GO