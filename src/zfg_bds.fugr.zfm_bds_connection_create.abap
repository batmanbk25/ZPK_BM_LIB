FUNCTION ZFM_BDS_CONNECTION_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"     VALUE(LOIO_ID) LIKE  BAPIBDS01-LOIO_ID
*"     VALUE(LOIO_CLASS) LIKE  BAPIBDS01-LOIO_CLASS OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(OBJECT_KEY) LIKE  BAPIBDS01-OBJKEY
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"      OWN_LOGICAL_SYSTEM_NOT_DEFINED
*"--------------------------------------------------------------------
************************** data declaration ****************************

  DATA: I_TABNAME LIKE DCOBJDEF-NAME,
        S_CONNECTION LIKE BDS_CONN00,
        S1_CONNECTION LIKE BDS_CONN01,
        I_X031L_TAB LIKE X031L OCCURS 1 WITH HEADER LINE,
        LINES TYPE P.

************************** initialization ******************************

  CLEAR: S_CONNECTION,
         S1_CONNECTION.

************************** program *************************************

* get logical system
  IF LOGICAL_SYSTEM IS INITIAL.
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
         IMPORTING
              OWN_LOGICAL_SYSTEM             = LOGICAL_SYSTEM
         EXCEPTIONS
              OWN_LOGICAL_SYSTEM_NOT_DEFINED = 1
              OTHERS                         = 2.
    IF SY-SUBRC <> 0.
      concatenate sy-sysid 'CLNT' sy-mandt into logical_system.
    ENDIF.
  ENDIF.

**********************************************************************
* TuanBA Edit START
**********************************************************************
*     CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
      CALL FUNCTION 'ZFM_BDS_DOCUMENTCLASS_GET'
**********************************************************************
* TuanBA Edit END
**********************************************************************
       EXPORTING
            CLASSNAME      = CLASSNAME
            CLASSTYPE      = CLASSTYPE
       IMPORTING
*         LO_CLASS       =
*         PH_CLASS       =
            TABNAME        = I_TABNAME
       EXCEPTIONS
            NOTHING_FOUND     = 1
            PARAMETER_ERROR   = 2
            NOT_ALLOWED       = 3
            ERROR_KPRO        = 4
            INTERNAL_ERROR    = 5
            NOT_AUTHORIZED    = 6
            OTHERS            = 9.
  IF SY-SUBRC NE 0.
    PERFORM INTERNAL_EH(SAPLBDS_BAPI)
                      USING SY-SUBRC SY-MSGID SY-MSGTY SY-MSGNO
                              SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF CLIENT IS INITIAL.
    MOVE SY-MANDT TO CLIENT.
  ENDIF.

  MOVE: LOGICAL_SYSTEM TO S_CONNECTION-LOG_SYSTEM,
        LOGICAL_SYSTEM TO S1_CONNECTION-LOG_SYSTEM,

        CLASSNAME TO S_CONNECTION-CLASSNAME,
        CLASSNAME TO S1_CONNECTION-CLASSNAME,

        CLASSTYPE TO S_CONNECTION-CLASSTYPE,
        CLASSTYPE TO S1_CONNECTION-CLASSTYPE,

        LOIO_ID TO S_CONNECTION-LOIO_ID,
        LOIO_ID TO S1_CONNECTION-LOIO_ID,

        LOIO_CLASS TO S_CONNECTION-LOIO_CLASS,
        LOIO_CLASS TO S1_CONNECTION-LOIO_CLASS,

        CLIENT TO S_CONNECTION-CLIENT,

        OBJECT_KEY TO S_CONNECTION-OBJECT_KEY,
        OBJECT_KEY TO S1_CONNECTION-OBJECT_KEY.

  CALL FUNCTION 'DDIF_NAMETAB_GET'
       EXPORTING
            TABNAME     = I_TABNAME
*         ALL_TYPES   = ' '
*    IMPORTING
*         X030L_WA    =
*         DTELINFO_WA =
*         TTYPINFO_WA =
*         DDOBJTYPE   =
       TABLES
            X031L_TAB   = I_X031L_TAB
*         DFIES_TAB   =
       EXCEPTIONS
            NOT_FOUND   = 1
            OTHERS      = 2
            .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                                        RAISING INTERNAL_ERROR.
  ENDIF.

  DESCRIBE TABLE I_X031L_TAB LINES LINES.

  CASE LINES.
    WHEN 6.
      INSERT INTO (I_TABNAME) CLIENT SPECIFIED VALUES S1_CONNECTION.
    WHEN 7.
      INSERT INTO (I_TABNAME) CLIENT SPECIFIED VALUES S_CONNECTION.
    WHEN OTHERS.
      MESSAGE W035 with i_tabname raiSING INTERNAL_ERROR.
  ENDCASE.

  IF SY-SUBRC NE 0.
    MESSAGE W036 RAISING INTERNAL_ERROR.
  ENDIF.





ENDFUNCTION.
