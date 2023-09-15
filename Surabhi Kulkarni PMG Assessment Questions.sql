-- 1. Write a query to get the sum of impressions by day.
SELECT m.date, SUM(impressions) as 'Total Impressions'
FROM marketing_data m
GROUP BY m.date;

-- 2. Write a query to get the top three revenue-generating states in order of best to worst. How much revenue did the third best state generate?
SELECT w.state, SUM(w.revenue) as Revenue
FROM website_revenue w
GROUP BY w.state
ORDER BY SUM(w.revenue) DESC
LIMIT 3;

-- The third best state was OH which generated $37,577 in total revenue


-- 3. Write a query that shows total cost, impressions, clicks, and revenue of each campaign. Make sure to include the campaign name in the output.
WITH group_rev AS (
SELECT campaign_id, SUM(revenue) AS 'Total_Revenue'
FROM website_revenue
GROUP BY campaign_id)

SELECT c.name, m.campaign_id, SUM(m.cost) AS 'Total Cost', SUM(m.impressions) AS 'Total Impressions', SUM(m.clicks) AS 'Total Clicks', g.Total_Revenue 
FROM marketing_data m INNER JOIN group_rev g ON m.campaign_id = g.campaign_id INNER JOIN campaign_info c ON c.id = m.campaign_id
GROUP BY m.campaign_id;


-- 4. Write a query to get the number of conversions of Campaign5 by state. Which state generated the most conversions for this campaign?
SELECT m.geo, SUM(m.conversions) AS 'Total Conversions'
FROM marketing_data m
WHERE m.campaign_id = (SELECT i.id
						FROM campaign_info i 
                        WHERE i.name = 'Campaign5')
GROUP BY m.geo;

-- The state that generated the most conversions for campaign 5 was Georgia with 672 total conversions

-- 5. In your opinion, which campaign was the most efficient, and why?
WITH group_rev AS (
SELECT campaign_id, SUM(revenue) AS 'Total_Revenue'
FROM website_revenue
GROUP BY campaign_id),
group_cost AS (
SELECT campaign_id, SUM(cost) AS 'Total_Cost'
FROM marketing_data
GROUP BY campaign_id),
rev_and_cost AS(
SELECT r.*, c.Total_Cost
FROM group_rev r INNER JOIN group_cost c ON r.campaign_id = c.campaign_id)

SELECT i.name, rc.campaign_id, (rc.Total_Revenue/rc.Total_Cost) AS 'Revenue/Cost Ratio'
FROM rev_and_cost rc INNER JOIN campaign_info i ON rc.campaign_id = i.id
ORDER BY (rc.Total_Revenue/rc.Total_Cost) DESC;

-- Based on the results, Campaign 5 was the most efficient because it had the highest revenue/cost ratio
-- The proportion of additional revenue earned with respect to the costs was much higher than the other campaigns
-- Revenue/Cost Ration for Campaign 5 was $78

-- 6. Write a query that showcases the best day of the week (e.g., Sunday, Monday, Tuesday, etc.) to run ads.
WITH rev AS(
SELECT DAYNAME(r.date) AS 'Day_', SUM(r.revenue) AS 'Total_Revenue'
FROM website_revenue r
GROUP BY DAYNAME(r.date)),
other AS(
SELECT DAYNAME(m.date) AS 'Day_', SUM(m.impressions) AS 'Total Impressions', 
SUM(m.clicks) AS 'Total Clicks', SUM(m.conversions) AS 'Total_Conversions'
FROM marketing_data m
GROUP BY DAYNAME(m.date))

SELECT o.*, r.Total_Revenue
FROM rev r INNER JOIN other o ON r.Day_ = o.Day_
ORDER BY o.Total_Conversions DESC;

-- Friday or Saturday are the best days of the week to run ads because we can see that the total clicks and conversions is high.
-- On those days, the revenue is relatively low compared to Monday, which shows that there is a high activity market with untapped potential. 