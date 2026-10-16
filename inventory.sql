-- DBMS Case Study 2: Inventory and Order Processing System
-- Database: MySQL

CREATE DATABASE IF NOT EXISTS InventoryDB;
USE InventoryDB;

CREATE TABLE IF NOT EXISTS Supplier (
    Supplier_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Product (
    Product_ID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    Supplier_ID INT,
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID)
);

CREATE TABLE IF NOT EXISTS Orders (
    Order_ID INT PRIMARY KEY,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Order_Date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

INSERT IGNORE INTO Supplier VALUES
(1, 'ABC Suppliers'),
(2, 'XYZ Traders');

INSERT IGNORE INTO Product VALUES
(101, 'Pen', 10.00, 100, 1),
(102, 'Book', 50.00, 50, 2),
(103, 'Pencil', 5.00, 200, 1);

-- Check that enough stock is available before accepting an order.
DROP TRIGGER IF EXISTS check_stock;
DELIMITER //
CREATE TRIGGER check_stock
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    SELECT Stock INTO available_stock
    FROM Product
    WHERE Product_ID = NEW.Product_ID;

    IF NEW.Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    IF available_stock IS NULL OR available_stock < NEW.Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found or insufficient stock';
    END IF;
END //
DELIMITER ;

-- Reduce stock automatically after an order is placed.
DROP TRIGGER IF EXISTS update_stock;
DELIMITER //
CREATE TRIGGER update_stock
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    UPDATE Product
    SET Stock = Stock - NEW.Quantity
    WHERE Product_ID = NEW.Product_ID;
END //
DELIMITER ;