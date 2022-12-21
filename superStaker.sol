// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "https://github.com/rocket-pool/rocketpool/blob/master/contracts/interface/RocketStorageInterface.sol";
import "https://github.com/rocket-pool/rocketpool/blob/master/contracts/interface/deposit/RocketDepositPoolInterface.sol";
import "https://github.com/rocket-pool/rocketpool/blob/master/contracts/interface/token/RocketTokenRETHInterface.sol";
import "https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol";



contract SuperStaker {

    RocketStorageInterface rocketStorage = RocketStorageInterface(0x1d8f8f00cfa6758d7bE78336684788Fb0ee0Fa46);

    mapping(address => uint256) userShares;
    uint totalShares;
    mapping(address => uint) rEthMintedbyContract;

    constructor(address _rocketStorageAddress) {
        rocketStorage = RocketStorageInterface(_rocketStorageAddress);
    }

    function vault_Deposit() public payable {
        require(msg.value > 1 gwei, "More than 0 pls");
        userShares[msg.sender] += msg.value;
        totalShares += msg.value;
    }


    function depositRocketPool() external  {

        // Load contracts
        address rocketDepositPoolAddress = rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", "rocketDepositPool")));
        RocketDepositPoolInterface rocketDepositPool = RocketDepositPoolInterface(rocketDepositPoolAddress);
        address rocketTokenRETHAddress = rocketStorage.getAddress(keccak256(abi.encodePacked("contract.address", "rocketTokenRETH")));
        RocketTokenRETHInterface rocketTokenRETH = RocketTokenRETHInterface(rocketTokenRETHAddress);
        // Forward deposit to RP & get amount of rETH minted
        uint256 rethBalance1 = rocketTokenRETH.balanceOf(address(this));

        uint256 rEthRatio = ((address(this).balance) / 30) / 100;

        rocketDepositPool.deposit{value: (rEthRatio)}();
        uint256 rethBalance2 = rocketTokenRETH.balanceOf(address(this));
        require(rethBalance2 > rethBalance1, "No rETH was minted");
        uint256 rethMinted = rethBalance2 - rethBalance1;
        // Update user's balance
        rEthMintedbyContract[msg.sender] += rethMinted;
    }
//pool contract
//0x1e19cf2d73a72ef1332c882f20534b6519be0276

//balancer vault contract
//0xBA12222222228d8Ba445958a75a0704d566BF2C8
//pool id
//0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112-0xae78736cd615f374d3085123a210448e74fc6393-0xc02aaa39b223fe8d0a0e5c4f27ead908

    function provideBalancer() external {

    IBalancerVault balancerVault = IBalancerVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    bytes32 rEthPoolID = 0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112-0xae78736cd615f374d3085123a210448e74fc6393-0xc02aaa39b223fe8d0a0e5c4f27ead908;

    balancerVault.joinPool();
    (IERC20[] memory tokens, , ) = IBalancerVault.getPoolTokens(rEthPoolID);

    }


    
    


}

