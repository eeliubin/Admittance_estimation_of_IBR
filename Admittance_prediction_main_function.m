clc;
clear all;
addpath Theoretical_admittance_models;

% Configuration of the impedance prediction algorithm 
M=2; % Selection of the highest order of combination of Vd, Id, and Iq
% freq=1; % Selection of the frequency point of interest

% Selection of the control mode
Control_mode=4; % 1: Current control GFLI, 2: Voltage control GFLI, 3: Power control GFLI, 4: VSG control GFMI.
Mea_err=2; % 1: Consider measurement error, 2: Not consider measurement error.
% The number of needed measurement data 
N=M*(M^2+6*M+11)/6+1; % Number of all possible polynominal terms composed of Vd, Id, and Iq
P=2*N-1; % Number of the available impedance data


% Generate the arbitrary three-dimensional operating point space
Avail_imp_data=zeros(P,4);
Avail_imp_data(:,1)= 469*(1+(2*rand(P,1)-1)/10); % Vd is varied from 0.9 p.u. to 1.1 p.u.
Avail_imp_data(:,2)= 4264*rand(P,1); % Id is varied from 0 p.u. to 1.0 p.u.
Avail_imp_data(:,3)= 4264*(2*rand(P,1)-1);


% Operating points where impedance data are to be predicted
Vd_pred=469*1;Id_pred=4264*0.3; Iq_pred=4264*0.3;

Z_pred_ref=[];Z_pred=[];
for freq=[1,2,5,10,40,100]
%for freq=1:1:1
% Calculate the theoretical impedance model at these random operating points
    for p=1:P
        if Control_mode==1
        Avail_imp_data(p,4)= Admittance_model_of_CC_PLL_GFLI(Avail_imp_data(p,1),Avail_imp_data(p,2),Avail_imp_data(p,3),freq);
        elseif Control_mode==2
            Avail_imp_data(p,4)= Admittance_model_of_Vdc_Vac_CC_PLL_GFLI(Avail_imp_data(p,1),Avail_imp_data(p,2),Avail_imp_data(p,3),freq);
        elseif Control_mode==3
            Avail_imp_data(p,4)= Admittance_model_of_PQ_CC_PLL_GFLI(Avail_imp_data(p,1),Avail_imp_data(p,2),Avail_imp_data(p,3),freq);
        else
            Avail_imp_data(p,4)= Admittance_model_of_VSG_GFMI(Avail_imp_data(p,1),Avail_imp_data(p,2),Avail_imp_data(p,3),freq);
        end
    end
if Mea_err==1
   err_per=5;
   measurement_error=err_per*real(Avail_imp_data(:,4)).*(2*rand(P,1)-1)/100+1i*err_per*imag(Avail_imp_data(:,4)).*(2*rand(P,1)-1)/100;
   Avail_imp_data(:,4)=Avail_imp_data(:,4)+measurement_error;
end
% Theoretical impedance data to be predicted at the operaing points
if Control_mode==1
   z_pred_ref= Admittance_model_of_CC_PLL_GFLI(Vd_pred,Id_pred,Iq_pred,freq);
   elseif Control_mode==2
          z_pred_ref= Admittance_model_of_Vdc_Vac_CC_PLL_GFLI(Vd_pred,Id_pred,Iq_pred,freq);
   elseif Control_mode==3
          z_pred_ref= Admittance_model_of_PQ_CC_PLL_GFLI(Vd_pred,Id_pred,Iq_pred,freq);
   else
          z_pred_ref= Admittance_model_of_VSG_GFMI(Vd_pred,Id_pred,Iq_pred,freq);
end
z_pred_ref=[freq,z_pred_ref];
Z_pred_ref=[Z_pred_ref;z_pred_ref];
% Implement the impedance prediction algorihm
z_pred=Admittance_prediction_algorithm(Vd_pred,Id_pred,Iq_pred,M,N,P,Avail_imp_data);
z_pred=[freq,z_pred];
Z_pred=[Z_pred;z_pred];
end

% Plot the theoretical and predicted impedance data
figure(2);
subplot(2,1,1);
loglog(Z_pred_ref(:,1),abs(Z_pred_ref(:,2)));
hold on
subplot(2,1,2);
semilogx(Z_pred_ref(:,1),mod(170+180*angle(Z_pred_ref(:,2))/pi,360)-170);
hold on 
subplot(2,1,1);
loglog(Z_pred(:,1),abs(Z_pred(:,2)));
hold on 
subplot(2,1,2);
semilogx(Z_pred(:,1),mod(170+180*angle(Z_pred(:,2))/pi,360)-170);


