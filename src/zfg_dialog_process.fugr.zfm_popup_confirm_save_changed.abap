FUNCTION ZFM_POPUP_CONFIRM_SAVE_CHANGED.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DISPLAY_CANCEL_BUTTON) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_SHOWICON) TYPE  XMARK DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(E_ANSWER) TYPE  C
*"--------------------------------------------------------------------
CONSTANTS:
    LC_ICON_OKAY      TYPE ICON-NAME  VALUE 'ICON_OKAY',
    LC_ICON_CANCEL    TYPE ICON-NAME  VALUE 'ICON_SYSTEM_CANCEL'.
  DATA:
*   Question text
    LW_QUESTION(62) TYPE C,
*   Title of pop-up confirm
    LW_TITLECONFIRMATION(60) TYPE C,
*   Temple variable store ok_code
    LW_UCOMM TYPE SYUCOMM,
    LW_ICON_BUTTON_1          TYPE ICON-NAME,
    LW_ICON_BUTTON_2          TYPE ICON-NAME.
*----------------------------------------------------*

* Set text question
* Set TITLE OF popup confirmation.
*  LW_TITLECONFIRMATION = TEXT-001.
  LW_TITLECONFIRMATION = TEXT-008.
*  LW_QUESTION = TEXT-002.
  LW_QUESTION = TEXT-005.

  IF I_SHOWICON = GC_XMARK.
    LW_ICON_BUTTON_1 = LC_ICON_OKAY.
    LW_ICON_BUTTON_2 = LC_ICON_CANCEL.
  ENDIF.

* Save sy-ucomm before call Pop up
  LW_UCOMM = SY-UCOMM.
* Call popup function
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = LW_TITLECONFIRMATION
      TEXT_QUESTION         = LW_QUESTION
      TEXT_BUTTON_1         = TEXT-003
      ICON_BUTTON_1         = LW_ICON_BUTTON_1
      TEXT_BUTTON_2         = TEXT-004
      ICON_BUTTON_2         = LW_ICON_BUTTON_2
      DISPLAY_CANCEL_BUTTON = I_DISPLAY_CANCEL_BUTTON
    IMPORTING
      ANSWER                = E_ANSWER.           "Answer

* Load sy-ucomm
  SY-UCOMM = LW_UCOMM.

ENDFUNCTION.
