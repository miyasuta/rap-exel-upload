@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_YPRODUCT
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_YPRODUCT
{
  key ProductId,
  ProductName,
  Price,
  @Semantics.currencyCode: true
  Currency,
  Stock,
  @Semantics.unitOfMeasure: true
  UnitOfMeasure,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LocalLastChangedAt,
  LastChangedAt
  
}
