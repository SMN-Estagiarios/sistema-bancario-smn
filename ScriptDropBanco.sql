USE SistemaBancario
GO
	-- DROPANDO CONSTRAINT DE FK 

	-- Executando o drop de constraint de FK na tabela ValorTaxaCartao
ALTER TABLE ValorTaxaCartao
	DROP CONSTRAINT FK_Id_TaxaCartao_TaxaCartao
GO

	-- Executando o drop de constraint de FK na tabela ValorTaxa
ALTER TABLE ValorTaxa
	DROP CONSTRAINT FK_Id_Taxa_ValorTaxa
GO

	-- Executando o drop de constraint de FK na tabela contas
ALTER TABLE Contas
	DROP CONSTRAINT FK_Id_CreditScore_Contas
GO
ALTER TABLE Contas
	DROP CONSTRAINT FK_Id_Correntista_Contas
GO
ALTER TABLE Contas
	DROP CONSTRAINT FK_Id_Usuario_Contas
GO

	-- Executando o drop de constraint de FK na tabela ValorTaxaEmprestimo
ALTER TABLE ValorTaxaEmprestimo
	DROP CONSTRAINT FK_Id_TaxaEmprestimo_ValorTaxaEmprestimo
GO
ALTER TABLE ValorTaxaEmprestimo
	DROP CONSTRAINT FK_Id_CreditScore_ValorTaxaEmprestimo
GO

	-- Executando o drop de constraint de FK na tabela ValorIndice
ALTER TABLE ValorIndice
	DROP CONSTRAINT FK_Id_Indice_ValorIndice
GO
ALTER TABLE ValorIndice
	DROP CONSTRAINT FK_Id_PeriodoIndice_ValorIndice
GO

	-- Executando o drop de constraint de FK na tabela Emprestimo
ALTER TABLE Emprestimo
	DROP CONSTRAINT FK_Id_Conta_Emprestimo
GO
ALTER TABLE Emprestimo
	DROP CONSTRAINT FK_Id_StatusEmprestimo_Emprestimo
GO
ALTER TABLE Emprestimo
	DROP CONSTRAINT FK_Id_TaxaEmprestimo_Emprestimo
GO
ALTER TABLE Emprestimo
	DROP CONSTRAINT FK_Id_Indice_Emprestimo
GO
ALTER TABLE Emprestimo
	DROP CONSTRAINT FK_Id_PeriodoIndice_Emprestimo
GO

	-- Executando o drop de constraint de FK na tabela SaldoDiario
ALTER TABLE SaldoDiario
	DROP CONSTRAINT FK_Id_Conta_SaldoDiario
GO

	-- Executando o drop de constraint de FK na tabela CartaoCredito
ALTER TABLE CartaoCredito
	DROP CONSTRAINT FK_Id_Conta_CartaoCredito
GO
ALTER TABLE CartaoCredito
	DROP CONSTRAINT FK_Id_StatusCartaoCredito_CartaoCredito
GO

	-- Executando o drop de constraint de FK na tabela Fatura
ALTER TABLE Fatura
	DROP CONSTRAINT FK_Id_StatusFatura_Fatura
GO
ALTER TABLE Fatura
	DROP CONSTRAINT FK_Id_Conta_Fatura
GO

	-- Executando o drop de constraint de FK na tabela TransacaoCartaoCredito
ALTER TABLE TransacaoCartaoCredito
	DROP CONSTRAINT FK_Id_CartaoCredito_TransacaoCartaoCredito
GO
ALTER TABLE TransacaoCartaoCredito
	DROP CONSTRAINT FK_Id_Fatura_TransacaoCartaoCredito
GO
ALTER TABLE TransacaoCartaoCredito
	DROP CONSTRAINT FK_Id_ValorTaxaCartao_TransacaoCartaoCredito
GO
ALTER TABLE TransacaoCartaoCredito
	DROP CONSTRAINT FK_Id_TipoTransacao_TransacaoCartaoCredito
GO

	-- Executando o drop de constraint de FK na tabela PrecoTarifas
ALTER TABLE PrecoTarifas
	DROP CONSTRAINT FK_Id_Tarifa_PrecoTarifas
GO

	-- Executando o drop de constraint de FK na tabela Lancamentos
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Id_Conta_Lancamentos
GO
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Id_Usuario_Lancamentos
GO
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Id_TipoLancamento_Lancamentos
GO

	-- Executando drop de constraint de FK na tabela Parcela
ALTER TABLE Parcela
	DROP CONSTRAINT FK_Id_Emprestimo_Parcela;
GO
ALTER TABLE Parcela
	DROP CONSTRAINT FK_Id_Lancamento_Parcela;
GO
ALTER TABLE Parcela
	DROP CONSTRAINT FK_Id_ValorIndice_Parcela;
GO

	-- Executando o drop de constraint de FK na tabela LancamentosPrecoTarifas
ALTER TABLE LancamentosPrecoTarifas
	DROP CONSTRAINT FK_Id_Lancamentos_LancamentosPrecoTarifas
GO
ALTER TABLE LancamentosPrecoTarifas
	DROP CONSTRAINT FK_Id_PrecoTarifas_LancamentosPrecoTarifas
GO

	-- Executando o drop de constraint de FK na tabela LancamentosValorTaxa
ALTER TABLE LancamentosValorTaxa
	DROP CONSTRAINT FK_Id_Lancamentos_LancamentosValorTaxa
GO
ALTER TABLE LancamentosValorTaxa
	DROP CONSTRAINT FK_Id_ValorTaxa_LancamentosValorTaxa
GO

	-- Executando o drop de constraint de FK na tabela LancamentosTransacao
ALTER TABLE LancamentosTransacao
	DROP CONSTRAINT FK_Id_Lancamentos_LancamentosTransacao
GO
ALTER TABLE LancamentosTransacao
	DROP CONSTRAINT FK_Id_TransacaoCartaoCredito_LancamentosTransacao
GO

	-- Executando o drop de constraint de FK na tabela Transferencias
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Id_Conta_Credito_Transferencias
GO
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Id_Conta_Debito_Transferencias
GO
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Id_Usuario_Transferencias
GO

	-- Executando o drop de constraint de FK na tabela LancamentosTransferencia
ALTER TABLE LancamentosTransferencia
	DROP CONSTRAINT FK_Id_Lancamentos_LancamentosTransferencias
GO
ALTER TABLE LancamentosTransferencia
	DROP CONSTRAINT FK_Id_Tranferencia_LancamentosTransferencia
GO
	-- DROPANDO TRIGGERS DO SISTEMA BANCARIO
DROP TRIGGER [dbo].[TRG_AplicarTarifaTransferencia]
GO
DROP TRIGGER [dbo].[TRG_AplicarTaxaAberturaConta]
GO
DROP TRIGGER [dbo].[TRG_AtualizarCreditoComprometido]
GO
DROP TRIGGER [dbo].[TRG_AtualizarLimiteComprometidoAposPagamento]
GO
DROP TRIGGER [dbo].[TRG_AtualizarSaldo]
GO
DROP TRIGGER [dbo].[TRG_GeraLancamentoSaque]
GO
DROP TRIGGER [dbo].[TRG_GerarLancamentosTransferidos]
GO
DROP TRIGGER [dbo].[TRG_GerarParcelas]
GO
DROP TRIGGER [dbo].[TRG_PopularTabelaLancamentosValorTaxa]
GO

	-- DROPANDO TODAS AS PROCEDURES

-- CartaoCredito
DROP PROC [dbo].[SP_InserirNovoCartaoCredito]
GO
DROP PROC [dbo].[SP_AtivaCartaoCredito]
GO
DROP PROC [dbo].[SP_AtivaAproximacaoCartao]
GO
DROP PROC [dbo].[SP_BloquearCartao]
GO

-- Contas
DROP PROC [dbo].[SP_ListarSaldoAtual]
GO
DROP PROC [dbo].[SP_ExcluirConta]
GO
DROP PROC [dbo].[SP_AtualizarConta]
GO
DROP PROC [dbo].[SP_InserirNovaConta]
GO

-- Correntista
DROP PROC [dbo].[SP_InserirNovoCorrentista]
GO
DROP PROC [dbo].[SP_ExcluirCorrentista]
GO

-- CreditScore
DROP PROC [dbo].[SP_ListarCreditSCore]
GO

-- Emprestimos
DROP PROC [dbo].[SP_RealizarEmprestimo]
GO

-- Indices
DROP PROC [dbo].[SP_ListarIndices]
GO
DROP PROC [dbo].[SP_ListarPeriodosIndices]
GO

-- Lancamentos
DROP PROC [dbo].[SP_CriarLancamentos]
GO

-- Parcelas
DROP PROC [dbo].[SP_ListarParcelas]
GO

-- Tarifas
DROP PROC [dbo].[SP_ListarTarifas]
GO
DROP PROC [dbo].[SP_InserirValorTarifa]
GO

-- Taxas
DROP PROC [dbo].[SP_ListarTaxas]
GO
DROP PROC [dbo].[SP_InserirTaxa]
GO
DROP PROC [dbo].[SP_ExcluirTaxa]
GO
DROP PROC [dbo].[SP_InserirValorTaxa]
GO
DROP PROC [dbo].[SP_InserirValorTaxaCartao]
GO
DROP PROC [dbo].[SP_InserirValorTaxaEmprestimo]
GO

-- TransacaoCartaoCredito
DROP PROC [dbo].[SP_GerarTransacaoCartaoCredito]
GO



-- Transferencia
DROP PROC [dbo].[SP_RealizarNovaTransferenciaBancaria]
GO
DROP PROC [dbo].[SP_RealizarEstornoTransferencia]
GO
DROP PROC [dbo].[SP_RegistrarLancamentosTransferencia]
GO
DROP PROC [dbo].[SP_ListarExtratoTransferencia]
GO

	-- DROPANDO TODAS OS JOBS 
DROP PROC [dbo].[SPJOB_AplicarMultaAtrasoFatura]
GO
DROP PROC [dbo].[SPJOB_AplicarTaxaManutencao]
GO
DROP PROC [dbo].[SPJOB_AtualizarCreditScore]
GO
DROP PROC [dbo].[SPJOB_AtualizarParcelasPos]
GO
DROP PROC [dbo].[SPJOB_AtualizarParcelasPos]
GO
DROP PROC [dbo].[SPJOB_AtualizarSaldo]
GO
DROP PROC [dbo].[SPJOB_FechamentoFatura]
GO
DROP PROC [dbo].[SPJOB_LancarParcela]
GO
DROP PROC [dbo].[SPJOB_LancarTaxaSaldoNegativo]
GO
DROP PROC [dbo].[SPJOB_PagamentoFatura]
GO
DROP PROC [dbo].[SPJOB_ProcessarPopulacaoSaldoDiario]
GO

	-- DROPANDO TODAS AS FUNCTIONS

DROP FUNCTION [dbo].[FNC_CalcularJurosAtrasoParcela]
GO
DROP FUNCTION [dbo].[FNC_CalcularSaldoAtual]
GO
DROP FUNCTION [dbo].[FNC_CalcularSaldoDisponivel]
GO
DROP FUNCTION [dbo].[FNC_CalcularTaxaEmprestimo]
GO
DROP FUNCTION [dbo].[FNC_CalculaTransacoes]
GO
DROP FUNCTION [dbo].[FNC_IdentificarTaxaDoDia]
GO
DROP FUNCTION [dbo].[FNC_ListarParcelasEmprestimo]
GO
DROP FUNCTION [dbo].[FNC_ListarSaldoNegativo]
GO
DROP FUNCTION [dbo].[FNC_ListarSaldosEJurosDoMes]
GO
DROP FUNCTION [dbo].[FNC_ListarSimulacaoEmprestimo]
GO
DROP FUNCTION [dbo].[FNC_ListarValorAtualTaxa]
GO
DROP FUNCTION [dbo].[FNC_ListarValorAtualTaxaCartao]
GO
DROP FUNCTION [dbo].[FNC_ListarValorAtualTaxaEmprestimo]
GO
DROP FUNCTION [dbo].[FNC_ListaValorAtualTarifa]
GO

	--DROPANDO TODAS AS TABELAS

DROP TABLE [dbo].[StatusCartaoCredito]
GO
DROP TABLE [dbo].[StatusEmprestimo]
GO
DROP TABLE [dbo].[TipoTransacao]
GO
DROP TABLE [dbo].[TaxaCartao]
GO
DROP TABLE [dbo].[ValorTaxaCartao]
GO
DROP TABLE [dbo].[StatusFatura]
GO
DROP TABLE [dbo].[Taxa]
GO
DROP TABLE [dbo].[ValorTaxa]
GO
DROP TABLE [dbo].[CreditScore]
GO
DROP TABLE [dbo].[Correntista]
GO
DROP TABLE [dbo].[TaxaEmprestimo]
GO
DROP TABLE [dbo].[ValorTaxaEmprestimo]
GO
DROP TABLE [dbo].[Indice]
GO
DROP TABLE [dbo].[PeriodoIndice]
GO 
DROP TABLE [dbo].[ValorIndice]
GO
DROP TABLE [dbo].[Parcela]
GO
DROP TABLE [dbo].[Emprestimo]
GO
DROP TABLE [dbo].[SaldoDiario]
GO
DROP TABLE [dbo].[CartaoCredito]
GO
DROP TABLE [dbo].[Fatura]
GO
DROP TABLE [dbo].[TransacaoCartaoCredito]
GO
DROP TABLE [dbo].[TransferenciasLancamentos]
GO
DROP TABLE [dbo].[Tarifas]
GO
DROP TABLE [dbo].[PrecoTarifas]
GO
DROP TABLE [dbo].[TipoLancamento]
GO
DROP TABLE [dbo].[Lancamentos]
GO
DROP TABLE [dbo].[LancamentosPrecoTarifas]
GO
DROP TABLE [dbo].[LancamentosValorTaxa]
GO
DROP TABLE [dbo].[LancamentosTransacao]
GO
DROP TABLE [dbo].[Transferencias]
GO
DROP TABLE [dbo].[LancamentosTransferencia]
GO
DROP TABLE [dbo].[Contas]
GO
DROP TABLE [dbo].[Usuarios]
GO
