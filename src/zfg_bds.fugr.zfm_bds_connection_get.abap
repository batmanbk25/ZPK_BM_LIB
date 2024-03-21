FUNCTION ZFM_BDS_CONNECTION_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BAPIBDS01-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BAPIBDS01-CLASSNAME OPTIONAL
*"     VALUE(CLASSTYPE) LIKE  BAPIBDS01-CLASSTYPE OPTIONAL
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"     VALUE(OBJECT_KEY) LIKE  BAPIBDS01-OBJKEY DEFAULT '%'
*"  TABLES
*"      BDS_CONNECTIONS STRUCTURE  BAPICONNEC OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
************************** data declaration ****************************

  DATA: i_tabname LIKE dcobjdef-name,
        lines TYPE p,
        lo_object LIKE sdokobject.

 DATA: cl_connection LIKE bds_conn00 OCCURS 1 WITH HEADER LINE,"7 fields
           ncl_connection LIKE bds_conn01 OCCURS 1 WITH HEADER LINE,"6 "
            i_x031l_tab LIKE x031l OCCURS 1 WITH HEADER LINE,
            i_document_classes LIKE bds_locl OCCURS 1 WITH HEADER LINE,
            BEGIN OF tabnames OCCURS 1,
            tabname LIKE bds_locl-tabname,
            END OF tabnames.

************************** initialization ******************************

  CLEAR: i_tabname,
         lines,
         lo_object.

  REFRESH: cl_connection,
           ncl_connection,
           i_x031l_tab,
           bds_connections,
           i_document_classes.

************************** program *************************************

* check client
  IF client IS INITIAL.
    MOVE sy-mandt TO client.
  ENDIF.

  TRANSLATE object_key USING '*%'.


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
            tabname          = i_tabname
       TABLES
            document_classes = i_document_classes
       EXCEPTIONS
            nothing_found    = 1
            parameter_error  = 2
            not_allowed      = 3
            error_kpro       = 4
            internal_error   = 5
            not_authorized   = 6
            OTHERS           = 9.
  IF sy-subrc NE 0.
    PERFORM internal_eh(saplbds_bapi)
                        USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  LOOP AT i_document_classes.
    MOVE i_document_classes-tabname TO tabnames-tabname.
    APPEND tabnames.
  ENDLOOP.
  SORT tabnames BY tabname.
  LOOP AT tabnames.
    AT NEW tabname.
      MOVE tabnames-tabname TO i_tabname.
      REFRESH: cl_connection, ncl_connection.
      CALL FUNCTION 'DDIF_NAMETAB_GET'
           EXPORTING
                tabname     = i_tabname
*         ALL_TYPES   = ' '
*    IMPORTING
*         X030L_WA    =
*         DTELINFO_WA =
*         TTYPINFO_WA =
*         DDOBJTYPE   =
           TABLES
                x031l_tab   = i_x031l_tab
*         DFIES_TAB   =
           EXCEPTIONS
                not_found   = 1
                OTHERS      = 2
                .
      DESCRIBE TABLE i_x031l_tab LINES lines.
      IF logical_system EQ space.
        CASE lines.
          WHEN 6.
            IF object_key CO '% '.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classname EQ classname
                                          AND classtype EQ classtype.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classname EQ classname.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classtype EQ classtype.
              ENDIF.
            ELSEIF object_key CS '%'.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classname EQ classname
                                          AND classtype EQ classtype
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                       WHERE object_key LIKE object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classname EQ classname
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classtype EQ classtype
                                         AND object_key LIKE object_key.
              ENDIF.
            ELSE.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classname EQ classname
                                          AND classtype EQ classtype
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE object_key EQ object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classname EQ classname
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                         WHERE classtype EQ classtype
                                          AND object_key EQ object_key.
              ENDIF.
            ENDIF.
          WHEN 7.
            IF object_key CO '% '.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classname EQ classname
                                          AND classtype EQ classtype
                                          AND client EQ client.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE client EQ client.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classname EQ classname
                                          AND client EQ client.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classtype EQ classtype
                                          AND client EQ client.
              ENDIF.
            ELSEIF object_key CS '%'.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classname EQ classname
                                          AND classtype EQ classtype
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE client EQ client
                                         AND object_key LIKE object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classname EQ classname
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classtype EQ classtype
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ENDIF.
            ELSE.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classname EQ classname
                                          AND classtype EQ classtype
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE client EQ client
                                          AND object_key EQ object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classname EQ classname
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                         WHERE classtype EQ classtype
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ENDIF.
            ENDIF.
          WHEN OTHERS.
            MESSAGE w001 RAISING nothing_found.
        ENDCASE.
      ELSE.
        CASE lines.
          WHEN 6.
            IF object_key CO '% '.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND classtype EQ classtype.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classtype EQ classtype.
              ENDIF.
            ELSEIF object_key CS '%'.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND classtype EQ classtype
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                         AND object_key LIKE object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classtype EQ classtype
                                         AND object_key LIKE object_key.
              ENDIF.
            ELSE.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND classtype EQ classtype
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND object_key EQ object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) INTO TABLE ncl_connection
                                     WHERE log_system EQ logical_system
                                          AND classtype EQ classtype
                                          AND object_key EQ object_key.
              ENDIF.
            ENDIF.
          WHEN 7.
            IF object_key CO '% '.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND classtype EQ classtype
                                          AND client EQ client.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND client EQ client.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND client EQ client.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classtype EQ classtype
                                          AND client EQ client.
              ENDIF.
            ELSEIF object_key CS '%'.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND classtype EQ classtype
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classtype EQ classtype
                                          AND client EQ client
                                         AND object_key LIKE object_key.
              ENDIF.
            ELSE.
              IF classname NE space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND classtype EQ classtype
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ELSEIF classname NE space AND classtype EQ space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classname EQ classname
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ELSEIF classname EQ space AND classtype NE space.
                SELECT * FROM (i_tabname) CLIENT SPECIFIED
                                          INTO TABLE cl_connection
                                     WHERE log_system EQ logical_system
                                          AND classtype EQ classtype
                                          AND client EQ client
                                          AND object_key EQ object_key.
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDIF.
      LOOP AT cl_connection.
        MOVE: cl_connection-loio_id TO lo_object-objid,
              cl_connection-loio_class TO lo_object-class,
              lo_object TO bds_connections-doc_id,
             cl_connection-classname TO bds_connections-classname,
             cl_connection-classtype TO bds_connections-classtype,
              cl_connection-object_key TO bds_connections-object_key.
        APPEND bds_connections.
      ENDLOOP.
      LOOP AT ncl_connection.
        MOVE: ncl_connection-loio_id TO lo_object-objid,
              ncl_connection-loio_class TO lo_object-class,
              lo_object TO bds_connections-doc_id,
              ncl_connection-classname TO bds_connections-classname,
              ncl_connection-classtype TO bds_connections-classtype,
              ncl_connection-object_key TO bds_connections-object_key.
        APPEND bds_connections.
      ENDLOOP.
    ENDAT.
  ENDLOOP.
  DESCRIBE TABLE bds_connections LINES lines.
  IF lines LE 0.
    MESSAGE w001 RAISING nothing_found.
  ENDIF.





ENDFUNCTION.
