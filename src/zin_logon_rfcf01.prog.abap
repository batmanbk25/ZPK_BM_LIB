*&---------------------------------------------------------------------*
*&  Include           ZIN_LOGON_RFCF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC .
  DATA:
    LW_RFCDEST        TYPE RFCDEST,
    LW_TASK           TYPE CHAR100,
    LW_RFC_DENI       TYPE XMARK.
  CASE GC_XMARK.
    WHEN P_RFCNAN.
      IF SY-UNAME = 'TUANBA'.
        LW_RFCDEST = 'BHXH_NAN'.
      ELSE.
        LW_RFCDEST = 'RFC_NAN'.
      ENDIF.
    WHEN P_RFCHTI.
      IF SY-UNAME = 'TUANBA'.
        LW_RFCDEST = 'BHXH_HTI'.
      ELSE.
        LW_RFCDEST = 'RFC_HTI'.
      ENDIF.
    WHEN P_RFCHCM.
      LW_RFCDEST = 'RFC_HCM'.
    WHEN P_RFCHUA.
      LW_RFCDEST = 'RFC_HUA'.
    WHEN OTHERS.
      LW_RFCDEST = 'NONE'.
  ENDCASE.

  CALL FUNCTION 'ZFM_VARIANT_GET'
    EXPORTING
      I_VAR_NAME        = 'ZVA_RFC_DENI'
    IMPORTING
      E_VAR_VALUE       = LW_RFC_DENI
    EXCEPTIONS
      NOT_FOUND         = 1
      OTHERS            = 2.
  IF LW_RFC_DENI = GC_XMARK.
    MESSAGE S010(ZMS_COL_LIB) DISPLAY LIKE GC_MTYPE_E.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ZFM_RFC_PROG_SUBMIT' DESTINATION LW_RFCDEST
    STARTING NEW TASK LW_TASK
    EXPORTING
*      I_TCODE       = 'SESSION_MANAGER'.
      I_TCODE       = 'SMEN'.
ENDFORM.                    " 0000_MAIN_PROC
