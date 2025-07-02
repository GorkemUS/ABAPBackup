*&---------------------------------------------------------------------*
*& Report ZDYP12_R_SPLITTER_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_layoutsplit_alv4.

TABLES: vbak, vbap.

DATA: gs_toolbar        TYPE stb_button.

DATA: splitter_1  TYPE REF TO cl_gui_splitter_container,
*      splitter_2 TYPE REF TO cl_gui_splitter_container,
      go_cust   TYPE REF TO cl_gui_custom_container,
      container_1 TYPE REF TO cl_gui_container,
      container_2 TYPE REF TO cl_gui_container,
      container_3 TYPE REF TO cl_gui_container.

DATA : it_vbak  TYPE TABLE OF vbak,
       it_vbap TYPE TABLE OF vbap,
*       it_makt  TYPE TABLE OF makt,
*       c_container TYPE scrfname VALUE 'CCONTAINER',
       grid1    TYPE REF TO cl_gui_alv_grid,
       grid2    TYPE REF TO cl_gui_alv_grid,
       grid3    TYPE REF TO cl_gui_alv_grid.

CLASS lcl_event_receiver DEFINITION DEFERRED.

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:

      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,

      hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no.
ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_user_command.
* e_ucomm
    DATA lt_cell TYPE lvc_t_cell.
    DATA ls_cell TYPE lvc_s_cell.
    DATA lv_answer(1).
    FIELD-SYMBOLS: <fv_val1> TYPE any.

    CASE e_ucomm.
      WHEN '&ADD'.
        READ TABLE it_vbak INTO DATA(ls_vbak) INDEX 1.
        DO 20 TIMES.
          APPEND ls_vbak TO it_vbak.
        ENDDO.
        PERFORM display_grid1.
      WHEN  '&DELETE'.
        DELETE it_vbak WHERE netwr > 1000.
        PERFORM display_grid1.
    ENDCASE.
  ENDMETHOD.

  METHOD hotspot_click.
* e_row_id e_column_id es_row_no

*    BREAK-POINT.
    IF  e_column_id EQ 'VBELN' AND es_row_no-row_id NE 0.
      READ TABLE it_vbak INTO DATA(ls_vbak) INDEX es_row_no-row_id.

      SELECT * FROM vbap INTO TABLE it_vbap
         WHERE vbeln = ls_vbak-vbeln.
      IF sy-subrc IS INITIAL.

        PERFORM display_grid2.

      ENDIF.

    ENDIF.

  ENDMETHOD.

    METHOD handle_toolbar.
* e_object e_interactive
*    CLEAR gs_toolbar.
*    gs_toolbar-butn_type = 3.
**    gt_toolbar-function = 3.
*    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&ADD'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_positive.
    gs_toolbar-text      = 'Add'.
    gs_toolbar-quickinfo = 'Add'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&DELETE'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_negative.
    gs_toolbar-text      = 'Delete'.
    gs_toolbar-quickinfo = 'Delete'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar


ENDCLASS.

START-OF-SELECTION.


  SELECT * FROM vbak INTO TABLE it_vbak UP TO 100 ROWS.
*  SELECT * FROM vbap INTO TABLE it_vbap UP TO 100 ROWS.

      CALL SCREEN 9000.


MODULE status_9000 OUTPUT.

  SET PF-STATUS 'STANDARD'.
*  PERFORM create_splitter_1.
*  PERFORM create_splitter_2.
  PERFORM display_grid1.
*  PERFORM display_grid2.
*  PERFORM display_grid3.

ENDMODULE.

FORM create_splitter_1 .

*  CREATE OBJECT splitter_1
*    EXPORTING
*      parent  = cl_gui_container=>default_screen
*      rows    = 2
*      columns = 1.
*
*  CALL METHOD splitter_1->get_container
*    EXPORTING
*      row       = 1
*      column    = 1
*    RECEIVING
*      container = container_1.
*
*  CALL METHOD splitter_1->get_container
*    EXPORTING
*      row       = 2
*      column    = 1
*    RECEIVING
*      container = container_2.

*    CALL METHOD splitter_1->get_container
*    EXPORTING
*      row       = 3
*      column    = 1
*    RECEIVING
*      container = container_3.

ENDFORM.


FORM create_splitter_2 .

*  CREATE OBJECT splitter_2
*    EXPORTING
*      parent  = container_2
*      rows    = 3
*      columns = 1.
*
*  CALL METHOD splitter_2->get_container
*    EXPORTING
*      row       = 1
*      column    = 1
*    RECEIVING
*      container = container_2.
*
*  CALL METHOD splitter_2->get_container
*    EXPORTING
*      row       = 2
*      column    = 1
*    RECEIVING
*      container = container_3.

ENDFORM.

FORM display_grid1 .

DATA: lt_fieldcatalog TYPE TABLE OF lvc_s_fcat,
      ls_fieldcatalog TYPE lvc_s_fcat.
    CREATE OBJECT go_cust
    EXPORTING
      container_name = 'CONTAINER_1'.
  IF grid1 IS BOUND.
    PERFORM refresh_alv USING grid1.

  ELSE.

    CREATE OBJECT grid1
      EXPORTING
        i_parent = go_cust.

*   Class operation
    DATA: lcl_alv_event TYPE REF TO lcl_event_receiver.
    CREATE OBJECT lcl_alv_event.

    SET HANDLER: lcl_alv_event->handle_user_command  FOR grid1,
                 lcl_alv_event->handle_toolbar       FOR grid1,
                 lcl_alv_event->hotspot_click        FOR grid1.


*  Enter
    CALL METHOD grid1->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.
    CALL METHOD grid1->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.




*  Field catalog
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name   = 'VBAK'
        i_bypassing_buffer = 'X'
      CHANGING
        ct_fieldcat        = lt_fieldcatalog[].
*  Edit Fileds

    LOOP AT lt_fieldcatalog INTO ls_fieldcatalog.
      CASE ls_fieldcatalog-fieldname.
        WHEN 'VBELN'.
          ls_fieldcatalog-hotspot = 'X'.
      ENDCASE.
      MODIFY lt_fieldcatalog FROM ls_fieldcatalog.
    ENDLOOP.

    CALL METHOD grid1->set_table_for_first_display
      EXPORTING
        i_structure_name = 'VBAK'
      CHANGING
        it_fieldcatalog  = lt_fieldcatalog
        it_outtab        = it_vbak.
ENDIF.
ENDFORM.

FORM display_grid2 .

    CREATE OBJECT go_cust
    EXPORTING
      container_name = 'CONTAINER_2'.

  IF grid2 IS BOUND.
    PERFORM refresh_alv USING grid2.

  ELSE.

    CREATE OBJECT grid2
      EXPORTING
        i_parent = go_cust.

    CALL METHOD grid2->set_table_for_first_display
      EXPORTING
        i_structure_name = 'VBAP'
      CHANGING
        it_outtab        = it_vbap.
  ENDIF.

ENDFORM.

FORM display_grid3 .

**    CREATE OBJECT container
**    EXPORTING
**      container_name = c_container.
*
*  CREATE OBJECT grid3
*    EXPORTING
*      i_parent = container_3.
*
*  CALL METHOD grid3->set_table_for_first_display
*    EXPORTING
*      i_structure_name = 'MAKT'
*    CHANGING
*      it_outtab        = it_makt.
ENDFORM.

MODULE user_command_9000 INPUT.

  CASE sy-ucomm.

    WHEN '&F03' OR '&F15' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.

FORM refresh_alv  USING   p_grid  TYPE REF TO cl_gui_alv_grid.
  DATA: ls_stable TYPE lvc_s_stbl.

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.

  CALL METHOD p_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = ls_stable.
ENDFORM.
