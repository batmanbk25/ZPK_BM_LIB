FUNCTION ZFM_BDS_PHIOS_GET_RIGHT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME OPTIONAL
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE OPTIONAL
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"     VALUE(OBJECT_KEY) LIKE  BAPIBDS01-OBJKEY OPTIONAL
*"     VALUE(ALL) DEFAULT 'X'
*"     VALUE(CHECK_STATE) DEFAULT SPACE
*"  TABLES
*"      INFOOBJECTS STRUCTURE  BAPIINFOBJ OPTIONAL
*"      SIGNATURE STRUCTURE  BAPISIGNAT OPTIONAL
*"      CONNECTIONS STRUCTURE  BAPICONNEC OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
************************ data declaration ******************************

  DATA: count TYPE i,
        count_signature TYPE i,
        count_infoobjects TYPE i,
        doc_id LIKE bapibds01-doc_id,
        doc_count2 TYPE p,
        old_doc_id LIKE bapibds01-doc_id,
        doc_var_id LIKE bapibds01-doc_var_id,
        doc_ver_no LIKE bapibds01-doc_ver_no,
        doc_var_tg LIKE bapibds01-doc_var_tg,
        doc_count LIKE bapibds01-doc_count,
        delete_flag TYPE c,
        lo_object LIKE sdokobject,
        ph_object LIKE sdokobject,
        ph_object_class LIKE sdokobject-class,
        unique TYPE c VALUE space,
        ver_signature LIKE bapisignat OCCURS 0 WITH HEADER LINE.


  DATA: i_result LIKE sdokrelist OCCURS 1 WITH HEADER LINE,
        i_pinfoobjects LIKE sdokobject OCCURS 1 WITH HEADER LINE,
        i_linfoobjects LIKE sdokobject OCCURS 1 WITH HEADER LINE,
        i_lproperties LIKE sdokproptl OCCURS 1 WITH HEADER LINE,
        i_pproperties LIKE sdokproptl OCCURS 1 WITH HEADER LINE,
        i_sdokerrkey LIKE sdokerrkey OCCURS 1 WITH HEADER LINE,
        i_bds_connections LIKE bapiconnec OCCURS 1 WITH HEADER LINE,
        del_infoobjects LIKE bapiinfobj OCCURS 1 WITH HEADER LINE,
        is_lproperties TYPE SORTED TABLE OF sdokproptl WITH NON-UNIQUE
KEY class objid,
        is_pproperties TYPE SORTED TABLE OF sdokproptl WITH NON-UNIQUE
KEY class objid,
        wa_lproperties LIKE LINE OF is_lproperties,
        wa_pproperties LIKE LINE OF is_pproperties.

  DATA:   BEGIN OF i_signature OCCURS 1.
          INCLUDE STRUCTURE bapisignat.
          INCLUDE STRUCTURE sdokobject.
  DATA    END OF i_signature.

  DATA:   BEGIN OF x_signature OCCURS 1.
          INCLUDE STRUCTURE bapisignat.
          INCLUDE STRUCTURE sdokobject.
  DATA    END OF x_signature.

  DATA:   BEGIN OF e_signature OCCURS 1.
          INCLUDE STRUCTURE bapisignat.
          INCLUDE STRUCTURE sdokobject.
  DATA    END OF e_signature.

  DATA: i_attributes LIKE sdokattrib OCCURS 1 WITH HEADER LINE.

************************ initialization ********************************

  CLEAR: count,
         count_signature,
         count_infoobjects,
         doc_count2,
         doc_id,
         old_doc_id,
         doc_var_id,
         doc_ver_no,
         doc_var_tg,
         doc_count,
         delete_flag,
         lo_object,
         ph_object,
         ph_object_class,
         unique.

  REFRESH: i_pproperties,
           i_lproperties,
           i_result,
           i_pinfoobjects,
           i_linfoobjects,
           i_sdokerrkey,
           i_bds_connections,
           i_signature,
           infoobjects,
           x_signature,
           e_signature,
           del_infoobjects,
           i_attributes,
           ver_signature.

************************ program ***************************************

* check classtype
  PERFORM check_classtype(saplbds_bapi)
              USING
                 classtype.

* check client because KPro-Core
  IF client EQ space.
    MOVE sy-mandt TO client.
  ENDIF.

  DESCRIBE TABLE signature LINES count_signature.

* get all connections
**********************************************************************
* TuanBA Edit START
**********************************************************************
*     CALL FUNCTION 'BDS_CONNECTION_GET'
  CALL FUNCTION 'ZFM_BDS_CONNECTION_GET'
**********************************************************************
* TuanBA Edit END
**********************************************************************
    EXPORTING
      logical_system  = logical_system
      classname       = classname
      classtype       = classtype
      client          = client
      object_key      = object_key
    TABLES
      bds_connections = i_bds_connections
    EXCEPTIONS
      nothing_found   = 1
      internal_error  = 5
      OTHERS          = 9.
  IF sy-subrc NE 0.
    PERFORM internal_eh(saplbds_bapi)
                        USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* get content repository
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
*          LO_CLASS         =
            ph_class         = ph_object_class
*          RE_CLASS         =
*          TABNAME          =
*     TABLES
*          DOCUMENT_CLASSES =
       EXCEPTIONS
            nothing_found    = 1
            parameter_error  = 2
            not_allowed      = 3
            error_kpro       = 4
            internal_error   = 5
            not_authorized   = 6
            OTHERS           = 7
            .
  IF sy-subrc <> 0.
    PERFORM internal_eh(saplbds_bapi)
                        USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* get attributes of phio class

  CALL FUNCTION 'SDOK_PHIO_ATTRIBUTES_GET'
    EXPORTING
      class          = ph_object_class
    TABLES
      attributes     = i_attributes
    EXCEPTIONS
      not_existing   = 1
      not_authorized = 6
      OTHERS         = 49.
  IF sy-subrc <> 0.
    PERFORM kpro_eh_3(saplbds_bapi)
                        USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* get all loio attributes

  LOOP AT i_bds_connections.
    MOVE: i_bds_connections-doc_id TO i_linfoobjects.
    APPEND i_linfoobjects.
  ENDLOOP.
  SORT i_linfoobjects BY objid.
  DELETE ADJACENT DUPLICATES FROM i_linfoobjects COMPARING ALL FIELDS.

* check signature

  DATA: l_h_signature TYPE SORTED TABLE OF bapisignat
                      WITH NON-UNIQUE KEY doc_id.
  IF count_signature NE 0.
    INSERT LINES OF signature INTO TABLE l_h_signature.
    READ TABLE l_h_signature WITH KEY doc_id = space
                             TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      LOOP AT i_linfoobjects.
        READ TABLE l_h_signature WITH KEY doc_id = i_linfoobjects
                                 TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          DELETE i_linfoobjects.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

* get loio properties

  CALL FUNCTION 'SDOK_LOIOS_PROPERTIES_GET'
       EXPORTING
            x_suppress_sys_prop  = 'X'
*             X_PC_PROPERTIES_ONLY =
            client               = client
       TABLES
            object_list          = i_linfoobjects
*             PROPERTIES_REQUEST   =
            properties           = i_lproperties
            bad_objects          = i_sdokerrkey
            .

* check attributes ?
  DELETE i_lproperties WHERE value EQ space.
  CLEAR is_lproperties.
  INSERT LINES OF i_lproperties INTO TABLE is_lproperties.
  IF count_signature NE 0.
    LOOP AT i_linfoobjects.
      LOOP AT is_lproperties INTO wa_lproperties
                          WHERE class EQ i_linfoobjects-class
                            AND objid EQ i_linfoobjects-objid.
        LOOP AT signature WHERE ( doc_id EQ i_linfoobjects
                                  OR doc_id IS INITIAL )
                          AND prop_name NE 'DESCRIPTION'
                          AND prop_name EQ wa_lproperties-name.
          IF wa_lproperties-value NE signature-prop_value.
            delete_flag = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF wa_lproperties-name EQ 'DESCRIPTION'.
          LOOP AT signature WHERE ( doc_id EQ i_linfoobjects
                                    OR doc_id IS INITIAL )
                            AND prop_name EQ 'BDS_DESCRIPTION'.
            IF wa_lproperties-value NE signature-prop_value.
              delete_flag = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF delete_flag EQ 'X'.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF delete_flag EQ 'X'.
        DELETE TABLE i_linfoobjects.
        delete_flag = space.
      ENDIF.
    ENDLOOP.
  ENDIF.

* get all phios

  LOOP AT i_linfoobjects.
    REFRESH: i_result.
    CALL FUNCTION 'SDOK_LOIO_FROM_RELATIONS_GET'
      EXPORTING
        object_id      = i_linfoobjects
        relation_class = 'LOGOBJECT'
        client         = client
      TABLES
        RESULT         = i_result
      EXCEPTIONS
        not_existing   = 1
        bad_class      = 10
        not_authorized = 6
        OTHERS         = 49.
    IF sy-subrc NE 0.
      " so what?
    ENDIF.

    LOOP AT i_result.
      MOVE: i_linfoobjects-class TO infoobjects-lo_class,
            i_linfoobjects-objid TO infoobjects-lo_objid,
            i_result-prtn_id TO infoobjects-ph_objid,
            i_result-prtn_id TO i_pinfoobjects-objid,
            i_result-prtn_class TO infoobjects-ph_class,
            i_result-prtn_class TO i_pinfoobjects-class.
      APPEND i_pinfoobjects.
      APPEND infoobjects.
    ENDLOOP.
  ENDLOOP.

  DESCRIBE TABLE infoobjects LINES count_infoobjects.
  IF count_infoobjects LE 0.
    MESSAGE w001 RAISING nothing_found.
  ENDIF.

* get all phio properties

  CALL FUNCTION 'SDOK_PHIOS_PROPERTIES_GET'
       EXPORTING
*         X_SUPPRESS_SYS_PROP  =
*         X_PC_PROPERTIES_ONLY =
            client               = client
       TABLES
            object_list          = i_pinfoobjects
*         PROPERTIES_REQUEST   =
            properties           = i_pproperties
            bad_objects          = i_sdokerrkey
            .
  PERFORM kpro_eh_1(saplbds_bapi) TABLES i_sdokerrkey.

* get meta signature
  DELETE i_pproperties WHERE value EQ space.

* check state eq '0002'
  IF check_state EQ 'X'.
    LOOP AT i_pproperties WHERE name EQ 'STATE' AND value NE '0002'.
      DELETE i_pproperties WHERE objid EQ i_pproperties-objid.
      DELETE i_pinfoobjects WHERE objid EQ i_pproperties-objid.
      DELETE infoobjects WHERE ph_objid EQ i_pproperties-objid AND
                               ph_class EQ i_pproperties-class.
    ENDLOOP.
  ENDIF.

  CLEAR is_pproperties.
  INSERT LINES OF i_pproperties INTO TABLE is_pproperties.

  DATA: l_index_from TYPE i,
        l_index_to   TYPE i.
  LOOP AT infoobjects.
    CLEAR: l_index_from, l_index_to.
    MOVE: infoobjects-lo_class TO lo_object-class,
          infoobjects-lo_objid TO lo_object-objid,
          infoobjects-ph_class TO i_signature-class,
          infoobjects-ph_objid TO i_signature-objid,
          lo_object TO i_signature-doc_id,
          sy-tabix TO i_signature-doc_count.
    LOOP AT is_pproperties INTO wa_pproperties
                            WHERE class EQ infoobjects-ph_class
                            AND objid EQ infoobjects-ph_objid.
      l_index_to = sy-tabix.
      IF l_index_from IS INITIAL.
        l_index_from = l_index_to.
      ENDIF.
      IF wa_pproperties-name EQ 'BDS_VERSION_NO'.
        MOVE wa_pproperties-value TO i_signature-doc_ver_no.
      ELSEIF wa_pproperties-name EQ 'BDS_VAR_ID'.
        MOVE wa_pproperties-value TO i_signature-doc_var_id.
      ELSEIF wa_pproperties-name EQ 'BDS_VAR_TAG'.
        MOVE wa_pproperties-value TO i_signature-doc_var_tg.
      ENDIF.
    ENDLOOP.
    IF NOT l_index_from IS INITIAL.
      LOOP AT is_pproperties INTO wa_pproperties FROM l_index_from
                                                 TO l_index_to.
        IF wa_pproperties-name NE 'BDS_VERSION_NO' AND
           wa_pproperties-name NE 'BDS_VAR_ID' AND
           wa_pproperties-name NE 'BDS_VAR_TAG'.
          MOVE: wa_pproperties-name TO i_signature-prop_name,
                wa_pproperties-value TO i_signature-prop_value.
          APPEND i_signature.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

* check phio_attributes
  IF count_signature GT 0.
* check doc_id, version, var_id and var_tag.
    READ TABLE signature WITH KEY doc_id = space
                                  doc_ver_no = space
                                  doc_var_id = space
                                  doc_var_tg = space
                         TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      LOOP AT i_signature.
        LOOP AT signature WHERE
         ( doc_id EQ i_signature-doc_id OR doc_id IS INITIAL ) AND
         ( doc_ver_no EQ i_signature-doc_ver_no OR doc_ver_no IS INITIAL )
     AND ( doc_var_id EQ i_signature-doc_var_id OR doc_var_id IS INITIAL )
     AND ( doc_var_tg EQ i_signature-doc_var_tg OR doc_var_tg IS INITIAL )
         .
          EXIT.
        ENDLOOP.
        IF sy-subrc EQ 4.
          CLEAR i_signature.
          MODIFY i_signature.
        ENDIF.
      ENDLOOP.
    ENDIF.
    DELETE i_signature WHERE doc_id EQ space.
    LOOP AT signature.
* check phio attributes only
      IF NOT signature-prop_name IS INITIAL
              AND signature-prop_name NE 'BDS_DOCUMENTTYPE'
              AND signature-prop_name NE 'BDS_DESCRIPTION'.
* 1 xxxx
        IF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 2 ----
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE prop_name EQ signature-prop_name
               AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
*         IF sy-subrc NE 0.
*           PERFORM insert_del_entries TABLES i_signature
*                                              e_signature
*                                      USING signature-prop_name.
*         ENDIF.
* 3 x---
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 4 -x--
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 5 --x-
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_var_id EQ signature-doc_var_id
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 6 ---x
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 7 xx--
        ELSEIF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 8 x-x-
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_var_id EQ signature-doc_var_id
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 9 -xx-
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 10 x--x
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 11 --xx
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 12 -x-x
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 13 xxx-
        ELSEIF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 14 -xxx
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 15 x-xx
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 16 xx-x
        ELSE.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_tg EQ signature-doc_var_tg
                                AND prop_name EQ signature-prop_name
                                AND prop_value EQ signature-prop_value.
            APPEND i_signature TO x_signature.
          ENDLOOP.
        ENDIF.
      ELSE.
* 1 xxxx
        IF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 2 ----
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          MOVE i_signature[] TO x_signature[].
* 3 x---
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 4 -x--
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 5 --x-
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_var_id EQ signature-doc_var_id.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 6 ---x
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 7 xx--
        ELSEIF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 8 x-x-
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_var_id EQ signature-doc_var_id.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 9 -xx-
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 10 x--x
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 11 --xx
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 12 -x-x
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 13 xxx-
        ELSEIF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 14 -xxx
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 15 x-xx
        ELSEIF NOT signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_var_id EQ signature-doc_var_id
                                AND doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
* 16 xx-x
        ELSE.
          LOOP AT i_signature WHERE doc_id EQ signature-doc_id
                                AND doc_ver_no EQ signature-doc_ver_no
                                AND doc_var_tg EQ signature-doc_var_tg.
            APPEND i_signature TO x_signature.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
    LOOP AT signature WHERE NOT prop_name IS INITIAL AND
                            NOT prop_value IS INITIAL AND
                                prop_name NE 'BDS_DESCRIPTION' AND
                                prop_name NE 'BDS_DOCUMENTTYPE'.
      LOOP AT i_attributes WHERE prop_name EQ signature-prop_name.
        MOVE i_attributes-x_unique TO unique.
        EXIT.
      ENDLOOP.
*      IF SIGNATURE-PROP_NAME NE 'BDS_KEYWORD'.
      IF unique EQ 'X'.
* general properties
*1. xxxx
        IF NOT signature-doc_id IS INITIAL AND
          NOT signature-doc_ver_no IS INITIAL AND
          NOT signature-doc_var_id IS INITIAL AND
          NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                   doc_id EQ signature-doc_id AND
                                  doc_ver_no EQ signature-doc_ver_no AND
                                  doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*2. ----
        ELSEIF signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE objid EQ ph_object-objid AND
                                       prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid.
              ENDIF.
            ENDAT.
          ENDLOOP.
*3. x---
        ELSEIF NOT signature-doc_id IS INITIAL AND
              signature-doc_ver_no IS INITIAL AND
              signature-doc_var_id IS INITIAL AND
              signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                         doc_id EQ signature-doc_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*4. -x--
        ELSEIF signature-doc_id IS INITIAL AND
          NOT signature-doc_ver_no IS INITIAL AND
              signature-doc_var_id IS INITIAL AND
              signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                         doc_ver_no EQ doc_ver_no.
              ENDIF.
            ENDAT.
          ENDLOOP.
*5. --x-
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_var_id EQ signature-doc_var_id
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                     doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*6. ---x
        ELSEIF    signature-doc_id IS INITIAL AND
                  signature-doc_ver_no IS INITIAL AND
                  signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                     doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*7. xx--
        ELSEIF NOT signature-doc_id IS INITIAL AND
             NOT signature-doc_ver_no IS INITIAL AND
                 signature-doc_var_id IS INITIAL AND
                 signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_ver_no
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                    doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_ver_no.
              ENDIF.
            ENDAT.
          ENDLOOP.
*8. x-x-
        ELSEIF NOT signature-doc_id IS INITIAL AND
                  signature-doc_ver_no IS INITIAL AND
              NOT signature-doc_var_id IS INITIAL AND
                  signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                         doc_id EQ signature-doc_id
                                 AND doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*9. -xx-
        ELSEIF     signature-doc_id IS INITIAL AND
              NOT signature-doc_ver_no IS INITIAL AND
              NOT signature-doc_var_id IS INITIAL AND
                  signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*10.x--x
        ELSEIF NOT signature-doc_id IS INITIAL AND
                  signature-doc_ver_no IS INITIAL AND
                  signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                    doc_id EQ signature-doc_id
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*11.--xx
        ELSEIF     signature-doc_id IS INITIAL AND
                  signature-doc_ver_no IS INITIAL AND
              NOT signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                     doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*12.-x-x
        ELSEIF     signature-doc_id IS INITIAL AND
              NOT signature-doc_ver_no IS INITIAL AND
                  signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*13.xxx-
        ELSEIF NOT signature-doc_id IS INITIAL AND
              NOT signature-doc_ver_no IS INITIAL AND
              NOT signature-doc_var_id IS INITIAL AND
                  signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                    doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*14.-xxx
        ELSEIF   signature-doc_id IS INITIAL AND
              NOT signature-doc_ver_no IS INITIAL AND
              NOT signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*15.x-xx
        ELSEIF NOT signature-doc_id IS INITIAL AND
                  signature-doc_ver_no IS INITIAL AND
              NOT signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                    doc_id EQ signature-doc_id
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*16.xx-x
        ELSEIF NOT signature-doc_id IS INITIAL AND
              NOT signature-doc_ver_no IS INITIAL AND
                  signature-doc_var_id IS INITIAL AND
              NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg
                                 AND objid EQ ph_object-objid
                                 AND prop_name EQ signature-prop_name
                                 AND prop_value EQ signature-prop_value.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                   doc_id EQ signature-doc_id
                                 AND doc_ver_no EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
        ENDIF.
* keyword
      ELSE.
*1. xxxx
        IF NOT signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
           NOT signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature WHERE prop_name EQ signature-prop_name
                                  AND prop_value EQ signature-prop_value
                                            AND objid EQ ph_object-objid
                                          AND doc_id EQ signature-doc_id
                                  AND doc_ver_no EQ signature-doc_ver_no
                                  AND doc_var_id EQ signature-doc_var_id
                                  AND doc_var_tg EQ signature-doc_var_tg.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                         doc_id EQ signature-doc_id AND
                                     doc_ver_no EQ signature-doc_ver_no
                                 AND doc_var_id EQ signature-doc_var_id
                                 AND doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*2. ----
        ELSEIF signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid.
              ENDIF.
            ENDAT.
          ENDLOOP.
*3. x---
        ELSEIF NOT signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_id EQ signature-doc_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*4. -x--
        ELSEIF signature-doc_id IS INITIAL AND
           NOT signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
               signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_ver_no EQ signature-doc_ver_no AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_ver_no EQ signature-doc_ver_no.
              ENDIF.
            ENDAT.
          ENDLOOP.
*5. --x-
        ELSEIF signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
            NOT signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_var_id EQ signature-doc_var_id AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                    doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*6. ---x
        ELSEIF signature-doc_id IS INITIAL AND
               signature-doc_ver_no IS INITIAL AND
               signature-doc_var_id IS INITIAL AND
           NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                   doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*7. xx--
        ELSEIF NOT signature-doc_id IS INITIAL AND
            NOT signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_id EQ signature-doc_id AND
                              doc_ver_no EQ signature-doc_ver_no.
              ENDIF.
            ENDAT.
          ENDLOOP.
*8. x-x-
        ELSEIF NOT signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
            NOT signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              doc_var_id EQ signature-doc_var_id AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_id EQ signature-doc_id AND
                              doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*9. -xx-
        ELSEIF signature-doc_id IS INITIAL AND
            NOT signature-doc_ver_no IS INITIAL AND
            NOT signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_id EQ signature-doc_var_id AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*10.x--x
        ELSEIF NOT signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
           NOT  signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                                    doc_id EQ signature-doc_id AND
                              doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*11.--xx
        ELSEIF signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
            NOT signature-doc_var_id IS INITIAL AND
            NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_var_id EQ signature-doc_var_id AND
                              doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_var_id EQ signature-doc_var_id AND
                              doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*12.-x-x
        ELSEIF signature-doc_id IS INITIAL AND
            NOT signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
            NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*13.xxx-
        ELSEIF NOT signature-doc_id IS INITIAL AND
            NOT signature-doc_ver_no IS INITIAL AND
            NOT signature-doc_var_id IS INITIAL AND
                signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_id EQ signature-doc_var_id AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_id EQ signature-doc_id AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_id EQ signature-doc_var_id.
              ENDIF.
            ENDAT.
          ENDLOOP.
*14.-xxx
        ELSEIF signature-doc_id IS INITIAL AND
           NOT  signature-doc_ver_no IS INITIAL AND
           NOT  signature-doc_var_id IS INITIAL AND
           NOT  signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_id EQ signature-doc_var_id AND
                              doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_id EQ signature-doc_var_id AND
                              doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*15.x-xx
        ELSEIF NOT signature-doc_id IS INITIAL AND
                signature-doc_ver_no IS INITIAL AND
            NOT signature-doc_var_id IS INITIAL AND
            NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              doc_var_id EQ signature-doc_var_id AND
                              doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
                EXIT.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_id EQ signature-doc_id AND
                              doc_var_id EQ signature-doc_var_id AND
                              doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
*16.xx-x
        ELSEIF NOT signature-doc_id IS INITIAL AND
            NOT signature-doc_ver_no IS INITIAL AND
                signature-doc_var_id IS INITIAL AND
            NOT signature-doc_var_tg IS INITIAL.
          LOOP AT x_signature.
            AT NEW objid.
              MOVE x_signature-objid TO ph_object-objid.
              LOOP AT x_signature
                        WHERE doc_id EQ signature-doc_id AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_tg EQ signature-doc_var_tg AND
                              prop_name EQ signature-prop_name AND
                              prop_value EQ signature-prop_value AND
                              objid EQ ph_object-objid.
              ENDLOOP.
              IF sy-subrc EQ 4.
                DELETE x_signature WHERE objid EQ ph_object-objid AND
                              doc_id EQ signature-doc_id AND
                              doc_ver_no EQ signature-doc_ver_no AND
                              doc_var_tg EQ signature-doc_var_tg.
              ENDIF.
            ENDAT.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDLOOP.
    LOOP AT infoobjects.
      MOVE: infoobjects-lo_objid TO lo_object-objid,
            infoobjects-lo_class TO lo_object-class.
      LOOP AT x_signature WHERE doc_id EQ lo_object
                            AND class EQ infoobjects-ph_class
                            AND objid EQ infoobjects-ph_objid.
      ENDLOOP.
      IF sy-subrc EQ 4.
        CLEAR infoobjects.
        MODIFY infoobjects.
      ENDIF.
    ENDLOOP.
    DELETE infoobjects WHERE lo_objid EQ space.
  ENDIF.

* sort infoobjects to get table i_signature sorted by doc_id:
  SORT infoobjects.

* set attributes, signature table and connections
  REFRESH: i_signature.
  LOOP AT infoobjects.
    count = sy-tabix.
    CLEAR: l_index_from, l_index_to.
    MOVE: count TO i_signature-doc_count,
          infoobjects-lo_class TO lo_object-class,
          infoobjects-lo_objid TO lo_object-objid,
          lo_object TO i_signature-doc_id,
          infoobjects-ph_class TO i_signature-class,
          infoobjects-ph_objid TO i_signature-objid.
* set signature: DOC_VER_NO, DOC_VAR_ID, DOC_VAR_TG
    LOOP AT is_pproperties INTO wa_pproperties
                           WHERE class EQ infoobjects-ph_class AND
                                 objid EQ infoobjects-ph_objid.
      l_index_to = sy-tabix.
      IF l_index_from IS INITIAL.
        l_index_from = l_index_to.
      ENDIF.
      CASE wa_pproperties-name.
        WHEN 'BDS_VERSION_NO'.
          MOVE wa_pproperties-value TO i_signature-doc_ver_no.
        WHEN 'BDS_VAR_ID'.
          MOVE wa_pproperties-value TO i_signature-doc_var_id.
        WHEN 'BDS_VAR_TAG'.
          MOVE wa_pproperties-value TO i_signature-doc_var_tg.
        WHEN OTHERS.
          " nothing to do.
      ENDCASE.
    ENDLOOP.
* set loio attributes
    LOOP AT is_lproperties INTO wa_lproperties
                           WHERE class EQ infoobjects-lo_class AND
                                 objid EQ infoobjects-lo_objid.
      IF wa_lproperties-name NE 'DESCRIPTION' AND
         NOT wa_lproperties-value IS INITIAL.
        MOVE: wa_lproperties-value TO i_signature-prop_value,
              wa_lproperties-name TO i_signature-prop_name.
        APPEND i_signature.
      ENDIF.
    ENDLOOP.
* set phio attributes
    IF NOT l_index_from IS INITIAL.
      LOOP AT is_pproperties INTO wa_pproperties FROM l_index_from
                                                 TO l_index_to.
        IF wa_pproperties-name NE 'BDS_VERSION_NO' AND
           wa_pproperties-name NE 'BDS_VAR_ID' AND
           wa_pproperties-name NE 'BDS_VAR_TAG' AND
           NOT wa_pproperties-value IS INITIAL.
          MOVE: wa_pproperties-value TO i_signature-prop_value,
                wa_pproperties-name TO i_signature-prop_name.
          APPEND i_signature.
          IF i_signature-prop_name = 'CREATED_AT'.
            APPEND i_signature TO ver_signature.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

* set connections

  LOOP AT i_bds_connections.
    READ TABLE i_signature WITH KEY doc_id = i_bds_connections-doc_id
               BINARY SEARCH. "i_signature is sorted by doc_id
    IF sy-subrc EQ 0.
      MOVE-CORRESPONDING i_bds_connections TO connections.
      APPEND connections.
    ENDIF.
  ENDLOOP.

* set signature

  REFRESH signature.
  CLEAR: old_doc_id,
         count.
* correction of signature

* Keep only the youngest PHIO per LOIO, version and variant
* (duplicates can occur when version are imported and locally
* created). To prepare this, use table ver_signature to find those
* PHIOs that have to be removed from table i_signature.
  DATA: l_previous_signature LIKE LINE OF ver_signature.
  SORT ver_signature BY doc_id doc_ver_no doc_var_id
                        prop_value DESCENDING.
  LOOP AT ver_signature.
    IF l_previous_signature-doc_id     = ver_signature-doc_id AND
       l_previous_signature-doc_ver_no = ver_signature-doc_ver_no AND
       l_previous_signature-doc_var_id = ver_signature-doc_var_id.
      READ TABLE i_signature WITH KEY doc_id = ver_signature-doc_id
                 BINARY SEARCH. "i_signature is sorted by doc_id
      IF sy-subrc = 0.
        l_index_from = sy-tabix.
        LOOP AT i_signature FROM l_index_from.
          IF i_signature-doc_count = ver_signature-doc_count AND
             i_signature-doc_id = ver_signature-doc_id AND
             i_signature-doc_ver_no = ver_signature-doc_ver_no AND
             i_signature-doc_var_id = ver_signature-doc_var_id.
            DELETE i_signature.
          ENDIF.
          IF i_signature-doc_id NE ver_signature-doc_id.
            EXIT. "loop
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
    l_previous_signature = ver_signature.
  ENDLOOP.

  IF all NE 'X'.
    REFRESH infoobjects.
    SORT i_signature BY doc_id doc_ver_no DESCENDING
                              doc_var_id DESCENDING.
* set signature
    DATA: l_x_new_doc_count LIKE sy-datar.
    LOOP AT i_signature.
      AT NEW doc_count.
        l_x_new_doc_count = 'X'.
      ENDAT.
      IF NOT l_x_new_doc_count IS INITIAL.
        CLEAR l_x_new_doc_count.
        CLEAR lo_object.
        MOVE: i_signature-doc_count TO doc_count,
              i_signature-doc_id TO doc_id.
        IF doc_id NE old_doc_id.
          lo_object = i_signature-doc_id.
          MOVE: lo_object-class TO infoobjects-lo_class,
                lo_object-objid TO infoobjects-lo_objid,
                i_signature-objid TO infoobjects-ph_objid,
                i_signature-class TO infoobjects-ph_class.
          APPEND infoobjects.
          MOVE doc_id TO old_doc_id.
        ENDIF.
      ENDIF.
      IF NOT lo_object IS INITIAL.
        MOVE-CORRESPONDING i_signature TO signature.
        APPEND signature.
      ENDIF.
    ENDLOOP.

    DATA: previous_doc_count LIKE signature-doc_count.
    CLEAR: previous_doc_count, count.
    LOOP AT signature.
      IF previous_doc_count NE signature-doc_count.
        count = count + 1.
        previous_doc_count = signature-doc_count.
      ENDIF.
      IF signature-doc_count NE count.
        signature-doc_count = count.
        MODIFY signature TRANSPORTING doc_count.
      ENDIF.
    ENDLOOP.

  ELSE.
    REFRESH infoobjects.
    LOOP AT i_signature.
      MOVE-CORRESPONDING i_signature TO signature.
      APPEND signature.
      MOVE: i_signature-objid TO infoobjects-ph_objid,
            i_signature-class TO infoobjects-ph_class.
      MOVE: i_signature-doc_id TO lo_object,
            lo_object-class TO infoobjects-lo_class,
            lo_object-objid TO infoobjects-lo_objid.
      AT NEW doc_count.
        APPEND infoobjects.
      ENDAT.
    ENDLOOP.

* There might be gaps in the doc_count values used, when
* multiple (internal) versions with the same triple (vers_id,
* var_id, var_tag) were reduced to a single one using
* the CREATED_AT property, so let´s assign new doc_count values.
    CLEAR: previous_doc_count, count.
    LOOP AT signature.
      IF previous_doc_count NE signature-doc_count.
        count = count + 1.
        previous_doc_count = signature-doc_count.
      ENDIF.
      IF signature-doc_count NE count.
        signature-doc_count = count.
        MODIFY signature TRANSPORTING doc_count.
      ENDIF.
    ENDLOOP.

  ENDIF.

  DESCRIBE TABLE signature LINES count_signature.
  IF count_signature EQ 0.
    MESSAGE w001 RAISING nothing_found.
  ENDIF.





ENDFUNCTION.
