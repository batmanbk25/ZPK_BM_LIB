class ZCL_BDS_DOCUMENT_SET definition
  public
  final
  create public .

public section.

  class-methods ASSIGN
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY
      !DOC_ID type SBDST_DOC_ID
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_ALLOWED
      NOT_AUTHORIZED
      PARAMETER_ERROR .
  class-methods COPY
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !NEW_CLASSNAME type SBDST_CLASSNAME
      !NEW_CLASSTYPE type SBDST_CLASSTYPE
      !NEW_CLIENT type SBDST_CLIENT optional
      !NEW_OBJECT_KEY type SBDST_OBJECT_KEY optional
    exporting
      !NEW_OBJECT_KEY_EXPORT type SBDST_OBJECT_KEY
      !NEW_DOC_ID type SBDST_DOC_ID
      !NEW_DOC_VER_NO type SBDST_DOC_VER_NO
      !NEW_DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      value(PROPERTIES) type SBDST_PROPERTIES optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_ALLOWED
      NOT_AUTHORIZED
      PARAMETER_ERROR .
  class-methods DELETE_PROPERTIES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !PROPERTIES type SBDST_DPROPERTIES
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CHANGE_PROPERTIES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CALL_NAVIGATOR
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !DISPLAY_SINGLE_DOC type BDS_X optional
      !DISPLAY_DOC type BDN_CON optional
    changing
      !OBJKEY type SBDST_OBJECT_KEY optional
      !SIGNATURE type SBDST_SIGNATURE optional
      !EXCLUDING type SBDST_EXCLUDING optional
      !FIXED_ATTRIBUTES type SBDST_PROPERTIES optional
    exceptions
      PARAMETER_ERROR
      INTERNAL_ERROR
      NOTHING_FOUND
      ERROR_KPRO
      NOT_ALLOWED
      NOT_AUTHORIZED .
  class-methods CREATE_VARIANT_WITH_FILES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !NEW_DOC_VAR_TG type SBDST_DOC_VAR_TG
    exporting
      !NEW_DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !FILES type SBDST_FILES
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_ALLOWED
      PARAMETER_ERROR
      NOTHING_FOUND
      NOT_AUTHORIZED .
  class-methods CREATE_VARIANT_WITH_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !NEW_DOC_VAR_TG type SBDST_DOC_VAR_TG
    exporting
      !NEW_DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !URIS type SBDST_URI
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_VERSION_WITH_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    exporting
      !NEW_DOC_VER_NO type SBDST_DOC_VER_NO
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !URIS type SBDST_URI
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_VERSION_WITH_FILES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE optional
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    exporting
      !NEW_DOC_VER_NO type SBDST_DOC_VER_NO
    changing
      !FILES type SBDST_FILES
      !PROPERTIES type SBDST_PROPERTIES optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods DELETE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !X_FORCE_DELETE type SBDST_X optional
    changing
      !SIGNATURE type SBDST_SIGNATURE
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods UPDATE_WITH_FILES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !X_FORCE_UPDATE type SBDST_X optional
    changing
      !FILES type SBDST_FILES
      !SIGNATURE type SBDST_SIGNATURE optional
      !PROPERTIES type SBDST_PROPERTIES optional
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_ALLOWED
      PARAMETER_ERROR
      NOT_AUTHORIZED .
  class-methods GET_WITH_COMP_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !URL_LIFETIME type SBDST_URL_LIFETIME optional
    exporting
      !URIS type SBDST_URI
      !SIGNATURE type SBDST_SIGNATURE
      !COMPONENTS type SBDST_COMPONENTS
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_WITH_OWN_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !URL type SBDST_URL
      !URL_LIFETIME type SBDST_URL_LIFETIME optional
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_WITH_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !URL_LIFETIME type SBDST_URL_LIFETIME optional
      !SELECTED_INDEX type INT2 optional
    changing
      !URIS type SBDST_URI
      !SIGNATURE type SBDST_SIGNATURE optional
      !COMPONENTS type SBDST_COMPONENTS optional
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_FAST_INFO
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLIENT type SBDST_CLIENT default sy-mandt
      !GET_PROPERTIES type SBDST_X default 'X'
    exporting
      !SIGNATURE type SBDST_SIGNATURE
    changing
      !CONNECTIONS type SBDST_CONNECTIONS
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_INFO
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !CHECK_STATE type BAPIBDS01-X default ' '
    exporting
      !CONNECTIONS type SBDST_CONNECTIONS
      !EXTENDED_COMPONENTS type SBDST_COMPONENTS2
    changing
      !COMPONENTS type SBDST_COMPONENTS optional
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods CREATE_WITH_OWN_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT default sy-mandt
      !URL type SBDST_URL
      !MIMETYPE type SBDST_MIMETYPE
      !BINARY_FLAG type SBDST_X default 'X'
    exporting
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !PROPERTIES type SBDST_PROPERTIES optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_WITH_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
    changing
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !URIS type SBDST_URI optional
      !COMPONENTS type SBDST_COMPONENTS optional
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods GET_WITH_AS_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !TEXT_AS_STREAM type SBDST_BINARY_FLAG default 'X'
    changing
      !ASCII_CONTENT type SBDST_ASCII_CONTENT
      !SIGNATURE type SBDST_SIGNATURE optional
      !COMPONENTS type SBDST_COMPONENTS optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NO_CONTENT
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_WITH_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
    changing
      !CONTENT type SBDST_CONTENT
      !SIGNATURE type SBDST_SIGNATURE optional
      !COMPONENTS type SBDST_COMPONENTS optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NO_CONTENT
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods CREATE_WITH_FILES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
    changing
      !FILES type SBDST_FILES
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !SIGNATURE type SBDST_SIGNATURE
    exceptions
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_ALLOWED
      NOT_AUTHORIZED
      NOTHING_FOUND .
  class-methods CREATE_WITH_AS_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !COMPONENTS type SBDST_COMPONENTS
      !ASCII_CONTENT type SBDST_ASCII_CONTENT
    changing
      value(OBJECT_KEY) type SBDST_OBJECT_KEY optional
      value(SIGNATURE) type SBDST_SIGNATURE
    exceptions
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED
      NOTHING_FOUND .
  class-methods CREATE_WITH_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !COMPONENTS type SBDST_COMPONENTS
      !CONTENT type SBDST_CONTENT
    changing
      value(OBJECT_KEY) type SBDST_OBJECT_KEY optional
      value(SIGNATURE) type SBDST_SIGNATURE
    exceptions
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED
      NOTHING_FOUND .
  class-methods UPDATE_WITH_AS_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !X_FORCE_UPDATE type SBDST_X optional
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !ASCII_CONTENT type SBDST_ASCII_CONTENT
      !SIGNATURE type SBDST_SIGNATURE optional
      !PROPERTIES type SBDST_PROPERTIES optional
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods UPDATE_WITH_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !X_FORCE_UPDATE type SBDST_X optional
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !CONTENT type SBDST_CONTENT
      !SIGNATURE type SBDST_SIGNATURE optional
      !PROPERTIES type SBDST_PROPERTIES optional
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods CONFIRM_CREATE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !X_FORCE_CONFIRM type SBDST_X optional
    changing
      !COMPONENTS type SBDST_COMPONENTS optional
      !SIGNATURE type SBDST_SIGNATURE optional
      !URIS type SBDST_URI optional
      !CONTENT type SBDST_CONTENT optional
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      ERROR_DP
      INTERNAL_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_RELATION
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !RELATIONS type SBDST_RELATIONS
      !SIGNATURE type SBDST_SIGNATURE
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_ALLOWED
      NOT_AUTHORIZED .
  class-methods GET_WITH_FILES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
    changing
      !FILES type SBDST_FILES
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods UPDATE_WITH_URL
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !X_FORCE_UPDATE type SBDST_X optional
    exporting
      !NEW_STOR_CAT type SDOKPHIO-STOR_CAT
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !URIS type SBDST_URI
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_ALLOWED
      PARAMETER_ERROR
      NOT_AUTHORIZED .
  class-methods QUERY_DOCUMENTS
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !QUERY type SBDST_QUERY
    changing
      !COMPONENTS type SBDST_COMPONENTS optional
      !CONNECTIONS type SBDST_CONNECTIONS optional
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods QUERY_RELATIONS
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID optional
      !DOC_VER_NO type SBDST_DOC_VER_NO optional
      !DOC_VAR_ID type SBDST_DOC_VAR_ID optional
      !QUERY type SBDST_QUERY
    changing
      !RELATIONS type SBDST_SRELATIONS optional
      !PROPERTIES type SBDST_LPROPERTIES optional
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_RELATIONS
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !NO_PROPERTIES type SBDST_X optional
    exporting
      !PROPERTIES type SBDST_LPROPERTIES
    changing
      !RELATIONS type SBDST_RELATIONS optional
      !SIGNATURE type SBDST_SIGNATURE optional
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods DELETE_RELATIONS
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
    changing
      !RELATIONS type SBDST_RELATIONS
    exceptions
      NOTHING_FOUND
      NOT_ALLOWED
      NOT_AUTHORIZED
      ERROR_KPRO
      INTERNAL_ERROR
      PARAMETER_ERROR .
  class-methods GET_COMPONENT_PROPERTIES
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    exporting
      !EXTENDED_COMPONENTS type SBDST_COMPONENTS3
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_VARIANT_WITH_AS_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !NEW_DOC_VAR_TG type SBDST_DOC_VAR_TG
    exporting
      !NEW_DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !ASCII_CONTENT type SBDST_ASCII_CONTENT
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_VARIANT_WITH_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !NEW_DOC_VAR_TG type SBDST_DOC_VAR_TG
    exporting
      !NEW_DOC_VAR_ID type SBDST_DOC_VAR_ID
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !CONTENT type SBDST_CONTENT
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods CREATE_VERSION_WITH_AS_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    exporting
      !NEW_DOC_VER_NO type SBDST_DOC_VER_NO
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !ASCII_CONTENT type SBDST_ASCII_CONTENT
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods CREATE_VERSION_WITH_TABLE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
    exporting
      !NEW_DOC_VER_NO type SBDST_DOC_VER_NO
    changing
      !COMPONENTS type SBDST_COMPONENTS
      !CONTENT type SBDST_CONTENT
      !PROPERTIES type SBDST_PROPERTIES
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods GET_TRANSPORT_INFOS
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
    changing
      !SIGNATURE type SBDST_SIGNATURE optional
      !COMMFILE_ENTRIES type SBDST_COMMFILE_ENTRIES
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_ALLOWED
      NOT_AUTHORIZED
      PARAMETER_ERROR .
  class-methods GET_INFO_NEWEST_ONLY
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !CHECK_STATE type BAPIBDS01-X default ' '
    exporting
      !CONNECTIONS type SBDST_CONNECTIONS
    changing
      !COMPONENTS type SBDST_COMPONENTS optional
      !SIGNATURE type SBDST_SIGNATURE
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_ALLOWED
      NOT_AUTHORIZED
      PARAMETER_ERROR .
  class-methods CONFIRM_UPDATE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !OBJECT_KEY type SBDST_OBJECT_KEY optional
      !X_FORCE_CONFIRM type SBDST_X optional
      !NEW_STOR_CAT type SDOKPHIO-STOR_CAT optional
    changing
      !COMPONENTS type SBDST_COMPONENTS optional
      !SIGNATURE type SBDST_SIGNATURE optional
      !URIS type SBDST_URI optional
      !CONTENT type SBDST_CONTENT optional
      !PROPERTIES type SBDST_PROPERTIES optional
    exceptions
      NOTHING_FOUND
      ERROR_KPRO
      ERROR_DP
      INTERNAL_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED
      PARAMETER_ERROR .
  class-methods DOCUMENT_DEQUEUE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !OBJECT_KEY type SBDST_OBJECT_KEY
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED .
  class-methods DOCUMENT_ENQUEUE
    importing
      !LOGICAL_SYSTEM type SBDST_LOGICAL_SYSTEM optional
      !CLASSNAME type SBDST_CLASSNAME
      !CLASSTYPE type SBDST_CLASSTYPE
      !CLIENT type SBDST_CLIENT optional
      !DOC_ID type SBDST_DOC_ID
      !DOC_VER_NO type SBDST_DOC_VER_NO
      !DOC_VAR_ID type SBDST_DOC_VAR_ID
      !OBJECT_KEY type SBDST_OBJECT_KEY
    exceptions
      NOTHING_FOUND
      INTERNAL_ERROR
      ERROR_KPRO
      PARAMETER_ERROR
      NOT_AUTHORIZED
      NOT_ALLOWED
      FOREIGN_LOCK .
protected section.
private section.

  types TY_FUNCNAME type BAPIBDS01-FUNCNAME .
  types TY_LOG_LEVEL type BAPIBDS01-LOG_LEVEL .

  class-methods ERROR_HANDLING
    importing
      !SY_SUBRC like SY-SUBRC
      !SY_MSGID like SY-MSGID
      !SY_MSGTY like SY-MSGTY
      !SY_MSGNO like SY-MSGNO
      !SY_MSGV1 like SY-MSGV1
      !SY_MSGV2 like SY-MSGV2
      !SY_MSGV3 like SY-MSGV3
      !SY_MSGV4 like SY-MSGV4
    exceptions
      ERROR_KPRO
      INTERNAL_ERROR
      NOTHING_FOUND
      NOT_ALLOWED
      NOT_AUTHORIZED
      PARAMETER_ERROR .
ENDCLASS.



CLASS ZCL_BDS_DOCUMENT_SET IMPLEMENTATION.


METHOD ASSIGN.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'assign'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
*             doc_ver_no       = doc_ver_no
*             doc_var_id       = doc_var_id
*             new_classname    = new_classname
*             new_classtype    = new_classtype
*             new_client       = new_client
*             new_object_key   = new_object_key
*             new_doc_id       = new_doc_id
*             new_doc_ver_no   = new_doc_ver_no
*             new_doc_var_id   = new_doc_var_id
*          NEW_VAR_TG       =
         IMPORTING
              exit             = i_exit
*    TABLES
*         COMPONENTS       =
*         SIGNATURE        =
*         CONTENT          =
*         URIS             =
*         RELATIONS        =
*         DPROPERTIES      =
*         PROPERTIES       =
*         COMMFILE_ENTRIES =
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_DOCUMENT_ASSIGN'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      WHEN 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '1' OR i_log_level EQ
             '2' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'assign'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  NEW_VAR_TG     =
                   exit_funcname  = i_funcname.
*              TABLES
*                   signature      =
*                   relations      =
*                   dproperties    =
*                   properties     = properties
          .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CALL_NAVIGATOR.
  CALL FUNCTION 'BDS_CALL_NAVIGATOR'
       EXPORTING
            LOGICAL_SYSTEM     = LOGICAL_SYSTEM
            CLASSNAME          = CLASSNAME
            CLASSTYPE          = CLASSTYPE
            OBJKEY             = OBJKEY
            CLIENT             = CLIENT
            DISPLAY_SINGLE_DOC = DISPLAY_SINGLE_DOC
            DISPLAY_DOC        = DISPLAY_DOC
       TABLES
            SIGNATURE          = SIGNATURE
            EXCLUDING          = EXCLUDING
            FIXED_ATTRIBUTES   = FIXED_ATTRIBUTES
       EXCEPTIONS
            INTERNAL_ERROR     = 1
            OTHERS             = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
  ENDIF.
ENDMETHOD.


METHOD CHANGE_PROPERTIES.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

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
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'change_properties'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.

**********************************************************************
* TuanBA Edit START
**********************************************************************
*    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CHANGE_P'
    CALL FUNCTION 'ZFM_BDS_BUSDOC_CHANGE_P'
**********************************************************************
* TuanBA Edit END
**********************************************************************
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         TABLES
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      WHEN 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '2' OR i_log_level EQ
             '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'change_properties'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                      NEW_VAR_TG     =
                   exit_funcname  = i_funcname
               TABLES
*                       signature      =
*                       relations      =
*                       dproperties    =
                    properties     = properties
                    .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CONFIRM_CREATE .

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'confirm_create'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
              COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
              CONTENT          = CONTENT
              URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CONFIRM'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              X_FORCE_CONFIRM = X_FORCE_CONFIRM
         TABLES
              COMPONENTS      = COMPONENTS
              SIGNATURE       = SIGNATURE
              URIS            = URIS
              CONTENT         = CONTENT
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              ERROR_KPRO      = 4
              INTERNAL_ERROR  = 5
              NOT_AUTHORIZED  = 6
              ERROR_DP        = 12
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF ( i_log_level EQ '3' or i_log_level eq '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'confirm_create'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CONFIRM_UPDATE .

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'confirm_update'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
              COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
              CONTENT          = CONTENT
              URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CONFIRM'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              TYPE            = 'UPDATE'
              X_FORCE_CONFIRM = X_FORCE_CONFIRM
              NEW_STOR_CAT    = NEW_STOR_CAT
         TABLES
              COMPONENTS      = COMPONENTS
              SIGNATURE       = SIGNATURE
              URIS            = URIS
              CONTENT         = CONTENT
              PROPERTIES      = PROPERTIES
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              ERROR_KPRO      = 4
              INTERNAL_ERROR  = 5
              NOT_AUTHORIZED  = 6
              ERROR_DP        = 12
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF ( i_log_level EQ '2' OR i_log_level EQ
             '3' or i_log_level eq '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'confirm_update'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD COPY.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'copy'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
              new_classname    = new_classname
              new_classtype    = new_classtype
              new_client       = new_client
              new_object_key   = new_object_key
              new_doc_id       = new_doc_id
              new_doc_ver_no   = new_doc_ver_no
              new_doc_var_id   = new_doc_var_id
*          NEW_VAR_TG       =
         IMPORTING
              exit             = i_exit
*    TABLES
*         COMPONENTS       =
*         SIGNATURE        =
*         CONTENT          =
*         URIS             =
*         RELATIONS        =
*         DPROPERTIES      =
*         PROPERTIES       =
*         COMMFILE_ENTRIES =
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_COPY'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              new_classname   = new_classname
              new_classtype   = new_classtype
              new_client      = new_client
              new_object_key  = new_object_key
         IMPORTING
              new_doc_id      = new_doc_id
              new_doc_ver_no  = new_doc_ver_no
              new_doc_var_id  = new_doc_var_id
              new_object_key  = new_object_key_export
         TABLES
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '1' OR i_log_level EQ
             '2' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'copy'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
                   new_classname  = new_classname
                   new_classtype  = new_classtype
                   new_client     = new_client
                   new_object_key = new_object_key
*                      NEW_VAR_TG     =
                   exit_funcname  = i_funcname
               TABLES
*                       signature      =
*                       relations      =
*                       dproperties    =
                    properties     = properties
                    .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_RELATION.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'create_relation'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
              DOC_ID           = DOC_ID
              DOC_VER_NO       = DOC_VER_NO
              DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
*             COMPONENTS       = COMPONENTS
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
              RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CREA_RELA'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              DOC_ID          = DOC_ID
              DOC_VER_NO      = DOC_VER_NO
              DOC_VAR_ID      = DOC_VAR_ID
         TABLES
              RELATIONS       = RELATIONS
              SIGNATURE       = SIGNATURE
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF ( i_log_level EQ '3' or i_log_level eq '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_relation'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
                   relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method CREATE_VARIANT_WITH_AS_TABLE .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_variant_with_as_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
              new_var_tg       = new_doc_var_tg
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
*             SIGNATURE        = SIGNATURE
              ascii_content    = ascii_content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_VA_T'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              new_var_tg      = new_doc_var_tg
              binary_flag     = space
         IMPORTING
              new_doc_var_id  = new_doc_var_id
         TABLES
              components      = components
              ascii_content   = ascii_content
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_variant_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
                   new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
endmethod.


METHOD CREATE_VARIANT_WITH_FILES.
  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'create_variant_with_files'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
              DOC_ID           = DOC_ID
              DOC_VER_NO       = DOC_VER_NO
              DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
              NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
*             COMPONENTS       = COMPONENTS
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
              FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_VA_F'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              DOC_ID          = DOC_ID
              DOC_VER_NO      = DOC_VER_NO
              DOC_VAR_ID      = DOC_VAR_ID
              NEW_VAR_TG      = NEW_DOC_VAR_TG
         IMPORTING
              NEW_DOC_VAR_ID  = NEW_DOC_VAR_ID
         TABLES
              FILES           = FILES
              PROPERTIES      = PROPERTIES
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_variant_with_files'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
                   NEW_VAR_TG     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                   signature      =
*                   relations      =
*                   dproperties    =
                    properties     = properties
                    .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_VARIANT_WITH_TABLE .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_variant_with_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
              new_var_tg       = new_doc_var_tg
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
*             SIGNATURE        = SIGNATURE
              content          = content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_VA_T'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              new_var_tg      = new_doc_var_tg
              binary_flag     = 'X'
         IMPORTING
              new_doc_var_id  = new_doc_var_id
         TABLES
              components      = components
              content         = content
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_variant_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
                   new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_VARIANT_WITH_URL.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_variant_with_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
              new_var_tg       = new_doc_var_tg
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
              uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_VA_U'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              new_var_tg      = new_doc_var_tg
         IMPORTING
              new_doc_var_id  = new_doc_var_id
         TABLES
              components      = components
              uris            = uris
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_variant_with_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
                   new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      =
*                  relations      =
*                  dproperties    =
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method CREATE_VERSION_WITH_AS_TABLE .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_version_with_as_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
*             SIGNATURE        = SIGNATURE
              ascii_content    = ascii_content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_NV_T'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              binary_flag     = space
         IMPORTING
              new_doc_ver_no  = new_doc_ver_no
         TABLES
              components      = components
              ascii_content   = ascii_content
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_version_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
endmethod.


METHOD CREATE_VERSION_WITH_FILES.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_version_with_files'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
              files            = files
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_NV_F'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         IMPORTING
              new_doc_ver_no  = new_doc_ver_no
         TABLES
              files           = files
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '1' OR i_log_level EQ '2' OR i_log_level EQ
             '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_version_with_files'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      =
*                  relations      =
*                  dproperties    =
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_VERSION_WITH_TABLE .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_version_with_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
*             SIGNATURE        = SIGNATURE
              content          = content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_NV_T'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              binary_flag     = 'X'
         IMPORTING
              new_doc_ver_no  = new_doc_ver_no
         TABLES
              components      = components
              content         = content
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_version_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_VERSION_WITH_URL.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_version_with_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
              uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_NV_U'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         IMPORTING
              new_doc_ver_no  = new_doc_ver_no
         TABLES
              components      = components
              uris            = uris
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_version_with_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      =
*                  relations      =
*                  dproperties    =
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method CREATE_WITH_AS_TABLE.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_with_as_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
              ascii_content    = ascii_content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CREA_TAB'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              binary_flag     = space
         IMPORTING
              object_key      = object_key
         TABLES
              signature       = signature
              components      = components
              ascii_content   = ascii_content
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
endmethod.


METHOD CREATE_WITH_FILES.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_with_files'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
              signature        = signature
*             CONTENT          = CONTENT
*             URIS             = URIS
              files            = files
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CREATEF'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
         IMPORTING
              object_key      = object_key
         TABLES
              files           = files
              signature       = signature
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_with_files'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_WITH_OWN_URL.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
*      TABLES
*           DOCUMENT_CLASSES =
       EXCEPTIONS
            nothing_found    = 1
            parameter_error  = 2
            not_allowed      = 3
            error_kpro       = 4
            internal_error   = 5
            not_authorized   = 6
            OTHERS           = 7
            .
  IF sy-subrc EQ 0 AND i_funcname NE space.
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_with_own_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             components       = components
*             signature        = signature
*             CONTENT          = CONTENT
*             uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CRE_O_URL'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              url             = url
              binary_flag     = binary_flag
              mimetype        = mimetype
         IMPORTING
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
           TABLES
                PROPERTIES      = properties[]
           EXCEPTIONS
                NOTHING_FOUND   = 1
                PARAMETER_ERROR = 2
                NOT_ALLOWED     = 3
                ERROR_KPRO      = 4
                INTERNAL_ERROR  = 5
                NOT_AUTHORIZED  = 6
                ERROR_DP        = 7
                OTHERS          = 9
              .
    CASE sy-subrc.
      WHEN 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_with_own_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      = signature
*                  relations      =
*                  dproperties    =
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
* ...
ENDMETHOD.


METHOD CREATE_WITH_TABLE.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

**********************************************************************
*   TuanBA Start Delete
**********************************************************************
*  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
*       EXPORTING
*            CLASSNAME        = CLASSNAME
*            CLASSTYPE        = CLASSTYPE
*        IMPORTING
**           LO_CLASS         =
**           PH_CLASS         =
**           RE_CLASS         =
**           TABNAME          =
*            FUNCNAME         = I_FUNCNAME
*            LOG_LEVEL        = I_LOG_LEVEL
**      TABLES
**           DOCUMENT_CLASSES =
*       EXCEPTIONS
**           NOTHING_FOUND    = 1
**           PARAMETER_ERROR  = 2
**           NOT_ALLOWED      = 3
**           ERROR_KPRO       = 4
**           INTERNAL_ERROR   = 5
**           NOT_AUTHORIZED   = 6
*            OTHERS           = 7
*            .
*  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
*    CALL FUNCTION I_FUNCNAME
*         EXPORTING
*              METHOD           = 'create_with_table'
*              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
*              CLASSNAME        = CLASSNAME
*              CLASSTYPE        = CLASSTYPE
*              CLIENT           = CLIENT
*              OBJECT_KEY       = OBJECT_KEY
**             DOC_ID           = DOC_ID
**             DOC_VER_NO       = DOC_VER_NO
**             DOC_VAR_ID       = DOC_VAR_ID
**             NEW_CLASSNAME    = NEW_CLASSNAME
**             NEW_CLASSTYPE    = NEW_CLASSTYPE
**             NEW_CLIENT       = NEW_CLIENT
**             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
**             NEW_VAR_TG       = NEW_DOC_VAR_TG
*         IMPORTING
*              EXIT             = I_EXIT
*         TABLES
*              COMPONENTS       = COMPONENTS
*              SIGNATURE        = SIGNATURE
*              CONTENT          = CONTENT
**             URIS             = URIS
**             FILES            = FILES
**             RELATIONS        = RELATIONS
**             DPROPERTIES      = PROPERTIES
**             PROPERTIES       = PROPERTIES
**             COMMFILE_ENTRIES = COMMFILE_ENTRIES
*              .
*  ENDIF.
**********************************************************************
*   TuanBA End Delete
**********************************************************************

  IF I_EXIT NE 'X'.
**********************************************************************
*   TuanBA Start Delete
**********************************************************************
*    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CREA_TAB'
**********************************************************************
*   TuanBA End Delete
**********************************************************************
*   TuanBA Start Add
**********************************************************************
    CALL FUNCTION 'ZFM_BDS_BUSDOC_CREA_TAB'
**********************************************************************
*   TuanBA End add
**********************************************************************
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              BINARY_FLAG     = 'X'
         IMPORTING
              OBJECT_KEY      = OBJECT_KEY
         TABLES
              SIGNATURE       = SIGNATURE
              COMPONENTS      = COMPONENTS
              CONTENT         = CONTENT
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      WHEN 0.
**********************************************************************
*   TuanBA Start Add
**********************************************************************
        RETURN.
**********************************************************************
*   TuanBA End add
**********************************************************************
        IF ( I_LOG_LEVEL EQ '3' OR I_LOG_LEVEL EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   METHOD         = 'create_with_table'
                   LOGICAL_SYSTEM = LOGICAL_SYSTEM
                   CLASSNAME      = CLASSNAME
                   CLASSTYPE      = CLASSTYPE
                   CLIENT         = CLIENT
                   OBJECT_KEY     = OBJECT_KEY
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   EXIT_FUNCNAME  = I_FUNCNAME
               TABLES
                   SIGNATURE      = SIGNATURE
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD CREATE_WITH_URL.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'create_with_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
*             CONTENT          = CONTENT
              uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CREA_URL'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
         IMPORTING
              object_key      = object_key
         TABLES
              uris            = uris
              components      = components
              signature       = signature
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '4' OR i_log_level EQ '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_with_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD DELETE.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'delete'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
              signature        = signature
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_DELETE'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              x_force_delete  = x_force_delete
         TABLES
              signature       = signature
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '1' OR i_log_level EQ '2' OR i_log_level EQ
             '3' or i_log_level eq '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'delete'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD DELETE_PROPERTIES.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'delete_properties'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             RELATIONS        = RELATIONS
              dproperties      = properties
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_DELETE_P'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         TABLES
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '1' OR i_log_level EQ '2' or
              i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'delete_properties'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  NEW_VAR_TG     =
                   exit_funcname  = i_funcname
               TABLES
*                  signature      =
*                  relations      =
                   dproperties    = properties
*                  properties     = properties
                    .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD DELETE_RELATIONS.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'delete_relations'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
*             OBJECT_KEY       = OBJECT_KEY
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
*             COMPONENTS       = COMPONENTS
*             SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
              RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_DEL_RELAS'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
         TABLES
              RELATIONS       = RELATIONS
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF ( i_log_level EQ '1' OR i_log_level EQ '2' OR i_log_level EQ
             '3' or i_log_level eq '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'delete_relations'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
*                  object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
*                  signature      = signature
                   relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method DOCUMENT_DEQUEUE .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'document_dequeue'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
*        TABLES
*             components       = components
*             signature        = signature
*             content          = content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_DEQUEUE'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '2' OR i_log_level EQ
             '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'update_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
*              TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD DOCUMENT_ENQUEUE .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'document_enqueue'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
*        TABLES
*             components       = components
*             signature        = signature
*             content          = content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_ENQUEUE'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              foreign_lock    = 7
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '2' OR i_log_level EQ
             '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'update_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
*              TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      when 7.
        message id sy-msgid type sy-msgty number sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING foreign_lock.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method ERROR_HANDLING.
 case sy_subrc.
   when 1.
     MESSAGE ID sy_msgid TYPE sy_msgty NUMBER sy_msgno
     WITH sy_msgv1 sy_msgv2 sy_msgv3 sy_msgv4 RAISING nothing_found.
   when 2.
     MESSAGE ID sy_msgid TYPE sy_msgty NUMBER sy_msgno
     WITH sy_msgv1 sy_msgv2 sy_msgv3 sy_msgv4 RAISING parameter_error.
   when 3.
     MESSAGE ID sy_msgid TYPE sy_msgty NUMBER sy_msgno
     WITH sy_msgv1 sy_msgv2 sy_msgv3 sy_msgv4 RAISING not_allowed.
   when 4.
     MESSAGE ID sy_msgid TYPE sy_msgty NUMBER sy_msgno
     WITH sy_msgv1 sy_msgv2 sy_msgv3 sy_msgv4 RAISING internal_error.
   when 5.
     MESSAGE ID sy_msgid TYPE sy_msgty NUMBER sy_msgno
     WITH sy_msgv1 sy_msgv2 sy_msgv3 sy_msgv4 RAISING error_kpro.
   when 6.
     MESSAGE ID sy_msgid TYPE sy_msgty NUMBER sy_msgno
     WITH sy_msgv1 sy_msgv2 sy_msgv3 sy_msgv4 RAISING not_authorized.
   when others.
 endcase.


endmethod.


METHOD GET_COMPONENT_PROPERTIES .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_file_properties'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             new_var_tg       = new_doc_var_tg
         IMPORTING
              exit             = i_exit
*        TABLES
*             components       = components
*             SIGNATURE        = SIGNATURE
*             ascii_content    = ascii_content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             properties       = properties
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_FPROP'
      EXPORTING
        logical_system  = logical_system
        classname       = classname
        classtype       = classtype
        client          = sy-mandt
        object_key      = object_key
        doc_id          = doc_id
        doc_ver_no      = doc_ver_no
        doc_var_id      = doc_var_id
      TABLES
        extended_components      = extended_components
      EXCEPTIONS
        nothing_found   = 1
        parameter_error = 2
        not_allowed     = 3
        error_kpro      = 4
        internal_error  = 5
        not_authorized  = 6
        OTHERS          = 9.
    CASE sy-subrc.
      WHEN 0.
        IF ( i_log_level EQ '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'create_variant_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                   new_var_tg     = new_doc_var_tg
*                  exit_funcname  = i_funcname
*              TABLES
*                  signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.                    "


METHOD GET_FAST_INFO.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c,
        wa_connections LIKE LINE OF connections.

  LOOP AT connections INTO wa_connections.
    CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
         EXPORTING
              classname        = wa_connections-classname
              classtype        = wa_connections-classtype
          IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
              funcname         = i_funcname
              log_level        = i_log_level
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
      CALL FUNCTION i_funcname
           EXPORTING
                method           = 'get_fast_info'
                logical_system   = logical_system
                classname        = wa_connections-classname
                classtype        = wa_connections-classtype
                client           = client
                object_key       = wa_connections-object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       =
           IMPORTING
                exit             = i_exit
           TABLES
*               components       = components
                signature        = signature
*             CONTENT          =
*             URIS             =
*             RELATIONS        =
*             DPROPERTIES      =
*             PROPERTIES       =
*             COMMFILE_ENTRIES =
                .
    ENDIF.
  ENDLOOP.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_FINFO'
         EXPORTING
              logical_system  = logical_system
              client          = client
              get_properties  = get_properties
         TABLES
              signature       = signature
              connections     = connections
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              OTHERS          = 7.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '4' ).
          LOOP AT connections INTO wa_connections.
            CALL FUNCTION 'BDS_WRITE_LOG'
                 EXPORTING
                     method         = 'get_fast_info'
                     logical_system = logical_system
                     classname      = wa_connections-classname
                     classtype      = wa_connections-classtype
                     client         = client
                     object_key     = wa_connections-object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                     exit_funcname  = i_funcname
                 TABLES
                     signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                     .
          ENDLOOP.
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD GET_INFO.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_info'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       =
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
*             CONTENT          =
*             URIS             =
*             RELATIONS        =
*             DPROPERTIES      =
*             PROPERTIES       =
*             COMMFILE_ENTRIES =
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_INFO'
      EXPORTING
        logical_system      = logical_system
        classname           = classname
        classtype           = classtype
        client              = client
        object_key          = object_key
        CHECK_STATE         = CHECK_STATE
      TABLES
        components          = components
        signature           = signature
        connections         = connections
        extended_components = extended_components
      EXCEPTIONS
        nothing_found       = 1
        parameter_error     = 2
        not_allowed         = 3
        error_kpro          = 4
        internal_error      = 5
        not_authorized      = 6
        OTHERS              = 9.
    CASE sy-subrc.
      WHEN 0.
        IF ( i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_info'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.                    "


METHOD GET_INFO_NEWEST_ONLY.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'get_info_newest_only'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
              COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_INFO'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              ALL             = ' '
              CHECK_STATE     = CHECK_STATE
         TABLES
              COMPONENTS      = COMPONENTS
              SIGNATURE       = SIGNATURE
              connections     = connections
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              ERROR_KPRO      = 4
              INTERNAL_ERROR  = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF i_log_level eq '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_info_newest_only'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD GET_RELATIONS.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'get_relations'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
              DOC_ID           = DOC_ID
              DOC_VER_NO       = DOC_VER_NO
              DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
*             COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
              RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_RELAS'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              DOC_ID          = DOC_ID
              DOC_VER_NO      = DOC_VER_NO
              DOC_VAR_ID      = DOC_VAR_ID
              no_properties   = no_properties
         TABLES
              RELATIONS       = RELATIONS
              SIGNATURE       = SIGNATURE
              properties      = properties
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF i_log_level eq '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_relations'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
                   relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD GET_TRANSPORT_INFOS.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'get_transport_infos'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
*             COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
              COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_TP'
         EXPORTING
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
         TABLES
              SIGNATURE        = SIGNATURE
              COMMFILE_ENTRIES = COMMFILE_ENTRIES
         EXCEPTIONS
              NOTHING_FOUND    = 1
              PARAMETER_ERROR  = 2
              NOT_ALLOWED      = 3
              INTERNAL_ERROR   = 4
              ERROR_KPRO       = 5
              NOT_AUTHORIZED   = 6
              OTHERS           = 9.
    CASE SY-SUBRC.
      when 0.
        IF i_log_level eq '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_transport_infos'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method GET_WITH_AS_TABLE.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_with_as_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
*             content          = content
              ascii_content    = ascii_content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.

    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_TAB'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              binary_flag     = space
              text_as_stream  = text_as_stream
         TABLES
              signature       = signature
              components      = components
              ascii_content   = ascii_content
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
endmethod.


METHOD GET_WITH_COMP_URL .

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_with_comp_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
*             CONTENT          = CONTENT
              uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_C_URL'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              url_lifetime    = url_lifetime
         TABLES
              uris            = uris
              signature       = signature
              components      = components
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              error_dp        = 7
              OTHERS          = 9.
    CASE sy-subrc.
      WHEN 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_with_own_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.

ENDMETHOD.


METHOD GET_WITH_FILES.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'get_with_files'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
*             COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
*             URIS             = URIS
              FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_FILES'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
         TABLES
              FILES           = FILES
              SIGNATURE       = SIGNATURE
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF i_log_level eq '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_with_files'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


method GET_WITH_OWN_URL.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_with_own_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              DOC_ID           = DOC_ID
              DOC_VER_NO       = DOC_VER_NO
              DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
*        TABLES
*             components       = components
*             signature        = signature
*             CONTENT          = CONTENT
*             uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
      CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_O_URL'
           EXPORTING
                LOGICAL_SYSTEM  = logical_system
                classname       = classname
                classtype       = classtype
                CLIENT          = client
                OBJECT_KEY      = object_key
                doc_id          = doc_id
                doc_ver_no      = doc_ver_no
                doc_var_id      = doc_var_id
                url             = url
                URL_LIFETIME    = url_lifetime
           EXCEPTIONS
                NOTHING_FOUND   = 1
                PARAMETER_ERROR = 2
                NOT_ALLOWED     = 3
                ERROR_KPRO      = 4
                INTERNAL_ERROR  = 5
                NOT_AUTHORIZED  = 6
                ERROR_DP        = 7
                OTHERS          = 8
                .
    CASE sy-subrc.
      when 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_with_own_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
*              TABLES
*                  signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.

endmethod.


METHOD GET_WITH_TABLE.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_with_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
              content          = content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_TAB'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              binary_flag     = 'X'
         TABLES
              signature       = signature
              components      = components
              content         = content
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD GET_WITH_URL.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_with_url'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             DOC_ID           = DOC_ID
*             DOC_VER_NO       = DOC_VER_NO
*             DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
*             CONTENT          = CONTENT
              uris             = uris
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_URL'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              url_lifetime    = url_lifetime
              selected_index  = selected_index
         TABLES
              uris            = uris
              signature       = signature
              components      = components
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'get_with_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      =
*                  dproperties    =
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD QUERY_DOCUMENTS.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'query_documents'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
*             doc_id           = doc_id
*             doc_ver_no       = doc_ver_no
*             doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
              signature        = signature
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_QUERY_D'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
         TABLES
              components      = components
              signature       = signature
              connections     = connections
              query           = query
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'query_relations'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD QUERY_RELATIONS.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'get_relations'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
              signature        = signature
*             CONTENT          = CONTENT
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_QUERY_R'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
         TABLES
              relations       = relations
              signature       = signature
              query           = query
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF i_log_level EQ '4'.
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'query_relations'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.

ENDMETHOD.


method UPDATE_WITH_AS_TABLE.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'update_with_as_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
              ascii_content    = ascii_content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_UPD_TAB'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              x_force_update  = x_force_update
              binary_flag     = space
         TABLES
              components      = components
              ascii_content   = ascii_content
              signature       = signature
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '2' OR i_log_level EQ
             '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'update_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.

endmethod.


METHOD UPDATE_WITH_FILES.
  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            classname        = classname
            classtype        = classtype
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            funcname         = i_funcname
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'update_with_files'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
*             COMPONENTS       = COMPONENTS
              signature        = signature
*             CONTENT          = CONTENT
*             URIS             = URIS
              files            = files
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_UPD_F'
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              x_force_update  = x_force_update
         TABLES
              files           = files
              signature       = signature
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '1' OR i_log_level EQ '2' or i_log_level
             eq '3' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'update_with_files'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
                   doc_id         = doc_id
                   doc_ver_no     = doc_ver_no
                   doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      =
*                  dproperties    =
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD UPDATE_WITH_TABLE.

  DATA: i_funcname TYPE ty_funcname,
        i_log_level TYPE ty_log_level,
        i_exit TYPE c.

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
            log_level        = i_log_level
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
    CALL FUNCTION i_funcname
         EXPORTING
              method           = 'update_with_table'
              logical_system   = logical_system
              classname        = classname
              classtype        = classtype
              client           = client
              object_key       = object_key
              doc_id           = doc_id
              doc_ver_no       = doc_ver_no
              doc_var_id       = doc_var_id
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              exit             = i_exit
         TABLES
              components       = components
              signature        = signature
              content          = content
*             URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
              PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF i_exit NE 'X'.
**********************************************************************
* TuanBA Edit START
**********************************************************************
*   CALL FUNCTION 'BDS_BUSINESSDOCUMENT_UPD_TAB'
    CALL FUNCTION 'ZFM_BDS_BUSDOC_UPD_TAB'
**********************************************************************
* TuanBA Edit END
**********************************************************************
         EXPORTING
              logical_system  = logical_system
              classname       = classname
              classtype       = classtype
              client          = client
              object_key      = object_key
              doc_id          = doc_id
              doc_ver_no      = doc_ver_no
              doc_var_id      = doc_var_id
              x_force_update  = x_force_update
              binary_flag     = 'X'
         TABLES
              components      = components
              content         = content
              signature       = signature
              properties      = properties
         EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              internal_error  = 4
              error_kpro      = 5
              not_authorized  = 6
              OTHERS          = 9.
    CASE sy-subrc.
      when 0.
        IF ( i_log_level EQ '2' OR i_log_level EQ
             '3' OR i_log_level EQ '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'update_with_table'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
                   properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING nothing_found.
      WHEN 2.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING parameter_error.
      WHEN 3.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_allowed.
      WHEN 4.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
      WHEN 5.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING error_kpro.
      WHEN 6.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING not_authorized.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.


METHOD UPDATE_WITH_URL.

  DATA: I_FUNCNAME TYPE TY_FUNCNAME,
        I_LOG_LEVEL TYPE TY_LOG_LEVEL,
        I_EXIT TYPE C.

  CALL FUNCTION 'BDS_DOCUMENTCLASS_GET'
       EXPORTING
            CLASSNAME        = CLASSNAME
            CLASSTYPE        = CLASSTYPE
        IMPORTING
*           LO_CLASS         =
*           PH_CLASS         =
*           RE_CLASS         =
*           TABNAME          =
            FUNCNAME         = I_FUNCNAME
            LOG_LEVEL        = I_LOG_LEVEL
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
  IF SY-SUBRC EQ 0 AND I_FUNCNAME NE SPACE.
    CALL FUNCTION I_FUNCNAME
         EXPORTING
              METHOD           = 'update_with_url'
              LOGICAL_SYSTEM   = LOGICAL_SYSTEM
              CLASSNAME        = CLASSNAME
              CLASSTYPE        = CLASSTYPE
              CLIENT           = CLIENT
              OBJECT_KEY       = OBJECT_KEY
              DOC_ID           = DOC_ID
              DOC_VER_NO       = DOC_VER_NO
              DOC_VAR_ID       = DOC_VAR_ID
*             NEW_CLASSNAME    = NEW_CLASSNAME
*             NEW_CLASSTYPE    = NEW_CLASSTYPE
*             NEW_CLIENT       = NEW_CLIENT
*             NEW_OBJECT_KEY   = NEW_OBJECT_KEY
*             NEW_VAR_TG       = NEW_DOC_VAR_TG
         IMPORTING
              EXIT             = I_EXIT
         TABLES
              COMPONENTS       = COMPONENTS
              SIGNATURE        = SIGNATURE
*             CONTENT          = CONTENT
              URIS             = URIS
*             FILES            = FILES
*             RELATIONS        = RELATIONS
*             DPROPERTIES      = PROPERTIES
*             PROPERTIES       = PROPERTIES
*             COMMFILE_ENTRIES = COMMFILE_ENTRIES
              .
  ENDIF.
  IF I_EXIT NE 'X'.
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_UPD_URL'
         EXPORTING
              LOGICAL_SYSTEM  = LOGICAL_SYSTEM
              CLASSNAME       = CLASSNAME
              CLASSTYPE       = CLASSTYPE
              CLIENT          = CLIENT
              OBJECT_KEY      = OBJECT_KEY
              DOC_ID          = DOC_ID
              DOC_VER_NO      = DOC_VER_NO
              DOC_VAR_ID      = DOC_VAR_ID
              X_FORCE_UPDATE  = X_FORCE_UPDATE
         IMPORTING
              NEW_STOR_CAT    = NEW_STOR_CAT
         TABLES
              COMPONENTS      = COMPONENTS
              URIS            = URIS
              SIGNATURE       = SIGNATURE
         EXCEPTIONS
              NOTHING_FOUND   = 1
              PARAMETER_ERROR = 2
              NOT_ALLOWED     = 3
              INTERNAL_ERROR  = 4
              ERROR_KPRO      = 5
              NOT_AUTHORIZED  = 6
              OTHERS          = 9.
    CASE SY-SUBRC.
      when 0.
        IF ( i_log_level EQ '2' OR i_log_level EQ
             '3' or i_log_level eq '4' ).
          CALL FUNCTION 'BDS_WRITE_LOG'
               EXPORTING
                   method         = 'update_with_url'
                   logical_system = logical_system
                   classname      = classname
                   classtype      = classtype
                   client         = client
                   object_key     = object_key
*                  doc_id         = doc_id
*                  doc_ver_no     = doc_ver_no
*                  doc_var_id     = doc_var_id
*                  new_classname  = new_classname
*                  new_classtype  = new_classtype
*                  new_client     = new_client
*                  new_object_key = new_object_key
*                  new_var_tg     = new_doc_var_tg
                   exit_funcname  = i_funcname
               TABLES
                   signature      = signature
*                  relations      = relations
*                  dproperties    = dproperties
*                  properties     = properties
                   .
        ENDIF.
      WHEN 1.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOTHING_FOUND.
      WHEN 2.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING PARAMETER_ERROR.
      WHEN 3.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_ALLOWED.
      WHEN 4.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING INTERNAL_ERROR.
      WHEN 5.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING ERROR_KPRO.
      WHEN 6.
        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 RAISING NOT_AUTHORIZED.
      WHEN OTHERS.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING internal_error.
    ENDCASE.
  ENDIF.
ENDMETHOD.
ENDCLASS.
