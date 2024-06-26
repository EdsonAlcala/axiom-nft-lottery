// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {EarthMindNFT} from "@contracts/EarthMindNFT.sol";
import {DeploymentUtils} from "@utils/DeploymentUtils.sol";
import {DeployerUtils} from "@utils/DeployerUtils.sol";
import {Constants} from "@constants/Constants.sol";

import {BaseScript} from "./BaseScript.s.sol";
import {console2} from "forge-std/console2.sol";
import {Vm} from "forge-std/Vm.sol";

contract EarthMindDeployScript is BaseScript {
    using DeployerUtils for Vm;
    using DeploymentUtils for Vm;

    function run() public {
        console2.log("Deploying EarthMindNFT contract");
        deployer = vm.loadDeployerAddress();

        console2.log("Deployer Address");
        console2.logAddress(deployer);

        vm.startBroadcast(deployer);

        address ticketAddress = vm.loadDeploymentAddress(Constants.EARTHMIND_TICKET);
        console2.log("EarthMindTicket Address");
        console2.logAddress(ticketAddress);

        EarthMindNFT earthMindNFT = new EarthMindNFT(
            ticketAddress, config.axiomV2QueryAddress, config.callbackSourceChainId, config.querySchema
        );
        console2.log("EarthMindNFT Address");
        console2.logAddress(address(earthMindNFT));

        vm.saveDeploymentAddress(Constants.EARTHMIND_NFT, address(earthMindNFT));
    }
}
