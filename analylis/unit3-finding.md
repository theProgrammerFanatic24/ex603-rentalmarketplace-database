# Unit 3 Finding: The No-Show Rate on the Dashboard Is Wrong

To: Dashboard team
From: Trust and Data team
Re: Renter no-show rate and the frozen agent commissions

The dashboard reported that about half of all property viewings end with the renter not showing up, and agent commissions were frozen based on that number. We checked the underlying data, and it does not support that figure. Out of 200 viewings, only 12 have "Renter no show" recorded as the reason, which is a no-show rate of about 6%, not 50%. Most viewings (156) were attended. Another 10 are marked disputed, but those renters stayed for real visits, some over 30 minutes, which suggests they were present. The remaining viewings with a recorded reason were cancelled for causes that were not the renter's fault, such as the agent being unavailable or the property being withdrawn.

The error came from how the dashboard's query filtered the data. It excluded viewings by comparing the "reason" field against a value, but 166 of the 200 viewings have no reason recorded at all, because nothing went wrong with them. The database cannot compare an empty value, so it quietly dropped all 166 of those viewings without any error or warning. That left the dashboard looking at only a small group of cancelled viewings, and within that group, about half were renter no-shows. In our reproduction, 12 out of the remaining 26 viewings were no-shows, roughly the "about half" the dashboard showed. The number looked reasonable, so nobody questioned it. A second, smaller problem in the query (referring to a calculated field before it existed) was also found and fixed.

We recommend releasing the frozen agent commissions, since the true no-show rate is about 6% and does not justify the freeze. The dashboard query should be replaced with the corrected version, which counts every viewing, including those with no reason recorded. The 10 disputed viewings should be reviewed separately and not counted as no-shows, since the visit records show the renters attended.
