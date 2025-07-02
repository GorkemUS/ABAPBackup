*&---------------------------------------------------------------------*
*& Include zdyp12_r_dynalv01_cls
*&---------------------------------------------------------------------*

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_column e_row es_row_no.
    METHODS:
      get_data,
      refresh_table,
      alv_splitter,
      display_grid1,
      display_grid2.



ENDCLASS.


CLASS lcl_main IMPLEMENTATION.

  METHOD handle_toolbar.

  ENDMETHOD.

  METHOD handle_user_command.

  ENDMETHOD.

  METHOD double_click.
*    e_column e_row es_row_no.

    DATA: lv_matnr        TYPE matnr,
          lv_month        TYPE char2,
          lv_year         TYPE char4,
          lt_ekpo_grp     TYPE TABLE OF ekpo WITH EMPTY KEY,
          ls_ekpo_grp     LIKE LINE OF lt_ekpo_grp,
          lv_ttl_quantity TYPE menge_d.

    IF e_column = 'MATNR' AND e_row-index NE 0.
      READ TABLE gt_mara INTO DATA(ls_mara) INDEX e_row-index.
      lv_matnr = ls_mara-matnr.

      SELECT matnr,
             aedat
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE @gt_ekpo
        WHERE matnr = @lv_matnr.

      IF sy-subrc = 0.

        LOOP AT gt_ekpo INTO DATA(ls_ekpo).

          lv_month = ls_ekpo-aedat+4(2). " month
          lv_year = ls_ekpo-aedat+0(4).  " year
          READ TABLE lt_ekpo_grp INTO ls_ekpo_grp
            WITH KEY aedat+0(4) = lv_year aedat+4(2) = lv_month.

          IF sy-subrc <> 0.
            " If no entry exists for this month and year, create a new entry
            CLEAR ls_ekpo_grp.
            MOVE-CORRESPONDING ls_ekpo TO ls_ekpo_grp.  " Copy the current entry
            APPEND ls_ekpo_grp TO lt_ekpo_grp.
          ENDIF.

        ENDLOOP.

        SORT lt_ekpo_grp BY aedat ASCENDING.

        gt_ekpo = lt_ekpo_grp.
        go_main->display_grid2( ).
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD get_data.

    SELECT * FROM mara INTO TABLE @gt_mara UP TO 100 ROWS
      WHERE mara~matnr IN @s_matnr.


  ENDMETHOD.

  METHOD refresh_table.
    DATA : ld_grid TYPE REF TO cl_gui_alv_grid.

    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ld_grid.

    IF ld_grid IS NOT BOUND.
      MESSAGE 'ALV Grid instance not found' TYPE 'E' DISPLAY LIKE 'S'.
    ENDIF.

    ld_grid->check_changed_data( ).

    DATA : BEGIN OF ls_stable,
             row TYPE c,
             col TYPE c,
           END OF ls_stable.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.
    CALL METHOD ld_grid->refresh_table_display
      EXPORTING
        i_soft_refresh = 'X'
        is_stable      = ls_stable.

  ENDMETHOD.

  METHOD alv_splitter.

    CREATE OBJECT splitter_1
      EXPORTING
        parent  = cl_gui_container=>default_screen
        rows    = 2
        columns = 1.

    CALL METHOD splitter_1->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = container_1.

    CALL METHOD splitter_1->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = container_2.


  ENDMETHOD.

  METHOD display_grid1.

    DATA: lt_fieldcatalog TYPE TABLE OF lvc_s_fcat,
          ls_fieldcatalog TYPE lvc_s_fcat.

    IF grid1 IS BOUND.
      go_main->refresh_table( ).
    ELSE.
      CREATE OBJECT grid1
        EXPORTING
          i_parent = container_1.

      SET HANDLER:  lcl_main=>handle_toolbar      FOR grid1,
                    lcl_main=>handle_user_command FOR grid1,
                    lcl_main=>double_click        FOR grid1.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = 'MARA'
*         i_bypassing_buffer     = 'X'
        CHANGING
          ct_fieldcat            = lt_fieldcatalog[]
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.

      CALL METHOD grid1->set_table_for_first_display
        EXPORTING
          i_structure_name = 'MARA'
        CHANGING
          it_outtab        = gt_mara
          it_fieldcatalog  = lt_fieldcatalog.

    ENDIF.
  ENDMETHOD.

  METHOD display_grid2.

    IF grid2 IS BOUND.
      go_main->refresh_table( ).
    ELSE.
      CREATE OBJECT grid2
        EXPORTING
          i_parent = container_2.

      CALL METHOD grid2->set_table_for_first_display
        EXPORTING
          i_structure_name = 'EKPO'
        CHANGING
          it_outtab        = gt_ekpo.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
