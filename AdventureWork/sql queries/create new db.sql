-------------------------------------------------------------------------

-- CREATE NEW DATABASE AND TABLE


create database AdventureWork_internet_sales

use AdventureWork_internet_sales

create table DimDate (
	DateKey int primary key,
	Date date,
	[Day] nvarchar(50),
	WeekNum smallint,
	[Month] nvarchar (50),
	MonthNum smallint check (MonthNum <= 12),
	[Quarter] smallint,
	[Year] smallint
)

create table DimCustomer (
	CustomerKey int primary key,
	GeographyKey int,
	FirstName nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	Gender nvarchar(20),
	BirthDate date, 
	DateFirstPurchase date
)

create table DimGeography (
	GeographyKey int primary key,
	City nvarchar(100),
	[State] nvarchar(100),
	Country nvarchar(100)
)

create table DimCategory (
	CategoryKey int primary key,
	CategoryName nvarchar(50)
)

create table DimSubCategory (
	SubCategoryKey int primary key,
	SubCategoryName nvarchar(50),
	CategoryKey int
)

create table DimProduct (
	ProductKey int primary key,
	ModelName nvarchar(50),
	ProductDetail nvarchar(100),
	ProductSubcategoryKey int
)

create table FactInternetSales (
	SalesKey int IDENTITY (1,1) primary key,
	ProductKey int,
	CustomerKey int,
	OrderDateKey int,
	ShipDateKey int,
	OrderDate date,
	ShipDate date,
	SalesOrderNumber nvarchar(50),
	OrderQuantity smallint,
	UnitPrice money,
	ProductStandardCost money,
	TotalProductCost money,
	SalesAmount money,
	Freight money
)

-------------------------------------------------------------------------
-- ADD FOREIGN KEY CONSTRAINT

alter table DimSubCategory
add foreign key (CategoryKey) references DimCategory (CategoryKey)


alter table DimProduct
add foreign key (ProductSubCategoryKey) references DimSubCategory (SubCategoryKey)


alter table DimCustomer
add foreign key (GeographyKey) references DimGeography (GeographyKey)


alter table FactInternetSales
add foreign key (OrderDateKey) references DimDate (DateKey)


alter table FactInternetSales
add foreign key (ShipDateKey) references DimDate (DateKey)


alter table FactInternetSales
add foreign key (ProductKey) references DimProduct (ProductKey)


alter table FactInternetSales
add foreign key (CustomerKey) references DimCustomer (CustomerKey)


-------------------------------------------------------------------------
-- IMPORT (INSERT) DATA

-- DIMDATE

insert into DimDate
select
	DateKey,
	FullDateAlternateKey,
	EnglishDayNameOfWeek,
	WeekNumberOfYear,
	EnglishMonthName,
	MonthNumberOfYear,
	CalendarQuarter,
	CalendarYear
from AdventureWorksDW2022..DimDate


-- DIMCATEGORY


insert into DimCategory
select 
	ProductCategoryKey,
	EnglishProductCategoryName
from AdventureWorksDW2022..DimProductCategory


-- DIMSUBCATEGORY


insert into DimSubCategory
select
	ProductSubcategoryKey,
	EnglishProductSubcategoryName,
	ProductCategoryKey
from AdventureWorksDW2022..DimProductSubcategory


-- DIMPRODUCT


insert into DimProduct
select 
	ProductKey,
	ModelName,
	EnglishProductName as ProductDetail,
	ProductSubcategoryKey
from AdventureWorksDW2022..DimProduct


-- DIMGEOGRAPHY


insert into DimGeography
select
	GeographyKey,
	City,
	StateProvinceName,
	EnglishCountryRegionName
from AdventureWorksDW2022..DimGeography


-- DIMCUSTOMER
select * from DimCustomer

insert into DimCustomer
select distinct
	cus.CustomerKey,
	GeographyKey,
	FirstName,
	MiddleName,
	LastName,
	Gender,
	-- IIF (MiddleName is null, FirstName + ' ' + LastName, FirstName + ' ' + MiddleName + ' ' + LastName) as FullName,
	BirthDate,
	DateFirstPurchase = CONVERT(date,MIN (FullDateAlternateKey) OVER (PARTITION BY cus.CustomerKey))
from AdventureWorksDW2022..DimCustomer cus
join AdventureWorksDW2022..FactInternetSales fact_internet
on cus.CustomerKey = fact_internet.CustomerKey
join AdventureWorksDW2022..DimDate date
on date.DateKey = fact_internet.OrderDateKey


-- FactInternetSales
select * from FactInternetSales

insert into FactInternetSales (
	ProductKey,
	CustomerKey,
	OrderDateKey,
	ShipDateKey,
	OrderDate,
	ShipDate,
	SalesOrderNumber,
	OrderQuantity,
	UnitPrice,
	ProductStandardCost,
	TotalProductCost,
	SalesAmount,
	Freight
)
select 
	ProductKey,
	CustomerKey,
	OrderDateKey,
	ShipDateKey,
	OrderDate,
	ShipDate,
	SalesOrderNumber,
	OrderQuantity,
	UnitPrice,
	ProductStandardCost,
	TotalProductCost,
	SalesAmount,
	Freight
from AdventureWorksDW2022..FactInternetSales