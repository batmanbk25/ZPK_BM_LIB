FUNCTION ZFM_BDS_BUSDOC_UPD_TAB.
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
*"     VALUE(X_FORCE_UPDATE) LIKE  BAPIBDS01-X OPTIONAL
*"     VALUE(BINARY_FLAG) LIKE  BAPIBDS01-X OPTIONAL
*"  TABLES
*"      COMPONENTS STRUCTURE  BAPICOMPON
*"      CONTENT STRUCTURE  BAPICONTEN OPTIONAL
*"      ASCII_CONTENT STRUCTURE  BAPIASCONT OPTIONAL
*"      SIGNATURE STRUCTURE  BAPISIGNAT OPTIONAL
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

  DATA: old_ph_object LIKE sdokobject,
        new_ph_object LIKE sdokobject,
        lo_object LIKE sdokobject,
        lines_filecontent TYPE i,
        lines_properties TYPE i,
        kpro_force_update LIKE sy-datar.

  DATA: i_components LIKE sdokcomchi OCCURS 1 WITH HEADER LINE,
        i_properties LIKE sdokpropty OCCURS 1 WITH HEADER LINE,
        file_access_info TYPE sdokfilaci OCCURS 0 WITH HEADER LINE,
        i_infoobjects LIKE bapiinfobj OCCURS 1 WITH HEADER LINE.

************************ initialization ********************************

  CLEAR: old_ph_object,
         new_ph_object,
         lo_object,
         lines_properties,
         lines_filecontent,
         kpro_force_update,
         signature.

  REFRESH: i_properties,
           i_components,
           file_access_info,
           i_infoobjects,
           signature.

  MOVE: x_force_update TO kpro_force_update.

************************ program ***************************************
*--------------------------------------------------------------------*
* TuanBA Delete
*--------------------------------------------------------------------*
** authority-check with classname and activity change
*  PERFORM authority_document_set
*                          TABLES
*                            signature
*                            properties
*                          USING
*                            'update_with_table'
*                            logical_system
*                            change
*                            classname
*                            classtype
*                            object_key
*                            client.

* check client because KPro-Core
  IF client EQ space.
    MOVE sy-mandt TO client.
  ENDIF.

* check files and signature and parameters

  DESCRIBE TABLE content LINES lines_filecontent.
  IF lines_filecontent EQ 0.
    DESCRIBE TABLE ascii_content LINES lines_filecontent.
  ENDIF.
  IF lines_filecontent EQ 0.
    MESSAGE e009 WITH 'CONTENT/ASCII_CONTENT'
'BDS_BUSINESSDOCUMENT_UPD_TAB' RAISING
    parameter_error.
  ENDIF.
  LOOP AT components WHERE doc_count NE '1'.
    MESSAGE e008 WITH 'BDS_BUSINESSDOCUMENT_UPD_TAB' RAISING
    parameter_error.
  ENDLOOP.

  IF doc_id IS INITIAL.
    MESSAGE e009 WITH 'DOC_ID' 'BDS_BUSINESSDOCUMENT_UPD_TAB' RAISING
    parameter_error.
  ENDIF.

  MOVE: doc_id TO signature-doc_id,
        doc_ver_no TO signature-doc_ver_no,
        doc_var_id TO signature-doc_var_id.
  APPEND signature.

* get the right phio

**********************************************************************
* TuanBA EDit START
**********************************************************************
* CALL FUNCTION 'BDS_PHIOS_GET_RIGHT'
  CALL FUNCTION 'ZFM_BDS_PHIOS_GET_RIGHT'
**********************************************************************
* TuanBA EDit START
**********************************************************************
       EXPORTING
            logical_system  = logical_system
            classname       = classname
            classtype       = classtype
            client          = client
            object_key      = object_key
            check_state     = 'X'
       TABLES
            infoobjects     = i_infoobjects
            signature       = signature
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
  READ TABLE i_infoobjects INDEX 1.
  MOVE: i_infoobjects-ph_objid TO old_ph_object-objid,
        i_infoobjects-ph_class TO old_ph_object-class,
        i_infoobjects-lo_objid TO lo_object-objid,
        i_infoobjects-lo_class TO lo_object-class.

  LOOP AT components.
    MOVE: components-mimetype TO file_access_info-mimetype,
          components-comp_id TO file_access_info-file_name,
          binary_flag TO file_access_info-binary_flg,
          components-comp_size TO file_access_info-file_size.
    APPEND file_access_info.
  ENDLOOP.

  DATA: l_bds_cl_docs TYPE TABLE OF bds_cl_doc,
        l_bds_cl_doc  TYPE bds_cl_doc,
        l_doc_type    TYPE toadv-ar_object,
        new_stor_cat LIKE  sdokphio-stor_cat.
  READ TABLE signature WITH KEY doc_id = doc_id
                                prop_name = 'BDS_DOCUMENTTYPE'.
  IF sy-subrc = 0.
    l_doc_type = signature-prop_value.
  ENDIF.
  CALL FUNCTION 'BDS_METAINFO_GET'
    EXPORTING
      classname             = classname
      classtype             = classtype
      documenttype          = l_doc_type
*     ACTIVEFLAG            = 'X'
*     USER_SPECIFIC         = ' '
      client                = client
    TABLES
*     ITAB_TOAOM            =
      itab_bds_cl_doc       = l_bds_cl_docs
    EXCEPTIONS
      nothing_found         = 1
      OTHERS                = 2.
  IF sy-subrc = 0.
    READ TABLE l_bds_cl_docs INTO l_bds_cl_doc INDEX 1.
    IF l_bds_cl_doc-cont_categ NE space.
      new_stor_cat = l_bds_cl_doc-cont_categ.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'SDOK_PHIO_STORE_AS_UPDATE'
       EXPORTING
            object_id            = old_ph_object
*           NEW_OBJECT_UNIQUE_ID =
            new_stor_cat      = new_stor_cat
            x_force_update       = kpro_force_update
            client               = client
            text_as_stream      = 'X'
       IMPORTING
            new_object_id        = new_ph_object
       TABLES
            file_access_info     = file_access_info
            file_content_ascii   = ascii_content
            file_content_binary  = content
       EXCEPTIONS
            not_existing         = 1
            not_allowed          = 20
            not_authorized       = 6
            no_content           = 7
            bad_storage_type     = 8
            OTHERS               = 9
            .
  IF sy-subrc NE 0.
    PERFORM kpro_eh_3 USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  PERFORM insert_phios USING old_ph_object new_ph_object.
  DESCRIBE TABLE properties LINES lines_properties.
  IF lines_properties GT 0.
    CALL FUNCTION 'BDS_SET_PROPERTIES'
         EXPORTING
              client          = client
              lo_object       = lo_object
              ph_object       = new_ph_object
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
      PERFORM kpro_eh_3 USING sy-subrc sy-msgid sy-msgty sy-msgno
                                sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* get the right phio
  REFRESH signature.
  CLEAR signature.
  MOVE: doc_id TO signature-doc_id,
        doc_ver_no TO signature-doc_ver_no,
        doc_var_id TO signature-doc_var_id.
  APPEND signature.

**********************************************************************
* TuanBA EDit START
**********************************************************************
* CALL FUNCTION 'BDS_PHIOS_GET_RIGHT'
  CALL FUNCTION 'ZFM_BDS_PHIOS_GET_RIGHT'
**********************************************************************
* TuanBA EDit START
**********************************************************************
       EXPORTING
            logical_system  = logical_system
            classname       = classname
            classtype       = classtype
            client          = client
            object_key      = object_key
       TABLES
            infoobjects     = i_infoobjects
            signature       = signature
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
