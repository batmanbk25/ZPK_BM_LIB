FUNCTION ZFM_BDS_BUSDOC_CHANGE_P.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"     VALUE(OBJECT_KEY) LIKE  BAPIBDS01-OBJKEY OPTIONAL
*"     VALUE(DOC_ID) LIKE  BAPIBDS01-DOC_ID
*"     VALUE(DOC_VER_NO) LIKE  BAPIBDS01-DOC_VER_NO
*"     VALUE(DOC_VAR_ID) LIKE  BAPIBDS01-DOC_VAR_ID
*"  TABLES
*"      PROPERTIES STRUCTURE  BAPIPROPER OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
************************ data declaration ******************************

  DATA: ph_object LIKE sdokobject,
        lo_object LIKE sdokobject,
        lines_properties TYPE p,
        i_infoobjects LIKE bapiinfobj OCCURS 1 WITH HEADER LINE,
        i_properties LIKE sdokpropty OCCURS 1 WITH HEADER LINE,
        i_signature LIKE bapisignat OCCURS 1 WITH HEADER LINE.

************************ initialization ********************************

  CLEAR: ph_object,
         lo_object,
         lines_properties.

  REFRESH: i_infoobjects,
           i_properties,
           i_signature.

************************ program ***************************************

** authority-check with classname and activity change
*  PERFORM authority_document_set
*                          TABLES
*                            i_signature
*                            properties
*                          USING
*                            'change_properties'
*                            logical_system
*                            change
*                            classname
*                            classtype
*                            object_key
*                            client.

* check classtype
  PERFORM check_classtype
              USING
                 classtype.

* check client because KPro-Core
  IF client EQ space.
    MOVE sy-mandt TO client.
  ENDIF.

* check parameters

  IF doc_id IS INITIAL.
    MESSAGE e009 WITH 'DOC_ID' 'BDS_BUSINESSDOCUMENT_CHANGE_P' RAISING
      parameter_error.
  ELSEIF doc_ver_no IS INITIAL.
 MESSAGE e009 WITH 'DOC_VER_NO' 'BDS_BUSINESSDOCUMENT_CHANGE_P' RAISING
      parameter_error.
  ELSEIF doc_var_id IS INITIAL.
    MESSAGE e009 WITH 'DOC_VAR_ID' 'BDS_BUSINESSDOCUMENT_CHANGE_P'
RAISING parameter_error.
  ENDIF.

  MOVE: doc_id TO i_signature-doc_id,
        doc_ver_no TO i_signature-doc_ver_no,
        doc_var_id TO i_signature-doc_var_id.
  APPEND i_signature.

* get the right phio

**********************************************************************
* TuanBA Edit START
**********************************************************************
*     CALL FUNCTION 'BDS_PHIOS_GET_RIGHT'
  CALL FUNCTION 'ZFM_BDS_PHIOS_GET_RIGHT'
**********************************************************************
* TuanBA Edit END
**********************************************************************
       EXPORTING
            logical_system = logical_system
            classname      = classname
            classtype      = classtype
            client         = client
            object_key     = object_key
       TABLES
            infoobjects    = i_infoobjects
            signature      = i_signature
       EXCEPTIONS
            nothing_found  = 1
            error_kpro     = 4
            internal_error = 5
            OTHERS         = 9.
  IF sy-subrc NE 0.
    PERFORM internal_eh USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  READ TABLE i_infoobjects INDEX 1.
  MOVE: i_infoobjects-ph_objid TO ph_object-objid,
        i_infoobjects-ph_class TO ph_object-class,
        i_infoobjects-lo_class TO lo_object-class,
        i_infoobjects-lo_objid TO lo_object-objid.

* set properties
  CALL FUNCTION 'BDS_SET_PROPERTIES'
       EXPORTING
            client          = client
            lo_object       = lo_object
            ph_object       = ph_object
       TABLES
            properties      = properties
       EXCEPTIONS
            nothing_found   = 1
            parameter_error = 2
            not_allowed     = 3
            error_kpro      = 4
            internal_error  = 5
            not_authorized  = 6
            OTHERS          = 9.
  IF sy-subrc NE 0.
    PERFORM internal_eh USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.





ENDFUNCTION.
