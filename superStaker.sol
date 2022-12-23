// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;
import "https://github.com/rocket-pool/rocketpool/blob/master/contracts/interface/RocketStorageInterface.sol";
import "https://github.com/rocket-pool/rocketpool/blob/master/contracts/interface/deposit/RocketDepositPoolInterface.sol";
import "https://github.com/rocket-pool/rocketpool/blob/master/contracts/interface/token/RocketTokenRETHInterface.sol";



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


    function depositRocketPool() internal  {

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

    


/*    function _convertERC20sToAssets(IERC20[] memory tokens) internal pure returns (IAsset[] memory assets) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            assets := tokens
        }
    }
*/


//balancer vault contract
//0xBA12222222228d8Ba445958a75a0704d566BF2C8

//pool id
//0x1e19cf2d73a72ef1332c882f20534b6519be0276000200000000000000000112-0xae78736cd615f374d3085123a210448e74fc6393-0xc02aaa39b223fe8d0a0e5c4f27ead908

//reth address
//0x9559aaa82d9649c7a7b220e7c461d2e74c9a3593
//weth address
//0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2




    function provideBalancer() internal {

    IBalancerVault balancerVault = IBalancerVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);



    bytes32 rEthPoolID = balancerVault.getPoolId();

  

    // should calculate amount to avoid slippage using queryJoin https://dev.balancer.fi/resources/query-batchswap-join-exit#queryjoin
  //  uint256[2] _maxAmountsIn = [uint256.max,uint256.max];





    //get assets
    address wEth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IERC20 rETH = IERC20(0x9559Aaa82d9649C7A7b220E7c461d2E74c9a3593);
    uint256 rETHBalance = rETH.balanceOf(address(this));

    IAsset[] memory assets = new IAsset[](2);
    assets[0] = IAsset(address(rETH));
    assets[1] = IAsset(wEth);

    //asset amounts
    uint256 contractEthAmt = address(this).balance;
    uint[2] memory rEthAndEthAmt = [rETHBalance,contractEthAmt ];

    //joinpool request
    IBalancerVault.JoinPoolRequest memory joinPoolRequest = IBalancerVault
    .JoinPoolRequest({
        assets:assets,
        maxAmountsIn: new uint256[](2),
        userData: abi.encode(
            IBalancerVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
            rEthAndEthAmt,
            1
        ),
        fromInternalBalance:true
    });
    //Joinpool
    balancerVault.joinPool(
        rEthPoolID,
        address(this),
        payable(address(this)),
        joinPoolRequest
    );

    }

   function withdrawBalancer() public {

       //withdraw from balancer

      
       
   }


    //execute strategy
    function executeStrategy() public {

        depositRocketPool();
        provideBalancer();

    }



   // end strategy

   function endStrategy() public {

       //require 1 year has passed

       //withdraw from balancer

       //swap reth for weth

       //burn weth

       //open user withdrawal

   }




    
    


}

interface IBalancerVault {
    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;

    struct JoinPoolRequest {
        IAsset[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    enum JoinKind { 
    INIT, 
    EXACT_TOKENS_IN_FOR_BPT_OUT, 
    TOKEN_IN_FOR_EXACT_BPT_OUT
 }

    
 function getPoolId() external view returns (bytes32);

 


}

interface IAsset {
   
}



