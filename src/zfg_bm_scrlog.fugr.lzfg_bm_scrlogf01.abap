*----------------------------------------------------------------------*
***INCLUDE LZFG_BM_SCRLOGF01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_INIT_PROG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_INIT_PROG .

  CALL FUNCTION 'ZFM_VARIANT_GET'
    EXPORTING
      I_VAR_NAME  = GC_VAR_SCR_LOG
    IMPORTING
      E_VAR_VALUE = GW_ALLOW_SCR_LOG
    EXCEPTIONS
      NOT_FOUND   = 1
      OTHERS      = 2.


ENDFORM.                    " 0000_INIT_PROG
