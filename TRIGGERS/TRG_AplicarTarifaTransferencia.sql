USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_TarifaTransferencia]
	ON [dbo].[Lancamentos]
	FOR INSERT
	AS
		/*
		DOCUMENTACAO
			Arquivo Fonte........:	TRG_AplicarTarifaTransferencia.sql
			Objetivo.............:	Atualizar o Saldo da tabela apos o registro de uma Transferencia
									Na parte de Estorno, estou setando o TipoOperacao como 'C'
			Autor................:	Olivio Freitas, Danyel Targino e Rafael Mauricio
			Data.................:	11/04/2024
			ObjetivoAlt..........:	A tabela de tarifas sofreu uma alteracao e os valores agora estao localizados na tabela PrecoTarifas,
									portanto preciso alterar para a nova estrutura do banco de dados.
			AutorAlt.............:	Olivio Freitas
			DataAlt..............:	23/04/2024
			Ex...................:	BEGIN TRAN
										DBCC DROPCLEANBUFFERS;
										DBCC FREEPROCCACHE;

										DECLARE @Dat_init DATETIME = GETDATE()

										SELECT * FROM Contas
										SELECT * FROM Transferencias
										SELECT * FROM Lancamentos

										INSERT INTO Lancamentos
												(Id_Conta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao ,Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
											VALUES
												(1, 0, 3, 3,'D', 50, 'Teste100', GETDATE(), 0)

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
				@Id_Tarifa TINYINT,
				@Valor_Tarifa DECIMAL(4,2),
				@Nome_Tarifa VARCHAR(50),
				@Valor_Debito DECIMAL(15,2),
				@Operacao_Lancamento CHAR(1),
				@Id_Usuario INT, 
				@Estorno BIT,
				@Id_TipoLancamento INT
				

		IF EXISTS (SELECT TOP 1 1
						FROM INSERTED WITH(NOLOCK)
						WHERE Estorno = 1 
							AND Id_Tarifa NOT IN (5,6,7)
							AND Id_Tarifa IS NOT NULL)
			BEGIN
				-- Atribuir valores as variaveis
				SELECT	@Id_Conta = Id_Conta,
						@Id_Tarifa = Id_Tarifa,
						@Operacao_Lancamento = 'C',
						@Id_Usuario = Id_Usuario,
						@Estorno = Estorno,
						@Id_TipoLancamento = Id_TipoLancamento
					FROM INSERTED
			
				-- Identifico qual a tarifa e capturo o valor
				IF @Id_Tarifa IS NOT NULL
					BEGIN
						SELECT	@Valor_Tarifa = vt.Valor,
								@Nome_Tarifa = vt.Nome
							FROM [dbo].[FNC_ListarValorAtualTarifa](@Id_Tarifa) vt
							
					END

				IF @Id_Conta IS NOT NULL
					BEGIN
						-- INSERT em Lancamentos
						INSERT INTO [dbo].[Lancamentos]
								(Id_Conta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
							VALUES
								(@Id_Conta, @Id_Usuario, @Id_TipoLancamento, @Id_Tarifa, 'C', @Valor_Tarifa, @Nome_Tarifa, GETDATE(), @Estorno)
					END
		    END
		ELSE IF EXISTS(SELECT TOP 1 1
							FROM INSERTED WITH(NOLOCK)
							WHERE Estorno = 0
							AND	  Tipo_Operacao = 'D'
							AND	  Id_Tarifa NOT IN (5,6,7)
							AND   Id_Tarifa IS NOT NULL)
			BEGIN
				-- Atribuir valores as variaveis
				SELECT	@Id_Conta = Id_Conta,
						@Id_Tarifa = Id_Tarifa,
						@Operacao_Lancamento = Tipo_Operacao,
						@Id_Usuario = Id_Usuario,
						@Estorno = Estorno,
						@Id_TipoLancamento = Id_TipoLancamento
					FROM INSERTED
				-- Identifico qual a tarifa e capturo o valor
				IF @Id_Tarifa IS NOT NULL
					BEGIN
						SELECT	@Valor_Tarifa = vt.Valor,
								@Nome_Tarifa = vt.Nome
							FROM [dbo].[FNC_ListarValorAtualTarifa](@Id_Tarifa) vt
					END
				IF @Id_Conta IS NOT NULL
					BEGIN
						-- INSERT em Lancamentos
						INSERT INTO [dbo].[Lancamentos]
								(Id_Conta, Id_Usuario, Id_TipoLancamento, Id_Tarifa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
							VALUES
								(@Id_Conta, @Id_Usuario, @Id_TipoLancamento, @Id_Tarifa, @Operacao_Lancamento, @Valor_Tarifa, @Nome_Tarifa, GETDATE(), @Estorno)
					END
		    END
	END
GO