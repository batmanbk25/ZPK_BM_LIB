FUNCTION ZFM_BDS_PHIO_CREATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(LOGICAL_SYSTEM) LIKE  BDS_CONN00-LOG_SYSTEM OPTIONAL
*"     VALUE(CLASSNAME) LIKE  BDS_CONN00-CLASSNAME
*"     VALUE(CLASSTYPE) LIKE  BDS_CONN00-CLASSTYPE
*"     VALUE(CLIENT) LIKE  BAPIBDS01-CLIENT DEFAULT SY-MANDT
*"  EXPORTING
*"     VALUE(PH_OBJECT) LIKE  SDOKOBJECT STRUCTURE  SDOKOBJECT
*"  TABLES
*"      PROPERTIES STRUCTURE  SDOKPROPTY OPTIONAL
*"      FROM_RELATIONS STRUCTURE  SDOKRELIST OPTIONAL
*"      TO_RELATIONS STRUCTURE  SDOKRELIST OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"      PARAMETER_ERROR
*"      NOT_ALLOWED
*"      ERROR_KPRO
*"      INTERNAL_ERROR
*"      NOT_AUTHORIZED
*"--------------------------------------------------------------------
**************************** data declaration **************************

  DATA: i_documenttype LIKE toadv-ar_object,
        i_itab_toaom LIKE toaom OCCURS 1 WITH HEADER LINE,
        i_itab_bds_cl_doc LIKE bds_cl_doc OCCURS 1 WITH HEADER LINE,
        ptimestamp TYPE timestamp,
        BEGIN OF timestamp,
              date TYPE d,
              time TYPE t,
        END OF timestamp.

**************************** initialization ****************************

  CLEAR: i_documenttype,
         ptimestamp,
         timestamp.

  REFRESH: i_itab_toaom,
           i_itab_bds_cl_doc.

************************** program *************************************

  IF classname NE space.
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
*             lo_class       =
              ph_class       = ph_object-class
         EXCEPTIONS
            nothing_found     = 1
            parameter_error   = 2
            not_allowed       = 3
            error_kpro        = 4
            internal_error    = 5
            not_authorized    = 6
            OTHERS            = 9
            .
    IF sy-subrc NE 0.
      PERFORM internal_eh(saplbds_bapi)
                          USING sy-subrc sy-msgid sy-msgty sy-msgno
                                sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    LOOP AT properties WHERE name EQ 'BDS_DOCUMENTTYPE'.
      MOVE properties-value TO i_documenttype.
      EXIT.
    ENDLOOP.
    DELETE properties WHERE name EQ 'BDS_DOCUMENTTYPE'.
* get expirytime
    CALL FUNCTION 'BDS_METAINFO_GET'
          EXPORTING
              classname       = classname
              classtype       = classtype
*         LOGSYS        =
              documenttype  = i_documenttype
              activeflag    = 'X'
         TABLES
            itab_toaom      = i_itab_toaom
            itab_bds_cl_doc = i_itab_bds_cl_doc
         EXCEPTIONS
              nothing_found = 1
              OTHERS        = 2
              .
    IF sy-subrc <> 0.
      "nothing to do
    ELSE.
      "expiry time already set?
      READ TABLE properties WITH KEY name = 'EXPIRY_TIME'
                            TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        READ TABLE i_itab_toaom INDEX 1.
        IF i_itab_toaom-expiry_tim NE space.
          GET TIME STAMP FIELD ptimestamp.
          MOVE ptimestamp TO timestamp.
          PERFORM find_del_date(oaall) USING timestamp-date
                        i_itab_toaom-expiry_tim timestamp-date.
          MOVE: timestamp TO properties-value,
                'EXPIRY_TIME' TO properties-name.
          APPEND properties.
        ENDIF.
      ENDIF.
      READ TABLE i_itab_bds_cl_doc INDEX 1.
      IF i_itab_bds_cl_doc-cont_categ NE space.
        MOVE: 'STORAGE_CATEGORY' TO properties-name,
              i_itab_bds_cl_doc-cont_categ TO properties-value.
        APPEND properties.
      ENDIF.
    ENDIF.
  ELSE.
    ph_object-class = 'BDS_POC1'.
  ENDIF.
  CALL FUNCTION 'SDOK_PHIO_CREATE'
       EXPORTING
          object_class        = ph_object-class
*         OBJECT_UNIQUE_ID    =
          client              = client
     IMPORTING
           object_id           = ph_object
       TABLES
            properties          = properties
            from_relations      = from_relations
            to_relations        = to_relations
       EXCEPTIONS
            missing_class       = 19
            bad_class           = 10
            missing_properties  = 11
            bad_relations       = 13
            bad_properties      = 12
            not_authorized      = 6
            duplicate_object_id = 14
            OTHERS              = 49
            .
  IF sy-subrc NE 0.
    PERFORM kpro_eh_3(saplbds_bapi)
                      USING sy-subrc sy-msgid sy-msgty sy-msgno
                              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.





ENDFUNCTION.
