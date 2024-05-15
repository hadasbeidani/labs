//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract english_auction {

address public owner; 
address public auction_owner; 

bool public started = false; 
uint256 public endAt; 
bool public ended = false; 
address public highestBidder; 
uint256 public highestBid; 

// mapping(address => uint256) public bids;
IERC20 public immutable Token;
IERC271 public immutable NFTToken;
uint public token_id;

event Start(uint256 indexed start_date, string desc);//memory....???c
event End(uint256 indexed end_date, string desc);
event Bid(uint256 indexed currentHighestBid, string desc);
// event Withdraw(uint256 indexed withdraw, string desc);

    constractor(address _Token, address _NFTToken){
        owner = msg.sender;
        Token = IERC20(_Token);
        NFTToken = IERC721(_NFTToken);
        //??????????????????????????
        //לבדוק איך ואם צריך שבעל החוזה ימשוך את כספו וכן אם עולה כסף להשתמש בחוזה -ליצור מכירה חדשה 
        //אם כן איך לוקחים את התשלום מאיפה ולאן
        //מציע משלם כסף לחוזה או למי 
    }
    receive() external payable {}

    function startAuction(uint256 starting_bid, uint256 end_date_in_x_days, uint _token_id) external {
        require(ended == true, "an auction is in progress");
        ended = false;
        started = true;
        endAt = block.timestamp + end_date_in_x_days;

        auction_owner = msg.sender;
        token_id = _token_id;
        highestBid = starting_bid;
        NFTToken.transferFrom(msg.sender, address(this), token_id)//passing the nft to the contract
        //need checking about the nft id - that is right ????
        emit Start(block.timestamp, "start english auction"); 
    }
    function endAt()returns (uint256) external {
        return endAt;
    }
    function Bid(uint256 bid) external {
        require(started == true && ended == false, "invalid date");
        require(bid > 0, "bid is 0");
        require(x.balanceOf(msg.sender) >= bid, "you dont have enough eth");
        require(bid > highestBid || address(0) && bid = highestBid, "invalid bid");
        //require(bids[msg.sender] < bid, "you can not decrease your bid");

        //return the money to the previous bidder
        Token.transferFrom(address(this), highestBidder, highestBid);

        Token.transferFrom(msg.sender, address(this), bid);
        highestBidder = msg.sender;
        highestBid = bid;

        // bids[msg.sender] = bid;
        //אם רלוונטי אז לשמור את ההצעה הקודמת
        emit Bid(highestBid, "the current highest bid"); 
    }
    function endAuction(uint256 starting_bid) external {
        require(block.timestamp >= endAt, "the auction has not yet closed");
        ended = true;
        if (highestBidder = address(0)){
            NFTToken.transferFrom(address(this), auction_owner, token_id);
        }
        else{
            NFTToken.transferFrom(address(this), highestBidder, token_id);
            Token.transferFrom(highestBidder, auction_owner, highestBid);
        }

        //לאפס בשביל המכירה הבאה 
        highestBidder = address(0);
        highestBid = 0;
        emit End(block.timestamp, "end english auction"); 
    }
    // function withdraw(){
    //     require(bids[msg.sender] > 0, "you did not take part in the auction");
    //     require(msg.sender != highestBidder, "you can not do withdraw action");
    //     x.transferFrom(address(this), msg.sender, bids[msg.sender]);
    //     //?? להסיר אותו מהמיפוי
    //     emit Withdraw(highestBid, "the current highest bid"); 
    // }

}