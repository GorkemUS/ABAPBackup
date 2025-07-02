*&---------------------------------------------------------------------*
*& Report ZDYP12_R_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_001.

TABLES: vbrk,vbrp,but000.

DATA: gs_data       TYPE zdyp12_s_001,
      gt_data       TYPE TABLE OF zdyp12_s_001,
      zdyp12_tt_001 TYPE TABLE OF zdyp12_s_001.

DATA: gt_adobe TYPE zdyp12_tt_001,
      gs_adobe TYPE zdyp12_s_001.

DATA: gs_outputparams TYPE sfpoutputparams,
      lv_adobe_name   TYPE rs38l_fnam,
      ls_adobeoutput  TYPE fpformoutput,
      ls_docparams    TYPE sfpdocparams.



SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln NO-EXTENSION NO INTERVALS OBLIGATORY.
  SELECT-OPTIONS: s_posnr FOR vbrp-posnr NO-EXTENSION NO INTERVALS.

SELECTION-SCREEN END OF BLOCK a1.

SELECT
   vbrk~vbeln,
   vbrk~fkdat,
*   vbrk~fkart,
   vbrk~kunag,
   vbrk~waerk,
   vbrp~posnr,
   vbrp~matnr,
   vbrp~arktx,
   vbrp~fkimg,
   vbrp~vrkme,
   vbrp~netwr,
   vbrp~mwsbp,
   but000~name_org1,
   but000~name_org2

  INTO CORRESPONDING FIELDS OF TABLE @gt_data
  FROM vbrk
  INNER JOIN vbrp ON vbrk~vbeln = vbrp~vbeln
  LEFT JOIN  but000 ON vbrk~kunag = but000~partner

  WHERE vbrk~vbeln IN @s_vbeln
  AND vbrp~posnr IN @s_posnr.

LOOP AT gt_data INTO gs_data.
  gs_adobe = CORRESPONDING #( gs_data ).
  APPEND gs_adobe TO gt_adobe.
ENDLOOP.

gs_outputparams-nodialog = abap_true.
gs_outputparams-preview  = abap_true.
gs_outputparams-dest     = 'LP01'.
*gs_outputparams-getpdf   = abap_true.


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
    i_name = 'ZDYP12_ADOBE_002_F'
  IMPORTING
    e_funcname = lv_adobe_name.

CALL FUNCTION lv_adobe_name
  EXPORTING
    /1bcdwb/docparams  = ls_docparams
    it_data            = gt_adobe
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
* IMPORTING
*   E_RESULT             =
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.


START-OF-SELECTION.
