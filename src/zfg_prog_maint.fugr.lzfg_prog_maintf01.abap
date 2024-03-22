*----------------------------------------------------------------------*
***INCLUDE LZFG_PROG_MAINTF01.
*----------------------------------------------------------------------*

**&---------------------------------------------------------------------
*
**&      Form  SAVE_PROG_SIGN
**&---------------------------------------------------------------------
*
**       Save prog sign parameter
**----------------------------------------------------------------------
*
*FORM SAVE_PROG_SIGN .
*  DATA:
*    LT_PROG_SIGNBUK_INS   TYPE TABLE OF ZTB_PROG_SIGNBUK,
*    LS_PROG_SIGNBUK       TYPE ZTB_PROG_SIGNBUK,
*    LW_REGIO              TYPE REGIO,
*    LS_T001               TYPE ZST_T001_USR.
*
*  CLEAR: LT_PROG_SIGNBUK_INS.
*
*  IF GT_PROG_SIGNBUK IS INITIAL.
*    SELECT *
*      FROM ZTB_PROG_SIGNBUK
*      INTO TABLE GT_PROG_SIGNBUK.
*  ENDIF.
*
*  IF GT_T001 IS INITIAL.
*    CALL FUNCTION 'ZFM_VARIANT_GET'
*      EXPORTING
*        I_VAR_NAME        = 'ZREGIO'
*      IMPORTING
*        E_VAR_VALUE       = LW_REGIO
*      EXCEPTIONS
*        NOT_FOUND         = 1
*        OTHERS            = 2.
*
*    SELECT  BUKRS
*            BUTXT
*            REGIO
*            CITY_CODE
*            PRBUK
*            BUKLV
*      FROM T001
*      INTO TABLE GT_T001
*     WHERE REGIO = LW_REGIO.
*  ENDIF.
*
*  ZVI_PROG_SIGN_TOTAL[] = TOTAL[].
*  LOOP AT ZVI_PROG_SIGN_TOTAL.
*    LOOP AT GT_T001 INTO LS_T001.
*      READ TABLE GT_PROG_SIGNBUK TRANSPORTING NO FIELDS
*        WITH KEY  BUKRS   = LS_T001-BUKRS
*                  REPID   = ZVI_PROG_SIGN_TOTAL-REPID
*                  SIGNERF = ZVI_PROG_SIGN_TOTAL-SIGNERF.
*      IF SY-SUBRC IS NOT INITIAL.
*        MOVE-CORRESPONDING ZVI_PROG_SIGN_TOTAL TO LS_PROG_SIGNBUK.
*        LS_PROG_SIGNBUK-BUKRS = LS_T001-BUKRS.
*        APPEND LS_PROG_SIGNBUK TO LT_PROG_SIGNBUK_INS.
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.
*
*  INSERT ZTB_PROG_SIGNBUK FROM TABLE LT_PROG_SIGNBUK_INS.
*  IF SY-SUBRC IS INITIAL.
*    APPEND LINES OF LT_PROG_SIGNBUK_INS TO GT_PROG_SIGNBUK.
*  ENDIF.
**  COMMIT WORK.
*ENDFORM.                    " SAVE_PROG_SIGN
*
**&---------------------------------------------------------------------
*
**&      Module  BTN_UPIMG  INPUT
**&---------------------------------------------------------------------
*
**       text
**----------------------------------------------------------------------
*
*MODULE BTN_UPIMG INPUT.
*  DATA:
*    LW_LINE     TYPE I,
*    LW_IMGNAME  TYPE TDOBNAME.
*  CHECK SY-UCOMM = 'FC_UPIMG'.
*
*  ZVI_SIGN_POS_BUK_EXTRACT[] = EXTRACT[].
*  GET CURSOR LINE LW_LINE.
**--------------------------------------------------------------------*
*  " Edited by NgocNV8 - 09/10/15
*  LW_LINE = TCTRL_ZVI_SIGN_POS_BUK-TOP_LINE + LW_LINE - 1.
**--------------------------------------------------------------------*
*  READ TABLE ZVI_SIGN_POS_BUK_EXTRACT INDEX LW_LINE.
*
*  CONCATENATE ZVI_SIGN_POS_BUK_EXTRACT-BUKRS
*              ZVI_SIGN_POS_BUK_EXTRACT-SPOSID
*              ZVI_SIGN_POS_BUK_EXTRACT-ITEMIX
*         INTO LW_IMGNAME.
*  CALL FUNCTION 'ZFM_BDS_UPLOAD_IMG'
*    EXPORTING
*      I_IMGNAME       = LW_IMGNAME.
*
*ENDMODULE.                 " BTN_UPIMG  INPUT
