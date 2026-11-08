
Assignment 5: Rental Marketplace Findings and Recommendations

To: Rental Marketplace Leadership
From: Trust and Data Team
Subject: Addressing High No-Show Rates and Properties Without Viewing Activity


EXECUTIVE SUMMARY

Our Rental Marketplace analysis identified two different concerns: properties experiencing elevated renter no-show rates and properties without any recorded viewing activity.

The platform recorded 200 viewings, including 12 renter no-shows, representing an overall no-show rate of 6%.

Property_2, Property_3, and Property_4 showed higher no-show rates than the platform average. Meanwhile, Property_14 and Property_15 had no recorded viewings.

These groups require different responses because missed appointments and an absence of appointments are separate operational problems.


FINDING 1: PROPERTIES WITH ELEVATED NO-SHOW RATES

The earlier performance analysis identified the following properties:

Property_2 (property_id 2):
3 no-shows out of 16 viewings, approximately 18.75%.

Property_3 (property_id 3):
2 no-shows out of 13 viewings, approximately 15.38%.

Property_4 (property_id 4):
1 no-show out of 6 viewings, approximately 16.67%.

Each property exceeded the overall platform no-show rate of 6%.

The analysis also established a 4.8% no-show baseline (7 out of 145 viewings) among properties with more than 15 viewings.

These findings suggest that certain properties experience attendance problems more frequently than the platform overall.

However, a higher percentage does not automatically establish poor property management. Property_4, for example, had only six viewings, meaning a single missed appointment substantially affected its percentage.

RECOMMENDATION

Leadership should prioritize Property_2 and Property_3 for further investigation because they recorded multiple no-shows and exceeded the platform average.

Property_4 should also be monitored, but its smaller sample size should be considered before drawing conclusions about its performance.

The marketplace should consider automated appointment reminders, renter confirmations, and easier rescheduling procedures.

Leadership should also examine whether missed appointments are associated with particular scheduling times, communication problems, or other identifiable factors.

After implementing improvements, the team should compare no-show rates over time to determine whether attendance improves.

Property managers should not be penalized solely because their properties have elevated no-show percentages without investigating the underlying circumstances.


FINDING 2: PROPERTIES WITHOUT RECORDED VIEWINGS

The Task 5.2 INNER JOIN returned 13 properties, while the LEFT JOIN returned all 15 properties.

The two excluded properties were:

Property_14 (property_id 14)
Property_15 (property_id 15)

Both properties had zero recorded viewings.

The NOT EXISTS and EXCEPT queries independently returned the same property identifiers, confirming the finding.

Unlike properties experiencing no-shows, these properties had no recorded viewing appointments.

The data establishes the absence of recorded activity but does not explain its cause.

Possible explanations include limited listing visibility, unavailable properties, recently created listings, or insufficient renter interest.

These possibilities require further investigation.

RECOMMENDATION

Leadership should investigate Property_14 and Property_15 to determine why neither has recorded viewing activity.

The team should verify that both listings are active, available, accurately described, and visible to potential renters.

Leadership should also review their rental prices, locations, listing dates, and descriptions.

If the properties are available but attracting limited interest, improving listing information and promotional visibility may encourage additional viewing requests.

The effectiveness of these changes should be measured through new viewing appointments rather than no-show percentages.


WHY THE TWO GROUPS REQUIRE DIFFERENT RESPONSES

Properties experiencing elevated no-show rates already attract scheduled viewings. Their primary problem is that some renters fail to attend appointments.

These properties may benefit from better scheduling, reminders, and renter communication.

Properties without recorded viewings face a different problem. Their immediate priority is understanding why appointments are not being scheduled.

Sending appointment reminders would not help Property_14 or Property_15 because neither has recorded viewing appointments.

Similarly, improving listing visibility would not necessarily resolve attendance problems at properties already attracting renters.

Leadership should therefore maintain separate measures for viewing activity and appointment attendance.


DATA LIMITATIONS

The database establishes that 12 of the 200 recorded viewings resulted in renter no-shows.

It also establishes that Property_2, Property_3, and Property_4 had higher no-show rates than the platform average.

However, the data does not establish why renters missed appointments.

Likewise, the absence of recorded viewings for Property_14 and Property_15 does not establish whether their listings are inactive, unavailable, or unattractive.

Leadership should investigate these circumstances before making operational or compensation decisions.

Percentages should also be interpreted alongside the number of recorded viewings because smaller samples can produce misleading impressions of performance.


FINAL RECOMMENDATION

Leadership should establish two separate improvement efforts.

First, investigate elevated no-show rates at Property_2, Property_3, and Property_4. Prioritize properties with repeated missed appointments, introduce appointment reminders and confirmations, and monitor whether attendance improves.

Second, investigate Property_14 and Property_15 to determine why they have no recorded viewing activity. Verify their listing status, availability, and visibility before deciding whether promotional or listing improvements are necessary.

Future performance reports should include all properties, including those with zero viewings, and distinguish between the number of scheduled appointments and the percentage of missed appointments.

This approach provides leadership with a more accurate picture of marketplace performance and supports fairer decisions based on verified evidence.
