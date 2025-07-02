*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_CLASSALV_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS: get_data,
      display_alv,
      initialization,
      at_selection_screen,
      at_selection_screen_output,
      clicked,
      clicked2,
      refresh_table.

ENDCLASS.


CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD get_data.

    SELECT vbrk~vbeln,
           vbrk~fkart,
           vbrp~posnr,
           vbrk~fkdat,
           kna1~kunnr,
           vbrk~kunag,
           vbrp~matnr,
           makt~maktx,
           vbrp~fkimg,
           vbrp~vrkme,
           vbrp~netwr,
           vbrk~waerk

      INTO CORRESPONDING FIELDS OF TABLE @gt_data
      FROM vbrk
      INNER JOIN vbrp ON  vbrk~vbeln = vbrp~vbeln
      INNER JOIN kna1 ON  vbrk~kunag = kna1~kunnr
      LEFT JOIN makt  ON  makt~matnr = vbrp~matnr
                      AND makt~spras = @sy-langu
      WHERE vbrp~matnr IN @s_matnr
        AND vbrk~vbeln IN @s_vbeln
        AND kna1~kunnr IN @s_kunnr
        AND vbrk~fkdat IN @s_fkdat.

    IF p_check1 = 'X'.
      DELETE gt_data WHERE fkimg < 20.
    ENDIF.

    IF p_check2 = 'X'.
      DELETE gt_data WHERE netwr < 100000.
    ENDIF.

    LOOP AT gt_data INTO gs_data.

      IF p_check4 = 'X'.
        gs_color-fname = 'NETWR'.
        MOVE '6'         TO gs_color-color-col."renk
        MOVE '0'         TO gs_color-color-int.
        MOVE '3'         TO gs_color-color-inv. "koyuluk
        APPEND gs_color  TO gs_data-clrt.

      ENDIF.

*      IF gv_flag = 'X'.
      IF p_check3 = 'X'.
        gs_color-fname = 'FKIMG'.
        MOVE '6'         TO gs_color-color-col."renk
        MOVE '0'         TO gs_color-color-int.
        MOVE '3'         TO gs_color-color-inv. "koyuluk
        APPEND gs_color  TO gs_data-clrt.

        IF gs_data-fkimg EQ 42.

          gs_color-fname = 'KUNNR'.
          MOVE '5'         TO gs_color-color-col."renk
          MOVE '0'         TO gs_color-color-int.
          MOVE '3'         TO gs_color-color-inv. "koyuluk
          APPEND gs_color  TO gs_data-clrt.
        ENDIF.
      ENDIF.
      MODIFY  gt_data FROM gs_data.
    ENDLOOP.

  ENDMETHOD.
  METHOD display_alv.
    DATA: lt_fieldcatalog TYPE TABLE OF lvc_s_fcat.
    DATA: ls_fieldcatalog TYPE lvc_s_fcat .
    DATA: ls_layout   TYPE lvc_s_layo .

    IF grid IS NOT BOUND.

      CREATE OBJECT grid
        EXPORTING
          i_parent = cl_gui_container=>screen0.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name   = 'ZDYP12_S_ODEV2'
          i_bypassing_buffer = 'X'
        CHANGING
          ct_fieldcat        = lt_fieldcatalog[].

      LOOP AT lt_fieldcatalog ASSIGNING FIELD-SYMBOL(<fs_catalog>).
        IF <fs_catalog>-fieldname = 'WAERK'.
          <fs_catalog>-emphasize = 'C300'.
        ENDIF.
      ENDLOOP.


      DELETE lt_fieldcatalog WHERE fieldname EQ 'COLOR'.
      DELETE lt_fieldcatalog WHERE fieldname EQ 'MATERIAL_DESC'.
      DELETE lt_fieldcatalog WHERE fieldname EQ 'ERNAM'.
      DELETE lt_fieldcatalog WHERE fieldname EQ 'AENAM'.

      ls_layout-info_fname = 'COLOR'.
      ls_layout-ctab_fname = 'CLRT'.
      ls_layout-zebra = 'X'.

      CALL METHOD grid->set_table_for_first_display
        EXPORTING
*         i_structure_name = 'ZDYP12_S_ODEV2'
          is_layout       = ls_layout
          i_save          = 'X'
        CHANGING
          it_fieldcatalog = lt_fieldcatalog
          it_outtab       = gt_data.

    ENDIF.

  ENDMETHOD.
  METHOD clicked.

    "Burada bug var düzelt bir ara
    IF gv_flag  = 'X'.
      IF p_check3 IS INITIAL.
        p_check3 = 'X'.
      ELSE.
        p_check3 = ''.
        CLEAR gv_flag.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD clicked2.

    "Burada bug var düzelt bir ara
    IF gv_flag2 = 'X'.
      IF p_check4 IS INITIAL.
        p_check4 = 'X'.
      ELSE.
        p_check4 = ''.
        CLEAR gv_flag2.
      ENDIF.
    ENDIF.

  ENDMETHOD.
  METHOD refresh_table.
    DATA : ld_grid TYPE REF TO cl_gui_alv_grid.

    IF ld_grid IS INITIAL.
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
        IMPORTING
          e_grid = ld_grid.
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

  METHOD initialization.

    MOVE '@Q1@ Quantity Boyama' TO sscrfields-functxt_01.
    MOVE '@Q1@ Net Value Boyama' TO sscrfields-functxt_02.

  ENDMETHOD.
  METHOD at_selection_screen.

    IF sscrfields-ucomm = 'FC01'.
      gv_flag = 'X'.
      g_main->clicked( ).
    ENDIF.

    IF sscrfields-ucomm = 'FC02'.
      gv_flag2 = 'X'.
      g_main->clicked2( ).
    ENDIF.

  ENDMETHOD.
  METHOD at_selection_screen_output.

    LOOP AT SCREEN.
      IF screen-group1 = 'CK1'. "AND screen-name = 'p_check4' .
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
