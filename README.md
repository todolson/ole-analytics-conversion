# ole-analytics-conversion
Automatically link analytic records

## Background
In OLE, we can deal with analytic records by having one holding attached to multiple bib records,
and we can deal with bound-withs by having one item attached to multiple holdings.
In Horizon, we would assign dummy barcodes for items in the analytic record so they coudl have call numbers and show up in call number browse.
The last few years of Horizon, we used a convention for the dummy barcode, `A` + the real barcode, for analytics.

We wish to leverage this convention to automatically link the analytic records to the real items.

### Caveats

There may be data from the dummy item records that we wish to preserve, so this may become more complicated.

Bound-with item barcodes will look simiar to analytic barcodes, but the linking process is very different and are currently out of scope.
Bound-withs will need to be identified and not processed.
For bound-withs, we used `A` + the real barcode + a letter to indicate the order of binding.
In practice, the trailing letter was usually omitted from the first dummy barcode.


## Basic process

1. Identify candidate analytic dummy barcodes. 

2. Separate bound-with from regular analytic barcodes. One approach: find all candiate dummy barcodes, strip inital "A" and any trailing letter.
Any multiply-ocurring barcodes are bound-withs and need to be pulled to a separate table.

3. Link the analytics to the real holdings and sever the link to the dummies

4. Delete the dummy items (and dummy holdings?)
