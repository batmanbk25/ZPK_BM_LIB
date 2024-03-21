FUNCTION ZFM_ALV_ROWS_GET_SELECTED.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_ALV_GRID) TYPE REF TO CL_GUI_ALV_GRID
*"     REFERENCE(IT_ALV_DATA) TYPE  TABLE
*"  EXPORTING
*"     REFERENCE(ET_SEL_DATA) TYPE  TABLE
*"--------------------------------------------------------------------
DATA:
    LT_SEL_ROWS               TYPE LVC_T_ROID,
    LS_SEL_ROW                TYPE LVC_S_ROID.
  FIELD-SYMBOLS:
    <LF_ALV_ROW>              TYPE ANY.

  CLEAR: ET_SEL_DATA.
  CALL METHOD I_ALV_GRID->GET_SELECTED_ROWS
    IMPORTING
      ET_ROW_NO = LT_SEL_ROWS.
  LOOP AT LT_SEL_ROWS INTO LS_SEL_ROW.
    READ TABLE IT_ALV_DATA ASSIGNING <LF_ALV_ROW>
      INDEX LS_SEL_ROW-ROW_ID.
    IF SY-SUBRC IS INITIAL.
      APPEND <LF_ALV_ROW> TO ET_SEL_DATA.
    ENDIF.
  ENDLOOP.





ENDFUNCTION.
