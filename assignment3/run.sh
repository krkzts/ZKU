# Delete the previous output files
rm circuit.rics
rm circuit.sym
rm circuit_*
rm -r circuit_*
rm pot*
rm proof.json
rm public.json
rm verifier.sol
rm verification_key.json
rm witness.wtns

# Compile the circuit
circom isTriangle.circom --r1cs --wasm --sym --c

# Compue the witness with WebAssembly
# A file with the extension .wtns containing all calculated signals and a file with the extension .r1cs containing
# the constraints describing the circuit are created. Both files are used to create the proof.
# first, copy input.json under isTriangle_js
cp input.json ./isTriangle_js/input.json
cd isTriangle_js
node generate_witness.js isTriangle.wasm input.json witness.wtns
# copy the generated witness to the root directory
cp witness.wtns ../witness.wtns
# return to root directory
cd ..

# Start a new "powers of tau" ceremony
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

# Contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v -e="random text"

# Prepare for start of phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

# Generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup isTriangle.r1cs pot12_final.ptau isTriangle_0000.zkey

# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute isTriangle_0000.zkey isTriangle_0001.zkey --name="1st Contributor Name" -v -e="random text"

# Export verification key
snarkjs zkey export verificationkey isTriangle_0001.zkey verification_key.json

# Generate a zero knowledge proof using the zkey and witness
# This command generates a proof of Groth16 and outputs two files.
# proof.json: contains the proof.
# public.json: contains the public input/output values.
snarkjs groth16 prove isTriangle_0001.zkey witness.wtns proof.json public.json

# Verify the proof
# Checks if the proof is valid. If the proof is valid, the command outputs OK.
# A valid proof not only proves that you know the set of signals that satisfy the circuit,
# but also that the public inputs and outputs used match those described in the public.json file.
snarkjs groth16 verify verification_key.json public.json proof.json

# Create a solidity verifier
# It takes the validation key circuit_0001.zkey and outputs the Solidity code to a file named verifier.sol.
snarkjs zkey export solidityverifier isTriangle_0001.zkey verifier.sol

# Generate and print parameters of call
snarkjs generatecall | tee parameters.txt