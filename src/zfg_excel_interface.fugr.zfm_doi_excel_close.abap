FUNCTION ZFM_DOI_EXCEL_CLOSE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILENAME) TYPE  LOCALFILE
*"     VALUE(I_OPEN_FILE) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_NO_ASK) TYPE  XMARK OPTIONAL
*"--------------------------------------------------------------------
DATA:
      LW_DOCUMENT_URL TYPE CHAR256,
      LO_ERROR        TYPE REF TO I_OI_ERROR,
      LW_RETCODE      TYPE SOI_RET_STRING,
      LW_ANSWER       TYPE C.

  CONCATENATE 'FILE://' I_FILENAME INTO LW_DOCUMENT_URL.

  CHECK GO_DOCUMENT IS NOT INITIAL.

  CALL METHOD GO_DOCUMENT->SAVE_DOCUMENT_TO_URL
    EXPORTING
      URL = LW_DOCUMENT_URL.

  PERFORM CLOSE_DOCUMENT.

  IF I_OPEN_FILE IS NOT INITIAL.
    IF I_NO_ASK IS INITIAL.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TITLEBAR              = TEXT-008
          TEXT_QUESTION         = TEXT-009
          ICON_BUTTON_1         = 'ICON_OKAY'
          ICON_BUTTON_2         = 'ICON_CANCEL'
          DISPLAY_CANCEL_BUTTON = SPACE
        IMPORTING
          ANSWER                = LW_ANSWER
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1
          OTHERS                = 2.
    ELSE.
      LW_ANSWER = 1.
    ENDIF.

    IF LW_ANSWER = 1.
      CALL FUNCTION 'WS_EXECUTE'
        EXPORTING
          INFORM             = ' '
          PROGRAM            = I_FILENAME
        EXCEPTIONS
          FRONTEND_ERROR     = 1
          NO_BATCH           = 2
          PROG_NOT_FOUND     = 3
          ILLEGAL_OPTION     = 4
          GUI_REFUSE_EXECUTE = 5
          OTHERS             = 6.
    ENDIF.

  ENDIF.





ENDFUNCTION.
