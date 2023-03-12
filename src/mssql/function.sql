USE SoftwareProject;

-- Create functions

-- Get book ID by book name
CREATE OR ALTER FUNCTION ufnGetBookID (@BookName NVARCHAR(50))
RETURNS INT
AS BEGIN
    DECLARE @id INT;

    SELECT @id = ID
    FROM Book
    WHERE Name = @BookName;

    RETURN(@id);
END

-- Get customer ID by customer name
CREATE OR ALTER FUNCTION ufnGetCustomerID (@CustomerName NVARCHAR(50))
RETURNS INT
AS BEGIN
    DECLARE @id INT;

    SELECT @id = ID
    FROM Customer
    WHERE Name = @CustomerName;

    RETURN(@id);
END

-- Get bill total price by bill ID
CREATE OR ALTER FUNCTION ufnTotalPrice (@BillID INT)
RETURNS DECIMAL(19, 4)
AS BEGIN
    DECLARE @sum DECIMAL(19, 4);

    SELECT @sum = SUM(bd.Amount * b.ImportPrice)
    FROM (
        SELECT BookID, Amount
        FROM BillDetail
        WHERE BillID = @BillID
    ) AS bd
    INNER JOIN (
        SELECT ID, ImportPrice
        FROM Book
    ) AS b ON bd.BookID = b.ID;

    RETURN @sum / 20 * 21;
END