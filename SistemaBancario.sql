CREATE DATABASE SistemaBancario
GO

USE SistemaBancario
GO

CREATE TABLE Usuarios(
	Id INT IDENTITY (0,1) PRIMARY KEY, 
	Nom_Usuario VARCHAR(50) NOT NULL 
);

CREATE TABLE StatusCartaoCredito(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	CONSTRAINT PK_IdStatusCartaoCredito PRIMARY KEY(Id)
);

CREATE TABLE StatusEmprestimo(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	CONSTRAINT PK_IdStatusEmprestimo PRIMARY KEY(Id)
);

CREATE TABLE TipoTransacao(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	CONSTRAINT PK_IdTipoTransacao PRIMARY KEY(Id)
);

CREATE TABLE TaxaCartao(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	CONSTRAINT PK_IdTaxaCartao PRIMARY KEY(Id)
);

CREATE TABLE ValorTaxaCartao (
	Id INT IDENTITY,
	Id_TaxaCartao TINYINT NOT NULL,
	Aliquota DECIMAL(6,5) NOT NULL,
	DataInicial DATE NOT NULL
	CONSTRAINT PK_IdValorTaxaCartao PRIMARY KEY(Id),
	CONSTRAINT FK_Id_TaxaCartao_TaxaCartao FOREIGN KEY (Id_TaxaCartao) REFERENCES TaxaCartao(Id)
);

CREATE TABLE Taxa(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL
	CONSTRAINT PK_IdTaxa PRIMARY KEY(Id)
);

CREATE TABLE ValorTaxa (
	Id INT IDENTITY,
	Id_Taxa TINYINT NOT NULL,
	Aliquota DECIMAL(6,5)NOT NULL,
	DataInicial DATE NOT NULL,
	CONSTRAINT PK_IdValorTaxa PRIMARY KEY(Id),
	CONSTRAINT FK_Id_Taxa_ValorTaxa FOREIGN KEY (Id_Taxa) REFERENCES Taxa(Id)
);

CREATE TABLE CreditScore (
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	Faixa DECIMAL(15,2) NOT NULL,
	Aliquota DECIMAL(3,2) NOT NULL,
	CONSTRAINT PK_IdCreditScore PRIMARY KEY(Id)
);

CREATE TABLE Correntista(
	Id INT IDENTITY,
	Nome VARCHAR(500) NOT NULL,
	Cpf BIGINT UNIQUE NOT NULL,
	DataNasc DATE NOT NULL,
	Contato BIGINT UNIQUE NOT NULL,
	Email VARCHAR(500) UNIQUE NOT NULL,
	Logradouro VARCHAR(500) NOT NULL,
	Numero VARCHAR(6),
	Ativo BIT NOT NULL,
	CONSTRAINT PK_IdCorrentista PRIMARY KEY(Id)
);

CREATE TABLE Contas (
	Id INT IDENTITY,
	Id_CreditScore TINYINT,
	Id_Correntista INT NOT NULL,
	Id_Usuario INT,
	Vlr_SldInicial DECIMAL (15,2) NOT NULL, 
	Vlr_Credito DECIMAL (15,2) NOT NULL,
	Vlr_Debito DECIMAL (15,2) NOT NULL, 
	Dat_Saldo DATE NOT NULL,
	Dat_Abertura DATE NOT NULL,
	Dat_Encerramento DATE, 
	Ativo BIT NOT NULL,
	Lim_ChequeEspecial DECIMAL(15,2) NOT NULL
	CONSTRAINT PK_IdContas PRIMARY KEY(Id),
	CONSTRAINT FK_Id_CreditScore_Contas FOREIGN KEY(Id_CreditScore) REFERENCES CreditScore(Id),
	CONSTRAINT FK_Id_Correntista_Contas FOREIGN KEY(Id_Correntista) REFERENCES Correntista(Id),
	CONSTRAINT FK_Id_Usuario_Contas FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id)
);

CREATE TABLE TaxaEmprestimo (
	Id TINYINT, 
	Nome VARCHAR (50) NOT NULL
	CONSTRAINT PK_IdTaxaEmprestimo PRIMARY KEY (Id)
);

CREATE TABLE ValorTaxaEmprestimo (
	Id INT IDENTITY,
	Id_TaxaEmprestimo TINYINT NOT NULL,
	Id_CreditScore TINYINT NOT NULL,
	Aliquota DECIMAL(6,5)NOT NULL,
	DataInicial DATE NOT NULL,
	CONSTRAINT PK_IdValorTaxaEmprestimo PRIMARY KEY(Id),
	CONSTRAINT FK_Id_TaxaEmprestimo_ValorTaxaEmprestimo FOREIGN KEY (Id_TaxaEmprestimo) REFERENCES TaxaEmprestimo(Id),
	CONSTRAINT FK_Id_CreditScore_ValorTaxaEmprestimo FOREIGN KEY (Id_CreditScore) REFERENCES CreditScore (Id)
);

CREATE TABLE Emprestimo (
	Id INT IDENTITY, 
	Id_Conta INT NOT NULL,
	Id_StatusEmprestimo TINYINT NOT NULL,
	Id_ValorTaxaEmprestimo INT NOT NULL, 
	Id_Taxa TINYINT NOT NULL,
	ValorSolicitado DECIMAL(15,2) NOT NULL,
	ValorParcela DECIMAL(15,2) NOT NULL,
	NumeroParcelas SMALLINT NOT NULL, 
	Tipo CHAR(3) NOT NULL, 
	DataInicio DATE NOT NULL
	CONSTRAINT PK_IdEmprestimo PRIMARY KEY (Id),
	CONSTRAINT FK_Id_Conta_Emprestimo FOREIGN KEY (Id_Conta) REFERENCES Contas (Id),
	CONSTRAINT FK_Id_StatusEmprestimo_Emprestimo FOREIGN KEY (Id_StatusEmprestimo) REFERENCES StatusEmprestimo (Id),
	CONSTRAINT FK_Id_TaxaEmprestimo_Emprestimo FOREIGN KEY (Id_ValorTaxaEmprestimo) REFERENCES ValorTaxaEmprestimo (Id),
	CONSTRAINT FK_Id_Taxa_Emprestimo FOREIGN KEY (Id_Taxa) REFERENCES Taxa (Id)
);

CREATE TABLE SaldoDiario(
	Id INT IDENTITY PRIMARY KEY,
	Id_Conta INT NOT NULL,
	Vlr_SldInicial DECIMAL(15,2) NOT NULL,
	Vlr_SldFinal DECIMAL(15,2) NOT NULL,
	Vlr_Credito DECIMAL(15,2) NOT NULL,
	Vlr_Debito DECIMAL(15,2) NOT NULL,
	Dat_Saldo DATE NOT NULL
	CONSTRAINT FK_Id_Conta_SaldoDiario FOREIGN KEY (Id_Conta) REFERENCES Contas(Id)
);

CREATE TABLE CartaoCredito(
	Id INT IDENTITY,
	Id_Conta INT NOT NULL,
	Id_StatusCartaoCredito TINYINT NOT NULL,
	NomeImpresso VARCHAR(500) NOT NULL,
	Numero BIGINT NOT NULL UNIQUE,
	Cvc SMALLINT NOT NULL,
	Limite DECIMAL(15,2) NOT NULL,
	LimiteComprometido DECIMAL(15,2) NOT NULL,
	DataEmissao DATE NOT NULL,
	DataValidade DATE NOT NULL,
	Aproximacao BIT NOT NULL,
	DiaVencimento TINYINT NOT NULL,
	CONSTRAINT PK_IdCartaoCredito PRIMARY KEY(Id),
	CONSTRAINT FK_Id_Conta_CartaoCredito FOREIGN KEY(Id_Conta) REFERENCES Contas(Id),
	CONSTRAINT FK_Id_StatusCartaoCredito_CartaoCredito FOREIGN KEY (Id_StatusCartaoCredito) REFERENCES StatusCartaoCredito(Id)
);

CREATE TABLE Fatura(
	Id INT IDENTITY,
	Id_Conta INT NOT NULL,
	Id_Lancamento INT NOT NULL,
	CodigoBarra BIGINT NOT NULL,
	DataEmissao DATE NOT NULL,
	DataVencimento DATE NOT NULL,
	Vlr_Fatura DECIMAL(15, 2) NOT NULL, 
	CONSTRAINT PK_IdFatura PRIMARY KEY(Id),
	CONSTRAINT FK_Id_StatusFatura_Fatura FOREIGN KEY (Id_StatusFatura) REFERENCES StatusFatura(Id),
	CONSTRAINT FK_Id_Conta_Fatura FOREIGN KEY(Id_Conta) REFERENCES Contas(Id),
	CONSTRAINT FK_Id_Lancamento_Fatura FOREIGN KEY(Id_Lancamento) REFERENCES Lancamentos(Id)
);

CREATE TABLE TransacaoCartaoCredito(
	Id INT IDENTITY,
	Id_CartaoCredito INT NOT NULL,
	Id_Fatura INT,
	Id_ValorTaxaCartao INT NOT NULL,
	Id_TipoTransacao TINYINT NOT NULL,
	Nom_Historico VARCHAR(500) NOT NULL,
	Dat_Trans DATETIME NOT NULL,
	Valor_Trans DECIMAL(15,2) NOT NULL,
	Estorno BIT NOT NULL
	CONSTRAINT PK_Id_TransacaoCartaoCredito PRIMARY KEY (Id),
	CONSTRAINT FK_Id_CartaoCredito_TransacaoCartaoCredito FOREIGN KEY (Id_CartaoCredito) REFERENCES CartaoCredito(Id),
	CONSTRAINT FK_Id_Fatura_TransacaoCartaoCredito FOREIGN KEY (Id_Fatura) REFERENCES Fatura(Id),
	CONSTRAINT FK_Id_ValorTaxaCartao_TransacaoCartaoCredito FOREIGN KEY (Id_ValorTaxaCartao) REFERENCES ValorTaxaCartao(Id),
	CONSTRAINT FK_Id_TipoTransacao_TransacaoCartaoCredito FOREIGN KEY (Id_TipoTransacao) REFERENCES TipoTransacao(Id)
);

CREATE TABLE Tarifas (
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	CONSTRAINT PK_IdTarifas PRIMARY KEY(Id)
);

CREATE TABLE PrecoTarifas (
	Id INT,
	Id_Tarifa TINYINT NOT NULL,
	Valor DECIMAL(4,2),
	DataInicial DATE NOT NULL,
	CONSTRAINT PK_IdPrecoTarifas PRIMARY KEY(Id),
	CONSTRAINT FK_Id_Tarifa_PrecoTarifas FOREIGN KEY(Id_Tarifa) REFERENCES Tarifas(Id)
);

CREATE TABLE TipoLancamento (
	Id TINYINT PRIMARY KEY,
	Nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Lancamentos (
	Id INT IDENTITY, 
	Id_Conta INT NOT NULL,
	Id_Usuario INT,
	Id_TipoLancamento TINYINT NOT NULL,
	Tipo_Operacao CHAR(1) NOT NULL,
	Vlr_Lanc Decimal (15,2) NOT NULL,
	Nom_Historico VARCHAR(500) NOT NULL,
	Dat_Lancamento DATETIME NOT NULL,
	Estorno BIT NOT NULL,
	CONSTRAINT PK_IdLancamentos PRIMARY KEY(Id),
	CONSTRAINT FK_Id_Conta_Lancamentos FOREIGN KEY (Id_Conta) REFERENCES Contas(Id),
	CONSTRAINT FK_Id_Usuario_Lancamentos FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id),
	CONSTRAINT FK_Id_TipoLancamento_Lancamentos FOREIGN KEY (Id_TipoLancamento) REFERENCES TipoLancamento(Id),
	CONSTRAINT CHK_Tipo_Operacao_C_D CHECK(Tipo_Operacao = 'C' OR Tipo_Operacao = 'D')
);

CREATE TABLE Parcela (
	Id_Emprestimo INT NOT NULL,
	Id_Lancamento INT NOT NULL UNIQUE,
	Valor DECIMAL(15,2) NOT NULL,
	Data_Cadastro DATE NOT NULL

	CONSTRAINT FK_Id_Emprestimo_Parcela FOREIGN KEY (Id_Emprestimo) REFERENCES Emprestimo(Id),
	CONSTRAINT FK_Id_Lancamento_Parcela FOREIGN KEY (Id_Lancamento) REFERENCES Lancamentos(Id)
);

CREATE TABLE LancamentosPrecoTarifas (
	Id_Lancamentos INT UNIQUE,
	Id_PrecoTarifas INT,
	CONSTRAINT FK_Id_Lancamentos_LancamentosPrecoTarifas FOREIGN KEY(Id_Lancamentos) REFERENCES Lancamentos(Id),
	CONSTRAINT FK_Id_PrecoTarifas_LancamentosPrecoTarifas FOREIGN KEY(Id_PrecoTarifas) REFERENCES PrecoTarifas(Id)
);

CREATE TABLE LancamentosValorTaxa (
	Id_Lancamentos INT UNIQUE,
	Id_ValorTaxa INT,
	CONSTRAINT FK_Id_Lancamentos_LancamentosValorTaxa FOREIGN KEY(Id_Lancamentos) REFERENCES Lancamentos(Id),
	CONSTRAINT FK_Id_ValorTaxa_LancamentosValorTaxa FOREIGN KEY(Id_ValorTaxa) REFERENCES ValorTaxa(Id)
);

CREATE TABLE LancamentosTransacao (
	Id_Lancamentos INT UNIQUE,
	Id_TransacaoCartaoCredito INT,
	CONSTRAINT FK_Id_Lancamentos_LancamentosTransacao FOREIGN KEY(Id_Lancamentos) REFERENCES Lancamentos(Id),
	CONSTRAINT FK_Id_TransacaoCartaoCredito_LancamentosTransacao FOREIGN KEY(Id_TransacaoCartaoCredito) REFERENCES TransacaoCartaoCredito(Id)
);

CREATE TABLE Transferencias (
	Id INT PRIMARY KEY IDENTITY, 
	Id_Usuario INT NOT NULL,
	Id_Conta_Credito INT NOT NULL, 
	Id_Conta_Debito INT NOT NULL, 
	Vlr_Trans DECIMAL (15,2) NOT NULL,
	Nom_Referencia VARCHAR (200) NOT NULL,
	Dat_Trans DATETIME NOT NULL,
	CONSTRAINT FK_Id_Conta_Credito_Transferencias FOREIGN KEY (Id_Conta_Credito) REFERENCES Contas(Id),
	CONSTRAINT FK_Id_Conta_Debito_Transferencias FOREIGN KEY (Id_Conta_Debito) REFERENCES Contas(Id),
	CONSTRAINT FK_Id_Usuario_Transferencias FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id),
);

CREATE TABLE TransferenciasLancamentos (
	IdTransferencia INT NOT NULL,
	IdLancamento INT UNIQUE NOT NULL,
	CONSTRAINT FK_IdTransferencia_TransferenciaLancamentos FOREIGN KEY (IdTransferencia) REFERENCES Transferencias(Id),
	CONSTRAINT FK_IdLancamento_TransferenciaLancamentos FOREIGN KEY (IdLancamento) REFERENCES Usuarios(Id)
);
