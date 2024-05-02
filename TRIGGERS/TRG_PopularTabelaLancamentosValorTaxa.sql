USE SistemaBancario
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_PopularTabelaLancamentosValorTaxa]
	ON [dbo].[Lancamentos]
	AFTER INSERT
	AS
	/*
		Documentacao
		Arquivo Fonte.....: TRG_PopularTabelaLancamentosValorTaxa.sql
		Objetivo..........: Ao inserir um lançamento onde o tipolancamento é igual ao 10 (juros de saldo negativo) ou outros que são,
							do tipo de taxa, deverá gerar um insert na tabela LancamentosValorTaxa, inserindo o valor do lancamento e
							o da taxa. Pra esse caso, como só temos a TSN (taxa de saldo negativo) o Id_Taxa = 1.
		Autor.............: Odlavir Florentino
		Data..............: 26/04/2024
		EX................:	BEGIN TRAN
								SELECT	Id,
										Id_Taxa,
										Aliquota,
										DataInicial
									FROM [dbo].[ValorTaxa] WITH(NOLOCK)
									ORDER BY Id_Taxa, DataInicial

								SELECT	Id_Lancamentos,
										Id_ValorTaxa
									FROM [dbo].[LancamentosValorTaxa] WITH(NOLOCK)

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
																VALUES
																(
																	1,
																	0,
																	10,
																	'D',
																	100,
																	'Teste',
																	'2024-04-01',
																	0
																)

								SELECT	Id_Lancamentos,
										Id_ValorTaxa
									FROM [dbo].[LancamentosValorTaxa] WITH(NOLOCK)
							ROLLBACK TRAN
	*/
	BEGIN
		DECLARE @Id_Taxa INT = 1,
				@DataAtual DATE = GETDATE()

		BEGIN
			INSERT INTO [dbo].[LancamentosValorTaxa] (Id_Lancamentos, Id_ValorTaxa)
				SELECT	L.Id,
						F.Id
					FROM FNC_IdentificarTaxaDoDia(@Id_Taxa, NULL) F
						CROSS JOIN inserted L;
		END
	END

