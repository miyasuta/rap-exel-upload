@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_YPRODUCT
  provider contract transactional_query
  as projection on ZR_YPRODUCT
{
  key ProductId,
  ProductName,
  Price,
  @Semantics.currencyCode: true
  @Consumption.valueHelpDefinition: [
    { entity: { name: 'I_CurrencyStdVH', element: 'Currency' } }
  ]
  Currency,
  Stock,
  @Semantics.unitOfMeasure: true
  @Consumption.valueHelpDefinition: [
    { entity: { name: 'I_UnitOfMeasureStdVH', element: 'UnitOfMeasure'} }
  ]
  UnitOfMeasure,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
