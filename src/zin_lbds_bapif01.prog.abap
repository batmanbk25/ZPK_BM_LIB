*----------------------------------------------------------------------*
*   INCLUDE LBDS_BAPIF01                                               *
*----------------------------------------------------------------------*

TYPE-POOLS: sdoka. "KPro Type-Pool for error-handling

DATA: i_msgno LIKE sy-msgno.

*---------------------------------------------------------------------*
*       FORM CHECKIN                                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_COMPONENTS                                                  *
*  -->  PH_OBJECT                                                     *
*  -->  RETURN                                                        *
*---------------------------------------------------------------------*
FORM checkin TABLES
                    i_components
             USING
                    client
                    c_subrc like sy-subrc
                    lo_object LIKE sdokobject
                    new_ph_object LIKE SDOKOBJECT.

  DATA: n TYPE i,
        i_sdokerrkey LIKE sdokerrkey OCCURS 1 WITH HEADER LINE,
        ph_object LIKE sdokobject,
        relas     like sdokrelist occurs 0 with header line,
        rela_ids  like sdokobject occurs 0 with header line.

  c_subrc = 0.
  CALL FUNCTION 'SDOK_PHIOS_CHECKIN'
               EXPORTING
*                   FTP_KEEP_OPEN_FLAG    =
                      client                = client
                  TABLES
*                       object_fileproperties = i_object_fileproperties
                      components            = i_components
                      bad_objects           = i_sdokerrkey
            .

  if not i_sdokerrkey[] is initial.
    c_subrc = 1.

    if not lo_object is initial.
* delete document if bad return parameter
      CALL FUNCTION 'SDOK_LOIO_DELETE_WITH_PHIOS'
          EXPORTING
               OBJECT_ID               = lo_object
               CLIENT                  = client
*           TABLES
*                DELETED_OBJECTS         =
*                BAD_OBJECTS             =
          EXCEPTIONS
*                NOT_EXISTING            = 1
*                NOT_ALLOWED             = 2
*                NOT_AUTHORIZED          = 3
*                EXCEPTION_IN_EXIT       = 4
               OTHERS                  = 0.
    endif.

    if not new_ph_object is initial.
* delete document if bad return parameter
    CALL FUNCTION 'SDOK_PHIO_DELETE'
      EXPORTING
        OBJECT_ID               = new_ph_object
        CLIENT                  = client
      EXCEPTIONS
*        NOT_EXISTING            = 1
         NOT_ALLOWED             = 2
*        NOT_AUTHORIZED          = 3
*        EXCEPTION_IN_EXIT       = 4
         OTHERS                  = 5.
      if sy-subrc = 2.
        "variants have incoming relations that belong
        "(unfortunately) to partner objects
        CALL FUNCTION 'SDOK_PHIO_FROM_RELATIONS_GET'
          EXPORTING
            OBJECT_ID               = new_ph_object
            CLIENT                  = client
          TABLES
            RESULT                  = relas[]
          EXCEPTIONS
            OTHERS                  = 0.
        loop at relas.
          rela_ids-class = relas-re_class.
          rela_ids-objid = relas-reio_id.
          append rela_ids.
        endloop.
        CALL FUNCTION 'SDOK_RELAS_DELETE'
          TABLES
            OBJECT_LIST       = rela_ids.
        CALL FUNCTION 'SDOK_PHIO_DELETE'
          EXPORTING
            OBJECT_ID               = new_ph_object
            CLIENT                  = client
          EXCEPTIONS
             OTHERS                  = 0.
      endif.
    endif.

  endif.

  PERFORM kpro_eh_1 TABLES i_sdokerrkey.
ENDFORM.                    "checkin


*---------------------------------------------------------------------*
*       FORM LOIO_PHIO_CREATE                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_PROPERTIES                                                  *
*  -->  CLASSNAME                                                     *
*  -->  LO_OBJECT                                                     *
*  -->  PH_OBJECT                                                     *
*  -->  RETURN                                                        *
*---------------------------------------------------------------------*
FORM loio_phio_create TABLES
                             i_properties STRUCTURE sdokpropty
                         USING
                               logical_system
                               classname
                               classtype
                               client
                         CHANGING
                                  lo_object STRUCTURE sdokobject
                                  ph_object STRUCTURE sdokobject
                                  doc_ver_no
                                  doc_var_id
                                  doc_var_tg.

  MOVE: 'BDS_VERSION_NO' TO i_properties-name,
         '1' TO i_properties-value,
         '1' TO doc_ver_no.
  APPEND i_properties.
  MOVE:  'BDS_VAR_ID' TO i_properties-name,
         '1' TO i_properties-value,
         '1' TO doc_var_id.
  APPEND i_properties.
  MOVE:  'BDS_VAR_TAG' TO i_properties-name,
         'OR' TO i_properties-value,
         'OR' TO doc_var_tg.
  APPEND i_properties.
**********************************************************************
* TuanBA EDit START
**********************************************************************
*  CALL FUNCTION 'BDS_LOIO_PHIO_CREATE'
  CALL FUNCTION 'ZFM_BDS_LOIO_PHIO_CREATE'
**********************************************************************
* TuanBA EDit START
**********************************************************************

    EXPORTING
      logical_system = logical_system
      classname      = classname
      classtype      = classtype
      client         = client
    IMPORTING
      lo_object      = lo_object
      ph_object      = ph_object
    TABLES
      properties     = i_properties
    EXCEPTIONS
      error_kpro     = 4
      internal_error = 5
      OTHERS         = 9.
  IF sy-subrc NE 0.
    PERFORM internal_eh USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "loio_phio_create

*---------------------------------------------------------------------*
*       FORM WRITE_BDS_CONNECTION                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  LOG_SYSTEM                                                    *
*  -->  CLASSNAME                                                     *
*  -->  CLASSTYPE                                                     *
*  -->  LO_OBJECT                                                     *
*  -->  OBJECT_KEY                                                    *
*---------------------------------------------------------------------*
FORM write_bds_connection
                             USING
                                  log_system
                                  classname
                                  classtype
                                  lo_object STRUCTURE sdokobject
                                  client
                                  object_key.
**********************************************************************
* TuanBA EDit START
**********************************************************************
*  CALL FUNCTION 'BDS_CONNECTION_CREATE'
  CALL FUNCTION 'ZFM_BDS_CONNECTION_CREATE'
**********************************************************************
* TuanBA EDit START
**********************************************************************
    EXPORTING
      client                         = client
      loio_id                        = lo_object-objid
      loio_class                     = lo_object-class
      classname                      = classname
      classtype                      = classtype
      logical_system                 = log_system
      object_key                     = object_key
    EXCEPTIONS
      nothing_found                  = 1
      parameter_error                = 2
      not_allowed                    = 3
      error_kpro                     = 4
      internal_error                 = 5
      not_authorized                 = 6
      own_logical_system_not_defined = 13
      OTHERS                         = 9.
  IF sy-subrc NE 0.
    PERFORM internal_eh USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*" write_bds_connection

*&---------------------------------------------------------------------*
*&      Form  STORE_CONTENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM store_content TABLES
                          file_access_info
                          ascii_content
                          content
                   USING
                         ph_object LIKE sdokobject
                         client LIKE sy-mandt
                         c_subrc like sy-subrc.

  CALL FUNCTION 'SDOK_PHIO_STORE_CONTENT'
    EXPORTING
      object_id           = ph_object
      client              = client
      text_as_stream      = 'X'
    TABLES
      file_access_info    = file_access_info
      file_content_ascii  = ascii_content
      file_content_binary = content
    EXCEPTIONS
      not_existing        = 1
      not_allowed         = 20
      not_authorized      = 6
      no_content          = 7
      bad_storage_type    = 8
      OTHERS              = 49.

  c_subrc = sy-subrc.

ENDFORM.                               " STORE_CONTENT

*---------------------------------------------------------------------*
*       FORM GET_URL_FOR_PUT                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_COMPONENTS                                                  *
*  -->  I_URLS                                                        *
*  -->  PH_OBJECT                                                     *
*  -->  CLIENT                                                        *
*---------------------------------------------------------------------*
FORM get_url_for_put USING
                           i_components
                           i_urls
                           ph_object
                           client
                           c_subrc like sy-subrc
                           standard_url_only
                           data_provider_url_only
                           web_applic_server_url_only
                           url_used_at.


  CALL FUNCTION 'SDOK_PHIO_GET_URL_FOR_PUT'
    EXPORTING
      object_id            = ph_object
      requested_components = i_components
      client               = client
      STANDARD_URL_ONLY             = standard_url_only
      DATA_PROVIDER_URL_ONLY        = data_provider_url_only
      WEB_APPLIC_SERVER_URL_ONLY    = web_applic_server_url_only
      URL_USED_AT                   = url_used_at
    IMPORTING
      urls                 = i_urls
    EXCEPTIONS
      not_existing         = 1
      not_authorized       = 6
      not_allowed          = 20
      bad_storage_type     = 8
      OTHERS               = 49.

  c_subrc = sy-subrc.

ENDFORM.                    "get_url_for_put

*&---------------------------------------------------------------------*
*&      Form  INTERNAL_EH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_SUBRC  text
*      -->P_SY_MSGID  text
*      -->P_SY_MSGTY  text
*      -->P_SY_MSGNO  text
*      -->P_SY_MSGV1  text
*      -->P_SY_MSGV2  text
*      -->P_SY_MSGV3  text
*      -->P_SY_MSGV4  text
*----------------------------------------------------------------------*
FORM internal_eh USING    p_sy_subrc LIKE sy-subrc
                          p_sy_msgid LIKE sy-msgid
                          p_sy_msgty LIKE sy-msgty
                          p_sy_msgno LIKE sy-msgno
                          p_sy_msgv1 LIKE sy-msgv1
                          p_sy_msgv2 LIKE sy-msgv2
                          p_sy_msgv3 LIKE sy-msgv3
                          p_sy_msgv4 LIKE sy-msgv4.
  DATA: local_subrc LIKE sy-subrc.
  MOVE p_sy_subrc TO local_subrc.
  IF p_sy_msgid NE space AND p_sy_msgty NE space AND
     p_sy_msgno NE space AND p_sy_msgno NE '001'
                         AND p_sy_msgno NE '101'.
    PERFORM write_application_log_2
                    USING p_sy_msgid p_sy_msgty p_sy_msgno
                          p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4.
    CASE local_subrc.
      WHEN 1.                          "NOTHING_FOUND
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
        WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
        RAISING nothing_found.
      WHEN 2.                          "PARAMETER_ERROR
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
         WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
         RAISING parameter_error.
      WHEN 3.                          "NOT_ALLOWED
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
         WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
         RAISING not_allowed.
      WHEN 4.                          "ERROR_KPRO
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
        WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
        RAISING error_kpro.
      WHEN 5.                          "INTERNAL_ERROR
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
         WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
         RAISING internal_error.
      WHEN 6.                          "NOT_AUTHORIZED
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
        WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
        RAISING not_authorized.
      WHEN 11.                         "NO_CONTENT
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
        WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
        RAISING no_content.
      WHEN 12.                         "ERROR_DP
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
         WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
         RAISING error_dp.
      WHEN 13.                         "OWN_LOGICAL_SYSTEM_NOT_DEFINED
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
         WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
         RAISING internal_error.
      WHEN OTHERS.
        MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
        WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
        RAISING internal_error.
    ENDCASE.
  ELSE.
    i_msgno = p_sy_subrc + 100.
    CASE p_sy_subrc.
      WHEN 1.                          "NOTHING_FOUND
        MESSAGE w101 RAISING nothing_found.
      WHEN 2.                          "PARAMETER_ERROR
        PERFORM write_application_log USING i_msgno.
        MESSAGE w102 RAISING parameter_error.
      WHEN 3.                          "NOT_ALLOWED
        PERFORM write_application_log USING i_msgno.
        MESSAGE w103 RAISING not_allowed.
      WHEN 4.                          "ERROR_KPRO
        PERFORM write_application_log USING i_msgno.
        MESSAGE w104 RAISING error_kpro.
      WHEN 5.                          "INTERNAL_ERROR
        PERFORM write_application_log USING i_msgno.
        MESSAGE w105 RAISING internal_error.
      WHEN 6.                          "NOT_AUTHORIZED
        MESSAGE w106 RAISING not_authorized.
      WHEN 11.                         "NO_CONTENT
        PERFORM write_application_log USING i_msgno.
        MESSAGE w111 RAISING internal_error.
      WHEN 12.                         "ERROR_DP
        MESSAGE w112 RAISING internal_error.
      WHEN 13.                         "OWN_LOGICAL_SYSTEM_NOT_DEFINED
        MESSAGE w113 RAISING internal_error.
      WHEN OTHERS.
        MESSAGE w105 RAISING internal_error. "not defined
    ENDCASE.
  ENDIF.
ENDFORM.                               " INTERNAL_EH

*&---------------------------------------------------------------------*
*&      Form  KPRO_EH_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BAD_OBJECTS  text
*----------------------------------------------------------------------*
FORM kpro_eh_1 TABLES p_sdokerrkey STRUCTURE sdokerrkey.

  DATA: count_bad_object TYPE i.

  DESCRIBE TABLE p_sdokerrkey LINES count_bad_object.

  IF count_bad_object GT 0.            "Any error?
    LOOP AT p_sdokerrkey.
      PERFORM check_kpro_error USING p_sdokerrkey-error_key.
    ENDLOOP.
  ENDIF.
ENDFORM.                                                    " KPRO_EH_1

*&---------------------------------------------------------------------*
*&      Form  KPRO_EH_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_SDOKERRMSG  text
*----------------------------------------------------------------------*
FORM kpro_eh_2 TABLES p_sdokerrmsg STRUCTURE sdokerrmsg.

  DATA: lines_bad_objects TYPE i.

  DESCRIBE TABLE p_sdokerrmsg LINES lines_bad_objects.
  IF lines_bad_objects NE 0.
    LOOP AT p_sdokerrmsg.
      IF p_sdokerrmsg-id NE space AND p_sdokerrmsg-type NE space
      AND p_sdokerrmsg-no NE space.
        i_msgno = p_sdokerrmsg-error_key + 200.
*       perform write_application_log using i_msgno.
        MESSAGE ID p_sdokerrmsg-id TYPE p_sdokerrmsg-type
        NUMBER p_sdokerrmsg-no WITH p_sdokerrmsg-v1 p_sdokerrmsg-v2
        p_sdokerrmsg-v3 p_sdokerrmsg-v4.
      ELSE.
        PERFORM check_kpro_error USING p_sdokerrmsg-error_key.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                                                    " KPRO_EH_2

*---------------------------------------------------------------------*
*       FORM CHECK_KPRO_ERROR                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ERROR_KEY                                                     *
*---------------------------------------------------------------------*
FORM check_kpro_error USING error_key LIKE sdokerrkey-error_key.
  i_msgno = error_key + 200.
* perform write_application_log using i_msgno.

  CASE error_key.
    WHEN sdoka_err_ok.                 "00 everthing o.k.
      "nothing to do
    WHEN sdoka_err_unexpected_error.                        "99
      MESSAGE w299 RAISING error_kpro.
    WHEN sdoka_err_not_existing.                            "01
      MESSAGE w201 RAISING error_kpro.
    WHEN sdoka_err_not_allowed.                             "02
      MESSAGE w202 RAISING not_allowed.
    WHEN sdoka_err_missing_directory.                       "03
      MESSAGE w203 RAISING error_kpro.
    WHEN sdoka_err_clashing_names.                          "04
      MESSAGE w204 RAISING error_kpro.
    WHEN sdoka_err_transfer_error.                          "05
      MESSAGE w205 RAISING error_kpro.
    WHEN sdoka_err_not_authorized.                          "06
      MESSAGE w206 RAISING error_kpro.
    WHEN sdoka_err_connection_error.                        "07
      MESSAGE w207 RAISING error_kpro.
    WHEN sdoka_err_bad_storage_category.                    "08
      MESSAGE w208 RAISING error_kpro.
    WHEN sdoka_err_file_open_error.                         "09
      MESSAGE w209 RAISING error_kpro.
    WHEN sdoka_err_file_read_error.                         "10
      MESSAGE w210 RAISING error_kpro.
    WHEN sdoka_err_internal_error.                          "11
      MESSAGE w211 RAISING error_kpro.
    WHEN sdoka_err_file_write_error.                        "12
      MESSAGE w212 RAISING error_kpro.
    WHEN sdoka_err_system_failure.                          "13
      MESSAGE w213 RAISING error_kpro.
    WHEN sdoka_err_comm_failure.                            "14
      MESSAGE w214 RAISING error_kpro.
    WHEN sdoka_err_duplicate_temp_id.                       "15
      MESSAGE w215 RAISING error_kpro.
    WHEN sdoka_err_no_physical_object.                      "16
      MESSAGE w216 RAISING error_kpro.
    WHEN sdoka_err_missing_filename.                        "17
      MESSAGE w217 RAISING error_kpro.
    WHEN sdoka_err_bad_class.                               "18
      MESSAGE w218 RAISING error_kpro.
    WHEN sdoka_err_source_equal_dest.                       "19
      MESSAGE w219 RAISING error_kpro.
    WHEN sdoka_err_in_exit.                                 "20
      MESSAGE w220 RAISING error_kpro.
    WHEN sdoka_err_foreign_lock.                            "21
      MESSAGE w221 RAISING error_kpro.
    WHEN sdoka_err_own_lock.                                "22
      MESSAGE w222 RAISING error_kpro.
    WHEN sdoka_err_enqueue_system_err.                      "23
      MESSAGE w223 RAISING error_kpro.
    WHEN sdoka_err_build_signature.                         "24
      MESSAGE w224 RAISING error_kpro.
    WHEN sdoka_err_not_supported.                           "25
      MESSAGE w225 RAISING error_kpro.
    WHEN sdoka_err_duplicate_filename.                      "26
      MESSAGE w226 RAISING error_kpro.
    WHEN sdoka_err_duplicate_object_id.                     "27
      MESSAGE w227 RAISING error_kpro.
    WHEN sdoka_err_no_tlogo_object.                         "28
      MESSAGE w228 RAISING not_allowed.
    WHEN sdoka_err_no_header_table.                         "29
      MESSAGE w229 RAISING error_kpro.
    WHEN sdoka_err_bad_property.                            "30
      MESSAGE w230 RAISING error_kpro.
    WHEN OTHERS.
      MESSAGE w000 WITH error_key RAISING error_kpro.
  ENDCASE.
ENDFORM.                    "check_kpro_error
*&---------------------------------------------------------------------*
*&      Form  KPRO_EH_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_SUBRC  text
*      -->P_SY_MSGID  text
*      -->P_SY_MSGTY  text
*      -->P_SY_MSGNO  text
*      -->P_SY_MSGV1  text
*      -->P_SY_MSGV2  text
*      -->P_SY_MSGV3  text
*      -->P_SY_MSGV4  text
*----------------------------------------------------------------------*
FORM kpro_eh_3 USING    p_sy_subrc
                        p_sy_msgid
                        p_sy_msgty
                        p_sy_msgno
                        p_sy_msgv1
                        p_sy_msgv2
                        p_sy_msgv3
                        p_sy_msgv4.

*********************** KPRO-Exceptions ********************************
*
* Exception                       Value               Message-No.
*
* NOT_EXISTING                    1                   151
* NOT_AUTHORIZED                  6                   156
* NO_CONTENT                      7                   157
* BAD_STORAGE_TYPE                8                   158
* MODEL_NOT_EXISTING              9                   159
* BAD_CLASS                       10                  160
* MISSING_PROPERTIES              11                  161
* BAD_PROPERTIES                  12                  162
* BAD_RELATIONS                   13                  163
* DUPLICATE_OBJECT_ID             14                  164
* CHECKED_OUT                     15                  165
* INITIAL                         16                  166
* SOURCE_NOT_EXISTING             17                  167
* TRANSFER_ERROR                  18                  168
* MISSING_CLASS                   19                  169
* NOT_ALLOWED                     20                  170
* NO_URL_AVAILABLE                21                  171
* FROM_OBJECT_NOT_EXISTING        22                  172
* TO_OBJECT_NOT_EXISTING          23                  173
* UNIQUE_AND_EXISISTING           24                  174
* DUPLICATE_RELATION_ID           25                  175
* BAD_QUERY                       26                  176
* FOREIGN_LOCK                    27                  177
* ENQUE_SYSTEM_FAILURE            28                  178
*
* OTHERS                          49                  149
*
*********************** KPRO-Exceptions ********************************

  i_msgno = p_sy_subrc + 150.
* perform write_application_log using i_msgno.
  IF p_sy_msgid EQ '1R' AND p_sy_msgty NE space AND
     p_sy_msgno NE space.
    MESSAGE ID p_sy_msgid TYPE p_sy_msgty NUMBER p_sy_msgno
               WITH p_sy_msgv1 p_sy_msgv2 p_sy_msgv3 p_sy_msgv4
               RAISING error_kpro.
  ELSE.
    MESSAGE ID 'SBDS' TYPE 'W' NUMBER i_msgno RAISING error_kpro.
  ENDIF.
ENDFORM.                                                    " KPRO_EH_3
*&---------------------------------------------------------------------*
*&      Form  WRITE_APPLICATION_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_MSGNO  text
*----------------------------------------------------------------------*
FORM write_application_log USING p_msgno.
  DATA: i_text LIKE balmi-altext.
  MOVE text-002 TO i_text.
  CALL FUNCTION 'BDS_WRITE_APPLICATIONLOG'
       EXPORTING
            msgid     = 'SBDS'
            msgty     = 'W'
            msgno     = p_msgno
*         MSGV1     =
*         MSGV2     =
*         MSGV3     =
*         MSGV4     =
            text      = i_text
            object    = 'SBDS'
            subobject = 'CORE'
            .
ENDFORM.                               " WRITE_APPLICATION_LOG

*&---------------------------------------------------------------------*
*&      Form  WRITE_APPLICATION_LOG_2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_SUBRC  text
*      -->P_SY_MSGID  text
*      -->P_SY_MSGTY  text
*      -->P_SY_MSGNO  text
*      -->P_SY_MSGV1  text
*      -->P_SY_MSGV2  text
*      -->P_SY_MSGV3  text
*      -->P_SY_MSGV4  text
*----------------------------------------------------------------------*
FORM write_application_log_2 USING    p_sy_msgid
                                      p_sy_msgty
                                      p_sy_msgno
                                      p_sy_msgv1
                                      p_sy_msgv2
                                      p_sy_msgv3
                                      p_sy_msgv4.
  DATA: i_text LIKE balmi-altext.
  MOVE text-002 TO i_text.
  CALL FUNCTION 'BDS_WRITE_APPLICATIONLOG'
    EXPORTING
      msgid     = p_sy_msgid
      msgty     = p_sy_msgty
      msgno     = p_sy_msgno
      msgv1     = p_sy_msgv1
      msgv2     = p_sy_msgv2
      msgv3     = p_sy_msgv3
      msgv4     = p_sy_msgv4
      text      = i_text
      object    = 'SBDS'
      subobject = 'CORE'.

ENDFORM.                               " WRITE_APPLICATION_LOG_2

*---------------------------------------------------------------------*
*       FORM AUTHORITY_DOCUMENT_SET                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  ACTIVITY                                                      *
*  -->  CLASSNAME                                                     *
*  -->  CLASSTYPE                                                     *
*  -->  RC                                                            *
*---------------------------------------------------------------------*
FORM authority_document_set TABLES
                                  p_signature
                                  p_properties
                            USING
                                  method LIKE bapibds01-method
                                logical_system LIKE bapibds01-log_system
                                  activity LIKE tact-actvt
                                  classname LIKE bapibds01-classname
                                  classtype LIKE bapibds01-classtype
                                  object_key LIKE bapibds01-objkey
                                  client LIKE bapibds01-client.

***************************** data declaration *************************

  DATA: i_funcname LIKE bapibds01-funcname,
        i_exit TYPE c.

***************************** initialization ***************************

  CLEAR: i_funcname,
         i_exit.

******************************** program *******************************

**********************************************************************
* TuanBA Edit START
**********************************************************************
*     CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
      CALL FUNCTION 'ZFM_BDS_DOCUMENTCLASS_GET'
**********************************************************************
* TuanBA Edit END
**********************************************************************
       EXPORTING
            classname        = classname
            classtype        = classtype
       IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
*           LOG_LEVEL        =
*      TABLES
*           DOCUMENT_CLASSES =
       EXCEPTIONS
*           NOTHING_FOUND    = 1
*           PARAMETER_ERROR  = 2
*           NOT_ALLOWED      = 3
*           ERROR_KPRO       = 4
*           INTERNAL_ERROR   = 5
*           NOT_AUTHORIZED   = 6
            OTHERS           = 7
            .
  IF sy-subrc EQ 0 AND i_funcname NE space.
    CONCATENATE 'a_' method INTO method.
    CALL FUNCTION i_funcname
         EXPORTING
              method           = method
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*              DOC_ID           =
*              DOC_VER_NO       =
*              DOC_VAR_ID       =
*              NEW_CLASSNAME    =
*              NEW_CLASSTYPE    =
*              NEW_CLIENT       =
*              NEW_OBJECT_KEY   =
*              NEW_VAR_TG       =
          IMPORTING
              exit             = i_exit
          TABLES
*             COMPONENTS       =
              signature        = p_signature
*             CONTENT          =
*             URIS             =
*             FILES            =
*             RELATIONS        =
*             DPROPERTIES      =
              properties       = p_properties
*             COMMFILE_ENTRIES =
              .
  ENDIF.
  IF i_exit NE 'X'.
    IF classname EQ space AND classtype EQ space.
      AUTHORITY-CHECK OBJECT 'S_BDS_DS'
                      ID  'CLASSNAME' DUMMY
                      ID  'CLASSTYPE' DUMMY
                      ID  'ACTVT' FIELD activity.
    ELSEIF classname NE space AND classtype EQ space.
      AUTHORITY-CHECK OBJECT 'S_BDS_DS'
                      ID  'CLASSNAME' FIELD classname
                      ID  'CLASSTYPE' DUMMY
                      ID  'ACTVT' FIELD activity.
    ELSEIF classname EQ space AND classtype NE space.
      AUTHORITY-CHECK OBJECT 'S_BDS_DS'
                      ID  'CLASSNAME' DUMMY
                      ID  'CLASSTYPE' FIELD classtype
                      ID  'ACTVT' FIELD activity.
    ELSE.
      AUTHORITY-CHECK OBJECT 'S_BDS_DS'
                      ID  'CLASSNAME' FIELD classname
                      ID  'CLASSTYPE' FIELD classtype
                      ID  'ACTVT' FIELD activity.
    ENDIF.
    IF sy-subrc NE 0.
      MESSAGE e106 RAISING not_authorized.
    ENDIF.
  ENDIF.
ENDFORM.                    "authority_document_set

*---------------------------------------------------------------------*
*       FORM AUTHORITY_DOCUMENT                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  LOIO_CLASS                                                    *
*  -->  ACTIVITY                                                      *
*  -->  RC                                                            *
*---------------------------------------------------------------------*
FORM authority_document USING
                             activity LIKE tact-actvt
                             loio_class LIKE bapibds01-loio_class.
  IF loio_class EQ space.
    AUTHORITY-CHECK OBJECT 'S_BDS_D'
                    ID  'LOIO_CLASS' DUMMY
                    ID  'ACTVT' FIELD activity.
  ELSE.
    AUTHORITY-CHECK OBJECT 'S_BDS_D'
                    ID  'LOIO_CLASS' FIELD loio_class
                    ID  'ACTVT' FIELD activity.
  ENDIF.
  IF sy-subrc NE 0.
    MESSAGE e106 RAISING not_authorized.
  ENDIF.
ENDFORM.                    "authority_document

*---------------------------------------------------------------------*
*       FORM CHECK_CLASSTYPE                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  CLASSTYPE                                                     *
*---------------------------------------------------------------------*
FORM check_classtype USING classtype.
  IF classtype NE 'BO'                 " Business Object Repository
     AND classtype NE 'CL'             " Classlibrary
     AND classtype NE 'OT'.            " Others
    MESSAGE w032 RAISING parameter_error.
  ENDIF.
ENDFORM.                    "check_classtype

*&---------------------------------------------------------------------*
*&      Form  CHECK_OBJECT_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_object_key USING object_key LIKE bapibds01-objkey.
  DATA: c_uuid LIKE sysuuid-c.
  IF object_key EQ space.
    CALL FUNCTION 'SYSTEM_UUID_C_CREATE'
      IMPORTING
        uuid = c_uuid.
    MOVE c_uuid TO object_key.
  ENDIF.
ENDFORM.                               " CHECK_OBJECT_KEY
*&---------------------------------------------------------------------*
*&      Form  SET_LOIO_PROPERTIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PROPERTIES  text
*      -->P_I_PROPERTIES  text
*----------------------------------------------------------------------*
FORM set_loio_properties TABLES   p_a_properties STRUCTURE sdokpropty
                                  p_l_properties STRUCTURE sdokpropty.
  LOOP AT p_a_properties WHERE name = 'BDS_DOCUMENTTYPE'
                        OR name EQ 'BDS_DESCRIPTION'.
    IF p_a_properties-name EQ 'BDS_DESCRIPTION'.
      MOVE: 'DESCRIPTION' TO p_l_properties-name,
            p_a_properties-value TO p_l_properties-value.
    ELSE.
      MOVE p_a_properties TO p_l_properties.
    ENDIF.
    APPEND p_l_properties.
  ENDLOOP.
  DELETE p_a_properties WHERE name EQ 'BDS_DESCRIPTION'.
ENDFORM.                               " SET_LOIO_PROPERTIES
*&---------------------------------------------------------------------*
*&      Form  insert_phios
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OLD_PH_OBJECT  text
*      -->P_NEW_PH_OBJECT  text
*----------------------------------------------------------------------*
FORM insert_phios USING    p_old_ph_object LIKE sdokobject
                           p_new_ph_object LIKE sdokobject.

  DATA: timestamp TYPE timestamp.
  GET TIME STAMP FIELD timestamp.

  MOVE: p_old_ph_object-objid TO bds_t_phio-o_ph_id,
        p_old_ph_object-class TO bds_t_phio-o_ph_class,
        p_new_ph_object-objid TO bds_t_phio-n_ph_id,
        p_new_ph_object-class TO bds_t_phio-n_ph_class,
        sy-uname TO bds_t_phio-crea_user,
        timestamp TO bds_t_phio-crea_time.

  INSERT bds_t_phio.

ENDFORM.                               " insert_phios
*&---------------------------------------------------------------------*
*&      Form  complete_tp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_INFOOBJECTS  text
*----------------------------------------------------------------------*
FORM complete_tp TABLES   p_infoobjects STRUCTURE bapiinfobj
                          p_objectlist STRUCTURE sdokobject.

  DATA: ph_object LIKE sdokobject,
        i_bds_t_phio LIKE bds_t_phio OCCURS 1 WITH HEADER LINE.

  DATA: timestamp TYPE timestamp.

  CLEAR: ph_object,
         timestamp.

  REFRESH: i_bds_t_phio.

  GET TIME STAMP FIELD timestamp.

  LOOP AT p_infoobjects.
    MOVE: p_infoobjects-ph_class TO ph_object-class,
          p_infoobjects-ph_objid TO ph_object-objid.
    DO.
      SELECT * FROM bds_t_phio APPENDING TABLE i_bds_t_phio
                         WHERE n_ph_id EQ ph_object-objid
                         AND n_ph_class EQ ph_object-class.
*                        AND state NE 'TRANSPORT'.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        LOOP AT i_bds_t_phio WHERE n_ph_id EQ ph_object-objid.
          MOVE: i_bds_t_phio-o_ph_id TO ph_object-objid,
                i_bds_t_phio-o_ph_class TO ph_object-class.
          EXIT.
        ENDLOOP.
      ENDIF.
    ENDDO.
  ENDLOOP.
  LOOP AT i_bds_t_phio.
    MOVE: i_bds_t_phio-o_ph_id TO p_objectlist-objid,
          i_bds_t_phio-o_ph_class TO p_objectlist-class.
    APPEND p_objectlist.
    UPDATE bds_t_phio SET trans_user = sy-uname
                          trans_time = timestamp
                          state = 'TRANSPORT'
                      WHERE n_ph_id EQ i_bds_t_phio-n_ph_id AND
                            n_ph_class EQ i_bds_t_phio-n_ph_class.
  ENDLOOP.
ENDFORM.                               " complete_tp

*---------------------------------------------------------------------*
*       FORM bds_adjust                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  I_FILE_ACCESS_INFO                                            *
*  -->  I2_FILE_ACCESS_INFO                                           *
*  -->  CONTENT                                                       *
*  -->  ASCII_CONTENT                                                 *
*  -->  BINARY_FLAG                                                   *
*---------------------------------------------------------------------*
FORM bds_adjust TABLES i_file_access_info STRUCTURE sdokfilaci
                       content STRUCTURE sdokcntbin
                       ascii_content STRUCTURE sdokcntasc
                 USING
                       binary_flag.
  DATA: i2_file_access_info LIKE scms_acinf OCCURS 1 WITH HEADER LINE.
  DATA: i3_file_access_info LIKE scms_acinf OCCURS 1 WITH HEADER LINE.
  LOOP AT i_file_access_info.
    MOVE-CORRESPONDING i_file_access_info TO i2_file_access_info.
    MOVE: i_file_access_info-file_size TO i2_file_access_info-comp_size,
          i_file_access_info-file_name TO i2_file_access_info-comp_id,
          i2_file_access_info TO i3_file_access_info.
    IF binary_flag EQ space.
      MOVE: 'A' TO i2_file_access_info-binary_flg.
    ELSE.
      MOVE binary_flag TO i2_file_access_info-binary_flg.
    ENDIF.
    APPEND i2_file_access_info.
    APPEND i3_file_access_info.
  ENDLOOP.
  CALL FUNCTION 'SCMS_DOC_ADJUST'
    EXPORTING
      crep_id         = space
      docid           = space
    TABLES
      req_access_info = i2_file_access_info
      access_info     = i3_file_access_info
      content_txt     = ascii_content
      content_bin     = content
    EXCEPTIONS
      error_parameter = 1
      comp_missing    = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE w157 RAISING error_kpro.
  ELSE.
    REFRESH i_file_access_info.
    LOOP AT i3_file_access_info.
      MOVE-CORRESPONDING i3_file_access_info TO i_file_access_info.
      MOVE:
         i3_file_access_info-comp_size TO i_file_access_info-file_size,
         i3_file_access_info-comp_id TO i_file_access_info-file_name.
      APPEND i_file_access_info.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "bds_adjust
*&---------------------------------------------------------------------*
*&      Form  Save_temp_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM Save_temp_parameters using save_flag type c.

  STATICS:  c_subrc like sy-subrc,
            c_msgid like sy-msgid,
            c_msgty like sy-msgty,
            c_msgno like sy-msgno,
            c_msgv1 like sy-msgv1,
            c_msgv2 like sy-msgv2,
            c_msgv3 like sy-msgv3,
            c_msgv4 like sy-msgv4.

  if save_flag = 'X'.
    c_subrc = sy-subrc.
    c_msgid = sy-msgid.
    c_msgty = sy-msgty.
    c_msgno = sy-msgno.
    c_msgv1 = sy-msgv1.
    c_msgv2 = sy-msgv2.
    c_msgv3 = sy-msgv3.
    c_msgv4 = sy-msgv4.
  else.
    sy-subrc = c_subrc.
    sy-msgid = c_msgid.
    sy-msgty = c_msgty.
    sy-msgno = c_msgno.
    sy-msgv1 = c_msgv1.
    sy-msgv2 = c_msgv2.
    sy-msgv3 = c_msgv3.
    sy-msgv4 = c_msgv4.
  endif.

ENDFORM.                    " Save_temp_parameters
