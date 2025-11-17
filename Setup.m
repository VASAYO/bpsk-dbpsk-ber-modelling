Mapper.Type = 'PSK';
Mapper.isTransparent = false;
Channel.isTransparent = false;
Mapper.ModulationOrder = 4;

BER.h2dBInit = 0;

% End of Params
Mapper.Type = 'DBPSK';
Mapper.isTransparent = false;
Channel.isTransparent = false;
Mapper.DecisionMethod = 'llr';

BER.h2dBInit = 0;
