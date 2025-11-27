function [] = plotpreproc(RawDiameter,CleanedDiameter,LP_Diameter,RepairedDiameter,Metadata_Cleaning,Metadata)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Plotting
figure
subplot(2,1,1)
hold on
plot(Metadata.Time,RawDiameter,'Linewidth',2)
plot(Metadata.Time,CleanedDiameter,'Linewidth',2)
plot(Metadata.Time,RepairedDiameter,'Linewidth',1)
plot(Metadata.Time,LP_Diameter,'Linewidth',2)
hold off
legend({'Raw';'Cleaned';'Repaired';'Low-pass'})
title('Timecourses')
subplot(2,1,2)
hold on
scatter(find(isnan(RawDiameter)),6*ones(sum(isnan(RawDiameter)),1),'filled')
scatter(find(Metadata_Cleaning.SetNanRange),5*ones(sum(Metadata_Cleaning.SetNanRange),1),"x",'MarkerEdgeColor',[0.8500 0.3250 0.0980])
scatter(find(Metadata_Cleaning.SetNanDiff),4*ones(sum(Metadata_Cleaning.SetNanDiff),1),"x",'MarkerEdgeColor',[0.8500 0.3250 0.0980])
scatter(find(isnan(CleanedDiameter)),3*ones(sum(isnan(CleanedDiameter)),1),'filled','MarkerEdgeColor',[0.8500 0.3250 0.0980],'MarkerFaceColor',[0.8500 0.3250 0.0980])
scatter(find(Metadata.SetNan),2*ones(sum(Metadata.SetNan),1),"x",'MarkerEdgeColor',[0.9290 0.6940 0.1250])
scatter(find(isnan(RepairedDiameter)),1*ones(sum(isnan(RepairedDiameter)),1),'filled','MarkerEdgeColor',[0.9290 0.6940 0.1250],'MarkerFaceColor',[0.9290 0.6940 0.1250])
scatter(find(isnan(LP_Diameter)),0*ones(sum(isnan(LP_Diameter)),1),'filled','MarkerEdgeColor',[0.4940 0.1840 0.5560],'MarkerFaceColor',[0.4940 0.1840 0.5560])
ylim([-.6 6.5])
yticks(0:6)
yticklabels({'low-pass';'Repaired';'ContCrit';'Cleaned';'DiffCrit';'RangeCrit';'Raw'})
title('Missing values (.) and removed values (x)')
hold off


end

