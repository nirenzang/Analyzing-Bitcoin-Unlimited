# Analyzing-Bitcoin-Unlimited
This is the evaluation code used in the [CoNEXT 2017](http://conferences2.sigcomm.org/co-next/2017/#!/home) paper ["On the Necessity of a Prescribed Block Validity Consensus: Analyzing Bitcoin Unlimited Mining Protocol"](https://eprint.iacr.org/2017/686.pdf) by [Ren Zhang](https://scholar.google.be/citations?user=JB1uRvQAAAAJ&hl=en) and [Bart Preneel](https://scholar.google.be/citations?user=omio-RsAAAAJ&hl=en). The code computes the optimal strategies and the maximum utility of a strategic miner in BU, under a predefined mining power distribution. Three utility functions are defined according to the strategic miner's three incentive models: compliant and profit-driven, non-compliant and profit-driven, non-profit-driven. Please check the paper for the complete definitions of the settings. This code is programmed by Ren Zhang.

**Important: this code is published due to the requirement of the CoNEXT conference. There is a bug in the "non-compliant and profit-driven" part of the code which might lead to inaccurate results. The developer will fix the bug and the numbers in the paper soon.**

The MDP state encoding and transition are quite complicated: many information regarding the structure of the blockchain needs to be encoded in the state to help the attacker make decisions. Therefore if you wish to fully understand and modify this source code rather than using it as a blackbox to execute and compare the results, the developer strongly recommend you to read the paper ["the Optimal Selfish Mining Strategies"](http://www.cs.huji.ac.il/~yoni_sompo/pubs/15/SelfishMining.pdf) and understand [my implementation](https://github.com/nirenzang/Optimal-Selfish-Mining-Strategies-in-Bitcoin) of their algorithm before modifying this code. 

## Quick Start
If you only need the results:
1. Make sure you have matlab.
2. Download the [MDP toolbox for matlab](https://nl.mathworks.com/matlabcentral/fileexchange/25786-markov-decision-processes--mdp--toolbox), decompress it, put it in a directory such as '/users/yourname/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox', copy the path.
3. Download the code, open Matlab, change the working dir to the dir of the code.
4. Open `Init.m`, paste your MDP toolbox path in the first line 
```
addpath('/users/yourname/Desktop/matlab/MDPtoolbox/fsroot/MDPtoolbox');
```
5. Modify *AD*, *alpha*, *beta*, *gamma* in `Init.m`. See there definitions in the paper.
6. Run `Init.m`.

## Implementation
* `Init.m`
The portal of the program. The parameters are defined here.
* `st2stnum.m`
A state in the paper is denoted as a 5-tuple. However in MDP, a state needs to be encoded as a number. This function converts a state tuple into the relevant number. 
* `stnum2st.m` 
This function does the reverse conversion.
* `SolveStrategy.m`
The code that actually computes the optimal mining strategies. The structure of the code follows the paper.
* `Checkstnum2st.m`
A test file, check whether `st2stnum.m` and `stnum2st.m` are bijection.

## Citation
Zhang R., Preneel B. (2017) On the Necessity of a Prescribed Block Validity Consensus: Analyzing Bitcoin Unlimited Mining Protocol. In: Proceedings of the 13th International on Conference on emerging Networking EXperiments and Technologies. ACM, 2017.
```
@inproceedings{Zhang2017BU,
 author = {Ren Zhang and Bart Preneel},
 title = {On the Necessity of a Prescribed Block Validity Consensus: Analyzing {B}itcoin {U}nlimited Mining Protocol},
 booktitle = {Proceedings of the 13th International on Conference on Emerging Networking EXperiments and Technologies},
 series = {CoNEXT '17},
 year = {2017},
 publisher = {ACM}
} 
```
Chadès, I., Chapron, G., Cros, M. J., Garcia, F., & Sabbadin, R. (2014). MDPtoolbox: a multi‐platform toolbox to solve stochastic dynamic programming problems. Ecography, 37(9), 916-920.
```
@article{chades2014mdptoolbox,
  title={MDPtoolbox: a multi-platform toolbox to solve stochastic dynamic programming problems},
  author={Chad{\`e}s, Iadine and Chapron, Guillaume and Cros, Marie-Jos{\'e}e and Garcia, Fr{\'e}d{\'e}rick and Sabbadin, R{\'e}gis},
  journal={Ecography},
  volume={37},
  number={9},
  pages={916--920},
  year={2014},
  publisher={Wiley Online Library}
}
```

## License
This code is licensed under GNU GPLv3.
