USE SoftwareProject;

-- Support types
CREATE TYPE BookList AS TABLE (
    Name NVARCHAR(50),
    Category NVARCHAR(20),
    Author NVARCHAR(50),
    ImportPrice DECIMAL(19, 4)
)

CREATE TYPE BookAmountList AS TABLE (
    BookName NVARCHAR(50),
    Amount INT
)

-- Create procedures

-- ===== Insert book =====
CREATE OR ALTER PROCEDURE uspInsertBook
    @name NVARCHAR(50),
    @category NVARCHAR(20),
    @author NVARCHAR(50),
    @importPrice DECIMAL(19, 4)
AS BEGIN
    -- If the same book does not exist, insert.
    IF NOT EXISTS (SELECT ID FROM Book WHERE Name = @name AND Category = @category AND Author = @author)
        INSERT INTO Book (Name, Category, Author, ImportPrice) VALUES
        (@name, @category, @author, @importPrice)
END

-- ===== Insert book list =====
CREATE OR ALTER PROCEDURE uspInsertBookList
    @bookList BookList READONLY
AS BEGIN
    DECLARE @name NVARCHAR(50),
            @category NVARCHAR(20),
            @author NVARCHAR(50),
            @price DECIMAL(19, 4);

    -- Using cursor to point at the list.
    DECLARE book_cursor CURSOR FOR
        SELECT Name, Category, Author, ImportPrice
        FROM @bookList;
    
    OPEN book_cursor;
    FETCH NEXT FROM book_cursor
    INTO @name, @category, @author, @price;

    -- Iterate over the how list, then insert every single one if needed.
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC uspInsertBook @name, @category, @author, @price;
        
        FETCH NEXT FROM book_cursor
        INTO @name, @category, @author, @price;
    END

    CLOSE book_cursor;
    DEALLOCATE book_cursor;
END;

-- ===== Insert passed month =====
CREATE OR ALTER PROCEDURE uspInsertPassedMonth
    @newMonth DATE
AS BEGIN
    IF NOT EXISTS (SELECT MonthYear FROM PassedMonth WHERE MonthYear = @newMonth)
    	INSERT INTO PassedMonth (MonthYear) VALUES (@newMonth);
END

-- ===== Insert warehouse =====
CREATE OR ALTER PROCEDURE uspInsertWarehouse
    @bookID INT,
    @importDate DATE,
    @initAmount INT,
    @finalAmount INT
AS BEGIN
    IF NOT EXISTS (SELECT BookID FROM Warehouse WHERE BookID = @bookId AND MonthYear = @importDate)
        INSERT INTO Warehouse (BookID, MonthYear, InitAmount, FinalAmount) VALUES
        (@bookID, @importDate, @initAmount, @finalAmount);
END

-- ===== Import book =====
CREATE OR ALTER PROCEDURE uspImportBook
    @BookName NVARCHAR(50),
    @ImportDate DATE,
    @AddedAmount INT
AS BEGIN
    DECLARE @bookId INT,
            @formattedImportDate DATE;
    SELECT  @bookId = dbo.ufnGetBookID(@BookName),
            @formattedImportDate = DATEFROMPARTS(YEAR(@ImportDate), MONTH(@ImportDate), 1);
           
    EXEC dbo.uspInsertPassedMonth @formattedImportDate;
    -- If this book has previously been imported this month, update the FinalAmount.
    IF EXISTS (
        SELECT BookID, MonthYear 
        FROM Warehouse 
        WHERE BookID = @bookId AND MonthYear = @formattedImportDate
    )
    BEGIN
        UPDATE Warehouse
        SET FinalAmount = FinalAmount + @AddedAmount
        WHERE BookID = @bookID 
            AND MonthYear = @formattedImportDate;
    END
    
    -- If this book hasn't been imported this month, add a record
    ELSE BEGIN
        DECLARE @latestMonth DATE,
                @latestAmount INT;
        
        -- Get the latest month that this book was imported.
        SELECT @latestMonth = MAX(MonthYear)
        FROM Warehouse 
        WHERE BookID = @bookId AND MonthYear < @formattedImportDate;

        -- Get its remaining amount in the stock.
        SELECT @latestAmount = FinalAmount
        FROM Warehouse
        WHERE BookID = @bookId AND MonthYear = @latestMonth;
       
       

        -- If this book hasn't been imported before (first time ever), add a record with InitAmount = FinalAmount
        IF (@latestMonth IS NULL)
        BEGIN       
            EXEC uspInsertWarehouse @bookId, @formattedImportDate, @AddedAmount, @AddedAmount;
        END
        
        -- If this book has been imported before this month, add a new record with its InitValue = its latest FinalValue
        ELSE BEGIN
	        SET @AddedAmount = @latestAmount + @AddedAmount;
            EXEC uspInsertWarehouse @bookId, @formattedImportDate, @latestAmount, @AddedAmount;
        END
    END
END

-- ===== Insert customer =====
CREATE OR ALTER PROCEDURE uspInsertCustomer
    @fullName NVARCHAR(50),
    @address NVARCHAR(100),
    @email VARCHAR(70),
    @phoneNumber CHAR(10)
AS BEGIN
    IF NOT EXISTS (SELECT ID FROM Customer WHERE FullName = @fullName AND Address = @address AND Email = @email AND PhoneNumber = @phoneNumber)
        INSERT INTO Customer (FullName, Address, Email, PhoneNumber) VALUES 
        (@fullName, @address, @email, @phoneNumber);
END

-- ===== Insert bill =====
CREATE OR ALTER PROCEDURE uspInsertBill
    @customerName NVARCHAR(50),
    @paid DECIMAL(19, 4),
    @occuredDate DATE,
    @insertedBillID INT OUTPUT
AS BEGIN
    DECLARE @customerId INT;
    SET @customerId = dbo.ufnGetCustomerID(@customerName);

    INSERT INTO Bill (CustomerID, Paid, OccuredDate) VALUES
    (@customerId, @paid, @occuredDate);

    SELECT @insertedBillID = MAX(ID) FROM Bill;
END

-- ===== Insert bill detail =====
CREATE OR ALTER PROCEDURE uspInsertBillDetail
    @billId INT,
    @bookAmountList BookAmountList READONLY
AS BEGIN

END