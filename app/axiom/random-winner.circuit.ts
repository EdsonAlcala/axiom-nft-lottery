import {
    add,
    addToCallback,
    checkLessThan,
    CircuitValue,
    constant,
    getHeader,
    mod,
} from "@axiom-crypto/client";


export interface CircuitInputs {
    itemId: CircuitValue;
    blockNumberWhenNFTWasMinted: CircuitValue;
    blockNumberWhenWinnerSelected: CircuitValue;
    totalTickets: CircuitValue;
    totalNFTs: CircuitValue;
}

// Default inputs for the circuit
export const defaultInputs = {
    "itemId": 1,
    "blockNumberWhenNFTWasMinted": 5000000,
    "blockNumberWhenWinnerSelected": 5000010,
    "totalTickets": 1000, // TODO: Can I make this accessible via storage read?
    "totalNFTs": 420, // TODO: Can I make this accessible via storage read?
};

export const circuit = async (inputs: CircuitInputs) => {
    checkLessThan(inputs.blockNumberWhenWinnerSelected, inputs.blockNumberWhenNFTWasMinted);

    checkLessThan(inputs.itemId, inputs.totalNFTs)

    const headerAtBlockWhenWinnerIsSelected = getHeader(inputs.blockNumberWhenWinnerSelected);

    const randaoValue = await headerAtBlockWhenWinnerIsSelected.mixHash();

    checkLessThan(constant(0), inputs.totalTickets)

    // module of the random value with the total tickets + 1 to get the ticket number of the winner in the range [1, totalTicketsValue]
    const ticketIdWinner = add(mod(randaoValue.hi(), inputs.totalTickets), 1);

    addToCallback(inputs.itemId);
    addToCallback(inputs.blockNumberWhenNFTWasMinted);
    addToCallback(inputs.blockNumberWhenWinnerSelected);
    addToCallback(inputs.totalTickets);
    addToCallback(inputs.totalNFTs);
    addToCallback(ticketIdWinner);
};