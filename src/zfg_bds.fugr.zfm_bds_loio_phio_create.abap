FUNCTION ZFM_BDS_LOIO_PHIO_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"  EXPORTING
*"     VALUE(LO_OBJECT) LIKE  SDOKOBJECT STRUCTURE  SDOKOBJECT
*"     VALUE(PH_OBJECT) LIKE  SDOKOBJECT STRUCTURE  SDOKOBJECT
*"  TABLES
*"      PROPERTIES STRUCTURE  SDOKPROPTY
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
************************** data declaration ****************************

  DATA: i_properties LIKE sdokpropty OCCURS 1 WITH HEADER LINE,
        i_to_relations LIKE sdokrelist OCCURS 1 WITH HEADER LINE.

************************** initialization ******************************

  CLEAR: lo_object.

  REFRESH: i_properties,
           i_to_relations.

***************************** program **********************************


* check classtype
  PERFORM check_classtype(saplbds_bapi)
              USING
                 classtype.
  PERFORM set_loio_properties(saplbds_bapi)
                                         TABLES properties i_properties.
**********************************************************************
* TuanBA Edit START
**********************************************************************
*  CALL FUNCTION 'BDS_LOIO_CREATE'
  CALL FUNCTION 'ZFM_BDS_LOIO_CREATE'
**********************************************************************
* TuanBA Edit START
**********************************************************************
       EXPORTING
            logical_system  = logical_system
            classname       = classname
            classtype       = classtype
            client          = client
       IMPORTING
            lo_object       = lo_object
       TABLES
            properties      = i_properties
       EXCEPTIONS
            nothing_found   = 1
            parameter_error = 2
            not_allowed     = 3
            error_kpro      = 4
            internal_error  = 5
            not_authorized  = 6
            OTHERS          = 9.
  IF sy-subrc ne 0.
    PERFORM internal_eh(saplbds_bapi)
                        USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  REFRESH: i_to_relations.

* set LOIO-Id
  MOVE: lo_object-class TO i_to_relations-prtn_class,
        lo_object-objid TO i_to_relations-prtn_id,
        'LOGOBJECT' TO i_to_relations-re_class.
  APPEND i_to_relations.
**********************************************************************
* TuanBA Edit START
**********************************************************************
*  CALL FUNCTION 'BDS_PHIO_CREATE'
  CALL FUNCTION 'ZFM_BDS_PHIO_CREATE'
**********************************************************************
* TuanBA Edit END
**********************************************************************
       EXPORTING
            logical_system      = logical_system
            classname           = classname
            classtype           = classtype
            client              = client
       IMPORTING
            ph_object         = ph_object
       TABLES
            properties        = properties
*         FROM_RELATIONS    =
            to_relations      = i_to_relations
       EXCEPTIONS
            nothing_found     = 1
            parameter_error   = 2
            not_allowed       = 3
            error_kpro        = 4
            internal_error    = 5
            not_authorized    = 6
            OTHERS            = 9.
  IF sy-subrc ne 0.
    PERFORM internal_eh(saplbds_bapi)
                        USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.





ENDFUNCTION.
