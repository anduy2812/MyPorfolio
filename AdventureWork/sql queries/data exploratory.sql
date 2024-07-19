select *
from FactInternetSales

select *
from DimDate

------------------------------------------------------------------------------------
-- DATE TIME

---- Total profit, cost, sales

select
    YEAR(OrderDate) as Year,
    SUM(TotalProductCost) as TotalCost,
    SUM(SalesAmount) as TotalSales,
    SUM(SalesAmount) - SUM(TotalProductCost) as TotalProfit
from FactInternetSales
group by YEAR(OrderDate)
order by YEAR


---- Total profit, sales same period of year comparison

select
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    SUM(SalesAmount) - SUM(TotalProductCost) as TotalProfit,
    LAG(SUM(SalesAmount) - SUM(TotalProductCost),12) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)) PrevTotalProfit_Month
from FactInternetSales
group by YEAR(OrderDate), MONTH(OrderDate)


select
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    SUM(SalesAmount) as TotalSales,
    LAG(SUM(SalesAmount), 12) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)) PrevTotalSales_Month
from FactInternetSales
group by YEAR(OrderDate), MONTH(OrderDate)


---- Total profit % on product cost

select
    *,
    TotalSales - TotalProductCost as TotalProfit,
    FORMAT((TotalSales - TotalProductCost) / TotalProductCost, 'p') as ROI_pct
from (
select
        YEAR(OrderDate) as Year,
        SUM(ProductStandardCost) as TotalProductCost,
        SUM(SalesAmount) as TotalSales
    from FactInternetSales
    group by YEAR(OrderDate)
) as info_tbl
order by [Year]


---- Rolling Sales Amount, Total profit by month in 2021, 2022, 2023

-- 2021
-- Sales Amount

select distinct
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    SUM(SalesAmount) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) as TotalSales,
    SUM(SalesAmount) OVER (order by MONTH(OrderDate)) as RollingSalesAmount
from FactInternetSales
where YEAR(OrderDate) = 2021
-- group by YEAR(OrderDate), MONTH(OrderDate)
order by [Year], [Month]


-- Total profit


select distinct
    [Year],
    [Month],
    SUM(TotalProfit) OVER () as TotalProfit,
    SUM(TotalProfit) OVER (ORDER BY [Year],[Month]) as Rolling_TotalProfit
from (
select distinct
        YEAR(OrderDate) as Year,
        MONTH(OrderDate) as Month,
        SUM(SalesAmount) - SUM(ProductStandardCost) as TotalProfit
    from FactInternetSales
    group by YEAR(OrderDate), MONTH(OrderDate)
) as info_tbl
where [Year] = 2021


-- 2022
-- Sales Amount

select distinct
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    SUM(SalesAmount) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) as TotalSales,
    SUM(SalesAmount) OVER (order by MONTH(OrderDate)) as RollingSalesAmount
from FactInternetSales
where YEAR(OrderDate) = 2022
-- group by YEAR(OrderDate), MONTH(OrderDate)
order by [Year], [Month]


-- Total profit

select distinct
    [Year],
    [Month],
    SUM(TotalProfit) OVER () as TotalProfit,
    SUM(TotalProfit) OVER (ORDER BY [Year],[Month]) as Rolling_TotalProfit
from (
select distinct
        YEAR(OrderDate) as Year,
        MONTH(OrderDate) as Month,
        SUM(SalesAmount) - SUM(ProductStandardCost) as TotalProfit
    from FactInternetSales
    group by YEAR(OrderDate), MONTH(OrderDate)
) as info_tbl
where [Year] = 2022


-- 2023
-- Sales Amount
select distinct
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    SUM(SalesAmount) OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate)) as TotalSales,
    SUM(SalesAmount) OVER (order by MONTH(OrderDate)) as RollingSalesAmount
from FactInternetSales
where YEAR(OrderDate) = 2023
-- group by YEAR(OrderDate), MONTH(OrderDate)
order by [Year], [Month]


-- Total profit

select distinct
    [Year],
    [Month],
    SUM(TotalProfit) OVER () as TotalProfit,
    SUM(TotalProfit) OVER (ORDER BY [Year],[Month]) as Rolling_TotalProfit
from (
select distinct
        YEAR(OrderDate) as Year,
        MONTH(OrderDate) as Month,
        SUM(SalesAmount) - SUM(ProductStandardCost) as TotalProfit
    from FactInternetSales
    group by YEAR(OrderDate), MONTH(OrderDate)
) as info_tbl
where [Year] = 2023


---- Profit margin by year

select
    YEAR(OrderDate) as Year,
    SUM(SalesAmount) - SUM(ProductStandardCost) as TotalProfit,
    SUM(SalesAmount) as TotalSales,
    FORMAT((SUM(SalesAmount) - SUM(ProductStandardCost)) / SUM(SalesAmount), 'p') as ProfitMargin
from FactInternetSales
group by YEAR(OrderDate)
order by [Year]


---- Total order number

select
    YEAR(OrderDate) as Year,
    COUNT(SalesOrderNumber) as TotalOrders
from FactInternetSales
group by YEAR(OrderDate)
order by Year


---- Total orders number comparison by previous month of year

select
    YEAR(OrderDate) as Year,
    MONTH(OrderDate) as Month,
    COUNT(SalesOrderNumber) as TotalOrders,
    LAG(COUNT(SalesOrderNumber),12) OVER (ORDER BY YEAR(OrderDate), MONTH(OrderDate)) PrevTotalOrders_Month
from FactInternetSales
group by YEAR(OrderDate), MONTH(OrderDate)

------------------------------------------------------------------------------------
-- CUSTOMERS, GEOGRAPHY

---- Total customers number by year

select distinct
    *,
    FORMAT (TotalCusNumByYear*1.0 / TotalCusNum, 'p') as  TotalCusPct
from (
select
        YEAR(Date) as Year,
        COUNT(cus.CustomerKey) OVER () as TotalCusNum,
        COUNT(cus.CustomerKey) OVER (PARTITION BY YEAR(OrderDate)) as TotalCusNumByYear
    from FactInternetSales fact
        join DimDate date
        on fact.OrderDateKey = date.DateKey
        join DimCustomer cus
        on fact.CustomerKey = cus.CustomerKey
) as total_tbl
order by [Year]


---- Total customers number comparison by same year period


select
    *,
    LAG(TotalCusNum, 12) OVER (ORDER BY Year,Month) as PrevTotalCusNum_Month
from (
select distinct
        YEAR([Date]) as Year,
        MONTH([Date]) as Month,
        COUNT(cus.CustomerKey) OVER (PARTITION BY YEAR([Date]), MONTH([DATE])) as TotalCusNum
    from FactInternetSales fact
        join DimDate date
        on fact.OrderDateKey = date.DateKey
        join DimCustomer cus
        on cus.CustomerKey = fact.CustomerKey
) as info_tbl


---- Total profit, sales per customers and loyal customer tier classify


select
    *,
    CASE 
        WHEN TotalSales >= 1000 and TotalSales < 1500 THEN 'Silver'
        WHEN TotalSales >= 1500 and TotalSales < 5000 then 'Gold'
        WHEN TotalSales >= 5000 THEN 'Diamond'
        ELSE 'Walk-in'
    END as LoyalCusTier
from (
select
        FullName,
        SUM(SalesAmount) as TotalSales,
        SUM(SalesAmount) - SUM(ProductStandardCost) as TotalProfit
    from FactInternetSales fact
        join DimCustomer cus
        on fact.CustomerKey = cus.CustomerKey
    group by FullName
-- order by TotalSales
) as tier_classify
order by TotalSales


---- Average day interval

WITH
    interval_tbl
    as
    (
        select
            FullName,
            OrderDate,
            LAG(OrderDate) OVER (PARTITION BY cus.CustomerKey ORDER BY OrderDate) as PrevOrder,
            DATEDIFF(DAY,LAG(OrderDate) OVER (PARTITION BY FullName ORDER BY OrderDate),OrderDate) as DayInterval
        from FactInternetSales fact
            join DimCustomer cus
            on fact.CustomerKey = cus.CustomerKey
    )
select distinct
    FullName,
    AVG(DayInterval) as AvgDayInterval
from interval_tbl
group by FullName
order by AvgDayInterval DESC


---- Total customers number by country, city, state


WITH
    TotalCus_tbl
    as
    (
        select distinct
            Country,
            COUNT(CustomerKey) OVER (PARTITION BY Country) as CusNumByCountry,
            COUNT(CustomerKey) OVER () as TotalCusNum
        from DimGeography geo
            join DimCustomer cus
            on geo.GeographyKey = cus.GeographyKey
    )
select
    *,
    FORMAT((CusNumByCountry*1.0 / TotalCusNum),'p') as CusNumPct
from TotalCus_tbl
order by CusNumByCountry


with
    cus_num_by_state
    as
    (
        select distinct
            Country,
            State,
            COUNT(CustomerKey) OVER (PARTITION BY Country) as TotalCus,
            COUNT(CustomerKey) OVER (PARTITION BY State) as CusNumByState
        from DimGeography geo
            join DimCustomer cus
            on geo.GeographyKey = cus.GeographyKey
    )
select
    *,
    FORMAT(CONVERT(decimal,CusNumByState) / TotalCus,'p') as CusNumPct
from cus_num_by_state

;

with
    cus_num_by_city
    as
    (
        select distinct
            Country,
            City,
            COUNT(CustomerKey) OVER (PARTITION BY Country) as TotalCus,
            COUNT(CustomerKey) OVER (PARTITION BY City) as CusNumByCity
        from DimGeography geo
            join DimCustomer cus
            on geo.GeographyKey = cus.GeographyKey
    )
select
    *,
    FORMAT(CONVERT(decimal,CusNumByCity) / TotalCus,'p') as CusNumPct
from cus_num_by_city
;

---- Customer growth rate


with
    totalcus_tbl
    as
    (
        select
            YEAR([OrderDate]) as Year,
            MONTH([OrderDate]) as Month,
            COUNT(CustomerKey) as TotalCus
        from FactInternetSales
        where YEAR(OrderDate) < 2024
        group by YEAR([OrderDate]), MONTH(OrderDate)
        -- order by Year, [Month]
    ),
    cusgrowthrate_tbl
    as
    (
        select
            *,
            LAG(TotalCus) OVER (ORDER BY Year, Month) as TotalCusPrevYear,
            (TotalCus - LAG(TotalCus) OVER (ORDER BY Year, Month))*1.0 / LAG(TotalCus) OVER (ORDER BY Year, Month) as CusGrowthRate
        from totalcus_tbl

    )
select
    Year,
    FORMAT(AVG(CusGrowthRate),'p') as AvgCusGrowthRate
from cusgrowthrate_tbl
group by Year


------------------------------------------------------------------------------------
-- PRODUCT, SUBCATEGORY, CATEGORY

---- CATEGORY

---- Profit, sales, cost


select
    CategoryName,
    SUM(TotalProductCost) as TotalCost,
    SUM(SalesAmount) as TotalSales,
    SUM(SalesAmount) - SUM(TotalProductCost) as TotalProfit
from FactInternetSales fact
    join DimProduct pro
    on fact.ProductKey = pro.ProductKey
    join DimSubCategory subcat
    on pro.ProductSubcategoryKey = subcat.SubCategoryKey
    join DimCategory cate
    on cate.CategoryKey = subcat.CategoryKey
group by CategoryName


---- Quantity
;
with
    total_tbl
    as
    (
        select distinct
            CategoryName,
            COUNT(OrderQuantity) OVER (PARTITION BY CategoryName) as QuantityByCategory,
            COUNT(OrderQuantity) OVER () as TotalQuantity
        from FactInternetSales fact
            join DimProduct pro
            on fact.ProductKey = pro.ProductKey
            join DimSubCategory subcat
            on pro.ProductSubcategoryKey = subcat.SubCategoryKey
            join DimCategory cate
            on cate.CategoryKey = subcat.CategoryKey
    )
        select 
            *,
            FORMAT(CAST(QuantityByCategory as decimal) / TotalQuantity, 'p') as CategoryQuantityPct
        from total_tbl

---- PRODUCT

---- Profit, sales, cost


select
    ModelName,
    SUM(TotalProductCost) as TotalCost,
    SUM(SalesAmount) as TotalSales,
    SUM(SalesAmount) - SUM(TotalProductCost) as TotalProfit
from FactInternetSales fact
    join DimProduct pro
    on fact.ProductKey = pro.ProductKey
group by ModelName

;
---- Quantity

WITH
    quantity_sold
    as
    (
        select distinct
            ModelName,
            CategoryName,
            SUM(OrderQuantity) OVER (PARTITION BY ModelName) as ProductQuantitySold,
            SUM(OrderQuantity) OVER (PARTITION BY CategoryName) as TotalQuantitySoldByCategory
        from FactInternetSales fact
            join DimProduct pro
            on fact.ProductKey = pro.ProductKey
            join DimSubCategory subcat 
            on pro.ProductSubcategoryKey = subcat.SubCategoryKey
            join DimCategory cate 
            on subcat.CategoryKey = cate.CategoryKey
    )
select
    *,
    FORMAT(CAST(ProductQuantitySold as decimal) / TotalQuantitySoldByCategory, 'p') as ProductQuantitySoldPct
from quantity_sold

