CREATE DATABASE IceCream;
GO

USE IceCream;
GO

CREATE TABLE IceCream (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(255),
    Price DECIMAL(10, 2),
    StockQuantity INT
);
GO

CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderDate DATETIME,
    Quantity INT,
    TotalCost DECIMAL(10, 2)
);
GO

CREATE TABLE OrderHistory (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,
    IceCreamID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(Id),
    FOREIGN KEY (IceCreamID) REFERENCES IceCream(Id)
);
GO
--======================================================
--1.������, ���� ��������� ������� ������ ��������, �� ���������� �� ����� ���� ������� ����������.

CREATE TRIGGER CountUpdate
ON OrderHistory
AFTER INSERT
AS
BEGIN
	UPDATE IceCream 
	SET StockQuantity = StockQuantity - Inserted.Quantity
	FROM IceCream
	JOIN Inserted ON IceCream.Id = Inserted.IceCreamID;
END;
GO

--2.������, ���� �������� �������� ������� ������� ���������� �� ������ �� � ������� "����������".

CREATE TRIGGER TotalCount
ON OrderHistory
AFTER INSERT
AS
BEGIN
	UPDATE Orders
	SET TotalCost = (
		SELECT SUM(OrderHistory.Quantity * IceCream.Price)
		FROM OrderHistory
		JOIN IceCream ON IceCream.Id = OrderHistory.IceCreamID
		WHERE OrderHistory.OrderID = Orders.Id
	)
	FROM Orders
	JOIN Inserted ON Orders.Id = Inserted.OrderID;
END;
GO

--7. ������, ���� ������� ������ ��������� ���� ������� ������ (���������, ����� 6 ������).

CREATE TRIGGER DeleteHistory
ON OrderHistory
AFTER INSERT
AS
BEGIN
    DELETE FROM OrderHistory
    WHERE OrderID IN (
        SELECT Id FROM Orders
        WHERE OrderDate < DATEADD(MONTH, -6, GETDATE())
    );
END;
GO
