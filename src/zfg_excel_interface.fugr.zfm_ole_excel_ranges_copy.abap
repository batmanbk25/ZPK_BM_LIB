FUNCTION ZFM_OLE_EXCEL_RANGES_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_RANGES) TYPE  ZTT_COPY_RANGES
*"--------------------------------------------------------------------
CHECK I_RANGES IS NOT INITIAL.

DATA: LT_RANGES       TYPE ZTT_COPY_RANGES,
      LS_RANGE        TYPE ZST_COPY_RANGES,
      OLE_CELL_STA    TYPE OLE2_OBJECT,
      OLE_CELL_END    TYPE OLE2_OBJECT,
      OLE_CELL_RAN    TYPE OLE2_OBJECT,
      OLE_ACTIVESHEET TYPE OLE2_OBJECT,
      LW_END_ROW      TYPE INT4,
      LW_END_COL      TYPE INT4,
      LW_STA_ROW      TYPE INT4,
      LW_STA_COL      TYPE INT4,
      LW_RIGHT_TIMES  TYPE INT4,
      LW_TIMES        TYPE INT4,
      LW_UNDER_TIMES  TYPE INT4.

  GET PROPERTY OF GS_OLE_EXCEL 'ACTIVESHEET' = OLE_ACTIVESHEET.
  CALL METHOD OF GS_OLE_EXCEL 'WORKSHEETS' = OLE_ACTIVESHEET
    EXPORTING
      #1 = 1.
  CALL METHOD OF OLE_ACTIVESHEET 'ACTIVATE'.

  LT_RANGES[] = I_RANGES[].

  LOOP AT LT_RANGES INTO LS_RANGE.

" ----- Create selection range parent -----
      LW_STA_ROW = LS_RANGE-ROW.
      LW_STA_COL = LS_RANGE-COL.
      LW_END_ROW = LS_RANGE-ROW + LS_RANGE-ROWS - 1.
      LW_END_COL = LS_RANGE-COL + LS_RANGE-COLS - 1.
    " Start cell
      CALL METHOD OF GS_OLE_EXCEL 'CELLS' = OLE_CELL_STA
        EXPORTING
         #1 = LW_STA_ROW
         #2 = LW_STA_COL.
    " End cell
      CALL METHOD OF GS_OLE_EXCEL 'CELLS' = OLE_CELL_END
        EXPORTING
         #1 = LW_END_ROW
         #2 = LW_END_COL.
    " Create range
      CALL METHOD OF GS_OLE_EXCEL 'RANGE' = OLE_CELL_RAN
        EXPORTING
         #1 = OLE_CELL_STA
         #2 = OLE_CELL_END.
    " Select range
      CALL METHOD OF OLE_CELL_RAN 'SELECT'.
    " Copy range
      CALL METHOD OF OLE_CELL_RAN 'COPY'.

" ----- Copy parent range to right side -----
    LW_RIGHT_TIMES = 0.
    DO LS_RANGE-RIGHT_TIMES TIMES.
      LW_RIGHT_TIMES = LW_RIGHT_TIMES + 1.
      LW_STA_ROW  = LS_RANGE-ROW.
      LW_STA_COL  = LS_RANGE-COL + LS_RANGE-COLS * LW_RIGHT_TIMES .
      LW_END_ROW  = ( LW_STA_ROW + LS_RANGE-ROWS - 1 ) * LW_RIGHT_TIMES.
      LW_END_COL  = ( LW_STA_COL + LS_RANGE-COLS - 1 ) * LW_RIGHT_TIMES.
    " Start cell
      CALL METHOD OF OLE_ACTIVESHEET 'CELLS' = OLE_CELL_STA
        EXPORTING
         #1 = LW_STA_ROW
         #2 = LW_STA_COL.
    " Select Cell
      CALL METHOD OF OLE_CELL_STA 'SELECT'.
    " Paste range
*      CALL METHOD OF OLE_CELL_RAN 'PASTE'.
      CALL METHOD OF OLE_ACTIVESHEET 'PASTE'.
    ENDDO.

" ----- Copy parent range to under side -----
    LW_UNDER_TIMES = 0.
    LW_TIMES       = LS_RANGE-RIGHT_TIMES + 1.
    DO LS_RANGE-UNDER_TIMES TIMES.
      LW_UNDER_TIMES = LW_UNDER_TIMES + 1.
      LW_STA_ROW  = LS_RANGE-ROW + LS_RANGE-ROWS * LW_UNDER_TIMES.
      LW_RIGHT_TIMES = 0.
      DO LW_TIMES TIMES.
        LW_STA_COL  = LS_RANGE-COL + LS_RANGE-COLS * LW_RIGHT_TIMES.
        LW_RIGHT_TIMES = LW_RIGHT_TIMES + 1.
      " Start cell
        CALL METHOD OF OLE_ACTIVESHEET 'CELLS' = OLE_CELL_STA
          EXPORTING
           #1 = LW_STA_ROW
           #2 = LW_STA_COL.
      " Select cell
        CALL METHOD OF OLE_CELL_STA 'SELECT'.
      " Paste range
        CALL METHOD OF OLE_ACTIVESHEET 'PASTE'.
      ENDDO.

    ENDDO.

  ENDLOOP.

  FREE OBJECT: OLE_CELL_STA,
               OLE_CELL_END,
               OLE_CELL_RAN,
               OLE_ACTIVESHEET.





ENDFUNCTION.
