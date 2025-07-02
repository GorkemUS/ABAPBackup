*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_STOCK_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.

    METHODS:refresh_table IMPORTING ld_grid TYPE REF TO cl_gui_alv_grid,
      get_data,
      display_alv,
      set_trafficdesign,
      print_smartform,
      initialization,
      at_selection_screen,
      at_selection_screen_output.


ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_user_command.

    DATA:
      ls_table    TYPE zdyp12_t_stock2,
      ls_logtable TYPE zdyp12_t_stock.

    grid->get_selected_rows(
      IMPORTING
       et_index_rows = lt_selected_row
       ).

    IF lt_selected_row IS INITIAL.
      MESSAGE 'Satır seçmediniz' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

    CASE e_ucomm.
      WHEN '&UPDATE'.
        LOOP AT lt_selected_row INTO ls_selected_row .
          READ TABLE gt_data INTO gs_data INDEX ls_selected_row-index.
          IF gs_data-sap_stock EQ gs_data-physical_stock.
            gs_data-traffic_light = '@08@'.
          ELSE.
            gs_data-traffic_light = '@0A@'.
          ENDIF.
          MODIFY gt_data FROM gs_data INDEX ls_selected_row-index .
        ENDLOOP.
        ls_table = CORRESPONDING #( gs_data ).
        MODIFY zdyp12_t_stock2 FROM ls_table.
      WHEN '&SAV'.
        LOOP AT lt_selected_row INTO ls_selected_row .
          ls_logtable = CORRESPONDING #( gs_data ).
          IF rbutton1 = abap_true.
            ls_logtable-stok_tipi = '1'.
          ELSEIF rbutton2 = abap_true.
            ls_logtable-stok_tipi = '2'.
          ELSEIF rbutton3 = abap_true.
            ls_logtable-stok_tipi = '3'.
          ENDIF.

          MODIFY zdyp12_t_stock FROM ls_logtable.
        ENDLOOP.
      WHEN '&EMAIL'.
        DATA: lv_string      TYPE string,
              lv_data_string TYPE string,
              lv_xstring     TYPE xstring.


        LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<ls_alv>).
          CONCATENATE <ls_alv>-matnr <ls_alv>-maktx <ls_alv>-werks <ls_alv>-name1 <ls_alv>-lgort <ls_alv>-charg
          INTO lv_string SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
          CONCATENATE lv_string lv_data_string INTO lv_data_string
          SEPARATED BY cl_abap_char_utilities=>newline.
        ENDLOOP.

        CONCATENATE 'Malzeme' 'Malzeme Tanimi' 'Uretim Y.' 'UY Tanımı' 'Parti' INTO lv_string SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
        CONCATENATE lv_string lv_data_string INTO lv_data_string
        SEPARATED BY cl_abap_char_utilities=>newline.

        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = lv_data_string
*           MIMETYPE       = ' '
*           ENCODING       =
          IMPORTING
            buffer = lv_xstring.

        " Generate Smartform PDF
        DATA: lv_fm_name       TYPE rs38l_fnam,
              lv_adobe_name    TYPE rs38l_fnam,
              ls_control_param TYPE ssfctrlop,
              gs_outputparams  TYPE sfpoutputparams,
              ls_docparams     TYPE sfpdocparams,
              ls_adobeoutput   TYPE fpformoutput,
              ls_output_param  TYPE ssfcompop,
              lt_otf           TYPE TABLE OF itcoo,
              lv_pdf           TYPE xstring,
              lt_pdf_lines     TYPE TABLE OF tline,
              lv_pdf_filesize  TYPE i,
              lv_output        TYPE ssfcrescl.


        " Set Smartform control parameters
        ls_control_param-no_dialog = 'X'.
        ls_control_param-getotf    = 'X'.

        LOOP AT lt_selected_row INTO ls_selected_row .
          READ TABLE gt_data INTO gs_data INDEX ls_selected_row-index.
          MODIFY gt_data FROM gs_data INDEX ls_selected_row-index .
          gs_smartform = CORRESPONDING #( gs_data ).
          APPEND gs_smartform TO gt_smartform.
        ENDLOOP.

        " Get the name of the Smartform function module
        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = 'ZDYP12_SF_STOCK'
          IMPORTING
            fm_name            = lv_fm_name
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

        IF sy-subrc NE 0.
          MESSAGE 'Error generating Smartform output' TYPE 'E'.
          EXIT.
        ENDIF.

        " Call the Smartform function module
        CALL FUNCTION lv_fm_name
          EXPORTING
            control_parameters = ls_control_param
            output_options     = ls_output_param
            it_data            = gt_smartform
          IMPORTING
            job_output_info    = lv_output
          TABLES
            otf                = lt_otf
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.


        lt_otf[] = lv_output-otfdata[].


        IF sy-subrc NE 0.
          MESSAGE 'Error generating Smartform output' TYPE 'E'.
          EXIT.
        ENDIF.

        " Convert OTF to PDF
        CALL FUNCTION 'CONVERT_OTF'
          EXPORTING
            format                = 'PDF'
          IMPORTING
            bin_file              = lv_pdf
            bin_filesize          = lv_pdf_filesize
          TABLES
            otf                   = lt_otf
            lines                 = lt_pdf_lines
          EXCEPTIONS
            err_max_linewidth     = 1
            err_format            = 2
            err_conv_not_possible = 3
            err_bad_otf           = 4
            OTHERS                = 5.

        IF sy-subrc NE 0.
          MESSAGE 'Error generating Smartform output' TYPE 'S' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer     = lv_pdf
          TABLES
            binary_tab = lt_pdf_lines
          EXCEPTIONS
            failed     = 1
            OTHERS     = 2.
****************************************************
        gs_outputparams-nodialog = abap_true.
        gs_outputparams-preview  = abap_true.
        gs_outputparams-dest     = 'LP01'.
        gs_outputparams-getpdf   = abap_true.



        CALL FUNCTION 'FP_JOB_OPEN'
          CHANGING
            ie_outputparams = gs_outputparams
          EXCEPTIONS
            cancel          = 1
            usage_error     = 2
            system_error    = 3
            internal_error  = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
        ENDIF.

        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = 'ZDYP12_ADOBE_STOCK_F'
          IMPORTING
            e_funcname = lv_adobe_name.

        CALL FUNCTION lv_adobe_name
          EXPORTING
            /1bcdwb/docparams  = ls_docparams
            it_adata           = gt_smartform
          IMPORTING
            /1bcdwb/formoutput = ls_adobeoutput
          EXCEPTIONS
            usage_error        = 1
            system_error       = 2
            internal_error     = 3
            OTHERS             = 4.
        IF sy-subrc <> 0.
        ENDIF.


        CALL FUNCTION 'FP_JOB_CLOSE'
          EXCEPTIONS
            usage_error    = 1
            system_error   = 2
            internal_error = 3
            OTHERS         = 4.
        IF sy-subrc <> 0.
        ENDIF.



        CREATE OBJECT mail.
        mail->set_subject( 'Excel,Smartform ve Adobe' ).
        mail->set_main_doc( iv_contents_txt = 'Excel and Smartform attached with headers' ).
        mail->add_recipient( 'gorkem.gokce@nagarro.com' ).


        mail->add_attachment(
          EXPORTING
            iv_doctype      = 'XLS'
            iv_filename     = 'alv.xls'
            iv_contents_bin =  lv_xstring
        ).

        IF lv_pdf IS NOT INITIAL.
          mail->add_attachment(
            EXPORTING
              iv_doctype      = 'PDF'
              iv_filename     = 'smartform.pdf'
              iv_contents_bin = lv_pdf
          ).
        ENDIF.

        IF ls_adobeoutput-pdf IS NOT INITIAL.
          mail->add_attachment(
            EXPORTING
              iv_doctype      = 'PDF'
              iv_filename     = 'AdobeForm.pdf'
              iv_contents_bin = ls_adobeoutput-pdf
          ).
        ENDIF.

        mail->send( ).

        CLEAR gt_smartform.
      WHEN '&YAZDIR'.
        g_main->print_smartform( ).

      WHEN '&INDIR'.

        DATA: lt_pdf_content  TYPE TABLE OF solix,
              lv_pdf_file     TYPE string,
              lv_file_path    TYPE string,
              lv_fullpath     TYPE string,
              lv_solix        TYPE solix_tab,
              lv_bin_filesize TYPE i.




        IF lt_selected_row IS INITIAL.
          MESSAGE 'Satır seçmediniz' TYPE 'S' DISPLAY LIKE 'E'.
          RETURN.
        ENDIF.


        LOOP AT lt_selected_row INTO ls_selected_row .
          READ TABLE gt_data INTO gs_data INDEX ls_selected_row-index.
          MODIFY gt_data FROM gs_data INDEX ls_selected_row-index .
          gs_smartform = CORRESPONDING #( gs_data ).
          APPEND gs_smartform TO gt_smartform.
        ENDLOOP.

        gs_outputparams-nodialog = abap_true.
        gs_outputparams-getpdf = abap_true.

        CALL FUNCTION 'FP_JOB_OPEN'
          CHANGING
            ie_outputparams = gs_outputparams
          EXCEPTIONS
            cancel          = 1
            usage_error     = 2
            system_error    = 3
            internal_error  = 4
            OTHERS          = 5.

        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = 'ZDYP12_ADOBE_STOCK_F'
          IMPORTING
            e_funcname = lv_adobe_name.

        CALL FUNCTION lv_adobe_name
          EXPORTING
            /1bcdwb/docparams  = ls_docparams
            it_adata           = gt_smartform
          IMPORTING
            /1bcdwb/formoutput = ls_adobeoutput
          EXCEPTIONS
            usage_error        = 1
            system_error       = 2
            internal_error     = 3
            OTHERS             = 4.


        lv_solix = cl_bcs_convert=>xstring_to_solix( iv_xstring = ls_adobeoutput-pdf ).

        "Diğer bir şekilde download yapma

*        CALL METHOD cl_gui_frontend_services=>directory_browse
*          EXPORTING
*            window_title    = 'Select Directory'
*          CHANGING
*            selected_folder = lv_file_path
*          EXCEPTIONS
*            OTHERS          = 1.

        "Combine directory and file name
*        CONCATENATE lv_file_path '\Stock Logs.pdf' INTO lv_fullpath.

        "Download the file
        CALL METHOD cl_gui_frontend_services=>file_save_dialog
          EXPORTING
            window_title              = 'Save as'
            default_extension         = 'pdf'
          CHANGING
            filename                  = lv_fullpath                 " File Name to Save
            path                      = lv_file_path                 " Path to File
            fullpath                  = lv_fullpath                  " Path + File Name
          EXCEPTIONS
            cntl_error                = 1                " Control error
            error_no_gui              = 2                " No GUI available
            not_supported_by_gui      = 3                " GUI does not support this
            invalid_default_file_name = 4                " Invalid default file name
            OTHERS                    = 5.

        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            bin_filesize            = lv_bin_filesize
            filename                = lv_fullpath
            filetype                = 'BIN'
          TABLES
            data_tab                = lv_solix
          EXCEPTIONS
            file_write_error        = 1
            no_batch                = 2
            gui_refuse_filetransfer = 3
            invalid_type            = 4
            no_authority            = 5
            unknown_error           = 6
            header_not_allowed      = 7
            separator_not_allowed   = 8
            filesize_not_allowed    = 9
            header_too_long         = 10
            dp_error_create         = 11
            dp_error_send           = 12
            dp_error_write          = 13
            unknown_dp_error        = 14
            access_denied           = 15
            dp_out_of_memory        = 16
            disk_full               = 17
            dp_timeout              = 18
            file_not_found          = 19
            dataprovider_exception  = 20
            control_flush_error     = 21
            OTHERS                  = 22.

        "Diğer bir şekilde download yapma
*
*        CALL METHOD cl_gui_frontend_services=>gui_download
*          EXPORTING
*            filename                = lv_fullpath
*            filetype                = 'BIN'
*          CHANGING
*            data_tab                = lv_solix
*          EXCEPTIONS
*            file_write_error        = 1
*            no_batch                = 2
*            gui_refuse_filetransfer = 3
*            invalid_type            = 4
*            no_authority            = 5
*            unknown_error           = 6
*            header_not_allowed      = 7
*            separator_not_allowed   = 8
*            filesize_not_allowed    = 9
*            header_too_long         = 10
*            dp_error_create         = 11
*            dp_error_send           = 12
*            dp_error_write          = 13
*            unknown_dp_error        = 14
*            access_denied           = 15
*            dp_out_of_memory        = 16
*            disk_full               = 17
*            dp_timeout              = 18
*            file_not_found          = 19
*            dataprovider_exception  = 20
*            control_flush_error     = 21
*            OTHERS                  = 22.

        CALL FUNCTION 'FP_JOB_CLOSE'
          EXCEPTIONS
            usage_error    = 1
            system_error   = 2
            internal_error = 3
            OTHERS         = 4.

    ENDCASE.

    g_main->refresh_table( ld_grid = grid ).

  ENDMETHOD.
  METHOD handle_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&UPDATE'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_system_save.
    gs_toolbar-text      = 'Güncelle'.
    gs_toolbar-quickinfo = 'Güncelle'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&SAV'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_system_save.
    gs_toolbar-text      = 'Kaydet'.
    gs_toolbar-quickinfo = 'Kaydet'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&EMAIL'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_system_save.
    gs_toolbar-text      = 'Send Email'.
    gs_toolbar-quickinfo = 'Send Email'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&YAZDIR'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_print.
    gs_toolbar-text      = 'Yazdır'.
    gs_toolbar-quickinfo = 'Yazdır'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

    CLEAR gs_toolbar.
    gs_toolbar-function = '&INDIR'.
    gs_toolbar-butn_type = 0.
    gs_toolbar-icon = icon_pdf.
    gs_toolbar-text      = 'PDF Indir'.
    gs_toolbar-quickinfo = 'PDF Indir'.
    APPEND gs_toolbar TO e_object->mt_toolbar.

  ENDMETHOD.
  METHOD set_trafficdesign.

    LOOP AT lt_fieldcatalog ASSIGNING <gfs_fieldcat>.
      IF <gfs_fieldcat>-fieldname = 'PHYSICAL_STOCK'.
        <gfs_fieldcat>-edit = abap_true.

        <gfs_fieldcat>-scrtext_l = 'Fiziksel'.
        <gfs_fieldcat>-scrtext_m = 'Fiziksel Stok'.
        <gfs_fieldcat>-scrtext_s = 'Fiziksel Stok'.

      ELSEIF <gfs_fieldcat>-fieldname = 'SAP_STOK'.

        <gfs_fieldcat>-scrtext_l = 'SAP Stok'.
        <gfs_fieldcat>-scrtext_m = 'Sap Stok'.
        <gfs_fieldcat>-scrtext_s = 'Sap Stok'.


      ELSEIF <gfs_fieldcat>-fieldname = 'CHK'.
        <gfs_fieldcat>-col_pos = 1.
      ENDIF.

    ENDLOOP.

    LOOP AT gt_data INTO gs_data.
      IF p_check1 = abap_true.
        IF gs_data-physical_stock NE gs_data-sap_stock.
          gs_data-traffic_light = '@0A@'.
*            gs_data-color = 'C600'.
        ELSE.
          gs_data-traffic_light = '@08@'.
*            gs_data-color = 'C500'.
        ENDIF.
      ENDIF.
      MODIFY gt_data FROM gs_data.
    ENDLOOP.
    g_main->refresh_table( ld_grid = grid ).
  ENDMETHOD.
  METHOD get_data.

    IF rbutton1 = abap_true.
      SELECT
        mchb~matnr,
        makt~maktx,
        mchb~werks,
        t001w~name1,
        mchb~lgort,
        mchb~charg,
        mchb~clabs AS sap_stock,
        zdyp12_t_stock2~physical_stock AS physical_stock
        INTO CORRESPONDING FIELDS OF TABLE @gt_data
        FROM mchb
        LEFT JOIN t001w ON mchb~werks = t001w~werks
        LEFT JOIN zdyp12_t_stock2  ON  mchb~matnr = zdyp12_t_stock2~matnr
        LEFT JOIN makt  ON  makt~matnr = mchb~matnr
                        AND makt~spras = @sy-langu
          WHERE mchb~matnr IN @s_matnr
          AND mchb~werks IN @s_werks
          AND mchb~charg IN @s_charg.

    ELSEIF rbutton2 = abap_true.
      SELECT
       mard~matnr,
       makt~maktx,
       mard~werks,
       t001w~name1,
       mard~lgort,
       mard~labst AS sap_stock,
       zdyp12_t_stock2~physical_stock AS physical_stock
       INTO CORRESPONDING FIELDS OF TABLE @gt_data
       FROM mard

       INNER JOIN t001w ON mard~werks = t001w~werks
       INNER JOIN mchb ON mard~matnr = mchb~matnr
       LEFT JOIN zdyp12_t_stock2  ON  mchb~matnr = zdyp12_t_stock2~matnr
       LEFT JOIN makt  ON  makt~matnr = mard~matnr
                       AND makt~spras = @sy-langu
         WHERE mchb~matnr IN @s_matnr
         AND mchb~werks IN @s_werks
         AND mard~lgort IN @s_lgort.

    ELSEIF rbutton3 = abap_true.
      SELECT
       mchb~matnr,
       makt~maktx,
       mchb~werks,
       t001w~name1,
       mchb~clabs AS sap_stock,
       zdyp12_t_stock2~physical_stock AS physical_stock

       INTO CORRESPONDING FIELDS OF TABLE @gt_data
       FROM mchb
       INNER JOIN t001w ON mchb~werks = t001w~werks
       LEFT JOIN zdyp12_t_stock2  ON  mchb~matnr = zdyp12_t_stock2~matnr
       LEFT JOIN makt  ON  makt~matnr = mchb~matnr
                       AND makt~spras = @sy-langu
         WHERE mchb~matnr IN @s_matnr
         AND mchb~werks IN @s_werks.

    ENDIF.
  ENDMETHOD.
  METHOD display_alv.

    IF grid IS NOT BOUND.

      CREATE OBJECT container_1 EXPORTING container_name = 'CONTAINER_1'.

      CREATE OBJECT grid
        EXPORTING
          i_parent = container_1.

      SET HANDLER: lcl_event_receiver=>handle_toolbar      FOR grid,
                   lcl_event_receiver=>handle_user_command FOR grid.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name   = 'ZDYP12_S_STOCK'
          i_bypassing_buffer = 'X'
        CHANGING
          ct_fieldcat        = lt_fieldcatalog[].

      ls_layout-info_fname = 'COLOR'.

      LOOP AT lt_fieldcatalog ASSIGNING FIELD-SYMBOL(<fs_fielcatalog>).
        CASE <fs_fielcatalog>-fieldname.
          WHEN 'CHARG'.
            IF rbutton2 = abap_true OR rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'MEINS'.
            IF rbutton1 = abap_true OR rbutton2 = abap_true OR rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'LGORT'.
            IF rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'LABST'.
            IF rbutton1 = abap_true OR rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'CLABS'.
            IF rbutton2 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'COLOR'.
            IF rbutton1 = abap_true OR rbutton2 = abap_true OR rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'CLRT'.
            IF rbutton1 = abap_true OR rbutton2 = abap_true OR rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'CONTROL'.
            IF rbutton1 = abap_true OR rbutton2 = abap_true OR rbutton3 = abap_true.
              <fs_fielcatalog>-tech = abap_true.
            ENDIF.
          WHEN 'PHYSICAL_STOCK'.
            IF p_check1 = abap_false.
              <fs_fielcatalog>-no_out = abap_true.
            ELSEIF p_check1 = abap_true.
              <fs_fielcatalog>-no_out = abap_false.
              <fs_fielcatalog>-edit = abap_true.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

      ls_fieldcatalog-reptext = 'SAP Stokları'.
      ls_fieldcatalog-scrtext_s = 'SAP Stokları'.
      ls_fieldcatalog-scrtext_m = 'SAP Stokları'.
      ls_fieldcatalog-scrtext_l = 'SAP Stokları'.
      MODIFY lt_fieldcatalog FROM ls_fieldcatalog TRANSPORTING reptext scrtext_s scrtext_m scrtext_l WHERE fieldname =  'SAP_STOCK'.

      ls_fieldcatalog-reptext = 'Fiziksel Stoklar'.
      ls_fieldcatalog-scrtext_s = 'Fiziksel Stoklar'.
      ls_fieldcatalog-scrtext_m = 'Fiziksel Stoklar'.
      ls_fieldcatalog-scrtext_l = 'Fiziksel Stoklar'.
      MODIFY lt_fieldcatalog FROM ls_fieldcatalog TRANSPORTING reptext scrtext_s scrtext_m scrtext_l WHERE fieldname =  'PHYSICAL_STOCK'.

      CALL METHOD grid->set_table_for_first_display
        EXPORTING
*         i_structure_name = 'ZDYP12_S_STOCK'
          is_layout       = ls_layout
*         i_save          = 'X'
        CHANGING
          it_fieldcatalog = lt_fieldcatalog
          it_outtab       = gt_data.
    ELSE.
      refresh_table( ld_grid = grid ).
    ENDIF.

  ENDMETHOD.

  METHOD refresh_table .

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
  METHOD print_smartform.
    DATA: ls_control_param TYPE ssfctrlop,
          ls_output_param  TYPE ssfcompop,
          lv_fm_name       TYPE rs38l_fnam.

    " Set Smartform control parameters
*    ls_control_param-getotf = 'X'.
    ls_control_param-no_dialog = 'X'.
    ls_control_param-preview   = abap_true.

    " Set output options
    ls_output_param-tddest = 'LP01'.
*    ls_output_param-tdnewid = 'X'.
    CLEAR gt_smartform.
    LOOP AT lt_selected_row INTO ls_selected_row .
      READ TABLE gt_data INTO gs_data INDEX ls_selected_row-index.
*      IF sy-subrc NE 0.
*        MESSAGE 'Satır seçmediniz' TYPE 'S'.
*      ENDIF.
      MODIFY gt_data FROM gs_data INDEX ls_selected_row-index .
      gs_smartform = CORRESPONDING #( gs_data ).
      APPEND gs_smartform TO gt_smartform.
    ENDLOOP.

    " Get the name of the Smartform function module
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        formname           = 'ZDYP12_SF_STOCK'
      IMPORTING
        fm_name            = lv_fm_name
      EXCEPTIONS
        no_form            = 1
        no_function_module = 2
        OTHERS             = 3.

    IF sy-subrc <> 0.
      MESSAGE 'Smartform not found' TYPE 'E'.
      EXIT.
    ENDIF.

    " Call the Smartform function module
    CALL FUNCTION lv_fm_name
      EXPORTING
        control_parameters = ls_control_param
        output_options     = ls_output_param
        it_data            = gt_smartform
      EXCEPTIONS
        formatting_error   = 1
        internal_error     = 2
        send_error         = 3
        user_canceled      = 4
        OTHERS             = 5.

    IF sy-subrc <> 0.
      MESSAGE 'Error printing Smartform' TYPE 'E'.
    ENDIF.
  ENDMETHOD.
  METHOD initialization.

  ENDMETHOD.
  METHOD at_selection_screen.


  ENDMETHOD.
  METHOD at_selection_screen_output.

    LOOP AT SCREEN.
      IF rbutton3 = 'X'.
        IF screen-group1 = 'CRG' OR screen-group1 = 'LRT'.
          screen-active = 0.
          MODIFY SCREEN.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
      IF rbutton1 = 'X'.
        IF screen-group1 = 'LRT'.
          screen-active = 0.
          MODIFY SCREEN.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
      IF rbutton2 = 'X'.
        IF screen-group1 = 'CRG'.
          screen-active = 0.
          MODIFY SCREEN.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
