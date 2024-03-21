*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_SVINFOF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_INIT_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_INIT_PROC .

ENDFORM.                    " 0000_INIT_PROC

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC .

  PERFORM 0000_GET_DATA.

  PERFORM 0000_PROCESS_DATA.

  CALL SCREEN 0100.
ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  0100_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PBO .
  IF GO_CUS_ALV_TRANS IS INITIAL.
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
      EXPORTING
        I_CUS_CONTROL_NAME            = 'CUS_ALV_TRANS'
        I_STRUCTURE_NAME              = 'ZST_BM_USR_TRAND'
      IMPORTING
        E_ALV_GRID                    = GO_ALV_TRANS
        E_CUS_CONTAINER               = GO_CUS_ALV_TRANS
      CHANGING
        IT_OUTTAB                     = GT_BM_USR_TRAND.

  ELSE.
    CALL METHOD GO_ALV_TRANS->REFRESH_TABLE_DISPLAY.
  ENDIF.
ENDFORM.                    " 0100_PBO

*&---------------------------------------------------------------------*
*&      Form  0100_GET_USR_ACCOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_GET_USR_ACCOUNT .
  PERFORM 9999_GET_USR_ACCOUNT
    USING ZST_BM_USR_ACCOUNT-USRNM.
ENDFORM.                    " 0100_GET_USR_ACCOUNT

*&---------------------------------------------------------------------*
*&      Form  0000_GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_GET_DATA .
* Get user
  SELECT *
    FROM ZTB_BM_SV_USR
    INTO TABLE GT_SVUSR
   WHERE ACTIVE = GC_XMARK.
  SORT GT_SVUSR BY USRNM.

* Get transaction header
  SELECT *
    FROM ZTB_BM_SV_TRANS
    INTO TABLE GT_BM_SV_TRANS
   WHERE DEACTIVE = SPACE.
  SORT GT_BM_SV_TRANS BY TDATE TDATP TRANTY PAYUSR.

* Get transaction header
  SELECT *
    FROM ZTB_BM_SV_TRAND
    INTO TABLE GT_BM_SV_TRAND.
  SORT GT_BM_SV_TRAND BY TDATE TDATP TRANTY PAYUSR PRIORITY RECVUSR.

ENDFORM.                    " 0000_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  0000_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_PROCESS_DATA .

  PERFORM 9999_AGGREGATE_SERVER.

  PERFORM 9999_GET_USR_ACCOUNT
    USING SY-UNAME.
ENDFORM.                    " 0000_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  9999_GET_USR_ACCOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_USRNM  text
*----------------------------------------------------------------------*
FORM 9999_GET_USR_ACCOUNT
  USING    LPW_USRNM          TYPE XUBNAME.
  DATA:
    LS_BM_USR_TRAND           TYPE ZST_BM_USR_TRAND,
    LS_SVUSR                  TYPE ZTB_BM_SV_USR.

  CLEAR: GT_BM_USR_TRAND.
  READ TABLE GT_SVUSR INTO LS_SVUSR
    WITH KEY SAPUN = LPW_USRNM.
  IF SY-SUBRC IS INITIAL.
    CLEAR: ZST_BM_USR_ACCOUNT.
    ZST_BM_USR_ACCOUNT-USRNM = LS_SVUSR-USRNM.
    ZST_BM_USR_ACCOUNT-UNAME = LS_SVUSR-UNAME.
  ENDIF.

  LOOP AT GT_BM_ALL_TRAND INTO LS_BM_USR_TRAND
    WHERE USRNM = LPW_USRNM.
    APPEND LS_BM_USR_TRAND TO GT_BM_USR_TRAND.
    ZST_BM_USR_ACCOUNT-AMOUNT = LS_BM_USR_TRAND-AMTDET
                              + ZST_BM_USR_ACCOUNT-AMOUNT.
    ZST_BM_USR_ACCOUNT-WAERS  = LS_BM_USR_TRAND-WAERS.
  ENDLOOP.

ENDFORM.                    " 9999_GET_USR_ACCOUNT

*&---------------------------------------------------------------------*
*&      Form  9999_AGGREGATE_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_AGGREGATE_SERVER.
  DATA:
    LS_BM_SV_TRANS            TYPE ZTB_BM_SV_TRANS,
    LS_BM_SV_TRAND            TYPE ZTB_BM_SV_TRAND,
    LS_BM_USR_TRAND           TYPE ZST_BM_USR_TRAND,
    LW_TCOUNT	                TYPE ZDD_BM_COUNT.

  LOOP AT GT_BM_SV_TRANS INTO LS_BM_SV_TRANS
    WHERE DEACTIVE IS INITIAL.
    CLEAR: LW_TCOUNT, LS_BM_USR_TRAND.
*   Init
    LS_BM_USR_TRAND-TDATE     = LS_BM_SV_TRANS-TDATE.
    LS_BM_USR_TRAND-TDATP     = LS_BM_SV_TRANS-TDATP.
    LS_BM_USR_TRAND-TRANTY    = LS_BM_SV_TRANS-TRANTY.
    LS_BM_USR_TRAND-PAYUSR    = LS_BM_SV_TRANS-PAYUSR.
    LS_BM_USR_TRAND-USRNM     = LS_BM_SV_TRANS-PAYUSR.
    LS_BM_USR_TRAND-AMTSUM    = LS_BM_SV_TRANS-AMOUNT.
    LS_BM_USR_TRAND-AMTDET    = LS_BM_SV_TRANS-AMOUNT.
    LS_BM_USR_TRAND-WAERS     = LS_BM_SV_TRANS-WAERS.
    APPEND LS_BM_USR_TRAND TO GT_BM_ALL_TRAND.

*   Calculate total count
    READ TABLE GT_BM_SV_TRAND TRANSPORTING NO FIELDS
      WITH KEY  TDATE     = LS_BM_SV_TRANS-TDATE
                TDATP     = LS_BM_SV_TRANS-TDATP
                TRANTY    = LS_BM_SV_TRANS-TRANTY
                PAYUSR    = LS_BM_SV_TRANS-PAYUSR BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      LOOP AT GT_BM_SV_TRAND INTO LS_BM_SV_TRAND FROM SY-TABIX.
        IF LS_BM_SV_TRAND-TDATE    <> LS_BM_SV_TRANS-TDATE
        OR LS_BM_SV_TRAND-TDATP    <> LS_BM_SV_TRANS-TDATP
        OR LS_BM_SV_TRAND-TRANTY   <> LS_BM_SV_TRANS-TRANTY
        OR LS_BM_SV_TRAND-PAYUSR   <> LS_BM_SV_TRANS-PAYUSR.
          EXIT.
        ENDIF.
        LW_TCOUNT                   = LS_BM_SV_TRAND-TCOUNT
                                    + LW_TCOUNT.
      ENDLOOP.
      CHECK LW_TCOUNT IS NOT INITIAL.

*     Calculate amount each person
      LOOP AT GT_BM_SV_TRAND INTO LS_BM_SV_TRAND FROM SY-TABIX.
        IF LS_BM_SV_TRANS-TDATE    <> LS_BM_SV_TRAND-TDATE
        OR LS_BM_SV_TRANS-TDATP    <> LS_BM_SV_TRAND-TDATP
        OR LS_BM_SV_TRANS-TRANTY   <> LS_BM_SV_TRAND-TRANTY
        OR LS_BM_SV_TRANS-PAYUSR   <> LS_BM_SV_TRAND-PAYUSR.
          EXIT.
        ENDIF.
        LS_BM_USR_TRAND-PRIORITY  = LS_BM_SV_TRAND-PRIORITY.
        LS_BM_USR_TRAND-TCOUNT    = LS_BM_SV_TRAND-TCOUNT.
        LS_BM_USR_TRAND-TOTCOUNT  = LW_TCOUNT.
        LS_BM_USR_TRAND-USRNM     = LS_BM_SV_TRAND-RECVUSR.

        LS_BM_USR_TRAND-AMTDET    = LS_BM_USR_TRAND-AMTSUM
                                  / LS_BM_USR_TRAND-TOTCOUNT
                                  * LS_BM_USR_TRAND-TCOUNT * -1.
        APPEND LS_BM_USR_TRAND TO GT_BM_ALL_TRAND.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'ZFM_GET_DESC_FOR_FIELD'
    EXPORTING
      I_DES_FIELD          = 'USRNM'
      I_DES_TFIELD         = 'UNAME'
      T_SRC_DATA           = GT_SVUSR
      I_SORT_DES_TAB       = SPACE
    CHANGING
      T_DES_DATA           = GT_BM_ALL_TRAND.

ENDFORM.                    " 9999_AGGREGATE_SERVER
