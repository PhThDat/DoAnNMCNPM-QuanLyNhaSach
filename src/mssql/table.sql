CREATE DATABASE SoftwareProject;

USE SoftwareProject;

-- Create tables
CREATE TABLE Book (
    ID INT IDENTITY(1, 1),
    Name NVARCHAR(50),
    Category NVARCHAR(20),
    Author NVARCHAR(50),
    ImportPrice DECIMAL(19, 4),
    CONSTRAINT PK_Book_ID PRIMARY KEY (ID),
);

CREATE TABLE PassedMonth (
    MonthYear DATE NOT NULL,
    CONSTRAINT PK_PassedMonth_MonthYear PRIMARY KEY (MonthYear),
);

CREATE TABLE Warehouse (
    BookID INT NOT NULL,
    MonthYear DATE NOT NULL,
    InitAmount INT,
    FinalAmount INT,
    CONSTRAINT PK_Warehouse_BookID_MonthYear PRIMARY KEY (BookID, MonthYear),
);

CREATE TABLE Customer (
    ID INT IDENTITY(1, 1),
    FullName NVARCHAR(50),
    Address NVARCHAR(100),
    PhoneNumber CHAR(10),
    Email VARCHAR(70),
    CONSTRAINT PK_Customer_ID PRIMARY KEY (ID)
);

CREATE TABLE Bill (
    ID INT IDENTITY(1, 1),
    CustomerID INT NOT NULL,
    Paid DECIMAL(19, 4),
    OccuredDate DATE,
    CONSTRAINT PK_Bill_ID PRIMARY KEY (ID),
);

CREATE TABLE BillDetail (
    BookID INT NOT NULL,
    BillID INT NOT NULL,
    Amount INT,
    CONSTRAINT PK_BillDetail_BookID_BillID PRIMARY KEY (BookID, BillID),
);

CREATE TABLE Debt (
    CustomerID INT NOT NULL,
    MonthYear DATE NOT NULL,
    InitAmount DECIMAL(19, 4),
    FinalAmount DECIMAL(19, 4),
    CONSTRAINT PK_Debt_CustomerID_MonthYear PRIMARY KEY (CustomerID, MonthYear),
);

CREATE TABLE ImportLog (
    OccuredDatetime DATETIME NOT NULL,
    BookID INT NOT NULL,
    Amount INT,
    Price DECIMAL(19, 4),
    CONSTRAINT PK_ImportLog_OccurenceDateTime PRIMARY KEY (OccuredDatetime),
);

CREATE TABLE PayDebtLog (
    OccuredDatetime DATETIME NOT NULL,
    CustomerID INT NOT NULL,
    PaidAmount DECIMAL(19, 4),
    CONSTRAINT PK_PayDebtLog_OccurenceDateTime PRIMARY KEY (OccuredDatetime),
);

-- Foreign Keys
ALTER TABLE Warehouse
ADD CONSTRAINT FK_Warehouse_Book_StockID FOREIGN KEY (BookID) REFERENCES Book(ID),
    CONSTRAINT FK_Warehouse_PassedMonth_MonthYear FOREIGN KEY (MonthYear) REFERENCES PassedMonth(MonthYear);

ALTER TABLE Bill
ADD CONSTRAINT FK_Bill_Customer_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(ID);

ALTER TABLE BillDetail
ADD CONSTRAINT FK_BillDetail_Book_BookID FOREIGN KEY (BookID) REFERENCES Book(ID),
    CONSTRAINT FK_BillDetail_Bill_BillID FOREIGN KEY (BillID) REFERENCES Bill(ID);

ALTER TABLE Debt
ADD CONSTRAINT FK_Debt_Customer_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(ID),
    CONSTRAINT FK_Debt_PassedMonth_MonthYear FOREIGN KEY (MonthYear) REFERENCES PassedMonth(MonthYear);

ALTER TABLE ImportLog
ADD CONSTRAINT FK_ImportLog_Book_BookID FOREIGN KEY (BookID) REFERENCES Book(ID);

ALTER TABLE PayDebtLog
ADD CONSTRAINT FK_PayDebtLog_Customer_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customer(ID);