--*************************************************************************--
-- Title: Assignment06
-- Author: SoojoungJang
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-05-21,SoojoungJang,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SoojoungJang')
	 Begin 
	  Alter Database [Assignment06DB_SoojoungJang] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SoojoungJang;
	 End
	Create Database Assignment06DB_SoojoungJang;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SoojoungJang;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go
select * from employees;

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vw_Categories
With SchemaBinding
As Select CategoryID, CategoryName
From dbo.Categories; 
go
Create View vw_Products 
With SchemaBinding
As Select ProductID, ProductName, CategoryID, UnitPrice
From dbo.Products; 
go
Create View vw_Employees
With SchemaBinding
As Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees; 
go 
Create View vw_Inventories
With SchemaBinding
As Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
From dbo.Inventories; 
go
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On Categories To Public
Grant Select On vw_Categories To Public
Go
Deny Select On Products To Public
Grant Select On vw_Products To Public
Go
Deny Select On Employees To Public
Grant Select On vw_Employees To Public
Go 
Deny Select On Inventories To Public
Grant Select On vw_Inventories To Public
Go
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

Create View vw_CategorynameandProductname
With SchemaBinding
As 
Select Top 10000
CategoryName, ProductName, UnitPrice
From dbo.Categories As C
Join dbo.Products As P 
On C.CategoryID = P.CategoryID
ORDER BY CategoryName,ProductName;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


Create View vw_ProdcutNameandInventoryCounts
With SchemaBinding
As 
Select Top 10000
ProductName, InventoryDate, Count 
From dbo.Products as P 
Join dbo.Inventories As I 
On P.ProductID = I.ProductID
ORDER BY ProductName, InventoryDate, Count;
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create View vw_InventoryDateByEmployeeName
With Schemabinding
As Select Top 10000
I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName As 'Employee Name'
From dbo.Inventories As I
Inner Join dbo.Employees As E
On I.EmployeeID = E.EmployeeID
GROUP BY InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName
Order By InventoryDate;
GO
Select * from vw_InventoryDateByEmployeeName;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

Create View vInventoriesandProductsandCategories
WITH SCHEMABINDING
AS
SELECT TOP 10000
CategoryName, ProductName, InventoryDate, Count 
From dbo.Categories as C
JOIN dbo.Products as P
On C.CategoryID = P.CategoryID
JOIN dbo.Inventories as I
On P.ProductID = I.ProductID
Order By CategoryName, ProductName, InventoryDate, Count;
Go
Select * From vInventoriesandProductsandCategories;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C?e de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran?Fant?tica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan
Create View vw_InventoriesNameandProductsNameandEmployees
WITH SCHEMABINDING
AS
SELECT TOP 10000
CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
FROM dbo.Categories as C
JOIN dbo.Products as P
On C.CategoryID = P.CategoryID
JOIN dbo.Inventories as I
On P.ProductID = I.ProductID
JOIN dbo.Employees as E
On I.EmployeeID = E.EmployeeID
Order by InventoryDate, CategoryName, ProductName, EmployeeName;
Go
Select * From vw_InventoriesNameandProductsNameandEmployees;
Go
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

Create View vw_InventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING
AS
SELECT TOP 10000
CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
From dbo.Categories as C
JOIN dbo.Products as P
On C.CategoryID = P.CategoryID
JOIN dbo.Inventories as I
On P.ProductID = I.ProductID
JOIN dbo.Employees as E
On I.EmployeeID = E.EmployeeID
Where ProductName in ('Chai', 'Chang');
Go
Select * From vw_InventoriesForChaiAndChangByEmployees;
Go
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

Create View vw_EmployeesandManager
WITH SCHEMABINDING
AS
SELECT TOP 10000
M.EmployeeFirstName + ' ' + M.EmployeeLastName as ManagerName
,E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName
From dbo.Employees as E
Inner Join dbo.Employees as M
On E.ManagerID = M.EmployeeID
Order By 1,2;
Go
Select * From vw_EmployeesandManager;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran?Fant?tica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran?Fant?tica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran?Fant?tica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

CREATE VIEW vw_InventoriesandProductsandCategoriesandEmployees
AS
	SELECT Top 10000000
		C.CategoryID,
		C.CategoryName,
		P.ProductID,
		P.ProductName,
		P.UnitPrice,
		I.InventoryID,
		I.InventoryDate,
		I.[Count],
		E.EmployeeID,
		E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee,
		Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName as Manager

	FROM
		vw_Categories as C
		INNER JOIN vw_Products as P
		ON C.CategoryID = P.CategoryID
		INNER JOIN vw_Inventories as I
		ON P.ProductID = I.ProductID
		INNER JOIN vw_Employees as E
		ON I.EmployeeID = E.EmployeeID
		INNER JOIN vw_Employees as Mgr
		ON E.ManagerID = Mgr.EmployeeID
	ORDER BY CategoryName, ProductID, ProductName, InventoryID, Employee;  
go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vw_Categories]
Select * From [dbo].[vw_Products]
Select * From [dbo].[vw_Inventories]
Select * From [dbo].[vw_Employees]

Select * From [dbo].[vw_CategorynameandProductname]
Select * From [dbo].[vw_ProdcutNameandInventoryCounts]
Select * From [dbo].[vw_InventoryDateByEmployeeName]
Select * From [dbo].[vInventoriesandProductsandCategories]
Select * From [dbo].[vw_InventoriesNameandProductsNameandEmployees]
Select * From [dbo].[vw_InventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vw_EmployeesandManager]
Select * From [dbo].[vw_InventoriesandProductsandCategoriesandEmployees]

/***************************************************************************************/