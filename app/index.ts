
import { circuit, CircuitInputs } from "./axiom/winner.circuit";
import dotenv from "dotenv";
dotenv.config();
import { Axiom, UserInput } from '@axiom-crypto/client';

// Inputs to the circuit
import inputs from './axiom/data/inputs.json';

// Compiled circuit file after running: npx axiom circuit compile app/axiom/winner.circuit.ts
import compiledCircuit from "./axiom/data/compiled.json";

const axiomMain = async (input: UserInput<CircuitInputs>) => {
    const axiom = new Axiom({
        circuit: circuit,
        compiledCircuit: compiledCircuit,
        chainId: "11155111",  // Sepolia
        provider: process.env.RPC_URL_SEPOLIA as string,
        privateKey: process.env.PRIVATE_KEY_SEPOLIA as string,
        callback: {
            target: "0x3639a81AD449039f00DDBf84487435864Cd37161",
        },
    });
    await axiom.init();
    const args = await axiom.prove(input);
    console.log("ZK proof generated successfully.");

    if (!process.env.PRIVATE_KEY_SEPOLIA) {
        console.log("No private key provided: Query will not be sent to the blockchain.");
        return;
    }

    console.log("Sending Query to Axiom on-chain...");
    const receipt = await axiom.sendQuery();
    console.log("Transaction receipt:", receipt);
    console.log(`View your Query on Axiom Explorer: https://explorer.axiom.xyz/v2/sepolia/query/${args.queryId}`);
};

axiomMain(inputs);