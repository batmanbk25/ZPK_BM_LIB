FUNCTION ZFM_BDS_BUSDOC_CREA_TAB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"     VALUE(OBJECT_KEY) LIKE  BAPIBDS01-OBJKEY OPTIONAL
*"     VALUE(BINARY_FLAG) LIKE  BAPIBDS01-X DEFAULT 'X'
*"  EXPORTING
*"     VALUE(OBJECT_KEY) LIKE  BAPIBDS01-OBJKEY
*"  TABLES
*"      SIGNATURE STRUCTURE  BAPISIGNAT
*"      COMPONENTS STRUCTURE  BAPICOMPON
*"      CONTENT STRUCTURE  BAPICONTEN OPTIONAL
*"      ASCII_CONTENT STRUCTURE  BAPIASCONT OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
************************ data declaration ******************************

  DATA: lo_object LIKE sdokobject,
        ph_object LIKE sdokobject,
        n TYPE i,
        lines TYPE i,
        count_filecontent TYPE i,
        count_signature TYPE i,
        count_components TYPE i,
        doc_ver_no LIKE bapibds01-doc_ver_no,
        doc_var_id LIKE bapibds01-doc_var_id,
        doc_var_tg LIKE bapibds01-doc_var_tg,
        i_doc_count LIKE bapifiles-doc_count,
        s_toadd LIKE toadd,
        c_subrc like sy-subrc.

  DATA: i_object_fileproperties LIKE sdokimport OCCURS
                                              1 WITH HEADER LINE,
        i_properties LIKE sdokpropty OCCURS 1 WITH HEADER LINE,
        file_access_info TYPE sdokfilaci OCCURS 0 WITH HEADER LINE.

************************ initialization ********************************

  CLEAR: lo_object,
         ph_object,
         n,
         i_doc_count,
         lines,
         count_filecontent,
         count_signature,
         count_components.

  REFRESH: i_properties,
           i_object_fileproperties,
           file_access_info.

************************ program ***************************************

*--------------------------------------------------------------------*
* TuanBA Delete Start
*--------------------------------------------------------------------*
** authority-check with classname and activity create
*  PERFORM authority_document_set
*                          TABLES
*                            signature
*                            i_properties
*                          USING
*                            'create_with_table'
*                            logical_system
*                            create
*                            classname
*                            classtype
*                            object_key
*                            client.
*
** check classtype
*  PERFORM check_classtype USING classtype.

* check object_key
  PERFORM check_object_key USING object_key.
*--------------------------------------------------------------------*
* TuanBA Delete End
*--------------------------------------------------------------------*

* check client because KPro-Core
  IF client EQ space.
    MOVE sy-mandt TO client.
  ENDIF.

* check parameter
  DESCRIBE TABLE content LINES count_filecontent.
  IF count_filecontent EQ 0.
    DESCRIBE TABLE ascii_content LINES count_filecontent.
  ENDIF.
  DESCRIBE TABLE signature LINES count_signature.
  DESCRIBE TABLE components LINES count_components.
  IF count_filecontent EQ 0.
    MESSAGE e009 WITH 'CONTENT/ASCII_CONTENT'
    'DOCUMENT CREATE WITH table'(001).
  ELSEIF count_signature EQ 0.
    MESSAGE e009 WITH 'SIGNATURE' 'DOCUMENT CREATE WITH TABLE'(001).
  ELSEIF count_components EQ 0.
    MESSAGE e009 WITH 'COMPONENTS' 'DOCUMENT CREATE WITH TABLE'(001).
  ENDIF.
  IF binary_flag NE 'X'.
    MOVE space TO binary_flag.
  ENDIF.

  LOOP AT components.
    LOOP AT signature WHERE doc_count EQ components-doc_count.
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0.
      MESSAGE e008 WITH 'DOCUMENT CREATE WITH TABLE'(001).
    ENDIF.
  ENDLOOP.
  LOOP AT signature.
    AT NEW doc_count.

      REFRESH: i_properties, file_access_info.

      LOOP AT signature WHERE prop_name NE space
                        AND prop_value NE space
                        AND doc_count EQ signature-doc_count.
        i_properties-name = signature-prop_name.
        i_properties-value = signature-prop_value.
        APPEND i_properties.
      ENDLOOP.
      LOOP AT components WHERE doc_count EQ signature-doc_count.
        MOVE: components-mimetype TO file_access_info-mimetype,
              components-comp_id TO file_access_info-file_name,
              binary_flag TO file_access_info-binary_flg,
              components-comp_size TO file_access_info-file_size.
        APPEND file_access_info.
      ENDLOOP.
      PERFORM loio_phio_create
                               TABLES
                                     i_properties
                               USING
                                     logical_system
                                     classname
                                     classtype
                                     client
                               CHANGING
                                     lo_object
                                     ph_object
                                     doc_ver_no
                                     doc_var_id
                                     doc_var_tg.

      PERFORM store_content
                  TABLES
                     file_access_info
                     ascii_content
                     content
                  USING
                     ph_object
                     client
                     c_subrc.

* delete document if need (was error)
      if c_subrc <> 0.

* save all parameters for using in kpro_eh_3
        perform save_temp_parameters using 'X'.

        CALL FUNCTION 'SDOK_LOIO_DELETE_WITH_PHIOS'
          EXPORTING
            OBJECT_ID               = lo_object
            CLIENT                  = client
*   TABLES
*     DELETED_OBJECTS         =
*     BAD_OBJECTS             =
          EXCEPTIONS
*     NOT_EXISTING            = 1
*     NOT_ALLOWED             = 2
*     NOT_AUTHORIZED          = 3
*     EXCEPTION_IN_EXIT       = 4
            OTHERS                  = 0.


* return all parameters which were saved
        perform save_temp_parameters using ' '.

* show message about error
        PERFORM kpro_eh_3 USING sy-subrc sy-msgid sy-msgty sy-msgno
                                  sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.


      PERFORM write_bds_connection
                             USING
                                  logical_system
                                  classname
                                  classtype
                                  lo_object
                                  client
                                  object_key.

      LOOP AT signature WHERE doc_count EQ signature-doc_count.
        MOVE: lo_object TO signature-doc_id,
              doc_ver_no TO signature-doc_ver_no,
              doc_var_id TO signature-doc_var_id,
              doc_var_tg TO signature-doc_var_tg.
        MODIFY signature.
      ENDLOOP.
    ENDAT.
  ENDLOOP.





ENDFUNCTION.
