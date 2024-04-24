USE SistemaBancario
GO
	-- DROPANDO CONSTRAINT DE FK 

	-- Executando o drop de constraint de FK na tabela contas
ALTER TABLE Contas
	DROP CONSTRAINT FK_IdCreditScore_Contas
GO
ALTER TABLE Contas
	DROP CONSTRAINT FK_IdCorrentista_Contas
GO
ALTER TABLE Contas
	DROP CONSTRAINT FK_IdUsuario_Contas
GO

	-- Executando o drop de constraint de FK na tabela TaxaEmprestimo
ALTER TABLE TaxaEmprestimo
	DROP CONSTRAINT FK_IdCreditScore_TaxaEmp
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
	DROP CONSTRAINT FK_Id_Taxa_Emprestimo
GO

	-- Executando o drop de constraint de FK na tabela SaldoDiario
ALTER TABLE SaldoDiario
	DROP CONSTRAINT FK_IdCta_SaldoDiario
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
	DROP CONSTRAINT FK_Id_TaxaCartao_TransacaoCartaoCredito
GO
ALTER TABLE TransacaoCartaoCredito
	DROP CONSTRAINT FK_Id_TipoTransacao_TransacaoCartaoCredito
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
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Id_Tarifa_Lancamentos
GO
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Id_Taxa_Lancamentos
GO
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Id_TransacaoCartaoCredito_Lancamentos
GO

	-- Executando o drop de constraint de FK na tabela Transferencias
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Id_CtaCre_Transferencias
GO
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Id_CtaDeb_Transferencias
GO
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Id_Usuario_Transferencias
GO

	-- DROPANDO TRIGGERS DO SISTEMA BANCARIO
DROP TRIGGER [TRG_AplicarTarifaTransferencia]
GO
DROP TRIGGER [TRG_AplicarTaxaAberturaConta]
GO
DROP TRIGGER [TRG_AtualizarSaldo]
GO
DROP TRIGGER [TRG_GerarLancamentosTransferidos]
GO


	-- DROPANDO TODAS AS PROCEDURES
DROP PROC [dbo].[SP_ListarSaldoAtual]
GO
DROP PROC [dbo].[SP_ExcluirConta]
GO
DROP PROC [dbo].[SP_AtualizarConta]
GO
DROP PROC [dbo].[SP_InserirNovaConta]
GO
DROP PROC [dbo].[SP_ListarExtratoTransferencia]
GO
DROP PROC [dbo].[SP_RealizarEstornoTransferencia]
GO
DROP PROC [dbo].[SP_RealizarNovaTransferenciaBancaria]
GO
DROP PROC [dbo].[SP_CriarLancamentos]
GO
DROP PROC [dbo].[SP_ListarCreditSCore]
GO
DROP PROC [dbo].[SP_ListarTarifas]
GO


	-- DROPANDO TODAS OS JOBS 
DROP PROC [dbo].[SPJOB_AplicarTaxaManutencao]
GO
DROP PROC [dbo].[SPJOB_AtualizarCreditScore]
GO
DROP PROC [dbo].[SPJOB_AtualizarSaldo]
GO
DROP PROC [dbo].[SPJOB_LancarTaxaSaldoNegativo]
GO

	-- DROPANDO TODAS AS FUNCTIONS

DROP FUNCTION [dbo].[FNC_CalcularSaldoAtual]
GO
DROP FUNCTION [dbo].[FNC_CalcularSaldoDisponivel]
GO
DROP FUNCTION [dbo].[FNC_ListarSaldoNegativo]
GO
DROP FUNCTION [dbo].[FNC_ListaValorAtualTarifa]
GO

	--DROPANDO TODAS AS TABELAS

DROP TABLE [dbo].[Usuarios]
GO
DROP TABLE [dbo].[StatusCartaoCredito]
GO
DROP TABLE [dbo].[StatusEmprestimo]
GO
DROP TABLE [dbo].[TipoTransacao]
GO
DROP TABLE [dbo].[TaxaCartao]
GO
DROP TABLE [dbo].[StatusFatura]
GO
DROP TABLE [dbo].[Taxa]
GO
DROP TABLE [dbo].[CreditScore]
GO
DROP TABLE [dbo].[Correntista]
GO
DROP TABLE [dbo].[Contas]
GO
DROP TABLE [dbo].[TaxaEmprestimo]
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
DROP TABLE [dbo].[Tarifas]
GO
DROP TABLE [dbo].[PrecoTarifas]
GO
DROP TABLE [dbo].[TipoLancamento]
GO
DROP TABLE [dbo].[Lancamentos]
GO
DROP TABLE [dbo].[Transferencias]
GO