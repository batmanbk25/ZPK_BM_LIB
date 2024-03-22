FUNCTION-POOL ZFG_BM_POPUP.                 "MESSAGE-ID ..


DATA:
  BEGIN OF GT_SEL_INIT OCCURS 0,
    OPTION  TYPE SE16N_OPTION,
    LOW(1),
    HIGH(1),
  END OF GT_SEL_INIT.

* INCLUDE LZFG_BM_POPUPD...                  " Local class definition
