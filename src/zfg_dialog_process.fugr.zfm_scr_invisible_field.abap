FUNCTION ZFM_SCR_INVISIBLE_FIELD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_FIELD) TYPE  ZTT_ERR_FIELD
*"--------------------------------------------------------------------
DATA: LS_FIELD      LIKE LINE OF IT_FIELD,
        LW_FIELD      TYPE ZST_ERR_FIELD-FIELD.

*----------------------------------------------------*
* Invisible field
  LOOP AT IT_FIELD INTO LS_FIELD.
    LOOP AT SCREEN.
      IF SCREEN-NAME = LS_FIELD-FIELD.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDLOOP.





ENDFUNCTION.
