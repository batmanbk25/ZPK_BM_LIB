FUNCTION-POOL ZFG_DATE.                     "MESSAGE-ID ..

**********************************************************************
* TYPES
**********************************************************************
TYPES:
  BEGIN OF GTY_QUARTER,
    YEAR                      TYPE NUMC4,
    MONTH                     TYPE NUMC2,
    QUART                     TYPE PERSL_KK,
    QUANM                     TYPE PERSLT_KK,
  END OF GTY_QUARTER.

**********************************************************************
* CONSTANTS
**********************************************************************
CONSTANTS:
  GC_FORMAT_DAY               TYPE CHAR2 VALUE 'DD',
  GC_FORMAT_MONTH             TYPE CHAR2 VALUE 'MM',
  GC_FORMAT_YEAR              TYPE CHAR4 VALUE 'YYYY'.

**********************************************************************
* DATA
**********************************************************************
DATA:
  GT_QUARTER                  TYPE TABLE OF GTY_QUARTER,
  GT_TFKPERIOD                TYPE TABLE OF ZST_TFKPERIOD.
