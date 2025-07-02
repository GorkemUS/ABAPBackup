*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_DYNALV02_FRM
*&---------------------------------------------------------------------*
FORM user_command USING  r_ucomm     LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  LOOP AT gt_data INTO gs_data WHERE chk = 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.

  CASE r_ucomm.
    WHEN '&RTR'.
      PERFORM check_lines.
      PERFORM check_keys.
      PERFORM check_keys_and_display.
  ENDCASE.

ENDFORM.
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD'.
ENDFORM.

FORM check_lines.
  " If no rows or more than one row selected, Show info message
  IF lv_count = 0.
    MESSAGE 'Lütfen en az bir alan seçiniz.' TYPE 'I'.
    RETURN.
  ENDIF.

ENDFORM.

FORM check_keys.

  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>) WHERE keyflag = 'X'.
    lt_keys-fieldname = <fs_data>-fieldname.
    lt_keys-tabname = <fs_data>-tabname.
    APPEND lt_keys.
  ENDLOOP.

  LOOP AT gt_data ASSIGNING <fs_data> WHERE chk = 'X'.
    lt_selected_fields-fieldname = <fs_data>-fieldname.
    lt_selected_fields-tabname = <fs_data>-tabname.
    APPEND lt_selected_fields.
  ENDLOOP.

  CONCATENATE 'Key fields for' p_table INTO lv_title SEPARATED BY space.
  IF sy-subrc = 0.
*    " Call POPUP_GET_VALUES to display the popup for key fields
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        popup_title     = lv_title
      IMPORTING
        returncode      = lv_ret
      TABLES
        fields          = lt_keys
      EXCEPTIONS
        error_in_fields = 1
        OTHERS          = 2.
  ENDIF.
ENDFORM.


FORM check_keys_and_display .

  DATA: l_structure           TYPE REF TO data,
        l_table               TYPE REF TO data,
        struc_desc            TYPE REF TO cl_abap_structdescr,
        ls_lvc_fieldcatalogue TYPE lvc_s_fcat,
        lt_lvc_fieldcatalogue TYPE lvc_t_fcat,
        ls_fieldcatalogue     TYPE slis_fieldcat_alv,
        lt_fieldcatalogue     TYPE slis_t_fieldcat_alv,
        lt_components         TYPE abap_component_tab,
        ls_component          TYPE abap_componentdescr.

* Field symbols declaration
  FIELD-SYMBOLS :
    <it_table> TYPE STANDARD TABLE,
    <dyn_str>  TYPE any.

* Step 1: Build the dynamic structure components based on selected fields
  LOOP AT lt_selected_fields ASSIGNING FIELD-SYMBOL(<fs_selected_field>).
    CLEAR ls_component.
    ls_component-name = <fs_selected_field>-fieldname.

    ls_component-type = cl_abap_elemdescr=>get_string( ).

    APPEND ls_component TO lt_components.
  ENDLOOP.

* Step 2: Create the dynamic structure
  struc_desc = cl_abap_structdescr=>create( lt_components ).
  CREATE DATA l_structure TYPE HANDLE struc_desc.
  ASSIGN l_structure->* TO <dyn_str>.

  LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<fs_component>).
    CLEAR ls_lvc_fieldcatalogue.
    ls_lvc_fieldcatalogue-fieldname = <fs_component>-name.
    ls_lvc_fieldcatalogue-ref_table = p_table. " Adjust the table name accordingly
    APPEND ls_lvc_fieldcatalogue TO lt_lvc_fieldcatalogue.
  ENDLOOP.

  " Example: Create dynamic internal table from the structure
  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      it_fieldcatalog = lt_lvc_fieldcatalogue
    IMPORTING
      ep_table        = l_table.

  ASSIGN l_table->* TO <it_table>.

  DATA: lt_fieldnames TYPE TABLE OF string.

  LOOP AT lt_selected_fields ASSIGNING FIELD-SYMBOL(<fs_selected_fields>).
    APPEND <fs_selected_fields>-fieldname TO lt_fieldnames.
  ENDLOOP.

  DATA: lt_where_clause TYPE TABLE OF string,
        lt_condtab      TYPE TABLE OF hrcond,
        lt_where        TYPE STANDARD TABLE OF char72 WITH DEFAULT KEY.

  LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<fs_key>).
    IF <fs_key>-value IS INITIAL.
      CONTINUE.
    ENDIF.
    APPEND VALUE hrcond(
          field = <fs_key>-fieldname
          opera = 'EQ'
          low   = <fs_key>-value )
          TO lt_condtab.
  ENDLOOP.

  CALL FUNCTION 'RH_DYNAMIC_WHERE_BUILD'
    EXPORTING
      dbtable         = space
    TABLES
      condtab         = lt_condtab
      where_clause    = lt_where_clause
    EXCEPTIONS
      empty_condtab   = 1
      no_db_field     = 2
      unknown_db      = 3
      wrong_condition = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


  SELECT (lt_fieldnames)
         FROM (p_table)
         INTO CORRESPONDING FIELDS OF TABLE <it_table>
    WHERE (lt_where_clause).

  CALL FUNCTION 'LVC_TRANSFER_TO_SLIS'
    EXPORTING
      it_fieldcat_lvc         = lt_lvc_fieldcatalogue
*     IT_SORT_LVC             =
*     IT_FILTER_LVC           =
*     IS_LAYOUT_LVC           =
    IMPORTING
      et_fieldcat_alv         = lt_fieldcatalogue
*     ET_SORT_ALV             =
*     ET_FILTER_ALV           =
*     ES_LAYOUT_ALV           =
*     TABLES
*     IT_DATA                 =
    EXCEPTIONS
      it_data_missing         = 1
      it_fieldcat_lvc_missing = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_screen_start_column = 30
      i_screen_start_line   = 4
      i_screen_end_column   = 120
      i_screen_end_line     = 15
*     i_callback_pf_status_set = 'SET_PF_STATUS'
*     i_callback_user_command  = 'USER_COMMAND'
*     is_layout             = lt_layout
      i_structure_name      = '<DYN_STR>'
      it_fieldcat           = lt_fieldcatalogue
      i_callback_program    = sy-repid
    TABLES
      t_outtab              = <it_table>
    EXCEPTIONS
      program_error         = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
