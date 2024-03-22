FUNCTION ZFM_DOI_EXCEL_FORMAT_CELLS_1.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_SPREADSHEET) TYPE REF TO I_OI_SPREADSHEET
*"     REFERENCE(T_CELLS_FORMAT) TYPE  ZTT_CELLS_FORMAT
*"--------------------------------------------------------------------
DATA:
    LO_ERROR          TYPE REF TO I_OI_ERROR,
    LW_RETCODE        TYPE SOI_RET_STRING,
    LT_CELLS_FORMAT   TYPE ZTT_CELLS_FORMAT,
    LS_CELLS_FORMAT   TYPE ZST_CELLS_FORMAT,
    LW_RANGE          TYPE CHAR30.
  FIELD-SYMBOLS:
    <LF_CELL_FORMATS> TYPE ZST_CELLS_FORMAT.

** Correct frame type
*  LT_CELLS_FORMAT = T_CELLS_FORMAT.
*  LOOP AT LT_CELLS_FORMAT ASSIGNING <LF_CELL_FORMATS>
*    WHERE FRAMETYP = -1.
*    <LF_CELL_FORMATS>-FRAMETYP = 127.
*  ENDLOOP.

** Format cells
*  CALL METHOD I_SPREADSHEET->CELL_FORMAT
*    EXPORTING
*      CELLS   = LT_CELLS_FORMAT
*    IMPORTING
*      ERROR   = LO_ERROR
*      RETCODE = LW_RETCODE.


  LOOP AT T_CELLS_FORMAT INTO LS_CELLS_FORMAT.
    LW_RANGE = SY-TABIX.
    CONDENSE LW_RANGE.  " Insert by NgocNV8
    CONCATENATE 'ABC' LW_RANGE INTO LW_RANGE.
    CALL METHOD I_SPREADSHEET->INSERT_RANGE_DIM
      EXPORTING
        NAME    = LW_RANGE
        LEFT    = LS_CELLS_FORMAT-LEFT
        TOP     = LS_CELLS_FORMAT-TOP
        ROWS    = LS_CELLS_FORMAT-ROWS
        COLUMNS = LS_CELLS_FORMAT-COLUMNS.

    CALL METHOD I_SPREADSHEET->SET_FONT
      EXPORTING
        RANGENAME = LW_RANGE
        FAMILY    = LS_CELLS_FORMAT-FONT
        SIZE      = LS_CELLS_FORMAT-SIZE
        BOLD      = LS_CELLS_FORMAT-BOLD
        ITALIC    = LS_CELLS_FORMAT-ITALIC
        ALIGN     = LS_CELLS_FORMAT-ALIGN.
    IF   LS_CELLS_FORMAT-FRONT IS NOT INITIAL
      OR LS_CELLS_FORMAT-BACK IS NOT INITIAL.
      CALL METHOD I_SPREADSHEET->SET_COLOR
        EXPORTING
          RANGENAME = LW_RANGE
          FRONT     = LS_CELLS_FORMAT-FRONT
          BACK      = LS_CELLS_FORMAT-BACK.
    ENDIF.
  ENDLOOP.





ENDFUNCTION.