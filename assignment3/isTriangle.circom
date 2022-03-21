pragma circom 2.0.0;

include "./node_modules/circomlib/circuits/comparators.circom";
include "./node_modules/circomlib/circuits/gates.circom";

template IsTriangle() {
    signal input Ax;
    signal input Ay;
    signal input Bx;
    signal input By;
    signal input Cx;
    signal input Cy;
    signal input energy;

    signal output is;

    /* check if the move lies on a triangle.
       if the area is zero, it cannot be a triangle.
       area = 1/2|(x1−x3)(y2−y3)−(x2−x3)(y1−y3)|
    */
    signal first;
    signal second;
    signal area;
    first <== (Ax-Cx)*(By-Cy);
    second <== (Bx-Cx)*(Ay-Cy);
    area <== first - second;

    component isZero = IsZero();
    isZero.in <== area;

    component neg = negation();
    neg.in <== isZero.out;

    /*
    check if the distance is less than energy
    */
    component ABLessThanEnergy = isLessThanEnergy();
    ABLessThanEnergy.ax <== Ax;
    ABLessThanEnergy.ay <== Ay;
    ABLessThanEnergy.bx <== Bx;
    ABLessThanEnergy.by <== By;
    ABLessThanEnergy.energy <== energy;

    component BCLessThanEnergy = isLessThanEnergy();
    BCLessThanEnergy.ax <== Bx;
    BCLessThanEnergy.ay <== By;
    BCLessThanEnergy.bx <== Cx;
    BCLessThanEnergy.by <== Cy;
    BCLessThanEnergy.energy <== energy;

    /*
    output
    */
    component validate = MultiAND(3);
    validate.in[0] <== neg.out;
    validate.in[1] <== ABLessThanEnergy.out;
    validate.in[2] <== BCLessThanEnergy.out;
    is <== validate.out;
}


template negation() {
    signal input in;
    signal output out;

    signal temp;
    temp <-- -1;

    out <== in*temp+1;
}

template isLessThanEnergy() {
    signal input ax;
    signal input ay;
    signal input bx;
    signal input by;
    signal input energy;

    signal output out;

    signal distance;

    signal X;
    signal Y;
    X <== bx - ax;
    Y <== by - ay;

    signal Xsq;
    signal Ysq;
    Xsq <== X * X;
    Ysq <== Y * Y;

    distance <== Xsq + Ysq;

    component lessEqThan = LessEqThan(64);
    lessEqThan.in[0] <== distance;
    lessEqThan.in[1] <== energy * energy;

    out <== lessEqThan.out;
}

component main = IsTriangle();