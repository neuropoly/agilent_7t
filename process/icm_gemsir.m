function results=icm_gemsir(fname,mask,param)
% EXAMPLE: icm_gemsir gemsir_01.nii.gz gemsir_01_param.mat
load(param)
TR=1.5;
ETL=4;
invert_angle=-1;
excitation_angle=10*pi/180;

nb_ti=length(param.ti(:));

params=[param.ti(:) repmat([param.tr TR ETL invert_angle excitation_angle], nb_ti, 1)];

data=load_nii_data(fname);
dims=size(data);
imagesc3D(data(:,:,:,1))
data=reshape2D(data,4);

mask=load_nii_data(mask);
results=zeros(2,dims(1)*dims(2)*dims(3));
for ivoxel=find(mask(:))'
    guess=[0.5; max(double(data(:,ivoxel)))*6];
    [results(1,ivoxel), results(2,ivoxel), M] = fit_t1_ll_simple(data(:,ivoxel), params, guess);
    plot(param.ti,data(:,ivoxel),'+'); hold on; plot(param.ti,M,'r'); hold off;  ylim([0 max(double(data(:)))*1.1]); drawnow;
end

results=reshape2D_undo(results,4,[dims(1:3) 2]);
save_nii_v2(results(:,:,:,2),'T1',fname)
    

function S=IR_Signal(parameter,Ti,TR,tau,N,alpha)
M0=parameter(1);
T1=parameter(2);
n=2;
tr=TR-Ti-(N-1)*tau;
E1=exp(-Ti/T1); E2=exp(-tau/T1); Er=exp(-tr/T1);
F=(1-E2)/(1-cos(alpha)*E2);

Q=(-F.*cos(alpha).*Er.*E1.*(1-(cos(alpha).*E2).^(N-1))-E1.*(1-Er)-E1+1)./(1+cos(alpha).*Er.*E1.*(cos(alpha).*E2).^(N-1));

Mn=M0.*(F+(cos(alpha).*E2).^(n-1).*(Q-F));

S=abs(sin(alpha)*Mn);
