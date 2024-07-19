use AdventureWorksDW2022

create database AdventureWork_internet_sales

select * from DimDate

select
	DateKey,
	FullDateAlternateKey as Date,
	EnglishDayNameOfWeek as Day,
	WeekNumberOfYear as WeekNum,
	EnglishMonthName as Month,
	MonthNumberOfYear as MonthNum,
	CalendarQuarter as Quarter,
	CalendarYear as Year
from DimDate

select * from DimCustomer
where CustomerAlternateKey = 'AW00029476'


select distinct
	cus.CustomerKey,
	GeographyKey,
	FirstName,
	MiddleName,
	LastName,
	-- IIF (MiddleName is null, FirstName + ' ' + LastName, FirstName + ' ' + MiddleName + ' ' + LastName) as FullName,
	BirthDate,
	DateFirstPurchase = MIN (FullDateAlternateKey) OVER (PARTITION BY cus.CustomerKey),
	Gender
from DimCustomer cus
join FactInternetSales fact_internet
on cus.CustomerKey = fact_internet.CustomerKey
join DimDate date
on date.DateKey = fact_internet.OrderDateKey


select
	GeographyKey,
	City,
	StateProvinceName,
	EnglishCountryRegionName
from DimGeography


select 
	ProductCategoryKey,
	EnglishProductCategoryName
from DimProductCategory


select * from DimProductSubcategory

select
	ProductSubcategoryKey,
	EnglishProductSubcategoryName,
	ProductCategoryKey
from DimProductSubcategory

select * from DimProduct

select 
	ProductKey,
	ModelName,
	EnglishProductName as ProductDetail,
	ProductSubcategoryKey
from DimProduct


select 
	DiscountAmount 
from FactInternetSales
where DiscountAmount != 0


select * from FactInternetSales


select distinct
	SalesOrderNumber 
from FactInternetSales

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
from FactInternetSales