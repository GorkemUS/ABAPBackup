CLASS zgg_cl_wsbadi_imp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES zgg_cl_wsbadi .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZGG_CL_WSBADI_IMP IMPLEMENTATION.


  METHOD zgg_cl_wsbadi~after_save.
    DATA: lt_logtable TYPE TABLE OF zgg_log_ch_play,
          ls_logtable TYPE zgg_log_ch_play.

    DATA: lv_terminal  TYPE usr41-terminal,
          lv_guid      TYPE sysuuid_c32.

    SELECT * INTO TABLE lt_logtable FROM zgg_log_ch_play WHERE player_id = ls_strbadi-PLAYER_id.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    CALL FUNCTION 'TERMINAL_ID_GET'
      EXPORTING
        username             = sy-uname
      IMPORTING
        terminal             = lv_terminal
      EXCEPTIONS
        multiple_terminal_id = 1
        no_terminal_found    = 2
        OTHERS               = 3.
    TRY.
        CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c32
          RECEIVING
            uuid = lv_guid.                  " UUID
      CATCH cx_uuid_error. " Error Class for UUID Processing Errors
    ENDTRY.

    ls_logtable-player_id = ls_strbadi-player_id.
    ls_logtable-change_guid = lv_guid.
    ls_logtable-username = sy-uname.
    ls_logtable-terminal_id = lv_terminal.
    ls_logtable-timestamp = lv_timestamp.

    MODIFY zgg_log_ch_play FROM ls_logtable.

  ENDMETHOD.


  METHOD zgg_cl_wsbadi~before_save.
    DATA: lt_table TYPE TABLE OF zgg_block_player.

    SELECT * INTO TABLE lt_table FROM zgg_block_player WHERE player_id = ls_strbadi-player_id.

    IF line_exists( lt_table[ player_id = ls_strbadi-player_id ] ).
      ev_rc = 4.
    ELSE.
      ev_rc = 0.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
