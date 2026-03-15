# Power Query Practice in Power BI – Connecting to PostgreSQL

> This practice is based on tables created in the script `postgres_setup_power_query_exercise.sql`.  
> Run the script in PostgreSQL first, then load the tables into Power BI via Power Query and complete the following tasks.

---

## Setup – Connecting to PostgreSQL and Loading Data

1. In Power BI Desktop: **Get Data** → **PostgreSQL database**.
2. Enter **Server** and **Database**, select **Data connectivity mode** (DirectQuery or Import).
3. Select the tables: `regions`, `categories`, `customers`, `products`, `orders`, `order_details`, `raw_sales_log`.
4. Click **Load** (or **Transform Data** if you want to edit before loading).

After loading, each task is performed in the **Power Query Editor** on the relevant tables.

---

# Power Query Tasks (15+)

## Task 1 – Trimming Extra Spaces (Trim)

**Table:** `customers`  
**Goal:** Remove leading and trailing spaces from the `full_name` column.

**Instructions:**  
Create a custom column or use **Transform → Format → Trim** on `full_name`.

**Solution (custom column):**
```powerquery
Text.Trim([full_name])
```

**Explanation:**  
In real data, names and sometimes emails come with extra spaces. Trim prevents search/filter failures (e.g. "John Doe" vs "  John Doe  ") and unifies values that are identical in content.

---

## Task 2 – Case Standardization (Upper/Lower)

**Table:** `customers`  
**Goal:** Create a column `email_lower` where the entire email is in lowercase.

**Solution:**
```powerquery
Text.Lower([email])
```

**Explanation:**  
Emails are case-insensitive, but in data systems comparing "User@Mail.com" to "user@mail.com" can fail. Standardizing to lower (or upper) avoids duplicates and errors in merges and filters.

---

## Task 3 – Filter Rows by Value (Filter)

**Table:** `customers`  
**Goal:** Keep only customers where `status` equals `active`.

**Instructions:**  
Click the filter arrow on the `status` column → check only **active** → OK.

**Explanation:**  
Filtering rows is a basic operation in Power Query. Here we focus on "active" customers for reports and measures, without changing the source data.

---

## Task 4 – Replacing Null Values (Fill / Replace)

**Table:** `customers`  
**Goal:** Replace empty cells in `email` with the string `"Not specified"`.

**Instructions:**  
On the `email` column: **Transform → Replace Values**.  
**Value to Find:** (leave blank or select null depending on version).  
**Replace With:** `Not specified`.

**Alternative (custom column):**
```powerquery
if [email] = null or [email] = "" then "Not specified" else [email]
```

**Explanation:**  
Empty values make reporting harder (blank text in charts, merge issues). Replacing with a default value improves readability and allows clear filter/group for "no email".

---

## Task 5 – Create Date Column – Month and Year

**Table:** `customers`  
**Goal:** Create a column `signup_year_month` in format `"YYYY-MM"` (e.g. `2023-01`) from `signup_date`.

**Solution:**
```powerquery
if [signup_date] = null then null else Date.ToText([signup_date], "yyyy-MM")
```

**Explanation:**  
Grouping by month/year is needed for trend reports (customer signups, sales). The `YYYY-MM` format suits chronological sorting and time axis in Power BI.

---

## Task 6 – Merge Tables (Merge) – Customers and Regions

**Goal:** Combine `customers` with `regions` to get `region_name` (or `country_hebrew`) for each customer row.

**Instructions:**  
1. Select the `customers` table.  
2. **Home → Merge Queries**.  
3. Select the second table: `regions`.  
4. Match columns: `customers[region_code]` = `regions[region_code]`.  
5. Join Kind: **Left Outer**.  
6. Confirm, then **Expand** the merged table column and select the desired columns (e.g. `region_name`, `country_hebrew`).

**Explanation:**  
Merge (Join) combines information from different tables. Left Outer keeps all `customers` rows even when no region is found (e.g. empty `region_code` or not in `regions`). This allows reporting by region without losing customers.

---

## Task 7 – Remove Columns

**Table:** `customers` (or any other table)  
**Goal:** Remove columns not needed for analysis (e.g. `notes` if added from merge, or a temporary column).

**Instructions:**  
Select the columns → right-click → **Remove Columns**, or **Home → Choose Columns** and select only what you need.

**Explanation:**  
Fewer columns = lighter model and faster load. Keep only what is actually used for reports and DAX.

---

## Task 8 – Filter by Number (Filter by condition)

**Table:** `products`  
**Goal:** Keep only products where `unit_price` is greater than 100.

**Instructions:**  
Filter on `unit_price` → **Number Filters** → **Greater Than** → 100.

**Explanation:**  
Filtering by numeric condition (price, quantity, weight) focuses on relevant items (e.g. expensive products, stock above a threshold) and reduces noise in the model.

---

## Task 9 – Calculated Column – Profit per Unit

**Table:** `products`  
**Goal:** Create a column `profit_per_unit` = `unit_price` minus `cost_price`.

**Solution:**
```powerquery
[unit_price] - [cost_price]
```

**Explanation:**  
Calculated columns in Power Query are computed once at load time. Suitable for measures like gross profit, margin percent, exchange rate – useful for DAX and charts too.

---

## Task 10 – Replace Values in Text (Replace / Standardize)

**Table:** `orders`  
**Goal:** Create a column `status_standard` where all `status` values are lowercase to unify "Shipped", "shipped", "SHIPPED".

**Solution:**
```powerquery
Text.Lower(Text.Trim([status]))
```

**Explanation:**  
When the system or users enter statuses in different casing, grouping by status splits into redundant values. Standardizing to lower (or a fixed value like "Shipped") unifies data for correct reports.

---

## Task 11 – Filter Rows with Empty Date

**Table:** `orders`  
**Goal:** Keep only rows where `order_date` is not empty (not null).

**Instructions:**  
Filter on `order_date` → **Remove Empty**.

**Explanation:**  
Orders without a date complicate time analysis. Removing empty rows (or replacing with a default) avoids errors in date calculations and time charts.

---

## Task 12 – Split Text Column (Split Column)

**Table:** `raw_sales_log`  
**Goal:** Split `log_text` into separate columns by the delimiter `|`.

**Instructions:**  
Select `log_text` → **Transform → Split Column → By Delimiter**.  
Delimiter: **Custom** → `|`.  
Choose **At each occurrence** or **At left-most/right-most** as needed. Confirm.

**Explanation:**  
Raw data often comes as a single string with delimiters (CSV, logs). Splitting into columns allows using fields separately (event type, ProductId, Qty, Price) for analysis and merge with other tables.

---

## Task 13 – Extract Value from Text (Extract)

**Table:** `raw_sales_log` (after splitting log by `|`, or on the original column).  
**Goal:** From a field containing a string like `"ProductId=1"`, create a column `product_id` with only the number (1).

**Solution (if there is a column with "ProductId=1"):**
```powerquery
Number.From(Text.Remove([ColumnName], Text.ToList("ProductId=")))
```
Or with **Extract → Text Between Delimiters**: start after `=`, to end of string.

**Explanation:**  
Extracting numbers or strings from a text field allows conversion to the correct type (number, date) and use in merges, filters, and calculations.

---

## Task 14 – Group By – Count Orders per Customer

**Table:** `orders`  
**Goal:** Create a new table (or query) with order count per `customer_id`.

**Instructions:**  
1. **Transform → Group By**.  
2. **Group by:** `customer_id`.  
3. **New column name:** `order_count`.  
4. **Operation:** **Count Rows**.  
5. Confirm.

**Explanation:**  
Group By aggregates data at group level (e.g. by customer, product, month). Counting rows gives "orders per customer" – basis for KPI, customer ranking, and loyalty measures.

---

## Task 15 – Change Data Type

**Various tables**  
**Goal:** Ensure `unit_price` and `cost_price` in `products` are **Decimal**, `order_date` in `orders` is **Date**, and `quantity` in `order_details` is **Whole Number**.

**Instructions:**  
Click the type icon next to the column name → select the desired type (Decimal, Date, Whole Number, etc.).

**Explanation:**  
Correct data types matter for calculations (sums, averages) and time axis (dates). If Power Query detects the wrong type (e.g. text instead of number), change it manually.

---

## Task 16 – Remove Duplicate Rows (Remove Duplicates)

**Table:** `categories`  
**Goal:** Remove duplicate rows (data has category "Electronics" twice).

**Instructions:**  
Select the relevant columns (e.g. `category_name` or all columns) → **Home → Remove Rows → Remove Duplicates**.

**Explanation:**  
Duplicates distort counts and sums. Removing duplicates by key (e.g. category name or id) cleans the model. Note: if only some columns are selected, duplicates are determined by those columns only.

---

## Task 17 – Fill Down – Fill Missing Values from Above

**Table:** Any table with a column that has repeated values then blanks (e.g. after pivot or import).  
**Goal:** Fill empty cells with the value from the row above.

**Instructions:**  
Select the column → **Transform → Fill → Down**.

**Explanation:**  
In Excel files or reports representing hierarchy, the value often appears only in the first row of each group. Fill Down "carries down" the value to all rows in the group – useful for normalizing tables.

---

## Task 18 – Reorder Columns

**Goal:** Change column order so identifier columns (id) are first, then names, then numeric values.

**Instructions:**  
Drag columns in the table header, or use **Choose Columns** and select columns in the desired order.

**Explanation:**  
Column order does not affect calculations but helps navigation in Power Query and data review. A consistent order (ids, dimensions, facts) is recommended.

---

# Summary and Recommendations

| Task | Power Query Technique | Typical Use |
|------|------------------------|-------------|
| 1 | Trim | Clean spaces in text |
| 2 | Text.Lower | Case standardization |
| 3, 8, 11 | Filter Rows | Filter by value or condition |
| 4 | Replace Values / if | Handle null |
| 5 | Date.ToText / custom column | Dates for reports |
| 6 | Merge Queries | Join tables |
| 7 | Remove Columns | Reduce model size |
| 9 | Add Column (Custom) | New calculation |
| 10 | Text.Lower + Trim | Standardization |
| 12 | Split Column | Split text |
| 13 | Extract | Extract from text |
| 14 | Group By | Aggregation and count |
| 15 | Change Type | Correct data types |
| 16 | Remove Duplicates | Clean duplicates |
| 17 | Fill Down | Fill missing values |
| 18 | Reorder | Organize columns |

**Recommendation:**  
Perform tasks on copies of tables (Duplicate) or save step-by-step (e.g. with "Reference" and "Duplicate") to keep intermediate versions. This allows rolling back if needed and building a clear ETL process for loading into Power BI.

---

*This practice is based on the data in `postgres_setup_power_query_exercise.sql`. Minor adjustments may be needed depending on Power BI and PostgreSQL version.*
