# Analyzing Conversion rate performance for Affiliate E-commerce platform
End-to-end affiliate performance analysis using MySQL and Power BI, covering revenue drivers, funnel behaviour, traffic source efficiency, and pricing strategy across five international markets.

**Included in the repository:**

  ● Word Documentation of the analysis 
  
  ● PowerPoint Presentation of the Insighs and Recommendations
  
  ● SQL Queries
  
  ● Power BI Dashboards 
  
  
  

|**📋 Table of Contents**|
|----|
|Business Problem|
|Executive Summary|
|Tools & Software|
|Data Model — ERD Diagram|
|Dashboard Overview & Key Insights|
|Recommendation|
|Limitations & Assumptions|
|Next Steps|



# **🧩 Business Problem**

Aventra Commerce is a mid-sized e-commerce marketplace that earns revenue through affiliate commissions across product categories including electronics, kitchen appliances, and home goods. Despite attracting meaningful traffic across social media, organic search, and referral platforms, the business was experiencing inconsistent conversion performance and uneven revenue contribution across markets, devices, and traffic sources.
Four core challenges were identified:


| Challenge | Business Risk |
| --- | --- |
| Large share of users stuck in early funnel stages (awareness/interest) without converting | Lost commission revenue | 
| Certain markets show strong engagement but weak revenue contribution | Growth opportunities left untapped | 
| Effectiveness of discount strategies and pricing tiers is unclear | Profitability leakage | 
| Some traffic sources drive high engagement but low ROI | Misallocated marketing spend | 


The analytics team was engaged to answer five key business question areas:

Unclear Revenue Drivers — Which products and categories consistently generate commissions, and are any being promoted inefficiently?
Conversion Funnel Drop-Off — Where are users disengaging, and what factors (discounts, device, user type) influence conversion?
Traffic Source Effectiveness — Which channels attract high-intent users that actually convert?
Device & User Experience Uncertainty — How does device type and geography affect engagement and purchase completion?
Customer Value & Retention — Do new or returning users deliver more long-term commission value?

 

# **📝 Executive Summary**

The analysis examined Aventra Commerce's affiliate performance across markets, traffic sources, user behaviour, and pricing strategies to surface the key levers for revenue growth.

Canada ($297) and the United States ($275) are the dominant revenue-generating markets, while Germany and Australia present high-growth potential — Germany holds the highest Average Order Value ($259) and engagement score (8.7), despite its small user base.

From a channel perspective, Organic Search delivers a 100% conversion rate among traffic sources, indicating strong purchase intent from users who actively seek the platform. Social Media attracts the largest user volume and maintains an 87% conversion rate, making it the single most impactful acquisition channel. Streaming platforms underperform significantly at a 50% conversion rate.
On user behaviour, mobile drives the highest awareness but suffers the largest funnel drop-off — only 13% of mobile users reach the action stage, compared to 27% on tablet and 25% on desktop. This signals a UX friction problem rather than a demand problem.

On pricing, moderate discounts of 10–20% generate the highest total commission ($316), while high discounts ($209) boost conversion volume but erode profitability. 68% of all conversions involved a discounted product.

The clearest opportunity for Aventra Commerce lies in fixing the mobile experience, doubling down on organic and social channels, expanding targeted marketing in Germany and Australia, and applying a disciplined discount strategy.

# **🛠 Tools & Software**

| Tools | Purpose |
| --- | --- | 
| MySQL | Data cleaning, staging tables, exploratory queries, and analytical calculations |
| Power BI | Dashboard development and stakeholder-facing visual reporting |

Dataset: Sourced from Kaggle — comprising four relational tables: user clicks, conversions, product information, and user behaviour.


# **🗂 Data Model — ERD Diagram**

The data model connects four core tables: 
- User clicks, 
- Conversions
- User behaviour
- Products

These tables were joined via user_id, click_id, and a composite key of product_asin + product_title (used due to duplicate ASINs in the source catalog).

<img width="940" height="638" alt="image" src="https://github.com/user-attachments/assets/c9713a6f-cf32-42ec-868e-16488beeb47d" />



# **📊 Dashboard Overview & Key Insights**

Four Power BI dashboards were developed, each tailored to a specific stakeholder audience.

1. Executive Performance Dashboard
Audience: Senior leadership and business executives
Surfaces top-line revenue metrics, the top 10 products by commission, market-level revenue comparisons, and new vs. returning customer Average Order Value trends.

<img width="940" height="529" alt="image" src="https://github.com/user-attachments/assets/93957e60-9b42-40a8-8cc1-b78bcc702294" />

Key Insight

- Canada and the US together account for the majority of affiliate revenue. 
- However, Germany's AOV of $259 — the highest across all markets — signals strong monetisation potential if traffic volume is increased.
- The UK, by contrast, shows the lowest AOV ($193), suggesting price sensitivity that could be addressed through targeted promotions.

2. Funnel Performance & Traffic Efficiency
Audience: Digital marketing team
Visualises the customer journey across funnel stages, traffic source conversion rates, engagement benchmarks, and country-level commission performance.

<img width="940" height="524" alt="image" src="https://github.com/user-attachments/assets/60c68eb7-5621-4a79-ae2c-4b22d2f6f12f" />

Key Insight 

- Organic Search converts at 100% with an average engagement score of 8.6, making it the highest-quality traffic source.
- Social Media is the volume leader with an 87% conversion rate.
- Streaming platforms lag significantly at 50%, suggesting their audience is not purchase-oriented.

3. User Interaction & Engagement
Audience: Marketing and UX/UI teams; secondary audience: IT/web development
Breaks down engagement metrics by device type, time on page, scroll depth, and click-to-conversion ratios by traffic source and device.

<img width="807" height="455" alt="image" src="https://github.com/user-attachments/assets/5cd3df9d-6fe9-4b57-a8f8-641c702322bc" />

Key Insight 
- Time spent on page does not correlate with conversion rate — users who spent the most time on page did not necessarily convert at higher rates.
- Social media and organic search drive the highest click-to-conversion ratios on desktop and mobile,
- Meanwhile video platforms show strong performance on tablet (81% conversion rate), pointing to an underutilised channel for that device segment.

4. Sales & Pricing Optimisation
Audience: Sales team and commercial/pricing decision-makers
Examines top-selling products, discount impact on conversions and commissions, and AOV comparisons across new vs. returning customers.

<img width="940" height="533" alt="image" src="https://github.com/user-attachments/assets/1256bcdd-de39-47c4-a943-16c667580e98" />

Key Insight: 
- Moderate discounts (10–20%) produce the highest total commission at $316, while high discounts generate more conversions (76% rate) but reduce per-sale profitability ($209 in commission).
- The Dyson V8 Cordless Vacuum stands out as both a top-seller and a high-commission product, making it the strongest candidate for continued promotion.
- Furniture has a high AOV (~$1,000) but low sales volume — a pricing incentive could unlock significant commission upside in this category.


**✅ Recommendations**
1. Fix the Mobile Conversion Gap
Mobile drives the highest awareness across all devices but has the lowest action rate (13%). Prioritise improvements to the mobile checkout flow — reduce steps, sharpen call-to-action buttons, and test mobile-optimised landing pages for top-performing products.
2. Protect and Scale High-Performing Channels
Maintain SEO investment to sustain organic search performance. Continue social media spend given its combination of high volume and strong conversion. Both channels represent the core engine of the affiliate business.
3. Improve Audio & Fitness Platform Returns
These channels generate above-average commission per conversion (~$7) but fall below 80% conversion rates. Targeted landing pages and tighter creative alignment to the platform audience could meaningfully improve their efficiency.
4. Deprioritise Streaming Platforms
At a 50% conversion rate, streaming is the weakest performer across all traffic sources. Reallocate that budget toward higher-converting channels or use it to test video platform ads on tablet, where the device-source combination shows an 81% conversion rate.
5. Invest in Germany and Australia
Germany's engagement score (8.7) and AOV ($259) are both market-leading figures — the constraint is simply user volume. Australia similarly punches above its size with an AOV of $252. Targeted paid campaigns in both markets would test whether the high intent signals at scale.
6. Standardise the Discount Strategy
Apply 10–20% discounts as the default promotional approach to optimise commission revenue. Reserve higher discounts for peak periods (e.g., sale events) where conversion volume is the priority over per-unit profitability. Introduce strategic discounting in the Furniture category, which currently generates low volume despite a high AOV.
7. Double Down on Returning Customers
Returning users generate a higher average commission ($5.3) than new users ($4.9). Email and retargeting campaigns targeting past converters — especially with personalised product recommendations — are likely to yield a strong return. Pair these with moderate loyalty incentives to drive repeat behaviour.


# **⚠️ Limitations & Assumptions**

Limitations

| Limitations | Impact |
| --- | --- |
| Single month of data (January only) — no visibility into seasonality or long-term trends | Insights may not reflect typical performance across the year | 
| Non-sequential funnel stages — users can appear to jump from awareness to purchase, bypassing intermediate stages | Drop-off rates between stages cannot be measured with full accuracy | 
| Attribution gaps — approximately 10% of conversions have no associated click ID | Conversion rate calculations and traffic source attribution may be understated |
| Duplicate product ASINs — the same ASIN appears with multiple product titles in the catalog | A composite key (product_asin + product_title) was applied as a workaround, but source-level inconsistencies remain |
| Missing traffic source data — 15% of user behaviour records are not linked to a traffic source | Traffic channel analysis covers a partial view of total user activity |
| No external context — competitor pricing, ad spend, and seasonal campaigns are not captured | The analysis cannot fully explain why certain trends occur |

Assumptions

- Each conversion record represents a completed purchase, and commission values accurately reflect revenue contribution.
- Conversions are correctly linked to their originating click, even where a click may have multiple associated conversions.
- Where multiple records exist for a single user, aggregated values (e.g., average engagement score) are treated as representative of overall behaviour.
- Discount percentages are assumed to directly influence conversion behaviour, with no adjustment for unobserved variables (e.g., brand preference, external demand).
- Behaviour patterns observed across devices and traffic sources are assumed to be representative, given the limited data window.


# **🔭 Next Steps**

These are concrete, near-term actions that follow logically from the analysis findings.

1. Extend the analysis beyond January
The current dataset covers a single month, which makes it impossible to distinguish a genuine trend from a one-off. The first priority is to pull at least three to six months of data and rerun the same queries to validate whether Canada and the US consistently lead, whether the mobile drop-off is structural, and whether the 10–20% discount sweet spot holds across different periods.

2. Investigate and close the attribution gap
Approximately 10% of conversions have no associated click ID. Before drawing firm conclusions about which channels drive conversions, it is worth coordinating with whoever manages the click tracking implementation to understand whether this is a tagging gap, a delayed event fire, or a data pipeline issue. Closing this gap will improve the accuracy of all traffic source metrics.

3. Resolve the product catalog data quality issue
Duplicate ASINs with conflicting product names are currently managed through a composite key workaround. This is functional for analysis but fragile. The longer-term fix is to raise it as a data governance issue — either standardise the product catalog at the source or implement a deduplication layer in the data pipeline before it reaches the analytical layer.

4. Set up a recurring monthly reporting cadence
The four Power BI dashboards are built — the next step is to connect them to a refreshable data source so stakeholders can monitor the same metrics month over month without requiring a new ad hoc analysis each time. Even a simple scheduled refresh would turn this into an ongoing operational tool rather than a one-time report.

5. Run a targeted test in Germany
Germany has the highest AOV and engagement score in the dataset but only 9 users in January. Rather than assuming scale will follow, run a small paid campaign — even a modest budget — to test whether the high-intent signals hold when more users are introduced to the platform. The result will either validate the growth opportunity or reveal that the small sample was not representative.

6. A/B test the mobile checkout flow
The mobile funnel drop-off is the single largest conversion opportunity identified in this analysis. Rather than implementing a broad redesign, test one specific change — such as reducing the number of checkout steps or replacing a text CTA with a button — and measure the impact on mobile action rate before committing to larger UX changes.

7. Review the streaming platform partnership
The 50% conversion rate from streaming is low enough to warrant a conversation about whether the current approach is justified. Before cutting the channel entirely, it is worth reviewing what types of content and placements are being used — the issue may be targeting rather than the channel itself.
