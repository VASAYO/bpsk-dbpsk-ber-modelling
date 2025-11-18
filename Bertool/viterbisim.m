function [ber, numBits] = viterbisim(EbNo, maxNumErrs, maxNumBits)
%VITERBISIM Viterbi decoder simulation example for BERTool.
%
%   [BER, NUMBITS] = VITERBISIM(EBNO, MAXNUMERRS, MAXNUMBITS) simulates a
%   Quaternary Phase Shift Keying (QPSK) or Binary PSK (BPSK) system over
%   an additive white Gaussian noise (AWGN) channel using convolutional
%   encoding and the Viterbi decoding algorithm with hard decision
%   decoding. EBNO is a vector of Eb/No values, MAXNUMERRS is the maximum
%   number of errors to collect before stopping, and MAXNUMBITS is the
%   maximum number of bits to run before stopping. BER is the computed bit
%   error rate, and NUMBITS is the actual number of bits run.
%
%   This function shows how to write a MATLAB simulation function for
%   BERTool, and cannot run without BERTool.

%   Copyright 2020-2023 The MathWorks, Inc.

narginchk(3,3)

% ==== DO NOT MODIFY if you intend to generate MEX file with MATLAB Coder. ====
% ==== Otherwise, you can remove the following two lines. ====
%#codegen
coder.extrinsic('isBERToolSimulationStopped')
% ==== END of DO NOT MODIFY ====

% Define number of bits per symbol (k). M = 4 for QPSK or 2 for BPSK.
M = 4;
k = log2(M);

% Code rate
codeRate = 1/2; 

% Create a rate 1/2, constraint length 7 ConvolutionalEncoder System
% object. This encoder takes one-bit symbols as inputs and generates 2-bit
% symbols as outputs.
enc = comm.ConvolutionalEncoder(poly2trellis(7, [171 133]));

% Adjust SNR for coded bits and multi-bit symbols.
snr = convertSNR(EbNo,"ebno",CodingRate=codeRate,BitsPerSymbol=k);

% Configure a comm.ViterbiDecoder System object to act as the decoder.
% Since the convolutional decoder makes hard decisions in this example, set
% the 'InputFormat' property to 'Hard'. This example uses a traceback depth
% of 32.
dec = comm.ViterbiDecoder(poly2trellis(7, [171 133]), ...
  InputFormat="Unquantized", TracebackDepth=32);

% Create a comm.ErrorRate System object to compare the decoded bits to the
% original transmitted bits. The output of the comm.ErrorRate object is a
% three-element vector containing the calculated bit error rate (BER), the
% number of errors observed, and the number of bits processed. The Viterbi
% decoder creates a delay in the output decoded bit stream equal to the
% traceback length. To account for this delay set the 'ReceiveDelay'
% property of the comm.ErrorRate object to the value of the
% 'TraceBackDepth' property of the comm.ViterbiDecoder object.
errorCalc = comm.ErrorRate(ReceiveDelay=dec.TracebackDepth);

% Create a vector to store current values of the bit error rate, errors
% incurred and number of bits processed.
v = zeros(3,1);

% Set the number of bits per iteration
bitsPerIter = 1e4;
% Exit loop when either the number of bit errors exceeds 'maxNumErrs'
% or the maximum number of iterations have been completed
while ((v(2) < maxNumErrs) && (v(3) <= maxNumBits))
    
    % ==== DO NOT MODIFY ====
    if isBERToolSimulationStopped()
        break
    end
    % ==== END of DO NOT MODIFY ====

    % Generate message bits
    data = randi([0 1], bitsPerIter, 1);
    % Convolutionally encode
    encData = enc(data);                
    % Modulate. Default is gray-coded symbol mapping.
    modData = pskmod(encData,M,pi/8,InputType="bit");
    % AWGN channel
    [channelOutput, nvar] = awgn(modData,snr);
     % Demodulate. Default is gray-coded symbol mapping.
    demodData = pskdemod(channelOutput,M,pi/8,OutputType="llr", ...
        NoiseVariance=nvar);
    % Viterbi decode
    decData = dec(demodData);
    % Count errors
    v = errorCalc(data, decData);

end

% Assign values to ber and numBits
ber = v(1);
numBits = v(3);
