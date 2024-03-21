FUNCTION ZFM_BDS_LOIO_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"  EXPORTING
*"     VALUE(LO_OBJECT) LIKE  SDOKOBJECT STRUCTURE  SDOKOBJECT
*"  TABLES
*"      PROPERTIES STRUCTURE  SDOKPROPTY
*"  EXCEPTIONS
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      PARAMETER_ERROR
*"      NOTHING_FOUND
*"      NOT_AUTHORIZED
*"      NOT_ALLOWED
*"--------------------------------------------------------------------
******************************** program *******************************

* check classtype
PERFORM CHECK_CLASSTYPE(SAPLBDS_BAPI)
            USING
               CLASSTYPE.

  IF CLASSNAME NE SPACE.
**********************************************************************
* TuanBA Edit START
**********************************************************************
*     CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
      CALL FUNCTION 'ZFM_BDS_DOCUMENTCLASS_GET'
**********************************************************************
* TuanBA Edit END
**********************************************************************
         EXPORTING
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
         IMPORTING
              LO_CLASS       = LO_OBJECT-CLASS
*             ph_class       =
         EXCEPTIONS
            INTERNAL_ERROR = 5
            NOTHING_FOUND  = 1
            PARAMETER_ERROR = 2
            OTHERS         = 9
            .
    IF SY-SUBRC <> 0.
      PERFORM INTERNAL_EH(SAPLBDS_BAPI)
                          USING SY-SUBRC SY-MSGID SY-MSGTY SY-MSGNO
                                SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ELSE.
    LO_OBJECT-CLASS = 'BDS_LOC1'.
  ENDIF.
* get documentclass LOIO
  CALL FUNCTION 'SDOK_LOIO_CREATE'
       EXPORTING
            OBJECT_CLASS        = LO_OBJECT-CLASS
*         OBJECT_UNIQUE_ID    =
            CLIENT              = CLIENT
      IMPORTING
           OBJECT_ID           = LO_OBJECT
      TABLES
           PROPERTIES          = PROPERTIES
      EXCEPTIONS
            MISSING_CLASS       = 1
            BAD_CLASS           = 2
            MISSING_PROPERTIES  = 3
            BAD_PROPERTIES      = 4
            NOT_AUTHORIZED      = 5
            DUPLICATE_OBJECT_ID = 6
            OTHERS              = 7
            .
    IF SY-SUBRC <> 0.
      PERFORM KPRO_EH_3(SAPLBDS_BAPI)
                          USING SY-SUBRC SY-MSGID SY-MSGTY SY-MSGNO
                                SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.





ENDFUNCTION.
