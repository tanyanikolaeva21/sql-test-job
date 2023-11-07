
USE MASTER 
GO

IF EXISTS (SELECT 1 FROM sys.databases AS d WHERE d.name = 'DBTestPractice')
DROP DATABASE DBTestPractice 
GO

CREATE DATABASE DBTestPractice;
GO
ALTER DATABASE DBTestPractice
SET RECOVERY SIMPLE;
GO
 
USE DBTestPractice;
GO

IF OBJECT_ID('dbo.DD_Docs') IS NOT NULL DROP TABLE dbo.DD_Docs
GO
IF OBJECT_ID('dbo.SD_Subscrs') IS NOT NULL DROP TABLE dbo.SD_Subscrs
GO
IF OBJECT_ID('dbo.FD_Bills') IS NOT NULL DROP TABLE dbo.FD_Bills
GO
IF OBJECT_ID('dbo.FD_Payments') IS NOT NULL DROP TABLE dbo.FD_Payments
GO
IF OBJECT_ID('dbo.FD_Payment_Details') IS NOT NULL DROP TABLE dbo.FD_Payment_Details
GO

CREATE TABLE dbo.SD_Subscrs -- Лицевые счета
(
    [LINK]          [int] IDENTITY NOT NULL PRIMARY KEY,    -- Ид
    [C_Number]      [varchar](20)  NOT NULL,                -- Номер лс
    [C_FirstName]   [varchar](150) NOT NULL,                -- Имя  
    [C_SecondName]  [varchar](150) NOT NULL,                -- Фамилия  
    [C_Address]     [varchar](300) NULL,                    -- Адрес регистрации
    [C_Doc_Serial]  [varchar](4) NULL,                      -- Серия паспорта
    [C_Doc_Number]  [varchar](6) NULL,                      -- Номер паспорта 
    [D_BirthDate]   [date] NOT NULL,                        -- Дата рождения    
    CONSTRAINT UC_SD_Subscrs_C_Number UNIQUE(C_Number) 
) 
GO
CREATE TABLE dbo.DD_Docs -- Документы
(
    [LINK]          [int] IDENTITY NOT NULL PRIMARY KEY,    -- Ид
    [C_Number]      [varchar] (50) NULL,                    -- Номер  
    [F_Subscr]      [int] NOT NULL,                         -- Л/с
    [C_Doc_Type]    [varchar](50) NOT NULL,                 -- Тип 
    [D_Date]        [date] NOT NULL DEFAULT GETDATE(),      -- Дата 
    [F_Docs]        [int] NULL,                             -- Родительский документ
    CONSTRAINT FK_DD_Docs_DD_Docs FOREIGN KEY (F_Docs) REFERENCES dbo.DD_Docs (LINK),
    CONSTRAINT FK_DD_Docs_SD_Subscrs FOREIGN KEY (F_Subscr) REFERENCES dbo.SD_Subscrs (LINK) ON DELETE CASCADE
) 
GO
CREATE TABLE dbo.FD_Bills -- Счета
(
    [LINK]          [int] IDENTITY NOT NULL PRIMARY KEY,    -- Ид
    [C_Number]      [varchar] (50) NULL,                    -- Номер  
    [F_Subscr]      [int] NOT NULL,                         -- Л/с
    [C_Sale_Items]  [varchar](50) NOT NULL,                 -- Услуга
    [D_Date]        [date] NOT NULL DEFAULT GETDATE(),      -- Дата 
    [N_Amount]      [money] NOT NULL,                       -- Сумма
    [N_Amount_Rest] [money] NOT NULL,                       -- Остаток
    CONSTRAINT FK_FD_Bills_SD_Subscrs FOREIGN KEY (F_Subscr) REFERENCES dbo.SD_Subscrs (LINK) ON DELETE CASCADE
) 
GO
CREATE TABLE dbo.FD_Payments -- Платежи
(
    [LINK]          [int] IDENTITY NOT NULL PRIMARY KEY,    -- Ид
    [C_Number]      [varchar] (50) NULL,                    -- Номер  
    [F_Subscr]      [int] NOT NULL,                         -- Л/с
    [D_Date]        [date] NOT NULL DEFAULT GETDATE(),      -- Дата 
    [N_Amount]      [money] NOT NULL,                       -- Сумма
    CONSTRAINT FK_FD_Payments_SD_Subscrs FOREIGN KEY (F_Subscr) REFERENCES dbo.SD_Subscrs (LINK) ON DELETE CASCADE
) 
GO
CREATE TABLE dbo.FD_Payment_Details -- Детализация платежей
(
    [F_Payments]    [int] NOT NULL,                         -- Ид платежа
    [F_Bills]       [int] NOT NULL,                         -- Ид счета
    [C_Sale_Items]  [varchar](50) NOT NULL,                 -- Услуга
    [N_Amount]      [money] NOT NULL                        -- Сумма  
    CONSTRAINT FK_FD_Payment_Details_FD_Payments FOREIGN KEY (F_Payments) REFERENCES dbo.FD_Payments (LINK) ON DELETE CASCADE,
    CONSTRAINT FK_FD_Payment_Details_FD_Bills FOREIGN KEY (F_Bills) REFERENCES dbo.FD_Bills (LINK),
) 
CREATE CLUSTERED INDEX IDC_FD_Payment_Details ON dbo.FD_Payment_Details (F_Payments) 
GO


INSERT dbo.SD_Subscrs
SELECT '10005000', 'Николай', 'Озеров', 'г. Чебоксары, ул. Гагарина, д. 10, кв. 15', '5766', '342456', '19820715'

INSERT dbo.SD_Subscrs
SELECT '10005001', 'Сергей', 'Иванов', 'г. Чебоксары, ул. Энгельса, д. 1 кв. 88', '4425', '678942', '19850224'

INSERT dbo.SD_Subscrs
SELECT '10005002', 'Алексей', 'Федоров', 'г. Чебоксары, пр-кт. Ленина, д. 26 кв. 4', '3435', '567823', '19750904'

INSERT dbo.SD_Subscrs
SELECT '10005003', 'Елена', 'Елисеева', 'г. Чебоксары, пр-кт. Ленина, д. 8 кв. 104', '2245', '442567', '20051110'

INSERT dbo.SD_Subscrs
SELECT '10005004', 'Петр', 'Сергеев', 'г. Чебоксары, ул. 324 Стрелковой дивизии, д. 5 кв. 27', '7765', '745832', '20030318'

INSERT dbo.SD_Subscrs
SELECT '10005005', 'Руслан', 'Нигматулин', 'д. Хыркасы, д. 9', '5535', '665447', '19900601'

SELECT * FROM dbo.SD_Subscrs

INSERT dbo.DD_Docs
SELECT '1-д/1', 1, 'Тип #1', '20190101', NULL
INSERT dbo.DD_Docs
SELECT '1-д/2', 2, 'Тип #1', '20190202', NULL
INSERT dbo.DD_Docs
SELECT '1-д/3', 3, 'Тип #1', '20190115', NULL
INSERT dbo.DD_Docs
SELECT '1-д/4', 4, 'Тип #1', '20181225', NULL
INSERT dbo.DD_Docs
SELECT '1-д/5', 5, 'Тип #1', '20181212', NULL
INSERT dbo.DD_Docs
SELECT '2-д/1', 1, 'Тип #6', '20190104', 1
INSERT dbo.DD_Docs
SELECT '3-д/1', 1, 'Тип #0', '20190112', 6
INSERT dbo.DD_Docs
SELECT '4-д/1', 1, 'Тип #4', '20190125', 7
INSERT dbo.DD_Docs
SELECT '5-д/1', 1, 'Тип #9', '20190202', 8
INSERT dbo.DD_Docs
SELECT '2-д/3', 3, 'Тип #6', '20190118', 3
INSERT dbo.DD_Docs
SELECT '3-д/3', 3, 'Тип #0', '20190125', 10
INSERT dbo.DD_Docs
SELECT '6-д/1', 1, 'Тип #3', '20190105', NULL
INSERT dbo.DD_Docs
SELECT '7-д/1', 1, 'Тип #3', '20190106', NULL

SELECT * FROM dbo.DD_Docs
 
INSERT dbo.FD_Bills 
SELECT 'Счг-1/1', 1, 'ГВС', '20181205', 150, 150  
INSERT dbo.FD_Bills 
SELECT 'Счх-1/1', 1, 'ХВС','20181208', 100, 100
INSERT dbo.FD_Bills 
SELECT 'Счэ-1/1', 1, 'Э/Э','20181221', 30, 30
INSERT dbo.FD_Bills 
SELECT 'Счг-1/2', 2, 'ГВС', '20181211', 170, 170
INSERT dbo.FD_Bills 
SELECT 'Счх-1/2', 2, 'ХВС','20181214', 105, 105
INSERT dbo.FD_Bills 
SELECT 'Счэ-1/2', 2, 'Э/Э','20181216', 45, 45

INSERT dbo.FD_Bills 
SELECT 'Счг-2/1', 1, 'ГВС', '20190105', 165, 165
INSERT dbo.FD_Bills 
SELECT 'Счх-2/1', 1, 'ХВС','20190108', 110, 110
INSERT dbo.FD_Bills 
SELECT 'Счэ-2/1', 1, 'Э/Э','20190121', 55, 55
INSERT dbo.FD_Bills 
SELECT 'Счг-2/2', 2, 'ГВС', '20190111', 185, 185
INSERT dbo.FD_Bills 
SELECT 'Счх-2/2', 2, 'ХВС','20190114', 115, 115
INSERT dbo.FD_Bills 
SELECT 'Счэ-2/2', 2, 'Э/Э','20190101', 60, 60

INSERT dbo.FD_Bills 
SELECT 'Счг-3/1', 1, 'ГВС', '20190205', 165, 165
INSERT dbo.FD_Bills 
SELECT 'Счх-3/1', 1, 'ХВС','20190208', 110, 110
INSERT dbo.FD_Bills 
SELECT 'Счэ-3/1', 1, 'Э/Э','20190221', 55, 55
INSERT dbo.FD_Bills 
SELECT 'Счг-3/2', 2, 'ГВС', '20190211', 185, 185
INSERT dbo.FD_Bills 
SELECT 'Счх-3/2', 2, 'ХВС','20190214', 115, 115
INSERT dbo.FD_Bills 
SELECT 'Счэ-3/2', 2, 'Э/Э','20190216', 60, 60

SELECT * FROM dbo.FD_Bills








