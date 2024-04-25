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
	CONSTRAINT FK_ValorTaxaCartao_TaxaCartao FOREIGN KEY (Id_TaxaCartao) REFERENCES TaxaCartao(Id)
);


CREATE TABLE StatusFatura(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL,
	CONSTRAINT PK_IdStatusFatura PRIMARY KEY(Id)
);


CREATE TABLE Taxa(
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL
	CONSTRAINT PK_IdTaxas PRIMARY KEY(Id)
);

CREATE TABLE ValorTaxa (
	Id INT IDENTITY,
	Id_Taxa TINYINT NOT NULL,
	Aliquota DECIMAL(6,5)NOT NULL,
	DataInicial DATE NOT NULL,
	CONSTRAINT PK_IdValorTaxa PRIMARY KEY(Id),
	CONSTRAINT FK_ValorTaxa_Taxa FOREIGN KEY (Id_Taxa) REFERENCES Taxa(Id)
);

CREATE TABLE CreditScore (
	Id TINYINT IDENTITY,
	Nome VARCHAR(50) NOT NULL,
	Faixa DECIMAL(15,2) NOT NULL,
	Aliquota DECIMAL(3,2) NOT NULL,
	CONSTRAINT PK_Id_CreditScore PRIMARY KEY(Id)
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
	CONSTRAINT FK_IdCreditScore_Contas FOREIGN KEY(Id_CreditScore) REFERENCES CreditScore(Id),
	CONSTRAINT FK_IdCorrentista_Contas FOREIGN KEY(Id_Correntista) REFERENCES Correntista(Id),
	CONSTRAINT FK_IdUsuario_Contas FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id)
);

CREATE TABLE TaxaEmprestimo (
	Id TINYINT, 
	DataInicial DATE NOT NULL
	CONSTRAINT PK_IdTaxaEmprestimo PRIMARY KEY (Id)
);

CREATE TABLE ValorTaxaEmprestimo (
	Id INT IDENTITY,
	Id_TaxaEmprestimo TINYINT NOT NULL,
	Id_CreditScore TINYINT NOT NULL,
	Aliquota DECIMAL(6,5)NOT NULL,
	DataInicial DATE NOT NULL,
	CONSTRAINT PK_IdValorTaxaEmprestimo PRIMARY KEY(Id),
	CONSTRAINT FK_ValorTaxaEmprestimo_TaxaEmprestimo FOREIGN KEY (Id_TaxaEmprestimo) REFERENCES TaxaEmprestimo(Id),
	CONSTRAINT FK_IdCreditScore_TaxaEmp FOREIGN KEY (Id_CreditScore) REFERENCES CreditScore (Id)
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
);

CREATE TABLE SaldoDiario(
    Id INT IDENTITY PRIMARY KEY,
    IdCta INT NOT NULL,
    Vlr_SldInicial DECIMAL(15,2) NOT NULL,
    Vlr_SldFinal DECIMAL(15,2) NOT NULL,
    Vlr_Credito DECIMAL(15,2) NOT NULL,
    Vlr_Debito DECIMAL(15,2) NOT NULL,
    Dat_Saldo DATE NOT NULL
    CONSTRAINT FK_IdCta_SaldoDiario FOREIGN KEY (IdCta) REFERENCES Contas(Id)
);

CREATE TABLE CartaoCredito(
	Id INT IDENTITY,
	Id_Conta INT NOT NULL,
	Id_StatusCartaoCredito TINYINT NOT NULL,
	NomeImpresso VARCHAR(500) NOT NULL,
	Numero BIGINT NOT NULL UNIQUE,
	Cvc SMALLINT NOT NULL,
	Limite DECIMAL(15,2) NOT NULL,
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
	Id_StatusFatura TINYINT NOT NULL,
	Id_Conta INT NOT NULL,
	CodigoBarra BIGINT NOT NULL,
	DataEmissao DATE NOT NULL,
	DataVencimento DATE NOT NULL,
	CONSTRAINT PK_IdFatura PRIMARY KEY(Id),
	CONSTRAINT FK_Id_StatusFatura_Fatura FOREIGN KEY (Id_StatusFatura) REFERENCES StatusFatura(Id),
	CONSTRAINT FK_Id_Conta_Fatura FOREIGN KEY(Id_Conta) REFERENCES Contas(Id)
);

CREATE TABLE TransacaoCartaoCredito(
	Id INT IDENTITY,
	Id_CartaoCredito INT NOT NULL,
	Id_Fatura INT NOT NULL,
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
	IdTarifa TINYINT NOT NULL,
	Valor DECIMAL(4,2),
	Taxa DECIMAL(6,5),
	DataInicial DATE NOT NULL,
	CONSTRAINT PK_PrecoTarifasId PRIMARY KEY(Id),
	CONSTRAINT FK_IdTarifaPreco FOREIGN KEY(IdTarifa) REFERENCES Tarifas(Id)
);

CREATE TABLE TipoLancamento (
	Id TINYINT PRIMARY KEY,
	Nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Lancamentos (
	Id INT IDENTITY PRIMARY KEY, 
	Id_Cta INT NOT NULL,
	Id_Usuario INT,
	Id_TipoLancamento TINYINT NOT NULL,
	Tipo_Operacao CHAR(1) NOT NULL,
	Vlr_Lanc Decimal (15,2) NOT NULL,
	Nom_Historico VARCHAR(500) NOT NULL,
	Dat_Lancamento DATETIME NOT NULL,
	Estorno BIT NOT NULL,
	CONSTRAINT FK_Conta_Lancamentos FOREIGN KEY (Id_Cta) REFERENCES Contas(Id),
	CONSTRAINT FK_Usuario_Lancamentos FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id),
	CONSTRAINT FK_TipoLancamento_Lancamentos FOREIGN KEY (Id_TipoLancamento) REFERENCES TipoLancamento(Id),
	CONSTRAINT CHK_Tipo_Operacao_C_D CHECK(Tipo_Operacao = 'C' OR Tipo_Operacao = 'D')
);

CREATE TABLE LancamentosPrecoTarifas (
	Id_Lancamentos INT UNIQUE,
	Id_PrecoTarifas INT,
	CONSTRAINT FK_IdLancamentosPT FOREIGN KEY(Id_Lancamentos) REFERENCES Lancamentos(Id),
	CONSTRAINT FK_IdPrecoTarifasLancamentosPT FOREIGN KEY(Id_PrecoTarifas) REFERENCES PrecoTarifas(Id)
);

CREATE TABLE LancamentosValorTaxa (
	Id_Lancamentos INT UNIQUE,
	Id_ValorTaxa INT,
	CONSTRAINT FK_IdLancamentosValorTaxa FOREIGN KEY(Id_Lancamentos) REFERENCES Lancamentos(Id),
	CONSTRAINT FK_IdValorTaxaLancamentosVT FOREIGN KEY(Id_ValorTaxa) REFERENCES ValorTaxa(Id)
);

CREATE TABLE LancamentosTransacao (
	Id_Lancamentos INT UNIQUE,
	Id_TransacaoCartaoCredito INT,
	CONSTRAINT FK_IdLancamentosTransacao FOREIGN KEY(Id_Lancamentos) REFERENCES Lancamentos(Id),
	CONSTRAINT FK_IdTransacaoCartaoCreditoLancamentos FOREIGN KEY(Id_TransacaoCartaoCredito) REFERENCES TransacaoCartaoCredito(Id)
);

CREATE TABLE Transferencias (
	Id INT PRIMARY KEY IDENTITY, 
	Id_Usuario INT NOT NULL,
	Id_CtaCre INT NOT NULL, 
	Id_CtaDeb INT NOT NULL, 
	Vlr_Trans DECIMAL (15,2) NOT NULL,
	Nom_Referencia VARCHAR (200) NOT NULL,
	Dat_Trans DATETIME NOT NULL,
	CONSTRAINT FK_Conta_Credito_Transferencias FOREIGN KEY (Id_CtaCre) REFERENCES Contas(Id),
	CONSTRAINT FK_Conta_Debito_Transferencias FOREIGN KEY (Id_CtaDeb) REFERENCES Contas(Id),
	CONSTRAINT FK_Usuario_Transferencias FOREIGN KEY (Id_Usuario ) REFERENCES Usuarios(Id)
);