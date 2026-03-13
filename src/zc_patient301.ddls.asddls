@EndUserText.label: 'Patient Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI.headerInfo: {
  typeName: 'Patient',
  typeNamePlural: 'Patients',
  title: { type: #STANDARD, value: 'PatientId' },
  description: { type: #STANDARD, value: 'PatientName' }
}

define root view entity ZC_PATIENT301
  provider contract transactional_query
  as projection on ZI_PATIENT301
{
      @UI.facet: [{
        id:       'PatientInfo',
        purpose:  #STANDARD,
        type:     #IDENTIFICATION_REFERENCE,
        label:    'Patient Information',
        position: 10
      }]

      @UI.lineItem:       [{ position: 10, label: 'Patient ID' }]
      @UI.identification: [{ position: 10, label: 'Patient ID' }]
  key PatientId,

      @UI.lineItem:       [{ position: 20, label: 'Patient Name' }]
      @UI.identification: [{ position: 20, label: 'Patient Name' }]
      PatientName,

      @UI.lineItem:       [{ position: 30, label: 'Age' }]
      @UI.identification: [{ position: 30, label: 'Age' }]
      Age,

      @UI.lineItem:       [{ position: 40, label: 'Gender' }]
      @UI.identification: [{ position: 40, label: 'Gender' }]
      Gender,

      @UI.lineItem:       [{ position: 50, label: 'Phone Number' }]
      @UI.identification: [{ position: 50, label: 'Phone Number' }]
      Phone,

      @UI.lineItem:       [{ position: 60, label: 'Address' }]
      @UI.identification: [{ position: 60, label: 'Address' }]
      Address
}
