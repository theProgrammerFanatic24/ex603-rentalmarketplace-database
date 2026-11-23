# Unit 6: Analytics with Window Functions

Theme: Rental Marketplace. Event table `viewings` (metric `duration_min`), producer `properties`, actor `renters`.

---

## Task 6.1: Compute across a window without collapsing

### Window average vs GROUP BY

The window version (`AVG(duration_min) OVER (PARTITION BY property_id)`) returns **200 rows**: one per viewing, each showing its property's average next to it. The `GROUP BY property_id` version returns **13 rows**: one per property. The averages are identical, but `GROUP BY` loses every individual viewing (`viewing_id` and its `duration_min`).

**A question that needs each row next to its group's average:**
*Which viewings ran unusually long or short compared with other viewings of the same property?*

`GROUP BY` cannot answer this because it returns only the average, not the viewings being compared to it. Example: viewing 43 lasted 70.86 minutes, while property 4's average is 19.49. That comparison is only visible when the viewing and the average sit on the same row.

### Ranking is never neutral

Ranking by number of viewings produced three ties: properties 5 and 7 (18 viewings), 2 and 11 (16), and 13 and 1 (11).

| Function | Properties 5 and 7 | Next property (12) |
|---|---|---|
| ROW_NUMBER | 4, 5 | 6 |
| RANK | 4, 4 | 6 |
| DENSE_RANK | 4, 4 | 5 |

**Feature:** a renter-facing dashboard listing the most-viewed properties, so renters can spot popular listings quickly.

**Function: `DENSE_RANK`.** Properties 5 and 7 performed the same, so they should share #4. `ROW_NUMBER` would arbitrarily push one landlord's listing down, which is unfair. `DENSE_RANK` leaves no gaps, so the next property shows as #5 and a renter scrolling the list never wonders where a number went.

### NTILE(4)

`NTILE(4)` split the 13 properties into bands of 4, 3, 3, 3 (the leftover property goes to band 1). It lines properties up by viewing count but then cuts purely by position, ignoring ties. As a result, tied properties land on both sides of a boundary: properties 5 and 7 (both 18) fall into bands 1 and 2, and properties 2 and 11 (both 16) fall into bands 2 and 3. NTILE is accurate for "roughly even quarters," but misleading if a band is read as a verdict on a property's performance.

---

## Task 6.2: Compare each row to its neighbors

### What a large delta means

For property 4, the deltas swing from −48.09 to +70.86. Most of that swing comes from cancellations: cancelled viewings record `duration_min = 0`, so a cancellation followed by a real viewing produces a large jump that reflects a **status change**, not a change in how long renters spend at the property. The one delta that reflects real viewing length is 70.86 → 22.77, and 70.86 is the longest viewing on the platform.

A large delta tells the team that something changed sharply between two consecutive viewings. They should check `viewing_status` for those two rows first: if one is cancelled, investigate why the viewing failed (agent availability, renter no-show); if both were attended, investigate what made one viewing so different (a serious renter, a problem at the property, or a data-entry error).

### Why a running total answers what a plain SUM cannot

A plain `SUM(duration_min)` returns one number: 3,628.19 minutes for 2023. The running total shows how the platform reached that number day by day. It reveals when growth stalled (it stays flat at 800.81 from March 2 to March 10, when every viewing was cancelled) and lets leadership measure progress against a target at any point in the year, not only at the end.

**Target:** 80 minutes per week, which gives 1,040 minutes per quarter (13 weeks) and 4,160 per year. The 2023 average was about 70 minutes per week.

| Quarter | Running total at quarter end | Minutes in quarter | % of 1,040 |
|---|---|---|---|
| Q1 | 909.78 | 909.78 | 87.5% |
| Q2 | 1,766.77 | 856.99 | 82.4% |
| Q3 | 2,770.88 | 1,004.11 | 96.5% |
| Q4 | 3,628.19 | 857.31 | 82.4% |
| Year | 3,628.19 | | 87.2% of 4,160 |

### Why an 8-row moving-average window

The moving average uses `ROWS BETWEEN 7 PRECEDING AND CURRENT ROW`, which covers 8 viewing-days. Viewings occur roughly every two to three days, so 8 viewing-days cover about two to three weeks of calendar time: long enough to smooth single-day spikes (a day of 0 next to a day of 83.6), short enough to still show real shifts such as the mid-March slump (≈7) and the late-September peak (≈40). A 3-row window would mostly repeat daily noise; a 30-row window would flatten the March slump almost completely and hide it.

Because `ROWS` counts rows, not days, and days without viewings are skipped, the window covers more than 8 calendar days.

**ROWS vs RANGE:** `ROWS` counts physical rows, so when two rows share the same `ORDER BY` value, the running total adds them one at a time and each tied row gets a different total. `RANGE` treats all rows with the same `ORDER BY` value as one block, so every tied row gets the same total, including all of them. In this query each `viewing_day` is unique, so both give the same result here.

### What a gap means

The gap query computes, per property, the time between each viewing and the previous one (`scheduled_at - LAG(scheduled_at)`) in a CTE, then keeps only gaps longer than 60 days in the outer query.

With a 60-day threshold, 11 gaps across 9 properties were found. The largest: **property 9 went 112 days** (about 3.7 months) without a viewing, from early January 2023 until viewing 131 on 2023-04-28, then started again. Property 12 (106 days, until 2023-06-17) and property 5 (93 days, until 2023-05-05) show the same stop-and-restart pattern.

**Which kind of gap this is:** most likely a **real stop in activity**, not data loss. Every viewing row is complete (it has a property, a timestamp, and a status), the stop and restart belong to the same property ID, and cancelled viewings are still recorded during quiet periods, so the system clearly kept logging events. A data-quality gap would show up as missing days across *all* properties at once, which the daily series does not show. The most likely cause is the property being unavailable (already rented, or withdrawn) and then re-listed. Confirming this would need listing-history data (when `is_available` changed), which the dataset does not keep.

---

## Task 6.3: Build the reporting patterns

### Top-N feature

**Feature:** a "Top viewings" panel on each landlord's property page, showing the three longest viewings for that property.

**Why three:** one result is a single data point and could be an outlier (like the 70.86-minute viewing). Ten would include ordinary and cancelled viewings for low-volume properties; property 4 has only six viewings in total. Three is enough to show a pattern of serious interest while staying meaningful for every property, including the smallest. The query returned 39 rows, exactly three per property; no property had a tie at third place, so `RANK()` kept every list at three.

### What a large month-over-month change means

In 2023, total viewing minutes fell about 70% from February (453.44) to March (135.98), then rose about 91% in April (259.75). Viewings dropped from 21 in February to 11 in March, and 3 of those 11 were cancelled (27%, the highest rate of the year). The cancellation rate then improved: 18.8% in January–June vs 15.2% in July–December, with zero cancellations in April. The missing-month check returned "ok" for every month, so each comparison is against the correct previous month. A large month-over-month drop in a rental marketplace means renters are spending far less time viewing properties, usually because viewings are failing (cancellations, no-shows) or because inventory dropped. The team should break that month down by `viewing_status` and `no_show_reason` to see whether the drop is caused by failures they can fix (agent availability) or by demand. A large rise should be checked the same way before being celebrated, since one unusually long viewing can inflate a month.

---

## Reflection

In a rental marketplace, a natural reporting question is: *"For each property, was this viewing better or worse than the one before it, and how does it compare to the property's normal viewing?"* With window functions this is one query. `LAG(duration_min) OVER (PARTITION BY property_id ORDER BY scheduled_at)` puts the previous viewing on the same row, and `AVG(duration_min) OVER (PARTITION BY property_id)` puts the property's average next to it, while every individual viewing stays visible.

With `GROUP BY` alone, this is awkward or impossible. `GROUP BY property_id` collapses each property's viewings into one row, so the individual viewings you want to compare disappear. To get the previous viewing without a window function, you would have to join the table to itself on property and find "the latest earlier timestamp" with a correlated subquery for every row. That is slow, hard to read, and easy to get wrong when two viewings share a timestamp. To get the property average, you would need a second grouped query joined back to the detail rows.

The difference is that aggregates answer "what is the total or average for the group," while window functions answer "how does this row relate to its group and its neighbors." Leadership's question, whether the platform is getting better or worse, is a question about change over time, and change can only be measured when the rows being compared are kept rather than collapsed.
