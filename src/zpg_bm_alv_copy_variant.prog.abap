REPORT ZPG_BM_ALV_COPY_VARIANT message-id KN.

tables: disvariant,
        ltdx,
        ltdxt,
        SSCRFIELDS.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK1 WITH FRAME TITLE TEXT-SE1.
parameters: q_vari like disvariant-variant obligatory,
            q_repo like disvariant-report obligatory memory id rid,
            q_handle like disvariant-handle,
            Q_user like disvariant-username no-display,
            Q_logg like disvariant-log_group.
SELECTION-SCREEN END OF BLOCK BLOCK1.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-SE2.
parameters: t_vari like disvariant-variant obligatory,
            t_repo like disvariant-report obligatory memory id rid,
            t_handle like disvariant-handle,
            t_logg like disvariant-log_group.
parameters: t_text like ltdxt-text.
SELECTION-SCREEN END OF BLOCK BLOCK2.

parameters f_dele no-display.
data: begin of t_z occurs 1,
        zeile(255),                                       "H2660071
      end of t_z.
data: l_answer, l_save.
data: l_text(60).

data t_ltdx like ltdx occurs 1 with header line.
AT SELECTION-SCREEN.
IF SSCRFIELDS-UCOMM = 'DELE'.
   move 'X' to f_dele.
elseif SSCRFIELDS-UCOMM = 'COPY'.
   clear f_dele.
endif.

INITIAlization.
clear f_dele.

start-of-selection.

move: q_vari to disvariant-variant,
      q_repo to disvariant-report,
      Q_user to disvariant-username,
      q_logg to disvariant-log_group,
      q_handle to disvariant-handle.

CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
     EXPORTING
          I_SAVE        = 'A'
     CHANGING
          CS_VARIANT    = disvariant
     EXCEPTIONS
          WRONG_INPUT   = 1
          NOT_FOUND     = 2
          PROGRAM_ERROR = 3
          OTHERS        = 4.

if sy-subrc <> 0.
   message s000 with text-001. stop.
endif.
read report t_repo into t_z.
if sy-subrc <> 0.
*   message s000 with text-002. stop.
endif.
SELECT * FROM  LTDX into table t_ltdx
       WHERE  RELID      = 'LT'
       AND    REPORT     = q_repo
       AND    HANDLE     = q_handle
       AND    LOG_GROUP  = q_logg
       and    username = Q_user
       AND    VARIANT    = q_vari.
read table t_ltdx index 1.
SELECT single * FROM  LTDXT
       WHERE  RELID      = t_ltdx-relid
       AND    REPORT     = t_ltdx-report
       AND    HANDLE     = t_ltdx-handle
       AND    LOG_GROUP  = t_ltdx-log_group
       AND    USERNAME   = t_ltdx-username
       AND    VARIANT    = t_ltdx-variant
       AND    TYPE       = t_ltdx-type
       AND    LANGU      = sy-langu.

if sy-subrc <> 0.
   message s000 with text-003. stop.
endif.

if f_dele = 'X'.
   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
             DEFAULTOPTION  = 'N'
             TEXTLINE1      = text-b00
             TEXTLINE2      = text-b01
             TITEL          = text-b02
             START_COLUMN   = 25
             START_ROW      = 6
             CANCEL_DISPLAY = 'X'
        IMPORTING
             ANSWER         = l_answer.

   check l_answer = 'J'.

   delete ltdx from table t_ltdx.
   delete ltdxt.
   if sy-subrc = 0.
      message s000 with text-005. stop.
   endif.
endif.

clear disvariant.
move: t_vari to disvariant-variant,
      t_repo to disvariant-report,
      q_user to disvariant-username,
      t_logg to disvariant-log_group,
      t_handle to disvariant-handle.

CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
     EXPORTING
          I_SAVE        = 'A'
     CHANGING
          CS_VARIANT    = disvariant
     EXCEPTIONS
          WRONG_INPUT   = 1
          NOT_FOUND     = 2
          PROGRAM_ERROR = 3
          OTHERS        = 4.

IF SY-SUBRC = 0.
   move text-a00 to l_text.
   replace '&' with disvariant-variant into l_text.
   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
             DEFAULTOPTION  = 'Y'
             TEXTLINE1      = l_text
             TEXTLINE2      = text-a01
             TITEL          = text-a02
             START_COLUMN   = 25
             START_ROW      = 6
             CANCEL_DISPLAY = 'X'
        IMPORTING
             ANSWER         = l_answer.

   check l_answer = 'J'.

ENDIF.

loop at t_ltdx.
   move: t_repo to t_ltdx-report,
         t_handle to t_ltdx-handle,
         t_logg to t_ltdx-log_group,
         t_vari to t_ltdx-variant.
   modify t_ltdx.
endloop.
move: t_repo to ltdxt-report,
      t_handle to ltdxt-handle,
      t_logg to ltdxt-log_group,
      t_vari to ltdxt-variant.
if not t_text is initial.
   move t_text to ltdxt-text.
endif.
modify ltdx from table t_ltdx.
modify ltdxt.

if sy-subrc = 0.
   message s000 with text-004.
endif.
