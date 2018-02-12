function drawRarefactionCurve(inFileName,varargin)
% drawRarefactionCurve(inFileName)
% Plot rarefaction curve with each number of subsamples.
% Required input:
% 'inFileName': String. Directory and name of input file.
% Optional inputs:
% 'outFileName': String. Directory and name of output figure. Default is same as 'inFileName'
% 'color': String or 1x3 numeric array. Color of plotted line. Default is 'k' (black).
% 'format': String. Format of output figure. Default is 'pdf'.
% 'hold': 0 or 1. Hold the figure for further plots. Default is 0.

%% add optional inputs
p = inputParser;

[filepath,name,~] = fileparts(inFileName);
defaultOutFileName = fullfile(filepath,name);

defaultColor = 'k';
validColors = {'r','g','b','y','m','c','k'};
checkColor = @(x) (ismember(char(x),validColors) || (isnumeric(x) && length(x)==3));

defaultFormat = 'pdf';
validFormats = {'fig','m','jpg','png','eps','pdf','bmp','emf','pbm','pcx','pgm','ppm','tif'};
checkFormat = @(x) any(validatestring(x,validFormats));

defaultHold = 0;
checkHold = @(x) x==0 || x==1;

addRequired(p,'inFileName',@ischar);
addOptional(p,'outFileName',defaultOutFileName);
addOptional(p,'color',defaultColor,checkColor);
addOptional(p,'format',defaultFormat,checkFormat);
addParameter(p,'hold',defaultHold,checkHold);

%% read data
fid = fopen(inFileName,'r');
dataArray = textscan(fid,'%d%f','delimiter',',','HeaderLines',1);
fclose(fid);
X = dataArray{1,1};
Y = dataArray{1,2};

%% plot
plot(X,Y,'color',color,'LineWidth',3);
xlabel('Subsample','FontSize',14,'FontWeight','bold');
ylabel('True diversity','FontSize',14,'FontWeight','bold');
set(gca,'FontSize',14,'FontWeight','bold');
if p.Results.hold==1
    hold on;
elseif p.Results.hold==0
    hold off;
    saveas(gcf,outFileName,format);
end
