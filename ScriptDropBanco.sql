USE SistemaBancario
GO
		-- DROPANDO CONSTRAINT DE FK 

-- Executando o drop de constraint de FK na tabela contas
ALTER TABLE CONTAS
	DROP CONSTRAINT FK_IdCreditScoreContas
GO

-- Executando o drop de constraint de FK na tabela Lancamentos
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Conta_Lancamento
GO
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Tarifa_Lancamentos
GO
ALTER TABLE Lancamentos
	DROP CONSTRAINT FK_Usuario_Lancamento
GO

-- Executando o drop de constraint de FK na tabela Transferencias
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Conta_Credito
GO
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_Conta_Debito
GO
ALTER TABLE Transferencias
	DROP CONSTRAINT FK_UsuarioTransferencia
GO

		-- DROPANDO TRIGGERS DO SISTEMA BANCARIO
DROP TRIGGER [TRG_InserirTaxaSaldoNegativo]
GO
DROP TRIGGER [TRG_TaxaAberturaConta]
GO
DROP TRIGGER [TRG_AtualizarSaldo]
GO
DROP TRIGGER [TRG_TarifaTransferencia]
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


		-- DROPANDO TODAS OS JOBS 
DROP PROC [dbo].[SPJOB_AtualizarCreditScore]
GO
DROP PROC [dbo].[SPJOB_AtualizarSaldo]
GO
DROP PROC [dbo].[SPJOB_AplicarTaxaManutencao]
GO


-- DROPANDO TODAS AS FUNCTIONS

DROP FUNCTION [dbo].[FNC_ListarSaldoNegativo]
GO
DROP FUNCTION [dbo].[FNC_CalcularSaldoDisponivel]
GO
DROP FUNCTION [dbo].[FNC_CalcularSaldoAtual]
GO

 --DROPANDO TODAS AS TABELAS

DROP TABLE [dbo].[Usuarios]
GO
DROP TABLE [dbo].[CreditScore]
GO
DROP TABLE [dbo].[Contas]
GO
DROP TABLE [dbo].[Tarifas]
GO
DROP TABLE [dbo].[Lancamentos]
GO
DROP TABLE [dbo].[Transferencias]
GO