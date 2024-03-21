set dotenv-load
set export

# contract deployments
deploy_all JSON_RPC_URL SENDER:
    forge script script/000_EarthMind_Deploy_Ticket.s.sol:EarthMindDeployTicketScript --rpc-url $JSON_RPC_URL --sender $SENDER --broadcast --verify --ffi -vvvv
    forge script script/001_EarthMind_Deploy.s.sol:EarthMindDeployScript --rpc-url $JSON_RPC_URL --sender $SENDER --broadcast --verify --ffi -vvvv
    forge script script/002_TransferOwnership.s.sol:TransferOwnershipScript --rpc-url $JSON_RPC_URL --sender $SENDER --broadcast --verify --ffi -vvvv

deploy_local:
    echo "Deploying contracts locally"
    NETWORK_ID=$CHAIN_ID_LOCAL MNEMONIC=$MNEMONIC_LOCAL just deploy_all $RPC_URL_LOCAL $SENDER_LOCAL

deploy_sepolia:
    echo "Deploying contracts to Sepolia testnet"
    NETWORK_ID=$CHAIN_ID_SEPOLIA MNEMONIC=$MNEMONIC_SEPOLIA just deploy_all $RPC_URL_SEPOLIA $SENDER_SEPOLIA

deploy_mainnet:
    echo "Deploying contracts to Mainnet"
    NETWORK_ID=$CHAIN_ID_MAINNET MNEMONIC=$MNEMONIC_MAINNET just deploy_all $RPC_URL_MAINNET $SENDER_MAINNET

# orchestration and testing
test_unit:
    echo "Running unit tests"
    forge test --match-path "test/unit/**/*.sol"

test_coverage:
    forge coverage --report lcov 
    lcov --remove ./lcov.info --output-file ./lcov.info 'script' 'DeployerUtils.sol' 'DeploymentUtils.sol'
    genhtml lcov.info -o coverage --branch-coverage --ignore-errors category

test CONTRACT:
    forge test --mc {{CONTRACT}} --ffi -vvvv

test_only CONTRACT TEST:
    forge test --mc {{CONTRACT}} --mt {{TEST}} --ffi -vvvv

# axiom
compile_circuit:
    echo "Compiling circuit"
    npx axiom circuit compile app/axiom/winner.circuit.ts --provider $RPC_URL_SEPOLIA

prove_circuit:
    echo "Proving circuit"
    npx axiom circuit prove app/axiom/data/compiled.json app/axiom/data/input.json --provider $RPC_URL_SEPOLIA