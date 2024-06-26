USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_AplicarTaxaManutencao]
	AS
		/*
			Documentacao
			Arquivo Fonte........:	SPJOB_AplicarTaxaManutencao.sql
			Objetivo.............:	Aplica a Tarifa de Manutencao de Conta a partir da data de abertura da conta nos meses subsequentes
									Id_Usuario o valor é 0, pois é usuario do sistema
									Id_TipoLancamento o valor é 6, pois refere-se a Tarifa
									Id_Tarifa o valor é 6, pois refere-se a Tarifa de Manutencao de Conta (TMC)
			Autor................:	Gustavo Targino, Danyel Targino e Thays Carvalho
			Data.................:	29/04/2024
			Ex...................:	BEGIN TRAN
										DBCC DROPCLEANBUFFERS;
										DBCC FREEPROCCACHE;

										DECLARE @Dat_init DATETIME = GETDATE()

										SELECT * FROM Contas ORDER BY Dat_Abertura DESC
										SELECT * FROM Lancamentos ORDER BY Dat_Lancamento DESC
										
										INSERT INTO Contas
												(Id_Correntista, Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura , Ativo, Lim_ChequeEspecial)
											VALUES
												(1, 0, 0, 0, GETDATE(), DATEFROMPARTS(YEAR(@Dat_init), MONTH(DATEADD(MONTH, -1, @Dat_init)), DAY(@Dat_init)), 1, 0)

										INSERT INTO Contas
												(Id_Correntista, Vlr_SldInicial, Vlr_Credito, Vlr_Debito, Dat_Saldo, Dat_Abertura , Ativo, Lim_ChequeEspecial)
											VALUES
												(1, 0, 0, 0, GETDATE(), DATEFROMPARTS(YEAR(@Dat_init), MONTH(DATEADD(MONTH, -1, @Dat_init)), DAY(@Dat_init)), 1, 0)

										EXEC [dbo].[SPJOB_AplicarTaxaManutencao];

										SELECT DATEDIFF(MILLISECOND, @Dat_init, GETDATE()) AS TempoExecucao
										
										SELECT * FROM Lancamentos
										SELECT * FROM Contas
										SELECT * FROM Tarifas
										SELECT * FROM PrecoTarifas
										SELECT * FROM LancamentosPrecoTarifas

									ROLLBACK TRAN
		*/

			-- Declarando variaveis
			DECLARE @Data_Atual DATE = GETDATE(),
					@Data_Abertura DATE,
					@Data_Cobranca INT,
					@Valor_TMC DECIMAL(4,2),
					@Nome_Tarifa VARCHAR(50),
					@IdTarifa TINYINT = 5, -- Tarifa de manutenção de conta
					@IdPrecoTarifas INT
			
			-- Selecionando este mesmo dia mês passado
			SET @Data_Abertura = DATEADD(MONTH, -1, @Data_Atual)

			-- Formatando corretamente o ano do mês passado para casos entre dezembro e janeiro
			SET @Data_Abertura = DATEFROMPARTS(YEAR(@Data_Abertura), MONTH(@Data_Abertura), DAY(@Data_Abertura))

			-- Capturar Id_Taxa e Valor da Taxa vigente para a data da chamada do Job
			SELECT	@IdPrecoTarifas = IdPrecoTarifas,
					@Valor_TMC = Valor,
					@Nome_Tarifa = Nome
				FROM [dbo].[FNC_ListarValorAtualTarifa](@IdTarifa)

			-- Se o último dia do mês atual for menor que o último dia do mês de abertura da conta, cobrar no último dia do mês atual
			IF DAY(EOMONTH(@Data_Atual)) < DAY(@Data_Abertura)
				SET @Data_Cobranca = DAY(EOMONTH(@Data_Atual));
			ELSE
				SET @Data_Cobranca = DAY(@Data_Abertura); 
				
			-- Criar uma tabela temporária para armazenar os IDs dos lançamentos inseridos
			CREATE TABLE #InsertedLancamentos (
				IdLancamento INT
			)

			-- INSERT em Lancamentos juntamente com capturar os Ids dos Lancamentos inseridos
			INSERT INTO [dbo].[Lancamentos] (	
												Id_Conta,
												Id_Usuario,
												Id_TipoLancamento,
												Tipo_Operacao,
												Vlr_Lanc,
												Nom_Historico,
												Dat_Lancamento,
												Estorno
											) 
				OUTPUT INSERTED.Id 
					INTO #InsertedLancamentos(IdLancamento) -- Capturando Ids dos Lancamentos inseridos
						SELECT	Id, 
								0,
								6, -- TipoLancamento: Tarifa
								'D',
								@Valor_TMC,
								@Nome_Tarifa,
								@Data_Atual,
								0
							FROM [dbo].[Contas] WITH (NOLOCK)
								WHERE DAY(Dat_Abertura) = @Data_Cobranca

			-- Checagem de erro
			DECLARE @MSG VARCHAR(100),
					@ERRO INT = @@ERROR
			
			-- Verificando se houve erro ao inserir o lançamento com a cobrança de tarifa de manutenção de conta
			IF @ERRO <> 0 OR @@ROWCOUNT <> 1
				BEGIN
					SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', na aplicacao de Tarifa de Manutenção de Conta'
						RAISERROR(@MSG, 16, 1)
				END

			-- Populando tabela de histórico de lançamentos originados por uma tarifa com a tarifa de manutenção de conta para a conta criada
			INSERT INTO [dbo].[LancamentosPrecoTarifas] (Id_Lancamentos, Id_PrecoTarifas) 
				SELECT	il.IdLancamento,
						@IdPrecoTarifas
					FROM #InsertedLancamentos il

			-- Apagar a tabela temporária
			DROP TABLE #InsertedLancamentos

			-- Verificando possível novo erro
			SET @ERRO = @@ERROR

			-- Verificando se houve erro ao inserir histórico
			IF @ERRO <> 0 OR @@ROWCOUNT <> 1
				BEGIN
					SET @MSG = 'ERRO' + CAST(@ERRO AS VARCHAR(3)) + ', em armazenar LancamentosPrecoTarifas na aplicacao de Tarifa de Manutenção de Conta'
						RAISERROR(@MSG, 16, 1)
				END
GO
