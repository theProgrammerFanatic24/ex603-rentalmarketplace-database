# Unit 4: From Rows to Insight

## Task 4.1 Write-up

### Who acts on the per-producer breakdown

The **Property Manager** would act on the per-property breakdown (Task 4.1, question 2). It shows them which properties draw the most viewings and how long renters stay, so they can decide which listings need attention.

### What the aggregate hides

**An average conceals its distribution.** Property 6 averages 18 minutes across 21 viewings, but that single number cannot show how many of those viewings were attended, cancelled, or disputed. Every cancelled viewing is recorded as 0 minutes, so the status mix controls the average. A property with long attended visits can look weak simply because it had several cancellations pulling its average down.

**A count conceals who is counted.** Property 6's 21 viewings could be 21 different renters or a handful of renters returning repeatedly. The count looks the same either way, so a high count does not necessarily mean broad interest from many renters.

### What I would need to see next

1. **Per property, the breakdown of viewing status** (attended, cancelled, disputed), to see whether a low average comes from short visits or from cancellations.
2. **Per property, which renters viewed it and how many times each**, to see whether a property's activity comes from many renters or a few repeat viewers (for example, one renter viewing the same property 4 times).

### Notes from the Task 4.1 queries

- The platform minimum duration is 0. This is a data-quality issue: cancelled viewings sit in the same metric as real visits and lower every average they touch.
- The busiest property is not the best performer: property 6 has the most viewings (21) but averages 18 minutes, while properties 8 and 5 average 23.
- My threshold for question 3 was more than 15 viewings, roughly the middle of the 6 to 21 range. Properties below it have too few data points for their averages to be reliable, since one or two cancellations swing them heavily.
- Among properties above the threshold there is a slight upward trend: properties with more viewings tend toward longer average durations. The trend is weak, with exceptions (property 11 averages 12 minutes despite 16 viewings).
- By city and status, attended viewings lead every city on both count and average duration. The one exception is Hanoi, where a single disputed viewing at 38 minutes is a low-volume outlier.

## Task 4.2 Write-up

### Part A: the two questions answered side by side

For each property, the conditional aggregation answers two questions at once:

1. **How many viewings did this property have?**
2. **How many of those viewings were renter no-shows?**

### Part B: who needs subtotals, and what the grand total supports

The **regional director** needs subtotals rather than detail rows. They are responsible for a whole city, not individual properties, so one row per city shows them how their region performs without wading through every listing.

The **grand total** supports a platform-wide decision that the group rows cannot: whether no-shows are a problem across the whole platform or only in certain regions. It gives leadership the single true failure rate (12 of 200 viewings, about 6%) to set policy against, and it is the benchmark each region's subtotal is measured against. For example, Danang's 19% only stands out because the platform rate is 6%.

### Part C: the question the pipeline answers

**What is the normal no-show rate for properties with enough viewings to trust?** The pipeline first summarizes each property, then keeps only the properties with more than 15 viewings and combines their results. The answer, 4.8%, is the baseline that any individual high-volume property can be judged against.

## Reflection

Conditional aggregation answers several questions in a single pass over the data. In Part A, one query read every viewing once and produced both each property's total viewings and its no-show count. The alternative is two separate filtered queries: one counting all viewings per property, and a second with a WHERE clause counting only the no-shows. That reads the table twice, and the two result sets then have to be matched back together by property before they can be compared.

At 200 rows the difference is invisible, since both approaches return instantly. At a million rows it matters. Each separate query is another full scan of a large table, so two queries roughly double the work the database does. Every extra metric adds another scan, and the cost grows with each question asked. The separate results also have to be joined, which is another expensive step, and if the data changes between the two queries the numbers can drift out of sync, so a no-show count no longer lines up with the total it is supposed to be a share of.

Conditional aggregation avoids all of this. One scan computes every metric together, the totals are guaranteed to describe the same rows at the same moment, and adding a new metric means adding another CASE expression, not another trip through the data.
