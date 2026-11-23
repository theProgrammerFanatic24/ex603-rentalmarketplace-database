# Unit 6 Closing Memo: Is the Platform Getting Better or Worse?

**To:** Leadership, Rental Marketplace
**Re:** Viewing failures and platform activity, January–December 2023

## Short answer

The platform did **not** get steadily better or worse over 2023. Activity is volatile month to month, with one clear collapse in **March** and a strong recovery peaking in **September**. Over the full year, the platform reached **87.2%** of a reasonable activity target, and it missed that target in every quarter. The failure problem is real but **episodic**: it shows up as bursts of cancellations, not a steady decline. The true no-show rate (about 6%, Unit 3) remains low; the larger issue is **cancellations**, especially ones that aren't the renter's fault.

## Evidence

**1. Monthly viewing minutes swing sharply** (Task 6.3 Part B, `q6_3.sql`)

| Month | Minutes | Change vs prior month | Days where every viewing was cancelled |
|---|---|---|---|
| Jan | 320.36 | — | 2 |
| Feb | 453.44 | +41.5% | 3 |
| **Mar** | **135.98** | **−70.0%** | **3** |
| Apr | 259.75 | +91.0% | 0 |
| May | 308.09 | +18.6% | 2 |
| Jun | 289.15 | −6.1% | 4 |
| Jul | 301.86 | +4.4% | 1 |
| Aug | 293.62 | −2.7% | 2 |
| **Sep** | **408.63** | **+39.2%** | 2 |
| Oct | 370.65 | −9.3% | 1 |
| Nov | 215.42 | −41.9% | 1 |
| Dec | 271.24 | +25.9% | 0 |

March lost 70% of its viewing minutes. Viewings fell from 21 to 11 and 3 of those 11 were cancelled (27%, the highest rate of the year), so the drop was fewer bookings plus a high failure rate. The cancellation rate improved slightly over the year: 18.8% (19 of 101) in January–June vs 15.2% (15 of 99) in July–December, and April had zero cancellations (Task 6.3 Part B). From March 2 to March 10 the running total stayed flat at 800.81 because every viewing on those days was cancelled (Task 6.2 Part B, `q6_2.sql`).

**2. The trend line confirms it** (Task 6.2 Part B). The 8-day moving average fell to about **7–9 minutes** in mid-to-late March, its lowest point of the year, and climbed to about **40** in late September, its highest.

**3. The platform missed its target every quarter** (Task 6.2 Part B). Against a target of 80 minutes per week (1,040 per quarter), the quarters reached 87.5%, 82.4%, **96.5%** (Q3), and 82.4%. The year ended at 3,628.19 of 4,160 minutes.

**4. Cancellations distort per-property trends** (Task 6.2 Part A). For property 4, four of five row-to-row changes came from a cancellation (duration 0) or a recovery from one, not from real changes in viewing length.

**5. Properties stop receiving viewings for months** (Task 6.2 Part C). Eleven gaps longer than 60 days occurred across 9 of the 13 properties that have viewings (properties 14 and 15 have never been viewed, Unit 5); property 9 went 112 days without a viewing.

**6. Demand is concentrated** (Task 6.1). Viewing counts range from 21 (property 6) to 6 (property 4), and the top five properties account for nearly half of all viewings (96 of 200).

## Recommendations for next quarter

1. **Treat cancellations as the main failure metric, not no-shows.** Split monthly cancellations by `no_show_reason` and track the reasons the platform controls (agent unavailable, property withdrawn) separately from renter-side ones. March shows that a cluster of platform-side cancellations can wipe out a month.
2. **Set an alert on the moving average.** If the 8-day moving average of daily minutes drops below about 15, review that week's cancellations immediately instead of finding out at month end.
3. **Investigate long gaps.** For any property with no viewings for 60+ days, check whether it was unavailable or simply not being shown, and record listing-availability history so the team can tell the two apart.
4. **Keep the corrected dashboard logic.** Continue using the NULL-safe no-show query from Unit 3, and report disputed viewings separately.
5. **Adopt the 80 min/week target** and review progress against it monthly using the running total.

## Limitation

The data covers one year (2023), so a single March collapse cannot be called a seasonal pattern yet. There is also no listing-availability history, so a viewing gap cannot be definitively classified as a real stop versus an unlisted property.
