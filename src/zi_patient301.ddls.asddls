@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Patient Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_PATIENT301
  as select from ypatient301
{
  key patient_id   as PatientId,
      patient_name as PatientName,
      age          as Age,
      gender       as Gender,
      phone        as Phone,
      address      as Address
}
