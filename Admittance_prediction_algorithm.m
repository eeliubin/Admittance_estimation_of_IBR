function Z_pred=Admittance_prediction_algorithm(Vd_pred,Id_pred,Iq_pred,M,N,P,Avail_imp_data)
% Vectors composed of measurement results
T_PxN_mat1=zeros(P,N);
for p=1:1:P
    for m=0:1:M
        for i=m:-1:0
            for j=m-i:-1:0
                n=(m+1)*(m+2)*(m+3)/6+(i*(i-2*m-3))/2-j;
                T_PxN_mat1(p,n)=Avail_imp_data(p,4)*Avail_imp_data(p,1)^(i)*Avail_imp_data(p,2)^(j)*Avail_imp_data(p,3)^(m-i-j);
            end
        end
    end
end
T_PxN_mat2=zeros(P,N);
for p=1:1:P
    for m=0:1:M
        for i=m:-1:0
            for j=m-i:-1:0
                n=(m+1)*(m+2)*(m+3)/6+(i*(i-2*m-3))/2-j;
                T_PxN_mat2(p,n)=-Avail_imp_data(p,1)^(i)*Avail_imp_data(p,2)^(j)*Avail_imp_data(p,3)^(m-i-j);
            end
        end
    end
end

% Vector composed of result to be predicted
T_N_pred=zeros(N,1);
for m=0:1:M
    for i=m:-1:0
        for j=m-i:-1:0
            n=(m+1)*(m+2)*(m+3)/6+(i*(i-2*m-3))/2-j;
            T_N_pred(n,1)=Vd_pred^(i)*Id_pred^(j)*Iq_pred^(m-i-j);
        end
    end
end


% Calculation of the impedance to be predicted using arbitrary admittance data points
T_PxN_mat2_transpose=transpose(T_PxN_mat2);
T_PxN_mat2_part1=T_PxN_mat2_transpose(:,1:N);
T_PxN_mat2_part2=T_PxN_mat2_transpose(:,N+1:P);
C_N=-inv(T_PxN_mat2_part1)*T_PxN_mat2_part2;
D_N=-inv(T_PxN_mat2_part1)*T_N_pred;
C_N1=[C_N;eye(P-N)];
D_N1=[D_N;zeros(P-N,1)];
Z_pred_vector=([T_N_pred,-transpose(T_PxN_mat1)*C_N1])\(transpose(T_PxN_mat1)*D_N1);
Z_pred=Z_pred_vector(1,1);
