// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindNFT} from "@contracts/EarthMindNFT.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {DeployerUtils} from "@utils/DeployerUtils.sol";

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract RequestAndApproveScript is Script {
    using DeployerUtils for Vm;
    using DeploymentUtils for Vm;

    address internal deployer;

    function run() public {
        console2.log("Requesting and approving an NFT");
        deployer = vm.loadDeployerAddress();

        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        address earthMindNFTAddress = vm.loadDeploymentAddress("EarthMindNFT");
        EarthMindNFT earthMindNFT = EarthMindNFT(earthMindNFTAddress);

        string memory metadataURI = "ipfs://QmdiZADNgiJwi6i6qQ3QwWMA6iq77dbHwDof8ukNPaAZDL";

        earthMindNFT.mintNFT(metadataURI);
    }
}
