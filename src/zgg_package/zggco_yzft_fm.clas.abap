class ZGGCO_YZFT_FM definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods YZFT_FM
    importing
      !INPUT type ZGGYZFT_FM
    exporting
      !OUTPUT type ZGGYZFT_FMRESPONSE
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZGGCO_YZFT_FM IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZGGCO_YZFT_FM'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method YZFT_FM.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'YZFT_FM'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
