%% LTSPice to Matlab
Bipolar_UF3C065040K4S_Raw = LTspice2Matlab('Bipolar_UF3C065040K4S_DeadTime.raw');

%% Definition of Arrays
t = Bipolar_UF3C065040K4S_Raw.time_vect;
Vsw_DS1 = Bipolar_UF3C065040K4S_Raw.variable_mat(10,:)-Bipolar_UF3C065040K4S_Raw.variable_mat(8,:);
Isw_1 = Bipolar_UF3C065040K4S_Raw.variable_mat(45,:);
%% NaN Value Elimination with Average
for i = 1:numel(t)
    if (isnan(Vsw_DS1(i)))
        a = 0;
        count = 0;
        for j = -3:3
            if (isnan(Vsw_DS1(i+j)) == 0)
                a = a + Vsw_DS1(i+j);
                count = count + 1;
            end
        end
        Vsw_DS1(i) = a/count;
    end
    if (isnan(Isw_1(i)))
        a = 0;
        count = 0;
        for j = -3:3
            if (isnan(Isw_1(i+j)) == 0)
                a = a + Isw_1(i+j);
                count = count + 1;
            end
        end
        Isw_1(i) = a/count;
    end
end
%% Total Loss of Semiconductors
T = 0;
for i = 1:numel(t)-1
    %Esw(i) = Vsw_DS1(i)*Isw_1(i)*t(i);
    Esw(i) = (Vsw_DS1(i+1)+Vsw_DS1(i))*0.5*(Isw_1(i+1)+Isw_1(i))*0.5*(t(i+1)-t(i));
    if (isnan(Esw(i)) == 0)
        T = T + Esw(i);
    end
end
Psw = T*50;
