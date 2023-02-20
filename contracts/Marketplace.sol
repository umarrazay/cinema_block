// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Marketplace is ERC721Holder {
    
    using Counters for Counters.Counter;

    Counters.Counter private _listingId;

    struct FixedPriceItem
    {
        bool forSale;
        uint256 tokendId;
        uint256 listingId;
        uint256 nftPrice;
        address seller;
        address nftAddress;
        address royaltyReciever;

    }

    mapping(uint256 => FixedPriceItem) public mFixedPriceItemDetails;
    
    event efixedPriceListing(
        uint256 _tokenId, 
        uint256 _listingId, 
        address _nftaddress, 
        uint256 _nftPrice, 
        address _seller
    );

    function listItemForFixedPrice(address _nftAddress , uint256 _tokenid , uint256 _nftPrice) public returns(bool isListed)
    {

         uint256 listingId = _listingId.current();
        _listingId.increment();

        mFixedPriceItemDetails[listingId] = FixedPriceItem({
            forSale:true,
            tokendId: _tokenid,
            listingId: listingId,
            nftPrice:_nftPrice,
            seller:msg.sender,
            nftAddress:_nftAddress,
            royaltyReciever: address(0)
        });

        // FixedPriceItemDetails[listingId].forSale = true;     
        // FixedPriceItemDetails[listingId].tokendId = _tokenid;   
        // FixedPriceItemDetails[listingId].listingId = listingId;
        // FixedPriceItemDetails[listingId].nftPrice = _nftPrice;
        // FixedPriceItemDetails[listingId].seller = msg.sender;
        // FixedPriceItemDetails[listingId].nftAddress = _nftAddress;
        // FixedPriceItemDetails[listingId].royaltyReciever = address(0);

        IERC721(_nftAddress).transferFrom(msg.sender ,address(this) , _tokenid);    

        emit efixedPriceListing(_tokenid,listingId,_nftAddress,_nftPrice,msg.sender);
        return true;

    }
    














}