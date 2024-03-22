FUNCTION ZFM_SCR_PAI_LOG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(I_FCODE) TYPE  SYUCOMM DEFAULT SY-UCOMM
*"--------------------------------------------------------------------
DATA:
    LS_TRAN         TYPE ZTB_BM_SL_TRAN,
    LS_STEP         TYPE ZTB_BM_SL_STEP,
    LS_SCRVL        TYPE ZTB_BM_SL_SCRVL,
    LT_SCRVL        TYPE TABLE OF ZTB_BM_SL_SCRVL,
    LW_FULLFIELD    TYPE CHAR100.
  FIELD-SYMBOLS:
    <LF_FIELD>      TYPE ANY.

  CHECK GW_ALLOW_SCR_LOG IS NOT INITIAL
    AND I_FCODE IS NOT INITIAL.

  READ TABLE GT_TRAN INTO LS_TRAN
    WITH KEY REPID  = I_REPID.
  IF SY-SUBRC IS NOT INITIAL.
    TRY.
      CALL METHOD CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32
          RECEIVING
            UUID = LS_TRAN-TRANID.
      CATCH CX_UUID_ERROR .
    ENDTRY.
    LS_TRAN-REPID   = I_REPID.
    LS_TRAN-UNAME   = SY-UNAME.
    LS_TRAN-TDATE   = SY-DATUM.
    LS_TRAN-TIMEFR  = SY-UZEIT.
    LS_TRAN-TIMETO  = SY-UZEIT.
    APPEND LS_TRAN TO GT_TRAN.
    INSERT ZTB_BM_SL_TRAN FROM LS_TRAN.
  ELSE.
    LS_TRAN-TIMETO  = SY-UZEIT.
    UPDATE ZTB_BM_SL_TRAN FROM LS_TRAN.
  ENDIF.

  READ TABLE GT_STEP INTO LS_STEP
    WITH KEY TRANID = LS_TRAN-TRANID
             STEPTM = SY-UZEIT
             FCODE  = I_FCODE.
  IF SY-SUBRC IS NOT INITIAL.
    LS_STEP-TRANID  = LS_TRAN-TRANID.
    LS_STEP-STEPTM  = SY-UZEIT.
    LS_STEP-FCODE   = I_FCODE.
    APPEND LS_STEP TO GT_STEP.
    INSERT ZTB_BM_SL_STEP FROM LS_STEP.
  ENDIF.

  LOOP AT SCREEN.
    CHECK SCREEN-NAME NS '%'.
    CONCATENATE '(' I_REPID ')' SCREEN-NAME INTO LW_FULLFIELD.
    ASSIGN (LW_FULLFIELD) TO <LF_FIELD>.
    IF SY-SUBRC IS INITIAL AND <LF_FIELD> IS NOT INITIAL.
      LS_SCRVL-TRANID = LS_STEP-TRANID.
      LS_SCRVL-STEPTM = LS_STEP-STEPTM.
      LS_SCRVL-DYNNR  = I_DYNNR.
      LS_SCRVL-FNAME  = SCREEN-NAME.
      LS_SCRVL-FVALUE = <LF_FIELD>.
      APPEND LS_SCRVL TO LT_SCRVL.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF LT_SCRVL TO GT_SCRVL.

  IF LT_SCRVL IS NOT INITIAL.
    INSERT ZTB_BM_SL_SCRVL FROM TABLE LT_SCRVL ACCEPTING DUPLICATE KEYS.
  ENDIF.
  COMMIT WORK.





ENDFUNCTION.