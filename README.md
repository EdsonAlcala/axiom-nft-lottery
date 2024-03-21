# EarthMind NFT Lottery

## Getting Started

```bash
$ git clone https://github.com/EdsonAlcala/axiom-nft-lottery.git

$ forge install

$ pnpm install
```
## Commands

The repo contains a justfile to facilitate commands for:

- deploy contracts
- test contracts
- execute coverage
- compile circuit
- prove circuit

You can run the following commands:

```bash
$ just deploy_local # Deploy to local environment
$ just deploy_sepolia # Deploy to sepolia testnet
$ just deploy_mainnet # Deploy to mainnet
$ just test_unit # Runs all unit tests
$ just test_coverage # To generate test coverage
$ just test {ContractName} # To run a particular test
$ just test_only {ContractName} {TestName} # To run a particular test in a test
```

npx axiom circuit compile app/axiom/random-winner.circuit.ts