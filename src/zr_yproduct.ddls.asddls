@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_YPRODUCT
  as select from ZYPRODUCT as Product
{
  key product_id as ProductId,
  product_name as ProductName,
  @Semantics.amount.currencyCode: 'Currency'
  price as Price,
  currency as Currency,
  @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
  stock as Stock,
  unit_of_measure as UnitOfMeasure,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
  
}
