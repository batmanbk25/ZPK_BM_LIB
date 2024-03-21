FUNCTION ZFM_SCR_HIGHLIGHT_FIELD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_FIELD) TYPE  ZTT_ERR_FIELD
*"     REFERENCE(I_FORCUS) TYPE  XMARK DEFAULT 'X'
*"--------------------------------------------------------------------
DATA: LS_FIELD      LIKE LINE OF IT_FIELD,
        LW_FIELD      TYPE ZST_ERR_FIELD-FIELD,
        LW_ROW        TYPE I.

*----------------------------------------------------*
* High light error field
  LOOP AT IT_FIELD INTO LS_FIELD.
    IF SY-TABIX = 1.
      LW_FIELD = LS_FIELD-FIELD.
      LW_ROW   = LS_FIELD-ROW.
    ENDIF.

    LOOP AT SCREEN.
      IF SCREEN-NAME = LS_FIELD-FIELD.
        SCREEN-INTENSIFIED = '1'.
        MODIFY SCREEN.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* Set cusor field
  IF I_FORCUS = GC_XMARK.
    SET CURSOR FIELD LW_FIELD LINE LW_ROW.
  ENDIF.





ENDFUNCTION.
