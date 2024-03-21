FUNCTION ZFM_MC_BUSAREA_UPDATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MCBAID) TYPE  ZDD_MCBAID
*"  CHANGING
*"     REFERENCE(C_BUSAREA) TYPE  ANY
*"--------------------------------------------------------------------
DATA:
    LS_MCCF_BUSELE    TYPE ZST_MCCF_BUSELE.
  FIELD-SYMBOLS:
    <LF_ELEMENTS>     TYPE ANY TABLE,
    <LF_ELEMENT>      TYPE ANY,
    <LFR_DATA>        TYPE REF TO DATA.

  CALL FUNCTION 'ZFM_MC_GET_CONFIG'
    EXPORTING
      I_MCBAID             = I_MCBAID
    IMPORTING
      E_MCCF_BUSAREA       = GS_MC_BUSAREA.

  LOOP AT GS_MC_BUSAREA-ELEMENTS INTO LS_MCCF_BUSELE.
*   Elements structure = bus.area structure
    IF LS_MCCF_BUSELE-STRUNAME = GS_MC_BUSAREA-STRUNAME.
*     Change single record  using list of changing field
      PERFORM CHANGE_SINGLE_RECORD
        USING LS_MCCF_BUSELE-FIELDS
        CHANGING C_BUSAREA.
*      CALL FUNCTION 'ZFM_MC_BUSELE_UPDATE'
*        EXPORTING
*          I_MCCF_BUSELE       = LS_MCCF_BUSELE
*        CHANGING
*          C_BUSELE            = C_BUSAREA.
    ELSE.
      IF LS_MCCF_BUSELE-ISITEM IS INITIAL.
        IF LS_MCCF_BUSELE-ISREF IS INITIAL.
         ASSIGN COMPONENT LS_MCCF_BUSELE-STRUNAME OF STRUCTURE C_BUSAREA
           TO <LF_ELEMENT>.
        ELSE.
          ASSIGN COMPONENT LS_MCCF_BUSELE-STRUNAME
            OF STRUCTURE C_BUSAREA TO <LFR_DATA>.
          CHECK SY-SUBRC IS INITIAL.
          ASSIGN <LFR_DATA>->* TO <LF_ELEMENT>.
        ENDIF.
        IF SY-SUBRC IS INITIAL.
*         Change single record  using list of changing field
          PERFORM CHANGE_SINGLE_RECORD
            USING LS_MCCF_BUSELE-FIELDS
            CHANGING <LF_ELEMENT>.
*          CALL FUNCTION 'ZFM_MC_BUSELE_UPDATE'
*            EXPORTING
*              I_MCCF_BUSELE       = LS_MCCF_BUSELE
*            CHANGING
*              C_BUSELE            = <LF_ELEMENT>.
        ENDIF.
      ELSE.
        IF LS_MCCF_BUSELE-ISREF IS INITIAL.
          ASSIGN COMPONENT LS_MCCF_BUSELE-STRUNAME
          OF STRUCTURE C_BUSAREA TO <LF_ELEMENTS>.
        ELSE.
          ASSIGN COMPONENT LS_MCCF_BUSELE-STRUNAME
            OF STRUCTURE C_BUSAREA TO <LFR_DATA>.
          CHECK SY-SUBRC IS INITIAL.
          ASSIGN <LFR_DATA>->* TO <LF_ELEMENTS>.
        ENDIF.
        IF SY-SUBRC IS INITIAL.
*         Change table data
          PERFORM CHANGE_MULTI_RECORDS
            USING LS_MCCF_BUSELE-FIELDS
            CHANGING <LF_ELEMENTS>.
*          LOOP AT <LF_ELEMENTS> ASSIGNING <LF_ELEMENT>.
*            CALL FUNCTION 'ZFM_MC_BUSELE_UPDATE'
*              EXPORTING
*                I_MCCF_BUSELE       = LS_MCCF_BUSELE
*              CHANGING
*                C_BUSELE            = <LF_ELEMENT>.
*          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.





ENDFUNCTION.
