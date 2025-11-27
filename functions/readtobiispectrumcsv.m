function [Timestamps,Timestamps_dev,DiameterL,DiameterR,Annotation,ValidityL,ValidityR] = readtobiispectrumcsv(FileName)
%READINTOBIISPECTRUMCSV reads in tobii spectrum files as they come out of
%the tobiispectrum recorder
%   Detailed explanation goes here
fID = fopen(FileName);
format = '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s';
header = textscan(fID, format, 1, 'Delimiter',',');
format = '%u64 %u64 %f %u %f %u %f %f %f %u %f %f %f %u %s';
Values = textscan(fID, format, 'Delimiter',',');
fclose(fID);

for ii = 1:size(header,2)
    if strcmp(header{ii},'Timestamps')
        Timestamps = double(Values{ii})/1e6;
        Timestamps = Timestamps - Timestamps(1);
    end
    if strcmp(header{ii},'Timestamps_dev')
        Timestamps_dev = double(Values{ii})/1e6;
        Timestamps_dev = Timestamps_dev - Timestamps_dev(1);
    end
    
    if strcmp(header{ii},'Diameter L')
        DiameterL = Values{ii};
    end
    if strcmp(header{ii},'Diameter R')
        DiameterR = Values{ii};
    end
    if strcmp(header{ii},'Trigger')
        Annotation = Values{ii};
    end
    if strcmp(header{ii},'Validity L')
        ValidityL = Values{ii};
    end
    if strcmp(header{ii},'Validity R')
        ValidityR = Values{ii};
    end
end


