function [] = LoadInputs()
    %% Set Global Variables
    global Rwd; global Pnlty;
    global Rwd_Peak; global Pnlty_Peak;
    global Rwd_std; global Pnlty_std;    

    %% Import Data
    headerlinesIn = 1;
    data = importdata('Input.txt','\t',headerlinesIn);

    %% Set variables
    Rwd = data.data(1);
    Pnlty = data.data(2);
    Rwd_Peak = data.data(3);
    Pnlty_Peak = data.data(4);
    Rwd_std = data.data(5);
    Pnlty_std = data.data(6);
end
