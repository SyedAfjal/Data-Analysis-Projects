-- ENROLLMENT TREND ANALYSIS

SELECT Enrollment_Year, COUNT(*) AS Enrollment_Count
FROM PortfolioProject2.customer_loyalty_history
GROUP BY Enrollment_Year
ORDER BY Enrollment_Year;

-- Flight Booking Based On Demographics

SELECT loyaltyHistory.Gender, loyaltyHistory.Education, 
loyaltyHistory.Marital_Status,loyaltyHistory.Country, loyaltyHistory.City,loyaltyHistory.Postal_Code,
flightActivity.Total_Flights
FROM customer_loyalty_history loyaltyHistory
JOIN customer_flight_activity flightActivity
ON loyaltyHistory.Loyalty_Number = flightActivity.Loyalty_Number
GROUP BY  loyaltyHistory.Gender, loyaltyHistory.Education, 
loyaltyHistory.Marital_Status,loyaltyHistory.Country, loyaltyHistory.City,loyaltyHistory.Postal_Code,
flightActivity.Total_Flights
ORDER BY flightActivity.Total_Flights  DESC;

-- CLV EVALUATION

SELECT loyaltyHistory.Loyalty_Number, loyaltyHistory.Loyalty_Card, CLV,
CASE
WHEN CLV > (SELECT AVG(CLV) FROM customer_loyalty_history) THEN 'Above Average'
WHEN CLV < (SELECT AVG(CLV) FROM customer_loyalty_history) THEN 'Below Average'
ELSE 'Equal Average'
END AS CLV_Category
FROM customer_loyalty_history loyaltyHistory
JOIN customer_flight_activity flightActivity
ON loyaltyHistory.Loyalty_Number = flightActivity.Loyalty_Number
ORDER BY CLV DESC;

-- Loyalty Card Analysis

SELECT loyaltyHistory.Loyalty_Card, AVG(flightActivity.Total_Flights) AS AVG_fligts,
AVG(Salary) AS AVG_Salary,  COUNT(loyaltyHistory.Enrollment_Year) AS Enrollment_COUNT, SUM(flightActivity.Points_Accumulated) AS Total_Points_Accumulated, 
SUM(flightActivity.Points_Redeemed) AS total_points_redeemed 
FROM customer_loyalty_history loyaltyHistory
JOIN customer_flight_activity flightActivity
ON loyaltyHistory.Loyalty_Number = flightActivity.Loyalty_Number
GROUP BY Loyalty_Card ;

