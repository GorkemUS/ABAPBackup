*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_DYNALV02_CLS
*&---------------------------------------------------------------------*

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.

    METHODS: get_data,
      display_alv.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.
  METHOD handle_user_command.
  ENDMETHOD.

  METHOD handle_toolbar.
  ENDMETHOD.

  METHOD get_data.
    SELECT
      dd03l~tabname,
      dd03l~position,
      dd03l~keyflag,
      dd03l~fieldname,
      dd03l~rollname,
      dd03l~datatype,
      dd03l~leng,
      dd03l~decimals,
      coalesce( dd03t~ddtext, dd04t~ddtext ) AS fieldtext
      FROM dd03l
      LEFT JOIN dd03t ON dd03t~tabname = dd03l~tabname
      AND dd03t~ddlanguage = @sy-langu
      LEFT JOIN dd04t ON dd04t~rollname = dd03l~rollname
      AND dd04t~ddlanguage = @sy-langu
      WHERE dd03l~tabname = @p_table
      AND dd03l~as4local = 'A'
      AND comptype = 'E'

      ORDER BY dd03l~position
      INTO CORRESPONDING FIELDS OF TABLE @gt_data.

  ENDMETHOD.

  METHOD display_alv.


    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
*       i_program_name     = alv_repid
*       i_internal_tabname = alv_tabname
*       i_inclname         = alv_repid
        i_structure_name   = 'ZDYP12_S_DYNALV'
        i_bypassing_buffer = 'X'
      CHANGING
        ct_fieldcat        = lt_fieldcatalog[].

    "ALV Layout
    lt_layout-zebra = 'X'.
    lt_layout-colwidth_optimize = 'X'.
    lt_layout-window_titlebar = t3.
    lt_layout-box_fieldname = 'CHK'.

    LOOP AT lt_fieldcatalog ASSIGNING FIELD-SYMBOL(<fs_fieldcat>).
      IF <fs_fieldcat>-fieldname = 'FIELDTEXT'.
        <fs_fieldcat>-seltext_m = 'Fieldtext'.
      ELSEIF <fs_fieldcat>-fieldname = 'FIELDNAME'.
        <fs_fieldcat>-tech = abap_true.
      ELSEIF <fs_fieldcat>-fieldname = 'CHK'.
        <fs_fieldcat>-tech = abap_true.
      ENDIF.

    ENDLOOP.
    " ALV Output
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_pf_status_set = 'SET_PF_STATUS'
        i_callback_user_command  = 'USER_COMMAND'
        is_layout                = lt_layout
        it_fieldcat              = lt_fieldcatalog[]
        i_callback_program       = sy-repid
      TABLES
        t_outtab                 = gt_data
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
