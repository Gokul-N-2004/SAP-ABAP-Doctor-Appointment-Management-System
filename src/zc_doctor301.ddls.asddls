@EndUserText.label: 'Doctor Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI.headerInfo: {
  typeName: 'Doctor',
  typeNamePlural: 'Doctors',
  title: { type: #STANDARD, value: 'DoctorId' },
  description: { type: #STANDARD, value: 'DoctorName' }
}

define root view entity ZC_DOCTOR301
  provider contract transactional_query
  as projection on ZI_DOCTOR301
{
      @UI.facet: [{
        id:       'DoctorInfo',
        purpose:  #STANDARD,
        type:     #IDENTIFICATION_REFERENCE,
        label:    'Doctor Information',
        position: 10
      }]

      @UI.lineItem:       [{ position: 10, label: 'Doctor ID' }]
      @UI.identification: [{ position: 10, label: 'Doctor ID' }]
  key DoctorId,

      @UI.lineItem:       [{ position: 20, label: 'Doctor Name' }]
      @UI.identification: [{ position: 20, label: 'Doctor Name' }]
      DoctorName,

      @UI.lineItem:       [{ position: 30, label: 'Specialization' }]
      @UI.identification: [{ position: 30, label: 'Specialization' }]
      Specialization,

      @UI.lineItem:       [{ position: 40, label: 'Phone Number' }]
      @UI.identification: [{ position: 40, label: 'Phone Number' }]
      Phone,

      @UI.lineItem:       [{ position: 50, label: 'Experience (Years)' }]
      @UI.identification: [{ position: 50, label: 'Experience (Years)' }]
      Experience,

      @UI.lineItem:       [{ position: 60, label: 'Joining Date' }]
      @UI.identification: [{ position: 60, label: 'Joining Date' }]
      JoiningDate,

      @UI.lineItem:       [{ position: 70, label: 'Success Cases' }]
      @UI.identification: [{ position: 70, label: 'Success Cases' }]
      SuccessCases
}
