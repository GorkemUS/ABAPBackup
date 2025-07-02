*&---------------------------------------------------------------------*
*& Report ZDYP12_R_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_test.

TABLES: ekko.

PARAMETERS: p_email TYPE somlreci1-receiver DEFAULT 'gorkem.gokce@nagarro.com'.

TYPES: BEGIN OF t_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         aedat TYPE ekpo-aedat,
         matnr TYPE ekpo-matnr,
       END OF t_ekpo.
DATA: it_ekpo TYPE STANDARD TABLE OF t_ekpo INITIAL SIZE 0,
      wa_ekpo TYPE t_ekpo.

TYPES: BEGIN OF t_charekpo,
         ebeln(10) TYPE c,
         ebelp(5)  TYPE c,
         aedat(8)  TYPE c,
         matnr(18) TYPE c,
       END OF t_charekpo.
DATA: wa_charekpo TYPE t_charekpo.

DATA: it_message TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE.
DATA: it_attach TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE.

DATA: t_packing_list  LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
      t_contents      LIKE solisti1 OCCURS 0 WITH HEADER LINE,
      t_receivers     LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
      t_attachment    LIKE solisti1 OCCURS 0 WITH HEADER LINE,
      t_object_header LIKE solisti1 OCCURS 0 WITH HEADER LINE,
      w_cnt           TYPE i,
      w_sent_all(1)   TYPE c,
      w_doc_data      LIKE sodocchgi1,
      gd_error        TYPE sy-subrc,
      gd_reciever     TYPE sy-subrc.

t_object_header = 'Excel.xls'.
APPEND t_object_header.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

* Retrieve sample data from table ekpo
  PERFORM data_retrieval.

* Populate table with details to be entered into .xls file
  PERFORM build_xls_data_table.

************************************************************************
* END-OF-SELECTION
************************************************************************
END-OF-SELECTION.

* Populate message body text
  PERFORM populate_email_message_body.

* Send file by email as .xls spreadsheet
  PERFORM send_file_as_email_attachment
    TABLES it_message
           it_attach
    USING p_email
          'Example .xls document attachment'
          'XLS'
          'filename'
          ' '
          ' '
          ' '
    CHANGING gd_error
             gd_reciever.

* Instructs mail send program for SAPCONNECT to send email(rsconn01)
  PERFORM initiate_mail_execute_program.

*&---------------------------------------------------------------------
*& Form DATA_RETRIEVAL
*&---------------------------------------------------------------------
FORM data_retrieval.
  SELECT ebeln ebelp aedat matnr
    UP TO 10 ROWS
    FROM ekpo
    INTO TABLE it_ekpo.
ENDFORM. " DATA_RETRIEVAL

*&---------------------------------------------------------------------
*& Form BUILD_XLS_DATA_TABLE
*&---------------------------------------------------------------------
FORM build_xls_data_table.
* CONSTANTS: con_cret TYPE x VALUE '0D', "OK for non Unicode
* con_tab TYPE x VALUE '09'. "OK for non Unicode

* If you have Unicode check active in program attributes then you will
* need to declare constants as follows
  CONSTANTS:
    con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
    con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.

  CONCATENATE 'EBELN' 'EBELP' 'AEDAT' 'MATNR'
    INTO it_attach SEPARATED BY con_tab.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.

  LOOP AT it_ekpo INTO wa_ekpo.
    wa_charekpo-ebeln = wa_ekpo-ebeln.
    wa_charekpo-ebelp = wa_ekpo-ebelp.
    wa_charekpo-aedat = wa_ekpo-aedat.
    wa_charekpo-matnr = wa_ekpo-matnr.

    CONCATENATE wa_charekpo-ebeln wa_charekpo-ebelp
                wa_charekpo-aedat wa_charekpo-matnr
      INTO it_attach SEPARATED BY con_tab.
    CONCATENATE con_cret it_attach INTO it_attach.
    APPEND it_attach.
  ENDLOOP.
ENDFORM. " BUILD_XLS_DATA_TABLE

*&---------------------------------------------------------------------
*& Form SEND_FILE_AS_EMAIL_ATTACHMENT
*&---------------------------------------------------------------------
FORM send_file_as_email_attachment TABLES pit_message
                                       pit_attach
                                    USING p_email
                                          p_mtitle
                                          p_format
                                          p_filename
                                          p_attdescription
                                          p_sender_address
                                          p_sender_addres_type
                                    CHANGING p_error
                                             p_reciever.

  DATA: ld_error               TYPE sy-subrc,
        ld_reciever            TYPE sy-subrc,
        ld_mtitle              LIKE sodocchgi1-obj_descr,
        ld_email               LIKE somlreci1-receiver,
        ld_format              TYPE so_obj_tp,
        ld_attdescription      TYPE so_obj_nam,
        ld_attfilename         TYPE so_obj_des,
        ld_sender_address      LIKE soextreci1-receiver,
        ld_sender_address_type LIKE soextreci1-adr_typ,
        ld_receiver            LIKE sy-subrc.

  ld_email = p_email.
  ld_mtitle = p_mtitle.
  ld_format = p_format.
  ld_attdescription = p_attdescription.
  ld_attfilename = p_filename.
  ld_sender_address = p_sender_address.
  ld_sender_address_type = p_sender_addres_type.

* Fill the document data.
  w_doc_data-doc_size = 1.

* Populate the subject/generic message attributes
  w_doc_data-obj_langu = sy-langu.
  w_doc_data-obj_name = 'SAPRPT'.
  w_doc_data-obj_descr = ld_mtitle .
  w_doc_data-sensitivty = 'F'.

* Fill the document data and get size of attachment
  CLEAR w_doc_data.
  READ TABLE it_attach INDEX w_cnt.
  w_doc_data-doc_size = ( w_cnt - 1 ) * 255 + strlen( it_attach ).
  w_doc_data-obj_langu = sy-langu.
  w_doc_data-obj_name = 'SAPRPT'.
  w_doc_data-obj_descr = ld_mtitle.
  w_doc_data-sensitivty = 'F'.
  CLEAR t_attachment.
  REFRESH t_attachment.
  t_attachment[] = pit_attach[].

* Describe the body of the message
  CLEAR t_packing_list.
  REFRESH t_packing_list.
  t_packing_list-transf_bin = space.
  t_packing_list-head_start = 1.
  t_packing_list-head_num = 0.
  t_packing_list-body_start = 1.
  DESCRIBE TABLE it_message LINES t_packing_list-body_num.
  t_packing_list-doc_type = 'RAW'.
  APPEND t_packing_list.

* Create attachment notification
  t_packing_list-transf_bin = 'X'.
  t_packing_list-head_start = 1.
  t_packing_list-head_num = 1.
  t_packing_list-body_start = 1.

  DESCRIBE TABLE t_attachment LINES t_packing_list-body_num.
  t_packing_list-doc_type = ld_format.
  t_packing_list-obj_descr = ld_attdescription.
  t_packing_list-obj_name = ld_attfilename.
  t_packing_list-doc_size = t_packing_list-body_num * 255.
  APPEND t_packing_list.

* Add the recipients email address
  CLEAR t_receivers.
  REFRESH t_receivers.
  t_receivers-receiver = ld_email.
  t_receivers-rec_type = 'U'.
  t_receivers-com_type = 'INT'.
  t_receivers-notif_del = 'X'.
  t_receivers-notif_ndel = 'X'.
  APPEND t_receivers.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = w_doc_data
      put_in_outbox              = 'X'
      sender_address             = ld_sender_address
      sender_address_type        = ld_sender_address_type
      commit_work                = 'X'
*    IMPORTING
*      sent_to_all                = w_sent_all
    TABLES
      object_header              = t_object_header
      packing_list               = t_packing_list
      contents_bin               = t_attachment
      contents_txt               = it_message
      receivers                  = t_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

* Populate zerror return code
  ld_error = sy-subrc.

* Populate zreceiver return code
  LOOP AT t_receivers.
    ld_receiver = t_receivers-retrn_code.
  ENDLOOP.
ENDFORM. " SEND_FILE_AS_EMAIL_ATTACHMENT

*&---------------------------------------------------------------------
*& Form INITIATE_MAIL_EXECUTE_PROGRAM
*&---------------------------------------------------------------------
FORM initiate_mail_execute_program.
  WAIT UP TO 2 SECONDS.
  SUBMIT rsconn01 WITH mode = 'INT' AND RETURN.
ENDFORM. " INITIATE_MAIL_EXECUTE_PROGRAM

*&---------------------------------------------------------------------
*& Form POPULATE_EMAIL_MESSAGE_BODY
*&---------------------------------------------------------------------
FORM populate_email_message_body.
  APPEND 'Please find the attached .xls document with the sample' TO it_message.
  APPEND 'data retrieved from table EKPO' TO it_message.
ENDFORM. " POPULATE_EMAIL_MESSAGE_BODY
