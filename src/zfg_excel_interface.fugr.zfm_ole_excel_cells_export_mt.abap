FUNCTION ZFM_OLE_EXCEL_CELLS_EXPORT_MT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(T_EXCEL_EXP) TYPE  ZTT_EXCEL_EXP
*"--------------------------------------------------------------------
DATA:
    LW_RC             TYPE I,
    LS_EXCEL_LAYOUT   TYPE ZTB_EXCEL_LAYOUT,
    LS_EXCEL          TYPE OLE2_OBJECT,
    LS_ACTIVESHEET    TYPE OLE2_OBJECT,
    LS_RANGE          TYPE OLE2_OBJECT,
    LW_LOCK           TYPE XMARK,
    LW_ROW            TYPE I,
    LS_CELL1          TYPE OLE2_OBJECT,
    LS_CELL2          TYPE OLE2_OBJECT,
    LS_DATA           TYPE REF TO DATA,
    LS_EXCEL_COLDAT   TYPE ZST_EXCEL_COLDAT,
    LT_EXCEL_COLDAT   TYPE TABLE OF ZST_EXCEL_COLDAT,
    LS_EXCEL_EXP      TYPE ZST_EXCEL_EXP,
    LS_CELLDAT        TYPE ZST_EXCEL_NUMBR,
    LS_CELLDAT_OLD    TYPE ZST_EXCEL_NUMBR,
    LT_CELLDAT        TYPE TABLE OF ZST_EXCEL-VALUE,
    LW_LINEDAT        TYPE ZST_EX_COLDAT-VALUE.

* Choose excel application
  IF I_EXCEL IS INITIAL.
    LS_EXCEL = GS_OLE_EXCEL.
  ELSE.
    LS_EXCEL = I_EXCEL.
  ENDIF.

  LOOP AT T_EXCEL_EXP  INTO LS_EXCEL_EXP.
    IF LS_EXCEL_EXP-INSRW IS INITIAL.
      LOOP AT LS_EXCEL_EXP-EXDATN INTO LS_CELLDAT.
*       Select first cell
        CALL METHOD OF LS_EXCEL 'Cells' = LS_CELL1
          EXPORTING
            #1 = LS_CELLDAT-ROW
            #2 = LS_CELLDAT-COLUMN.

        CALL METHOD OF LS_EXCEL 'Range' = LS_RANGE
          EXPORTING
          #1 = LS_CELL1
          #2 = LS_CELL1.

        CALL METHOD OF LS_RANGE 'Select'.
        SET PROPERTY OF LS_RANGE 'VALUE' = LS_CELLDAT-VALUE.
*        SET PROPERTY OF LS_RANGE 'VALUE' = T_EXCEL_DATA.
      ENDLOOP.
    ELSE.

      PERFORM 9999_EXPORT_WHOLE_TABLE
        USING LS_EXCEL_EXP.
    ENDIF.
  ENDLOOP.

*      IF 1 = 1.
*        SORT LS_EXCEL_EXP-EXDATN BY ROW DESCENDING COLUMN DESCENDING.
*        READ TABLE LS_EXCEL_EXP-EXDATN INTO LS_CELLDAT INDEX 1.
**       Select last cell
*        CALL METHOD OF LS_EXCEL 'Cells' = LS_CELL2
*          EXPORTING
*            #1 = LS_CELLDAT-ROW
*            #2 = LS_CELLDAT-COLUMN.
*        SORT LS_EXCEL_EXP-EXDATN BY ROW COLUMN.
*
*        READ TABLE LS_EXCEL_EXP-EXDATN INTO LS_CELLDAT INDEX 1.
**       Select first cell
*        CALL METHOD OF LS_EXCEL 'Cells' = LS_CELL1
*          EXPORTING
*            #1 = LS_CELLDAT-ROW
*            #2 = LS_CELLDAT-COLUMN.
*
*        CALL METHOD OF LS_EXCEL 'Range' = LS_RANGE
*          EXPORTING
*          #1 = LS_CELL1
*          #2 = LS_CELL1.
*
*        CALL METHOD OF LS_RANGE 'Select'.
**        SET PROPERTY OF LS_RANGE 'VALUE' = LS_CELLDAT-VALUE.
*        MOVE-CORRESPONDING LS_EXCEL_EXP-EXDATN TO LT_RANGE_DATA.
*        SET PROPERTY OF LS_RANGE 'VALUE' = LT_RANGE_DATA.
**        CALL METHOD OF LS_RANGE 'SetRangesData2'.
*        EXIT.
*      ENDIF.





ENDFUNCTION.