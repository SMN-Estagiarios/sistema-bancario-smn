CREATE DATABASE SistemaBancario
GO

USE SistemaBancario
GO

CREATE TABLE Usuarios(
	Id INT IDENTITY (0,1) PRIMARY KEY, 
	Nom_Usuario VARCHAR(50) NOT NULL 
);

CREATE TABLE CreditScore (
	Id TINYINT IDENTITY,
	Nome VARCHAR(50) NOT NULL,
	Faixa DECIMAL(15,2) NOT NULL,
	Aliquota DECIMAL(3,2) NOT NULL,
	CONSTRAINT Id_CreditScore PRIMARY KEY(Id)
);

CREATE TABLE Correntista(
	Id INT IDENTITY,
	Nome VARCHAR(500) NOT NULL,
	Cpf BIGINT NOT NULL,
	DataNasc DATE NOT NULL,
	Contato BIGINT NOT NULL,
	Email VARCHAR(500) NOT NULL,
	Logradouro VARCHAR(500) NOT NULL,
	Numero SMALLINT,
	CONSTRAINT PK_IdCorrentista PRIMARY KEY(Id)
);

CREATE TABLE Contas (
	Id INT IDENTITY,
	Vlr_SldInicial DECIMAL (15,2) NOT NULL, 
	Vlr_Credito DECIMAL (15,2) NOT NULL,
	Vlr_Debito DECIMAL (15,2) NOT NULL, 
	Dat_Saldo DATE NOT NULL,
	Dat_Abertura DATE NOT NULL,
	Dat_Encerramento DATE, 
	Ativo BIT NOT NULL,
	Lim_ChequeEspecial DECIMAL(15,2) NOT NULL,
	IdCreditScore TINYINT,
	IdCorrentista INT NOT NULL,
	CONSTRAINT PK_IdContas PRIMARY KEY(Id),
	CONSTRAINT FK_IdCreditScoreContas FOREIGN KEY(IdCreditScore) REFERENCES CreditScore(Id),
	CONSTRAINT FK_IdCorrentistaContas FOREIGN KEY(IdCorrentista) REFERENCES Correntista(Id)
); 

CREATE TABLE StatusCartaoCredito(
	Id TINYINT IDENTITY,
	Nome VARCHAR(500),
	CONSTRAINT PK_IdStatusCartaoCredito PRIMARY KEY(Id)
);

CREATE TABLE CartaoCredito(
	Id INT IDENTITY,
	NomeImpresso VARCHAR(500) NOT NULL,
	Numero BIGINT NOT NULL UNIQUE,
	Cvc SMALLINT NOT NULL,
	Limite DECIMAL(15,2) NOT NULL,
	DataEmissao DATE NOT NULL,
	DataValidade DATE NOT NULL,
	Aproximacao BIT NOT NULL,
	VencimentoDia TINYINT NOT NULL,
	IdConta INT NOT NULL,
	IdStatusCartaoCredito TINYINT NOT NULL,
	CONSTRAINT PK_IdCartaoCredito PRIMARY KEY(Id),
	CONSTRAINT FK_IdContasCartaoCredito FOREIGN KEY(IdConta) REFERENCES Contas(Id),
	CONSTRAINT FK_IdStatusCartaoCreditoCartaoCredito FOREIGN KEY (IdStatusCartaoCredito) REFERENCES StatusCartaoCredito(Id)
);

CREATE TABLE StatusFatura(
	Id TINYINT IDENTITY,
	Nome VARCHAR(500),
	CONSTRAINT PK_IdStatusFatura PRIMARY KEY(Id)
);

CREATE TABLE Fatura(
	Id INT IDENTITY,
	CodigoBarra BIGINT NOT NULL,
	DataEmissao DATE NOT NULL,
	DataVencimento DATE NOT NULL,
	IdStatusFatura TINYINT NOT NULL,
	IdConta INT NOT NULL,
	CONSTRAINT PK_IdFatura PRIMARY KEY(Id),
	CONSTRAINT FK_IdStatusFaturaFatura FOREIGN KEY (IdStatusFatura) REFERENCES StatusFatura(Id),
	CONSTRAINT FK_IdContaFatura FOREIGN KEY(IdConta) REFERENCES Contas(Id)
);

CREATE TABLE TransacaoCartaoCredito(
	Id INT IDENTITY,
	Nom_Historico VARCHAR(500) NOT NULL,
	Dat_Trans DATETIME NOT NULL,
	Valor_Trans DECIMAL(15,2) NOT NULL,
	Estorno BIT NOT NULL,
	IdCartaoCredito INT NOT NULL,
	IdFatura INT NOT NULL,
	CONSTRAINT PK_IdTransacaoCartaoCredito PRIMARY KEY (Id),
	CONSTRAINT FK_IdCartaoCreditoTransacaoCartaoCredito FOREIGN KEY (IdCartaoCredito) REFERENCES CartaoCredito(Id),
	CONSTRAINT FK_IdFaturaTransacaoCartaoCredito FOREIGN KEY (IdFatura) REFERENCES Fatura(Id)
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
    Id INT PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL UNIQUE
 );

 CREATE TABLE Lancamentos (
    Id INT IDENTITY PRIMARY KEY, 
    Id_Cta INT NOT NULL,
	Id_Usuario INT NOT NULL,
    Id_TipoLancamento INT NOT NULL,
    Id_Tarifa TINYINT,
    Tipo_Operacao CHAR(1) NOT NULL,
    Vlr_Lanc Decimal (15,2) NOT NULL,
    Nom_Historico VARCHAR(500) NOT NULL,
    Dat_Lancamento DATETIME NOT NULL,
    Estorno BIT NOT NULL,
    CONSTRAINT FK_Conta_Lancamentos FOREIGN KEY (Id_Cta) REFERENCES Contas(Id),
	CONSTRAINT FK_Usuario_Lancamentos FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id),
    CONSTRAINT FK_TipoLancamento_Lancamentos FOREIGN KEY (Id_TipoLancamento) REFERENCES TipoLancamento(Id),
    CONSTRAINT FK_Tarifa_Lancamentos FOREIGN KEY (Id_Tarifa) REFERENCES Tarifas(Id),
	CONSTRAINT CHK_Tipo_Operacao_C_D CHECK(Tipo_Operacao = 'C' OR Tipo_Operacao = 'D')
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