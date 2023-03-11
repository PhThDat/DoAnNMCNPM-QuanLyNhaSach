USE SoftwareProject;

-- Create procedures

-- Insert book
CREATE OR ALTER PROCEDURE uspInsertBook (
    @Name NVARCHAR(50),
    @Category NVARCHAR(20),
    @Author NVARCHAR(50),
    @ImportPrice DECIMAL(19, 4)
) AS
BEGIN
    DECLARE @bookId INT;
   	SET @bookId = dbo.ufnGetBookID(@Name);
    IF NOT EXISTS (SELECT ID FROM Book WHERE Name = @Name AND Category = @Category AND Author = @Author)
        INSERT INTO Book (Name, Category, Author, ImportPrice) VALUES
        (@Name, @Category, @Author, @ImportPrice)
END

-- Import book
CREATE OR ALTER PROCEDURE uspImportBook (
    
)