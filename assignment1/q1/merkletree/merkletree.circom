pragma circom 2.0.0;

include "./node_modules/circomlib/circuits/mimcsponge.circom";

template MerkleRoot(n) {
    signal input leaves[n];
    signal output root;
    var nodeNums = n * 2 - 1;

    component nodes[nodeNums];

    var temp[nodeNums];
    for (var i = 0; i < n; i++) {
        temp[i] = leaves[i];
    }

    for (var i = 2; i < nodeNums; i += 2) {
        var parent = i / 2 + n - 1;
        nodes[parent] = MiMCSponge(2, 220, 1);
        nodes[parent].ins[0] <== temp[i - 2];
        nodes[parent].ins[1] <== temp[i - 1];
        nodes[parent].k <== 0;
        temp[parent] = nodes[parent].outs[0];
    }

    root <== nodes[nodeNums - 1].outs[0];
}

component main {public [leaves]} = MerkleRoot(8);