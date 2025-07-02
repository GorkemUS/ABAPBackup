*&---------------------------------------------------------------------*
*& Include          ZGG_R_SOAP_SCR
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'TITLE'.

  AUTHORITY-CHECK OBJECT 'ZGG_AO_01'
               ID 'ACTVT' FIELD '03'
               ID 'ULKE' FIELD p_ulke.

  IF sy-subrc EQ 0.
    MESSAGE 'Yetki kontrolü başarıyla geçildi.' TYPE 'S' .

    go_main->alv_splitter( ).
    go_main->display_flag( ).
    go_main->display_leagues( ).

  ELSE.
    MESSAGE 'Bu ülke liglerini görüntülemeye yetkiniz yoktur' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN 0.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  SET PF-STATUS 'STANDARD'.

  DATA: lo_gui_html_viewer2 TYPE REF TO cl_gui_html_viewer,
        lv_url2(200)        TYPE c,
        lv_btn              TYPE char10.

  DATA: lv_name TYPE thead-tdname.

  lv_url2 = gs_playerphoto-photo.

  LOOP AT SCREEN.
    IF gv_flag IS INITIAL.
      lv_btn = 'Değiştir'.
      IF screen-name = 'SAVE'.
        screen-invisible = 1.
        MODIFY SCREEN.
      ELSEIF screen-group1 = 'G1'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
      MODIFY SCREEN.
    ELSEIF gv_flag IS NOT INITIAL.
      lv_btn = 'Görüntüle'.
      IF screen-group2 = 'G2'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


  IF text_cont IS INITIAL.

    CREATE OBJECT text_cont
      EXPORTING
        container_name              = 'TEXT_CONT'      " Name of the Screen CustCtrl Name to Link Container To
      EXCEPTIONS
        cntl_error                  = 1                " CNTL_ERROR
        cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
        create_error                = 3                " CREATE_ERROR
        lifetime_error              = 4                " LIFETIME_ERROR
        lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
        OTHERS                      = 6.

  ENDIF.

  IF text_edit IS NOT BOUND.
    CREATE OBJECT text_edit
      EXPORTING
        parent = text_cont.
  ENDIF.

  lv_name = gs_playerphoto-id.

  CLEAR: lt_tline, gt_text.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
*     CLIENT                  = SY-MANDT
      id                      = 'TID'
      language                = 'E'
      name                    = lv_name
      object                  = 'ZGG_TO_01'
*     ARCHIVE_HANDLE          = 0
*     LOCAL_CAT               = ' '
*   IMPORTING
*     HEADER                  = HEADER
*     OLD_LINE_COUNTER        = OLD_LINE_COUNTER
    TABLES
      lines                   = lt_tline
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.


  LOOP AT lt_tline INTO DATA(ls_lines2).

    APPEND ls_lines2 TO gt_text.

  ENDLOOP.

  CALL METHOD text_edit->set_text_as_r3table
    EXPORTING
      table           = gt_text
    EXCEPTIONS
      error_dp        = 1
      error_dp_create = 2
      OTHERS          = 3.



  IF gv_flag IS INITIAL.

    CALL METHOD text_edit->set_readonly_mode
      EXPORTING
        readonly_mode          = 1
      EXCEPTIONS
        error_cntl_call_method = 1
        invalid_parameter      = 2
        OTHERS                 = 3.

  ENDIF.

  IF custom_cont IS BOUND.

    custom_cont->free(
     EXCEPTIONS
       cntl_error        = 1                " CNTL_ERROR
       cntl_system_error = 2                " CNTL_SYSTEM_ERROR
       OTHERS            = 3
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    FREE custom_cont.

  ENDIF.

  IF custom_cont IS NOT BOUND.

    CREATE OBJECT custom_cont
      EXPORTING
        container_name              = 'CCONT' " Name of the Screen CustCtrl Name to Link Container To
      EXCEPTIONS
        cntl_error                  = 1                " CNTL_ERROR
        cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
        create_error                = 3                " CREATE_ERROR
        lifetime_error              = 4                " LIFETIME_ERROR
        lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
        OTHERS                      = 6.

    CREATE OBJECT go_picture1
      EXPORTING
        parent = custom_cont.                " Parent Container

    go_picture1->load_picture_from_url_async(
      EXPORTING
        url    =  lv_url2                " URL
    ).

    go_picture1->set_display_mode(
      EXPORTING
        display_mode =  4                " Display Mode
    ).
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.


  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F15'.
      DATA: lv_answer TYPE char1.

      IF gv_flag IS INITIAL.
        LEAVE TO SCREEN 0.
      ELSEIF gv_flag IS NOT INITIAL.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            text_question         = 'Changes that are not saved will be lost. Do you want to continue?'
            text_button_1         = 'Yes'
            icon_button_1         = 'ICON_CHECKED'
            text_button_2         = 'No'
            icon_button_2         = 'ICON_INCOMPLETE'
            display_cancel_button = space
          IMPORTING
            answer                = lv_answer
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.

        IF lv_answer = '1'.
          LEAVE TO SCREEN 0.
        ENDIF.
      ENDIF.

    WHEN '&DEG'.

      DATA: lv_rc TYPE sy-subrc.

      CREATE OBJECT go_cl.

      READ TABLE ls_leagues-leagues INTO DATA(ls_ulke) WITH KEY country = p_ulke.

      gv_player = gs_playerphoto-id.
      gv_ulke = ls_ulke-country.
      gv_lig = ls_teams-team_id.
      gs_block-player_id = gs_playerphoto-id.

      go_cl->zgg_cl_wsbadi~before_save(
        EXPORTING
          iv_ulke    = gv_ulke
          iv_lig     = gv_lig
          iv_player  = gv_player
        IMPORTING
          ev_rc      =  lv_rc
        CHANGING
          ls_strbadi = gs_block
      ).

      IF lv_rc = 4.
        MESSAGE 'Bu oyuncuya erişim sistem tarafından kısıtlanmıştır.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      "convert INT4 to CHAR10
      gv_teamidchar = CONV char10( ls_teams-team_id ).

      CONDENSE gv_teamidchar.

      AUTHORITY-CHECK OBJECT 'ZGG_AO_01'
                    ID 'ACTVT' FIELD '02'
                    ID 'ULKE' FIELD p_ulke
                    ID 'LIG' FIELD gv_leagueidchar
                    ID 'TAKIM' FIELD gv_teamidchar.

      IF sy-subrc EQ 0.
        MESSAGE 'Yetki kontrolü başarıyla geçildi.' TYPE 'S' .

        IF gv_flag IS INITIAL.
          gv_flag = 1.
        ELSEIF gv_flag IS NOT INITIAL.
          CLEAR gv_flag.
        ENDIF.

        CALL FUNCTION 'ENQUEUE_EZGG_PLAYER'
          EXPORTING
            mode_zgg_t_player = 'E'
*           mandt             = sy-mandt
            id                = gs_playerphoto-id
*           X_ID              = ' '
*           _SCOPE            = '2'
*           _WAIT             = ' '
*           _COLLECT          = ' '
          EXCEPTIONS
            foreign_lock      = 1
            system_failure    = 2
            OTHERS            = 3.

        IF sy-subrc = 1.

          MESSAGE | { sy-uname } Tarafından kontrol ediliyor. | TYPE 'E'.

        ENDIF.


        IF gv_flag IS NOT INITIAL.
          CALL METHOD text_edit->set_readonly_mode
            EXPORTING
              readonly_mode          = 0
            EXCEPTIONS
              error_cntl_call_method = 1
              invalid_parameter      = 2
              OTHERS                 = 3.
        ENDIF.

      ELSE.
        MESSAGE 'Bu futbolcuyu değiştirme yetkiniz yoktur.' TYPE 'S' DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.
    WHEN '&KAYDET'.

      gs_log-player_id = gs_playerphoto-id.

      go_cl->zgg_cl_wsbadi~after_save(
        EXPORTING
          iv_ulke    = gv_ulke
          iv_lig     = gv_lig
          iv_player  = gv_player
        CHANGING
          ls_strbadi = gs_log
      ).

      IF gv_flag IS NOT INITIAL.
        CALL METHOD text_edit->set_readonly_mode
          EXPORTING
            readonly_mode          = 0
          EXCEPTIONS
            error_cntl_call_method = 1
            invalid_parameter      = 2
            OTHERS                 = 3.
      ENDIF.

      CLEAR: gt_text,lt_tline.

      CALL METHOD text_edit->get_text_as_r3table
        IMPORTING
          table                  = gt_text
        EXCEPTIONS
          error_dp               = 1
          error_cntl_call_method = 2
          error_dp_create        = 3
          potential_data_loss    = 4
          OTHERS                 = 5.


      LOOP AT gt_text INTO DATA(ls_text).
        ls_tline-tdline = ls_text.
        APPEND ls_tline TO lt_tline.
      ENDLOOP.

      gs_header-tdobject = 'ZGG_TO_01'.
      gs_header-tdid = 'TID'.
      gs_header-tdspras = 'E'.
      gs_header-tdname = gs_playerphoto-id.


      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
*         CLIENT   = SY-MANDT
          header   = gs_header
*         INSERT   = ' '
*         SAVEMODE_DIRECT         = ' '
*         OWNER_SPECIFIED         = ' '
*         LOCAL_CAT               = ' '
*         KEEP_LAST_CHANGED       = ' '
*       IMPORTING
*         FUNCTION =
*         NEWHEADER               =
        TABLES
          lines    = lt_tline
        EXCEPTIONS
          id       = 1
          language = 2
          name     = 3
          object   = 4
          OTHERS   = 5.


      IF sy-subrc EQ 0.
*        UPDATE zgg_t_player SET id = gs_playerphoto-id
*                                age = gs_playerphoto-age
*                                name = gs_playerphoto-name
*                                forma_no = gs_playerphoto-number
*                                pozisyon = gs_playerphoto-position
*                                user_name = sy-uname
*                                change_date = sy-datum
*                                change_time = sy-uzeit.
**        IF sy-subrc EQ 0.
*          MESSAGE 'Kayıt başarıyla değiştirilmiştir.' TYPE 'I'.
*        ENDIF.
*      ELSE.
        gs_texttable-id = gs_playerphoto-id.
        gs_texttable-name = gs_playerphoto-name.
        gs_texttable-age =  gs_playerphoto-age.
        gs_texttable-forma_no = gs_playerphoto-number.
        gs_texttable-pozisyon = gs_playerphoto-position.
        gs_texttable-user_name = sy-uname.
        gs_texttable-change_date = sy-datum.
        gs_texttable-change_time = sy-uzeit.

*        gs_block-player_id = gs_playerphoto-id.

*        INSERT zgg_t_player FROM gs_texttable.
        MODIFY zgg_t_player FROM gs_texttable.
*        MODIFY zgg_block_player FROM gs_block.


        IF sy-subrc EQ 0.
          MESSAGE 'Kayıt başarıyla kaydedilmiştir veya değiştirilmiştir.' TYPE 'I'.
        ENDIF.
      ENDIF.

      CLEAR gv_flag.

  ENDCASE.




ENDMODULE.
