FUNCTION ZFM_EXCEL_TABLE_CONV_CONFI_CEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_START_ROW) TYPE  I DEFAULT 1
*"     REFERENCE(I_START_COL) TYPE  I DEFAULT 1
*"     REFERENCE(I_GET_BOLD) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_TRANSPOSE) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_USE_COLPOS) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_KEEP_VALUE) TYPE  XMARK OPTIONAL
*"  TABLES
*"      T_OUTTAB
*"      T_CONFIG OPTIONAL
*"      T_FIELDCAT TYPE  LVC_T_FCAT OPTIONAL
*"      T_EXCEL TYPE  ZTT_EXCEL
*"      T_CELLS_FORMAT TYPE  ZTT_CELLS_FORMAT OPTIONAL
*"      T_BOLD_ROWS TYPE  ZTT_BOLD_ROW OPTIONAL
*"--------------------------------------------------------------------
TYPES: BEGIN OF ZSOI_GENERIC_ITEM,
         ROW(8) TYPE C,
         COLUMN(4) TYPE C,
         VALUE(256) TYPE C,
       END OF ZSOI_GENERIC_ITEM.
DATA:
      LS_FIELDCAT     TYPE LVC_S_FCAT,
      LT_FIELDCAT     TYPE LVC_T_FCAT,
*      LS_EXCEL_DATA   TYPE ZSOI_GENERIC_ITEM,
      LS_EXCEL_DATA   TYPE ZST_EXCEL,
      LW_ROW          TYPE I,
      LW_COL          TYPE I,
      LW_FIELDPOS     TYPE I,
      LW_GET_BOLD     TYPE XMARK VALUE SPACE,
      LS_BOLD_FORMAT  TYPE I,
      LT_RETURN       TYPE TABLE OF BAPIRET2,
      LS_CELL_CONFIG  TYPE ZST_CELLS_FORMAT,
      LW_CELL_INITIAL TYPE MARK. " Insert by NgocNV8.
  FIELD-SYMBOLS:
    <LF_DATA>       TYPE ANY,
    <LF_DATA_CONFIG> TYPE ANY, " Insert by NgocNV8
    <LF_VALUE>      TYPE ANY,
    <LF_VALUE_CONFIG> TYPE ANY," Insert by NgocNV8
    <LF_CURKY>      TYPE ANY,
    <LF_BOLD>       TYPE ANY.

* Init
  LW_ROW = I_START_ROW.
  LW_COL = I_START_COL.
  REFRESH: T_EXCEL[], T_BOLD_ROWS[].

  IF I_TABNAME IS NOT INITIAL.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = I_TABNAME
      CHANGING
        CT_FIELDCAT            = LT_FIELDCAT
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
  ELSE.
    LT_FIELDCAT[] = T_FIELDCAT[].
  ENDIF.

  CHECK LT_FIELDCAT[] IS NOT INITIAL.

* Sort field category table
  SORT LT_FIELDCAT BY NO_OUT COL_POS.
  IF I_GET_BOLD = 'X'.
    READ TABLE LT_FIELDCAT WITH KEY FIELDNAME = GC_FIELD_BOLD
      TRANSPORTING NO FIELDS.
    IF SY-SUBRC IS INITIAL.
      LW_GET_BOLD = 'X'.
    ENDIF.
  ENDIF.


  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      USERNAME = SY-UNAME
    IMPORTING
      DEFAULTS = GS_DEFAULTS
    TABLES
      RETURN   = LT_RETURN.

* Process data
  LOOP AT T_OUTTAB ASSIGNING <LF_DATA>.
    IF T_CONFIG IS NOT INITIAL.
       READ TABLE T_CONFIG ASSIGNING <LF_DATA_CONFIG> INDEX SY-TABIX. " Insert by NgocNV8
    ENDIF.
    LW_FIELDPOS = 0.
*   Process each cell
    LOOP AT LT_FIELDCAT INTO LS_FIELDCAT WHERE NO_OUT IS INITIAL.
*     Get cell position
      IF I_USE_COLPOS IS INITIAL.
        LW_FIELDPOS = LW_FIELDPOS + 1.
      ELSE.
        LW_FIELDPOS = LS_FIELDCAT-COL_POS.
      ENDIF.
*     Process cell at column name LS_FIELDCAT-FIELDNAME
      ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME OF STRUCTURE <LF_DATA>
        TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
        " Insert by NgocNV8 - Start
          IF <LF_DATA_CONFIG> IS ASSIGNED.
            ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME OF STRUCTURE <LF_DATA_CONFIG>
              TO <LF_VALUE_CONFIG>.
          ENDIF.
        " Insert by NgocNV8 - End
*       Get Row, column in excel file
        IF I_TRANSPOSE IS INITIAL.
          LW_COL = LW_FIELDPOS + I_START_COL - 1.
        ELSE.
          LW_ROW = LW_FIELDPOS + I_START_ROW - 1.
        ENDIF.
*       Set position
        LS_EXCEL_DATA-ROW     = LW_ROW.
        LS_EXCEL_DATA-COLUMN  = LW_COL.
*       Set value
        PERFORM STANDARD_VALUE_LVC
          USING     LS_FIELDCAT <LF_DATA> <LF_VALUE> I_KEEP_VALUE
          CHANGING  LS_EXCEL_DATA-VALUE.
      " Insert by NgocNV8
        IF <LF_VALUE_CONFIG> IS ASSIGNED.
          CALL FUNCTION 'ZFM_EXCEL_SPL_CONFID_TO_FORMAT'
            EXPORTING
              I_CONFIG             = <LF_VALUE_CONFIG>
           IMPORTING
             E_CELL_FORMAT        = LS_CELL_CONFIG
             E_CELL_INITIAL       = LW_CELL_INITIAL.
        ENDIF.
      " Insert by NgocNV8

        CONDENSE: LS_EXCEL_DATA-ROW, LS_EXCEL_DATA-COLUMN,
                  LS_EXCEL_DATA-VALUE.
        APPEND LS_EXCEL_DATA TO T_EXCEL.
      " Insert by NgocNV8
        IF LS_CELL_CONFIG IS NOT INITIAL AND LW_CELL_INITIAL IS INITIAL.
          LS_CELL_CONFIG-TOP = LS_EXCEL_DATA-ROW.
          LS_CELL_CONFIG-LEFT = LS_EXCEL_DATA-COLUMN.
          LS_CELL_CONFIG-ROWS = LS_CELL_CONFIG-COLUMNS = 1.
          APPEND LS_CELL_CONFIG TO T_CELLS_FORMAT.
          CLEAR LS_CELL_CONFIG.
        ENDIF.
      " Insert by NgocNV8
      ENDIF.
    ENDLOOP.
    IF LW_GET_BOLD = 'X'.
      ASSIGN COMPONENT GC_FIELD_BOLD OF STRUCTURE <LF_DATA>
        TO <LF_BOLD>.
      IF <LF_BOLD> IS NOT INITIAL.
        T_BOLD_ROWS-ROW = LW_ROW.
        APPEND T_BOLD_ROWS.
      ENDIF.
    ENDIF.

    IF I_TRANSPOSE IS INITIAL.
      LW_ROW = LW_ROW + 1.
    ELSE.
      LW_COL = LW_COL + 1.
    ENDIF.
  ENDLOOP.
  END.





ENDFUNCTION.
