# Power BI Visualizations Practice

> This practice is based on data after processing in Power Query according to the instructions in [Power Query Practice](Power%20Query%20Practice.md),  
> from the tables defined in `data לתרגול power query.sql` (regions, categories, customers, products, orders, order_details).

**Data model:** Ensure there are relationships between:  
`order_details` → `orders`, `products`; `orders` → `customers`; `customers` → `regions`; `products` → `categories`.

**Useful measure:** Create a measure for order revenue, for example:
```dax
Revenue = SUMX(order_details, order_details[quantity] * order_details[unit_price_at_order] * (1 - order_details[discount_pct] / 100))
```

**What the measure represents:**  
The measure calculates **total revenue** from all order detail rows. Each row in `order_details` has: quantity sold (`quantity`), unit price at order time (`unit_price_at_order`), and discount percent (`discount_pct`). Revenue per row = quantity × price × (1 − discount as decimal). Summing over all rows (according to dashboard filters) gives total revenue.

**How it works:**  
- **SUMX** is a DAX function that iterates **row by row** over the table (here: `order_details`), evaluates the second expression per row, and sums the results.  
- The expression per row: `quantity * unit_price_at_order * (1 - discount_pct / 100)`  
  - `quantity` – number of units.  
  - `unit_price_at_order` – unit price **at order time** (important: not current price from products table).  
  - `(1 - discount_pct / 100)` – applies discount: if `discount_pct = 10` then effective price is 90% of list price.  
- When you add the measure to a visual with dimensions (region, month, category, etc.), Power BI filters `order_details` by relationships and current filters, and SUMX sums only the relevant rows – so you get revenue by the selected region/month/category.

---

## Exercise 1

**Business question:** What are total revenue and number of orders in the organization?

**How to answer:** Two **Cards** – one for revenue and one for order count (Count of order_id from orders or order_details).

**Design improvements:**  
- Number format (currency for revenue, number for orders).  
- Clear title for each card.  
- Background color or light border to distinguish cards.

---

## Exercise 2

**Business question:** How is revenue distributed across regions/countries?

**How to answer:** **Column Chart** or **horizontal Bar Chart** – X-axis: `country_hebrew` or `region_name`, Y-axis: revenue measure.

**Design improvements:**  
- Sort by revenue (descending).  
- Different colors per column (or single hue with emphasis on leader).  
- Data labels on columns.

---

## Exercise 3

**Business question:** What is the revenue trend over time (by month)?

**How to answer:** **Line Chart** – X-axis: month/year (from order date), Y-axis: revenue measure.

**Design improvements:**  
- Date/month data type on time axis.  
- Data points on the line for readability.  
- Title and Y-axis description.

---

## Exercise 4

**Business question:** What is each category’s share of total revenue?

**How to answer:** **Pie Chart** or **Donut** – Legend: category name, Value: revenue. Use **Legend** for category names.

**Design improvements:**  
- Limit to 5–7 main slices (rest in "Other").  
- Percentages on slices.  
- Distinct, clear colors for Legend.

---

## Exercise 5

**Business question:** Compare revenue by category and by region in one view.

**How to answer:** **Clustered Bar Chart** – Axis: categories, Value: revenue, **Legend**: region (`region_name` or `country_hebrew`).

**Design improvements:**  
- Column order (e.g. by total).  
- Clear, readable Legend.  
- Labels on bars if not too dense.

---

## Exercise 6

**Business question:** What are the top 10 products by sales (quantity or revenue)?

**How to answer:** **Horizontal Bar Chart** – Y-axis: `product_name`, X-axis: revenue or sum of quantity. Limit to Top 10 (Filter on visual → Top N).

**Design improvements:**  
- Descending sort.  
- Gradient or single color with emphasis.  
- Value label at end of each bar.

---

## Exercise 7

**Business question:** How are orders distributed by status (Pending, Shipped, Delivered, Cancelled)?

**How to answer:** **Pie or Donut Chart** – Value: order count (Count), Legend: `status_standard`. Use **Legend** for statuses.

**Design improvements:**  
- Consistent colors for status (e.g. red for cancelled, green for delivered).  
- Percentages and data labels.

---

## Exercise 8

**Business question:** Detailed table of products with quantity sold and revenue.

**How to answer:** **Table** or **Matrix** – Columns: product name, category, sum of quantity, revenue measure.

**Design improvements:**  
- Conditional formatting on revenue column (color scale).  
- Currency and number format.  
- Sort by column.

---

## Exercise 9

**Business question:** Revenue trend over time with volume emphasis (area).

**How to answer:** **Area Chart** – X-axis: date/month, Y-axis: revenue.

**Design improvements:**  
- Slight transparency on the area.  
- Continuous time axis.  
- Title and units.

---

## Exercise 10

**Business question:** Compare revenue and order count by month side by side.

**How to answer:** **Line and Clustered Column Chart** – X-axis: month, primary Y: revenue (columns), secondary Y: order count (line). **Legend** to distinguish series.

**Design improvements:**  
- Two Y-axes with clear labels.  
- Different colors for columns and line.  
- Legend in a convenient corner.

---

## Exercise 11

**Business question:** Which region contributes most to revenue, and what is each one’s relative share?

**How to answer:** **Waterfall Chart** – Category: region, Value: revenue. Shows start, contributions, and total.

**Design improvements:**  
- Positive/negative color if there are decreases.  
- Labels on each step.  
- Clear title.

---

## Exercise 12

**Business question:** Sales trend over months by region – multiple lines.

**How to answer:** **Line Chart** – X-axis: month, Y-axis: revenue, **Legend**: `region_name` or `country_hebrew` (one line per region).

**Design improvements:**  
- Distinct colors per line.  
- Readable Legend.  
- Limit number of regions if many (e.g. Top 5).

---

## Exercise 13

**Business question:** Is there a relationship between product unit price and quantity sold?

**How to answer:** **Scatter Chart** – X-axis: unit price (from products or order_details), Y-axis: sum of quantity sold. Each point = product.

**Design improvements:**  
- Bubble size by a third measure (e.g. revenue).  
- Labels for standout products.  
- Reasonable X/Y axis range.

---

## Exercise 14

**Business question:** Snapshot of order flow – pending through shipped to delivered.

**How to answer:** **Funnel Chart** – Stages: values of `status_standard`, Value: order count per stage.

**Design improvements:**  
- Logical stage order (Pending → Shipped → Delivered → Cancelled).  
- Colors by stage.  
- Percent moving between stages (if relevant).

---

## Exercise 15

**Business question:** Matrix – revenue by category and by month (cross-tab).

**How to answer:** **Matrix** – Rows: category, Columns: month from order date, Value: revenue.

**Design improvements:**  
- Conditional formatting (color by value size).  
- Row and column totals.  
- Currency format.

---

## Exercise 16

**Business question:** KPI – Is current month revenue higher than last month?

**How to answer:** **KPI visual** or **Card** with measure + comparison measure. Measure: revenue (e.g. current month), Target/Compare: previous month or average.

**Design improvements:**  
- Visual indicator (arrow/color) for up/down.  
- Currency format.  
- Title and units.

---

## Exercise 17

**Business question:** Customer distribution by region with emphasis on leaders.

**How to answer:** **Treemap** – Area of rectangles: customer count or revenue, **Legend** / Category: region (`country_hebrew`).

**Design improvements:**  
- Colors by region.  
- Labels inside rectangles.  
- Limit to meaningful regions if many.

---

## Exercise 18

**Business question:** Compare profitability (gross profit) across categories.

**How to answer:** **Column Chart** – Axis: category, Value: sum of (unit_price - cost_price) * quantity from orders, or a DAX measure on profit. Optional **Legend** if splitting by region too.

**Design improvements:**  
- Positive color (e.g. green) for profit.  
- Labels on columns.  
- Sort by profit.

---

## Exercise 19

**Business question:** Concise dashboard – cards + one main chart.

**How to answer:** **Page with 2–3 cards** (revenue, orders, average per order) and **one Bar/Column chart** (e.g. Top 5 categories or regions).

**Design improvements:**  
- Tidy layout (cards at top or side).  
- Consistent colors with theme.  
- Clear titles and units.

---

## Exercise 20

**Business question:** Gauge – what percent of monthly sales target was achieved?

**How to answer:** **Gauge Chart** – Value: revenue (or monthly measure), Min 0, Max = target (constant or from measure). Shows achievement percent.

**Design improvements:**  
- Color bands (red/yellow/green).  
- Clear label (percent or amount).  
- Realistic target based on data.

---

# Solutions – Summary

| Exercise | Question | Visualization Type | Legend Used |
|----------|----------|--------------------|-------------|
| 1 | Total revenue and orders | Card (x2) | No |
| 2 | Revenue by region | Column / Bar | No |
| 3 | Revenue trend over time | Line Chart | No |
| 4 | Category share of revenue | Pie / Donut | Yes – category |
| 5 | Revenue by category and region | Clustered Bar | Yes – region |
| 6 | Top 10 products by sales | Horizontal Bar | No |
| 7 | Distribution by order status | Pie / Donut | Yes – status |
| 8 | Detailed product table | Table / Matrix | No |
| 9 | Revenue trend (area) | Area Chart | No |
| 10 | Revenue vs order count by month | Line and Column | Yes – series |
| 11 | Region contribution to revenue | Waterfall | No |
| 12 | Sales trend by region | Line Chart | Yes – region |
| 13 | Price–quantity relationship | Scatter | Optional (product) |
| 14 | Order status stages | Funnel | No |
| 15 | Category × month | Matrix | No |
| 16 | Current vs previous month KPI | KPI / Card | No |
| 17 | Distribution by region | Treemap | Yes – region |
| 18 | Profitability by category | Column | Optional – region |
| 19 | Concise dashboard | Cards + Bar/Column | No |
| 20 | Target achievement percent | Gauge | No |

---

## General Tips

- **Measures:** Define revenue, order count, and average per order as measures once and reuse them in all visuals.
- **Dates:** Create a Date table and relate it to `orders[order_date]` for correct period analysis.
- **Legend:** Use Legend when splitting by a dimension (region, category, status) in the same chart – several exercises use Legend (4, 5, 7, 10, 12, 17, 18).
- **Filtering:** Use the Filter pane or Slicer (e.g. by year/month or region) to make the dashboard interactive.

---

*This practice is based on data after Power Query processing and the Power BI data model.*
