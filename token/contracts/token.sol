// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "OpenZeppelin/openzeppelin-contracts@4.7.3/contracts/token/ERC20/ERC20.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.3/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "OpenZeppelin/openzeppelin-contracts@4.7.3/contracts/access/Ownable.sol";

import "contracts/whitelist.sol";

contract Maxima is ERC20, Whitelist {
    // Mint
    uint256 private _maxSupply;

    // Swap
    address public pancakeSwapRouter;
    address public pancakeSwapV2Pair;

    // slippage
    address public slippagePool;
    uint256 public sellSlippage = 3;
    uint256 public buySlippage = 3;

    constructor(string memory name_, string memory symbol_, uint256 maxSupply_)
        ERC20(name_, symbol_)
    {
        // Init max supply
        _maxSupply = maxSupply_;

        // Init slippage pool
        setSlippagePool(_msgSender());
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function setSwap(address router, address lp) public onlyOwner {
        pancakeSwapRouter = router;
        pancakeSwapV2Pair = lp;
    }

    // set slippage pool
    function setSlippagePool(address pool) public onlyOwner {
        slippagePool = pool;
    }

    // set sell slippage
    function setSellSlippage(uint256 newSlippage) public onlyOwner {
        sellSlippage = newSlippage;
    }

    // set buy slippage
    function setBuySlippage(uint256 newSlippage) public onlyOwner {
        buySlippage = newSlippage;
    }

    // sell slippage view
    function getSellSlippage() public view returns (uint256) {
        return sellSlippage;
    }
    // buy slippage view
    function getBuySlippage() public view returns (uint256) {
        return buySlippage;
    }
    // slippage pool view
    function getSlippagePool() public view returns (address) {
        return slippagePool;
    }

    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        require(totalSupply() + amount <= _maxSupply, "Exceeds max supply");
        _mint(to, amount);
        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();

        // no slippage if in whitelist
        if (isInWhitelist(owner) || isInWhitelist(to)) {
            _transfer(owner, to, amount);
            return true;
        }

        // Pancake Swap Buy
        if (owner == pancakeSwapV2Pair) {
            _tokenTransferBuy(owner, to, amount);
            return true;
        }

        // no slippage needed
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        if (
            isInWhitelist(from) || isInWhitelist(spender) || isInWhitelist(to)
        ) {
            _transfer(from, to, amount);
            return true;
        }

        // Pancake Swap Sell
        if (to == pancakeSwapV2Pair && spender == pancakeSwapRouter) {
            _tokenTransferSell(from, to, amount);
            return true;
        }

        _transfer(from, to, amount);
        return true;
    }

    function _tokenTransferSell(
        address from,
        address to,
        uint256 amount
    ) private {
        // slippage amount
        uint256 slippageAmount = (amount * sellSlippage) / 100;

        // Remaining amount after deducting slippage
        uint256 toAmount = amount - slippageAmount;

        _transfer(from, slippagePool, slippageAmount);
        _transfer(from, to, toAmount);
    }

    function _tokenTransferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        // slippage amount
        uint256 slippageAmount = (amount * buySlippage) / 100;

        // Remaining amount after deducting slippage
        uint256 toAmount = amount - slippageAmount;

        _transfer(from, slippagePool, slippageAmount);
        _transfer(from, to, toAmount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {}
}
