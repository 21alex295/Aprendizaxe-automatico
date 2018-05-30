function [patient] = get_patient(patients_data,patient_number)
    patient = patients_data(patient_number);
    patient = cell2struct(patient,'data',1)
    patient = patient.data;
end