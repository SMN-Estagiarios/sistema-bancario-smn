USE SistemaBancario
GO

CREATE OR ALTER PROCEDURE [dbo].[SPJOB_LancarTaxaSaldoNegativo]
	@Id_Conta INT = NULL,
	@DataPassada DATE = NULL
	AS
	/*
		DOCUMENTAÇÃO
		Arquivo fonte.....: SPJOB_LancarTaxaSaldoNegativo.sql
		Objetivo..........: Verificar diariamente quais as contas que estão negativas e lançar uma taxa de saldo nelas.
							Para o insert atribuimos diretamente o valor de Id_Usuario = 0 que é o equivalente ao ADMIN,
							Id_TipoLancamento = 9 que é o de juros, Id_Taxa = 1 que é o de taxa saldo negativo e Estorno = 0,
							que evidencia que não é um estorno.
		Autor.............: Orcino Neto, Odlavir Florentino e Pedro Avelino
		Data..............: 18/04/2024
		Ex................: BEGIN TRAN
								SELECT	Id_Cta,
										Id_Usuario,
										Id_TipoLancamento,
										Id_Tarifa,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos] WITH(NOLOCK)
			
								UPDATE Contas
									SET Vlr_SldInicial = -1500,
										Vlr_Credito = 150,
										Vlr_Debito = 500
									-- WHERE Id = 1

								SELECT	Id,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo,
										Dat_Abertura,
										Dat_Encerramento,
										Ativo 
									FROM [dbo].[Contas]  WITH(NOLOCK)
                                
                                DBCC DROPCLEANBUFFERS
								DBCC FREEPROCCACHE
								DBCC FREESYSTEMCACHE ('ALL')

                                DECLARE @Data_ini DATETIME = GETDATE()

								EXEC [dbo].[SPJOB_LancarTaxaSaldoNegativo]

								SELECT	Id,
										Vlr_SldInicial,
										Vlr_Credito,
										Vlr_Debito,
										Dat_Saldo,
										Dat_Abertura,
										Dat_Encerramento,
										Ativo 
									FROM [dbo].[Contas]  WITH(NOLOCK)

								SELECT DATEDIFF(MILLISECOND, @Data_ini, GETDATE()) AS TempoExecucao

								SELECT	Id_Cta,
										Id_Usuario,
										Id_TipoLancamento,
										Id_Tarifa,
										Tipo_Operacao,
										Vlr_Lanc,
										Nom_Historico,
										Dat_Lancamento,
										Estorno
									FROM [dbo].[Lancamentos] WITH(NOLOCK)

							ROLLBACK TRAN
	*/

	BEGIN
		-- Criar a atribuir o valor da variavel de taxa
		-- Criar a atribuir o valor da variavel de taxa
		DECLARE @IdTaxa TINYINT = 1

		IF @DataPassada IS NULL OR @Id_Conta IS NULL
			BEGIN
				-- Aplicar a taxa de saldo negativo para as mesmas
				INSERT INTO [dbo].[Lancamentos]	(Id_Conta, Id_Usuario, Id_TipoLancamento, Id_Taxa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
					SELECT	F.Id,
							0,
							9,
							@IdTaxa,
							'D',
							(VT.Aliquota * ABS(F.Saldo)),
							'Valor REF sobre cobranças de limite cheque especial',
							GETDATE(),
							0
						FROM [dbo].FNC_ListarSaldoNegativo() F
							INNER JOIN [dbo].[ValorTaxa] VT WITH(NOLOCK)
								ON VT.Id_Taxa = @IdTaxa

				IF @@ERROR <> 0 OR @@ROWCOUNT <> (SELECT COUNT(Id) FROM [dbo].FNC_ListarSaldoNegativo())
					BEGIN
						RAISERROR('Erro ao lancar a taxa de saldo negativo para uma data anterior.', 16, 1)
					END
			END

		ELSE
			BEGIN
				DECLARE @DataInicio DATE = DATEADD(MONTH, -1, GETDATE()),
                @DataFim DATE,
				@Valor DECIMAL(15,2)

				SET @DataInicio = DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 01)
				SET @DataFim = EOMONTH(GETDATE())


				CREATE TABLE #TabelaData(
											DataSaldo DATE
										)

				--Populando tabela de dias
				WHILE @DataInicio <= @DataFim
					BEGIN
						INSERT INTO #TabelaData	(DataSaldo) VALUES 
												(@DataInicio)
						SET @DataInicio = DATEADD(DAY, 1, @DataInicio)
					END;

				-- Atribuindo a variavel @Valor o resultado do saldo do dia para a data solicitada.
				SELECT @Valor = (s.ValorSaldoAtual - ISNULL(l.Credito, 0) + ISNULL(l.Debito, 0))
					FROM (
							SELECT  c.id AS ID_Conta,
									td.DataSaldo,
									(c.Vlr_SldInicial + c.Vlr_Credito - c.Vlr_Debito) AS ValorSaldoAtual
								FROM #TabelaData td
								CROSS JOIN [dbo].[Contas] c WITH(NOLOCK)
							) s
						LEFT OUTER JOIN (
											SELECT  x.Id_Conta,
													x.DataSaldo,
													SUM(CASE WHEN x.TipoLancamento = 'C' THEN x.Vlr_Lanc ELSE 0 END) AS Credito,
													SUM(CASE WHEN x.TipoLancamento = 'D' THEN x.Vlr_Lanc ELSE 0 END) AS Debito
												FROM (
														SELECT  td.DataSaldo,
																la.Dat_Lancamento,
																la.Id_Conta,
																ISNULL(la.Tipo_Operacao, 'X') as TipoLancamento,
																la.Vlr_Lanc
															FROM #TabelaData td
																LEFT OUTER JOIN [dbo].[Lancamentos] la WITH(NOLOCK)
																	ON DATEDIFF(DAY, td.DataSaldo, la.Dat_Lancamento) > 0
														) x
												GROUP BY x.DataSaldo, x.Id_Conta
										) l
							ON	s.ID_Conta = l.Id_Conta
								AND s.DataSaldo = l.DataSaldo
					WHERE	s.ID_Conta = @Id_Conta AND 
							s.DataSaldo = @DataPassada

				IF @Valor < 0
					BEGIN
						-- Aplicar a taxa de saldo negativo para as mesmas
						INSERT INTO [dbo].[Lancamentos]	(Id_Conta, Id_Usuario, Id_TipoLancamento, Id_Taxa, Tipo_Operacao, Vlr_Lanc, Nom_Historico, Dat_Lancamento, Estorno)
							SELECT	@Id_Conta,
									1,
									9,
									@IdTaxa,
									'D',
									(VT.Aliquota * ABS(@Valor)),
									'Valor REF sobre cobranças de limite cheque especial de uma data anterior',
									GETDATE(),
									0
								FROM [dbo].[ValorTaxa] VT  WITH(NOLOCK)
								WHERE VT.Id_Taxa = @IdTaxa

						IF @@ERROR <> 0 OR @@ROWCOUNT <> 1
							BEGIN
								RAISERROR('Erro ao lancar a taxa de saldo negativo para uma data anterior.', 16, 1)
							END
					END

			END
		
	END
GO