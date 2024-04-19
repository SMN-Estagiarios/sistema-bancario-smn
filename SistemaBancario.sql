USE SistemaBancario
GO

CREATE DATABASE SistemaBancario
GO

USE SistemaBancario
GO

CREATE TABLE Usuarios(
	Id INT IDENTITY PRIMARY KEY, 
	Nom_Usuario VARCHAR(50) NOT NULL 
);

CREATE TABLE CreditScore (
	Id TINYINT IDENTITY,
	Nome VARCHAR(50) NOT NULL,
	Faixa DECIMAL(15,2) NOT NULL,
	Aliquota DECIMAL(3,2) NOT NULL,
	CONSTRAINT Id_CreditScore PRIMARY KEY(Id)
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
	CONSTRAINT PK_ContasId PRIMARY KEY(Id),
	CONSTRAINT FK_IdCreditScoreContas FOREIGN KEY(IdCreditScore) REFERENCES CreditScore(Id)
); 

CREATE TABLE Tarifas (
	Id TINYINT,
	Nome VARCHAR(50) NOT NULL, 
	Valor DECIMAL(4,2),
	Taxa DECIMAL(6,5),
	CONSTRAINT PK_TarifasId PRIMARY KEY(Id)
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
    CONSTRAINT FK_Conta_Lancamento FOREIGN KEY (Id_Cta) REFERENCES Contas(Id),
    CONSTRAINT FK_Usuario_Lancamento FOREIGN KEY (Id_Usuario) REFERENCES Usuarios(Id),
	CONSTRAINT CHK_Tipo_Operacao_C_D CHECK(Tipo_Operacao = 'C' OR Tipo_Operacao = 'D'),
    CONSTRAINT FK_TipoLancamento_Lancamentos FOREIGN KEY (Id_TipoLancamento) REFERENCES TipoLancamento(Id),
    CONSTRAINT FK_Tarifa_Lancamentos FOREIGN KEY (Id_Tarifa) REFERENCES Tarifas(Id)
);


CREATE TABLE Transferencias (
	Id INT PRIMARY KEY IDENTITY, 
	Id_Usuario INT NOT NULL,
	Id_CtaCre INT NOT NULL, 
	Id_CtaDeb INT NOT NULL, 
	Vlr_Trans DECIMAL (15,2) NOT NULL,
	Nom_Referencia VARCHAR (200) NOT NULL,
	Dat_Trans DATETIME NOT NULL,
	CONSTRAINT FK_Conta_Credito FOREIGN KEY (Id_CtaCre) REFERENCES Contas(Id),
	CONSTRAINT FK_Conta_Debito FOREIGN KEY (Id_CtaDeb) REFERENCES Contas(Id),
	CONSTRAINT FK_UsuarioTransferencia  FOREIGN KEY (Id_Usuario ) REFERENCES Usuarios(Id)
); 




