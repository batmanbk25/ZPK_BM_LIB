FUNCTION ZFM_EXCEL_GETHEADER_CONFIG_CEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPORT) TYPE  PROGRAMM DEFAULT SY-CPROG
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_HEADER)
*"     REFERENCE(I_HEADER_CONFIG) OPTIONAL
*"     REFERENCE(T_EXCEL_LAYOUT) TYPE  ZTT_EXCEL_LAYOUT OPTIONAL
*"  EXPORTING
*"     REFERENCE(T_EXCEL_EXP) TYPE  ZTT_EXCEL_EXP
*"     REFERENCE(E_PAGESETUP) TYPE  ZST_EXCEL_PAGESETUP
*"--------------------------------------------------------------------
DATA:
      LT_EXCEL_HDR  TYPE TABLE OF ZTB_EXCEL_LAYOUT,
      LS_EXCEL_HDR  TYPE ZTB_EXCEL_LAYOUT,
      LT_EXCEL_ITM  TYPE TABLE OF ZTB_EXCEL_LAYOUT,
      LS_EXCEL_ITM  TYPE ZTB_EXCEL_LAYOUT,
      LS_EXCEL      TYPE ZST_EXCEL,
      LS_EXCEL_EXP  TYPE ZST_EXCEL_EXP,
      LW_GRPEX      TYPE ZTB_EXCEL_HDR-GRPEX,
      LT_FIELDCAT   TYPE TABLE OF LVC_S_FCAT,
      LS_FIELDCAT   TYPE LVC_S_FCAT,
      LW_TABNAME    TYPE TABNAME,
      LS_CELL_CONFIG TYPE ZST_CELLS_FORMAT, " Insert by NgocNV8
      LW_CELL_INITIAL TYPE MARK,
      LW_ROWINS     TYPE I.
  FIELD-SYMBOLS:
    <LF_DATA>       TYPE ANY,
    <LF_CONFIG>     TYPE ANY, " Insert by NgocNV8
    <LFT_ITEMS>     TYPE ANY TABLE,
    <LF_PAGESETUP_F> TYPE ANY.

  LW_TABNAME = I_TABNAME.
  IF LW_TABNAME IS INITIAL.
    DESCRIBE FIELD I_HEADER HELP-ID LW_TABNAME.
  ENDIF.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = LW_TABNAME
      I_INTERNAL_TABNAME = LW_TABNAME
    CHANGING
      CT_FIELDCAT        = LT_FIELDCAT
    EXCEPTIONS
      OTHERS             = 3.

* Get excel layout
  LT_EXCEL_HDR = T_EXCEL_LAYOUT.
  IF LT_EXCEL_HDR IS INITIAL.
    SELECT *
      INTO TABLE LT_EXCEL_HDR
      FROM ZTB_EXCEL_LAYOUT
     WHERE REPORT  = I_REPORT.
  ENDIF.
  LT_EXCEL_ITM = LT_EXCEL_HDR.
  DELETE LT_EXCEL_HDR WHERE IS_ITEM = 'X'.
  DELETE LT_EXCEL_ITM WHERE IS_ITEM <> 'X'.

  SORT LT_EXCEL_HDR BY GRPEX ROW_POS COL_POS.
  LOOP AT LT_EXCEL_HDR INTO LS_EXCEL_HDR.
    IF (   LS_EXCEL_HDR-GRPEX IS INITIAL
        OR LS_EXCEL_HDR-GRPEX <> LW_GRPEX )
    AND LS_EXCEL_EXP IS NOT INITIAL.
      APPEND LS_EXCEL_EXP TO T_EXCEL_EXP.
      CLEAR LS_EXCEL_EXP.
    ENDIF.
    LW_GRPEX = LS_EXCEL_HDR-GRPEX.
    CLEAR: LS_EXCEL.
    CLEAR: LS_CELL_CONFIG. " Insert by NgocNV8
    ASSIGN COMPONENT LS_EXCEL_HDR-FNAME OF STRUCTURE I_HEADER
      TO <LF_DATA>.
* Insert by NgocNV8 - Start
    IF I_HEADER_CONFIG IS NOT INITIAL.
      ASSIGN COMPONENT LS_EXCEL_HDR-FNAME OF STRUCTURE I_HEADER_CONFIG
        TO <LF_CONFIG>.
    ENDIF.
* Insert by NgocNV8 - End
*   Set position
    LS_EXCEL-ROW    = LS_EXCEL_HDR-ROW_POS.
    LS_EXCEL-COLUMN = LS_EXCEL_HDR-COL_POS.
*   Change position if item has insert rows
    LOOP AT LT_EXCEL_ITM INTO LS_EXCEL_ITM.
*     Set row
      IF LS_EXCEL_HDR-ROW_POS > LS_EXCEL_ITM-ROW_POS
      AND LS_EXCEL_ITM-INSERT_ROW = 'X'.
        ASSIGN COMPONENT LS_EXCEL_ITM-FNAME OF STRUCTURE I_HEADER
          TO <LFT_ITEMS>.
        DESCRIBE TABLE <LFT_ITEMS> LINES LW_ROWINS.
        IF LW_ROWINS > LS_EXCEL_ITM-INITROWS.
          LS_EXCEL-ROW = LS_EXCEL-ROW + LW_ROWINS
                       - LS_EXCEL_ITM-INITROWS.
        ENDIF.
      ENDIF.

*     Set column
      IF LS_EXCEL_HDR-COL_POS > LS_EXCEL_ITM-COL_POS
      AND LS_EXCEL_ITM-INSERT_COL = 'X'.
        IF LS_EXCEL_ITM-NCOLS > LS_EXCEL_ITM-INITCOLS.
          LS_EXCEL-COLUMN = LS_EXCEL-COLUMN + LS_EXCEL_ITM-NCOLS
                          - LS_EXCEL_ITM-INITCOLS.
        ENDIF.
      ENDIF.
    ENDLOOP.
    READ TABLE LT_FIELDCAT INTO LS_FIELDCAT
      WITH KEY FIELDNAME = LS_EXCEL_HDR-FNAME.
    IF SY-SUBRC IS INITIAL.
      PERFORM STANDARD_VALUE_LVC USING  LS_FIELDCAT
                                        I_HEADER
                                        <LF_DATA>
                                        ''
                                 CHANGING
                                        LS_EXCEL-VALUE.
      " Insert by NgocNV8 - Start
      " Split config format to cell format
        IF <LF_CONFIG> IS ASSIGNED.
          CALL FUNCTION 'ZFM_EXCEL_SPL_CONFID_TO_FORMAT'
            EXPORTING
              I_CONFIG            = <LF_CONFIG>
            IMPORTING
              E_CELL_FORMAT       = LS_CELL_CONFIG
              E_CELL_INITIAL      = LW_CELL_INITIAL.
        ENDIF.
      " Insert by NgocNV8 - End
    ENDIF.
    CONDENSE: LS_EXCEL-ROW, LS_EXCEL-COLUMN, LS_EXCEL-VALUE.
    " Insert by NgocNV8 - Start
      IF LS_CELL_CONFIG IS NOT INITIAL AND LW_CELL_INITIAL IS INITIAL.
        LS_CELL_CONFIG-TOP = LS_EXCEL-ROW.
        LS_CELL_CONFIG-LEFT = LS_EXCEL-COLUMN.
        LS_CELL_CONFIG-ROWS = LS_CELL_CONFIG-COLUMNS = 1.
      ENDIF.
    " Insert by NgocNV8 - End

    IF LS_EXCEL-VALUE IS NOT INITIAL OR LS_EXCEL-VALUE EQ ' '.
*     Check field name is page setup: Header, footer
      ASSIGN COMPONENT LS_EXCEL_HDR-FNAME OF STRUCTURE E_PAGESETUP
      TO <LF_PAGESETUP_F>.
      IF SY-SUBRC IS INITIAL.
        <LF_PAGESETUP_F> = LS_EXCEL-VALUE.
      ELSE.
        APPEND LS_EXCEL TO LS_EXCEL_EXP-EXDAT.
        IF LS_CELL_CONFIG IS NOT INITIAL.
          APPEND LS_CELL_CONFIG TO LS_EXCEL_EXP-CELLS_FORMAT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
  APPEND LS_EXCEL_EXP TO T_EXCEL_EXP.





ENDFUNCTION.
