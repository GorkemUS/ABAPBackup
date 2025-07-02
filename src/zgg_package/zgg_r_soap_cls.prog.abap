*&---------------------------------------------------------------------*
*& Include          ZGG_R_SOAP_CLS
*&---------------------------------------------------------------------*

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.

*    INTERFACES zgg_cl_wsbadi.
    CLASS-METHODS:
      hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,

      hotspot_clickteams
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id e_column_id es_row_no,

      double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_column e_row es_row_no sender,

      double_clickteams
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_column e_row es_row_no sender.


    METHODS: initialization,
      webservice IMPORTING iv_input TYPE any,
      alv_splitter,
      refresh_table IMPORTING ld_grid TYPE REF TO cl_gui_alv_grid,
      row_coloring,
      display_flag,
      display_flag2,
      display_flag3,
      display_leagues,
      display_teams,
      restapi_squads,
      display_squad,
      display_photo.

ENDCLASS.

CLASS lcl_main IMPLEMENTATION.
  METHOD webservice.

    input-iv_selection = iv_input.
    IF iv_input = 'LIG'.
      gs_item-selname = 'COUNTRY'.
      gs_item-sign    = 'I'.
      gs_item-option  = 'EQ'.
      gs_item-low     = p_ulke.
      APPEND gs_item TO input-it_rsparams-item.
    ENDIF.


    TRY.
        CREATE OBJECT lr_proxy
          EXPORTING
            logical_port_name = 'ZPORT1'.

        CALL METHOD lr_proxy->yzft_fm
          EXPORTING
            input  = input
          IMPORTING
            output = output.

      CATCH cx_ai_system_fault.
    ENDTRY.

    CASE iv_input.
      WHEN 'ULKE'.
        "Convert RAWSTRING (EV_XML) to STRING using conversion
        lr_conv = cl_abap_conv_in_ce=>create( input = output-ev_xml ).
        lr_conv->read( IMPORTING data = lv_encoded_xml ).

        CALL TRANSFORMATION zgg_transformation
          SOURCE XML lv_encoded_xml
          RESULT response = ls_countries.
      WHEN 'LIG'.
        "Convert RAWSTRING (EV_XML) to STRING using conversion
        lr_conv = cl_abap_conv_in_ce=>create( input = output-ev_xml ).
        lr_conv->read( IMPORTING data = lv_encoded_xml ).

        CALL TRANSFORMATION zgg_transleague
          SOURCE XML lv_encoded_xml
          RESULT response = ls_leagues.

      WHEN 'PUAN_DURUMU'.
        CLEAR lv_encoded_xml.
        "Convert RAWSTRING (EV_XML) to STRING using conversion
        lr_conv = cl_abap_conv_in_ce=>create( input = output-ev_xml ).
        lr_conv->read( IMPORTING data = lv_encoded_xml ).

        CALL TRANSFORMATION zgg_transteams
          SOURCE XML lv_encoded_xml
          RESULT response = gs_teams.
    ENDCASE.

  ENDMETHOD.
  METHOD initialization.

    webservice('ULKE').

    LOOP AT ls_countries-countries INTO DATA(ls_country).
      APPEND INITIAL LINE TO lt_vrm ASSIGNING FIELD-SYMBOL(<vrm>).
      <vrm>-key = ls_country-code.
      <vrm>-text = ls_country-name.
    ENDLOOP.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id              = 'P_ULKE'
        values          = lt_vrm
      EXCEPTIONS
        id_illegal_name = 1
        OTHERS          = 2.



  ENDMETHOD.
  METHOD hotspot_click.

*    IF container2 IS BOUND.
*      go_splitter->remove_control( EXPORTING row = 1
*                                      column = 2
*                           IMPORTING result = DATA(result) ).
*      CLEAR container2.
*    ENDIF.
*    CALL METHOD cl_gui_cfw=>flush.


    READ TABLE lt_leagues INTO gs_leaguelogo INDEX es_row_no-row_id.
    "convert INT4 to CHAR10
    gv_leagueidchar = CONV char10( gs_leaguelogo-id ).

    CONDENSE gv_leagueidchar.

    AUTHORITY-CHECK OBJECT 'ZGG_AO_01'
                  ID 'ACTVT' FIELD '03'
                  ID 'ULKE' FIELD p_ulke
                  ID 'LIG' FIELD gv_leagueidchar.

    IF sy-subrc EQ 0.
      MESSAGE 'Yetki kontrolü başarıyla geçildi.' TYPE 'S' .

      IF  e_column_id EQ 'ID' AND es_row_no-row_id NE 0.
*        READ TABLE lt_leagues INTO gs_leaguelogo INDEX es_row_no-row_id.
        IF sy-subrc = 0.
          go_main->display_flag2( ).
        ENDIF.
        IF container3 IS BOUND.
          go_picture1->clear_picture( ).
        ENDIF.
        gv_row_id = es_row_no-row_id.
        go_main->row_coloring( ).
        go_main->display_teams( ).

        CLEAR gt_squads.
        IF grid3 IS BOUND.
          go_main->refresh_table( ld_grid = grid3 ).
        ENDIF.
      ENDIF.

      CLEAR gs_leaguelogo.
    ELSE.
      MESSAGE 'Bu ligi görüntülemeye yetkiniz yoktur' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.


  ENDMETHOD.
  METHOD hotspot_clickteams.



    IF  e_column_id EQ 'TEAM_NAME' AND es_row_no-row_id NE 0.
      READ TABLE gt_teams INTO ls_teams INDEX es_row_no-row_id.


      "convert INT4 to CHAR10
      gv_teamidchar = CONV char10( ls_teams-team_id ).

      CONDENSE gv_teamidchar.

      AUTHORITY-CHECK OBJECT 'ZGG_AO_01'
                    ID 'ACTVT' FIELD '03'
                    ID 'ULKE' FIELD p_ulke
*                    ID 'LIG' FIELD gv_leagueidchar
                    ID 'TAKIM' FIELD gv_teamidchar.

      IF sy-subrc EQ 0.
        MESSAGE 'Yetki kontrolü başarıyla geçildi.' TYPE 'S' .

        IF sy-subrc = 0.
          go_main->display_flag3( ).
        ENDIF.
        gv_rowteam_id = es_row_no-row_id.
        go_main->row_coloring( ).
        go_main->restapi_squads( ).
      ELSE.
        MESSAGE 'Bu takımı görüntülemeye yetkiniz yoktur' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
*      IF container3 IS BOUND.
*        go_splitter->remove_control( EXPORTING row = 1
*                                        column = 3
*                             IMPORTING result = DATA(result) ).
*        CLEAR container3.
*      ENDIF.
*      CALL METHOD cl_gui_cfw=>flush.


    ELSEIF e_column_id = 'NAME' AND es_row_no-row_id NE 0.
      READ TABLE gt_squads INTO gs_playerphoto INDEX es_row_no-row_id.
      READ TABLE gt_player INTO DATA(ls_info) WITH KEY id = gs_playerphoto-id.

      IF sy-subrc <> 0.
        gv_uname = sy-uname.
        gv_datum  = sy-datum.
        gv_uzeit  = sy-uzeit.
      ELSE.
        gv_uname = ls_info-user_name.
        gv_datum  = ls_info-change_date.
        gv_uzeit  = ls_info-change_time.
      ENDIF.

      CLEAR gv_flag.

      gv_rowplayer_id = es_row_no-row_id.
      go_main->display_photo( ).

    ENDIF.

*    CLEAR gs_leaguelogo.
  ENDMETHOD.
  METHOD double_click.
*
*    IF container2 IS BOUND.
*      go_splitter->remove_control( EXPORTING row = 1
*                                      column = 2
*                           IMPORTING result = DATA(result) ).
*      CLEAR container2.
*    ENDIF.
*    CALL METHOD cl_gui_cfw=>flush.

    READ TABLE lt_leagues INTO gs_leaguelogo INDEX es_row_no-row_id.

    gv_leagueidchar = CONV char10( gs_leaguelogo-id ).
    CONDENSE gv_leagueidchar.

    AUTHORITY-CHECK OBJECT 'ZGG_AO_01'
                  ID 'ACTVT' FIELD '03'
                  ID 'ULKE' FIELD p_ulke
                  ID 'LIG' FIELD gv_leagueidchar.

    IF sy-subrc EQ 0.
      MESSAGE 'Yetki kontrolü başarıyla geçildi.' TYPE 'S' .

      IF sy-subrc = 0.
        go_main->display_flag2( ).
      ENDIF.

      CLEAR gt_squads.
      IF grid3 IS BOUND.
        go_main->refresh_table( ld_grid = grid3 ).
      ENDIF.

      IF container3 IS BOUND.
        go_picture1->clear_picture( ).
      ENDIF.

      gv_row_id = es_row_no-row_id.
      go_main->row_coloring( ).
      go_main->display_teams( ).

      CLEAR gs_leaguelogo.

    ELSE.
      MESSAGE 'Bu ülke liglerini görüntülemeye yetkiniz yoktur' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

  ENDMETHOD.
  METHOD double_clickteams.
*    IF container3 IS BOUND.
*      go_splitter->remove_control( EXPORTING row = 1
*                                      column = 3
*                           IMPORTING result = DATA(result) ).
*      CLEAR container3.
*    ENDIF.
*    CALL METHOD cl_gui_cfw=>flush.

    READ TABLE gt_teams INTO ls_teams INDEX es_row_no-row_id.

    "convert INT4 to CHAR10
    gv_teamidchar = CONV char10( ls_teams-team_id ).

    CONDENSE gv_teamidchar.

    AUTHORITY-CHECK OBJECT 'ZGG_AO_01'
                  ID 'ACTVT' FIELD '03'
                  ID 'ULKE' FIELD p_ulke
*                  ID 'LIG' FIELD gv_leagueidchar
                  ID 'TAKIM' FIELD gv_teamidchar.

    IF sy-subrc EQ 0.
      MESSAGE 'Yetki kontrolü başarıyla geçildi.' TYPE 'S' .

      IF sy-subrc = 0.
        go_main->display_flag3( ).
        go_main->restapi_squads( ).
      ENDIF.
      gv_rowteam_id = es_row_no-row_id.
      go_main->row_coloring( ).

    ELSE.
      MESSAGE 'Bu ligi görüntülemeye yetkiniz yoktur' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.


  ENDMETHOD.
  METHOD row_coloring.

    IF grid IS BOUND.
      READ TABLE lt_leagues INTO DATA(ls_coloring) INDEX gv_row_id.
      LOOP AT lt_leagues INTO DATA(ls_league).
        ls_league-rowcolor = ' '.
        IF ls_league-id = ls_coloring-id.
          ls_league-rowcolor = 'C311'.
        ENDIF.
        MODIFY lt_leagues FROM ls_league.
      ENDLOOP.
      go_main->refresh_table( ld_grid = grid ).
    ENDIF.
    IF grid2 IS BOUND.
      READ TABLE gt_teams INTO DATA(ls_teamcolor) INDEX gv_rowteam_id.
      LOOP AT gt_teams INTO DATA(ls_team).
        ls_team-rowcolor = ' '.
        IF ls_team-team_id = ls_teamcolor-team_id.
          ls_team-rowcolor = 'C311'.
        ENDIF.
        MODIFY gt_teams FROM ls_team.
      ENDLOOP.
      go_main->refresh_table( ld_grid = grid2 ).
    ENDIF.

  ENDMETHOD.
  METHOD alv_splitter.

    CREATE OBJECT go_splitter
      EXPORTING
        parent  = cl_gui_container=>default_screen
        rows    = 2
        columns = 3.

    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = container1.
*    CALL METHOD go_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 2
*      RECEIVING
*        container = container2.
*    CALL METHOD go_splitter->get_container
*      EXPORTING
*        row       = 1
*        column    = 3
*      RECEIVING
*        container = container3.
    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = container4.
    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 2
        column    = 2
      RECEIVING
        container = container5.
    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 2
        column    = 3
      RECEIVING
        container = container6.

    CALL METHOD go_splitter->set_row_height
      EXPORTING
        id                = 2                 " Row ID
        height            = 70                " Height
      EXCEPTIONS
        cntl_error        = 1                " See CL_GUI_CONTROL
        cntl_system_error = 2                " See CL_GUI_CONTROL
        OTHERS            = 3.


  ENDMETHOD.
  METHOD display_flag.
    DATA: lo_gui_html_viewer TYPE REF TO cl_gui_html_viewer,
          lv_url(200)        TYPE c.

    CREATE OBJECT lo_gui_html_viewer
      EXPORTING
        parent             = container1                 " Container
      EXCEPTIONS
        cntl_error         = 1                " error in call method of ooCFW
        cntl_install_error = 2                " HTML control was not installed properly
        dp_install_error   = 3                " DataProvider was not installed properly
        dp_error           = 4                " error in call of DataProvider function
        OTHERS             = 5.


    READ TABLE ls_countries-countries INTO DATA(ls_country) WITH KEY code = p_ulke.
    lv_url = ls_country-flag.

*    CREATE OBJECT go_picture
*      EXPORTING
*        parent             = container1       .
*
*
*    go_picture->load_picture_from_url_async(
*      EXPORTING
*        url    = lv_url                 " URL
**      EXCEPTIONS
**        error  = 1                " Errors
**        others = 2
*    ).
*    IF sy-subrc <> 0.
**     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

**
*    go_picture->set_display_mode(
*      EXPORTING
*        display_mode =   1               " Display Mode
**      EXCEPTIONS
**        error        = 1                " Errors
**        others       = 2
*    ).
*    IF sy-subrc <> 0.
**     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    ENDIF.

*
    DATA: lw_html TYPE w3html,
          it_html TYPE STANDARD TABLE OF w3html.
    "230
    lw_html-line = '<html><body style="margin:0; padding:0; width: 380px; height: 255px;">' &&
               '<img src="' && lv_url && '" style="width: 150%; height: 100%; "/>' &&
               '</body></html>'.


    APPEND lw_html TO it_html.

    lo_gui_html_viewer->load_data(
      IMPORTING assigned_url = lv_url
        CHANGING data_table = it_html ).


    lo_gui_html_viewer->show_url(
      EXPORTING
        url                    = lv_url           " URL
*        frame                  = '20'
        in_place               = 'X'              " Is the document displayed in the GUI?
      EXCEPTIONS
        cntl_error             = 1                " Error in CFW Call
        cnht_error_not_allowed = 2                " Navigation outside R/3 is not allowed
        cnht_error_parameter   = 3                " Incorrect parameters
        dp_error_general       = 4                " Error in DP FM call
        OTHERS                 = 5
    ).


  ENDMETHOD.
  METHOD display_leagues.
    DATA: lt_fc1    TYPE  lvc_t_fcat,
          ls_layout TYPE lvc_s_layo.


    webservice( 'LIG' ).

    LOOP AT ls_leagues-leagues INTO DATA(ls_league) WHERE country = p_ulke.
      APPEND ls_league TO lt_leagues.
    ENDLOOP.

    CREATE OBJECT grid
      EXPORTING
        i_parent = container4.

    DATA: lcl_alv_event TYPE REF TO lcl_main.

    CREATE OBJECT lcl_alv_event.

    SET HANDLER:  lcl_alv_event->hotspot_click  FOR grid.
    SET HANDLER:  lcl_alv_event->double_click  FOR grid.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       I_BUFFER_ACTIVE    =
        i_structure_name   = 'ZGG_S_LEAGUE'
*       I_CLIENT_NEVER_DISPLAY       = 'X'
        i_bypassing_buffer = 'X'
*       I_INTERNAL_TABNAME =
      CHANGING
        ct_fieldcat        = lt_fc1.

    ls_layout-info_fname = 'ROWCOLOR'.
    ls_layout-no_toolbar = abap_true.
    ls_layout-zebra = abap_true.

    LOOP AT lt_fc1 ASSIGNING FIELD-SYMBOL(<fs_fc1>).
      IF <fs_fc1>-fieldname = 'NAME'.
        <fs_fc1>-scrtext_s = 'League'.
        <fs_fc1>-scrtext_m = 'League Name'.
        <fs_fc1>-scrtext_l = 'League Name'.
      ELSEIF <fs_fc1>-fieldname = 'ID'.
        <fs_fc1>-hotspot = abap_true.
        <fs_fc1>-scrtext_s =
        <fs_fc1>-scrtext_m =
        <fs_fc1>-scrtext_l =
        <fs_fc1>-reptext = 'ID'.
      ELSEIF <fs_fc1>-fieldname = 'LOGO'.
        <fs_fc1>-tech = abap_true.
      ELSEIF <fs_fc1>-fieldname = 'MANDT'.
        <fs_fc1>-tech = abap_true.
      ELSEIF <fs_fc1>-fieldname = 'COUNTRY'.
        <fs_fc1>-tech = abap_true.
      ELSEIF <fs_fc1>-fieldname = 'ROWCOLOR'.
        <fs_fc1>-tech = abap_true.
      ENDIF.
    ENDLOOP.

    CALL METHOD grid->set_table_for_first_display
      EXPORTING
        is_layout                     = ls_layout
*       i_structure_name              = 'ZGG_S_SOAP'     " Internal Output Table Structure Name
      CHANGING
        it_outtab                     = lt_leagues           " Output Table
        it_fieldcatalog               = lt_fc1              " Field Catalog
*       it_sort                       =                  " Sort Criteria
*       it_filter                     =                  " Filter Criteria
      EXCEPTIONS
        invalid_parameter_combination = 1                " Wrong Parameter
        program_error                 = 2                " Program Errors
        too_many_lines                = 3                " Too many Rows in Ready for Input Grid
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.
  METHOD display_flag2.
    DATA: lo_gui_html_viewer TYPE REF TO cl_gui_html_viewer.
    DATA:    lv_url(200)        TYPE c.


    lv_url = gs_leaguelogo-logo.

    IF container2 IS NOT BOUND.

      CALL METHOD go_splitter->get_container
        EXPORTING
          row       = 1
          column    = 2
        RECEIVING
          container = container2.

      CREATE OBJECT go_picture
        EXPORTING
*         lifetime   =                  " Lifetime
*         shellstyle =                  " Shell Style
          parent = container2                " Parent Container
*         name   =                  " Name
*        EXCEPTIONS
*         error  = 1                " Errors
*         others = 2
        .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      go_picture->load_picture_from_url_async(
        EXPORTING
          url    =  lv_url                " URL
      ).

      go_picture->set_display_mode(
        EXPORTING
          display_mode =  4                " Display Mode
      ).
    ENDIF.

    IF container2 IS BOUND.

      go_picture->load_picture_from_url_async(
        EXPORTING
          url    =  lv_url                " URL
*        EXCEPTIONS
*          error  = 1                " Errors
*          others = 2
      ).
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.

*    IF container2 IS NOT BOUND.
*      CALL METHOD go_splitter->get_container
*        EXPORTING
*          row       = 1
*          column    = 2
*        RECEIVING
*          container = container2.
*
*      CREATE OBJECT lo_gui_html_viewer
*        EXPORTING
*          parent             = container2                 " Container
*        EXCEPTIONS
*          cntl_error         = 1                " error in call method of ooCFW
*          cntl_install_error = 2                " HTML control was not installed properly
*          dp_install_error   = 3                " DataProvider was not installed properly
*          dp_error           = 4                " error in call of DataProvider function
*          OTHERS             = 5.
*
*
*      lo_gui_html_viewer->show_url(
*        EXPORTING
*          url                    = lv_url           " URL
*          in_place               = 'X'              " Is the document displayed in the GUI?
*        EXCEPTIONS
*          cntl_error             = 1                " Error in CFW Call
*          cnht_error_not_allowed = 2                " Navigation outside R/3 is not allowed
*          cnht_error_parameter   = 3                " Incorrect parameters
*          dp_error_general       = 4                " Error in DP FM call
*          OTHERS                 = 5
*      ).
*    ENDIF.
**      CLEAR lo_gui_html_viewer.

  ENDMETHOD.
  METHOD display_teams.
    DATA: lt_fc2    TYPE  lvc_t_fcat,
          ls_fc2    TYPE lvc_s_fcat,
          ls_layout TYPE lvc_s_layo.

    DATA : lv_full_icons TYPE string.

    CLEAR gt_teams.

    webservice( 'PUAN_DURUMU' ).

    READ TABLE lt_leagues INTO DATA(ls_leagueid) INDEX gv_row_id.

    gs_item-selname = 'LIG'.
    gs_item-sign = 'I'.
    gs_item-option = 'EQ'.
    gs_item-low = ls_leagueid-id.

    LOOP AT gs_teams-puan_durumu INTO DATA(ls_teams) WHERE league = ls_leagueid-id.
      APPEND ls_teams TO gt_teams.
    ENDLOOP.


*    LOOP AT gt_teams INTO DATA(ls_icon).
**      CLEAR lv_full_icons.
*      DATA(lv_len) = strlen( ls_icon-form ).
*      DO lv_len TIMES.
*
*        DATA lv_icon TYPE icon_d.
*        DATA(lv_index) = sy-index - 1.
*        CLEAR lv_icon.
*
*        lv_icon = ls_icon-form+lv_index(1).
*        CASE lv_icon.
*          WHEN 'W'.
*            lv_icon = icon_led_green.
*          WHEN 'D'.
*            lv_icon = icon_led_yellow.
*          WHEN 'L'.
*            lv_icon = icon_led_red.
*        ENDCASE.
*        CONCATENATE lv_icon lv_full_icons INTO lv_full_icons SEPARATED BY space .
*        lv_index += 1.
*      ENDDO.
*      ls_icon-form = lv_full_icons.
*      MODIFY gt_teams FROM ls_icon.
*    ENDLOOP.

    IF gt_teams IS INITIAL AND go_picture1 IS NOT INITIAL.

      go_picture1->clear_picture(
        EXCEPTIONS
          error  = 1                " Errors
          OTHERS = 2
      ).

*      IF container3 IS BOUND.
*        go_splitter->remove_control( EXPORTING row = 1
*                                        column = 3
*                             IMPORTING result = DATA(result) ).
*        CLEAR container3.
*      ENDIF.
*
*      CALL METHOD cl_gui_cfw=>flush.
    ENDIF.


    IF grid2 IS NOT BOUND.

      CREATE OBJECT grid2
        EXPORTING
          i_parent = container5.

      DATA: lcl_alv_event TYPE REF TO lcl_main.

      CREATE OBJECT lcl_alv_event.

      SET HANDLER:  lcl_alv_event->hotspot_clickteams  FOR grid2.
      SET HANDLER:  lcl_alv_event->double_clickteams  FOR grid2.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
*         I_BUFFER_ACTIVE    =
          i_structure_name   = 'ZGG_S_TEAMS'
*         I_CLIENT_NEVER_DISPLAY       = 'X'
          i_bypassing_buffer = 'X'
*         I_INTERNAL_TABNAME =
        CHANGING
          ct_fieldcat        = lt_fc2.

      ls_layout-col_opt = 'X'.
      ls_layout-info_fname = 'ROWCOLOR'.
      ls_layout-zebra = 'X'.
      ls_layout-no_toolbar = abap_true.


      LOOP AT lt_fc2 ASSIGNING FIELD-SYMBOL(<fs_fc2>).
        IF <fs_fc2>-fieldname = 'TEAM_NAME'.
          <fs_fc2>-outputlen = 20.
          <fs_fc2>-coltext = 'Team Name'.
          <fs_fc2>-hotspot = 'X'.
        ELSEIF <fs_fc2>-fieldname = 'FORM'.
          <fs_fc2>-col_pos = 13.
          <fs_fc2>-outputlen = 15.
          <fs_fc2>-coltext = 'Form'.
          <fs_fc2>-icon = 'X'.
        ELSEIF <fs_fc2>-fieldname = 'LOGO'.
          <fs_fc2>-tech = abap_true.
        ELSEIF <fs_fc2>-fieldname = 'TEAM_ID'.
          <fs_fc2>-tech = abap_true.
        ELSEIF <fs_fc2>-fieldname = 'LEAGUE'.
          <fs_fc2>-tech = abap_true.
        ELSEIF <fs_fc2>-fieldname = 'COUNTRY'.
          <fs_fc2>-tech = abap_true.
        ELSEIF <fs_fc2>-fieldname = 'RANK'.
          <fs_fc2>-coltext = 'Rank'.
        ELSEIF <fs_fc2>-fieldname = 'POINTS'.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-tech = abap_true.
          <fs_fc2>-coltext = 'Points'.
        ELSEIF <fs_fc2>-fieldname = 'GOALSDIFF'.
          <fs_fc2>-outputlen = 6.
          <fs_fc2>-col_pos = 10.
          <fs_fc2>-coltext = 'Goals Diff'.
        ELSEIF <fs_fc2>-fieldname = 'PLAYED'.
          <fs_fc2>-col_pos = 6.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-coltext = 'Played'.
        ELSEIF <fs_fc2>-fieldname = 'WIN'.
          <fs_fc2>-col_pos = 7.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-coltext = 'Win'.
        ELSEIF <fs_fc2>-fieldname = 'DRAW'.
          <fs_fc2>-col_pos = 8.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-coltext = 'Draw'.
        ELSEIF <fs_fc2>-fieldname = 'LOSE'.
          <fs_fc2>-col_pos = 9.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-coltext = 'Lose'.
        ELSEIF <fs_fc2>-fieldname = 'FOR_'.
          <fs_fc2>-col_pos = 11.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-coltext = 'Scored'.
        ELSEIF <fs_fc2>-fieldname = 'AGAINST'.
          <fs_fc2>-col_pos = 12.
          <fs_fc2>-outputlen = 5.
          <fs_fc2>-coltext = 'Eaten'.
        ELSEIF <fs_fc2>-fieldname = 'ROWCOLOR'.
          <fs_fc2>-tech = abap_true.
        ENDIF.
      ENDLOOP.

      CALL METHOD grid2->set_table_for_first_display
        EXPORTING
          is_layout                     = ls_layout
        CHANGING
          it_outtab                     = gt_teams           " Output Table
          it_fieldcatalog               = lt_fc2             " Field Catalog
*         it_sort                       =                  " Sort Criteria
*         it_filter                     =                  " Filter Criteria
        EXCEPTIONS
          invalid_parameter_combination = 1                " Wrong Parameter
          program_error                 = 2                " Program Errors
          too_many_lines                = 3                " Too many Rows in Ready for Input Grid
          OTHERS                        = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      go_main->refresh_table( ld_grid = grid2 ).
    ENDIF.

  ENDMETHOD.
  METHOD display_flag3.

    DATA: lo_gui_html_viewer TYPE REF TO cl_gui_html_viewer,
          lv_url2(200)       TYPE c.

    lv_url2 = ls_teams-logo.

    IF container3 IS NOT BOUND.

      CALL METHOD go_splitter->get_container
        EXPORTING
          row       = 1
          column    = 3
        RECEIVING
          container = container3.

      CREATE OBJECT go_picture1
        EXPORTING
*         lifetime   =                  " Lifetime
*         shellstyle =                  " Shell Style
          parent = container3                " Parent Container
*         name   =                  " Name
*        EXCEPTIONS
*         error  = 1                " Errors
*         others = 2
        .
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      go_picture1->load_picture_from_url_async(
        EXPORTING
          url    =  lv_url2                " URL
      ).

      go_picture1->set_display_mode(
        EXPORTING
          display_mode =  4                " Display Mode
      ).
    ENDIF.

    IF container3 IS BOUND.

      go_picture1->load_picture_from_url_async(
        EXPORTING
          url    =  lv_url2                " URL
*        EXCEPTIONS
*          error  = 1                " Errors
*          others = 2
      ).
      IF sy-subrc <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

    ENDIF.

*    IF container3 IS NOT BOUND.
*      CALL METHOD go_splitter->get_container
*        EXPORTING
*          row       = 1
*          column    = 3
*        RECEIVING
*          container = container3.
*
*      CREATE OBJECT lo_gui_html_viewer
*        EXPORTING
*          parent             = container3                 " Container
*        EXCEPTIONS
*          cntl_error         = 1                " error in call method of ooCFW
*          cntl_install_error = 2                " HTML control was not installed properly
*          dp_install_error   = 3                " DataProvider was not installed properly
*          dp_error           = 4                " error in call of DataProvider function
*          OTHERS             = 5.
*

*
*      lo_gui_html_viewer->show_url(
*        EXPORTING
*          url                    = lv_url           " URL
*          in_place               = 'X'              " Is the document displayed in the GUI?
*        EXCEPTIONS
*          cntl_error             = 1                " Error in CFW Call
*          cnht_error_not_allowed = 2                " Navigation outside R/3 is not allowed
*          cnht_error_parameter   = 3                " Incorrect parameters
*          dp_error_general       = 4                " Error in DP FM call
*          OTHERS                 = 5
*      ).
*    ENDIF.
*    CLEAR lo_gui_html_viewer.



  ENDMETHOD.
  METHOD restapi_squads.


*http Client Abstraction
    DATA  lo_client TYPE REF TO if_http_client.

*Data variables for storing response in xstring and string
    DATA  : lv_xstring   TYPE xstring,
            lv_string    TYPE string,
            lv_node_name TYPE string.

*Pass the URL to get Data
    lv_string = 'https://api-football-v1.p.rapidapi.com/v3/players/squads?team=' && ls_teams-team_id.
    CONDENSE lv_string NO-GAPS.

*Creation of New IF_HTTP_Client Object
    cl_http_client=>create_by_url(
    EXPORTING
      url                = lv_string
    IMPORTING
      client             = lo_client
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      ).
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

    lo_client->propertytype_logon_popup = lo_client->co_disabled.
    lo_client->request->set_method( 'GET' ).
    lo_client->request->set_header_field(
      EXPORTING
        name  = 'x-rapidapi-host'                 " Name of the header field
        value = 'api-football-v1.p.rapidapi.comf'  " HTTP header field value
    ).
    lo_client->request->set_header_field(
      EXPORTING
        name  = 'x-rapidapi-key'                 " Name of the header field
        value = '04ce2a23e7msh5a26d760d94b3a0p195281jsn9e189d0df35f'  " HTTP header field value
    ).

*Structure of HTTP Connection and Dispatch of Data
    lo_client->send(
*      EXPORTING
*        timeout                    = co_timeout_default " Timeout of Answer Waiting Time
      EXCEPTIONS
        http_communication_failure = 1                  " Communication Error
        http_invalid_state         = 2                  " Invalid state
        http_processing_failed     = 3                  " Error when processing method
        http_invalid_timeout       = 4                  " Invalid Time Entry
        OTHERS                     = 5
    ).
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

*Receipt of HTTP Response
    lo_client->receive(
      EXCEPTIONS
        http_communication_failure = 1                " Communication Error
        http_invalid_state         = 2                " Invalid state
        http_processing_failed     = 3                " Error when processing method
        OTHERS                     = 4
    ).
    IF sy-subrc IS NOT INITIAL.
      RETURN.
    ENDIF.

*Return the HTTP body of this entity as binary data
    lv_xstring = lo_client->response->get_data( ).

    /ui2/cl_json=>deserialize(
    EXPORTING
      jsonx            = lv_xstring         " JSON XString
    CHANGING
      data             = gs_squad
            ).

    IF gs_squad IS NOT INITIAL.
      go_main->display_squad( ).
    ENDIF.

  ENDMETHOD.
  METHOD display_squad.
    DATA: lt_fc3    TYPE  lvc_t_fcat,
          ls_layout TYPE lvc_s_layo.

    gt_squads = gs_squad-response[ 1 ]-players.

    SELECT * FROM zgg_t_player INTO TABLE gt_player.

    LOOP AT gt_squads INTO DATA(ls_player).
      READ TABLE gt_player INTO DATA(ls_slcplayer) WITH KEY id = ls_player-id.
      IF sy-subrc EQ 0.
        ls_player-name = ls_slcplayer-name.
        ls_player-age = ls_slcplayer-age.
        ls_player-number = ls_slcplayer-forma_no.
        ls_player-position = ls_slcplayer-pozisyon.

        MODIFY gt_squads FROM ls_player.
      ENDIF.
    ENDLOOP.

*    IF container6 IS BOUND.
*
*      FREE container6.
*
*      go_splitter->remove_control(
*        EXPORTING
*          row               =  2                 " Row
*          column            =  3                " Column
*      ).
*
*    ENDIF.
*
*
*    CALL METHOD go_splitter->get_container
*      EXPORTING
*        row       = 2
*        column    = 3
*      RECEIVING
*        container = container6.

    IF grid3 IS NOT BOUND.

      CREATE OBJECT grid3
        EXPORTING
          i_parent = container6.

      DATA: lcl_alv_event TYPE REF TO lcl_main.

      CREATE OBJECT lcl_alv_event.

      SET HANDLER:  lcl_alv_event->hotspot_clickteams  FOR grid3.
*      SET HANDLER:  lcl_alv_event->double_clickteams  FOR grid3.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
*         I_BUFFER_ACTIVE    =
          i_structure_name   = 'ZGG_S_SQUAD'
*         I_CLIENT_NEVER_DISPLAY       = 'X'
          i_bypassing_buffer = 'X'
*         I_INTERNAL_TABNAME =
        CHANGING
          ct_fieldcat        = lt_fc3.

      ls_layout-no_toolbar = abap_true.
      ls_layout-zebra = abap_true.


      LOOP AT lt_fc3 ASSIGNING FIELD-SYMBOL(<fs_fc3>).
        IF <fs_fc3>-fieldname = 'NUMBER'.
          <fs_fc3>-col_pos = 1.
          <fs_fc3>-outputlen = 3.
          <fs_fc3>-coltext = 'Number'.
        ELSEIF <fs_fc3>-fieldname = 'POSITION'.
          <fs_fc3>-col_pos = 2.
          <fs_fc3>-outputlen = 15.
          <fs_fc3>-coltext = 'Position'.
        ELSEIF <fs_fc3>-fieldname = 'NAME'.
          <fs_fc3>-col_pos = 3.
          <fs_fc3>-outputlen = 20.
          <fs_fc3>-hotspot = 'X'.
          <fs_fc3>-coltext = 'Name'.
        ELSEIF <fs_fc3>-fieldname = 'AGE'.
          <fs_fc3>-col_pos = 4.
          <fs_fc3>-outputlen = 5.
          <fs_fc3>-coltext = 'Age'.
        ELSEIF <fs_fc3>-fieldname = 'ID'.
          <fs_fc3>-tech = abap_true.
        ELSEIF <fs_fc3>-fieldname = 'PHOTO'.
          <fs_fc3>-tech = abap_true.
        ENDIF.
      ENDLOOP.


      CALL METHOD grid3->set_table_for_first_display
        EXPORTING
          is_layout                     = ls_layout
*         i_structure_name              = 'ZGG_S_SOAP'     " Internal Output Table Structure Name
        CHANGING
          it_outtab                     = gt_squads        " Output Table
          it_fieldcatalog               = lt_fc3              " Field Catalog
*         it_sort                       =                  " Sort Criteria
*         it_filter                     =                  " Filter Criteria
        EXCEPTIONS
          invalid_parameter_combination = 1                " Wrong Parameter
          program_error                 = 2                " Program Errors
          too_many_lines                = 3                " Too many Rows in Ready for Input Grid
          OTHERS                        = 4.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
      go_main->refresh_table( ld_grid = grid3 ).
    ENDIF.

  ENDMETHOD.
  METHOD display_photo.

    CALL SCREEN 0200 STARTING AT 40 5
                     ENDING AT 200 30.

  ENDMETHOD.
  METHOD refresh_table.

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
*  METHOD zgg_cl_wsbadi~before_save.
*
*
*
*
*  ENDMETHOD.
*  METHOD zgg_cl_wsbadi~after_save.
*
*
*  ENDMETHOD.
ENDCLASS.
