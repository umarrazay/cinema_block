// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface INFT
{
    function getMinter(uint256 _tokenid) external view returns(address _minterAddress) ;
    function getRoyaltyPercentage(uint256 _tokenid , address _address) external view returns(uint256 _royaltyPercentage);
}

contract Marketplace is ERC721Holder {
    
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _listingId;

    // State Variables

    INFT private inft;
    uint256 private platformFee = 250;
    uint256 private royaltyFee  = 150;
    address public NFTcontract;
    address public MarketPlaceOwner = msg.sender;

    constructor(address _NFTcontract)
    {
        NFTcontract  = _NFTcontract;  
    }

    

    // Errors Defined

    string public constant REVERT_PAY_EXACT_PRICE = "Marketplace:: pay exact price ";

    struct FixedPriceItem
    {
        bool isSold;
        bool forSale;
        uint256 tokendId;
        uint256 listingId;
        uint256 nftPrice;
        uint256 royaltyfee;
        address seller;
        address nftAddress;
        address royaltyReciever;

    }

    mapping(uint256 => FixedPriceItem) public mFixedPriceItem;
    
    event efixedPriceListing(
        uint256 _tokenId, 
        uint256 _listingId, 
        address _nftaddress, 
        uint256 _nftPrice, 
        address _seller
    );

    function listItemForFixedPrice(address _nftAddress , uint256 _tokenid , uint256 _nftPrice) public returns(bool isListed)
    {
        inft = INFT(_nftAddress);


         uint256 listingId = _listingId.current();
        _listingId.increment();

        uint256 royaltyfees = inft.getRoyaltyPercentage(_tokenid, _nftAddress);
        address royaltyReciever = inft.getMinter(_tokenid);

        mFixedPriceItem[listingId] = FixedPriceItem({
            isSold:false,
            forSale:true,
            tokendId: _tokenid,
            listingId: listingId,
            nftPrice:_nftPrice,
            royaltyfee:royaltyfees,
            seller:msg.sender,
            nftAddress:_nftAddress,
            royaltyReciever: royaltyReciever
        });

        IERC721(_nftAddress).transferFrom(msg.sender ,address(this) , _tokenid);    

        emit efixedPriceListing(_tokenid,listingId,_nftAddress,_nftPrice,msg.sender);
        return true;

    }

    event eBuyFixedPriceItem(
        uint256 _listingid,
        uint256 _tokenid,
        uint256 _nftPrice,
        address _buyer,
        address _seller
    );

    function calculatePlatformFee(uint256 _nftprice , uint256 _pbp) public pure returns(uint256)
    {
        uint256 platformfee = _nftprice.mul(_pbp).div(10000);
        return platformfee;
    }
    function calculateRoyaltyFee(uint256 _nftprice , uint256 _pbp) public pure returns(uint256)
    {
        uint256 royaltyfee = _nftprice.mul(_pbp).div(10000);
        return royaltyfee;
    }

    function buyFixedPriceItem(uint256 _listingid) public payable returns(bool isBought)
    {
        uint256 tokenid  = mFixedPriceItem[_listingid].tokendId;
        uint256 nftPrice = mFixedPriceItem[_listingid].nftPrice;
        address sellers  = mFixedPriceItem[_listingid].seller;  

        require(msg.value == nftPrice , REVERT_PAY_EXACT_PRICE);

        uint256 platformfee = calculatePlatformFee(msg.value,platformFee);  
        uint256 royaltyfes = calculateRoyaltyFee(msg.value, royaltyFee);
        uint256 totalFeeCharge = platformFee + royaltyfes;
        uint256 amountPayToSeller = msg.value.sub(totalFeeCharge);

        payable(MarketPlaceOwner).transfer(platformfee);
        payable(sellers).transfer(amountPayToSeller);


        
        IERC721(mFixedPriceItem[_listingid].nftAddress).transferFrom(address(this),msg.sender,tokenid);


        emit eBuyFixedPriceItem(_listingid,tokenid,msg.value,msg.sender,sellers) ;
        return true;
    }
    
}