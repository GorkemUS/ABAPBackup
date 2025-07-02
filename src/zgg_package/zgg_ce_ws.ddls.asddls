@EndUserText.label: 'Custom Entity Web Service Consume'
@ObjectModel.query.implementedBy: 'ABAP:ZGG_CE_WEBSRV'
@Metadata.allowExtensions: true

@UI.headerInfo: {
    imageUrl: 'LOGO'
}
@UI.badge.headLine.label: 'Deneme'
define custom entity ZGG_CE_WS
{
      //  key client  : abap.clnt;
      @EndUserText.label: 'ID'
      @UI.lineItem: [{ position: 10 }]
  key id      : int4;
      @EndUserText.label: 'Ülke Kodu'
      @UI     : { lineItem: [{ position: 20  }],
      identification: [{ position: 20 }],
      selectionField: [{ position: 20 ,element: 'country'}]
      }
      @Consumption.valueHelpDefinition: [{entity: { name: 'ZGG_CE_WS',
                                                    element: 'country' }}]
      country : land1;
      @EndUserText.label: 'Lig Adı'
      @UI.lineItem: [{ position: 30 }]
      name    : char100;
      @UI.lineItem: [{ position: 40, importance: #HIGH }]
      @Semantics.imageUrl: true
      @UI.textArrangement: #TEXT_ONLY
      @EndUserText.label: 'Logo'
      logo    : char200;

}
