% p8_noise_temp.m
% written by jared kofron <jared.kofron@gmail.com>
% calculates the total noise temperature of the project 8 receiver
% chain in kelvin.  all noise temperatures in kelvin, all gains in
% dB.
function [temperature gain] = p8_noise_temp()
% convert noise figure to temp
nf_2_t = @(phys_t,nf) phys_t*(10^(nf/10)-1);

% convert gain in dB to relative power
db_2_pw = @(dB) 10^(dB/10);

% window
wind_nf = 0.6;
wind_t = nf_2_t(50,wind_nf);
wind_g = -wind_nf;
wind_pw = db_2_pw(wind_g);

% nrao amp
nrao_t = 30;
nrao_g = 20;
nrao_pw = db_2_pw(nrao_g);

% cable to get from NRAO to HF cascade
cable_nf = 10;
cable_t  = nf_2_t(200,cable_nf);
cable_g  = -10;
cable_pw = db_2_pw(cable_g);

% high frequency amp Quinstar QLW-18262530-J0
quin_nf = 2.5;
quin_t = nf_2_t(300,quin_nf);
quin_g  = 30;
quin_pw = db_2_pw(quin_g);

% high frequency filter Lorch 4E27-26000
lorch_nf = 0.5;
lorch_t  = nf_2_t(300,lorch_nf);
lorch_g = -0.5;
lorch_pw  = db_2_pw(lorch_g);

% high frequency mixer Miteq TB0426LW1
miteq_nf = 10;
miteq_t  = nf_2_t(300,miteq_nf);
miteq_g = -10;
miteq_pw  = db_2_pw(miteq_g);

% low frequency input amp Mini-Circuits ZX60-3018G-S+
n_amps = 3;
zx60_nf = 2.7;
zx60_t  = nf_2_t(300,zx60_nf);
zx60_g  = 20;
zx60_pw = db_2_pw(zx60_g);

% low frequency mixer Polyphase IRM0622B
poly_nf = 9;
poly_t = nf_2_t(300,poly_nf);
poly_g = -10;
poly_pw = db_2_pw(poly_g);

% low frequency DC block filter MC ZFHP-0R055-S+
% loss is quoted as < 1.6dB over passband
dcblk_nf = 1.6;
dcblk_t  = nf_2_t(300,dcblk_nf);
dcblk_g  = -1.6;
dcblk_pw = db_2_pw(dcblk_g);

% low frequency anti-aliasing filter MC SLP-90+
% loss quoted as < 1dB over passband
aaf_nf = 1;
aaf_t = nf_2_t(300,aaf_nf);
aaf_g = -1;
aaf_pw = db_2_pw(aaf_g);

% low frequency directional coupler MC ZX30-17-5-S+
% looks to average out around 1dB loss
coup_nf = 1;
coup_t = nf_2_t(300,coup_nf);
coup_g = -1;
coup_pw = db_2_pw(coup_g);

gain = wind_g + nrao_g + cable_g + quin_g + lorch_g + miteq_g + n_amps*zx60_g + poly_g ...
       + dcblk_g + aaf_g + coup_g;

% friis equation!
temperature = wind_t + nrao_t/wind_pw +...
    cable_t/(wind_pw*nrao_pw) +...
    quin_t/(wind_pw*nrao_pw*cable_pw) +...
    lorch_t/(wind_pw*nrao_pw*quin_pw*cable_pw) +...
    miteq_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*cable_pw) +...
    zx60_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*cable_pw) +...
    zx60_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*zx60_pw*cable_pw) +...
    zx60_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*zx60_pw^2*cable_pw) +...
    poly_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*zx60_pw^3*cable_pw) +...
    dcblk_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*zx60_pw^3*poly_pw*cable_pw) +...
    aaf_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*zx60_pw^3*poly_pw*dcblk_pw*cable_pw) +...
    coup_t/(wind_pw*nrao_pw*quin_pw*lorch_pw*miteq_pw*zx60_pw^3*poly_pw*dcblk_pw*aaf_pw*cable_pw);
end